"""Generate a font-outline based stroke animation preview.

This is a prototype for the "font outline extraction + manual correction"
workflow. It extracts each character outline from a Korean-capable font and
renders manually authored stroke centerlines on top of that outline.

Run from repository root:
    python tools/stroke_seed/generate_font_outline_preview.py
"""

from __future__ import annotations

from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[2]
FONT_PATH = Path(r"C:\Windows\Fonts\NotoSerifKR-VF.ttf")
OUTPUT = ROOT / "docs" / "prototypes" / "font_outline_stroke_preview.html"


SAMPLES = [
    {
        "id": "HJ-0001",
        "character": "一",
        "sequence": "1",
        "strokes": ["M18 52 C36 49 64 49 83 52"],
    },
    {
        "id": "HJ-0002",
        "character": "百",
        "sequence": "132511",
        "strokes": [
            "M19 16 C39 14 63 14 82 16",
            "M39 18 C36 28 33 36 29 45",
            "M27 42 C41 40 60 40 73 42",
            "M29 42 L29 79",
            "M72 42 L72 79",
            "M30 60 C42 58 59 58 71 60",
        ],
    },
    {
        "id": "HJ-0006",
        "character": "日",
        "sequence": "2511",
        "strokes": [
            "M28 20 L28 80",
            "M28 20 C42 18 60 18 73 20 L73 80",
            "M30 49 C43 47 59 47 71 49",
            "M30 80 C43 78 59 78 73 80",
        ],
    },
    {
        "id": "HJ-0008",
        "character": "村",
        "sequence": "1234154",
        "strokes": [
            "M14 31 C24 30 35 30 44 31",
            "M30 14 L30 85",
            "M29 43 C22 56 16 66 10 74",
            "M32 43 C37 50 42 57 46 64",
            "M49 37 C62 35 77 35 89 37",
            "M73 16 L73 84",
            "M57 51 C62 55 66 60 69 65",
        ],
    },
    {
        "id": "HJ-0013",
        "character": "東",
        "sequence": "12511234",
        "strokes": [
            "M20 20 C39 18 62 18 80 20",
            "M50 12 L50 88",
            "M28 34 C42 32 61 32 74 34 L74 67 C60 65 42 65 28 67 Z",
            "M29 49 C42 47 60 47 73 49",
            "M28 67 C42 65 60 65 74 67",
            "M48 68 C39 78 29 84 18 88",
            "M52 68 C61 78 72 84 84 88",
            "M36 76 C44 73 55 73 64 76",
        ],
    },
]


def load_cmap(font: TTFont) -> dict[int, str]:
    cmap: dict[int, str] = {}
    for table in font["cmap"].tables:
        if table.isUnicode():
            cmap.update(table.cmap)
    return cmap


def extract_normalized_outline(font: TTFont, character: str) -> str:
    glyph_set = font.getGlyphSet()
    cmap = load_cmap(font)
    glyph_name = cmap.get(ord(character))
    if glyph_name is None:
        raise ValueError(f"Font has no glyph for {character}")

    bounds_pen = BoundsPen(glyph_set)
    glyph_set[glyph_name].draw(bounds_pen)
    if bounds_pen.bounds is None:
        raise ValueError(f"Glyph has no outline for {character}")
    x_min, y_min, x_max, y_max = bounds_pen.bounds
    width = x_max - x_min
    height = y_max - y_min
    scale = 86 / max(width, height)
    x_offset = (100 - width * scale) / 2 - x_min * scale
    y_offset = (100 - height * scale) / 2 + y_max * scale

    svg_pen = SVGPathPen(glyph_set)
    transform_pen = TransformPen(svg_pen, (scale, 0, 0, -scale, x_offset, y_offset))
    glyph_set[glyph_name].draw(transform_pen)
    return svg_pen.getCommands()


def sample_card(sample: dict[str, object], outline: str) -> str:
    strokes = sample["strokes"]
    assert isinstance(strokes, list)
    stroke_paths = "\n".join(
        f'<path class="stroke s{i}" d="{stroke}" pathLength="100" />'
        for i, stroke in enumerate(strokes, start=1)
    )
    labels = "\n".join(
        f'<text class="num" x="{_label_x(stroke)}" y="{_label_y(stroke)}">{i}</text>'
        for i, stroke in enumerate(strokes, start=1)
    )
    duration = 0.42 * len(strokes) + 0.7
    return f"""
      <article class="card" style="--duration:{duration:.2f}s">
        <div class="meta">
          <strong>{sample["character"]}</strong>
          <span>{sample["id"]} · CNS {sample["sequence"]}</span>
        </div>
        <svg viewBox="0 0 100 100" role="img" aria-label="{sample["character"]} stroke preview">
          <rect class="paper" x="4" y="4" width="92" height="92" rx="2" />
          <path class="guide" d="M50 6 V94 M6 50 H94 M17 17 L83 83 M83 17 L17 83" />
          <path class="outline" d="{outline}" />
          {stroke_paths}
          {labels}
        </svg>
      </article>
    """


