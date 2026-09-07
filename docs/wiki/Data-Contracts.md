# Data Contracts

The raw schema is declared in `contracts.py`. A valid input event contains:

| Field | Type | Rule |
|---|---|---|
| `event_id` | string | Required business key |
| `device_id` | string | Required and normalized to lowercase |
| `event_time` | ISO timestamp string | Must parse to a timestamp |
| `metric_name` | string | Required and normalized to lowercase |
| `metric_value` | double | Required numeric value |
| `region` | string | Required and normalized to uppercase |

Contract changes require compatibility analysis, tests, backfill instructions and an updated package version.
