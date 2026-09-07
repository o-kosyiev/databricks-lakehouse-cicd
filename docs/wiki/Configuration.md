# Configuration

| Source | Contains | Storage |
|---|---|---|
| `*.tfvars` | Azure and Unity Catalog environment values | Ignored local file or protected pipeline library |
| Bundle variables | Catalog, schema, host and runtime identity | Azure DevOps environment variables |
| Job parameters | Catalog and schema used by tasks | Bundle definition |
| Application code | Transform behavior and contracts | Git |

Never place workspace IDs, tenant IDs, access tokens, passwords, or production paths in `databricks.yml`.
