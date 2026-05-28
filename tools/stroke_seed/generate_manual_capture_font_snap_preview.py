"""Generate a font-outline anchor snapping preview for manual captures."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

from fontTools.pens.basePen import BasePen
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

from generate_manual_capture_font_fit_preview import (
    DEFAULT_FONT,
    DEFAULT_INPUT,
    ROOT,
    all_points,
    bounds,
    distance,
    extract_outline,
    fmt,
    load_cmap,
    simplify_path_to_points,
    straighten_axis,
    to_path,
    transform_points,
)

DEFAULT_OUTPUT = ROOT / "docs" / "prototypes" / "manual_capture_font_snap_preview.html"


class OutlineSamplingPen(BasePen):
    def __init__(self, glyph_set):
        super().__init__(glyph_set)
        self.points: list[tuple[float, float]] = []
        self.current: tuple[float, float] | None = None

    def _moveTo(self, p0):
        self.current = (float(p0[0]), float(p0[1]))
        self.points.append(self.current)

    def _lineTo(self, p1):
        if self.current is None:
            self._moveTo(p1)
            return
        start = self.current
        end = (float(p1[0]), float(p1[1]))
        steps = max(2, int(distance(start, end) / 2.5))
        for i in range(1, steps + 1):
            t = i / steps
            self.points.append(
                (start[0] + (end[0] - start[0]) * t, start[1] + (end[1] - start[1]) * t)
            )
        self.current = end

    def _qCurveToOne(self, p1, p2):
        if self.current is None:
            self._moveTo(p2)
            return
        start = self.current
        control = (float(p1[0]), float(p1[1]))
        end = (float(p2[0]), float(p2[1]))
        steps = max(8, int((distance(start, control) + distance(control, end)) / 3.0))
        for i in range(1, steps + 1):
            t = i / steps
            x = (1 - t) ** 2 * start[0] + 2 * (1 - t) * t * control[0] + t**2 * end[0]
            y = (1 - t) ** 2 * start[1] + 2 * (1 - t) * t * control[1] + t**2 * end[1]
            self.points.append((x, y))
        self.current = end

    def _curveToOne(self, p1, p2, p3):
        if self.current is None:
            self._moveTo(p3)
            return
        start = self.current
        c1 = (float(p1[0]), float(p1[1]))
        c2 = (float(p2[0]), float(p2[1]))
        end = (float(p3[0]), float(p3[1]))
        steps = max(
            10,
            int((distance(start, c1) + distance(c1, c2) + distance(c2, end)) / 3.0),
        )
        for i in range(1, steps + 1):
            t = i / steps
            x = (
                (1 - t) ** 3 * start[0]
                + 3 * (1 - t) ** 2 * t * c1[0]
                + 3 * (1 - t) * t**2 * c2[0]
                + t**3 * end[0]
            )
            y = (
                (1 - t) ** 3 * start[1]
                + 3 * (1 - t) ** 2 * t * c1[1]
                + 3 * (1 - t) * t**2 * c2[1]
                + t**3 * end[1]
            )
            self.points.append((x, y))
        self.current = end

    def _closePath(self):
        self.current = None


def extract_outline_samples(
    font: TTFont,
    character: str,
) -> tuple[str, tuple[float, float, float, float], list[tuple[float, float]]]:
    glyph_set = font.getGlyphSet()
    glyph_name = load_cmap(font).get(ord(character))
    if glyph_name is None:
        return "", (8, 8, 92, 92), []

    bounds_pen = BoundsPen(glyph_set)
    glyph_set[glyph_name].draw(bounds_pen)
    if bounds_pen.bounds is None:
        return "", (8, 8, 92, 92), []

    x_min, y_min, x_max, y_max = bounds_pen.bounds
    width = x_max - x_min
    height = y_max - y_min
    scale = 86 / max(width, height)
    x_offset = (100 - width * scale) / 2 - x_min * scale
    y_offset = (100 - height * scale) / 2 + y_max * scale
    transform = (scale, 0, 0, -scale, x_offset, y_offset)

    svg_pen = SVGPathPen(glyph_set)
    glyph_set[glyph_name].draw(TransformPen(svg_pen, transform))

    sampling_pen = OutlineSamplingPen(glyph_set)
    glyph_set[glyph_name].draw(TransformPen(sampling_pen, transform))

    outline_bounds = (
        x_min * scale + x_offset,
        y_offset - y_max * scale,
        x_max * scale + x_offset,
        y_offset - y_min * scale,
    )
    return svg_pen.getCommands(), outline_bounds, sampling_pen.points


def nearest(
    point: tuple[float, float],
    candidates: list[tuple[float, float]],
    max_distance: float,
) -> tuple[float, float] | None:
    if not candidates:
        return None
    closest = min(candidates, key=lambda candidate: distance(point, candidate))
    if distance(point, closest) <= max_distance:
        return closest
    return None


def weighted(
    point: tuple[float, float],
    target: tuple[float, float],
    amount: float,
) -> tuple[float, float]:
    return (
        point[0] * (1 - amount) + target[0] * amount,
        point[1] * (1 - amount) + target[1] * amount,
    )


def snap_axis_points(
    points: list[tuple[float, float]],
    samples: list[tuple[float, float]],
) -> list[tuple[float, float]]:
    if len(points) < 2 or not samples:
        return points

    start = points[0]
    end = points[-1]
    length = max(distance(start, end), 0.01)
    dx = end[0] - start[0]
    dy = end[1] - start[1]
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    width = max(xs) - min(xs)
    height = max(ys) - min(ys)

    snapped = list(points)
    if abs(dy) / length < 0.26 and width > height:
        y = sum(ys) / len(ys)
        band = [sample for sample in samples if abs(sample[1] - y) <= 5.5]
        left = nearest((min(xs), y), band, 10.0)
        right = nearest((max(xs), y), band, 10.0)
        if left is not None:
            snapped[0] = weighted(snapped[0], (left[0], y), 0.72)
        if right is not None:
            snapped[-1] = weighted(snapped[-1], (right[0], y), 0.72)
        if height < 5.2:
            avg_y = sum(point[1] for point in snapped) / len(snapped)
            snapped = [(point[0], avg_y) for point in snapped]
        return snapped

    if abs(dx) / length < 0.26 and height > width:
        x = sum(xs) / len(xs)
        band = [sample for sample in samples if abs(sample[0] - x) <= 5.5]
        top = nearest((x, min(ys)), band, 10.0)
        bottom = nearest((x, max(ys)), band, 10.0)
        if top is not None:
            snapped[0] = weighted(snapped[0], (x, top[1]), 0.72)
        if bottom is not None:
            snapped[-1] = weighted(snapped[-1], (x, bottom[1]), 0.72)
        if width < 5.2:
            avg_x = sum(point[0] for point in snapped) / len(snapped)
            snapped = [(avg_x, point[1]) for point in snapped]
        return snapped

    for index in [0, len(snapped) - 1]:
        target = nearest(snapped[index], samples, 7.0)
        if target is not None:
            snapped[index] = weighted(snapped[index], target, 0.45)
    return snapped


def snap_row(row: dict[str, object], font: TTFont) -> dict[str, object]:
    paths = [str(path) for path in row.get("svgPaths") or []]
    sketch_points = all_points(paths)
    if not sketch_points:
        return dict(row)

    outline, outline_bounds, samples = extract_outline_samples(font, str(row["character"]))
    source_bounds = bounds(sketch_points)
    snapped_paths: list[str] = []
    for path in paths:
        points = simplify_path_to_points(path)
        points = transform_points(points, source_bounds, outline_bounds)
        points = straighten_axis(points)
        points = snap_axis_points(points, samples)
        snapped_paths.append(to_path(points))

    snapped = dict(row)
    snapped["id"] = f"{row.get('id', 'stroke')}-font-snap"
    snapped["source"] = "manual_font_snap"
    snapped["svgPaths"] = snapped_paths
    snapped["outline"] = outline
    return snapped


def build_html(originals: list[dict[str, object]], fitted: list[dict[str, object]], snapped: list[dict[str, object]]) -> str:
    original_json = json.dumps(originals, ensure_ascii=False)
    fitted_json = json.dumps(fitted, ensure_ascii=False)
    snapped_json = json.dumps(snapped, ensure_ascii=False)
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Manual Capture Font Snap Preview</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f5f7fb;
      --surface: #ffffff;
      --ink: #101828;
      --muted: #667085;
      --raw: #98a2b3;
      --fit: #175cd3;
      --snap: #c7432b;
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
      width: min(1500px, calc(100% - 28px));
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
      grid-template-columns: 1fr;
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
    .triple {{
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
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
    .snap .stroke {{ stroke: var(--snap); }}
    .playing .stroke {{ animation-play-state: running; }}
    @keyframes draw {{
      to {{ stroke-dashoffset: 0; }}
    }}
    @media (max-width: 900px) {{
      .triple {{ grid-template-columns: 1fr; }}
    }}
  </style>
</head>
<body>
  <main>
    <header>
      <div>
        <h1>원본 한자 윤곽 스냅 보정 비교</h1>
        <p class="summary">원본, 전체 박스 맞춤, 윤곽 경계 후보에 시작점/끝점을 스냅한 보정본을 비교합니다.</p>
      </div>
      <button id="replay">다시 보기</button>
    </header>
    <section id="grid" class="grid"></section>
  </main>
  <script>
    const originals = {original_json};
    const fitted = {fitted_json};
    const snapped = {snapped_json};
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
      grid.innerHTML = originals.map((row, index) => `
        <article class="card">
          <div class="meta">
            <strong>${{row.character}}</strong>
            <span>${{row.hanjaId}} · ${{row.svgPaths.length}}획</span>
          </div>
          <div class="triple">
            <div>
              <p class="label">원본</p>
              ${{renderSvg(row, "raw")}}
            </div>
            <div>
              <p class="label">전체 비율 맞춤</p>
              ${{renderSvg(fitted[index], "fit")}}
            </div>
            <div>
              <p class="label">윤곽 스냅</p>
              ${{renderSvg(snapped[index], "snap")}}
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
    parser.add_argument("--font", type=Path, default=DEFAULT_FONT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    rows = json.loads(args.input.read_text(encoding="utf-8"))
    originals = [row for row in rows if row.get("svgPaths")]
    font = TTFont(args.font)

    # Import lazily to avoid duplicating the box-fit implementation in this file.
    from generate_manual_capture_font_fit_preview import fit_row

    fitted = [fit_row(row, font) for row in originals]
    snapped = [snap_row(row, font) for row in originals]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(build_html(originals, fitted, snapped), encoding="utf-8")
    print(f"Wrote {args.output}")
    print(f"Rows: {len(originals)}")


if __name__ == "__main__":
    main()
