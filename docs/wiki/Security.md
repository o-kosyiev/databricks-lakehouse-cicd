# Security

```mermaid
flowchart LR
  ADO[Azure DevOps] -->|Federated OIDC token| Entra[Microsoft Entra ID]
  Entra --> Deploy[Deployment principal]
  Deploy --> Bundle[Bundle-owned jobs]
  Runtime[Runtime principal] --> Catalog[Workload catalog]
  Connector[Access connector] --> Storage[One ADLS account]
  Internet -. no route .-> Storage
```

| Risk | Mitigation |
|---|---|
| Token leakage | Workload identity federation; no personal access token |
| Data exfiltration | Private endpoints, no-public-IP compute and catalog isolation |
| Privilege coupling | Separate deployment, runtime and storage identities |
| Storage firewall | Default deny; only Azure trusted services bypass the rule set |
| Schema drift | Explicit schema and fail-closed quality gate |
| Supply-chain change | Locked dependencies and versioned wheel artifact |
