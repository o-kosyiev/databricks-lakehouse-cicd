# Unity Catalog

| Object | Purpose | Owner |
|---|---|---|
| Storage credential | Maps managed identity to storage | Platform administrator |
| External location | Restricts the workload storage root | Platform administrator |
| Catalog | Environment isolation boundary | Workload owner |
| Schema | Tables and volume namespace | Data engineering team |
| External volume | Landing files | Runtime identity |

The operator group receives only catalog/schema privileges needed to operate the demo. Production should assign ownership to service principals, not individuals.
