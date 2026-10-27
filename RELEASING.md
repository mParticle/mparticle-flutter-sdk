# Releasing

1. Run **Release – Draft** on `main` and choose a patch, minor, or major bump.
   The workflow uses the shared Rokt changelog generator to collect merged PR
   titles since the previous release tag. All commit types are included, including
   dependency updates titled `chore`. The generated notes appear in both the
   changelog and the release PR description.
2. Review the generated release PR. Check dependency changes, migration guidance,
   breaking changes, version files, and comparison links before merging it.
   Conventional PR titles determine categories; use `!` for breaking changes.
   Keep **Unreleased empty** rather than adding handwritten changelog entries.
   Detailed guidance can be added to the generated section during release review.
3. Merging the release PR updates `VERSION` and creates its `v`-prefixed tag.
   **Release – Publish** runs tests and builds, validates the tagged version,
   extracts its notes, and prepares the GitHub release body before publishing.
   The release body includes the exact version's **Full Changelog** URL.

Package versions and changelog headings use bare versions (`2.3.0`), while Git
tags and comparison endpoints use `v` (`v2.3.0`). Changelog generation requires a
full checkout with tags (`fetch-depth: 0`) and explicitly sets `tag-prefix: v`.
Historical headings link existing tags; `1.0.5` stays unlinked because no tag
exists, and the earliest release links its tagged source tree.

Run the local release checks with:

```sh
python3 .github/scripts/release.py check
python3 -m unittest discover -s .github/scripts -p 'test_*.py'
flutter test
```

To repair an existing GitHub release, first save its body, prepare the corrected
notes and matching comparison footer, and apply them with
`gh release edit TAG --notes-file FILE`. Re-fetch the release to verify the edit.
Keep its tag, assets and publication metadata unchanged. Published package
archives receive documentation repairs only in a subsequent package version.
