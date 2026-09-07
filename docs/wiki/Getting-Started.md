# Getting Started

## Offline workflow

```bash
python3.13 -m venv .venv
source .venv/bin/activate
python -m pip install --require-hashes -r requirements-dev.lock
./scripts/validate-ci.sh
```

## Cloud workflow

1. Deploy the Azure stack.
2. Connect an approved runner to the private network.
3. Apply Unity Catalog configuration.
4. Configure separate deployment and runtime service principals.
5. Upload only the synthetic fixture to the landing volume.
6. Validate and deploy the `dev` bundle target.
7. Run the job and inspect data-quality output before promotion.
