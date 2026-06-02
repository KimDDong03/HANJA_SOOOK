"""Build app stroke seed data from Excel, hanja_demo, and manual captures.

Run from repository root:
    python tools/stroke_seed/build_app_stroke_seed.py
"""

from __future__ import annotations

import argparse
import csv
import json
import sqlite3
import urllib.error
import urllib.parse
import urllib.request
import zipfile
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_XLSX = Path(r"C:\Users\User\Downloads\한자쏘옥완전DB초3~6학년.xlsx")
DEFAULT_HANJA_DEMO_DB = Path(
    r"C:\Projects\hanja_demo\core\src\commonMain\composeResources\files\hanja_soook_data-base-v15.sql"
)
DEFAULT_MANUAL_JSON = ROOT / "output" / "manual_stroke" / "manual_stroke_capture_final.json"
DEFAULT_OUTPUT_JSON = ROOT / "assets" / "data" / "stroke_seed.example.json"
DEFAULT_REPORT_CSV = ROOT / "output" / "manual_stroke" / "stroke_seed_build_report.csv"
DEFAULT_TEXTBOOK_COUNTS = ROOT / "output" / "manual_stroke" / "textbook_stroke_counts.csv"
DEFAULT_HANZI_WRITER_CACHE = ROOT / "output" / "hanzi_writer_data"
HANZI_WRITER_DATA_BASE_URL = "https://cdn.jsdelivr.net/npm/hanzi-writer-data@2.0.1"
SPREADSHEET_NS = {"a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
STROKE_CHARACTER_ALIASES = {
    "內": "内",
}


@dataclass(frozen=True)
class HanjaRow:
    hanja_id: str
    character: str
    excel_character: str
    expected_stroke_count: int | None
    sound: str = ""
    meaning: str = ""
    grade: str = ""
    unit: str = ""
    lesson: str = ""
    unit_id: str = ""
    unit_name: str = ""


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
    if not xlsx.exists():
        raise FileNotFoundError(f"Excel file not found: {xlsx}")

    with zipfile.ZipFile(xlsx) as archive:
        root = ET.fromstring(archive.read("xl/worksheets/sheet1.xml"))

    rows: list[HanjaRow] = []
    for row in root.findall("a:sheetData/a:row", SPREADSHEET_NS):
        values = [cell_text(cell) for cell in row.findall("a:c", SPREADSHEET_NS)]
        if len(values) >= 2 and values[0].startswith("HJ-"):
            rows.append(
                HanjaRow(
                    hanja_id=values[0],
                    character=values[1],
                    excel_character=values[1],
                    expected_stroke_count=None,
                    sound=values[2] if len(values) > 2 else "",
                    meaning=values[3] if len(values) > 3 else "",
                    grade=values[4] if len(values) > 4 else "",
                    unit=values[5] if len(values) > 5 else "",
                    lesson=values[6] if len(values) > 6 else "",
                    unit_id=values[7] if len(values) > 7 else "",
                    unit_name=values[8] if len(values) > 8 else "",
                )
            )
    return rows


def read_textbook_rows(path: Path) -> list[HanjaRow]:
    if not path.exists():
        return []

    rows: list[HanjaRow] = []
    with path.open("r", encoding="utf-8-sig", newline="") as source:
        for row in csv.DictReader(source):
            hanja_id = str(row.get("id") or "")
            if not hanja_id.startswith("HJ-"):
                continue
            textbook_character = str(row.get("textbook_character") or "").strip()
            excel_character = str(row.get("excel_character") or "").strip()
            count_text = str(row.get("textbook_stroke_count") or "").strip()
            rows.append(
                HanjaRow(
                    hanja_id=hanja_id,
                    character=textbook_character or excel_character,
                    excel_character=excel_character or textbook_character,
                    expected_stroke_count=int(count_text) if count_text else None,
                    sound=str(row.get("sound") or ""),
                    meaning=str(row.get("meaning") or ""),
                    grade=str(row.get("grade") or ""),
                    unit=str(row.get("unit") or ""),
                    lesson=str(row.get("lesson") or ""),
                    unit_id=str(row.get("unit_id") or ""),
                    unit_name=str(row.get("unit_name") or ""),
                )
            )
    return rows


def read_demo_paths(db_path: Path) -> dict[str, list[str]]:
    if not db_path.exists():
        raise FileNotFoundError(f"hanja_demo DB not found: {db_path}")

    paths: dict[str, list[str]] = {}
    with sqlite3.connect(f"file:{db_path}?mode=ro", uri=True) as connection:
        rows = connection.execute(
            """
            SELECT character, stroke_path
            FROM character_stroke
            ORDER BY character, stroke_number
            """
        ).fetchall()
    for character, stroke_path in rows:
        paths.setdefault(str(character), []).append(str(stroke_path))
    return paths


def read_manual_rows(path: Path) -> dict[str, dict[str, object]]:
    if not path.exists():
        raise FileNotFoundError(f"manual stroke JSON not found: {path}")

    rows = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(rows, list):
        raise ValueError(f"manual stroke JSON must be a list: {path}")

    result: dict[str, dict[str, object]] = {}
    for row in rows:
        if not isinstance(row, dict):
            continue
        hanja_id = str(row.get("hanjaId") or row.get("hanja_id") or "")
        if hanja_id:
            result[hanja_id] = row
    return result


def read_preserved_seed_rows(path: Path) -> list[dict[str, object]]:
    if not path.exists():
        return []

    rows = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(rows, list):
        return []

    preserved: list[dict[str, object]] = []
    for row in rows:
        if not isinstance(row, dict):
            continue
        hanja_id = str(row.get("hanjaId") or row.get("hanja_id") or "")
        if hanja_id.startswith("HJ-DEMO-"):
            preserved.append(row)
    return preserved


def read_existing_seed_rows_by_hanja(path: Path) -> dict[str, dict[str, object]]:
    if not path.exists():
        return {}

    rows = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(rows, list):
        return {}

    result: dict[str, dict[str, object]] = {}
    for row in rows:
        if not isinstance(row, dict):
            continue
        hanja_id = str(row.get("hanjaId") or row.get("hanja_id") or "")
        if hanja_id and not hanja_id.startswith("HJ-DEMO-"):
            result[hanja_id] = row
    return result


def read_expected_stroke_counts(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}

    with path.open("r", encoding="utf-8-sig", newline="") as source:
        return {
            row["hanja_id"]: row.get("cns_stroke_count", "")
            for row in csv.DictReader(source)
            if row.get("hanja_id")
        }


def read_hanzi_writer_data(
    character: str,
    cache_dir: Path,
    use_network: bool,
) -> dict[str, object] | None:
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_path = cache_dir / f"{ord(character):X}.json"
    if cache_path.exists():
        return json.loads(cache_path.read_text(encoding="utf-8"))

    if not use_network:
        return None

    encoded = urllib.parse.quote(character)
    url = f"{HANZI_WRITER_DATA_BASE_URL}/{encoded}.json"
    request = urllib.request.Request(url, headers={"User-Agent": "hanja-soook-stroke-seed/1.0"})
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            if response.status != 200:
                return None
            text = response.read().decode("utf-8")
    except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError):
        return None

    cache_path.write_text(text, encoding="utf-8")
    return json.loads(text)


