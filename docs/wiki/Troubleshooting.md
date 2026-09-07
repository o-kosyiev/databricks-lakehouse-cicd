# Troubleshooting

| Symptom | Investigation |
|---|---|
| CLI cannot authenticate | Confirm command runs inside `AzureCLI@2` and the service connection uses federation |
| Workspace URL times out | Check runner private DNS, routing and private endpoint approval |
| Storage returns 403 | Check access connector identity, RBAC propagation and external location URL |
| Job cannot use catalog | Check runtime principal grants and workspace binding |
| MERGE fails | Validate target schema and duplicate source keys |
| Bundle validation differs by target | Inspect inherited target variables and production mode settings |
