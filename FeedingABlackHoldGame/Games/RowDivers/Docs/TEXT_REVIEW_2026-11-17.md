# Railway wording and translation refresh

Source follow-up after the published 0.5 builds; fresh exports are required.

Player-facing death/victory headings, damage source labels, resistance upgrade
names/descriptions, the completion achievement and ending heading now use Railway
or railway/track wording. The death heading is `THE RAILWAY CLAIMS YOU`.
Progression IDs, achievement IDs and save profiles are preserved.

The three design datasets were reviewed. All 557 current source messages were
rebuilt for 17 supported languages, including the new controller prompts.
The refresh retranslated all non-overridden messages and retained previously
reviewed terminology. New overrides correct ambiguous controller terms such as
PAN and the figurative death message. These are machine-assisted translations;
the checks do not certify a native-speaker review of every sentence.

The runtime catalog and per-language caches no longer contain legacy `row`
source keys. The extractor also excludes an internal UI-node identifier that
was incorrectly collected as copy. Historical simulation reports and internal
module/save identifiers are not player-facing copy.

Validation:

- 20,305 localization/runtime checks passed: equal language coverage, no legacy
  source wording, preserved placeholders, translation registration, actual death
  heading/details, progression gates and full/demo save isolation.
- 37 focused controller/menu checks passed after the catalog refresh.

Regenerate from scratch with `python tools/railway_demo/localize.py --refresh`.
`tools/railway_demo/review_railway_text.py` records the newly reviewed wording in
the persistent overrides. Normal regeneration retains those overrides.
