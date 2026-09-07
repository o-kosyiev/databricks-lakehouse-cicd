# Environment Promotion

Promote source and a versioned wheel, never mutable workspace files.

1. CI validates the commit and builds the wheel.
2. Development deployment runs integration checks.
3. Stage approval promotes the same commit.
4. Production approval promotes the same commit with production variables.
5. Record bundle identity and job run URL in the release evidence.

Rollback redeploys the previous known-good commit. Table contract rollbacks may require a forward data migration rather than code-only rollback.
