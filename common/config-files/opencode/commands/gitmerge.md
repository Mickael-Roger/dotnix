---
description: Merge the current repository state into remote main
agent: git
subtask: true
---

Merge the current repository state into the remote `main` branch.

Optional instruction:
$ARGUMENTS

Objective:
Make sure the current code is present on remote `main`.

Behavior:
- Inspect the repo state: branch, uncommitted changes, unpushed commits, remotes, and hosting provider.
- If needed, create or reuse a suitable branch.
- Commit any uncommitted changes with a clear message.
- Push the branch or push directly to `main` when safe and allowed.
- If direct push is not appropriate, open a GitHub PR or GitLab MR targeting `main`, then merge it when possible.
- Verify that remote `main` contains the changes.

Constraints:
- Do not lose or overwrite user work.
- Do not force push unless explicitly requested.
- If blocked by auth, permissions, checks, or branch protection, explain the blocker and the next required action.
