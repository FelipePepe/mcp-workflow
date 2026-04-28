---
name: "gitflow-hotfix"
description: "GitFlow hotfix branch lifecycle: patch a critical production bug without disrupting ongoing development"
domain: "version-control"
confidence: "high"
source: "manual"
triggers: [hotfix, hot fix, hotfix branch, production bug, critical bug, urgent fix, patch production, gitflow hotfix, emergency fix, production fix]
roles: [lead, developer, devops, backend]
---

## Context

Hotfix branches handle **critical production bugs** that can't wait for the next regular release. They branch from `main` (not `develop`) so the fix can be deployed immediately. When done, they merge into both `main` (to deploy the fix) and `develop` (to keep the fix in future releases).

**Use a hotfix when:** there is a bug in production (`main`) that is causing significant impact and must be resolved immediately, outside the normal release cycle.

## Starting a Hotfix

```bash
# Always branch from main (the production branch)
git checkout main
git pull origin main

# Create hotfix branch — name includes the patch version
git checkout -b hotfix/2.0.1

# Push immediately
git push -u origin hotfix/2.0.1
```

The patch version must be a valid semver increment over the last release on `main`.

```bash
# Check current version on main
git tag --sort=-version:refname | head -1
# e.g., v2.0.0  →  hotfix version will be v2.0.1
```

## Fixing the Bug

Work only on the specific bug. No scope creep — this is not a feature delivery.

```bash
# Bump version to the patch version
npm version 2.0.1 --no-git-tag-version
# or edit "version": "2.0.1" manually

git add .
git commit -m "chore: bump version to 2.0.1"

# Fix the bug
git add .
git commit -m "fix: prevent null pointer in payment handler (#501)"
git push
```

Keep commits minimal and focused. Document the root cause in the commit message.

## Finishing a Hotfix

Like releases, hotfixes must merge into **both** `main` and `develop`.

### Step 1: Merge into main

```bash
git checkout main
git pull origin main
git merge --no-ff hotfix/2.0.1 -m "chore: hotfix 2.0.1"
```

### Step 2: Tag on main

```bash
git tag -a v2.0.1 -m "Hotfix 2.0.1 — fix null pointer in payment handler"
```

### Step 3: Push main and tag

```bash
git push origin main
git push origin v2.0.1
```

### Step 4: Merge back into develop

```bash
git checkout develop
git pull origin develop
git merge --no-ff hotfix/2.0.1 -m "chore: merge hotfix/2.0.1 back into develop"
```

**If there is an open release branch**, merge into that instead of `develop` (the release branch will carry the fix into `develop` when it finishes):

```bash
# If release/2.1.0 exists, merge hotfix there instead
git checkout release/2.1.0
git merge --no-ff hotfix/2.0.1 -m "chore: merge hotfix/2.0.1 into release/2.1.0"
git push origin release/2.1.0
```

### Step 5: Push develop

```bash
git push origin develop
```

### Step 6: Delete the hotfix branch

```bash
git branch -d hotfix/2.0.1
git push origin --delete hotfix/2.0.1
```

### Step 7: Create GitHub Release

```bash
gh release create v2.0.1 \
  --title "v2.0.1 — Critical fix: null pointer in payment handler" \
  --notes "**Hotfix:** Resolves null pointer exception in the payment processing flow.\n\nAffected versions: v2.0.0" \
  --latest
```

## Complete Example

```bash
# Start
git checkout main && git pull origin main
git checkout -b hotfix/1.3.1
git push -u origin hotfix/1.3.1

# Fix
npm version 1.3.1 --no-git-tag-version
git add . && git commit -m "chore: bump version to 1.3.1"

# ... make the fix ...
git add . && git commit -m "fix: resolve race condition in session cleanup (#308)"
git push

# Finish: merge to main
git checkout main && git pull origin main
git merge --no-ff hotfix/1.3.1 -m "chore: hotfix 1.3.1"
git tag -a v1.3.1 -m "Hotfix 1.3.1 — race condition in session cleanup"
git push origin main && git push origin v1.3.1

# Finish: sync develop (or active release branch)
git checkout develop && git pull origin develop
git merge --no-ff hotfix/1.3.1 -m "chore: merge hotfix/1.3.1 back into develop"
git push origin develop

# Cleanup
git branch -d hotfix/1.3.1
git push origin --delete hotfix/1.3.1

# GitHub Release
gh release create v1.3.1 \
  --title "v1.3.1 — Hotfix: race condition in session cleanup" \
  --notes "Critical fix for race condition reported in #308." \
  --latest
```

## Active Release Branch Scenario

If a `release/x.y.z` branch is open when the hotfix is needed:

```
main (v2.0.0) ──── hotfix/2.0.1 ────► main (v2.0.1, tag)
                         └──────────► release/2.1.0 (instead of develop)
                                           └──► develop (when release finishes)
```

```bash
# After merging hotfix to main and tagging...
git checkout release/2.1.0
git pull origin release/2.1.0
git merge --no-ff hotfix/2.0.1 -m "chore: incorporate hotfix/2.0.1"
git push origin release/2.1.0
# Do NOT merge to develop directly — let the release branch carry it
```

## Checklist Before Starting

- [ ] Confirmed bug is in production (`main`), not just in `develop`
- [ ] Severity justifies a hotfix (not every bug is a hotfix)
- [ ] Identified the exact patch version number (valid semver increment)
- [ ] Informed the team that a hotfix is in progress

## Checklist Before Finishing

- [ ] Bug is fixed and verified locally
- [ ] Version bumped in all relevant files
- [ ] Tests pass
- [ ] Merging into `main` + `develop` (or active release branch)
- [ ] Annotated tag created on `main`
- [ ] Hotfix branch deleted after merge

## Anti-Patterns

- ❌ Branching hotfix from `develop` — always from `main`
- ❌ Adding unrelated changes — scope is strictly the production bug only
- ❌ Forgetting to merge back into `develop` — future releases will re-introduce the bug
- ❌ Not tagging after merging to `main` — every production change needs a tag
- ❌ Using hotfix for non-critical bugs — if it can wait for the next release, it should wait
- ❌ Leaving the hotfix branch open after merging — delete immediately
- ❌ Skipping version bump — every hotfix release needs a new patch version
