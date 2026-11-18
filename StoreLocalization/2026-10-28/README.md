# Railway Fury store localization — October 28, 2026

Saved to the Steamworks store records for Railway Fury (5520300, item 1410386)
and Railway Fury Demo (5520330, item 1410394).

## Coverage

Both pages have English plus French, Italian, German, Spanish (Spain), Czech,
Indonesian, Japanese, Korean, Polish, Portuguese (Portugal), Russian,
Simplified Chinese, Thai, Turkish, and Vietnamese.

The main game has localized About This Game, short description, and all four
populated minimum-system-requirement text fields. The demo has localized
About This Demo, short description, and its populated system-requirement note.
The previously blank English demo short description was also added.
Existing English copy and hardware specifications were preserved.

Catalan is also supported by the game. Steam's store text language selectors
and bulk-localization format do not offer Catalan. `catalan.json` contains both
pages' translated copy and requirements for reuse outside Steam. No unrelated
Steam locale was used to hold Catalan text.

## Files and validation

- `main_steam_upload.json` and `demo_steam_upload.json`: packages uploaded.
- `main_before.json` and `demo_before.json`: original Steam exports.
- `main_verified.json` and `demo_verified.json`: fresh exports after import.
- `verification.json`: exact comparisons against the uploaded fields.
- Language-named JSON files: final edited translations, including Catalan.
- `english.json`: English source and the added demo short description.
- Preview PNGs: German main-game and Japanese demo descriptions in Steamworks.

All 90 uploaded main-game fields and all 46 uploaded demo fields matched the
fresh Steam exports exactly. Short descriptions are at most 300 characters.
Paragraph markup, game title, control meanings, four main-game railways, two
endings, the demo's first-boss limit, and its separate save were checked.
German main-game and Japanese demo descriptions were inspected in the visual
editor after reloading the saved records.

These changes are saved as unpublished store changes. The store editors state
that Valve must approve the pages before their initial public release. No
publish or review submission was made in this task.

The draft generator is `tools/railway_demo/localize_store.py`; the editorial
copy and requirements are in `tools/railway_demo/review_store.py`. Run the latter
to reapply the edited copy and rebuild upload packages without network access.