def _label_x(path: str) -> str:
    parts = path.replace("M", "").replace("C", " ").replace("L", " ").split()
    return parts[0] if parts else "50"


def _label_y(path: str) -> str:
    parts = path.replace("M", "").replace("C", " ").replace("L", " ").split()
    return parts[1] if len(parts) > 1 else "50"


def build_html(cards: str) -> str:
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Font Outline Stroke Preview</title>
  <style>
    :root {{
      color-scheme: light;
      --ink: #111827;
      --muted: #667085;
      --line: #d9dee7;
      --accent: #d14f2a;
      --paper: #fffdf8;
      --bg: #f4f7fb;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      font-family: "Noto Sans KR", "Malgun Gothic", sans-serif;
      background: var(--bg);
      color: var(--ink);
    }}
    main {{
      width: min(1180px, calc(100% - 32px));
      margin: 28px auto;
    }}
    h1 {{
      margin: 0 0 8px;
      font-size: 24px;
      letter-spacing: 0;
    }}
    p {{
      margin: 0 0 22px;
      color: var(--muted);
      line-height: 1.55;
    }}
    .grid {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
      gap: 16px;
    }}
    .card {{
      background: white;
      border: 1px solid #e4e7ec;
      border-radius: 8px;
      padding: 12px;
      box-shadow: 0 8px 20px rgba(16, 24, 40, 0.06);
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
      font-size: 28px;
      font-weight: 700;
      line-height: 1;
    }}
    .meta span {{
      color: var(--muted);
      font-size: 12px;
      text-align: right;
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
      stroke-width: 0.7;
    }}
    .guide {{
      fill: none;
      stroke: #d8c7a2;
      stroke-width: 0.35;
      stroke-dasharray: 1.4 1.4;
    }}
    .outline {{
      fill: rgba(17, 24, 39, 0.13);
      stroke: rgba(17, 24, 39, 0.38);
      stroke-width: 0.45;
    }}
    .stroke {{
      fill: none;
      stroke: var(--accent);
      stroke-width: 4.2;
      stroke-linecap: round;
      stroke-linejoin: round;
      stroke-dasharray: 100;
      stroke-dashoffset: 100;
      animation: draw 0.38s ease-out forwards;
    }}
    .num {{
      fill: white;
      stroke: var(--accent);
      stroke-width: 0.6;
      paint-order: stroke fill;
      font-size: 5px;
      font-weight: 800;
      dominant-baseline: central;
      text-anchor: middle;
      opacity: 0;
      animation: show 0.18s ease-out forwards;
    }}
    .s1 {{ animation-delay: 0.12s; }}
    .s2 {{ animation-delay: 0.52s; }}
    .s3 {{ animation-delay: 0.92s; }}
    .s4 {{ animation-delay: 1.32s; }}
    .s5 {{ animation-delay: 1.72s; }}
    .s6 {{ animation-delay: 2.12s; }}
    .s7 {{ animation-delay: 2.52s; }}
    .s8 {{ animation-delay: 2.92s; }}
    .num:nth-of-type(1) {{ animation-delay: 0.18s; }}
    .num:nth-of-type(2) {{ animation-delay: 0.58s; }}
    .num:nth-of-type(3) {{ animation-delay: 0.98s; }}
    .num:nth-of-type(4) {{ animation-delay: 1.38s; }}
    .num:nth-of-type(5) {{ animation-delay: 1.78s; }}
    .num:nth-of-type(6) {{ animation-delay: 2.18s; }}
    .num:nth-of-type(7) {{ animation-delay: 2.58s; }}
    .num:nth-of-type(8) {{ animation-delay: 2.98s; }}
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
    <h1>폰트 윤곽 기반 획 애니메이션 샘플</h1>
    <p>Noto Serif KR 글자 윤곽을 실제 SVG path로 추출하고, CNS 획순 코드를 기준으로 획별 중심선을 얹은 3번 방식의 작업 샘플입니다.</p>
    <section class="grid">
      {cards}
    </section>
  </main>
</body>
</html>
"""


def main() -> None:
    font = TTFont(FONT_PATH)
    cards = []
    for sample in SAMPLES:
        outline = extract_normalized_outline(font, str(sample["character"]))
        cards.append(sample_card(sample, outline))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(build_html("\n".join(cards)), encoding="utf-8")
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
