"""Generate a manual stroke capture page with textbook card references."""

from __future__ import annotations

import csv
import json
import os
from pathlib import Path

import pypdfium2 as pdfium


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_REPORT_CSV = ROOT / "output" / "manual_stroke" / "stroke_seed_build_report.csv"
DEFAULT_TEXTBOOK_COUNTS = ROOT / "output" / "manual_stroke" / "textbook_stroke_counts.csv"
DEFAULT_OUTPUT = ROOT / "docs" / "prototypes" / "manual_stroke_capture_textbook_refs.html"
DEFAULT_CARD_DIR = ROOT / "output" / "manual_stroke" / "textbook_reference_cards"
DEFAULT_QUEUE_CSV = ROOT / "output" / "manual_stroke" / "manual_capture_textbook_ref_queue.csv"

TEXTBOOK_PDFS = {
    "초3": Path(r"C:\Users\User\Documents\카카오톡 받은 파일\교과서-3학년_full.pdf"),
    "초4": Path(r"C:\Users\User\Documents\카카오톡 받은 파일\교과서-4학년_full.pdf"),
    "초5": Path(r"C:\Users\User\Documents\카카오톡 받은 파일\교과서-5학년_ful.pdf"),
    "초6": Path(r"C:\Users\User\Documents\카카오톡 받은 파일\교과서-6학년_full.pdf"),
}

RENDER_SCALE = 1.6


def card_crop_box(lesson_position: int) -> tuple[int, int, int, int]:
    if lesson_position <= 4:
        tops = [386, 532, 847, 992]
        return (88, tops[lesson_position - 1], 242, tops[lesson_position - 1] + 148)

    tops = [270, 415]
    return (112, tops[lesson_position - 5], 266, tops[lesson_position - 5] + 148)


def read_rows(report_csv: Path, textbook_counts: Path) -> list[dict[str, str]]:
    textbook_by_id: dict[str, dict[str, str]] = {}
    with textbook_counts.open(encoding="utf-8-sig", newline="") as file:
        for row in csv.DictReader(file):
            textbook_by_id[row["id"]] = row

    rows: list[dict[str, str]] = []
    with report_csv.open(encoding="utf-8-sig", newline="") as file:
        for row in csv.DictReader(file):
            if row["source"] not in {"hanzi_writer_data", "missing"}:
                continue
            textbook = textbook_by_id.get(row["hanja_id"])
            if not textbook:
                continue
            rows.append({**row, **textbook})
    return rows


def render_page(pdf_path: Path, page_number: int):
    document = pdfium.PdfDocument(str(pdf_path))
    try:
        page = document[page_number - 1]
        return page.render(scale=RENDER_SCALE).to_pil().convert("RGB")
    finally:
        document.close()


def write_reference_cards(rows: list[dict[str, str]], card_dir: Path, html_path: Path) -> list[dict[str, object]]:
    card_dir.mkdir(parents=True, exist_ok=True)
    page_cache: dict[tuple[str, int], object] = {}
    items: list[dict[str, object]] = []

    for row in rows:
        grade = row["grade"]
        page_number = int(row["textbook_page"])
        lesson_position = int(row["lesson_position"])
        key = (grade, page_number)
        if key not in page_cache:
            page_cache[key] = render_page(TEXTBOOK_PDFS[grade], page_number)

        image = page_cache[key]
        crop = image.crop(card_crop_box(lesson_position))
        character = row["textbook_character"]
        filename = f"{row['hanja_id']}_U{ord(character):04X}.png"
        output_path = card_dir / filename
        crop.save(output_path)

        items.append(
            {
                "id": row["hanja_id"],
                "character": character,
                "sound": row["sound"],
                "meaning": row["meaning"],
                "grade": grade,
                "unit": row["unit"],
                "lesson": row["lesson"],
                "unitName": row["unit_name"],
                "lessonPosition": lesson_position,
                "textbookPage": page_number,
                "expectedStrokeCount": int(row["expected_stroke_count"]),
                "previousSource": row["source"],
                "referenceImage": relative_path(output_path, html_path.parent),
                "svgPaths": [],
            }
        )

    return items


