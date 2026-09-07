# Medallion Architecture

```mermaid
flowchart LR
  Landing[Immutable JSON landing] --> Bronze[Bronze: raw plus metadata]
  Bronze --> Gate1{Parse and required fields}
  Gate1 --> Silver[Silver: normalized and deduplicated]
  Silver --> Gate2{Unique non-null event ID}
  Gate2 --> Gold[Gold: daily metrics]
```

| Field | Bronze | Silver | Gold |
|---|---|---|---|
| Event key | Source string | Trimmed and unique | Distinct count |
| Event time | String | Timestamp | Event date |
| Metric | Source case | Lowercase | Grouping dimension |
| Region | Source case | Uppercase | Grouping dimension |
| Ingestion metadata | Added | Preserved | Not exposed |
