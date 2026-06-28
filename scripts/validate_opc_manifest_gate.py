#!/usr/bin/env python3
"""Validate OPC task reports for mandatory manifest gate blocks."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path


REQUIRED_STRINGS = [
    "OPC MANIFEST CHECK — TASK START",
    "OPC MANIFEST COMPLIANCE — TASK END",
    "Manifest read:",
    "Manifest compliance checked:",
    "PASS / NOT PASS:",
]

LEGACY_EXEMPTION = "OPC_MANIFEST_GATE_LEGACY_EXEMPTION"


def run_git(args: list[str]) -> str:
    result = subprocess.run(
        ["git", *args],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return result.stdout.strip()


def git_ref_exists(ref: str) -> bool:
    result = subprocess.run(
        ["git", "rev-parse", "--verify", "--quiet", ref],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    return result.returncode == 0


def choose_base(cli_base: str | None) -> str:
    candidates = [
        cli_base,
        os.environ.get("OPC_MANIFEST_GATE_BASE"),
        os.environ.get("GITHUB_BASE_SHA"),
        "origin/main",
        "HEAD^",
    ]

    for candidate in candidates:
        if not candidate:
            continue
        if set(candidate) == {"0"}:
            continue
        if git_ref_exists(candidate):
            return candidate

    raise RuntimeError(
        "Could not determine a valid base ref. Pass --base or set OPC_MANIFEST_GATE_BASE."
    )


def changed_reports(base: str) -> list[Path]:
    diff_output = run_git(
        [
            "diff",
            "--name-only",
            "--diff-filter=ACMRT",
            f"{base}...HEAD",
            "--",
            "docs/tasks",
        ]
    )
    reports: list[Path] = []
    if diff_output:
        for line in diff_output.splitlines():
            path = Path(line)
            if path.suffix.lower() == ".md" and path.parts[:2] == ("docs", "tasks"):
                reports.append(path)
    for path in working_tree_reports():
        if path not in reports:
            reports.append(path)
    return reports


def working_tree_reports() -> list[Path]:
    status_output = run_git(["status", "--porcelain", "--", "docs/tasks"])
    reports: list[Path] = []
    for line in status_output.splitlines():
        if len(line) < 4:
            continue
        status = line[:2]
        if status == " D" or status == "D ":
            continue
        raw_path = line[3:]
        if " -> " in raw_path:
            raw_path = raw_path.split(" -> ", 1)[1]
        path = Path(raw_path)
        if path.suffix.lower() == ".md" and path.parts[:2] == ("docs", "tasks"):
            reports.append(path)
    return reports


def validate_report(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    if LEGACY_EXEMPTION in text:
        return []
    return [required for required in REQUIRED_STRINGS if required not in text]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate changed OPC task reports for manifest gate blocks."
    )
    parser.add_argument(
        "--base",
        help="Base ref used to select changed docs/tasks/*.md reports.",
    )
    args = parser.parse_args()

    try:
        base = choose_base(args.base)
        reports = changed_reports(base)
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"OPC manifest gate setup failed: {error}", file=sys.stderr)
        return 2

    if not reports:
        print(f"OPC manifest gate: no changed task reports to validate against {base}.")
        return 0

    failures: dict[Path, list[str]] = {}
    for report in reports:
        missing = validate_report(report)
        if missing:
            failures[report] = missing

    if failures:
        print("OPC manifest gate failed. Missing required strings:")
        for report, missing in failures.items():
            print(f"- {report}")
            for required in missing:
                print(f"  - {required}")
        return 1

    print(f"OPC manifest gate passed for {len(reports)} changed task report(s).")
    for report in reports:
        print(f"- {report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
