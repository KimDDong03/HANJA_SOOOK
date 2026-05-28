# Stroke Seed Worklist

This folder contains tooling for manual Hanja stroke-data production.

`build_cns_manual_worklist.py` reads the project Excel DB and CNS11643 data, then
creates `output/manual_stroke/cns_manual_worklist.csv`.

The CSV is a manual production sheet, not final app data. CNS provides baseline
metadata such as Unicode mapping, stroke count, and stroke-type sequence. The
actual app-quality SVG paths still need manual drawing and review.

`export_hanja_demo_missing_strokes.py` compares Excel Hanja rows with
`hanja_demo` stroke data and writes the manual capture target list. It treats
`內` as matched by the `hanja_demo` `内` stroke data because the textbook glyph
matches that form.

`build_app_stroke_seed.py` builds `assets/data/stroke_seed.example.json` from
the textbook-extracted character/count list, `hanja_demo` paths, manual capture
paths, and Hanzi Writer Data 2.0.1 paths derived from Make Me A Hanzi. It only
keeps rows whose source character and stroke count match the textbook-derived
character/count. Non-matching rows are reported as `missing`.

`generate_stroke_mismatch_review.py` reads the app stroke seed and build report,
then creates `docs/prototypes/stroke_mismatch_review.html` for reviewing rows
whose generated stroke count differs from the CNS baseline.

`generate_textbook_mismatch_review.py` reads
`output/manual_stroke/stroke_mismatch_locations.csv`, maps each mismatch to its
textbook learning page, renders the supplied textbook PDF page, and writes a
manual review workbook/HTML under
`output/manual_stroke/textbook_mismatch_review/`.

`apply_textbook_stroke_counts_to_excel.py` extracts textbook characters and
total stroke counts from the textbook PDFs and writes them back to a copy of the
source Excel workbook as `교과서한자`, `교과서획수`, `획수출처`, and `획수검증`.

Run:

```powershell
python tools/stroke_seed/build_cns_manual_worklist.py --xlsx "C:\Users\User\Downloads\한자쏘옥완전DB초3~6학년.xlsx"
```
