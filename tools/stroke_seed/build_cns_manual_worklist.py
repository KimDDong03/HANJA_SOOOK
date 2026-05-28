"""Build a manual stroke-data worklist from the Hanja Excel DB and CNS11643.

The generated CSV is not app-ready stroke path data. It is a reviewer/work
sheet that provides a reliable baseline for manual SVG path production:
character, lesson metadata, CNS code, stroke count, and stroke-type sequence.

Run from repository root:
    python tools/stroke_seed/build_cns_manual_worklist.py --xlsx "C:\\Users\\User\\Downloads\\hanja.xlsx"
"""

from __future__ import annotations

import argparse
import csv
import re
import zipfile
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_XLSX = Path(r"C:\Users\User\Downloads\한자쏘옥완전DB초3~6학년.xlsx")
DEFAULT_OUTPUT = ROOT / "output" / "manual_stroke" / "cns_manual_worklist.csv"
CNS_ROOT = ROOT / "output" / "cns11643"
SPREADSHEET_NS = {"a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}

OUTPUT_COLUMNS = [
    "hanja_id",
    "character",
    "sound",
    "meaning",
    "grade",
    "unit",
    "lesson",
    "unit_id",
    "unit_name",
    "difficulty",
    "cns_code",
    "cns_stroke_count",
    "cns_stroke_sequence",
    "review_status",
    "manual_svg_paths",
    "notes",
]


@dataclass(frozen=True)
class HanjaRow:
    hanja_id: str
    character: str
    sound: str
    meaning: str
    grade: str
    unit: str
    lesson: str
    unit_id: str
    unit_name: str
    difficulty: str


def cell_text(cell: ET.Element) -> str:
    if cell.get("t") == "inlineStr":
        return "".join(
            text.text or ""
            for text in cell.iter(
                "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t"
            )
        ).strip()

    value = cell.find("a:v", SPREADSHEET_NS)
    return (value.text if value is not None else "").strip()


def read_sheet_rows(xlsx: Path, sheet_name: str) -> list[list[str]]:
    with zipfile.ZipFile(xlsx) as archive:
        root = ET.fromstring(archive.read(sheet_name))

    rows: list[list[str]] = []
    for row in root.findall("a:sheetData/a:row", SPREADSHEET_NS):
        rows.append([cell_text(cell) for cell in row.findall("a:c", SPREADSHEET_NS)])
    return rows


def read_hanja_rows(xlsx: Path) -> list[HanjaRow]:
    if not xlsx.exists():
        raise FileNotFoundError(f"Excel file not found: {xlsx}")

    raw_rows = read_sheet_rows(xlsx, "xl/worksheets/sheet1.xml")
    rows: list[HanjaRow] = []
    for raw in raw_rows:
        if len(raw) < 10 or not raw[0].startswith("HJ-"):
            continue
        rows.append(
            HanjaRow(
                hanja_id=raw[0],
                character=raw[1],
                sound=raw[2],
                meaning=raw[3],
                grade=raw[4],
                unit=raw[5],
                lesson=raw[6],
                unit_id=raw[7],
                unit_name=raw[8],
                difficulty=raw[9],
            )
        )
    return rows


def read_cns_unicode_map(cns_root: Path) -> dict[str, list[str]]:
    unicode_dir = cns_root / "MapingTables" / "Unicode"
    if not unicode_dir.exists():
        raise FileNotFoundError(f"CNS Unicode mapping directory not found: {unicode_dir}")

    character_to_cns: dict[str, list[str]] = {}
    for path in unicode_dir.glob("CNS2UNICODE_Unicode *.txt"):
        with path.open("r", encoding="utf-8", errors="ignore") as source:
            for line in source:
                parts = line.strip().split()
                if len(parts) < 2:
                    continue
                cns_code, unicode_hex = parts[0], parts[1]
                try:
                    character = chr(int(unicode_hex, 16))
                except ValueError:
                    continue
                character_to_cns.setdefault(character, []).append(cns_code)

    return character_to_cns


def read_cns_property(cns_root: Path, filename: str) -> dict[str, str]:
    path = cns_root / "Properties" / filename
    if not path.exists():
        raise FileNotFoundError(f"CNS property file not found: {path}")

    values: dict[str, str] = {}
    with path.open("r", encoding="utf-8", errors="ignore") as source:
        for line in source:
            parts = line.strip().split()
            if len(parts) >= 2:
                values[parts[0]] = parts[1]
    return values


def choose_cns_code(
    codes: list[str],
    stroke_counts: dict[str, str],
    stroke_sequences: dict[str, str],
) -> str:
    for code in codes:
        if code in stroke_counts and code in stroke_sequences:
            return code
    for code in codes:
        if code in stroke_counts:
            return code
    return codes[0] if codes else ""


def build_worklist(
    xlsx: Path,
    cns_root: Path,
    output: Path,
) -> tuple[int, int, int]:
    hanja_rows = read_hanja_rows(xlsx)
    character_to_cns = read_cns_unicode_map(cns_root)
    stroke_counts = read_cns_property(cns_root, "CNS_stroke.txt")
    stroke_sequences = read_cns_property(cns_root, "CNS_strokes_sequence.txt")

    output.parent.mkdir(parents=True, exist_ok=True)
    missing_cns = 0
    missing_sequence = 0

    with output.open("w", encoding="utf-8-sig", newline="") as target:
        writer = csv.DictWriter(target, fieldnames=OUTPUT_COLUMNS, lineterminator="\n")
        writer.writeheader()

        for row in hanja_rows:
            cns_codes = character_to_cns.get(row.character, [])
            cns_code = choose_cns_code(cns_codes, stroke_counts, stroke_sequences)
            stroke_count = stroke_counts.get(cns_code, "")
            stroke_sequence = stroke_sequences.get(cns_code, "")
            if not cns_code:
                missing_cns += 1
            if not stroke_sequence:
                missing_sequence += 1

            writer.writerow(
                {
                    "hanja_id": row.hanja_id,
                    "character": row.character,
                    "sound": row.sound,
                    "meaning": row.meaning,
                    "grade": row.grade,
                    "unit": row.unit,
                    "lesson": row.lesson,
                    "unit_id": row.unit_id,
                    "unit_name": row.unit_name,
                    "difficulty": row.difficulty,
                    "cns_code": cns_code,
                    "cns_stroke_count": stroke_count,
                    "cns_stroke_sequence": stroke_sequence,
                    "review_status": "todo",
                    "manual_svg_paths": "",
                    "notes": "",
                }
            )

    return len(hanja_rows), missing_cns, missing_sequence


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--xlsx", type=Path, default=DEFAULT_XLSX)
    parser.add_argument("--cns-root", type=Path, default=CNS_ROOT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    row_count, missing_cns, missing_sequence = build_worklist(
        args.xlsx,
        args.cns_root,
        args.output,
    )
    print(f"Wrote {row_count} rows to {args.output}")
    print(f"Missing CNS mappings: {missing_cns}")
    print(f"Missing CNS stroke sequences: {missing_sequence}")


if __name__ == "__main__":
    main()
