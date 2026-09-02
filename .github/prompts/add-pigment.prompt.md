---
mode: agent
description: 'Add a new pigment to ChromaStudio, keeping source data, bundled assets, and the Rust engine in sync.'
---

# Add a New Pigment

Ask the user (if not already provided) for:

- Common name and pigment code(s) (e.g. `PB29` for Ultramarine Blue).
- Reflectance spectrum source (spectrophotometer data preferred; otherwise a
  cited reference) — must resolve to exactly 41 samples, 380–780 nm at 10 nm
  steps.
- Opacity, tinting strength, toxicity notes, binder affinity.
- Which brand catalog(s), if any, should reference it.

Then, using the `pigment-data-curator` agent's conventions:

1. Add the entry to `data/pigments/all_pigments.json`.
2. Regenerate/sync bundled assets (`apps/mobile/assets/pigments/`,
   `tools/generate_pigments.py` if applicable).
3. Rebuild the Rust engine so the embedded pigment table matches:
   ```bash
   cd packages/chroma_engine
   cargo build --release
   cargo test --release
   ```
4. Add a Dart test exercising the new pigment (e.g. a single-pigment mix
   producing a plausible Lab/sRGB masstone, or a catalog lookup test if it
   was added to a brand file).
5. Run `flutter test` from `apps/mobile/`.
6. If this pigment should appear in a brand catalog, add/update the relevant
   `apps/mobile/assets/data/brands/*.json` entry and verify the pigment id
   resolves in `lib/engine/catalog.dart`.

Report which files changed and confirm both test suites pass.
