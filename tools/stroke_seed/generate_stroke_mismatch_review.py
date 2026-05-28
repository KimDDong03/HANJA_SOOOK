"""Generate an HTML review sheet for stroke-count mismatches.

Run from repository root:
    python tools/stroke_seed/generate_stroke_mismatch_review.py
"""

from __future__ import annotations

import argparse
import csv
import json
import zipfile
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_XLSX = Path(r"C:\Users\User\Downloads\한자쏘옥완전DB초3~6학년.xlsx")
DEFAULT_SEED_JSON = ROOT / "assets" / "data" / "stroke_seed.example.json"
DEFAULT_REPORT_CSV = ROOT / "output" / "manual_stroke" / "stroke_seed_build_report.csv"
DEFAULT_OUTPUT = ROOT / "docs" / "prototypes" / "stroke_mismatch_review.html"
SPREADSHEET_NS = {"a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}


@dataclass(frozen=True)
class HanjaMeta:
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


def read_hanja_meta(xlsx: Path) -> dict[str, HanjaMeta]:
    if not xlsx.exists():
        raise FileNotFoundError(f"Excel file not found: {xlsx}")

    with zipfile.ZipFile(xlsx) as archive:
        root = ET.fromstring(archive.read("xl/worksheets/sheet1.xml"))

    result: dict[str, HanjaMeta] = {}
    for row in root.findall("a:sheetData/a:row", SPREADSHEET_NS):
        values = [cell_text(cell) for cell in row.findall("a:c", SPREADSHEET_NS)]
        if len(values) < 10 or not values[0].startswith("HJ-"):
            continue
        result[values[0]] = HanjaMeta(
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
    return result


def read_seed(seed_json: Path) -> dict[str, dict[str, object]]:
    rows = json.loads(seed_json.read_text(encoding="utf-8-sig"))
    if not isinstance(rows, list):
        raise ValueError(f"stroke seed must be a list: {seed_json}")

    result: dict[str, dict[str, object]] = {}
    for row in rows:
        if not isinstance(row, dict):
            continue
        hanja_id = str(row.get("hanjaId") or row.get("hanja_id") or "")
        if hanja_id:
            result[hanja_id] = row
    return result


def read_mismatches(report_csv: Path) -> list[dict[str, str]]:
    with report_csv.open("r", encoding="utf-8-sig", newline="") as source:
        return [
            row
            for row in csv.DictReader(source)
            if row.get("count_matches_expected") == "no"
        ]


def build_rows(
    report_csv: Path,
    seed_json: Path,
    xlsx: Path,
) -> list[dict[str, object]]:
    metadata = read_hanja_meta(xlsx)
    seed_rows = read_seed(seed_json)
    rows: list[dict[str, object]] = []

    for mismatch in read_mismatches(report_csv):
        hanja_id = mismatch["hanja_id"]
        meta = metadata.get(hanja_id)
        seed = seed_rows.get(hanja_id)
        if meta is None or seed is None:
            continue

        actual = int(mismatch["stroke_count"])
        expected = int(mismatch["expected_stroke_count"])
        rows.append(
            {
                "hanjaId": hanja_id,
                "character": meta.character,
                "sound": meta.sound,
                "meaning": meta.meaning,
                "grade": meta.grade,
                "unitId": meta.unit_id,
                "unitName": meta.unit_name,
                "lesson": meta.lesson,
                "difficulty": meta.difficulty,
                "source": mismatch["source"],
                "sourceCharacter": mismatch["source_character"],
                "actualStrokeCount": actual,
                "expectedStrokeCount": expected,
                "delta": actual - expected,
                "svgPaths": seed.get("svgPaths") or seed.get("svg_paths") or [],
            }
        )

    return rows


def build_html(rows: list[dict[str, object]]) -> str:
    data_json = json.dumps(rows, ensure_ascii=False)
    fewer_count = sum(1 for row in rows if int(row["delta"]) < 0)
    more_count = sum(1 for row in rows if int(row["delta"]) > 0)
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Stroke Mismatch Review</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f5f7fb;
      --surface: #ffffff;
      --ink: #101828;
      --muted: #667085;
      --line: #d7deea;
      --accent: #c7432b;
      --paper: #fffdf8;
      --warn: #b54708;
      --ok: #087443;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      background: var(--bg);
      color: var(--ink);
      font-family: "Noto Sans KR", "Malgun Gothic", system-ui, sans-serif;
    }}
    main {{
      width: min(1420px, calc(100% - 28px));
      margin: 22px auto;
    }}
    header {{
      display: flex;
      align-items: end;
      justify-content: space-between;
      gap: 16px;
      margin-bottom: 14px;
    }}
    h1 {{
      margin: 0;
      font-size: 22px;
      letter-spacing: 0;
    }}
    .summary {{
      margin: 6px 0 0;
      color: var(--muted);
      font-size: 13px;
    }}
    .toolbar {{
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      justify-content: flex-end;
    }}
    button {{
      height: 38px;
      border: 1px solid var(--ink);
      border-radius: 6px;
      background: var(--ink);
      color: white;
      padding: 0 14px;
      font: inherit;
      font-weight: 800;
      cursor: pointer;
    }}
    button.secondary {{
      background: white;
      color: var(--ink);
      border-color: var(--line);
    }}
    .grid {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
      gap: 14px;
    }}
    .card {{
      background: var(--surface);
      border: 1px solid #e4e7ec;
      border-radius: 8px;
      padding: 12px;
      box-shadow: 0 8px 20px rgba(16, 24, 40, 0.05);
    }}
    .meta {{
      display: grid;
      grid-template-columns: auto 1fr;
      gap: 10px;
      align-items: center;
      margin-bottom: 8px;
    }}
    .char {{
      font-family: "Noto Serif KR", Batang, serif;
      font-size: 34px;
      line-height: 1;
    }}
    .title {{
      min-width: 0;
    }}
    .title strong {{
      display: block;
      font-size: 13px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }}
    .title span {{
      display: block;
      color: var(--muted);
      font-size: 12px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }}
    .badges {{
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      margin-bottom: 8px;
    }}
    .badge {{
      display: inline-flex;
      border: 1px solid #d0d5dd;
      border-radius: 999px;
      padding: 2px 8px;
      color: var(--muted);
      font-size: 11px;
      font-weight: 800;
    }}
    .badge.warn {{
      color: var(--warn);
      border-color: #fedf89;
      background: #fffaeb;
    }}
    .badge.more {{
      color: #175cd3;
      border-color: #b2ccff;
      background: #eff4ff;
    }}
    dl {{
      display: grid;
      grid-template-columns: auto 1fr;
      gap: 4px 8px;
      margin: 8px 0;
      font-size: 12px;
    }}
    dt {{ color: var(--muted); }}
    dd {{
      margin: 0;
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }}
    svg {{
      display: block;
      width: 100%;
      aspect-ratio: 1;
    }}
    .paper {{
      fill: var(--paper);
      stroke: #d8c7a2;
      stroke-width: 0.75;
    }}
    .guide {{
      fill: none;
      stroke: #d8c7a2;
      stroke-width: 0.35;
      stroke-dasharray: 1.4 1.6;
    }}
    .ghost {{
      fill: rgba(16, 24, 40, 0.075);
      font-family: "Noto Serif KR", Batang, serif;
      font-size: 78px;
      font-weight: 700;
      text-anchor: middle;
      dominant-baseline: central;
    }}
    .stroke {{
      fill: none;
      stroke: var(--accent);
      stroke-width: 4.4;
      stroke-linecap: round;
      stroke-linejoin: round;
      stroke-dasharray: 1;
      stroke-dashoffset: 1;
      animation-name: draw;
      animation-duration: 0.28s;
      animation-timing-function: ease-out;
      animation-fill-mode: forwards;
      animation-play-state: paused;
    }}
    .playing .stroke {{ animation-play-state: running; }}
    .num {{
      fill: white;
      stroke: var(--accent);
      stroke-width: 0.65;
      paint-order: stroke fill;
      font-size: 5px;
      font-weight: 900;
      dominant-baseline: central;
      text-anchor: middle;
      opacity: 0;
      animation: show 0.16s ease-out forwards paused;
    }}
    .playing .num {{ animation-play-state: running; }}
    @keyframes draw {{ to {{ stroke-dashoffset: 0; }} }}
    @keyframes show {{ to {{ opacity: 1; }} }}
    @media (max-width: 760px) {{
      header {{ align-items: start; flex-direction: column; }}
      .toolbar {{ justify-content: start; }}
    }}
  </style>