def relative_path(target: Path, start: Path) -> str:
    return Path(os.path.relpath(target, start)).as_posix()


def write_queue_csv(items: list[dict[str, object]], output_csv: Path) -> None:
    output_csv.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "hanja_id",
        "character",
        "sound",
        "meaning",
        "grade",
        "unit",
        "lesson",
        "textbook_page",
        "lesson_position",
        "expected_stroke_count",
        "previous_source",
        "reference_image",
    ]
    with output_csv.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        for item in items:
            writer.writerow(
                {
                    "hanja_id": item["id"],
                    "character": item["character"],
                    "sound": item["sound"],
                    "meaning": item["meaning"],
                    "grade": item["grade"],
                    "unit": item["unit"],
                    "lesson": item["lesson"],
                    "textbook_page": item["textbookPage"],
                    "lesson_position": item["lessonPosition"],
                    "expected_stroke_count": item["expectedStrokeCount"],
                    "previous_source": item["previousSource"],
                    "reference_image": item["referenceImage"],
                }
            )


def render_html(items: list[dict[str, object]]) -> str:
    items_json = json.dumps(items, ensure_ascii=False)
    return HTML_TEMPLATE.replace("__ITEMS_JSON__", items_json)


HTML_TEMPLATE = """<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Manual Stroke Capture - Textbook References</title>
  <style>
    @font-face {
      font-family: "Chosun Sinmyeongjo";
      src: url("../../assets/fonts/chosun_sinmyeongjo/ChosunSm.TTF") format("truetype");
      font-weight: 400;
      font-style: normal;
      font-display: block;
    }
    :root {
      color-scheme: light;
      --bg: #f4f6fa;
      --surface: #ffffff;
      --line: #d7deea;
      --ink: #111827;
      --muted: #667085;
      --accent: #c7432b;
      --ok: #087443;
      --warn: #b54708;
      --paper: #fffdf8;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: "Noto Sans KR", "Malgun Gothic", system-ui, sans-serif;
      background: var(--bg);
      color: var(--ink);
    }
    main {
      width: min(1420px, calc(100% - 28px));
      margin: 16px auto;
      display: grid;
      grid-template-columns: minmax(300px, 380px) minmax(0, 1fr);
      gap: 14px;
    }
    aside, section {
      background: var(--surface);
      border: 1px solid #e4e7ec;
      border-radius: 8px;
    }
    aside {
      padding: 14px;
      min-height: calc(100vh - 32px);
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    h1 {
      margin: 0;
      font-size: 20px;
      letter-spacing: 0;
    }
    .stat {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 8px;
    }
    .stat div {
      border: 1px solid var(--line);
      border-radius: 6px;
      padding: 8px;
      background: #fbfcff;
    }
    .stat strong {
      display: block;
      font-size: 18px;
      line-height: 1.1;
    }
    .stat span, .meta, .count {
      color: var(--muted);
      font-size: 12px;
    }
    .row { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
    button, label.file {
      border: 1px solid var(--line);
      background: white;
      color: var(--ink);
      height: 38px;
      border-radius: 6px;
      padding: 0 12px;
      font: inherit;
      font-weight: 800;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
    }
    button.primary { background: var(--ink); color: white; border-color: var(--ink); }
    button.danger { color: #b42318; }
    button:disabled { opacity: 0.45; cursor: default; }
    input[type="file"] { display: none; }
    .check {
      display: flex;
      align-items: center;
      gap: 8px;
      color: var(--muted);
      font-size: 13px;
      font-weight: 800;
      cursor: pointer;
      user-select: none;
    }
    .check input { width: 16px; height: 16px; accent-color: var(--ink); }
    .list {
      border: 1px solid var(--line);
      border-radius: 6px;
      overflow: auto;
      max-height: calc(100vh - 310px);
      min-height: 220px;
    }
    .item {
      display: grid;
      grid-template-columns: 42px 1fr auto;
      gap: 8px;
      align-items: center;
      width: 100%;
      border: 0;
      border-bottom: 1px solid #eef1f6;
      border-radius: 0;
      min-height: 48px;
      padding: 6px 8px;
      font-weight: 500;
      text-align: left;
    }
    .item.active { background: #f2f4f7; }
    .char, .current strong {
      font-family: "Chosun Sinmyeongjo", Batang, serif;
      line-height: 1;
    }
    .char {
      font-size: 25px;
      text-align: center;
    }
    .item .meta {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .done { color: var(--ok); font-size: 12px; font-weight: 900; }
    .todo { color: var(--warn); font-size: 12px; font-weight: 900; }
    .workspace {
      padding: 14px;
      min-height: calc(100vh - 32px);
      display: grid;
      grid-template-rows: auto minmax(0, 1fr) auto;
      gap: 12px;
    }
    .topbar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 12px;
    }
    .current {
      display: flex;
      align-items: baseline;
      gap: 12px;
      min-width: 0;
    }
    .current strong { font-size: 42px; }
    .workgrid {
      display: grid;
      grid-template-columns: 260px minmax(0, 1fr);
      gap: 16px;
      min-height: 0;
      align-items: start;
    }
    .reference {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .reference img {
      width: 100%;
      border-radius: 8px;
      border: 1px solid #cfd8e3;
      background: white;
    }
    .refbox {
      border: 1px solid var(--line);
      border-radius: 6px;
      padding: 10px;
      background: #fbfcff;
    }
    .refbox dl {
      display: grid;
      grid-template-columns: 70px 1fr;
      gap: 6px 8px;
      margin: 0;
      font-size: 13px;
    }
    .refbox dt { color: var(--muted); font-weight: 800; }
    .refbox dd { margin: 0; font-weight: 800; }
    .canvasWrap {
      display: grid;
      place-items: center;
      min-height: 0;
    }
    svg {
      display: block;
      width: min(100%, 680px);
      aspect-ratio: 1;
      touch-action: none;
      user-select: none;
    }
    .paper { fill: var(--paper); stroke: #d8c7a2; stroke-width: 0.8; }
    .guide {
      fill: none;
      stroke: #d8c7a2;
      stroke-width: 0.38;
      stroke-dasharray: 1.4 1.6;
    }
    .ghost {
      fill: rgba(16, 24, 40, 0.07);
      font-family: "Chosun Sinmyeongjo", Batang, serif;
      font-size: 78px;
      font-weight: 700;
      text-anchor: middle;
      dominant-baseline: central;
      pointer-events: none;
    }
    .stroke {
      fill: none;
      stroke: var(--accent);
      stroke-width: 4.8;
      stroke-linecap: round;
      stroke-linejoin: round;
    }
    .previewStroke {
      fill: none;
      stroke: #344054;
      stroke-width: 4.2;
      stroke-linecap: round;
      stroke-linejoin: round;
      opacity: 0.75;
    }
    .num {
      fill: white;
      stroke: var(--accent);
      stroke-width: 0.6;
      paint-order: stroke fill;
      font-size: 5px;
      font-weight: 900;
      dominant-baseline: central;
      text-anchor: middle;
      pointer-events: none;
    }
    output {
      display: block;
      min-height: 124px;
      max-height: 220px;
      overflow: auto;
      white-space: pre-wrap;
      word-break: break-word;
      background: #0b1220;
      color: #e6edf7;
      border-radius: 6px;
      padding: 12px;
      font: 12px/1.5 Consolas, monospace;
    }
    @media (max-width: 960px) {
      main { grid-template-columns: 1fr; }
      aside, .workspace { min-height: auto; }
      .workgrid { grid-template-columns: 1fr; }
      .reference { max-width: 280px; }
    }
  </style>
</head>
<body>
  <main>
    <aside>
      <h1>수작업 획 입력</h1>
      <div class="stat">
        <div><strong id="totalCount">0</strong><span>대상</span></div>
        <div><strong id="doneCount">0</strong><span>완료</span></div>
        <div><strong id="leftCount">0</strong><span>남음</span></div>
      </div>
      <div class="row">
        <label class="file">기존 JSON 불러오기<input id="fileInput" type="file" accept=".json" /></label>
        <button id="copyJson">JSON 복사</button>
        <button id="downloadJson">JSON 저장</button>
      </div>
      <label class="check">
        <input id="straightMode" type="checkbox" checked />
        직선 자동 보정
      </label>
      <label class="check">
        <input id="stabilizeMode" type="checkbox" checked />
        꺾임 흔들림 보정
      </label>
      <div id="charList" class="list"></div>
    </aside>

    <section class="workspace">
      <div class="topbar">
        <div class="current">
          <strong id="currentChar"></strong>
          <span id="currentMeta" class="meta"></span>
        </div>
        <div class="row">
          <button id="undo">한 획 취소</button>
          <button id="clear" class="danger">지우기</button>
          <button id="prev">이전</button>
          <button id="next" class="primary">다음</button>
        </div>
      </div>

      <div class="workgrid">
        <div class="reference">
          <img id="referenceImage" alt="교과서 획순 카드" />
          <div class="refbox">
            <dl>
              <dt>교과서</dt><dd id="bookMeta"></dd>
              <dt>뜻음</dt><dd id="meaningMeta"></dd>
              <dt>획수</dt><dd id="strokeMeta"></dd>
              <dt>대체</dt><dd id="sourceMeta"></dd>
            </dl>
          </div>
        </div>

        <div class="canvasWrap">
          <svg id="board" viewBox="0 0 100 100" aria-label="stroke capture board">
            <rect class="paper" x="4" y="4" width="92" height="92" rx="2"></rect>
            <path class="guide" d="M50 6 V94 M6 50 H94 M17 17 L83 83 M83 17 L17 83"></path>
            <text id="ghost" class="ghost" x="50" y="52"></text>
            <g id="strokes"></g>
            <path id="preview" class="previewStroke"></path>
          </svg>
        </div>
      </div>

      <output id="jsonOutput"></output>
    </section>
  </main>

  <script>
    const manualQueue = __ITEMS_JSON__;
    const state = {
      items: manualQueue,
      activeIndex: 0,
      drawing: false,
      currentPoints: [],
      holdTimer: null,
      straightLocked: false,
      lastStablePoint: null,
    };

    const els = {
      totalCount: document.getElementById("totalCount"),
      doneCount: document.getElementById("doneCount"),
      leftCount: document.getElementById("leftCount"),
      fileInput: document.getElementById("fileInput"),
      charList: document.getElementById("charList"),
      currentChar: document.getElementById("currentChar"),
      currentMeta: document.getElementById("currentMeta"),
      referenceImage: document.getElementById("referenceImage"),
      bookMeta: document.getElementById("bookMeta"),
      meaningMeta: document.getElementById("meaningMeta"),
      strokeMeta: document.getElementById("strokeMeta"),
      sourceMeta: document.getElementById("sourceMeta"),
      ghost: document.getElementById("ghost"),
      board: document.getElementById("board"),
      strokes: document.getElementById("strokes"),
      preview: document.getElementById("preview"),
      straightMode: document.getElementById("straightMode"),
      stabilizeMode: document.getElementById("stabilizeMode"),
      undo: document.getElementById("undo"),
      clear: document.getElementById("clear"),
      prev: document.getElementById("prev"),
      next: document.getElementById("next"),
      copyJson: document.getElementById("copyJson"),
      downloadJson: document.getElementById("downloadJson"),
      jsonOutput: document.getElementById("jsonOutput"),
    };

    function activeItem() {
      return state.items[state.activeIndex];
    }

    function toBoardPoint(event) {
      const rect = els.board.getBoundingClientRect();
      return {
        x: clamp(((event.clientX - rect.left) / rect.width) * 100, 0, 100),
        y: clamp(((event.clientY - rect.top) / rect.height) * 100, 0, 100),
      };
    }

    function clamp(value, min, max) {
      return Math.max(min, Math.min(max, value));
    }

    function pointsToPath(points, options = {}) {
      if (points.length === 0) return "";
      if (points.length === 1) return `M${fmt(points[0].x)} ${fmt(points[0].y)}`;
      const shouldStabilize = options.stabilize ?? els.stabilizeMode.checked;
      const simplified = shouldStabilize
        ? stabilizeStroke(points)
        : simplifyBySpacing(points, 0.85);
      if (shouldStabilize) return pointsToRoundedPath(simplified);

      let path = `M${fmt(simplified[0].x)} ${fmt(simplified[0].y)}`;
      for (let i = 1; i < simplified.length; i++) {
        path += ` L${fmt(simplified[i].x)} ${fmt(simplified[i].y)}`;
      }
      return path;
    }

    function pointsToRoundedPath(points) {
      if (points.length <= 2) return pointsToPolylinePath(points);
      let path = `M${fmt(points[0].x)} ${fmt(points[0].y)}`;
      for (let i = 1; i < points.length - 1; i++) {
        const previous = points[i - 1];
        const corner = points[i];
        const next = points[i + 1];
        const radius = cornerRadius(previous, corner, next);
        if (radius <= 0.25) {
          path += ` L${fmt(corner.x)} ${fmt(corner.y)}`;
          continue;
        }
        const before = pointToward(corner, previous, radius);
        const after = pointToward(corner, next, radius);
        path += ` L${fmt(before.x)} ${fmt(before.y)}`;
        path += ` Q${fmt(corner.x)} ${fmt(corner.y)} ${fmt(after.x)} ${fmt(after.y)}`;
      }
      const end = points[points.length - 1];
      path += ` L${fmt(end.x)} ${fmt(end.y)}`;
      return path;
    }

    function pointsToPolylinePath(points) {
      if (points.length === 0) return "";
      let path = `M${fmt(points[0].x)} ${fmt(points[0].y)}`;
      for (let i = 1; i < points.length; i++) {
        path += ` L${fmt(points[i].x)} ${fmt(points[i].y)}`;
      }
      return path;
    }

    function cornerRadius(previous, corner, next) {
      const incoming = segmentLength(previous, corner);
      const outgoing = segmentLength(corner, next);
      const angle = turnAngle(previous, corner, next);
      const maxRadius = angle > 55 ? 0.85 : 1.8;
      const segmentRatio = angle > 55 ? 0.12 : 0.26;
      return Math.min(maxRadius, incoming * segmentRatio, outgoing * segmentRatio);
    }

    function turnAngle(previous, corner, next) {
      const ax = corner.x - previous.x;
      const ay = corner.y - previous.y;
      const bx = next.x - corner.x;
      const by = next.y - corner.y;
      const aLength = Math.hypot(ax, ay);
      const bLength = Math.hypot(bx, by);
      if (aLength === 0 || bLength === 0) return 0;
      const cosine = clamp((ax * bx + ay * by) / (aLength * bLength), -1, 1);
      return Math.acos(cosine) * 180 / Math.PI;
    }

    function pointToward(from, to, distance) {
      const total = segmentLength(from, to);
      if (total === 0 || distance <= 0) return from;
      const ratio = Math.min(1, distance / total);
      return {
        x: from.x + (to.x - from.x) * ratio,
        y: from.y + (to.y - from.y) * ratio,
      };
    }

    function straightPath(points) {
      if (points.length < 2) return pointsToPath(points);
      const start = points[0];
      const end = points[points.length - 1];
      return `M${fmt(start.x)} ${fmt(start.y)} L${fmt(end.x)} ${fmt(end.y)}`;
    }

    function shouldStraighten(points) {
      if (!els.straightMode.checked || points.length < 3) return false;
      const start = points[0];
      const end = points[points.length - 1];
      const lineLength = Math.hypot(end.x - start.x, end.y - start.y);
      if (lineLength < 5) return false;

      let maxDistance = 0;
      let totalDistance = 0;
      let previous = start;
      for (const point of points.slice(1)) {
        totalDistance += Math.hypot(point.x - previous.x, point.y - previous.y);
        previous = point;
        maxDistance = Math.max(maxDistance, distanceToLine(point, start, end));
      }

      return maxDistance <= 2.25 && totalDistance / lineLength <= 1.18;
    }

    function distanceToLine(point, start, end) {
      const dx = end.x - start.x;
      const dy = end.y - start.y;
      const denominator = Math.hypot(dx, dy);
      if (denominator === 0) return Math.hypot(point.x - start.x, point.y - start.y);
      return Math.abs(dy * point.x - dx * point.y + end.x * start.y - end.y * start.x) / denominator;
    }

    function distanceToSegment(point, start, end) {
      const dx = end.x - start.x;
      const dy = end.y - start.y;
      const lengthSquared = dx * dx + dy * dy;
      if (lengthSquared === 0) return Math.hypot(point.x - start.x, point.y - start.y);
      const t = clamp(((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared, 0, 1);
      return Math.hypot(point.x - (start.x + t * dx), point.y - (start.y + t * dy));
    }

    function stablePoint(rawPoint) {
      if (!els.stabilizeMode.checked || !state.lastStablePoint) return rawPoint;
      const distance = Math.hypot(rawPoint.x - state.lastStablePoint.x, rawPoint.y - state.lastStablePoint.y);
      const weight = distance > 8 ? 0.82 : 0.68;
      return {
        x: state.lastStablePoint.x * weight + rawPoint.x * (1 - weight),
        y: state.lastStablePoint.y * weight + rawPoint.y * (1 - weight),
      };
    }

    function stabilizeStroke(points) {
      const spaced = simplifyBySpacing(points, 0.65);
      if (spaced.length <= 2) return spaced;
      const denoised = movingAverage(spaced);
      const simplified = rdp(denoised, 1.85);
      return removeTinyHooks(simplified);
    }

    function movingAverage(points) {
      if (points.length <= 4) return points;
      return points.map((point, index) => {
        if (index === 0 || index === points.length - 1) return point;
        const prev = points[index - 1];
        const next = points[index + 1];
        return {
          x: point.x * 0.5 + prev.x * 0.25 + next.x * 0.25,
          y: point.y * 0.5 + prev.y * 0.25 + next.y * 0.25,
        };
      });
    }

    function rdp(points, tolerance) {
      if (points.length <= 2) return points;
      let maxDistance = 0;
      let splitIndex = 0;
      const start = points[0];
      const end = points[points.length - 1];
      for (let i = 1; i < points.length - 1; i++) {
        const distance = distanceToSegment(points[i], start, end);
        if (distance > maxDistance) {
          maxDistance = distance;
          splitIndex = i;
        }
      }
      if (maxDistance <= tolerance) return [start, end];
      const left = rdp(points.slice(0, splitIndex + 1), tolerance);
      const right = rdp(points.slice(splitIndex), tolerance);
      return left.slice(0, -1).concat(right);
    }

    function removeTinyHooks(points) {
      if (points.length <= 3) return points;
      const cleaned = [...points];
      while (cleaned.length > 3 && segmentLength(cleaned[0], cleaned[1]) < 1.4) {
        cleaned.splice(1, 1);
      }
      while (cleaned.length > 3 && segmentLength(cleaned[cleaned.length - 2], cleaned[cleaned.length - 1]) < 1.4) {
        cleaned.splice(cleaned.length - 2, 1);
      }
      return cleaned;
    }

    function segmentLength(a, b) {
      return Math.hypot(a.x - b.x, a.y - b.y);
    }

    function clearHoldTimer() {
      if (state.holdTimer !== null) {
        clearTimeout(state.holdTimer);
        state.holdTimer = null;
      }
    }

    function scheduleStraightHold() {
      clearHoldTimer();
      if (!els.straightMode.checked || state.currentPoints.length < 2) return;
      state.holdTimer = setTimeout(() => {
        if (!state.drawing || state.currentPoints.length < 2) return;
        state.straightLocked = true;
        els.preview.setAttribute("d", straightPath(state.currentPoints));
      }, 450);
    }

    function simplifyBySpacing(points, tolerance) {
      if (points.length <= 2) return points;
      const kept = [points[0]];
      for (let i = 1; i < points.length - 1; i++) {
        const prev = kept[kept.length - 1];
        const point = points[i];
        if (Math.hypot(point.x - prev.x, point.y - prev.y) >= tolerance) {
          kept.push(point);
        }
      }
      kept.push(points[points.length - 1]);
      return kept;
    }

    function fmt(value) {
      return Number(value.toFixed(2)).toString();
    }

    function sourceLabel(source) {
      return source === "hanzi_writer_data" ? "Hanzi Writer 제외분" : "기존 누락";
    }

    function render() {
      const item = activeItem();
      const done = state.items.filter((row) => row.svgPaths.length === row.expectedStrokeCount).length;
      els.totalCount.textContent = state.items.length;
      els.doneCount.textContent = done;
      els.leftCount.textContent = state.items.length - done;
      els.charList.innerHTML = "";

      state.items.forEach((row, index) => {
        const button = document.createElement("button");
        const complete = row.svgPaths.length === row.expectedStrokeCount;
        button.className = `item${index === state.activeIndex ? " active" : ""}`;
        button.innerHTML = `
          <span class="char">${escapeHtml(row.character)}</span>
          <span class="meta">${escapeHtml(row.id)} · ${escapeHtml(row.grade)} ${escapeHtml(row.unit)}-${escapeHtml(row.lesson)} · ${escapeHtml(row.meaning)}</span>
          <span class="${complete ? "done" : "todo"}">${row.svgPaths.length}/${row.expectedStrokeCount}</span>
        `;
        button.addEventListener("click", () => {
          state.activeIndex = index;
          render();
        });
        els.charList.appendChild(button);
      });

      if (!item) return;
      els.currentChar.textContent = item.character;
      els.ghost.textContent = item.character;
      els.currentMeta.textContent = `${item.id} · ${item.grade} ${item.unit}단원 ${item.lesson}차시 · p.${item.textbookPage}`;
      els.referenceImage.src = item.referenceImage;
      els.bookMeta.textContent = `${item.grade} ${item.unit}단원 ${item.lesson}차시 / p.${item.textbookPage}`;
      els.meaningMeta.textContent = `${item.meaning} (${item.sound})`;
      els.strokeMeta.textContent = `${item.svgPaths.length}/${item.expectedStrokeCount}획`;
      els.sourceMeta.textContent = sourceLabel(item.previousSource);
      els.prev.disabled = state.activeIndex === 0;
      els.next.disabled = state.activeIndex >= state.items.length - 1;

      els.strokes.innerHTML = item.svgPaths.map((path, index) => {
        const start = firstPoint(path);
        return `<path class="stroke" d="${escapeHtml(path)}"></path><text class="num" x="${start.x}" y="${start.y}">${index + 1}</text>`;
      }).join("");
      els.preview.setAttribute("d", pointsToPath(state.currentPoints));
      els.jsonOutput.textContent = JSON.stringify(exportData(), null, 2);
    }

    function firstPoint(path) {
      const match = String(path).match(/[Mm]\\s*([-+0-9.eE]+)[,\\s]+([-+0-9.eE]+)/);
      return match ? { x: Number(match[1]), y: Number(match[2]) } : { x: 50, y: 50 };
    }

    function exportData() {
      return state.items
        .filter((row) => row.svgPaths.length > 0)
        .map((row) => ({
          id: `stroke-${row.id}`,
          hanjaId: row.id,
          character: row.character,
          source: "manual_capture",
          dataFormat: "svg_paths",
          strokeCount: row.svgPaths.length,
          svgPaths: row.svgPaths,
          reviewStatus: row.svgPaths.length === row.expectedStrokeCount ? "draft" : "incomplete",
        }));
    }

    function mergeManualJson(rows) {
      const byId = new Map(rows.map((row) => [row.hanjaId || row.id, row]));
      state.items.forEach((item) => {
        const manual = byId.get(item.id) || byId.get(`stroke-${item.id}`);
        if (!manual || !Array.isArray(manual.svgPaths)) return;
        item.svgPaths = [...manual.svgPaths];
      });
      render();
    }

    function escapeHtml(value) {
      return String(value).replace(/[&<>"']/g, (ch) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#039;",
      }[ch]));
    }

    els.board.addEventListener("pointerdown", (event) => {
      if (!activeItem()) return;
      els.board.setPointerCapture(event.pointerId);
      state.drawing = true;
      state.lastStablePoint = toBoardPoint(event);
      state.currentPoints = [state.lastStablePoint];
      state.straightLocked = false;
      scheduleStraightHold();
      render();
    });

    els.board.addEventListener("pointermove", (event) => {
      if (!state.drawing) return;
      clearHoldTimer();
      const point = stablePoint(toBoardPoint(event));
      state.lastStablePoint = point;
      state.currentPoints.push(point);
      state.straightLocked = false;
      els.preview.setAttribute("d", pointsToPath(state.currentPoints));
      scheduleStraightHold();
    });

    function finishStroke() {
      if (!state.drawing) return;
      clearHoldTimer();
      state.drawing = false;
      const item = activeItem();
      const path = state.straightLocked || shouldStraighten(state.currentPoints)
        ? straightPath(state.currentPoints)
        : pointsToPath(state.currentPoints);
      if (item && state.currentPoints.length >= 2 && path) {
        item.svgPaths.push(path);
      }
      state.currentPoints = [];
      state.straightLocked = false;
      state.lastStablePoint = null;
      render();
    }

    els.board.addEventListener("pointerup", finishStroke);
    els.board.addEventListener("pointercancel", finishStroke);
    els.undo.addEventListener("click", () => {
      const item = activeItem();
      if (item) item.svgPaths.pop();
      render();
    });
    els.clear.addEventListener("click", () => {
      const item = activeItem();
      if (item) item.svgPaths = [];
      render();
    });
    els.prev.addEventListener("click", () => {
      state.activeIndex = Math.max(0, state.activeIndex - 1);
      render();
    });
    els.next.addEventListener("click", () => {
      state.activeIndex = Math.min(state.items.length - 1, state.activeIndex + 1);
      render();
    });
    els.fileInput.addEventListener("change", async () => {
      const file = els.fileInput.files[0];
      if (!file) return;
      mergeManualJson(JSON.parse(await file.text()));
    });
    els.copyJson.addEventListener("click", async () => {
      await navigator.clipboard.writeText(JSON.stringify(exportData(), null, 2));
    });
    els.downloadJson.addEventListener("click", () => {
      const blob = new Blob([JSON.stringify(exportData(), null, 2)], { type: "application/json" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = "manual_stroke_capture_textbook_refs.json";
      a.click();
      URL.revokeObjectURL(a.href);
    });

    render();
  </script>
</body>
</html>
"""


def main() -> None:
    rows = read_rows(DEFAULT_REPORT_CSV, DEFAULT_TEXTBOOK_COUNTS)
    items = write_reference_cards(rows, DEFAULT_CARD_DIR, DEFAULT_OUTPUT)
    write_queue_csv(items, DEFAULT_QUEUE_CSV)
    DEFAULT_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    DEFAULT_OUTPUT.write_text(render_html(items), encoding="utf-8")
    print(f"wrote {DEFAULT_OUTPUT}")
    print(f"wrote {len(items)} reference cards to {DEFAULT_CARD_DIR}")
    print(f"wrote queue csv to {DEFAULT_QUEUE_CSV}")


if __name__ == "__main__":
    main()
