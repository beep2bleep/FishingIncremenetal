"""Reviewed railway/death wording and unambiguous controller commands."""
import json
from localize import OUT

# A death message means the railway takes your life, rather than requesting you.
# PAN means moving the upgrade view, never bread, cookware or a chemical acronym.
TEXT = {
    'es': ['EL FERROCARRIL SE COBRA TU VIDA', 'EL FERROCARRIL ES TUYO', 'DESPLAZAR', 'AMPLIAR', 'CURSOR', 'MENÚ'],
    'de': ['DIE EISENBAHN FORDERT DEIN LEBEN', 'DIE EISENBAHN GEHÖRT DIR', 'VERSCHIEBEN', 'VERGRÖSSERN', 'ZEIGER', 'MENÜ'],
    'pt': ['A FERROVIA LEVA SUA VIDA', 'A FERROVIA É SUA', 'MOVER VISÃO', 'AMPLIAR', 'PONTEIRO', 'MENU'],
    'fr': ['LE CHEMIN DE FER EMPORTE TA VIE', 'LE CHEMIN DE FER EST À TOI', 'DÉPLACER LA VUE', 'AGRANDIR', 'CURSEUR', 'MENU'],
    'it': ['LA FERROVIA RECLAMA LA TUA VITA', 'LA FERROVIA È TUA', 'SPOSTA VISUALE', 'INGRANDISCI', 'CURSORE', 'MENÙ'],
    'zh': ['铁路夺走了你的生命', '铁路属于你', '平移视图', '缩放', '光标', '菜单'],
    'ja': ['鉄道がお前の命を奪う', '鉄道はお前のものだ', '視点移動', '拡大・縮小', 'カーソル', 'メニュー'],
    'ko': ['철도가 당신의 목숨을 앗아갑니다', '철도는 당신의 것입니다', '화면 이동', '확대·축소', '커서', '메뉴'],
    'ru': ['ЖЕЛЕЗНАЯ ДОРОГА ЗАБИРАЕТ ТВОЮ ЖИЗНЬ', 'ЖЕЛЕЗНАЯ ДОРОГА ТВОЯ', 'СДВИГ ВИДА', 'МАСШТАБ', 'КУРСОР', 'МЕНЮ'],
    'pl': ['KOLEJ ODBIERA CI ŻYCIE', 'KOLEJ JEST TWOJA', 'PRZESUŃ WIDOK', 'SKALA', 'KURSOR', 'MENU'],
    'tr': ['DEMİRYOLU CANINI ALIYOR', 'DEMİRYOLU SENİNDİR', 'GÖRÜNÜMÜ KAYDIR', 'YAKINLAŞTIR', 'İMLEÇ', 'MENÜ'],
    'th': ['ทางรถไฟพรากชีวิตคุณ', 'ทางรถไฟเป็นของคุณ', 'เลื่อนมุมมอง', 'ย่อหรือขยาย', 'เคอร์เซอร์', 'เมนู'],
    'id': ['JALUR KERETA MERENGGUT NYAWAMU', 'JALUR KERETA ADALAH MILIKMU', 'GESER TAMPILAN', 'PERBESAR', 'KURSOR', 'MENU'],
    'cs': ['ŽELEZNICE SI BERE TVŮJ ŽIVOT', 'ŽELEZNICE JE TVOJE', 'POSUN POHLEDU', 'PŘIBLÍŽENÍ', 'KURZOR', 'NABÍDKA'],
    'ca': ['EL FERROCARRIL S’EMPORTA LA TEVA VIDA', 'EL FERROCARRIL ÉS TEU', 'DESPLAÇA LA VISTA', 'AMPLIA', 'PUNTER', 'MENÚ'],
    'vi': ['ĐƯỜNG SẮT CƯỚP ĐI MẠNG SỐNG CỦA BẠN', 'ĐƯỜNG SẮT THUỘC VỀ BẠN', 'DỊCH CHUYỂN KHUNG NHÌN', 'THU PHÓNG', 'CON TRỎ', 'TRÌNH ĐƠN'],
}
KEYS = ['THE RAILWAY CLAIMS YOU', 'THE RAILWAY IS YOURS', 'PAN', 'ZOOM', 'CURSOR', 'MENU']


def main():
    path = OUT / 'overrides.json'
    overrides = json.loads(path.read_text(encoding='utf8'))
    for locale, values in TEXT.items():
        overrides.setdefault(locale, {}).update(dict(zip(KEYS, values)))
    overrides['de'].update({'Level 2': 'Stufe 2', 'Level 3': 'Stufe 3', 'Level 4': 'Stufe 4', 'PAUSE': 'PAUSIEREN'})
    overrides['fr']['PAUSE'] = 'METTRE EN PAUSE'
    overrides['tr']['Shuriken'] = 'Şuriken'
    overrides['ca'].update({'AIM': 'APUNTA', 'MOVE CURSOR': 'MOU EL PUNTER'})
    overrides['cs'].update({'AIM': 'MÍŘENÍ', 'PLAY / RETURN': 'HRÁT / ZPĚT', 'POWER': 'SCHOPNOST',
                            'RUN': 'BĚH', 'SCROLL': 'POSOUVÁNÍ', 'MOVE CURSOR': 'POHYB KURZORU',
                            'Impact Armor I': 'Nárazové brnění I', 'Max HP I': 'Maximální zdraví I',
                            'Max HP III': 'Maximální zdraví III', 'Max HP IV': 'Maximální zdraví IV'})
    for level in range(2, 5):
        for branch in range(1, 5):
            overrides['cs'][f'Ember Channels {level}-{branch}'] = f'Žhavé kanály {level}-{branch}'
    # Native words legitimately shared with English.
    # Use translated labels elsewhere instead of whitelisting ambiguous PAN/ZOOM.
    path.write_text(json.dumps(overrides, ensure_ascii=False, indent=2) + '\n', encoding='utf8')
    print('Reviewed railway death/win wording and controller commands in 16 translations.')


if __name__ == '__main__':
    main()
