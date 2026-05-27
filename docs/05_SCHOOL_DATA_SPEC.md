# 05. School Data Specification

## Source File

```txt
data/source/학교기본정보_2026년03월31일기준.csv
```

Encoding:

```txt
cp949
```

Total source includes multiple school types. MVP uses only elementary schools.

## Raw Columns

```txt
시도교육청코드
시도교육청명
행정표준코드
학교명
영문학교명
학교종류명
시도명
관할조직명
설립명
도로명우편번호
도로명주소
도로명상세주소
전화번호
홈페이지주소
남녀공학구분명
팩스번호
고등학교구분명
산업체특별학급존재여부
고등학교일반전문구분명
특수목적고등학교계열명
입시전후기구분명
주야구분명
설립일자
개교기념일
수정일자
```

## MVP Filter

```txt
학교종류명 == '초등학교'
```

Do not include middle/high schools in MVP search results.

## Mapping

| Supabase column | CSV column |
|---|---|
| standard_school_code | 행정표준코드 |
| office_code | 시도교육청코드 |
| office_name | 시도교육청명 |
| school_name | 학교명 |
| school_name_eng | 영문학교명 |
| school_kind | 학교종류명 |
| region_name | 시도명 |
| jurisdiction_name | 관할조직명 |
| establishment_type | 설립명 |
| road_zip_code | 도로명우편번호 |
| road_address | 도로명주소 |
| road_detail_address | 도로명상세주소 |
| phone_number | 전화번호 |
| homepage_url | 홈페이지주소 |
| coeducation_type | 남녀공학구분명 |
| fax_number | 팩스번호 |
| founded_at | 설립일자 |
| anniversary_at | 개교기념일 |
| source_updated_at | 수정일자 |

## Login Search Behavior

- Search starts from 2 Korean characters.
- Search by `school_name ilike %keyword%`.
- Optional filter by `region_name` later.
- Max results: 20.
- Sort by exact prefix match first, then school_name asc.

## UI Display

Search result card:

```txt
학교명
시도명 · 도로명주소
표준학교코드: 행정표준코드
```

The standard code should be small text. Users should search by school name, not type the code.

## Duplicate School Names

If schools have same name, distinguish by:

1. region_name
2. road_address
3. office_name

## Import Deliverable

`tools/school_seed/import_school_csv.py` should output:

```txt
supabase/seed/schools_elementary_seed.csv
```

The generated CSV should match Supabase `schools` columns except `id`, `created_at`, `updated_at`.
