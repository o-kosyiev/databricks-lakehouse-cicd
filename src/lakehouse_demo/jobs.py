"""Databricks job entry points for each medallion layer."""

import argparse
import re
from collections.abc import Sequence

from pyspark.sql import SparkSession

from lakehouse_demo.contracts import RAW_EVENT_SCHEMA
from lakehouse_demo.quality import require_valid_keys
from lakehouse_demo.transforms import add_bronze_metadata, aggregate_daily_metrics, curate_events

TABLE_NAME = re.compile(r"^[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*){2}$")


def _table_name(value: str) -> str:
    if not TABLE_NAME.fullmatch(value):
        raise argparse.ArgumentTypeError("table names must use catalog.schema.table notation")
    return value


def _spark() -> SparkSession:
    return SparkSession.builder.appName("lakehouse-demo").getOrCreate()


def bronze_main(arguments: Sequence[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Ingest synthetic telemetry into bronze Delta")
    parser.add_argument("--source", required=True)
    parser.add_argument("--target-table", required=True, type=_table_name)
    options = parser.parse_args(arguments)

    spark = _spark()
    events = spark.read.schema(RAW_EVENT_SCHEMA).json(options.source)
    add_bronze_metadata(events).write.format("delta").mode("append").saveAsTable(
        options.target_table
    )


def silver_main(arguments: Sequence[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Curate and merge silver telemetry")
    parser.add_argument("--source-table", required=True, type=_table_name)
    parser.add_argument("--target-table", required=True, type=_table_name)
    options = parser.parse_args(arguments)

    spark = _spark()
    curated = curate_events(spark.table(options.source_table))
    require_valid_keys(curated, "event_id")
    curated.createOrReplaceTempView("silver_updates")
    # argparse validates the identifier against TABLE_NAME before interpolation.
    target_table = options.target_table

    spark.sql(
        f"CREATE TABLE IF NOT EXISTS {target_table} USING DELTA "  # noqa: S608
        "AS SELECT * FROM silver_updates WHERE false"
    )
    spark.sql(
        f"""  # noqa: S608
        MERGE INTO {target_table} AS target
        USING silver_updates AS source
          ON target.event_id = source.event_id
        WHEN MATCHED AND source.ingested_at >= target.ingested_at THEN UPDATE SET *
        WHEN NOT MATCHED THEN INSERT *
        """
    )


def gold_main(arguments: Sequence[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Publish daily gold aggregates")
    parser.add_argument("--source-table", required=True, type=_table_name)
    parser.add_argument("--target-table", required=True, type=_table_name)
    options = parser.parse_args(arguments)

    spark = _spark()
    gold = aggregate_daily_metrics(spark.table(options.source_table))
    gold.write.format("delta").mode("overwrite").option("overwriteSchema", "true").saveAsTable(
        options.target_table
    )
