# 04. Writing Engine Specification

## Goal

The writing feature must feel interactive and demo-ready while staying simple enough for MVP.
It must support future replacement of the stroke data source.

## Architecture

```txt
WritingScreen
→ WritingController
→ StrokeEngine
→ StrokeGuideProvider / StrokeScoringService
```

`WritingScreen` must not import open-source stroke packages directly.

## StrokeEngine Interface

Required behavior:

```dart
abstract class StrokeEngine {
  Future<StrokeGuideData?> loadGuide(String hanjaId);

  List<NormalizedPoint> normalizePoints({
    required List<RawPoint> rawPoints,
    required double canvasWidth,
    required double canvasHeight,
  });

  StrokeScore scoreStroke({
    required List<NormalizedPoint> userPoints,
    required List<NormalizedPoint> expectedPoints,
  });

  WritingScore scoreWriting({
    required List<UserStroke> userStrokes,
    StrokeGuideData? guideData,
  });
}
```

## Modes

| Mode | Condition | Behavior |
|---|---|---|
| preview | guide exists | 획순 보기 |
| guided | guide exists | 획별 가이드 + 단순 판정 |
| free | no guide | 자유쓰기 fallback |
| result | completed | 결과 계산 후 result screen |

## Input Collection

- `onPanStart`: create new `UserStroke`
- `onPanUpdate`: append raw point
- `onPanEnd`: finalize stroke
- Normalize points to 0~1 canvas coordinate.

### Raw Point

```json
{ "x": 123.0, "y": 240.0, "timestampMs": 32 }
```

### Normalized Point

```json
{ "x": 0.41, "y": 0.80, "t": 32 }
```

## Noise Filtering

Before scoring:

- If point count < 3, invalid stroke.
- If total distance < 0.03, invalid stroke.
- If distance between consecutive points < 0.004, merge/ignore.

## Smoothing

Use simple moving average.
Start/end point should remain unchanged.

```txt
smoothed[i] = average(points[i-1], points[i], points[i+1])
```

## Resampling

Resample both user stroke and expected stroke to 48 points by path length.

## Stroke Scoring

Final score is 100 max.

| Component | Weight |
|---|---:|
| Start point similarity | 15 |
| End point similarity | 15 |
| Average path distance | 35 |
| Direction similarity | 20 |
| Length/coverage | 15 |

Formula:

```txt
finalScore =
  startScore * 0.15 +
  endScore * 0.15 +
  pathScore * 0.35 +
  directionScore * 0.20 +
  coverageScore * 0.15
```

### Start/End Distance Score

| Distance | Score |
|---:|---:|
| <= 0.05 | 100 |
| <= 0.10 | 80 |
| <= 0.18 | 50 |
| > 0.18 | 20 |

### Path Distance Score

| Average Distance | Score |
|---:|---:|
| <= 0.04 | 100 |
| <= 0.08 | 80 |
| <= 0.13 | 60 |
| <= 0.20 | 40 |
| > 0.20 | 20 |

### Direction Score

Compare start→end vector cosine similarity.

| Cosine Similarity | Score |
|---:|---:|
| >= 0.90 | 100 |
| >= 0.75 | 80 |
| >= 0.50 | 60 |
| >= 0.20 | 40 |
| < 0.20 | 20 |

### Coverage Score

Compare length ratio: user length / expected length.

| Ratio | Score |
|---|---:|
| 0.75~1.30 | 100 |
| 0.60~1.50 | 75 |
| 0.40~1.80 | 50 |
| else | 25 |

## Writing Score

Guided mode:

- Score each stroke where expected data exists.
- If user wrote fewer strokes, missing strokes score 35.
- If user wrote extra strokes, apply small penalty.
- MVP must be forgiving.

Free mode fallback:

```txt
baseScore = 60
+ input amount sufficient: +10
+ center area coverage: +10
+ stroke count close to expected: +10
- too short/tap only: -30
max: 85
```

## Stars

| Score | Stars |
|---:|---:|
| >= 85 | 3 |
| >= 65 | 2 |
| >= 45 | 1 |
| < 45 | 0 |

## Data Source Policy

Open-source stroke data can be used only through adapter.

Candidate sources:

- Make Me a Hanzi / Hanzi Writer data
- stroke_order_animator package
- manual SVG/path data

Every stroke asset must track:

- source
- data_format
- license_note
- review_status

`review_status` values:

- available
- needs_review
- missing
- manual_required

## Demo Safety Rule

Missing/invalid stroke data must not block the flow.
Always fallback to free-writing mode.
