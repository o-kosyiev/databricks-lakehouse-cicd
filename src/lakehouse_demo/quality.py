"""Small, fail-closed data-quality checks used before publishing tables."""

from dataclasses import dataclass

from pyspark.sql import DataFrame
from pyspark.sql import functions as F


class DataQualityError(RuntimeError):
    """Raised when a publish-blocking data-quality rule fails."""


@dataclass(frozen=True)
class QualityResult:
    row_count: int
    null_key_count: int
    duplicate_key_count: int

    @property
    def passed(self) -> bool:
        return self.row_count > 0 and self.null_key_count == 0 and self.duplicate_key_count == 0


def evaluate_keys(frame: DataFrame, key: str) -> QualityResult:
    """Evaluate presence, nullability, and uniqueness of a business key."""
    row_count = frame.count()
    null_key_count = frame.where(F.col(key).isNull()).count()
    duplicate_sum_row = (
        frame.groupBy(key).count().where(F.col("count") > 1).select(F.sum("count"))
    ).first()
    duplicate_key_count = (
        0 if duplicate_sum_row is None or duplicate_sum_row[0] is None else duplicate_sum_row[0]
    )
    return QualityResult(row_count, null_key_count, int(duplicate_key_count))


def require_valid_keys(frame: DataFrame, key: str) -> QualityResult:
    result = evaluate_keys(frame, key)
    if not result.passed:
        raise DataQualityError(f"Data-quality gate failed for key {key}: {result}")
    return result
