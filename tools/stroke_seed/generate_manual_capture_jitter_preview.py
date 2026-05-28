"""Generate a light jitter-reduction preview for manual stroke captures."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_INPUT = Path(r"C:\Users\User\Downloads\manual_stroke_capture.json")
DEFAULT_OUTPUT = ROOT / "docs" / "prototypes" / "manual_capture_jitter_preview.html"
NUMBER_RE = re.compile(r"-?\d+(?:\.\d+)?")


def parse_points(path: str) -> list[tuple[float, float]]:
    numbers = [float(match.group(0)) for match in NUMBER_RE.finditer(path)]
    return list(zip(numbers[0::2], numbers[1::2]))


def fmt(value: float) -> str:
    return f"{value:.2f}".rstrip("0").rstrip(".")


def reduce_near_duplicates(points: list[tuple[float, float]], min_distance: float = 1.5) -> list[tuple[float, float]]:
    if len(points) <= 2:
        return points
    reduced = [points[0]]
    for point in points[1:-1]:
        prev = reduced[-1]
        if ((point[0] - prev[0]) ** 2 + (point[1] - prev[1]) ** 2) ** 0.5 >= min_distance:
            reduced.append(point)
    reduced.append(points[-1])
    return reduced


def smooth_jitter(points: list[tuple[float, float]]) -> list[tuple[float, float]]:
    """Light smoothing that preserves endpoints and overall handwritten shape."""
    if len(points) <= 3:
        return points

    smoothed = [points[0]]
    for index in range(1, len(points) - 1):
        prev_point = points[index - 1]
        point = points[index]
        next_point = points[index + 1]
        smoothed.append(
            (
                prev_point[0] * 0.24 + point[0] * 0.52 + next_point[0] * 0.24,
                prev_point[1] * 0.24 + point[1] * 0.52 + next_point[1] * 0.24,
            )
        )
    smoothed.append(points[-1])
    return smoothed


def perpendicular_distance(
    point: tuple[float, float],
    start: tuple[float, float],
    end: tuple[float, float],
) -> float:
    if start == end:
        return ((point[0] - start[0]) ** 2 + (point[1] - start[1]) ** 2) ** 0.5
    x, y = point
    x1, y1 = start
    x2, y2 = end
    numerator = abs((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1)
    denominator = ((y2 - y1) ** 2 + (x2 - x1) ** 2) ** 0.5
    return numerator / denominator


def rdp(points: list[tuple[float, float]], epsilon: float) -> list[tuple[float, float]]:
    if len(points) <= 2:
        return points
    index = 0
    max_distance = 0.0
    for i in range(1, len(points) - 1):
        distance = perpendicular_distance(points[i], points[0], points[-1])
        if distance > max_distance:
            index = i
            max_distance = distance
    if max_distance > epsilon:
        return rdp(points[: index + 1], epsilon)[:-1] + rdp(points[index:], epsilon)
    return [points[0], points[-1]]


def points_to_curve_path(points: list[tuple[float, float]]) -> str:
    if not points:
        return ""
    if len(points) == 1:
        return f"M{fmt(points[0][0])} {fmt(points[0][1])}"
    if len(points) == 2:
        return (
            f"M{fmt(points[0][0])} {fmt(points[0][1])} "
            f"L{fmt(points[1][0])} {fmt(points[1][1])}"
        )

    path = f"M{fmt(points[0][0])} {fmt(points[0][1])}"
    for index in range(1, len(points) - 1):
        current = points[index]
        next_point = points[index + 1]
        midpoint = ((current[0] + next_point[0]) / 2, (current[1] + next_point[1]) / 2)
        path += f" Q{fmt(current[0])} {fmt(current[1])} {fmt(midpoint[0])} {fmt(midpoint[1])}"
    path += f" T{fmt(points[-1][0])} {fmt(points[-1][1])}"
    return path


def jitter_reduce_path(path: str) -> str:
    points = parse_points(path)
    if len(points) < 2:
        return path
    reduced = reduce_near_duplicates(points)
    smoothed = reduced
    for _ in range(4):
        smoothed = smooth_jitter(smoothed)
    simplified = rdp(smoothed, epsilon=1.25)
    if len(simplified) > 8:
        simplified = rdp(smoothed, epsilon=1.9)
    if len(simplified) > 12:
        simplified = simplified[::2] + [simplified[-1]]
    return points_to_curve_path(simplified)


def jitter_rows(rows: list[dict[str, object]]) -> list[dict[str, object]]:
    output = []
    for row in rows:
        paths = row.get("svgPaths") or []
        if not paths:
            continue
        next_row = dict(row)
        next_row["source"] = "manual_jitter_reduced"
        next_row["id"] = f"{row.get('id', 'stroke')}-jitter"
        next_row["svgPaths"] = [jitter_reduce_path(str(path)) for path in paths]
        output.append(next_row)
    return output


def build_html(originals: list[dict[str, object]], jittered: list[dict[str, object]]) -> str:
    original_json = json.dumps(originals, ensure_ascii=False)
    jitter_json = json.dumps(jittered, ensure_ascii=False)
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Manual Capture Jitter Preview</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f5f7fb;
      --surface: #ffffff;
      --ink: #101828;
      --muted: #667085;
      --raw: #98a2b3;
      --clean: #c7432b;
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
      width: min(1240px, calc(100% - 28px));
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
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
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
    .pair {{
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }}
    .label {{
      margin: 0 0 4px;
      color: var(--muted);
      font-size: 12px;
      font-weight: 800;
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
    .raw .stroke {{ stroke: var(--raw); }}
    .clean .stroke {{ stroke: var(--clean); }}
    .playing .stroke {{ animation-play-state: running; }}
    @keyframes draw {{
      to {{ stroke-dashoffset: 0; }}
    }}
  </style>
</head>
<body>
  <main>
    <header>
      <div>
        <h1>원본 유지 흔들림 보정 비교</h1>
        <p class="summary">왼쪽은 원본, 오른쪽은 글자 형태를 바꾸지 않고 손떨림만 약하게 줄인 버전입니다.</p>
      </div>
      <button id="replay">다시 보기</button>
    </header>
    <section id="grid" class="grid"></section>
  </main>
  <script>
    const originals = {original_json};
    const jittered = {jitter_json};
    const grid = document.getElementById("grid");
    const replay = document.getElementById("replay");

    function renderSvg(row, mode) {{
      const strokes = (row.svgPaths || []).map((path, index) => {{
        const delay = 0.12 + index * 0.38;
        return `<path class="stroke" d="${{path}}" pathLength="1" style="animation-delay:${{delay}}s"></path>`;
      }}).join("");
      return `
        <svg class="${{mode}}" viewBox="0 0 100 100">
          <rect class="paper" x="4" y="4" width="92" height="92" rx="2"></rect>
          <path class="guide" d="M50 6 V94 M6 50 H94 M17 17 L83 83 M83 17 L17 83"></path>
          <text class="ghost" x="50" y="52">${{row.character}}</text>
          ${{strokes}}
        </svg>
      `;
    }}

    function render() {{
      grid.innerHTML = originals.map((row, index) => `
        <article class="card">
          <div class="meta">
            <strong>${{row.character}}</strong>
            <span>${{row.hanjaId}} · ${{row.svgPaths.length}}획</span>
          </div>
          <div class="pair">
            <div>
              <p class="label">원본</p>
              ${{renderSvg(row, "raw")}}
            </div>
            <div>
              <p class="label">흔들림만 보정</p>
              ${{renderSvg(jittered[index], "clean")}}
            </div>
          </div>
        </article>
      `).join("");
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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    rows = json.loads(args.input.read_text(encoding="utf-8"))
    originals = [row for row in rows if row.get("svgPaths")]
    jittered = jitter_rows(originals)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(build_html(originals, jittered), encoding="utf-8")
    print(f"Wrote {args.output}")
    print(f"Rows: {len(originals)}")


if __name__ == "__main__":
    main()
