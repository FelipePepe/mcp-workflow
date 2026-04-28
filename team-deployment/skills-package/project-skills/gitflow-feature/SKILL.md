---
name: "gitflow-feature"
description: "GitFlow feature branch lifecycle: start, develop, finish, and publish a feature"
domain: "version-control"
confidence: "high"
source: "manual"
triggers: [feature branch, new feature, start feature, finish feature, gitflow feature, develop feature, feature workflow]
roles: [developer, backend, frontend, lead]
---

## Context

Feature branches are where all new work happens. They branch from `develop` and merge back into `develop` when complete. Never merge a feature directly into `main`.

A feature branch lives for the duration of one feature or user story. Once merged, delete it.

## Starting a Feature

```bash
# Always start from an up-to-date develop
git checkout develop
git pull origin develop

# Create the feature branch
git checkout -b feature/42-user-authentication

# Push and set upstream (do this early to back up work)
git push -u origin feature/42-user-authentication
```

If using GitHub/GitLab, create a **draft PR** targeting `develop` immediately after pushing:

```bash
gh pr create \
  --base develop \
  --title "feat: user authentication (#42)" \
  --body "Closes #42" \
  --draft
```

## During Development

Work normally on the feature branch. Commit often with meaningful messages:

```bash
git add .
git commit -m "feat(auth): add JWT token validation"
git push
```

**Keep up to date with `develop`** to minimize merge conflicts:

```bash
# Option A: Merge develop into feature (simpler, safer)
git fetch origin develop
git merge origin/develop

# Option B: Rebase onto develop (cleaner history, riskier if branch is shared)
git fetch origin develop
git rebase origin/develop
```

Prefer **merge** over rebase for shared feature branches. Use rebase only for local-only branches.

## Finishing a Feature

### Step 1: Final sync with develop

```bash
git checkout develop
git pull origin develop
git checkout feature/42-user-authentication
git merge origin/develop  # resolve any conflicts
git push
```

### Step 2: Mark PR as ready and get review

```bash
gh pr ready  # if using GitHub draft PRs
```

### Step 3: Merge into develop

Via PR (preferred — enables code review and CI):

```bash
# After PR approval, merge via GitHub UI or:
gh pr merge --merge --delete-branch
```

Manually (if not using PRs):

```bash
git checkout develop
git merge --no-ff feature/42-user-authentication \
  -m "feat: merge feature/42-user-authentication into develop"
git push origin develop
```

### Step 4: Clean up

```bash
# Delete local branch
git branch -d feature/42-user-authentication

# Delete remote branch (if not auto-deleted by PR merge)
git push origin --delete feature/42-user-authentication
```

## Examples

**Simple feature:**
```bash
git checkout develop && git pull origin develop
git checkout -b feature/dark-mode
# ... work ...
git push -u origin feature/dark-mode
# create PR → review → merge → delete branch
```

**Feature with issue number:**
```bash
git checkout develop && git pull origin develop
git checkout -b feature/134-export-csv
gh pr create --base develop --title "feat: export to CSV (#134)" --body "Closes #134" --draft
# ... work ...
gh pr ready
gh pr merge --merge --delete-branch
```

## Anti-Patterns

- ❌ Branching from `main` — always branch from `develop`
- ❌ Long-lived branches (> 2 weeks) — split large features into smaller deliverable chunks
- ❌ Merging directly to `main` — features only go into `develop`
- ❌ Force-pushing to a shared feature branch — coordinate with teammates first
- ❌ Skipping the sync step before finishing — always rebase or merge `develop` before PR
- ❌ Leaving stale feature branches after merge — delete immediately
