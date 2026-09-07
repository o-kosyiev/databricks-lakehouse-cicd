# Operations

## Operational signals

| Signal | Alert condition |
|---|---|
| Job success rate | Any failed production run |
| Data freshness | Gold watermark exceeds agreed lag |
| Quality rejection | Any key-quality gate failure |
| Runtime | Material deviation from rolling baseline |
| Cost | Unexpected DBU or storage growth |

Reprocessing starts from an immutable landing input. Bronze is append-only, silver uses a deterministic key merge, and gold is fully derivable from silver.
