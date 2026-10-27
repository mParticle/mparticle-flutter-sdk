"""Validate release metadata and prepare the GitHub release description."""

import argparse
import re
import subprocess
from pathlib import Path

REPOSITORY = "https://github.com/mParticle/mparticle-flutter-sdk"
VERSION = r"\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?"
HEADING = re.compile(
    rf"(?:\[(Unreleased|{VERSION})\]|({VERSION}))(?: - \d{{4}}-\d{{2}}-\d{{2}})?",
    re.IGNORECASE,
)
REFERENCE = re.compile(r"^\[([^\]]+)\]:\s+(\S+)\s*$", re.MULTILINE)


def read_changelog(root):
    text = (root / "CHANGELOG.md").read_text()
    headings = list(re.finditer(r"^## (.+)$", text, re.MULTILINE))
    sections, links = {}, {}
    for reference in REFERENCE.finditer(text):
        name, url = reference.groups()
        name = name.lower()
        if name in links:
            raise ValueError(f"Duplicate comparison reference: {name}")
        links[name] = url
    for index, heading in enumerate(headings):
        match = HEADING.fullmatch(heading[1])
        if not match:
            raise ValueError(f"Invalid release heading: {heading[1]}")
        name = (match[1] or match[2]).lower()
        if name in sections:
            raise ValueError(f"Duplicate release heading: {name}")
        if not heading[1].startswith("[") and name != "1.0.5":
            raise ValueError(f"Release heading must be linked: {name}")
        end = headings[index + 1].start() if index + 1 < len(headings) else len(text)
        sections[name] = REFERENCE.sub("", text[heading.end() : end]).strip()
        if heading[1].startswith("[") and name not in links:
            raise ValueError(f"Missing comparison reference: {name}")
    if (
        not sections
        or next(iter(sections)) != "unreleased"
        or "unreleased" not in links
    ):
        raise ValueError("Changelog must start with a linked Unreleased section")
    if sections["unreleased"]:
        raise ValueError(
            "Unreleased must be empty; release notes are generated from PR titles"
        )
    versions = [name for name in sections if name != "unreleased"]
    if not versions:
        raise ValueError("Changelog has no released versions")
    for version in versions:
        # Historical versions without a verifiable tag stay unlinked.
        if version not in links:
            continue
        expected = (
            rf"{re.escape(REPOSITORY)}/compare/v{VERSION}\.\.\.v{re.escape(version)}"
        )
        if not re.fullmatch(expected, links[version]) and not (
            version == versions[-1]
            and links[version] == f"{REPOSITORY}/tree/v{version}"
        ):
            raise ValueError(f"Invalid comparison URL for {version}: {links[version]}")
    if links["unreleased"] != f"{REPOSITORY}/compare/v{versions[0]}...HEAD":
        raise ValueError(
            "Unreleased comparison must start at the latest v-prefixed tag"
        )
    return sections, links, versions[0]


def validate(root, next_version=None, tag=None):
    sections, links, latest = read_changelog(root)
    version = (root / "VERSION").read_text().strip()
    manifest = re.search(
        r"^version:\s*(\S+)\s*$", (root / "pubspec.yaml").read_text(), re.MULTILINE
    )
    if not manifest or manifest[1] != version or latest != version:
        raise ValueError(
            "VERSION, pubspec.yaml and the latest changelog heading must agree"
        )
    if not any(
        line.strip() and not line.startswith("#")
        for line in sections[latest].splitlines()
    ):
        raise ValueError(f"Release notes are empty for {latest}")
    if tag is not None and tag != f"v{version}":
        raise ValueError(f"Tag must match v{version}, got {tag}")
    if next_version is not None:
        if not re.fullmatch(r"\d+\.\d+\.\d+", next_version) or next_version in sections:
            raise ValueError("Next version must be a new bare stable version")
        if tuple(map(int, next_version.split("."))) <= tuple(
            map(int, version.split("."))
        ):
            raise ValueError("Next version must be newer than the current version")
        shallow = subprocess.check_output(
            ["git", "rev-parse", "--is-shallow-repository"], cwd=root, text=True
        ).strip()
        if shallow != "false":
            raise ValueError("Changelog generation requires fetch-depth: 0")
        subprocess.run(
            ["git", "merge-base", "--is-ancestor", f"v{version}", "HEAD"],
            cwd=root,
            check=True,
        )
        tags = subprocess.check_output(
            ["git", "tag", "--merged", "HEAD"], cwd=root, text=True
        ).splitlines()
        stable_tags = [
            value for value in tags if re.fullmatch(r"v\d+\.\d+\.\d+", value)
        ]
        if (
            max(stable_tags, key=lambda value: tuple(map(int, value[1:].split("."))))
            != f"v{version}"
        ):
            raise ValueError("Latest reachable release tag must match VERSION")
    return sections, links, latest


def prepare_body(root, tag, notes_file, output):
    sections, links, version = validate(root, tag=tag)
    notes = notes_file.read_text().strip()
    if notes != sections[version]:
        raise ValueError(
            "Extracted release notes do not match the tagged version's section"
        )
    output.write_text(
        f"## Release notes:\n{notes}\n\n**Full Changelog**: {links[version]}\n"
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path("."))
    commands = parser.add_subparsers(dest="command", required=True)
    check = commands.add_parser("check")
    check.add_argument("--next-version")
    check.add_argument("--tag")
    body = commands.add_parser("body")
    body.add_argument("--tag", required=True)
    body.add_argument("--notes-file", type=Path, required=True)
    body.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        if args.command == "check":
            validate(args.root, args.next_version, args.tag)
        else:
            prepare_body(args.root, args.tag, args.notes_file, args.output)
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Release validation failed: {error}\n")


if __name__ == "__main__":
    main()
