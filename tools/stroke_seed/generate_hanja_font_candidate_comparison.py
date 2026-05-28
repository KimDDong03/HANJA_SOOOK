"""Generate a textbook-vs-font Hanja glyph comparison page.

Run from repository root:
    python tools/stroke_seed/generate_hanja_font_candidate_comparison.py
"""

from __future__ import annotations

import os
from html import escape
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "docs" / "prototypes" / "hanja_font_candidate_comparison.html"

SAMPLES = [
    {
        "id": "HJ-0011",
        "character": "萬",
        "code": "U+842C",
        "reading": "일만 만",
        "reference": ROOT
        / "output"
        / "manual_stroke"
        / "textbook_reference_cards"
        / "HJ-0011_U842C.png",
        "focus": "위쪽 艹 모양이 붙는지, 가운데 田/禸 계열 연결이 교과서 카드와 맞는지 확인",
    },
    {
        "id": "HJ-0499",
        "character": "瞬",
        "code": "U+77AC",
        "reading": "눈 깜짝일 순",
        "reference": ROOT
        / "output"
        / "manual_stroke"
        / "textbook_reference_cards"
        / "HJ-0499_U77AC.png",
        "focus": "오른쪽 아래 舛 계열의 16번째 획 연결감과 분리 위치 확인",
    },
]

WEB_FONTS = [
    {
        "family": "Chosun Sinmyeongjo Candidate",
        "label": "조선신명조",
        "source": ROOT
        / "assets"
        / "fonts"
        / "chosun_sinmyeongjo"
        / "ChosunSm.TTF",
        "format": "truetype",
        "type": "selected",
    },
    {
        "family": "Noto Serif TC Candidate",
        "label": "Noto Serif TC",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "NotoSerifTC-Regular.subset.otf",
        "format": "opentype",
    },
    {
        "family": "TW Kai CNS11643 Candidate",
        "label": "TW-Kai CNS11643",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "TW-Kai-98_1.subset.ttf",
        "format": "truetype",
    },
    {
        "family": "TW Sung CNS11643 Candidate",
        "label": "TW-Sung CNS11643",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "TW-Sung-98_1.subset.ttf",
        "format": "truetype",
    },
    {
        "family": "MOE Standard Kai Candidate",
        "label": "교육부 표준楷書",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "edukai-3.subset.ttf",
        "format": "truetype",
    },
    {
        "family": "MOE Standard Song Candidate",
        "label": "교육부 표준宋體",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "eduSong_Unicode.subset.ttf",
        "format": "truetype",
    },
    {
        "family": "Iansui Candidate",
        "label": "Iansui",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "Iansui-Regular.subset.ttf",
        "format": "truetype",
    },
    {
        "family": "LXGW WenKai TC Candidate",
        "label": "LXGW WenKai TC",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "LXGWWenKaiTC-Regular.subset.ttf",
        "format": "truetype",
    },
    {
        "family": "GenYoMin2 TW Candidate",
        "label": "GenYoMin2 TW",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "GenYoMin2TW-R.subset.otf",
        "format": "opentype",
    },
    {
        "family": "GenWanMin2 TW Candidate",
        "label": "GenWanMin2 TW",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "GenWanMin2TW-R.subset.otf",
        "format": "opentype",
    },
    {
        "family": "GenRyuMin2 TW Candidate",
        "label": "GenRyuMin2 TW",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "GenRyuMin2TW-R.subset.otf",
        "format": "opentype",
    },
    {
        "family": "I Ming Candidate",
        "label": "I.Ming",
        "source": ROOT
        / "output"
        / "manual_stroke"
        / "fonts"
        / "preview_subset"
        / "I.Ming-8.10.subset.ttf",
        "format": "truetype",
    },
]

SYSTEM_FONTS = []


def rel(path: Path) -> str:
    return Path(os.path.relpath(path, OUTPUT.parent)).as_posix()


def build_font_faces() -> str:
    faces = []
    for font in WEB_FONTS:
        source = Path(font["source"])
        if not source.exists():
            continue
        faces.append(
            "@font-face { "
            f"font-family: '{font['family']}'; "
            f"src: url('{rel(source)}') format('{font['format']}'); "
            "font-weight: 400; "
            "font-style: normal; "
            "font-display: block; "
            "}"
        )
    return "\n    ".join(faces)


def candidate_cards(sample: dict[str, object]) -> str:
    cards = [reference_card(sample)]
    for font in WEB_FONTS:
        if not Path(font["source"]).exists():
            continue
        cards.append(
            glyph_card(
                sample["character"],
                font["label"],
                f"'{font['family']}', serif",
                str(font.get("type", "new")),
            )
        )
    for font in SYSTEM_FONTS:
        cards.append(
            glyph_card(
                sample["character"],
                font["label"],
                f"'{font['family']}', serif",
                "system",
            )
        )
    return "\n".join(cards)


def reference_card(sample: dict[str, object]) -> str:
    image = Path(sample["reference"])
    if not image.exists():
        return ""
    return f"""
        <article class="card reference">
          <div class="card-head">
            <strong>교과서 카드</strong>
            <span>reference</span>
          </div>
          <div class="tile image-tile">
            <img src="{rel(image)}" alt="{escape(str(sample['character']))} textbook stroke card" />
          </div>
        </article>
    """


