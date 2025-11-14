Param(
    [string]$Workspace = $Env:GITHUB_WORKSPACE
)

# Exit on any error
$ErrorActionPreference = 'Stop'

Write-Host "Workspace: $Workspace"

# Determine branch that triggered the workflow
$ref = $Env:GITHUB_REF
if (-not $ref) {
    throw "GITHUB_REF is not set"
}

# GITHUB_REF for a branch looks like: refs/heads/release/1.2.3
if ($ref -notmatch 'refs/heads/(.+)') {
    throw "GITHUB_REF ($ref) does not look like a branch ref"
}

$branchName = $Matches[1]
Write-Host "Trigger branch: $branchName"

if ($branchName -notmatch '^release/') {
    Write-Host "Not a release branch; exiting"
    exit 0
}

# Extract last part after release/
$releaseSuffix = $branchName -replace '^release/', ''
Write-Host "Release suffix: $releaseSuffix"

# Local paths to artifacts in x64\Release
# Adjust filenames or paths if your build outputs different names.
$artifactFiles = @('sample_program\x64\Release\sample_program.o', 'sample_program\x64\Release\sample_program.json')
foreach ($f in $artifactFiles) {
    $full = Join-Path $Workspace $f
    if (-not (Test-Path $full)) {
        throw "Required artifact not found: $full"
    }
}

# Prepare repo clone to work in a clean repo state
$tempDir = Join-Path $Env:TEMP ([System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempDir | Out-Null
Write-Host "Using temp dir: $tempDir"

# Configure git
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global user.name "github-actions[bot]"

# Use the already-checked-out repository in $Workspace and create a worktree for the release binaries
$repo = $Env:GITHUB_REPOSITORY  # owner/repo
if (-not $repo) { throw "GITHUB_REPOSITORY not set" }

Push-Location $Workspace

# Ensure we have the latest refs
git fetch origin

# Ensure empty_branch exists on remote; if not, create it as an orphan and push
$emptyExists = (git ls-remote --heads origin empty_branch) -ne $null
if (-not $emptyExists) {
    Write-Host "empty_branch not found on remote, creating an orphan empty_branch locally and pushing"
    git checkout --orphan empty_branch
    git rm -rf . | Out-Null
    New-Item -ItemType File -Name README.md -Value "Empty branch for release binaries" | Out-Null
    git add README.md
    git commit -m "Create empty_branch"
    git push origin empty_branch
    # return to previous branch
    git checkout -
}

# Create a worktree from empty_branch and make our target branch there
# Use branch name: release_binaries/<suffix>
$targetBranch = "release_binaries/$releaseSuffix"
Write-Host "Creating worktree for: $targetBranch"

# If an existing worktree at $tempDir exists, remove it (unlikely)
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }

git worktree add -B $targetBranch $tempDir origin/empty_branch
Push-Location $tempDir

# Copy artifacts into repo root
foreach ($f in $artifactFiles) {
    $src = Join-Path $Workspace $f
    $dst = Join-Path $tempDir (Split-Path $f -Leaf)
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "Copied $src -> $dst"
}

# Commit and push
git add .
git commit -m "Add release binaries for $branchName"

git -c "http.extraheader=AUTHORIZATION: bearer $Env:GITHUB_TOKEN" push origin HEAD:refs/heads/$targetBranch --force

Pop-Location
Write-Host "Published release branch: $targetBranch"

# Cleanup
Remove-Item -Recurse -Force $tempDir