</head>
<body>
  <main>
    <header>
      <div>
        <h1>획수 불일치 검수</h1>
        <p class="summary">총 {len(rows)}건 · 실제 획수 적음 {fewer_count}건 · 실제 획수 많음 {more_count}건</p>
      </div>
      <div class="toolbar">
        <button class="secondary" data-filter="all">전체</button>
        <button class="secondary" data-filter="fewer">실제 획수 적음</button>
        <button class="secondary" data-filter="more">실제 획수 많음</button>
        <button id="replay">다시 보기</button>
      </div>
    </header>
    <section id="grid" class="grid"></section>
  </main>
  <script>
    const rows = {data_json};
    const grid = document.getElementById("grid");
    const replay = document.getElementById("replay");
    let activeFilter = "all";

    function esc(value) {{
      return String(value ?? "").replace(/[&<>"']/g, (ch) => ({{
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#039;",
      }}[ch]));
    }}

    function startPoint(path) {{
      const match = String(path).match(/M\\s*([0-9.+-]+)[,\\s]+([0-9.+-]+)/i);
      return match ? {{ x: match[1], y: match[2] }} : {{ x: 50, y: 50 }};
    }}

    function visibleRows() {{
      if (activeFilter === "fewer") return rows.filter((row) => row.delta < 0);
      if (activeFilter === "more") return rows.filter((row) => row.delta > 0);
      return rows;
    }}

    function render() {{
      const data = visibleRows();
      grid.innerHTML = data.map((row) => {{
        const paths = row.svgPaths || [];
        const deltaLabel = row.delta > 0 ? `+${{row.delta}}` : row.delta;
        const deltaClass = row.delta > 0 ? "more" : "warn";
        const strokes = paths.map((path, index) => {{
          const delay = 0.1 + index * 0.3;
          const point = startPoint(path);
          return `
            <path class="stroke" d="${{esc(path)}}" pathLength="1" style="animation-delay:${{delay}}s"></path>
            <text class="num" x="${{point.x}}" y="${{point.y}}" style="animation-delay:${{delay + 0.08}}s">${{index + 1}}</text>
          `;
        }}).join("");
        return `
          <article class="card">
            <div class="meta">
              <div class="char">${{esc(row.character)}}</div>
              <div class="title">
                <strong>${{esc(row.hanjaId)}} · ${{esc(row.sound)}} · ${{esc(row.meaning)}}</strong>
                <span>${{esc(row.unitId)}} · ${{esc(row.unitName)}}</span>
              </div>
            </div>
            <div class="badges">
              <span class="badge">${{esc(row.source)}}</span>
              <span class="badge ${{deltaClass}}">현재 ${{row.actualStrokeCount}} / 기준 ${{row.expectedStrokeCount}} (${{deltaLabel}})</span>
            </div>
            <dl>
              <dt>원본자</dt><dd>${{esc(row.sourceCharacter)}}</dd>
              <dt>난이도</dt><dd>${{esc(row.grade)}} · ${{esc(row.difficulty)}}</dd>
            </dl>
            <svg viewBox="0 0 100 100" aria-label="${{esc(row.character)}} preview">
              <rect class="paper" x="4" y="4" width="92" height="92" rx="2"></rect>
              <path class="guide" d="M50 6 V94 M6 50 H94 M17 17 L83 83 M83 17 L17 83"></path>
              <text class="ghost" x="50" y="52">${{esc(row.character)}}</text>
              ${{strokes}}
            </svg>
          </article>
        `;
      }}).join("");
      document.body.classList.remove("playing");
      requestAnimationFrame(() => document.body.classList.add("playing"));
    }}

    document.querySelectorAll("[data-filter]").forEach((button) => {{
      button.addEventListener("click", () => {{
        activeFilter = button.dataset.filter;
        render();
      }});
    }});
    replay.addEventListener("click", render);
    render();
  </script>
</body>
</html>
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--xlsx", type=Path, default=DEFAULT_XLSX)
    parser.add_argument("--seed-json", type=Path, default=DEFAULT_SEED_JSON)
    parser.add_argument("--report-csv", type=Path, default=DEFAULT_REPORT_CSV)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    rows = build_rows(args.report_csv, args.seed_json, args.xlsx)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(build_html(rows), encoding="utf-8")
    print(f"Wrote {args.output}")
    print(f"Mismatch rows: {len(rows)}")


if __name__ == "__main__":
    main()
