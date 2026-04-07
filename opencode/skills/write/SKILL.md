---
name: write
description: Use when asked to write, edit, or polish prose in Chinese or English, or when another skill explicitly routes prose through this one. Removes AI writing patterns and rewrites text to sound natural. Not for code comments, commit messages, or inline docs.
version: 3.0.0
---

# Write: Natural Prose in Chinese and English

Detect the language of the **text being edited**, not the user's instruction:

- Contains Chinese characters: load `references/write-zh.md`
- Otherwise, for English, mixed text, or uncertain cases: load `references/write-en.md`

If the audience is unclear, ask before editing. The same text should read very differently if it is for blog readers, an RFC, or an email to senior engineers.

## Boundary

This skill only handles prose. It can be used for direct user requests or when another skill explicitly sends a draft here for prose cleanup. Do not use it for code comments, commit messages, changelog one-liners, inline documentation, or source code.

## Execution

Read the matching reference file, follow it strictly, output the revised content.

After outputting the revised content, stop. Unless the user explicitly asks, do not explain the edits.
