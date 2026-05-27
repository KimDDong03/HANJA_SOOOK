"""Convert Korean school master CSV into Supabase schools seed CSV.

Run from repository root:
    python tools/school_seed/import_school_csv.py
"""

from __future__ import annotations

from pathlib import Path
import pandas as pd

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
    if pd.isna(value):
        return ""
    return str(value).strip()


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"Source CSV not found: {SOURCE}")

    df = pd.read_csv(SOURCE, encoding="cp949", dtype=str)
    missing = [col for col in COLUMN_MAP if col not in df.columns]
    if missing:
        raise ValueError(f"Missing source columns: {missing}")

    df = df[df["학교종류명"].map(clean_value) == "초등학교"].copy()
    df = df[list(COLUMN_MAP.keys())].rename(columns=COLUMN_MAP)

    for col in df.columns:
        df[col] = df[col].map(clean_value)

    df = df[(df["standard_school_code"] != "") & (df["school_name"] != "")]
    df = df.drop_duplicates(subset=["standard_school_code"], keep="first")
    df["is_active"] = True
    df["is_demo"] = False
    df = df[OUTPUT_COLUMNS]
    df = df.sort_values(["region_name", "school_name", "standard_school_code"])

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT, index=False, encoding="utf-8-sig")
    print(f"Wrote {len(df):,} elementary schools to {OUTPUT}")


if __name__ == "__main__":
    main()
