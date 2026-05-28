"""Generate an HTML preview from manual_stroke_capture.json."""

from __future__ import annotations

import argparse
import json
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_INPUT = Path(r"C:\Users\User\Downloads\manual_stroke_capture.json")
DEFAULT_OUTPUT = ROOT / "docs" / "prototypes" / "manual_capture_result_preview.html"
DEFAULT_HANJA_DEMO_DB = Path(
    r"C:\Projects\hanja_demo\core\src\commonMain\composeResources\files\hanja_soook_data-base-v15.sql"
)
DEFAULT_DEMO_CHARS = ["一", "百", "日", "村", "東", "家"]


def build_html(rows: list[dict[str, object]]) -> str:
    drawn = [row for row in rows if row.get("svgPaths")]
    data_json = json.dumps(drawn, ensure_ascii=False)
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Manual Capture Result Preview</title>
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
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      background: var(--bg);
      color: var(--ink);
      font-family: "Noto Sans KR", "Malgun Gothic", system-ui, sans-serif;
    }}
    main {{
      width: min(1180px, calc(100% - 28px));
      margin: 22px auto;
    }}
    header {{
      display: flex;
      justify-content: space-between;
      gap: 12px;
      align-items: center;
      margin-bottom: 14px;
    }}
    h1 {{
      margin: 0;
      font-size: 22px;
      letter-spacing: 0;
    }}
    .summary {{
      margin: 4px 0 0;
      color: var(--muted);
      font-size: 13px;
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
    .grid {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
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
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: 8px;
      margin-bottom: 8px;
    }}
    .meta strong {{
      font-family: "Noto Serif KR", Batang, serif;
      font-size: 30px;
      line-height: 1;
    }}
    .meta span {{
      color: var(--muted);
      font-size: 12px;
      text-align: right;
      white-space: nowrap;
    }}
    .source {{
      display: inline-flex;
      margin-bottom: 8px;
      border: 1px solid #d0d5dd;
      border-radius: 999px;
      padding: 2px 8px;
      color: var(--muted);
      font-size: 11px;
      font-weight: 800;
    }}
    .source.demo {{
      color: #175cd3;
      border-color: #b2ccff;
      background: #eff4ff;
    }}
    .source.manual {{
      color: #b42318;
      border-color: #fecdca;
      background: #fff1f0;
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
      animation-duration: 0.34s;
      animation-timing-function: ease-out;
      animation-fill-mode: forwards;
      animation-play-state: paused;
    }}
    .playing .stroke {{
      animation-play-state: running;
    }}
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
    .playing .num {{
      animation-play-state: running;
    }}
    @keyframes draw {{
      to {{ stroke-dashoffset: 0; }}
    }}
    @keyframes show {{
      to {{ opacity: 1; }}
    }}
  </style>
</head>
<body>
  <main>
    <header>
      <div>
        <h1>수동 캡처 획 애니메이션 미리보기</h1>
        <p class="summary">hanja_demo 기존 데이터와 수동 캡처 데이터를 같은 방식으로 재생합니다. 총 {len(drawn)}자를 표시합니다.</p>
      </div>
      <button id="replay">다시 보기</button>
    </header>
    <section id="grid" class="grid"></section>
  </main>
  <script>
    const rows = {data_json};
    const grid = document.getElementById("grid");
    const replay = document.getElementById("replay");

    function startPoint(path) {{
      const match = path.match(/M\\s*([0-9.]+)\\s+([0-9.]+)/);
      return match ? {{ x: match[1], y: match[2] }} : {{ x: 50, y: 50 }};
    }}

    function render() {{
      grid.innerHTML = rows.map((row) => {{
        const paths = row.svgPaths || [];
        const strokes = paths.map((path, index) => {{
          const delay = 0.12 + index * 0.38;
          const point = startPoint(path);
          return `
            <path class="stroke" d="${{path}}" pathLength="1" style="animation-delay:${{delay}}s"></path>
            <text class="num" x="${{point.x}}" y="${{point.y}}" style="animation-delay:${{delay + 0.08}}s">${{index + 1}}</text>
          `;
        }}).join("");
        return `
          <article class="card">
            <div class="meta">
              <strong>${{row.character}}</strong>
              <span>${{row.hanjaId}} · ${{paths.length}}획</span>
            </div>
            <span class="source ${{row.source === "hanja_demo" ? "demo" : "manual"}}">${{row.source}}</span>
            <svg viewBox="0 0 100 100" aria-label="${{row.character}} preview">
              <rect class="paper" x="4" y="4" width="92" height="92" rx="2"></rect>
              <path class="guide" d="M50 6 V94 M6 50 H94 M17 17 L83 83 M83 17 L17 83"></path>
              <text class="ghost" x="50" y="52">${{row.character}}</text>
              ${{strokes}}
            </svg>
          </article>
        `;
      }}).join("");
      requestAnimationFrame(() => document.body.classList.add("playing"));
    }}

    replay.addEventListener("click", () => {{
      document.body.classList.remove("playing");
      render();
    }});

    render();
  </script>
</body>
</html>
"""


def read_demo_rows(db_path: Path, characters: list[str]) -> list[dict[str, object]]:
    if not db_path.exists():
        return []

    rows: list[dict[str, object]] = []
    with sqlite3.connect(f"file:{db_path}?mode=ro", uri=True) as connection:
        for character in characters:
            stroke_rows = connection.execute(
                """
                SELECT stroke_path
                FROM character_stroke
                WHERE character = ?
                ORDER BY stroke_number
                """,
                (character,),
            ).fetchall()
            paths = [str(row[0]) for row in stroke_rows]
            if not paths:
                continue
            rows.append(
                {
                    "id": f"stroke-demo-{character}",
                    "hanjaId": f"demo-{character}",
                    "character": character,
                    "source": "hanja_demo",
                    "dataFormat": "svg_paths",
                    "strokeCount": len(paths),
                    "svgPaths": paths,
                    "reviewStatus": "available",
                }
            )
    return rows


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--demo-db", type=Path, default=DEFAULT_HANJA_DEMO_DB)
    parser.add_argument(
        "--demo-chars",
        default="".join(DEFAULT_DEMO_CHARS),
        help="Existing hanja_demo characters to include for comparison.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    manual_rows = json.loads(args.input.read_text(encoding="utf-8"))
    demo_rows = read_demo_rows(args.demo_db, list(args.demo_chars))
    rows = demo_rows + manual_rows
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(build_html(rows), encoding="utf-8")
    drawn = sum(1 for row in rows if row.get("svgPaths"))
    print(f"Wrote {args.output}")
    print(f"Demo rows: {len(demo_rows)}")
    print(f"Manual rows: {len(manual_rows)}")
    print(f"Drawn rows: {drawn}")


if __name__ == "__main__":
    main()
