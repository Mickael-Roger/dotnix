# Global Agent Guidelines

This file (`AGENTS.md`) defines global rules and best practices for all projects. If a local `AGENTS.md` does not exist or is empty, create one based on the project's content and these guidelines.

## IMPORTANT


- Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.
- Always use the TodoWrite tool to plan and track tasks throughout the conversation.
- Always use LSP tools (definition, references, symbols, types) to analyze the codebase. Do not rely on guesses or plain text search when LSP is available.


## Language and Documentation Standards
- **Always use English** for:
  - `README.md` and all markdown files
  - Code comments
  - Variable, function, and file names
  - Any project-related documentation

## Local `AGENTS.md` Management
- **After any action** that modifies code or local files:
  - Update the local `AGENTS.md` if the change is relevant to the project (e.g., new features, bug fixes, configuration changes).
  - Ensure all relevant information is recorded in `AGENTS.md`.

## File Organization
- **If `AGENTS.md` becomes too large** (more than around 100 lines) or its content can be logically split:
  - Split it into dedicated markdown files (e.g., `CODING_STYLE.md`, `SETUP.md`, `DEPENDENCIES.md`).
  - Reference these files in the main `AGENTS.md` under clear sections, e.g.:
    ```markdown
    ## Coding Style
    See [CODING_STYLE.md](CODING_STYLE.md) for detailed guidelines.
    ```

## Error Handling and Learning
- **When a user points out an error or suboptimal action**:
  - If the issue is relevant and likely to recur, document it in:
    - The local `AGENTS.md` (if not split)
    - The appropriate dedicated file (if split, e.g., `PITFALLS.md` or `LESSONS_LEARNED.md`)
  - Include:
    - A description of the issue
    - The correct approach or solution
    - Any context or examples to avoid repetition

## Example Structure for Local `AGENTS.md`
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
