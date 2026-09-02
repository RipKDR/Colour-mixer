---
name: drift-migration
description: Safely add or change a persisted table/column in ChromaStudio's Drift database (recipes/inventory) including schema version bump, migration step, and codegen. Use when editing apps/mobile/lib/features/recipes/database.dart or any Drift table definition.
---

# Drift Migration

ChromaStudio persists recipes/inventory via Drift
(`apps/mobile/lib/features/recipes/database.dart`), currently at
**schemaVersion 4**. Any schema change needs a deliberate migration, not just
a field edit.

## Step 1 — Change the table definition

Edit the relevant `Table` class (or add a new one) in `database.dart`.

## Step 2 — Bump the schema version

Increment the `schemaVersion` getter by 1.

## Step 3 — Add a migration step

In the `migration` (`MigrationStrategy`) override, add an `onUpgrade` branch
for the new version transition, e.g.:

```dart
onUpgrade: (m, from, to) async {
  if (from < 5) {
    await m.addColumn(myTable, myTable.newColumn);
  }
  // ...existing branches for earlier versions...
},
```

Never silently drop/rewrite existing branches — each one represents a real
migration path for a user's existing local database.

## Step 4 — Regenerate codegen

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `database.g.dart`, which **is committed** — make sure it's
included in your diff, not gitignored/stale.

## Step 5 — Test the migration

Add/extend a test that:
- Constructs the DB at the *previous* schema version (or uses Drift's
  migration testing helpers if already set up in `test/`).
- Runs the upgrade.
- Asserts the new column/table exists with the expected default/behaviour.

## Step 6 — Verify

```bash
cd apps/mobile
flutter analyze
flutter test
```

## Guardrails

- Never change `schemaVersion` without a corresponding `onUpgrade` branch —
  existing installs will crash trying to open an unmigrated database.
- Never reuse a schema version number that's already shipped.
- If the change affects data synced to Appwrite (recipes), check
  `docs/FEATURES.md`'s Appwrite section — the cloud document shape may also
  need updating, and sync is explicit push/pull (no background migration of
  remote data happens automatically).
