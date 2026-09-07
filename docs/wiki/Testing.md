# Testing

| Test | Location | Purpose |
|---|---|---|
| Transformation tests | `tests/test_transforms.py` | Normalization, deduplication and aggregation |
| Quality tests | `tests/test_quality.py` | Unique, non-null business keys |
| Type and lint checks | `pyproject.toml` | Maintainable Python interfaces |
| Terraform validation | Both infrastructure stacks | Provider schema and dependency graph |
| Bundle validation | Authenticated pipeline | Bundle inheritance and workspace resolution |

Synthetic tests run with local Spark. Integration tests should use an isolated development catalog and delete test tables after execution.
