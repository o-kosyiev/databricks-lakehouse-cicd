# Contributing

Use a short-lived branch and include tests for every transformation or contract change. Run `./scripts/validate-ci.sh` before opening a pull request.

Data fixtures must be synthetic and small. Do not commit exported notebooks with results, workspace metadata, access tokens, organization URLs, state files, cluster logs, or generated bundle deployment directories.

Breaking table contract changes require a migration note and an update to the Wiki design decisions.
