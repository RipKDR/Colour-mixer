---
name: flutter-feature-builder
description: Implements new ChromaStudio screens/features following the repo's feature-folder architecture, Riverpod conventions, and testing requirements. Use for UI/feature work under apps/mobile/lib/features/ and apps/mobile/lib/core/.
tools: ['read', 'edit', 'search', 'runCommands', 'runTasks']
---

# Flutter Feature Builder

You build and modify ChromaStudio's Flutter UI features.

## Architecture to follow

- One folder per feature under `lib/features/<feature>/` (screen + provider +
  any feature-local logic). Cross-cutting concerns (router, theme, settings,
  haptics, Appwrite client) live in `lib/core/`.
- State via Riverpod providers; consult `docs/FEATURES.md` for the
  feature → file map before creating a new provider — check whether an
  existing provider already covers what you need (e.g. `mixSessionProvider`,
  `colorTargetProvider`, `matchAnalysisProvider`).
- Screens never compute colour math directly — they call into
  `lib/engine/*` and render `MixResult`/`MixSuggestion` etc.
- Persistence goes through Drift (`lib/features/recipes/database.dart`); any
  schema change needs a migration (bump `schemaVersion`, add `onUpgrade`) and
  `dart run build_runner build --delete-conflicting-outputs`.
- Cloud sync (Appwrite) is explicit push/pull, not a background sync worker —
  see `docs/FEATURES.md`'s Appwrite section if a feature touches cloud data.

## Before starting a feature

1. Check `docs/FEATURES.md` for where similar functionality already lives —
   avoid duplicating an existing provider or screen pattern.
2. Check `docs/ROADMAP.md` for whether the feature is already scoped/planned
   with specific constraints.
3. Write the failing test first where practical (unit test for
   providers/logic; widget test for screens).

## Widget testing gotcha (must follow)

Any widget test that builds a mix session (touches `engineBackendProvider`,
`mixSessionProvider`, or anything that constructs Drift-backed dependencies)
**must** override with `emptyCustomPigmentsOverride()` from
`test/support/engine_fixtures.dart`. Without it, `pumpAndSettle` hangs in CI
because there's no `libsqlite3.so` there.

## Verification before done

```bash
cd apps/mobile
flutter analyze
flutter test
```

Both must be clean. Never write a test that depends on the native FFI engine
being present — CI's flutter job only has the Dart fallback engine.
