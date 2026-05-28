from __future__ import annotations

import argparse
import csv
import json
import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SEED_JSON = ROOT / "assets" / "data" / "stroke_seed.example.json"
DEFAULT_REPORT_CSV = ROOT / "output" / "manual_stroke" / "stroke_seed_build_report.csv"
DEFAULT_HANJA_DEMO_DB = Path(
    r"C:\Projects\hanja_demo\core\src\commonMain\composeResources\files\hanja_soook_data-base-v15.sql"
)
DEFAULT_OUTPUT = ROOT / "docs" / "prototypes" / "stroke_source_comparison_preview.html"

DEMO_SAMPLE_IDS = [
    "HJ-0001",
    "HJ-0002",
    "HJ-0019",
    "HJ-0023",
    "HJ-0024",
    "HJ-0129",
    "HJ-0139",
    "HJ-0181",
    "HJ-0341",
    "HJ-0558",
    "HJ-0711",
]


def read_demo_paths(db_path: Path) -> dict[str, list[str]]:
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


def build_preview(
    seed_json: Path,
    report_csv: Path,
    demo_db: Path,
    output_html: Path,
) -> None:
    seed_rows = json.loads(seed_json.read_text(encoding="utf-8-sig"))
    report_rows = {
        row["hanja_id"]: row
        for row in csv.DictReader(report_csv.open(encoding="utf-8-sig", newline=""))
    }
    demo_paths = read_demo_paths(demo_db)

    seed_by_id = {
        str(row.get("hanjaId") or row.get("hanja_id")): row
        for row in seed_rows
        if isinstance(row, dict) and str(row.get("hanjaId") or row.get("hanja_id"))
    }

    comparisons: list[dict[str, object]] = []
    for seed in seed_rows:
        if seed.get("source") != "hanzi_writer_data":
            continue
        hanja_id = str(seed["hanjaId"])
        report = report_rows[hanja_id]
        demo_character = str(seed.get("sourceCharacter") or seed["character"])
        demo = demo_paths.get(demo_character, [])
        comparisons.append(
            {
                "group": "hanzi_writer_vs_demo",
                "hanjaId": hanja_id,
                "excelCharacter": report["excel_character"],
                "textbookCharacter": report["textbook_character"],
                "sound": report["sound"],
                "meaning": report["meaning"],
                "grade": report["grade"],
                "unit": report["unit"],
                "lesson": report["lesson"],
                "expectedStrokeCount": int(report["expected_stroke_count"]),
                "selected": {
                    "label": "hanzi_writer_data",
                    "source": "hanzi_writer_data",
                    "strokeCount": len(seed.get("svgPaths") or []),
                    "paths": seed.get("svgPaths") or [],
                },
                "comparison": {
                    "label": "hanja_demo 후보",
                    "source": "hanja_demo",
                    "strokeCount": len(demo),
                    "paths": demo,
                },
            }
        )

    demo_samples: list[dict[str, object]] = []
    for hanja_id in DEMO_SAMPLE_IDS:
        seed = seed_by_id.get(hanja_id)
        report = report_rows.get(hanja_id)
        if not seed or seed.get("source") != "hanja_demo" or not report:
            continue
        demo_samples.append(
            {
                "group": "hanja_demo_sample",
                "hanjaId": hanja_id,
                "excelCharacter": report["excel_character"],
                "textbookCharacter": report["textbook_character"],
                "sound": report["sound"],
                "meaning": report["meaning"],
                "grade": report["grade"],
                "unit": report["unit"],
                "lesson": report["lesson"],
                "expectedStrokeCount": int(report["expected_stroke_count"]),
                "selected": {
                    "label": "hanja_demo 채택",
                    "source": "hanja_demo",
                    "strokeCount": len(seed.get("svgPaths") or []),
                    "paths": seed.get("svgPaths") or [],
                },
                "comparison": None,
            }
        )

    output_html.parent.mkdir(parents=True, exist_ok=True)
    output_html.write_text(
        render_html(comparisons, demo_samples),
        encoding="utf-8",
    )
    print(f"wrote {output_html}")
    print(f"hanzi writer comparisons {len(comparisons)}")
    print(f"hanja_demo samples {len(demo_samples)}")


