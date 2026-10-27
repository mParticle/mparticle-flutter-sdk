"""Regression tests for changelog validation and release body preparation."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

import release


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.text = (
            "# Changelog\n\n## [Unreleased]\n\n## [2.3.0] - 2026-10-27\n\n"
            "### Added\n\n- A feature ([#1](https://github.com/example/sdk/pull/1)).\n\n"
            "## [2.2.1] - 2026-09-15\n\n- An older fix.\n\n"
            f"[unreleased]: {release.REPOSITORY}/compare/v2.3.0...HEAD\n"
            f"[2.3.0]: {release.REPOSITORY}/compare/v2.2.1...v2.3.0\n"
            f"[2.2.1]: {release.REPOSITORY}/tree/v2.2.1\n"
        )
        (self.root / "CHANGELOG.md").write_text(self.text)
        (self.root / "VERSION").write_text("2.3.0\n")
        (self.root / "pubspec.yaml").write_text("name: example\nversion: 2.3.0\n")

    def test_current_release_body(self):
        with (self.root / "CHANGELOG.md").open("a") as changelog:
            changelog.write(
                f"[12.3.0]: {release.REPOSITORY}/compare/v12.2.0...v12.3.0\n"
            )
        sections, links, version = release.validate(self.root, tag="v2.3.0")
        notes, output = self.root / "notes.md", self.root / "body.md"
        notes.write_text(sections[version] + "\n")
        release.prepare_body(self.root, "v2.3.0", notes, output)
        self.assertEqual(
            output.read_text(),
            f"## Release notes:\n{sections[version]}\n\n**Full Changelog**: {links[version]}\n",
        )
        notes.write_text(sections["2.2.1"])
        with self.assertRaisesRegex(ValueError, "do not match"):
            release.prepare_body(self.root, "v2.3.0", notes, output)
        self.assertIn(f"**Full Changelog**: {links[version]}", output.read_text())

    def test_invalid_changelogs(self):
        cases = {
            "duplicate heading": ("## [2.2.1] - 2026-09-15", "## [2.3.0] - 2026-09-15"),
            "duplicate reference": ("[2.2.1]:", "[2.3.0]:"),
            "manual Unreleased": (
                "## [Unreleased]\n",
                "## [Unreleased]\n\n- Manual note.\n",
            ),
            "missing heading": ("## [Unreleased]", "# Unreleased"),
            "missing reference": ("[2.3.0]:", "[other]:"),
            "missing Unreleased link": ("[unreleased]:", "[other]:"),
            "empty release": (
                "- A feature ([#1](https://github.com/example/sdk/pull/1)).",
                "",
            ),
            "bare comparison": ("compare/v2.2.1...v2.3.0", "compare/2.2.1...2.3.0"),
            "wrong comparison target": (
                "compare/v2.2.1...v2.3.0",
                "compare/v2.2.1...v2.3.1",
            ),
            "wrong Unreleased base": ("compare/v2.3.0...HEAD", "compare/v2.2.1...HEAD"),
            "unlinked current version": ("## [2.3.0]", "## 2.3.0"),
        }
        for name, (old, new) in cases.items():
            with self.subTest(name=name):
                text = self.text.replace(old, new)
                (self.root / "CHANGELOG.md").write_text(text)
                with self.assertRaises(ValueError):
                    release.validate(self.root)
                self.assertEqual((self.root / "CHANGELOG.md").read_text(), text)

    def test_mismatched_versions_and_tags(self):
        for tag in ("2.3.0", "v2.2.1", "v2.3.01"):
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                release.validate(self.root, tag=tag)
        for file in ("VERSION", "pubspec.yaml"):
            path = self.root / file
            original = path.read_text()
            path.write_text(original.replace("2.3.0", "2.3.1"))
            with self.subTest(file=file), self.assertRaises(ValueError):
                release.validate(self.root)
            path.write_text(original)

    def test_next_version_and_history(self):
        self.git("init", "-q")
        self.git(
            "-c",
            "user.name=Example",
            "-c",
            "user.email=example@example.com",
            "commit",
            "--allow-empty",
            "-qm",
            "Initial",
        )
        self.git("tag", "v2.3.0")
        release.validate(self.root, next_version="2.3.1")
        for version in ("2.3.0", "2.2.0", "v2.3.1"):
            with self.subTest(version=version), self.assertRaises(ValueError):
                release.validate(self.root, next_version=version)
        self.git("tag", "v2.4.0")
        with self.assertRaisesRegex(ValueError, "Latest reachable"):
            release.validate(self.root, next_version="2.3.1")
        self.git("tag", "-d", "v2.4.0")
        (self.root / ".git" / "shallow").write_text(
            self.git("rev-parse", "HEAD").strip() + "\n"
        )
        with self.assertRaisesRegex(ValueError, "fetch-depth"):
            release.validate(self.root, next_version="2.3.1")

    def test_generation_noop_fails_post_validation(self):
        for file in ("VERSION", "pubspec.yaml"):
            path = self.root / file
            path.write_text(path.read_text().replace("2.3.0", "2.3.1"))
        with self.assertRaisesRegex(ValueError, "must agree"):
            release.validate(self.root, tag="v2.3.1")

    def git(self, *args):
        return subprocess.check_output(
            ["git", "-c", "core.hooksPath=/dev/null", *args],
            cwd=self.root,
            text=True,
            env={**os.environ, "GIT_CONFIG_NOSYSTEM": "1"},
        )


if __name__ == "__main__":
    unittest.main()
