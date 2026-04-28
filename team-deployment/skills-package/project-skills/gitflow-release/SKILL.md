---
name: "gitflow-release"
description: "GitFlow release branch lifecycle: prepare, finalize, tag, and publish a release"
domain: "version-control"
confidence: "high"
source: "manual"
triggers: [release branch, start release, finish release, gitflow release, prepare release, publish release, version bump, tag release, release candidate]
roles: [lead, devops, developer]
---

## Context

Release branches freeze a snapshot of `develop` for release preparation. Only bug fixes, documentation, and version bumps go into a release branch — **no new features**. When ready, it merges into both `main` (to publish) and `develop` (to sync the fixes back).

**When to create a release branch:** when `develop` has all the features for the next release and you need a stabilization period before going live.

## Starting a Release

```bash
# Ensure develop is up to date and stable
git checkout develop
git pull origin develop

# Create release branch (always named with the target version)
git checkout -b release/2.1.0

# Push immediately
git push -u origin release/2.1.0
```

## Preparing the Release

On the release branch, perform only:

1. **Version bump** — update version in `package.json`, `pyproject.toml`, `pom.xml`, etc.
2. **Changelog update** — document what's in this release.
3. **Bug fixes only** — any bugs found during QA. No new features.
4. **Documentation** — update README, API docs if needed.

```bash
# Example: bump version in package.json
npm version 2.1.0 --no-git-tag-version
# or edit manually: "version": "2.1.0"

git add .
git commit -m "chore: bump version to 2.1.0"
git push
```

**If bugs are found during QA**, fix them on the release branch:

```bash
git add .
git commit -m "fix: resolve edge case in payment processing"
git push
```

Those fixes will flow back to `develop` when the release is finished.

## Finishing a Release

This is the critical step. The release branch must merge into **both** `main` and `develop`.

### Step 1: Merge into main

```bash
git checkout main
git pull origin main
git merge --no-ff release/2.1.0 -m "chore: release 2.1.0"
```

### Step 2: Tag the release on main

```bash
git tag -a v2.1.0 -m "Release 2.1.0"
```

### Step 3: Push main and tag

```bash
git push origin main
git push origin v2.1.0
```

### Step 4: Merge back into develop

```bash
git checkout develop
git pull origin develop
git merge --no-ff release/2.1.0 -m "chore: merge release/2.1.0 back into develop"
git push origin develop
```

### Step 5: Delete the release branch

```bash
git branch -d release/2.1.0
git push origin --delete release/2.1.0
```

### Step 6: Create GitHub Release (if applicable)

```bash
gh release create v2.1.0 \
  --title "v2.1.0" \
  --notes "$(cat CHANGELOG.md | head -50)" \
  --latest
```

## Complete Example

```bash
# Start
git checkout develop && git pull origin develop
git checkout -b release/3.0.0
git push -u origin release/3.0.0

# Prepare
npm version 3.0.0 --no-git-tag-version
git add . && git commit -m "chore: bump version to 3.0.0"
git push

# Finish: merge to main
git checkout main && git pull origin main
git merge --no-ff release/3.0.0 -m "chore: release 3.0.0"
git tag -a v3.0.0 -m "Release 3.0.0"
git push origin main && git push origin v3.0.0

# Finish: sync develop
git checkout develop && git pull origin develop
git merge --no-ff release/3.0.0 -m "chore: merge release/3.0.0 back into develop"
git push origin develop

# Cleanup
git branch -d release/3.0.0
git push origin --delete release/3.0.0

# GitHub Release
gh release create v3.0.0 --title "v3.0.0" --notes "Release notes" --latest
```

## Checklist Before Finishing

- [ ] All planned features are merged into `develop` before the release branch was created
- [ ] Version number updated in all relevant files
- [ ] Changelog is up to date
- [ ] All tests pass on the release branch
- [ ] QA / staging sign-off obtained
- [ ] No new features added to release branch (bugs only)

## Anti-Patterns

- ❌ Adding new features to a release branch — feature freeze means no new features
- ❌ Branching release from `main` — always from `develop`
- ❌ Forgetting to merge back into `develop` — causes develop to lose the release fixes
- ❌ Not tagging on `main` after merge — every release on main must have an annotated tag
- ❌ Creating a release branch too early — wait until `develop` has all the planned features
- ❌ Keeping the release branch alive after finish — delete it immediately
- ❌ Merging `develop` updates into the release branch — the branch is frozen; merge nothing in
