import pytest

from lakehouse_demo.quality import DataQualityError, evaluate_keys, require_valid_keys


def test_quality_gate_accepts_unique_non_null_keys(spark) -> None:  # type: ignore[no-untyped-def]
    frame = spark.createDataFrame([("a",), ("b",)], ["event_id"])
    result = require_valid_keys(frame, "event_id")
    assert result.passed


def test_quality_gate_rejects_duplicate_keys(spark) -> None:  # type: ignore[no-untyped-def]
    frame = spark.createDataFrame([("a",), ("a",)], ["event_id"])
    result = evaluate_keys(frame, "event_id")
    assert result.duplicate_key_count == 2
    with pytest.raises(DataQualityError):
        require_valid_keys(frame, "event_id")
