# Security Policy

Report vulnerabilities using GitHub private vulnerability reporting. Do not include credentials, workspace URLs, tenant identifiers, production table names, state files, or data samples from a real environment.

## Security invariants

- CI/CD uses workload identity federation, not personal tokens.
- Deployment and runtime service principals are separate.
- Compute has no public IP.
- Storage and workspace endpoints are private.
- Unity Catalog permissions are workload-scoped.
- Only synthetic fixtures are committed.
- Bundle targets contain variables rather than environment identifiers.

Before release, run secret detection against both the working tree and complete Git history, scan Terraform for high/critical misconfigurations, and audit locked Python dependencies.
