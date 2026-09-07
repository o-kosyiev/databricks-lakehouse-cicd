"""Pure DataFrame transformations for bronze, silver, and gold layers."""

from pyspark.sql import DataFrame, Window
from pyspark.sql import functions as F


def add_bronze_metadata(events: DataFrame) -> DataFrame:
    """Add ingestion metadata without changing the source fields."""
    return events.withColumns(
        {
            "ingested_at": F.current_timestamp(),
            "source_file": F.coalesce(F.input_file_name(), F.lit("inline")),
        }
    )


def curate_events(bronze: DataFrame) -> DataFrame:
    """Normalize values, reject malformed rows, and keep the latest event version."""
    normalized = bronze.select(
        F.trim("event_id").alias("event_id"),
        F.lower(F.trim("device_id")).alias("device_id"),
        F.try_to_timestamp("event_time").alias("event_time"),
        F.lower(F.trim("metric_name")).alias("metric_name"),
        F.col("metric_value").cast("double").alias("metric_value"),
        F.upper(F.trim("region")).alias("region"),
        "ingested_at",
        "source_file",
    ).where(
        F.col("event_id").isNotNull()
        & F.col("device_id").isNotNull()
        & F.col("event_time").isNotNull()
        & F.col("metric_name").isNotNull()
        & F.col("metric_value").isNotNull()
    )

    latest_first = Window.partitionBy("event_id").orderBy(F.col("ingested_at").desc())
    return (
        normalized.withColumn("row_number", F.row_number().over(latest_first))
        .where(F.col("row_number") == 1)
        .drop("row_number")
    )


def aggregate_daily_metrics(silver: DataFrame) -> DataFrame:
    """Produce deterministic daily aggregates for analytics consumers."""
    return (
        silver.withColumn("event_date", F.to_date("event_time"))
        .groupBy("event_date", "region", "metric_name")
        .agg(
            F.countDistinct("event_id").alias("event_count"),
            F.round(F.avg("metric_value"), 4).alias("average_value"),
            F.min("metric_value").alias("minimum_value"),
            F.max("metric_value").alias("maximum_value"),
        )
    )
