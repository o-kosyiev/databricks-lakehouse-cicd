from datetime import UTC, datetime

from lakehouse_demo.transforms import aggregate_daily_metrics, curate_events


def test_curate_events_normalizes_and_deduplicates(spark) -> None:  # type: ignore[no-untyped-def]
    rows = [
        (
            "evt-1",
            " Sensor-A ",
            "2026-01-01T10:00:00Z",
            " Temperature ",
            21.5,
            "eu",
            datetime(2026, 1, 1, 10, 1, tzinfo=UTC),
            "a.json",
        ),
        (
            "evt-1",
            " Sensor-A ",
            "2026-01-01T10:00:00Z",
            " Temperature ",
            22.0,
            "eu",
            datetime(2026, 1, 1, 10, 2, tzinfo=UTC),
            "b.json",
        ),
        (
            "evt-2",
            "Sensor-B",
            "not-a-date",
            "humidity",
            45.0,
            "na",
            datetime(2026, 1, 1, 10, 3, tzinfo=UTC),
            "c.json",
        ),
    ]
    columns = [
        "event_id",
        "device_id",
        "event_time",
        "metric_name",
        "metric_value",
        "region",
        "ingested_at",
        "source_file",
    ]

    actual = curate_events(spark.createDataFrame(rows, columns)).collect()

    assert len(actual) == 1
    assert actual[0].device_id == "sensor-a"
    assert actual[0].metric_value == 22.0
    assert actual[0].region == "EU"


def test_gold_aggregation_is_grouped_by_day_region_and_metric(spark) -> None:  # type: ignore[no-untyped-def]
    rows = [
        ("evt-1", "a", datetime(2026, 1, 1, 10, 0), "temperature", 20.0, "EU"),
        ("evt-2", "b", datetime(2026, 1, 1, 11, 0), "temperature", 22.0, "EU"),
    ]
    columns = ["event_id", "device_id", "event_time", "metric_name", "metric_value", "region"]

    result = aggregate_daily_metrics(spark.createDataFrame(rows, columns)).collect()

    assert len(result) == 1
    assert result[0].event_count == 2
    assert result[0].average_value == 21.0
