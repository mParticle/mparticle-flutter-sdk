# Releasing

Run **Release – Draft** on `main` and choose a patch, minor, or major bump.
The shared Rokt action generates changelog entries from merged PR titles since
the previous release tag, including all commit types. Conventional prefixes
determine categories; use `!` for breaking changes. Keep Unreleased empty.

Review the generated notes in the release PR, adding migration guidance where
needed. Merging creates the `v`-prefixed tag and starts tests, builds and
publication. The GitHub release includes the matching Full Changelog URL.

Package versions and changelog headings use bare versions (`2.3.0`); tags use
`v` (`v2.3.0`). Generation uses full history and explicitly sets `tag-prefix: v`.
Historical links retain existing tags; the untagged `1.0.5` heading stays unlinked.
