empty_branch: purpose and usage

This branch is intentionally empty and is used by the CI workflow as the base for publishing release binaries.

How the CI uses `empty_branch`
- When a push to a `release/*` branch completes the Release configuration build, the workflow runs a post-build script.
- The post-build script clones the repository, checks out `empty_branch` (creating it as an orphan if it does not exist), and then creates a new branch named `release_binaries/<release-suffix>` based on `empty_branch`.
- Build artifacts from the Release build (copied from `sample_program/x64/Release`) are placed into the root of the new `release_binaries/<release-suffix>` branch, committed, and pushed to the remote.

Why `empty_branch` exists
- Using an intentionally empty branch ensures that `release_binaries/*` branches contain only the published artifacts, with no other repository history or source files.
- This keeps binary-only branches small, focused, and easy to fetch.

Security and permissions
- The workflow uses the `GITHUB_TOKEN` (with `contents: write` permission) to create and push the `release_binaries/*` branches. If your repo policy restricts the token, you may need to provide a dedicated PAT.

Notes for maintainers
- If you prefer the artifacts to be stored as GitHub Releases or in a storage bucket instead of `release_binaries/*` branches, update the workflow script (`scripts/publish_release_binaries.ps1`) accordingly.