def median_paths_from_hanzi_writer(data: dict[str, object]) -> list[str]:
    medians = data.get("medians")
    if not isinstance(medians, list):
        return []

    paths: list[str] = []
    x_scale = 109 / 1024
    y_scale = 109 / 1024
    hanzi_writer_y_origin = 900
    for stroke in medians:
        if not isinstance(stroke, list) or not stroke:
            continue
        points: list[tuple[float, float]] = []
        for point in stroke:
            if not isinstance(point, list) or len(point) < 2:
                continue
            x = float(point[0]) * x_scale
            y = (hanzi_writer_y_origin - float(point[1])) * y_scale
            points.append((x, y))
        if not points:
            continue
        commands = [f"M{points[0][0]:.2f} {points[0][1]:.2f}"]
        commands.extend(f"L{x:.2f} {y:.2f}" for x, y in points[1:])
        paths.append(" ".join(commands))
    return paths


def stroke_asset(
    *,
    hanja_id: str,
    character: str,
    source: str,
    paths: list[str],
    license_note: str,
    source_character: str | None = None,
    median_points: list[object] | None = None,
) -> dict[str, object]:
    row: dict[str, object] = {
        "id": f"stroke-{hanja_id}",
        "hanjaId": hanja_id,
        "character": character,
        "strokeCount": len(paths),
        "reviewStatus": "available",
        "source": source,
        "dataFormat": "svg",
        "licenseNote": license_note,
        "svgPaths": paths,
        "isActive": True,
    }
    if median_points:
        row["medianPoints"] = median_points
    if source_character and source_character != character:
        row["sourceCharacter"] = source_character
    return row


