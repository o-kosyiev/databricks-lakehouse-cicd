# Job Orchestration

The bundle deploys one queued job with a shared autoscaling job cluster.

| Task | Depends on | Failure behavior |
|---|---|---|
| `bronze_ingestion` | None | Stop workflow |
| `silver_curation` | Bronze | Stop if parsing or quality fails |
| `gold_aggregation` | Silver | Preserve previous gold table if task never starts |

The schedule is paused by default. Operators enable it only after the first controlled run and data-quality review.
