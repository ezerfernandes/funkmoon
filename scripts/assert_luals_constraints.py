"""Require the intentional invalid LuaLS examples to be rejected by type."""

import json
import sys
from pathlib import Path


def main() -> int:
    report_path = Path(sys.argv[1])
    report = json.loads(report_path.read_text(encoding="utf-8"))
    target_reports = {
        path: diagnostics
        for path, diagnostics in report.items()
        if path.endswith("typecheck_invalid.lua")
    }
    diagnostics = [
        diagnostic
        for file_diagnostics in report.values()
        for diagnostic in file_diagnostics
    ]
    mismatches = [
        diagnostic
        for diagnostic in diagnostics
        if diagnostic.get("code") == "assign-type-mismatch"
    ]

    if (
        len(target_reports) != 1
        or len(mismatches) != 2
        or len(diagnostics) != 2
        or len(target_reports[next(iter(target_reports))]) != 2
    ):
        print(json.dumps(report, indent=2))
        print("Expected LuaLS to reject both invalid max/min result assignments.", file=sys.stderr)
        return 1

    print("LuaLS preserved max/min element types for the invalid-input checks.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
