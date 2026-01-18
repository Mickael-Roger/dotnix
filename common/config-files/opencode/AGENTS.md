# Global Agent Guidelines

This file (`AGENTS.md`) defines global rules and best practices for all projects. If a local `AGENTS.md` does not exist or is empty, create one based on the project's content and these guidelines.

---

## 1. Language and Documentation Standards
- **Always use English** for:
  - `README.md` and all markdown files
  - Code comments
  - Variable, function, and file names
  - Any project-related documentation

---

## 2. Local `AGENTS.md` Management
- **After any action** that modifies code or local files:
  - Update the local `AGENTS.md` if the change is relevant to the project (e.g., new features, bug fixes, configuration changes).
  - Ensure all relevant information is recorded in `AGENTS.md`.

---

## 3. File Organization
- **If `AGENTS.md` becomes too large** or its content can be logically split:
  - Split it into dedicated markdown files (e.g., `CODING_STYLE.md`, `SETUP.md`, `DEPENDENCIES.md`).
  - Reference these files in the main `AGENTS.md` under clear sections, e.g.:
    ```markdown
    ## Coding Style
    See [CODING_STYLE.md](CODING_STYLE.md) for detailed guidelines.
    ```

---

## 4. Error Handling and Learning
- **When a user points out an error or suboptimal action**:
  - If the issue is relevant and likely to recur, document it in:
    - The local `AGENTS.md` (if not split)
    - The appropriate dedicated file (if split, e.g., `PITFALLS.md` or `LESSONS_LEARNED.md`)
  - Include:
    - A description of the issue
    - The correct approach or solution
    - Any context or examples to avoid repetition

---

## 5. Example Structure for Local `AGENTS.md`
```markdown
# Project-Specific Agent Guidelines

## Overview
- Purpose: [Brief description]
- Key files: [List and describe]

## Rules
- [Project-specific rules]

## Lessons Learned
- [Documented mistakes/improvements]

## See Also
- [CODING_STYLE.md](CODING_STYLE.md)
- [SETUP.md](SETUP.md)
