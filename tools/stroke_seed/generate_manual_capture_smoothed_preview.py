"""Generate original vs smoothed preview for manual stroke captures."""

from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_INPUT = Path(r"C:\Users\User\Downloads\manual_stroke_capture.json")
DEFAULT_OUTPUT = ROOT / "docs" / "prototypes" / "manual_capture_smoothed_preview.html"
NUMBER_RE = re.compile(r"-?\d+(?:\.\d+)?")


def parse_path_points(path: str) -> list[tuple[float, float]]:
    numbers = [float(match.group(0)) for match in NUMBER_RE.finditer(path)]
    return list(zip(numbers[0::2], numbers[1::2]))


def format_number(value: float) -> str:
    return f"{value:.2f}".rstrip("0").rstrip(".")


def point_distance(a: tuple[float, float], b: tuple[float, float]) -> float:
    return math.hypot(a[0] - b[0], a[1] - b[1])


def perpendicular_distance(
    point: tuple[float, float],
    start: tuple[float, float],
    end: tuple[float, float],
) -> float:
    if start == end:
        return point_distance(point, start)
    x, y = point
    x1, y1 = start
    x2, y2 = end
    numerator = abs((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1)
    denominator = math.hypot(y2 - y1, x2 - x1)
    return numerator / denominator


def rdp(points: list[tuple[float, float]], epsilon: float) -> list[tuple[float, float]]:
    if len(points) <= 2:
        return points

    max_distance = 0.0
    index = 0
    for i in range(1, len(points) - 1):
        distance = perpendicular_distance(points[i], points[0], points[-1])
        if distance > max_distance:
            index = i
            max_distance = distance

    if max_distance > epsilon:
        left = rdp(points[: index + 1], epsilon)
        right = rdp(points[index:], epsilon)
        return left[:-1] + right
    return [points[0], points[-1]]


def smooth_points(points: list[tuple[float, float]]) -> list[tuple[float, float]]:
    if len(points) <= 2:
        return points

    smoothed = [points[0]]
    for index in range(1, len(points) - 1):
        prev_point = points[index - 1]
        point = points[index]
        next_point = points[index + 1]
        smoothed.append(
            (
                prev_point[0] * 0.2 + point[0] * 0.6 + next_point[0] * 0.2,
                prev_point[1] * 0.2 + point[1] * 0.6 + next_point[1] * 0.2,
            )
        )
    smoothed.append(points[-1])
    return smoothed


def linear_regression(points: list[tuple[float, float]]) -> tuple[float, float] | None:
    n = len(points)
    if n < 2:
        return None
    mean_x = sum(point[0] for point in points) / n
    mean_y = sum(point[1] for point in points) / n
    denominator = sum((point[0] - mean_x) ** 2 for point in points)
    if abs(denominator) < 0.0001:
        return None
    slope = sum((point[0] - mean_x) * (point[1] - mean_y) for point in points) / denominator
    intercept = mean_y - slope * mean_x
    return slope, intercept


def straighten_if_axis_aligned(points: list[tuple[float, float]]) -> str | None:
    if len(points) < 2:
        return None

    start = points[0]
    end = points[-1]
    dx = end[0] - start[0]
    dy = end[1] - start[1]
    width = max(point[0] for point in points) - min(point[0] for point in points)
    height = max(point[1] for point in points) - min(point[1] for point in points)
    length = max(point_distance(start, end), 0.01)

    if abs(dy) / length < 0.16 and height < 3.0:
        y = sum(point[1] for point in points) / len(points)
        x1 = min(point[0] for point in points)
        x2 = max(point[0] for point in points)
        return f"M{format_number(x1)} {format_number(y)} L{format_number(x2)} {format_number(y)}"

    if abs(dx) / length < 0.16 and width < 3.0:
        x = sum(point[0] for point in points) / len(points)
        y1 = min(point[1] for point in points)
        y2 = max(point[1] for point in points)
        return f"M{format_number(x)} {format_number(y1)} L{format_number(x)} {format_number(y2)}"

    return None


def to_quadratic_path(points: list[tuple[float, float]]) -> str:
    if not points:
        return ""
    if len(points) == 1:
        return f"M{format_number(points[0][0])} {format_number(points[0][1])}"
    if len(points) == 2:
        return (
            f"M{format_number(points[0][0])} {format_number(points[0][1])} "
            f"L{format_number(points[1][0])} {format_number(points[1][1])}"
        )

    path = f"M{format_number(points[0][0])} {format_number(points[0][1])}"
    index = 1
    while index < len(points) - 1:
        control = points[index]
        end = (
            (points[index][0] + points[index + 1][0]) / 2,
            (points[index][1] + points[index + 1][1]) / 2,
        )
        path += (
            f" Q{format_number(control[0])} {format_number(control[1])} "
            f"{format_number(end[0])} {format_number(end[1])}"
        )
        index += 1
    last = points[-1]
    path += f" T{format_number(last[0])} {format_number(last[1])}"
    return path


def smooth_path(path: str) -> str:
    points = parse_path_points(path)
    if len(points) < 2:
        return path

    axis = straighten_if_axis_aligned(points)
    if axis is not None:
        return axis

    simplified = rdp(points, epsilon=1.6)
    if len(simplified) > 8:
        simplified = rdp(points, epsilon=2.4)
    smoothed = smooth_points(simplified)

    axis_after = straighten_if_axis_aligned(smoothed)
    if axis_after is not None:
        return axis_after

    if len(smoothed) <= 3:
        return " ".join(
            [
                f"M{format_number(smoothed[0][0])} {format_number(smoothed[0][1])}",
                *[
                    f"L{format_number(point[0])} {format_number(point[1])}"
                    for point in smoothed[1:]
                ],
            ]
        )
    return to_quadratic_path(smoothed)


def build_smoothed_rows(rows: list[dict[str, object]]) -> list[dict[str, object]]:
    smoothed_rows: list[dict[str, object]] = []
    for row in rows:
        paths = row.get("svgPaths") or []
        if not paths:
            continue
        smoothed = dict(row)
        smoothed["source"] = "manual_smoothed"
        smoothed["id"] = f"{row.get('id', 'stroke')}-smoothed"
        smoothed["svgPaths"] = [smooth_path(str(path)) for path in paths]
        smoothed_rows.append(smoothed)
    return smoothed_rows


def build_html(original_rows: list[dict[str, object]], smoothed_rows: list[dict[str, object]]) -> str:
    originals = [row for row in original_rows if row.get("svgPaths")]
    original_json = json.dumps(originals, ensure_ascii=False)
    smoothed_json = json.dumps(smoothed_rows, ensure_ascii=False)
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Manual Capture Smoothed Preview</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f5f7fb;
      --surface: #ffffff;
      --ink: #101828;
      --muted: #667085;
      --line: #d7deea;
      --raw: #98a2b3;
      --smooth: #c7432b;
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
    .smooth .stroke {{ stroke: var(--smooth); }}
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
        <h1>수동 캡처 보정 비교</h1>
        <p class="summary">왼쪽은 원본 마우스 입력, 오른쪽은 자동 단순화/직선화/곡선화 1차 보정입니다.</p>
      </div>
      <button id="replay">다시 보기</button>
    </header>
    <section id="grid" class="grid"></section>
  </main>
  <script>
    const originals = {original_json};
    const smoothed = {smoothed_json};
    const grid = document.getElementById("grid");
    const replay = document.getElementById("replay");

    function renderSvg(row, className) {{
      const paths = row.svgPaths || [];
      const strokes = paths.map((path, index) => {{
        const delay = 0.12 + index * 0.38;
        return `<path class="stroke" d="${{path}}" pathLength="1" style="animation-delay:${{delay}}s"></path>`;
      }}).join("");
      return `
        <svg class="${{className}}" viewBox="0 0 100 100" aria-label="${{row.character}} preview">
          <rect class="paper" x="4" y="4" width="92" height="92" rx="2"></rect>
          <path class="guide" d="M50 6 V94 M6 50 H94 M17 17 L83 83 M83 17 L17 83"></path>
          <text class="ghost" x="50" y="52">${{row.character}}</text>
          ${{strokes}}
        </svg>
      `;
    }}

    function render() {{
      grid.innerHTML = originals.map((row, index) => {{
        const clean = smoothed[index];
        return `
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
                <p class="label">보정</p>
                ${{renderSvg(clean, "smooth")}}
              </div>
            </div>
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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    rows = json.loads(args.input.read_text(encoding="utf-8"))
    originals = [row for row in rows if row.get("svgPaths")]
    smoothed = build_smoothed_rows(originals)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(build_html(originals, smoothed), encoding="utf-8")
    print(f"Wrote {args.output}")
    print(f"Rows: {len(originals)}")


if __name__ == "__main__":
    main()