def render_html(
    comparisons: list[dict[str, object]],
    demo_samples: list[dict[str, object]],
) -> str:
    comparisons_json = json.dumps(comparisons, ensure_ascii=False)
    demo_samples_json = json.dumps(demo_samples, ensure_ascii=False)
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Stroke Source Comparison Preview</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f5f7fb;
      --surface: #ffffff;
      --ink: #101828;
      --muted: #667085;
      --line: #d7deea;
      --paper: #fffdf8;
      --demo: #175cd3;
      --hanzi: #9a3412;
      --stroke: #c7432b;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      background: var(--bg);
      color: var(--ink);
      font-family: "Noto Sans KR", "Malgun Gothic", system-ui, sans-serif;
    }}
    main {{
      width: min(1460px, calc(100% - 28px));
      margin: 22px auto;
    }}
    header {{
      display: flex;
      justify-content: space-between;
      align-items: end;
      gap: 16px;
      margin-bottom: 14px;
    }}
    h1 {{
      margin: 0;
      font-size: 22px;
      letter-spacing: 0;
    }}
    h2 {{
      margin: 24px 0 10px;
      font-size: 18px;
      letter-spacing: 0;
    }}
    .summary {{
      margin: 6px 0 0;
      color: var(--muted);
      font-size: 13px;
    }}
    button {{
      height: 38px;
      border: 1px solid var(--ink);
      border-radius: 6px;
      background: var(--ink);
      color: #fff;
      padding: 0 14px;
      font: inherit;
      font-weight: 800;
      cursor: pointer;
    }}
    .grid {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(430px, 1fr));
      gap: 14px;
    }}
    .samples {{
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    }}
    .card {{
      background: var(--surface);
      border: 1px solid #e4e7ec;
      border-radius: 8px;
      padding: 12px;
      box-shadow: 0 8px 20px rgba(16, 24, 40, 0.05);
    }}
    .card-head {{
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
    .title strong {{
      display: block;
      font-size: 13px;
    }}
    .title span {{
      display: block;
      color: var(--muted);
      font-size: 12px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }}
    .compare {{
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }}
    .sample-one {{
      display: block;
    }}
    .panel {{
      min-width: 0;
    }}
    .panel-head {{
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      margin-bottom: 6px;
    }}
    .badge {{
      display: inline-flex;
      align-items: center;
      border: 1px solid #d0d5dd;
      border-radius: 999px;
      padding: 2px 8px;
      color: var(--muted);
      font-size: 11px;
      font-weight: 800;
      white-space: nowrap;
    }}
    .badge.hanzi {{
      color: var(--hanzi);
      border-color: #fed7aa;
      background: #fff7ed;
    }}
    .badge.demo {{
      color: var(--demo);
      border-color: #b2ccff;
      background: #eff4ff;
    }}
    .count {{
      color: var(--muted);
      font-size: 12px;
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
      font-size: 82px;
      font-weight: 700;
      text-anchor: middle;
      dominant-baseline: central;
    }}
    .stroke {{
      fill: none;
      stroke: var(--stroke);
      stroke-width: 4.2;
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
    .trace {{
      fill: none;
      stroke: rgba(199, 67, 43, 0.24);
      stroke-width: 4;
      stroke-linecap: round;
      stroke-linejoin: round;
    }}
    .playing .stroke {{
      animation-play-state: running;
    }}
    .num {{
      fill: white;
      stroke: var(--stroke);
      stroke-width: 0.7;
      paint-order: stroke fill;
      font-size: 5px;
      font-weight: 900;
      dominant-baseline: central;
      text-anchor: middle;
      opacity: 0;
      animation: show 0.16s ease-out forwards paused;
    }}
    .playing .num {{
      animation-play-state: running;
    }}
    @keyframes draw {{
      to {{ stroke-dashoffset: 0; }}
    }}
    @keyframes show {{
      to {{ opacity: 1; }}
    }}
    @media (max-width: 720px) {{
      header {{
        align-items: stretch;
        flex-direction: column;
      }}
      .grid, .samples {{
        grid-template-columns: 1fr;
      }}
      .compare {{
        grid-template-columns: 1fr;
      }}
    }}
  </style>
</head>
<body>
  <main>
    <header>
      <div>
        <h1>획 데이터 소스 비교 미리보기</h1>
        <p class="summary">Hanzi Writer로 채택된 글자는 hanja_demo 후보와 좌우 비교합니다. 아래에는 hanja_demo 채택 샘플을 따로 표시합니다.</p>
      </div>
      <button id="replay">다시 보기</button>
    </header>
    <h2>Hanzi Writer 채택 21자 vs hanja_demo 후보</h2>
    <section id="comparisonGrid" class="grid"></section>
    <h2>hanja_demo 채택 샘플</h2>
    <section id="sampleGrid" class="grid samples"></section>
  </main>
  <script>
    const comparisons = {comparisons_json};
    const demoSamples = {demo_samples_json};
    const replay = document.getElementById("replay");
    const comparisonGrid = document.getElementById("comparisonGrid");
    const sampleGrid = document.getElementById("sampleGrid");

    function esc(value) {{
      return String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;");
    }}

    function startPoint(path) {{
      const match = String(path).match(/[Mm]\\s*([-+0-9.eE]+)[,\\s]+([-+0-9.eE]+)/);
      return match ? {{ x: Number(match[1]), y: Number(match[2]) }} : {{ x: 54, y: 54 }};
    }}

    function sourceClass(source) {{
      return source === "hanzi_writer_data" ? "hanzi" : "demo";
    }}

    function renderSvg(item, character) {{
      const paths = item?.paths || [];
      const traces = paths.map((path) => `<path class="trace" d="${{esc(path)}}"></path>`).join("");
      const strokes = paths.map((path, index) => {{
        const delay = 0.08 + index * 0.23;
        const point = startPoint(path);
        return `
          <path class="stroke" d="${{esc(path)}}" pathLength="1" style="animation-delay:${{delay}}s"></path>
          <text class="num" x="${{point.x}}" y="${{point.y}}" style="animation-delay:${{delay + 0.06}}s">${{index + 1}}</text>
        `;
      }}).join("");
      return `
        <svg viewBox="0 0 109 109" aria-label="${{esc(character)}} preview">
          <rect class="paper" x="5" y="5" width="99" height="99" rx="2"></rect>
          <path class="guide" d="M54.5 7 V102 M7 54.5 H102 M19 19 L90 90 M90 19 L19 90"></path>
          <text class="ghost" x="54.5" y="57">${{esc(character)}}</text>
          ${{traces}}
          ${{strokes}}
        </svg>
      `;
    }}

    function renderPanel(item, character, expected) {{
      if (!item) return "";
      const mismatch = item.strokeCount === expected ? "" : ` / 교과서 ${{expected}}획`;
      return `
        <div class="panel">
          <div class="panel-head">
            <span class="badge ${{sourceClass(item.source)}}">${{esc(item.label)}}</span>
            <span class="count">${{item.strokeCount}}획${{mismatch}}</span>
          </div>
          ${{renderSvg(item, character)}}
        </div>
      `;
    }}

    function renderComparison(row) {{
      return `
        <article class="card">
          <div class="card-head">
            <div class="char">${{esc(row.textbookCharacter)}}</div>
            <div class="title">
              <strong>${{esc(row.hanjaId)}} · ${{esc(row.meaning)}}</strong>
              <span>${{esc(row.grade)}} ${{esc(row.unit)}}-${{esc(row.lesson)}} · 교과서 ${{row.expectedStrokeCount}}획</span>
            </div>
          </div>
          <div class="compare">
            ${{renderPanel(row.selected, row.textbookCharacter, row.expectedStrokeCount)}}
            ${{renderPanel(row.comparison, row.textbookCharacter, row.expectedStrokeCount)}}
          </div>
        </article>
      `;
    }}

    function renderSample(row) {{
      return `
        <article class="card">
          <div class="card-head">
            <div class="char">${{esc(row.textbookCharacter)}}</div>
            <div class="title">
              <strong>${{esc(row.hanjaId)}} · ${{esc(row.meaning)}}</strong>
              <span>${{esc(row.grade)}} ${{esc(row.unit)}}-${{esc(row.lesson)}} · ${{row.expectedStrokeCount}}획</span>
            </div>
          </div>
          <div class="sample-one">
            ${{renderPanel(row.selected, row.textbookCharacter, row.expectedStrokeCount)}}
          </div>
        </article>
      `;
    }}

    function render() {{
      comparisonGrid.innerHTML = comparisons.map(renderComparison).join("");
      sampleGrid.innerHTML = demoSamples.map(renderSample).join("");
      requestAnimationFrame(() => document.body.classList.add("playing"));
    }}

    replay.addEventListener("click", () => {{
      document.body.classList.remove("playing");
      void document.body.offsetWidth;
      document.body.classList.add("playing");
    }});

    render();
  </script>
</body>
</html>
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed-json", type=Path, default=DEFAULT_SEED_JSON)
    parser.add_argument("--report-csv", type=Path, default=DEFAULT_REPORT_CSV)
    parser.add_argument("--demo-db", type=Path, default=DEFAULT_HANJA_DEMO_DB)
    parser.add_argument("--output-html", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    build_preview(args.seed_json, args.report_csv, args.demo_db, args.output_html)


if __name__ == "__main__":
    main()