def build_seed(
    xlsx: Path,
    demo_db: Path,
    manual_json: Path,
    output_json: Path,
    report_csv: Path,
    textbook_counts: Path,
    hanzi_writer_cache: Path,
    use_hanzi_writer: bool,
    use_network: bool,
    preserve_existing_demo: bool,
) -> tuple[int, int, int, int, int, int, int, int]:
    hanja_rows = read_textbook_rows(textbook_counts) or read_hanja_rows(xlsx)
    demo_paths = read_demo_paths(demo_db)
    manual_rows = read_manual_rows(manual_json)
    existing_seed_rows = read_existing_seed_rows_by_hanja(output_json)
    preserved_rows = read_preserved_seed_rows(output_json) if preserve_existing_demo else []

    seed_rows: list[dict[str, object]] = list(preserved_rows)
    report_rows: list[dict[str, object]] = []
    manual_count = 0
    alias_count = 0
    demo_count = 0
    hanzi_writer_count = 0
    preserved_existing_count = 0
    missing_count = 0
    rejected_count = 0

    for hanja in hanja_rows:
        manual = manual_rows.get(hanja.hanja_id)
        if manual:
            paths = [str(path) for path in manual.get("svgPaths") or []]
            manual_character = str(manual.get("character") or hanja.character)
            if paths and manual_character == hanja.character and count_matches(hanja, len(paths)):
                seed_rows.append(
                    stroke_asset(
                        hanja_id=hanja.hanja_id,
                        character=hanja.character,
                        source="manual_capture",
                        paths=paths,
                        license_note="Manual capture created for Hanjasoook.",
                    )
                )
                report_rows.append(report_row(hanja, "manual_capture", hanja.character, len(paths), ""))
                manual_count += 1
                continue
            if paths:
                rejected_count += 1

        source_character = STROKE_CHARACTER_ALIASES.get(hanja.character, hanja.character)
        paths = demo_paths.get(source_character, [])
        if paths and count_matches(hanja, len(paths)):
            seed_rows.append(
                stroke_asset(
                    hanja_id=hanja.hanja_id,
                    character=hanja.character,
                    source="hanja_demo",
                    paths=paths,
                    license_note="User-provided from C:\\Projects\\hanja_demo.",
                    source_character=source_character,
                )
            )
            report_rows.append(report_row(hanja, "hanja_demo", source_character, len(paths), ""))
            if source_character != hanja.character:
                alias_count += 1
            else:
                demo_count += 1
            continue
        if paths:
            rejected_count += 1

        if use_hanzi_writer:
            hanzi_data = read_hanzi_writer_data(
                source_character,
                hanzi_writer_cache,
                use_network=use_network,
            )
            if hanzi_data:
                hanzi_paths = median_paths_from_hanzi_writer(hanzi_data)
                if hanzi_paths and count_matches(hanja, len(hanzi_paths)):
                    seed_rows.append(
                        stroke_asset(
                            hanja_id=hanja.hanja_id,
                            character=hanja.character,
                            source="hanzi_writer_data",
                            paths=hanzi_paths,
                            license_note=(
                                "Hanzi Writer Data 2.0.1, derived from Make Me A Hanzi; "
                                "Arphic Public License."
                            ),
                            source_character=source_character,
                            median_points=hanzi_data.get("medians")
                            if isinstance(hanzi_data.get("medians"), list)
                            else None,
                        )
                    )
                    report_rows.append(
                        report_row(hanja, "hanzi_writer_data", source_character, len(hanzi_paths), "")
                    )
                    hanzi_writer_count += 1
                    continue
                if hanzi_paths:
                    rejected_count += 1

        existing = existing_seed_rows.get(hanja.hanja_id)
        if existing:
            existing_paths = [str(path) for path in existing.get("svgPaths") or []]
            existing_character = str(existing.get("character") or "")
            if existing_paths and existing_character == hanja.character and count_matches(hanja, len(existing_paths)):
                seed_rows.append(existing)
                report_rows.append(
                    report_row(
                        hanja,
                        str(existing.get("source") or "existing_seed"),
                        str(existing.get("sourceCharacter") or existing_character),
                        len(existing_paths),
                        "preserved from existing app stroke seed",
                    )
                )
                preserved_existing_count += 1
                continue
            if existing_paths:
                rejected_count += 1

        report = report_row(
            hanja,
            "missing",
            "",
            0,
            "no source matched textbook character and stroke count",
        )
        report_rows.append(report)
        missing_count += 1

    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(
        json.dumps(seed_rows, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    report_csv.parent.mkdir(parents=True, exist_ok=True)
    with report_csv.open("w", encoding="utf-8-sig", newline="") as target:
        writer = csv.DictWriter(
            target,
            fieldnames=[
                "hanja_id",
                "excel_character",
                "textbook_character",
                "sound",
                "meaning",
                "grade",
                "unit",
                "lesson",
                "unit_id",
                "unit_name",
                "source",
                "source_character",
                "stroke_count",
                "expected_stroke_count",
                "count_matches_expected",
                "note",
            ],
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(report_rows)

    return (
        len(seed_rows),
        demo_count,
        alias_count,
        manual_count,
        hanzi_writer_count,
        preserved_existing_count,
        missing_count,
        rejected_count,
    )


def count_matches(hanja: HanjaRow, stroke_count: int) -> bool:
    return hanja.expected_stroke_count is None or hanja.expected_stroke_count == stroke_count


def report_row(
    hanja: HanjaRow,
    source: str,
    source_character: str,
    stroke_count: int,
    note: str,
) -> dict[str, object]:
    return {
        "hanja_id": hanja.hanja_id,
        "excel_character": hanja.excel_character,
        "textbook_character": hanja.character,
        "sound": hanja.sound,
        "meaning": hanja.meaning,
        "grade": hanja.grade,
        "unit": hanja.unit,
        "lesson": hanja.lesson,
        "unit_id": hanja.unit_id,
        "unit_name": hanja.unit_name,
        "source": source,
        "source_character": source_character,
        "stroke_count": stroke_count,
        "expected_stroke_count": hanja.expected_stroke_count or "",
        "count_matches_expected": "yes"
        if hanja.expected_stroke_count is not None and stroke_count == hanja.expected_stroke_count
        else "",
        "note": note,
    }


def add_expected_count(
    report: dict[str, object],
    expected_counts: dict[str, str],
) -> bool:
    expected = expected_counts.get(str(report["hanja_id"]), "")
    if not expected:
        return False

    actual = str(report["stroke_count"])
    matches = actual == expected
    report["expected_stroke_count"] = expected
    report["count_matches_expected"] = "yes" if matches else "no"
    if not matches and not report["note"]:
        report["note"] = "stroke count differs from CNS baseline"
    return not matches


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--xlsx", type=Path, default=DEFAULT_XLSX)
    parser.add_argument("--demo-db", type=Path, default=DEFAULT_HANJA_DEMO_DB)
    parser.add_argument("--manual-json", type=Path, default=DEFAULT_MANUAL_JSON)
    parser.add_argument("--output-json", type=Path, default=DEFAULT_OUTPUT_JSON)
    parser.add_argument("--report-csv", type=Path, default=DEFAULT_REPORT_CSV)
    parser.add_argument("--textbook-counts", type=Path, default=DEFAULT_TEXTBOOK_COUNTS)
    parser.add_argument("--hanzi-writer-cache", type=Path, default=DEFAULT_HANZI_WRITER_CACHE)
    parser.add_argument("--no-hanzi-writer", action="store_true")
    parser.add_argument("--no-network", action="store_true")
    parser.add_argument(
        "--no-preserve-existing-demo",
        action="store_true",
        help="Do not keep existing HJ-DEMO-* rows in the output seed.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    (
        total,
        demo_count,
        alias_count,
        manual_count,
        hanzi_writer_count,
        preserved_existing_count,
        missing_count,
        rejected_count,
    ) = build_seed(
        args.xlsx,
        args.demo_db,
        args.manual_json,
        args.output_json,
        args.report_csv,
        args.textbook_counts,
        args.hanzi_writer_cache,
        use_hanzi_writer=not args.no_hanzi_writer,
        use_network=not args.no_network,
        preserve_existing_demo=not args.no_preserve_existing_demo,
    )
    print(f"Wrote {total} stroke seed rows to {args.output_json}")
    print(f"hanja_demo exact rows: {demo_count}")
    print(f"hanja_demo alias rows: {alias_count}")
    print(f"manual rows: {manual_count}")
    print(f"hanzi_writer_data rows: {hanzi_writer_count}")
    print(f"preserved existing rows: {preserved_existing_count}")
    print(f"missing rows: {missing_count}")
    print(f"rejected candidates: {rejected_count}")
    print(f"Wrote report to {args.report_csv}")


if __name__ == "__main__":
    main()