def glyph_card(character: object, label: str, family: str, source_type: str) -> str:
    return f"""
        <article class="card">
          <div class="card-head">
            <strong>{escape(label)}</strong>
            <span>{source_type}</span>
          </div>
          <div class="tile">
            <span class="glyph" style="font-family:{family};">{escape(str(character))}</span>
          </div>
        </article>
    """


def sample_section(sample: dict[str, object]) -> str:
    return f"""
      <section class="sample">
        <header class="sample-head">
          <div>
            <h2>{escape(str(sample["character"]))}</h2>
            <p>{escape(str(sample["id"]))} · {escape(str(sample["code"]))} · {escape(str(sample["reading"]))}</p>
          </div>
          <p class="focus">{escape(str(sample["focus"]))}</p>
        </header>
        <div class="grid">
          {candidate_cards(sample)}
        </div>
      </section>
    """


def build_html() -> str:
    return f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Hanja Font Candidate Comparison</title>
  <style>
    {build_font_faces()}
    :root {{
      color-scheme: light;
      --bg: #f3f6fb;
      --surface: #ffffff;
      --ink: #101828;
      --muted: #667085;
      --line: #d0d5dd;
      --tile: #fbfaf6;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      background: var(--bg);
      color: var(--ink);
      font-family: "Noto Sans KR", "Malgun Gothic", system-ui, sans-serif;
    }}
    main {{
      width: min(1540px, calc(100% - 32px));
      margin: 24px auto 40px;
    }}
    .page-head {{
      display: flex;
      align-items: flex-end;
      justify-content: space-between;
      gap: 16px;
      margin-bottom: 18px;
    }}
    h1 {{
      margin: 0;
      font-size: 24px;
      letter-spacing: 0;
    }}
    .page-head p,
    .sample-head p {{
      margin: 5px 0 0;
      color: var(--muted);
      font-size: 13px;
      line-height: 1.45;
    }}
    .sources {{
      color: var(--muted);
      font-size: 12px;
      text-align: right;
      line-height: 1.45;
    }}
    .sample {{
      background: var(--surface);
      border: 1px solid #e4e7ec;
      border-radius: 8px;
      padding: 16px;
      margin-bottom: 18px;
      box-shadow: 0 8px 20px rgba(16, 24, 40, 0.05);
    }}
    .sample-head {{
      display: flex;
      justify-content: space-between;
      gap: 16px;
      align-items: flex-start;
      margin-bottom: 14px;
    }}
    h2 {{
      margin: 0;
      font-family: "Chosun Sinmyeongjo Candidate", Batang, serif;
      font-size: 34px;
      line-height: 1;
      letter-spacing: 0;
    }}
    .focus {{
      max-width: 540px;
      text-align: right;
    }}
    .grid {{
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(186px, 1fr));
      gap: 12px;
    }}
    .card {{
      border: 1px solid #e4e7ec;
      border-radius: 8px;
      padding: 10px;
      background: #fff;
    }}
    .reference {{
      border-color: #d6b66c;
      background: #fffdf6;
    }}
    .card-head {{
      display: flex;
      justify-content: space-between;
      align-items: baseline;
      gap: 8px;
      min-height: 32px;
      margin-bottom: 8px;
    }}
    .card-head strong {{
      font-size: 13px;
      line-height: 1.25;
    }}
    .card-head span {{
      color: var(--muted);
      font-size: 11px;
      white-space: nowrap;
    }}
    .tile {{
      height: 178px;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      background: var(--tile);
      border: 1px solid var(--line);
      border-radius: 6px;
    }}
    .glyph {{
      display: block;
      font-size: 132px;
      line-height: 1;
      color: #111827;
      font-feature-settings: "locl" 1;
      -webkit-font-smoothing: antialiased;
      text-rendering: geometricPrecision;
    }}
    .image-tile {{
      background: #ece7d5;
    }}
    img {{
      display: block;
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }}
    @media (max-width: 820px) {{
      .page-head,
      .sample-head {{
        display: block;
      }}
      .sources,
      .focus {{
        text-align: left;
      }}
      .grid {{
        grid-template-columns: repeat(auto-fill, minmax(148px, 1fr));
      }}
      .tile {{
        height: 142px;
      }}
      .glyph {{
        font-size: 104px;
      }}
    }}
  </style>
</head>
<body>
  <main>
    <header class="page-head">
      <div>
        <h1>한자 자형 폰트 후보 비교</h1>
        <p>교과서 필순 카드 이미지를 기준으로 같은 유니코드 글자를 후보 폰트별로 렌더링했습니다.</p>
      </div>
      <div class="sources">Selected: Chosun Sinmyeongjo · comparison candidates kept for reference</div>
    </header>
    {"".join(sample_section(sample) for sample in SAMPLES)}
  </main>
</body>
</html>
"""


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    missing = [
        str(path)
        for path in [sample["reference"] for sample in SAMPLES]
        + [font["source"] for font in WEB_FONTS]
        if not Path(path).exists()
    ]
    if missing:
        print("Missing candidate assets:")
        for path in missing:
            print(f"- {path}")
    OUTPUT.write_text(build_html(), encoding="utf-8")
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
