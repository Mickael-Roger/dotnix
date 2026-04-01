---
description: Manage long-term memories (list, search, delete, summarize, stats)
subtask: true
---

# Memory Management Command

Manage the agent's long-term memory. Parse the user's arguments to determine the subcommand.

Arguments from the user:
```
$ARGUMENTS
```

## Subcommands

### No arguments or `list`
List all stored memories, paginated (20 per page). Display each memory as:
```
[ID: <short_id>] [<category>] <text>
  Created: <date> | Language: <language> | Topic: <topic>
```
Where `short_id` is the first 8 characters of the memory ID. If metadata fields are absent, omit them.

### `search <query>`
Perform a semantic search using `search_memories` with the provided query. Display results ranked by relevance using the same format as `list`. Show the top 10 results.

### `delete <query_or_id>`
If the argument looks like a memory ID (UUID or partial UUID), delete that specific memory after showing it to the user.
If it's a text query, search for matching memories, display them, and ask the user which one(s) to delete. Support deleting multiple at once if the user confirms.

### `summarize`
Perform memory consolidation:

1. Retrieve ALL memories using `get_memories` (paginate if needed).
2. Analyze them and identify:
   - **Duplicates**: memories that say essentially the same thing.
   - **Mergeable groups**: closely related memories on the same topic that could be combined into a richer single memory (e.g., 3 separate Python style preferences -> 1 consolidated Python coding style memory).
   - **Outdated**: memories that appear contradicted by newer ones.
3. Present the proposed changes to the user in a clear table:
   ```
   ## Proposed Memory Consolidation

   ### Merge (X groups)
   - Group 1: "Python coding style"
     - [id1] "User prefers snake_case..."
     - [id2] "User wants imports at top..."
     -> Proposed merged memory: "User's Python style: snake_case naming, imports always at top of file, ..."

   ### Delete as duplicate (X memories)
   - [id3] duplicates [id4]

   ### Delete as outdated (X memories)
   - [id5] contradicted by [id6]
   ```
4. **Wait for user approval** before making ANY changes. The user may accept all, reject all, or cherry-pick.
5. Only after explicit approval, execute the merges (create new + delete old) and deletions.

### `stats`
Show memory statistics:
- Total number of memories
- Breakdown by category (from metadata)
- Breakdown by language (from metadata)
- Date range (oldest to newest)
- Number of memories without metadata (suggest adding metadata to these)
