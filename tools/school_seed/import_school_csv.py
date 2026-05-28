"""Convert Korean school master CSV into Supabase schools seed CSV.

Run from repository root:
    python tools/school_seed/import_school_csv.py
"""

from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "data" / "source" / "학교기본정보_2026년03월31일기준.csv"
OUTPUT = ROOT / "supabase" / "seed" / "schools_elementary_seed.csv"

COLUMN_MAP = {
    "행정표준코드": "standard_school_code",
    "시도교육청코드": "office_code",
    "시도교육청명": "office_name",
    "학교명": "school_name",
    "영문학교명": "school_name_eng",
    "학교종류명": "school_kind",
    "시도명": "region_name",
    "관할조직명": "jurisdiction_name",
    "설립명": "establishment_type",
    "도로명우편번호": "road_zip_code",
    "도로명주소": "road_address",
    "도로명상세주소": "road_detail_address",
    "전화번호": "phone_number",
    "홈페이지주소": "homepage_url",
    "남녀공학구분명": "coeducation_type",
    "팩스번호": "fax_number",
    "설립일자": "founded_at",
    "개교기념일": "anniversary_at",
    "수정일자": "source_updated_at",
}

OUTPUT_COLUMNS = list(COLUMN_MAP.values()) + ["is_active", "is_demo"]


def clean_value(value: object) -> str:
    if value is None:
        return ""
    return str(value).strip()


def convert_school_csv(source: Path, output: Path) -> int:
    if not source.exists():
        raise FileNotFoundError(f"Source CSV not found: {source}")

    rows: list[dict[str, str]] = []
    seen_codes: set[str] = set()

    with source.open("r", encoding="cp949", newline="") as source_file:
        reader = csv.DictReader(source_file)
        missing = [col for col in COLUMN_MAP if col not in (reader.fieldnames or [])]
        if missing:
            raise ValueError(f"Missing source columns: {missing}")

        for raw_row in reader:
            if clean_value(raw_row.get("학교종류명")) != "초등학교":
                continue

            row = {
                target_column: clean_value(raw_row.get(source_column))
                for source_column, target_column in COLUMN_MAP.items()
            }

            standard_school_code = row["standard_school_code"]
            if standard_school_code == "" or row["school_name"] == "":
                continue
            if standard_school_code in seen_codes:
                continue

            seen_codes.add(standard_school_code)
            row["is_active"] = "True"
            row["is_demo"] = "False"
            rows.append(row)

    rows.sort(
        key=lambda row: (
            row["region_name"],
            row["school_name"],
            row["standard_school_code"],
        )
    )

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8-sig", newline="") as output_file:
        writer = csv.DictWriter(
            output_file,
            fieldnames=OUTPUT_COLUMNS,
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(rows)

    return len(rows)


def main() -> None:
    row_count = convert_school_csv(SOURCE, OUTPUT)
    print(f"Wrote {row_count:,} elementary schools to {OUTPUT}")


if __name__ == "__main__":
    main()
