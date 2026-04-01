# Global Agent Guidelines

This file (`AGENTS.md`) defines global rules and best practices for all projects. If a local `AGENTS.md` does not exist or is empty, create one based on the project's content and these guidelines.

## IMPORTANT

- Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.
- Always use the TodoWrite tool to plan and track tasks throughout the conversation.
- Always use LSP tools (definition, references, symbols, types) to analyze the codebase. Do not rely on guesses or plain text search when LSP is available.
- Always prioritize using a dedicated subagent for a task whenever one exists, even if a CLI or direct method could also accomplish it.
- Before running git add or committing after modifying code, you must perform both a code review and a security analysis using @review and @security-review, and only consider the task complete once these checks are finished.


## Long-Term Memory

You have access to persistent memory tools (`memory_*`). Memory survives across sessions and provides continuity. Use it **proactively** without waiting for the user to ask.

### When to STORE memories

Store a memory when any of the following occurs during conversation:

1. **User expresses a preference** - coding style, tool choice, naming convention, formatting, workflow habit, etc.
   - Example: "I prefer ruff over black" -> store `"User prefers ruff over black for Python formatting"`
2. **User corrects you** - if the user says "no, do it this way", that correction is a preference worth remembering.
3. **A lesson is learned** - a bug was hard to find, a pattern caused issues, a workaround was needed.
4. **User shares personal information** - facts about their life, opinions, habits, events, interests. This matters for chatbot mode.
5. **User discusses news or current events** - notable information the user finds interesting or relevant.
6. **Architecture/design decisions** - how the user likes to structure projects, patterns they favor.
7. **Tool or library preferences** - preferred frameworks, test runners, linters, package managers per language.
8. **Project knowledge** - key facts about projects the user works on (tech stack, purpose, constraints).

**After storing, briefly notify the user** with a short inline note, e.g.:
> Noted: you prefer dataclasses over pydantic for simple DTOs.

Do NOT ask for confirmation before storing. Just store and notify.

### When to RETRIEVE memories

Search memory **contextually** when a topic arises that might have prior context:

- **Before writing code**: search for preferences about the detected language, framework, or tools (e.g., `"python coding style"`, `"typescript preferences"`, `"preferred test framework"`).
- **Before architectural decisions**: search for design patterns and structural preferences.
- **When discussing a topic with personal context**: search for personal facts, opinions, or prior conversations about that topic.
- **When the user references something from the past**: search for related memories.
- **In chatbot/conversational mode**: search for personal context relevant to the discussion topic.

Use `search_memories` with descriptive queries. Cast a slightly wide net - it's better to retrieve and ignore than to miss relevant context.

### Memory Quality Rules

1. **Search before adding** - always search for existing memories on the same topic before creating a new one. If a relevant memory exists, **update it** instead of creating a duplicate.
2. **Keep memories atomic** - one clear fact per memory. Not paragraphs, not lists of mixed concerns.
   - Good: `"User prefers snake_case for Python variables and functions"`
   - Bad: `"User likes Python and prefers snake_case and uses pytest and doesn't like Java"`
3. **Use clear, searchable phrasing** - write memories as factual statements that will match semantic searches well.
   - Good: `"User prefers Go for CLI tools and system utilities"`
   - Bad: `"they said go is nice for cli stuff"`
4. **When a preference changes, update the old memory** - don't leave contradictory memories. Use `update_memory` with the existing memory's ID.
5. **Use metadata** for categorization on every memory:
   ```json
   {
     "category": "coding-style | tool-preference | architecture | lesson | personal | project | news",
     "language": "python | go | typescript | nix | ...",
     "topic": "free-form short tag"
   }
   ```
   - `category` is required. `language` and `topic` are optional but encouraged when applicable.

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
