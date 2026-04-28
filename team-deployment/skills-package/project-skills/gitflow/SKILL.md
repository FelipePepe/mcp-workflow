---
name: "gitflow"
description: "GitFlow branching model: conventions, branch structure, and general rules"
domain: "version-control"
confidence: "high"
source: "manual"
triggers: [gitflow, git flow, branching model, branching strategy, branch model, develop branch, feature branch, release branch, hotfix]
roles: [lead, developer, backend, frontend, devops]
---

## Context

GitFlow is a branching model designed for projects with scheduled releases. It defines a strict branching structure where every type of work has a dedicated branch type with clear lifecycle rules.

**Use GitFlow when:** you need clear separation between stable code, in-progress features, and release preparation.

## Branch Structure

| Branch | Origin | Merges into | Purpose |
|--------|--------|-------------|---------|
| `main` | — | — | Production-ready code. Every commit is a release. |
| `develop` | `main` | — | Integration branch. Always reflects the latest delivered development. |
| `feature/*` | `develop` | `develop` | New features and non-emergency fixes. |
| `release/*` | `develop` | `main` + `develop` | Release preparation: version bumps, last-minute fixes. |
| `hotfix/*` | `main` | `main` + `develop` | Critical production bug fixes. |

## Naming Conventions

```
feature/short-description
feature/issue-42-user-auth
release/1.4.0
hotfix/1.3.1
hotfix/critical-login-bug
```

- Use kebab-case, all lowercase
- For feature branches, prefix with issue number when applicable: `feature/42-user-auth`
- Release and hotfix branches must include the version number: `release/2.1.0`, `hotfix/2.0.1`

## Core Rules

1. **Never commit directly to `main` or `develop`** — always use a branch and PR/merge.
2. **`main` is always deployable** — only merge tested, release-ready code.
3. **`develop` is the source of truth for next release** — all features merge here first.
4. **Merges use `--no-ff`** — preserves branch history and makes merges identifiable.
5. **Tags mark every release** — annotated tags on `main` after every release or hotfix.
6. **Releases and hotfixes merge into BOTH `main` AND `develop`** — keeps branches in sync.

## Initial Setup

For a new repository:

```bash
# Initialize with main and develop
git checkout -b develop
git push -u origin develop

# Set develop as the default branch in your git host for PRs
```

For an existing repository that doesn't have `develop`:

```bash
git checkout main
git pull origin main
git checkout -b develop
git push -u origin develop
```

## Anti-Patterns

- ❌ Branching features from `main` — always branch from `develop`
- ❌ Merging features directly to `main` — features go to `develop` only
- ❌ Long-lived feature branches (> 1 sprint) — leads to merge hell; break into smaller features
- ❌ Using fast-forward merges (`--ff`) for branch integration — loses history context
- ❌ Committing directly to `main` or `develop` — no exceptions, even for small fixes
- ❌ Forgetting to merge release/hotfix back into `develop` — causes divergence
- ❌ Creating release branches before `develop` is stable — stabilize first
