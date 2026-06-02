"""Merge a downloaded manual stroke capture JSON into the final manual JSON."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_TARGET = ROOT / "output" / "manual_stroke" / "manual_stroke_capture_final.json"


def read_rows(path: Path) -> list[dict[str, object]]:
    if not path.exists():
        return []

    rows = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(rows, list):
        raise ValueError(f"JSON must be a list: {path}")
    return [row for row in rows if isinstance(row, dict)]


def hanja_id(row: dict[str, object]) -> str:
    return str(row.get("hanjaId") or row.get("hanja_id") or "")


def validate_capture_rows(rows: list[dict[str, object]], source: Path) -> None:
    for row in rows:
        row_hanja_id = hanja_id(row)
        if not row_hanja_id:
            raise ValueError(f"Manual row is missing hanjaId in {source}")
        svg_paths = row.get("svgPaths")
        if not isinstance(svg_paths, list) or not svg_paths:
            raise ValueError(f"Manual row {row_hanja_id} has no svgPaths")
        stroke_count = row.get("strokeCount")
        if stroke_count is not None and int(stroke_count) != len(svg_paths):
            raise ValueError(
                f"Manual row {row_hanja_id} strokeCount={stroke_count} "
                f"but svgPaths has {len(svg_paths)} paths"
            )


def merge_rows(source: Path, target: Path) -> tuple[int, int, int]:
    source_rows = read_rows(source)
    validate_capture_rows(source_rows, source)

    target_rows = read_rows(target)
    by_hanja_id = {hanja_id(row): row for row in target_rows if hanja_id(row)}

    added = 0
    replaced = 0
    for row in source_rows:
        row_hanja_id = hanja_id(row)
        if row_hanja_id in by_hanja_id:
            replaced += 1
        else:
            added += 1
        by_hanja_id[row_hanja_id] = row

    merged = sorted(by_hanja_id.values(), key=lambda row: hanja_id(row))
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        json.dumps(merged, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return len(source_rows), added, replaced


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path, help="Downloaded manual capture JSON")
    parser.add_argument("--target", type=Path, default=DEFAULT_TARGET)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    merged, added, replaced = merge_rows(args.source, args.target)
    print(f"merged rows: {merged}")
    print(f"added rows: {added}")
    print(f"replaced rows: {replaced}")
    print(f"wrote {args.target}")


if __name__ == "__main__":
    main()
