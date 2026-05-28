"""Generate a font-guided preview for manual stroke captures.

This preview uses the user's manual strokes as the ordered sketch, then fits the
smoothed paths to the target font glyph bounds. It does not infer perfect stroke
skeletons from the font outline, but it gives a better approximation of the
intended character proportions than raw mouse paths alone.
"""

from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_INPUT = Path(r"C:\Users\User\Downloads\manual_stroke_capture.json")
DEFAULT_OUTPUT = ROOT / "docs" / "prototypes" / "manual_capture_font_fit_preview.html"
DEFAULT_FONT = Path(r"C:\Windows\Fonts\NotoSerifKR-VF.ttf")
NUMBER_RE = re.compile(r"-?\d+(?:\.\d+)?")


def parse_path_points(path: str) -> list[tuple[float, float]]:
    numbers = [float(match.group(0)) for match in NUMBER_RE.finditer(path)]
    return list(zip(numbers[0::2], numbers[1::2]))


def fmt(value: float) -> str:
    return f"{value:.2f}".rstrip("0").rstrip(".")


def bounds(points: list[tuple[float, float]]) -> tuple[float, float, float, float]:
    return (
        min(point[0] for point in points),
        min(point[1] for point in points),
        max(point[0] for point in points),
        max(point[1] for point in points),
    )


def all_points(paths: list[str]) -> list[tuple[float, float]]:
    points: list[tuple[float, float]] = []
    for path in paths:
        points.extend(parse_path_points(path))
    return points


def distance(a: tuple[float, float], b: tuple[float, float]) -> float:
    return math.hypot(a[0] - b[0], a[1] - b[1])


