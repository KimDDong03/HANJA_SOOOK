"""Generate a manual capture page for Hanja missing from the app stroke seed."""

from __future__ import annotations

import argparse
import csv
import json
import os
from pathlib import Path

from generate_manual_capture_textbook_ref_page import render_html


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_HANJA_JSON = ROOT / "assets" / "data" / "hanja_seed.example.json"
DEFAULT_STROKE_JSON = ROOT / "assets" / "data" / "stroke_seed.example.json"
DEFAULT_TEXTBOOK_COUNTS = ROOT / "output" / "manual_stroke" / "textbook_stroke_counts.csv"
DEFAULT_CARD_DIR = ROOT / "output" / "manual_stroke" / "textbook_reference_cards"
DEFAULT_OUTPUT_HTML = ROOT / "docs" / "prototypes" / "manual_stroke_capture_missing.html"
DEFAULT_OUTPUT_CSV = ROOT / "output" / "manual_stroke" / "manual_capture_missing_queue.csv"


def read_json_list(path: Path) -> list[dict[str, object]]:
    rows = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(rows, list):
        raise ValueError(f"JSON must be a list: {path}")
    return [row for row in rows if isinstance(row, dict)]


def active(row: dict[str, object]) -> bool:
    return bool(row.get("is_active", row.get("isActive", True)))


def row_id(row: dict[str, object]) -> str:
    return str(row.get("id") or "")


def stroke_hanja_id(row: dict[str, object]) -> str:
    return str(row.get("hanja_id") or row.get("hanjaId") or "")


def find_missing_hanja(
    hanja_json: Path,
    stroke_json: Path,
) -> list[dict[str, object]]:
    hanja_rows = [row for row in read_json_list(hanja_json) if active(row)]
    stroke_rows = [row for row in read_json_list(stroke_json) if active(row)]
    stroke_ids = {row_id(row) for row in stroke_rows}
    stroke_hanja_ids = {stroke_hanja_id(row) for row in stroke_rows}

    missing: list[dict[str, object]] = []
    for row in hanja_rows:
        hanja_id = row_id(row)
        stroke_asset_id = str(row.get("stroke_asset_id") or row.get("strokeAssetId") or "")
        if stroke_asset_id not in stroke_ids or hanja_id not in stroke_hanja_ids:
            missing.append(row)
    return missing


def read_textbook_counts(path: Path) -> dict[str, dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as file:
        return {row["id"]: row for row in csv.DictReader(file) if row.get("id")}


def reference_image_path(
    *,
    card_dir: Path,
    html_dir: Path,
    hanja_id: str,
    character: str,
) -> str:
    card_path = card_dir / f"{hanja_id}_U{ord(character):04X}.png"
    if not card_path.exists():
        raise FileNotFoundError(f"Reference card not found: {card_path}")
    return Path(os.path.relpath(card_path, html_dir)).as_posix()


def build_items(
    missing_rows: list[dict[str, object]],
    textbook_counts: Path,
    card_dir: Path,
    html_path: Path,
) -> list[dict[str, object]]:
    textbook_by_id = read_textbook_counts(textbook_counts)
    items: list[dict[str, object]] = []

    for row in missing_rows:
        hanja_id = row_id(row)
        textbook = textbook_by_id.get(hanja_id)
        if not textbook:
            raise ValueError(f"Textbook metadata not found for {hanja_id}")

        character = str(textbook.get("textbook_character") or row.get("character") or "")
        expected_count = str(
            textbook.get("textbook_stroke_count") or row.get("stroke_count") or row.get("strokeCount") or ""
        )
        if not character or not expected_count:
            raise ValueError(f"Missing character or stroke count for {hanja_id}")

        items.append(
            {
                "id": hanja_id,
                "character": character,
                "sound": textbook.get("sound") or row.get("sound") or "",
                "meaning": textbook.get("meaning") or row.get("meaning") or "",
                "grade": textbook.get("grade") or row.get("grade") or "",
                "unit": textbook.get("unit") or "",
                "lesson": textbook.get("lesson") or row.get("lesson_no") or row.get("lessonNo") or "",
                "unitName": textbook.get("unit_name") or row.get("unit_name") or row.get("unitName") or "",
                "lessonPosition": int(textbook.get("lesson_position") or 0),
                "textbookPage": int(textbook.get("textbook_page") or 0),
                "expectedStrokeCount": int(expected_count),
                "previousSource": "missing",
                "referenceImage": reference_image_path(
                    card_dir=card_dir,
                    html_dir=html_path.parent,
                    hanja_id=hanja_id,
                    character=character,
                ),
                "svgPaths": [],
            }
        )

    return items


def write_queue_csv(items: list[dict[str, object]], output_csv: Path) -> None:
    output_csv.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "hanja_id",
        "character",
        "sound",
        "meaning",
        "grade",
        "unit",
        "lesson",
        "textbook_page",
        "lesson_position",
        "expected_stroke_count",
        "previous_source",
        "reference_image",
    ]
    with output_csv.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        for item in items:
            writer.writerow(
                {
                    "hanja_id": item["id"],
                    "character": item["character"],
                    "sound": item["sound"],
                    "meaning": item["meaning"],
                    "grade": item["grade"],
                    "unit": item["unit"],
                    "lesson": item["lesson"],
                    "textbook_page": item["textbookPage"],
                    "lesson_position": item["lessonPosition"],
                    "expected_stroke_count": item["expectedStrokeCount"],
                    "previous_source": item["previousSource"],
                    "reference_image": item["referenceImage"],
                }
            )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--hanja-json", type=Path, default=DEFAULT_HANJA_JSON)
    parser.add_argument("--stroke-json", type=Path, default=DEFAULT_STROKE_JSON)
    parser.add_argument("--textbook-counts", type=Path, default=DEFAULT_TEXTBOOK_COUNTS)
    parser.add_argument("--card-dir", type=Path, default=DEFAULT_CARD_DIR)
    parser.add_argument("--output-html", type=Path, default=DEFAULT_OUTPUT_HTML)
    parser.add_argument("--output-csv", type=Path, default=DEFAULT_OUTPUT_CSV)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    missing = find_missing_hanja(args.hanja_json, args.stroke_json)
    items = build_items(missing, args.textbook_counts, args.card_dir, args.output_html)

    args.output_html.parent.mkdir(parents=True, exist_ok=True)
    args.output_html.write_text(render_html(items), encoding="utf-8")
    write_queue_csv(items, args.output_csv)

    print(f"wrote {args.output_html}")
    print(f"wrote {args.output_csv}")
    print(f"missing stroke items: {len(items)}")


if __name__ == "__main__":
    main()
