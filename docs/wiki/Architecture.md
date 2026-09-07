# Architecture

```mermaid
flowchart TB
  subgraph Azure[Azure subscription]
    VNet[Injected VNet]
    DBW[Private Databricks workspace]
    ADLS[Private ADLS Gen2]
    Connector[Access connector identity]
    PE[Private endpoints and DNS]
  end
  subgraph Governance[Unity Catalog]
    Credential[Storage credential]
    Location[External location]
    Catalog[Workload catalog]
    Schema[Schema and volume]
  end
  VNet --> DBW
  DBW --> Governance
  Connector --> ADLS
  PE --> DBW
  PE --> ADLS
  Credential --> Connector
  Location --> ADLS
  Catalog --> Location
  Schema --> Catalog
```

| Plane | Ownership |
|---|---|
| Azure infrastructure | Platform team |
| Databricks account and metastore | Data platform administrators |
| Workload catalog and bundle | Data engineering team |
| Runtime data | Environment-specific job identity |
