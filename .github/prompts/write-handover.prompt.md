---
mode: agent
description: 'Write a session handover update to docs/HANDOVER.md (and related docs) based on verified current repo state.'
---

# Write Session Handover

Use the `handover-scribe` agent's conventions. Do this now:

1. Run the verification suite (see `verify-all.prompt.md`) to get real,
   current pass/fail state — do not guess or reuse stale numbers.
2. Check `git log` / `git status` (or ask the user) for what changed this
   session: files touched, features added, bugs fixed.
3. Update `docs/HANDOVER.md`:
   - Add a new dated entry (or replace the "current session" section per the
     file's existing convention) summarizing what shipped.
   - List any new gotchas discovered.
   - List concrete "resume here" next steps for whoever picks this up next.
   - If a security-sensitive issue was found (leaked secret, credential in
     chat, overly broad token), flag it prominently at the top and tell the
     user directly, don't bury it in the middle of the doc.
4. If architecture, the FFI ABI, the schema, or the feature map changed,
   update `docs/DESIGN.md`, `docs/ENGINE.md`, or `docs/FEATURES.md`
   respectively — keep them in sync with reality, not with what was planned.
5. Show the user a short diff summary of what you changed in the docs.
