# Design Decisions

| Decision | Choice | Reason |
|---|---|---|
| Deployment unit | One focused bundle | Shared lifecycle for code, wheel and job |
| Environment model | Targets in one bundle | Prevents configuration copy/paste drift |
| Storage access | Access connector managed identity | Passwordless Unity Catalog access |
| Processing model | Bronze append, silver MERGE, gold rebuild | Replayable and understandable behavior |
| Runtime | Databricks Runtime 18 LTS | Supported Spark 4.1 baseline |
| Local PySpark | Pin 4.1.x while Runtime 18 LTS uses Spark 4.1 | Prevents tests from drifting ahead of the managed runtime |
| CI platform | Azure DevOps WIF | Demonstrates secretless Azure-native promotion |
