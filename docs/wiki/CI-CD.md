# CI/CD

```mermaid
flowchart LR
  PR[Pull request] --> Validate[Lint, type-check and tests]
  Validate --> Build[Build versioned wheel]
  Build --> Scan[Dependency, secret and IaC scans]
  Scan --> Dev[Deploy dev bundle]
  Dev --> StageGate{Stage approval}
  StageGate --> Stage[Deploy same commit]
  Stage --> ProdGate{Production approval}
  ProdGate --> Prod[Deploy same commit]
```

| Stage | Identity | Mutable input allowed? |
|---|---|---|
| Validate | None | Source commit only |
| Dev deploy | Dev deployment principal | Environment variables |
| Stage deploy | Stage deployment principal | No artifact rebuild |
| Prod deploy | Production deployment principal | No artifact rebuild |

Azure DevOps environment checks provide human approval. The service connection uses workload identity federation and all Databricks commands execute inside `AzureCLI@2`.