def perpendicular_distance(
    point: tuple[float, float],
    start: tuple[float, float],
    end: tuple[float, float],
) -> float:
    if start == end:
        return distance(point, start)
    x, y = point
    x1, y1 = start
    x2, y2 = end
    numerator = abs((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1)
    denominator = math.hypot(y2 - y1, x2 - x1)
    return numerator / denominator


def rdp(points: list[tuple[float, float]], epsilon: float) -> list[tuple[float, float]]:
    if len(points) <= 2:
        return points
    index = 0
    max_distance = 0.0
    for i in range(1, len(points) - 1):
        d = perpendicular_distance(points[i], points[0], points[-1])
        if d > max_distance:
            index = i
            max_distance = d
    if max_distance > epsilon:
        return rdp(points[: index + 1], epsilon)[:-1] + rdp(points[index:], epsilon)
    return [points[0], points[-1]]


def smooth_points(points: list[tuple[float, float]]) -> list[tuple[float, float]]:
    if len(points) <= 2:
        return points
    output = [points[0]]
    for i in range(1, len(points) - 1):
        prev_point = points[i - 1]
        point = points[i]
        next_point = points[i + 1]
        output.append(
            (
                prev_point[0] * 0.18 + point[0] * 0.64 + next_point[0] * 0.18,
                prev_point[1] * 0.18 + point[1] * 0.64 + next_point[1] * 0.18,
            )
        )
    output.append(points[-1])
    return output


def straighten_axis(points: list[tuple[float, float]]) -> list[tuple[float, float]]:
    if len(points) < 2:
        return points
    x1, y1 = points[0]
    x2, y2 = points[-1]
    length = max(distance(points[0], points[-1]), 0.01)
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    width = max(xs) - min(xs)
    height = max(ys) - min(ys)

    if abs(y2 - y1) / length < 0.18 and height < 3.8:
        y = sum(ys) / len(ys)
        return [(min(xs), y), (max(xs), y)]
    if abs(x2 - x1) / length < 0.18 and width < 3.8:
        x = sum(xs) / len(xs)
        return [(x, min(ys)), (x, max(ys))]
    return points


def to_path(points: list[tuple[float, float]]) -> str:
    if not points:
        return ""
    if len(points) == 1:
        return f"M{fmt(points[0][0])} {fmt(points[0][1])}"
    if len(points) == 2:
        return f"M{fmt(points[0][0])} {fmt(points[0][1])} L{fmt(points[1][0])} {fmt(points[1][1])}"

    path = f"M{fmt(points[0][0])} {fmt(points[0][1])}"
    i = 1
    while i < len(points) - 1:
        control = points[i]
        end = ((points[i][0] + points[i + 1][0]) / 2, (points[i][1] + points[i + 1][1]) / 2)
        path += f" Q{fmt(control[0])} {fmt(control[1])} {fmt(end[0])} {fmt(end[1])}"
        i += 1
    path += f" T{fmt(points[-1][0])} {fmt(points[-1][1])}"
    return path


def simplify_path_to_points(path: str) -> list[tuple[float, float]]:
    points = parse_path_points(path)
    if len(points) <= 2:
        return points
    simplified = rdp(points, 1.5)
    if len(simplified) > 9:
        simplified = rdp(points, 2.3)
    return straighten_axis(smooth_points(simplified))


def transform_points(
    points: list[tuple[float, float]],
    source_bounds: tuple[float, float, float, float],
    target_bounds: tuple[float, float, float, float],
) -> list[tuple[float, float]]:
    sx1, sy1, sx2, sy2 = source_bounds
    tx1, ty1, tx2, ty2 = target_bounds
    source_width = max(sx2 - sx1, 0.01)
    source_height = max(sy2 - sy1, 0.01)
    target_width = max(tx2 - tx1, 0.01)
    target_height = max(ty2 - ty1, 0.01)
    scale_x = target_width / source_width
    scale_y = target_height / source_height
    return [
        (tx1 + (x - sx1) * scale_x, ty1 + (y - sy1) * scale_y)
        for x, y in points
    ]


def load_cmap(font: TTFont) -> dict[int, str]:
    cmap: dict[int, str] = {}
    for table in font["cmap"].tables:
        if table.isUnicode():
            cmap.update(table.cmap)
    return cmap


def extract_outline(font: TTFont, character: str) -> tuple[str, tuple[float, float, float, float]]:
    glyph_set = font.getGlyphSet()
    glyph_name = load_cmap(font).get(ord(character))
    if glyph_name is None:
        return "", (8, 8, 92, 92)

    bounds_pen = BoundsPen(glyph_set)
    glyph_set[glyph_name].draw(bounds_pen)
    if bounds_pen.bounds is None:
        return "", (8, 8, 92, 92)

    x_min, y_min, x_max, y_max = bounds_pen.bounds
    width = x_max - x_min
    height = y_max - y_min
    scale = 86 / max(width, height)
    x_offset = (100 - width * scale) / 2 - x_min * scale
    y_offset = (100 - height * scale) / 2 + y_max * scale

    svg_pen = SVGPathPen(glyph_set)
    transform_pen = TransformPen(svg_pen, (scale, 0, 0, -scale, x_offset, y_offset))
    glyph_set[glyph_name].draw(transform_pen)

    outline_bounds = (
        x_min * scale + x_offset,
        y_offset - y_max * scale,
        x_max * scale + x_offset,
        y_offset - y_min * scale,
    )
    return svg_pen.getCommands(), outline_bounds


def fit_row(row: dict[str, object], font: TTFont) -> dict[str, object]:
    paths = [str(path) for path in row.get("svgPaths") or []]
    sketch_points = all_points(paths)
    if not sketch_points:
        return dict(row)

    outline, outline_bounds = extract_outline(font, str(row["character"]))
    source_bounds = bounds(sketch_points)

    fitted_paths = []
    for path in paths:
        points = simplify_path_to_points(path)
        points = transform_points(points, source_bounds, outline_bounds)
        points = straighten_axis(points)
        fitted_paths.append(to_path(points))

    fitted = dict(row)
    fitted["id"] = f"{row.get('id', 'stroke')}-font-fit"
    fitted["source"] = "manual_font_fit"
    fitted["svgPaths"] = fitted_paths
    fitted["outline"] = outline
    return fitted


def build_html(original_rows: list[dict[str, object]], fitted_rows: list[dict[str, object]]) -> str:
    original_json = json.dumps(original_rows, ensure_ascii=False)
    fitted_json = json.dumps(fitted_rows, ensure_ascii=False)
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Manual Capture Font Fit Preview</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f5f7fb;
      --surface: #ffffff;
      --ink: #101828;
      --muted: #667085;
      --raw: #98a2b3;
      --fit: #c7432b;
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
      width: min(1280px, calc(100% - 28px));
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
      line-height: 1.45;
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
    .outline {{
      fill: rgba(16, 24, 40, 0.08);
      stroke: rgba(16, 24, 40, 0.26);
      stroke-width: 0.45;
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
    .fit .stroke {{ stroke: var(--fit); }}
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
        <h1>원본 한자 모양 기준 보정 비교</h1>
        <p class="summary">왼쪽은 네가 그은 원본이고, 오른쪽은 Noto Serif KR 글자 윤곽에 전체 비율을 맞춘 보정본입니다.</p>
      </div>
      <button id="replay">다시 보기</button>
    </header>
    <section id="grid" class="grid"></section>
  </main>
  <script>
    const originals = {original_json};
    const fitted = {fitted_json};
    const grid = document.getElementById("grid");
    const replay = document.getElementById("replay");

    function renderSvg(row, mode) {{
      const paths = row.svgPaths || [];
      const outline = row.outline ? `<path class="outline" d="${{row.outline}}"></path>` : `<text class="ghost" x="50" y="52">${{row.character}}</text>`;
      const strokes = paths.map((path, index) => {{
        const delay = 0.12 + index * 0.38;
        return `<path class="stroke" d="${{path}}" pathLength="1" style="animation-delay:${{delay}}s"></path>`;
      }}).join("");
      return `
        <svg class="${{mode}}" viewBox="0 0 100 100">
          <rect class="paper" x="4" y="4" width="92" height="92" rx="2"></rect>
          <path class="guide" d="M50 6 V94 M6 50 H94 M17 17 L83 83 M83 17 L17 83"></path>
          ${{outline}}
          ${{strokes}}
        </svg>
      `;
    }}

    function render() {{
      grid.innerHTML = originals.map((row, index) => {{
        const clean = fitted[index];
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
                <p class="label">글자 모양 기준 보정</p>
                ${{renderSvg(clean, "fit")}}
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
    parser.add_argument("--font", type=Path, default=DEFAULT_FONT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    rows = json.loads(args.input.read_text(encoding="utf-8"))
    originals = [row for row in rows if row.get("svgPaths")]
    font = TTFont(args.font)
    fitted = [fit_row(row, font) for row in originals]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(build_html(originals, fitted), encoding="utf-8")
    print(f"Wrote {args.output}")
    print(f"Rows: {len(originals)}")


if __name__ == "__main__":
    main()
