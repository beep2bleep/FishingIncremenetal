"""Compare fresh Steam downloads with upload packages and original exports."""
import json
import pathlib
from localize_catalog import OUT

report=[]
for row in json.loads((OUT/'saved_exports.json').read_text(encoding='utf8')):
    itemid=row['itemid']
    expected=json.loads((OUT/(itemid+'_upload.json')).read_text(encoding='utf8'))
    original=json.loads((OUT/(itemid+'_before.json')).read_text(encoding='utf8'))
    actual=json.loads(pathlib.Path(row['download']).read_text(encoding='utf8'))
    differences=[(language,key) for language,fields in expected['languages'].items()
                 for key,value in fields.items()
                 if actual['languages'].get(language,{}).get(key)!=value]
    untouched=[(language,key) for language,fields in original['languages'].items()
               for key,value in fields.items()
               if key not in expected['languages'].get(language,{})
               and actual['languages'].get(language,{}).get(key)!=value]
    entry={'itemid':itemid,'title':row['name'],
           'translation_languages':len(expected['languages']),
           'fields_verified':sum(len(f) for f in expected['languages'].values()),
           'mismatches':differences,'unexpected_changes':untouched,
           'english_preserved':actual['languages']['english']==original['languages']['english']}
    report.append(entry)
    (OUT/(itemid+'_verified.json')).write_text(json.dumps(actual,ensure_ascii=False,indent=2),encoding='utf8')
(OUT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
assert len(report)==8, 'Incomplete catalog exports'
assert len({r['itemid'] for r in report})==8, 'Duplicate catalog exports'
assert all(not r['mismatches'] and not r['unexpected_changes'] and r['english_preserved'] for r in report), report
print(json.dumps(report,indent=2))
print('TOTAL',sum(r['fields_verified'] for r in report),'verified fields; all English and untouched locales preserved.')
