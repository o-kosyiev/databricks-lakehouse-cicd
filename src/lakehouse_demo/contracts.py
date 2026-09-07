"""Explicit input and curated schemas for the lakehouse pipeline."""

from pyspark.sql.types import DoubleType, StringType, StructField, StructType, TimestampType

RAW_EVENT_SCHEMA = StructType(
    [
        StructField("event_id", StringType(), nullable=False),
        StructField("device_id", StringType(), nullable=False),
        StructField("event_time", StringType(), nullable=False),
        StructField("metric_name", StringType(), nullable=False),
        StructField("metric_value", DoubleType(), nullable=False),
        StructField("region", StringType(), nullable=False),
    ]
)

SILVER_EVENT_SCHEMA = StructType(
    [
        StructField("event_id", StringType(), nullable=False),
        StructField("device_id", StringType(), nullable=False),
        StructField("event_time", TimestampType(), nullable=False),
        StructField("metric_name", StringType(), nullable=False),
        StructField("metric_value", DoubleType(), nullable=False),
        StructField("region", StringType(), nullable=False),
        StructField("ingested_at", TimestampType(), nullable=False),
        StructField("source_file", StringType(), nullable=False),
    ]
)
