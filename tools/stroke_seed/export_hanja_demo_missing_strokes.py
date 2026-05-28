"""Export Excel characters that are missing stroke paths in hanja_demo DB.

Run from repository root:
    python tools/stroke_seed/export_hanja_demo_missing_strokes.py
"""

from __future__ import annotations

import argparse
import csv
import sqlite3
import zipfile
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_XLSX = Path(r"C:\Users\User\Downloads\한자쏘옥완전DB초3~6학년.xlsx")
DEFAULT_HANJA_DEMO_DB = Path(
    r"C:\Projects\hanja_demo\core\src\commonMain\composeResources\files\hanja_soook_data-base-v15.sql"
)
DEFAULT_OUTPUT_CSV = ROOT / "output" / "manual_stroke" / "hanja_demo_missing_strokes.csv"
DEFAULT_OUTPUT_TXT = ROOT / "output" / "manual_stroke" / "hanja_demo_missing_strokes_for_capture.txt"
SPREADSHEET_NS = {"a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
STROKE_CHARACTER_ALIASES = {
    "內": "内",
}


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


def read_hanja_rows(xlsx: Path) -> list[HanjaRow]:
    with zipfile.ZipFile(xlsx) as archive:
        root = ET.fromstring(archive.read("xl/worksheets/sheet1.xml"))

    rows: list[HanjaRow] = []
    for row in root.findall("a:sheetData/a:row", SPREADSHEET_NS):
        values = [cell_text(cell) for cell in row.findall("a:c", SPREADSHEET_NS)]
        if len(values) < 10 or not values[0].startswith("HJ-"):
            continue
        rows.append(
            HanjaRow(
                hanja_id=values[0],
                character=values[1],
                sound=values[2],
                meaning=values[3],
                grade=values[4],
                unit=values[5],
                lesson=values[6],
                unit_id=values[7],
                unit_name=values[8],
                difficulty=values[9],
            )
        )
    return rows


def read_demo_stroke_characters(db_path: Path) -> set[str]:
    if not db_path.exists():
        raise FileNotFoundError(f"hanja_demo DB not found: {db_path}")

    with sqlite3.connect(f"file:{db_path}?mode=ro", uri=True) as connection:
        rows = connection.execute(
            "SELECT DISTINCT character FROM character_stroke"
        ).fetchall()
    return {str(row[0]) for row in rows}


def export_missing(
    xlsx: Path,
    demo_db: Path,
    output_csv: Path,
    output_txt: Path,
) -> tuple[int, int, int]:
    hanja_rows = read_hanja_rows(xlsx)
    demo_characters = read_demo_stroke_characters(demo_db)
    missing_rows = [
        row
        for row in hanja_rows
        if STROKE_CHARACTER_ALIASES.get(row.character, row.character) not in demo_characters
    ]

    output_csv.parent.mkdir(parents=True, exist_ok=True)
    with output_csv.open("w", encoding="utf-8-sig", newline="") as target:
        writer = csv.DictWriter(
            target,
            fieldnames=[
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
            ],
            lineterminator="\n",
        )
        writer.writeheader()
        for row in missing_rows:
            writer.writerow(row.__dict__)

    with output_txt.open("w", encoding="utf-8", newline="") as target:
        for row in missing_rows:
            target.write(f"{row.hanja_id},{row.character},{row.sound},{row.meaning}\n")

    return len(hanja_rows), len(demo_characters), len(missing_rows)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--xlsx", type=Path, default=DEFAULT_XLSX)
    parser.add_argument("--demo-db", type=Path, default=DEFAULT_HANJA_DEMO_DB)
    parser.add_argument("--output-csv", type=Path, default=DEFAULT_OUTPUT_CSV)
    parser.add_argument("--output-txt", type=Path, default=DEFAULT_OUTPUT_TXT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    excel_count, demo_count, missing_count = export_missing(
        args.xlsx,
        args.demo_db,
        args.output_csv,
        args.output_txt,
    )
    matched_count = excel_count - missing_count
    print(f"Excel rows: {excel_count}")
    print(f"hanja_demo characters with strokes: {demo_count}")
    print(f"Matched Excel rows: {matched_count}")
    print(f"Missing Excel rows: {missing_count}")
    print(f"Wrote {args.output_csv}")
    print(f"Wrote {args.output_txt}")


if __name__ == "__main__":
    main()
