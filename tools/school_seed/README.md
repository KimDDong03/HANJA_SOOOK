# School Seed Tool

Use this tool to convert the public school master CSV into a Supabase-importable CSV.

```bash
python tools/school_seed/import_school_csv.py
```

Input:

```txt
data/source/학교기본정보_2026년03월31일기준.csv
```

Output:

```txt
supabase/seed/schools_elementary_seed.csv
```

The script must read the source with `cp949` and use only rows where `학교종류명 == '초등학교'`.
