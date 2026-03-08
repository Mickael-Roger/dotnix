 ---
description: Archive this conversation
subtask: true
---

Create a markdown file in !`echo $OPENCODE_ARCHIVER_DIRECTORY` that summarizes the current conversation.

User can ask for particular consign for this archive. Here are the user consign:
```
$ARGUMENTS
```

The filename must follow this format: `YYYY-MM-DD-TOPIC.md`
-   `YYYY-MM-DD` is today's date.
-   `TOPIC` is a short descriptive title (kebab-case, concise, 3-6 words) summarizing the main topic of the conversation.

The file must start with this exact header format:
``` markdown
---
description: SHORT DESCRIPTION OF THE CONVERSATION
keywords: keyword1, keyword2, keyword3
---
```

After the header:

-   Write a structured, readable markdown document that preserves the full useful content of the conversation.
-   Include the user prompts and the assistant responses in chronological order.
-   Do NOT include hidden reasoning, internal thoughts, or system messages.
-   Clean formatting, proper markdown sections, and code blocks where relevant.
-   The result should feel like a clean long-form transcript suitable for documentation and future reference.


