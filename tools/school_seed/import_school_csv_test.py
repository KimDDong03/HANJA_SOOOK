from __future__ import annotations

import csv
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from import_school_csv import COLUMN_MAP, OUTPUT_COLUMNS, convert_school_csv


class ImportSchoolCsvTest(unittest.TestCase):
    def test_convert_school_csv_filters_and_normalizes_rows(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            source = temp_path / "source.csv"
            output = temp_path / "schools_elementary_seed.csv"

            source_columns = list(COLUMN_MAP.keys()) + ["고등학교구분명"]
            rows = [
                self._row(" 1001 ", " 한빛초등학교 ", "초등학교"),
                self._row("1001", "중복초등학교", "초등학교"),
                self._row("1002", "한빛중학교", "중학교"),
                self._row("", "코드없음초등학교", "초등학교"),
                self._row("1003", " ", "초등학교"),
                self._row("1004", "가람초등학교", "초등학교"),
            ]

            with source.open("w", encoding="cp949", newline="") as source_file:
                writer = csv.DictWriter(source_file, fieldnames=source_columns)
                writer.writeheader()
                writer.writerows(rows)

            row_count = convert_school_csv(source, output)

            self.assertEqual(row_count, 2)
            with output.open("r", encoding="utf-8-sig", newline="") as output_file:
                output_rows = list(csv.DictReader(output_file))

            self.assertEqual(OUTPUT_COLUMNS, list(output_rows[0].keys()))
            self.assertEqual(
                ["1004", "1001"],
                [row["standard_school_code"] for row in output_rows],
            )
            self.assertEqual(
                ["가람초등학교", "한빛초등학교"],
                [row["school_name"] for row in output_rows],
            )
            self.assertTrue(all(row["school_kind"] == "초등학교" for row in output_rows))
            self.assertTrue(all(row["is_active"] == "True" for row in output_rows))
            self.assertTrue(all(row["is_demo"] == "False" for row in output_rows))

    def test_convert_school_csv_reports_missing_columns(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            source = Path(temp_dir) / "source.csv"
            output = Path(temp_dir) / "output.csv"
            source.write_text("학교명\n한빛초등학교\n", encoding="cp949")

            with self.assertRaises(ValueError):
                convert_school_csv(source, output)

    def _row(
        self,
        standard_school_code: str,
        school_name: str,
        school_kind: str,
    ) -> dict[str, str]:
        row = {source_column: "" for source_column in COLUMN_MAP}
        row.update(
            {
                "행정표준코드": standard_school_code,
                "학교명": school_name,
                "학교종류명": school_kind,
                "시도명": "서울특별시",
                "도로명주소": "서울특별시 예시로 1",
            }
        )
        row["고등학교구분명"] = ""
        return row


if __name__ == "__main__":
    unittest.main()
