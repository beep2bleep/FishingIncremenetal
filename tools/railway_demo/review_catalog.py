"""Editorial terminology, descriptions, and audits for catalog uploads."""
import json
import re
from collections import Counter
from localize_catalog import OUT, ABOUT, SHORT, TAGS, BRANDS, normalized, build

# Columns: BleepWare, Data Breach, Deepcore, Vanguard. Main English is retained.
SHORTS = {
'french': [
"Cinq jeux incrémentaux complets et un crossover qui les relie. Développez votre machine de guerre, creusez toujours plus profond, résistez aux assauts, plongez dans l'absurde et pêchez au cœur des ténèbres. Une collection où chaque aventure fait grandir vos chiffres.",
"Pilotez un engin de piratage dans les infrastructures d'une entreprise hostile. Creusez le pare-feu, brisez les cœurs de daemons, ramenez votre butin et achetez des améliorations permanentes entre les missions.",
"Un jeu minier incrémental rythmé par de courtes expéditions. Pilotez une foreuse, rapportez le minerai à la base, débloquez des profondeurs inédites et investissez vos gains dans des améliorations permanentes.",
"Un auto-battler idle où votre escouade combat en continu. Optimisez vos améliorations, activez les compétences des héros au bon moment et franchissez les différentes phases des boss."],
'german': [
"Fünf vollständige Incremental-Spiele und ein verbindendes Crossover. Baue deine Kriegsmaschine aus, grabe nach Rohstoffen, überstehe immer härtere Abwehrkämpfe, erlebe absurdes Chaos und angle in unheimlicher Dunkelheit. Eine Sammlung voller stetigen Wachstums.",
"Steuere ein Hacking-Fahrzeug in feindliche Unternehmenssysteme. Baue die Firewall ab, knacke Daemon-Kerne, sichere deine Beute und kaufe zwischen den Einsätzen dauerhafte Upgrades.",
"Ein Incremental-Bergbauspiel mit kurzen Expeditionen: Steuere dein Bohrfahrzeug, bringe Erz zur Basis, erschließe tiefere Schichten und investiere deine Erträge in dauerhafte Upgrades.",
"Ein Idle-Auto-Battler, in dem dein Trupp ständig kämpft. Optimiere Upgrades, setze aktive Heldenfähigkeiten im richtigen Moment ein und durchbrich die Bossphasen."],
'italian': [
"Cinque giochi incrementali completi e un crossover che li collega. Sviluppa la tua macchina da guerra, scava sempre più a fondo, resisti agli assalti, abbraccia il caos assurdo e pesca nell'oscurità. Una raccolta di avventure in cui i numeri non smettono di crescere.",
"Pilota un mezzo da hacking nelle infrastrutture di un'azienda ostile. Scava nel firewall, distruggi i nuclei dei daemon, porta in salvo il bottino e acquista potenziamenti permanenti tra le missioni.",
"Un gioco minerario incrementale a spedizioni: guida una trivella, riporta il minerale alla base, sblocca strati più profondi e investi i guadagni di brevi spedizioni in potenziamenti permanenti.",
"Un auto-battler idle in cui la tua squadra combatte senza sosta. Ottimizza i potenziamenti, attiva le abilità degli eroi e supera le fasi dei boss."],
'spanish': [
"Cinco juegos incrementales completos y un crossover que los conecta. Desarrolla tu máquina de guerra, excava en busca de recursos, resiste asaltos crecientes, abraza el caos absurdo y pesca entre las sombras. Una colección de aventuras donde los números no dejan de crecer.",
"Pilota un vehículo de intrusión en las infraestructuras de una empresa hostil. Excava el cortafuegos, destruye núcleos de daemons, extrae tu botín y compra mejoras permanentes entre misiones.",
"Un juego minero incremental por expediciones: pilota una perforadora, lleva mineral a la base, desbloquea capas más profundas e invierte las ganancias de incursiones breves en mejoras permanentes.",
"Un auto-battler idle en el que tu escuadrón combate sin parar. Optimiza mejoras, activa las habilidades de los héroes y supera las fases de los jefes."],
'czech': [
"Pět kompletních inkrementálních her a crossover, který je propojuje. Rozvíjej válečnou mašinérii, těž stále hlouběji, odolávej sílícím útokům, užij si absurdní chaos a rybař v plíživé temnotě. Sbírka dobrodružství, ve kterých čísla stále rostou.",
"Pilotuj hackerský stroj v nepřátelské firemní infrastruktuře. Těž firewall, nič jádra daemonů, unikni s kořistí a mezi misemi kupuj trvalá vylepšení.",
"Inkrementální těžební hra s krátkými výpravami. Řiď vrtný stroj, voz rudu na základnu, odemykej hlubší vrstvy a proměňuj odměny z výprav v trvalá vylepšení.",
"Idle auto-battler, ve kterém tvoje družina nepřetržitě bojuje. Optimalizuj vylepšení, aktivuj schopnosti hrdinů a překonávej fáze bossů."],
'indonesian': [
"Lima game inkremental lengkap dan crossover yang menghubungkannya. Kembangkan mesin perang, gali sumber daya semakin dalam, bertahan dari serangan yang meningkat, nikmati kekacauan absurd, dan memancing di tengah kegelapan. Kumpulan petualangan dengan angka yang terus bertumbuh.",
"Kendalikan kendaraan peretasan di infrastruktur perusahaan musuh. Tambang firewall, hancurkan inti daemon, bawa pulang jarahan, dan beli peningkatan permanen di antara misi.",
"Game penambangan inkremental dengan ekspedisi singkat. Kendalikan kendaraan bor, bawa bijih ke markas, buka lapisan lebih dalam, dan investasikan hasil ekspedisi untuk peningkatan permanen.",
"Auto-battler idle: pasukanmu terus bertempur saat kamu mengoptimalkan peningkatan, mengaktifkan kemampuan hero, dan menembus fase bos."],
'japanese': [
"五つの完成されたインクリメンタルゲームと、それらをつなぐクロスオーバーを収録。軍備を拡大し、資源を求めて地中深くへ進み、激化する防衛戦を生き抜こう。奇想天外な成長や、忍び寄る闇の中での釣りも楽しめる、数字が伸び続ける冒険集。",
"侵入用マシンを操り、敵対企業のシステムへ潜入。ファイアウォールを掘り進み、デーモンコアを破壊し、戦利品を持ち帰ろう。ミッションの合間に永続強化を購入し、次はさらに奥へ。",
"短い遠征を繰り返す採掘インクリメンタルゲーム。掘削マシンを操り、鉱石を基地に持ち帰り、より深い層を解放。遠征で得た報酬を永続強化に使い、次の挑戦につなげよう。",
"部隊が戦い続ける放置型オートバトラー。強化を最適化し、ここぞという場面でヒーローのアクティブスキルを発動して、ボスの各フェーズを突破しよう。"],
'koreana': [
"완성된 다섯 가지 점진적 성장 게임과 이를 연결하는 크로스오버를 만나보세요. 전쟁 병기를 키우고, 지하 깊이 자원을 캐고, 거세지는 공격을 막아내세요. 황당한 혼돈과 어둠 속 낚시까지, 숫자가 계속 커지는 모험을 하나의 모음집에 담았습니다.",
"침투 장비를 조종해 적대 기업의 시스템으로 들어가세요. 방화벽에서 자원을 캐고, 데몬 코어를 파괴하고, 전리품을 챙겨 탈출하세요. 임무 사이에 영구 강화를 구매해 다음에는 더 깊이 침투하세요.",
"짧은 탐사를 반복하는 점진적 성장 채굴 게임입니다. 굴착 장비를 조종해 광석을 기지로 가져오고, 더 깊은 지층을 해금하세요. 탐사 보상을 영구 강화에 투자해 더 멀리 나아가세요.",
"부대가 계속 전투를 벌이는 방치형 오토 배틀러입니다. 강화를 최적화하고, 영웅의 액티브 능력을 발동하며, 보스의 각 단계를 돌파하세요."],
'polish': [
"Pięć pełnych gier z przyrostowym rozwojem i łączący je crossover. Rozbudowuj machinę wojenną, wydobywaj coraz głębiej, odpieraj coraz silniejsze ataki, zanurz się w absurdalnym chaosie i łów w narastającym mroku. Kolekcja przygód, w których liczby stale rosną.",
"Pilotuj maszynę hakerską w infrastrukturze wrogiej korporacji. Wydobywaj zasoby z zapory, rozbijaj rdzenie daemonów, uciekaj z łupem i kupuj trwałe ulepszenia między misjami.",
"Gra górnicza z przyrostowym rozwojem i krótkimi wyprawami. Steruj wiertnicą, dowoź rudę do bazy, odblokowuj głębsze warstwy i inwestuj zyski z wypraw w trwałe ulepszenia.",
"Bezczynnościowy auto-battler, w którym drużyna nieustannie walczy. Optymalizuj ulepszenia, aktywuj umiejętności bohaterów i przebijaj się przez fazy bossów."],
'portuguese': [
"Cinco jogos incrementais completos e um crossover que os liga. Expande a tua máquina de guerra, escava cada vez mais fundo, resiste a ataques crescentes, abraça o caos absurdo e pesca na escuridão. Uma coleção de aventuras em que os números não param de crescer.",
"Pilota um veículo de intrusão nas infraestruturas de uma empresa hostil. Escava a firewall, destrói núcleos de daemons, regressa com o saque e compra melhorias permanentes entre missões.",
"Um jogo mineiro incremental com expedições curtas. Conduz uma perfuradora, leva minério à base, desbloqueia camadas mais profundas e investe os ganhos das expedições em melhorias permanentes.",
"Um auto-battler idle em que a tua equipa combate sem parar. Otimiza melhorias, ativa as habilidades dos heróis e supera as fases dos bosses."],
'brazilian': [
"Cinco jogos incrementais completos e um crossover que os conecta. Expanda sua máquina de guerra, escave cada vez mais fundo, resista a ataques crescentes, abrace o caos absurdo e pesque na escuridão. Uma coleção de aventuras em que os números não param de crescer.",
"Pilote um veículo de invasão pela infraestrutura de uma empresa hostil. Escave o firewall, destrua núcleos de daemons, saia com o saque e compre melhorias permanentes entre missões.",
"Um jogo incremental de mineração com expedições curtas. Pilote uma perfuradora, leve minério à base, desbloqueie camadas mais profundas e invista os ganhos das expedições em melhorias permanentes.",
"Um auto-battler idle em que sua equipe luta sem parar. Otimize melhorias, ative as habilidades dos heróis e supere as fases dos chefes."],
'russian': [
"Пять полноценных инкрементальных игр и объединяющий их кроссовер. Развивайте военную машину, добывайте ресурсы всё глубже, отражайте всё более сильные атаки, окунитесь в абсурдный хаос и рыбачьте во тьме. Коллекция приключений, где числа постоянно растут.",
"Управляйте машиной для взлома в системах враждебной корпорации. Добывайте ресурсы из фаервола, разрушайте ядра демонов, возвращайтесь с добычей и покупайте постоянные улучшения между вылазками.",
"Инкрементальная игра о добыче руды в коротких экспедициях. Управляйте буровой машиной, доставляйте руду на базу, открывайте более глубокие слои и вкладывайте награды в постоянные улучшения.",
"Idle-автобаттлер, в котором отряд сражается непрерывно. Оптимизируйте улучшения, применяйте активные способности героев и преодолевайте фазы боссов."],
'schinese': [
"五款完整的增量游戏，加上将它们串联起来的联动内容。壮大你的战争机器，深入地下开采资源，抵御不断升级的攻势，拥抱荒诞混乱，并在逐渐蔓延的黑暗中垂钓。在这一合集里，以不同方式体验数值不断增长的冒险。",
"驾驶入侵装置，渗透敌对企业的基础设施。挖掘防火墙资源，击破守护进程核心，带着收获撤离，并在任务之间购买永久强化，向更深处发起下一次入侵。",
"以短途探险为核心的增量采矿游戏。驾驶钻探装置，将矿石运回基地，解锁更深的地层，再把每次探险的收益投入永久强化。",
"你的队伍将持续自动作战，而你负责优化强化、发动英雄的主动技能，突破首领的各个阶段。体验兼具放置成长与战术选择的自动战斗游戏。"],
'thai': [
"เกมสะสมพลังฉบับเต็มห้าเกม พร้อมครอสโอเวอร์ที่เชื่อมทุกเกมเข้าด้วยกัน สร้างกองทัพ ขุดหาทรัพยากรให้ลึกขึ้น ต้านการโจมตีที่รุนแรงขึ้น สนุกกับความวุ่นวายสุดเพี้ยน และตกปลาในความมืด รวมการผจญภัยที่ตัวเลขเติบโตได้หลายรูปแบบ",
"บังคับเครื่องเจาะระบบเข้าสู่โครงสร้างของบริษัทศัตรู ขุดไฟร์วอลล์ ทำลายแกนเดมอน หนีออกมาพร้อมของที่ได้ และซื้ออัปเกรดถาวรระหว่างภารกิจเพื่อบุกลึกกว่าเดิม",
"เกมขุดแร่แบบสะสมพลังผ่านการสำรวจสั้น ๆ บังคับรถเจาะ ขนแร่กลับฐาน ปลดล็อกชั้นดินที่ลึกขึ้น และนำรายได้จากการสำรวจไปซื้ออัปเกรดถาวร",
"เกมต่อสู้อัตโนมัติแบบไอเดิลที่ทีมของคุณสู้ต่อเนื่อง วางแผนอัปเกรด ใช้สกิลกดใช้ของฮีโร่ให้ถูกจังหวะ และฝ่าการต่อสู้แต่ละช่วงของบอส"],
'turkish': [
"Beş tam artımlı oyun ve onları birbirine bağlayan bir crossover. Savaş makineni büyüt, kaynaklar için daha derine kaz, artan saldırılara diren, absürt kaosa dal ve karanlıkta balık tut. Sayıların farklı şekillerde büyüdüğü bir macera koleksiyonu.",
"Bir sızma aracını düşman şirketin altyapısına sok. Güvenlik duvarından kaynak çıkar, daemon çekirdeklerini parçala, ganimetinle kaç ve görevler arasında kalıcı yükseltmeler al.",
"Kısa seferlere dayalı artımlı bir madencilik oyunu. Sondaj aracını sür, cevheri üsse taşı, daha derin katmanları aç ve seferlerden kazandıklarını kalıcı yükseltmelere yatır.",
"Ekibinin sürekli savaştığı bir idle auto-battler. Yükseltmeleri optimize et, kahramanların aktif yeteneklerini kullan ve boss aşamalarını aş."],
'vietnamese': [
"Năm game tăng tiến hoàn chỉnh và nội dung giao thoa kết nối chúng. Phát triển cỗ máy chiến tranh, đào sâu tìm tài nguyên, chống đỡ các đợt tấn công mạnh dần, đón nhận hỗn loạn phi lý và câu cá giữa bóng tối. Một tuyển tập phiêu lưu với những con số không ngừng tăng.",
"Lái thiết bị xâm nhập vào hạ tầng của tập đoàn thù địch. Đào tường lửa lấy tài nguyên, phá lõi daemon, mang chiến lợi phẩm thoát ra và mua nâng cấp vĩnh viễn giữa các nhiệm vụ.",
"Game khai khoáng tăng tiến với những chuyến thám hiểm ngắn. Lái giàn khoan, mang quặng về căn cứ, mở khóa tầng sâu hơn và dùng thu nhập từ mỗi chuyến đi để mua nâng cấp vĩnh viễn.",
"Game auto-battler nhàn rỗi, nơi đội hình chiến đấu liên tục. Tối ưu nâng cấp, kích hoạt kỹ năng chủ động của anh hùng và vượt qua các giai đoạn của trùm."],
}


CORES = {
'french': [
"Data Breach Inc. est un jeu d'action arcade à progression incrémentale où chaque mission vous fait pénétrer dans les infrastructures d'une entreprise hostile. Pilotez un engin de piratage, creusez le pare-feu pour en extraire des ressources, brisez les cœurs de daemons et échappez-vous avant que la situation ne dégénère. Investissez vos gains pour aller plus loin à la prochaine tentative.",
"Deepcore est un jeu minier incrémental fondé sur des expéditions souterraines courtes et intenses. Pilotez une foreuse dans un terrain destructible, extrayez du minerai et rapportez votre cargaison à l'anneau de la base avant la fin du temps imparti, l'usure de la foreuse ou la saturation de votre soute.",
"repose sur l'exploration des profondeurs, l'extraction et l'optimisation industrielle. Creusez toujours plus loin, récoltez des ressources de plus en plus précieuses et investissez-les pour étendre vos opérations sous terre. Améliorez vos cycles de production, augmentez le rendement et dépassez vos limites à mesure que votre exploitation grandit."],
'german': [
"Data Breach Inc. ist ein Arcade-Actionspiel mit inkrementellem Fortschritt. Dringe in riskanten Einsätzen in die Infrastruktur feindlicher Unternehmen ein. Steuere ein Hacking-Fahrzeug, baue Ressourcen aus der Firewall ab, knacke Daemon-Kerne und entkomme, bevor die Lage zu gefährlich wird. Investiere deinen Verdienst, um beim nächsten Einsatz tiefer vorzudringen.",
"Deepcore ist ein Incremental-Bergbauspiel mit kurzen, intensiven Expeditionen unter Tage. Steuere ein Bohrfahrzeug durch zerstörbares Gelände, baue Erz ab und bringe deine Ladung zum Basisring zurück, bevor die Zeit abläuft, der Bohrer verschlissen ist oder dein Frachtraum an seine Grenzen stößt.",
"dreht sich um den Vorstoß in die Tiefe, den Rohstoffabbau und die Optimierung deiner Industrie. Grabe tiefer, sammle immer wertvollere Ressourcen und investiere sie, um deinen gesamten Betrieb unter Tage auszubauen. Verbessere Abläufe und Durchsatz und überwinde neue Grenzen, während Bergbau und Produktion wachsen."],
'japanese': [
"Data Breach Inc.は、危険な任務を重ねて敵対企業のシステムに侵入する、インクリメンタル要素を備えたアーケードアクションです。侵入用マシンを操り、ファイアウォールを掘って資源を集め、デーモンコアを破壊。状況が悪化する前に脱出し、得た報酬で強化して、次はさらに奥を目指しましょう。",
"Deepcoreは、短く緊張感のある地下遠征を繰り返す採掘インクリメンタルゲームです。掘削マシンで破壊可能な地形を掘り進み、鉱石を採掘。制限時間が切れる前に、ドリルが摩耗しきる前に、そして積載量が限界になる前に、戦利品を基地のリングへ持ち帰りましょう。",
"は、地下への探索、資源の採掘、生産の効率化を楽しむゲームです。より深く掘り進み、価値の高い資源を集め、その収益で地下の事業を拡大。採掘と生産の規模が大きくなるにつれて、資源の循環を強化し、生産効率を高め、限界を突破していきましょう。"],
'koreana': [
"Data Breach Inc.는 위험한 임무를 거듭하며 적대 기업의 시스템을 뚫는 점진적 성장 아케이드 액션 게임입니다. 침투 장비를 조종해 방화벽에서 자원을 캐고, 데몬 코어를 파괴하세요. 상황이 위험해지기 전에 탈출하고, 수익을 강화에 투자해 다음에는 더 깊이 침투하세요.",
"Deepcore는 짧고 긴장감 넘치는 지하 탐사를 반복하는 점진적 성장 채굴 게임입니다. 굴착 장비를 조종해 파괴 가능한 지형을 뚫고 광석을 캐세요. 제한 시간이 끝나거나 드릴이 닳거나 적재 한도에 이르기 전에 수확물을 기지의 링으로 가져와야 합니다.",
"는 더 깊은 지하로 내려가 자원을 채굴하고 산업 시설을 최적화하는 게임입니다. 점점 더 귀중한 자원을 모아 사업 전체를 지하로 확장하는 시스템에 투자하세요. 채굴과 생산 규모를 키우며 자원 순환과 처리량을 개선하고 기존의 한계를 돌파하세요."],
'schinese': [
"Data Breach Inc. 是一款街机风格的增量动作游戏，你将在一次次高风险出击中突破敌对企业的基础设施。驾驶入侵装置，挖掘防火墙以获取资源，击破守护进程核心，并在局势恶化前带着收获撤离。把收益投入强化，让下一次入侵走得更深。",
"Deepcore 是一款围绕短途高压探险展开的增量采矿游戏。驾驶钻探装置穿越可破坏的地下地形，开采矿石，并在倒计时结束、钻头耗尽或货舱达到极限之前，将收获运回基地环。",
"以深入地下、开采资源和工业优化为核心。向地层深处挖掘，收集越来越珍贵的资源，并将其投入能让整个采矿事业继续向地下扩张的系统。随着开采与生产规模不断增长，优化资源循环、提高产能，逐步突破原有的限制。"],
'russian': [
"Data Breach Inc. — аркадный экшен с инкрементальным развитием, в котором вы проникаете в инфраструктуру враждебных корпораций, выполняя опасные вылазки. Управляйте машиной для взлома, добывайте ресурсы из фаервола, разрушайте ядра демонов и возвращайтесь до того, как ситуация выйдет из-под контроля. Вкладывайте заработанное в улучшения, чтобы в следующий раз пробраться глубже.",
"Deepcore — инкрементальная игра о добыче руды в коротких напряжённых экспедициях. Управляйте буровой машиной в разрушаемых подземельях, добывайте руду и доставляйте груз к кольцу базы, пока не истекло время, не износился бур или не был достигнут предел грузоподъёмности.",
"посвящена освоению глубин, добыче ресурсов и оптимизации производства. Бурите всё глубже, собирайте всё более ценные ресурсы и вкладывайте их в системы, расширяющие ваше предприятие под землёй. Совершенствуйте производственные циклы, увеличивайте пропускную способность и преодолевайте ограничения по мере роста добычи и производства."],
'thai': [
"Data Breach Inc. เป็นเกมแอ็กชันอาร์เคดแบบสะสมพลังที่ให้คุณบุกโครงสร้างระบบของบริษัทศัตรูผ่านภารกิจเสี่ยงอันตราย บังคับเครื่องเจาะระบบ ขุดไฟร์วอลล์เพื่อเก็บทรัพยากร ทำลายแกนเดมอน แล้วถอนตัวก่อนสถานการณ์จะเลวร้าย นำรายได้ไปอัปเกรดเพื่อบุกได้ลึกขึ้นในครั้งต่อไป",
"Deepcore เป็นเกมขุดแร่แบบสะสมพลังที่เน้นการสำรวจใต้ดินระยะสั้นแต่กดดัน บังคับรถเจาะผ่านภูมิประเทศที่ทำลายได้ ขุดแร่ แล้วขนกลับมายังวงแหวนฐานก่อนหมดเวลา หัวเจาะสึกจนใช้งานไม่ได้ หรือถึงขีดจำกัดการบรรทุก",
"เน้นการลงลึกใต้ดิน การขุดทรัพยากร และการเพิ่มประสิทธิภาพอุตสาหกรรม ขุดให้ลึกขึ้น เก็บทรัพยากรที่มีค่ามากขึ้น แล้วลงทุนในระบบที่ช่วยขยายกิจการทั้งหมดลงไปใต้ดิน พัฒนาวงจรการผลิต เพิ่มกำลังผลิต และก้าวข้ามข้อจำกัดเมื่อขนาดการขุดและการผลิตเติบโตขึ้น"],
}

TERMS = {
'french': [('industrie clandestine','industrie souterraine'),('incrémentielle','incrémentale'),('incrémentiels','incrémentaux'),('noyaux de démons','cœurs de daemons'),('noyau de démon','cœur de daemon'),('vos mises à niveau','vos améliorations'),('chaque mise à niveau','chaque amélioration'),('leurs effectifs','leur puissance')],
'german': [('Rüsten du deine','Rüste deine'),('Verwalten du deine','Verwalte deine'),('Investieren du deine Einnahmen in permanente Upgrades und unterstützen Sie Drohnen','Investiere deinen Verdienst in dauerhafte Upgrades und Unterstützungsdrohnen')],
'italian': [('industria clandestina','industria sotterranea'),('nuclei dei demoni','nuclei dei daemon'),('nuclei demoniaci','nuclei dei daemon'),('ogni aggiornamento','ogni potenziamento')],
'spanish': [('industria clandestina','industria subterránea'),('Irrumpir en infraestructura corporativa hostil a través de misiones peligrosas.','Infiltra las infraestructuras de empresas hostiles en misiones peligrosas.'),('núcleos de demonios','núcleos de daemons'),('tu transporte de regreso','tu cargamento de regreso'),('cada actualización','cada mejora')],
'czech': [('postupným postupem','inkrementálním postupem'),('postupným progresem','inkrementálním postupem'),('trvalou postupnou progresí','trvalým inkrementálním postupem'),('přírůstkových her','inkrementálních her'),('svůj zátah','svůj náklad')],
'indonesian': [('permainan tambahan','game inkremental'),('hasil tangkapan Anda','hasil tambang Anda'),('perkembangan bertahap','perkembangan inkremental')],
'japanese': [('永久アップグレード','永続強化'),('増分ゲーム','インクリメンタルゲーム'),('増分エクスペリエンス','インクリメンタルゲーム体験'),('永続的な増分進行','永続的な成長'),('メッキ','装甲'),('各フライト','各出撃'),('リソース パス','資源の種類')],
'koreana': [('활성 능력','액티브 능력'),('활성 능력을','액티브 능력을'),('영구적인 증분 진행','영구적인 성장'),('증분 게임','점진적 성장 게임'),('증분 경험','점진적 성장 경험')],
'polish': [('opiera się na pochodzeniu','skupia się na schodzeniu coraz głębiej'),('rdzenie demonów','rdzenie daemonów')],
'portuguese': [('indústria clandestina','indústria subterrânea'),('atualizações permanentes','melhorias permanentes'),('traga o seu transporte','traga a sua carga')],
'brazilian': [('indústria clandestina','indústria subterrânea'),('atualizações permanentes','melhorias permanentes'),('traga seu transporte','traga sua carga')],
'russian': [('Data Breach Inc..','Data Breach Inc.'),('дополнительных игр','инкрементальных игр'),('добычу полезных ископаемых, передвижение, выживание и добычу полезных ископаемых','добычу ресурсов, передвижение, выживание и эвакуацию')],
'schinese': [('主线活动','主线战役'),('广告系列','战役'),('渐进式防御游戏','增量防御游戏')],
'thai': [('การสาธิต','เดโม'),('ปฏิบัติการด้านข้าง','ภารกิจเสริม'),('เกมที่เพิ่มขึ้นอย่างสมบูรณ์ห้าเกม','เกมสะสมพลังฉบับเต็มห้าเกม'),('บันทึกการต่อสู้ที่ยากลำบาก','กอบกู้สถานการณ์ในการต่อสู้ที่ยากลำบาก')],
'turkish': [],
'vietnamese': [('thiệt hại','sát thương'),('khai thác, di chuyển, sinh tồn và khai thác','khai thác, di chuyển, sinh tồn và rút lui')],
}

# Genre labels are gaming terms, not literal inactivity or fighter aircraft.
LABELS = {
'french': ['Auto-battlers','Progression idle et incrémentale'],
'german': ['Auto-Battler','Idle- und Incremental-Fortschritt'],
'italian': ['Auto-battler','Progressione idle e incrementale'],
'spanish': ['Auto-battlers','Progresión idle e incremental'],
'czech': ['Automatické souboje','Idle a inkrementální postup'],
'indonesian': ['Auto-battler','Progres idle dan inkremental'],
'japanese': ['オートバトラー','放置とインクリメンタルな成長'],
'koreana': ['오토 배틀러','방치형 게임과 점진적 성장'],
'polish': ['Auto-battlery','Rozwój bezczynnościowy i przyrostowy'],
'portuguese': ['Auto-battlers','Progressão idle e incremental'],
'brazilian': ['Auto-battlers','Progressão idle e incremental'],
'russian': ['Автобаттлеры','Idle-игры и инкрементальное развитие'],
'schinese': ['自动战斗游戏','放置与增量成长'],
'thai': ['เกมต่อสู้อัตโนมัติ','การเติบโตแบบไอเดิลและสะสมพลัง'],
'turkish': ['Auto-battler oyunları','Idle ve artımlı ilerleme'],
'vietnamese': ['Auto-battler','Tiến trình nhàn rỗi và tăng tiến'],
}


PREFIX_EDITS = {
'japanese': {
 'Each flight': '各出撃では、アクションと強化の戦略が試されます。安全な道を掘るか、価値の高いブロックを狙うか、デーモンコアを攻めるか、それとも早めに帰還して戦利品を確保するか。資金、XP、ルートカーネルを使い、攻撃力、攻撃速度、積載量、燃料、ドローン、射程、収益、コアへの攻撃力を永続的に強化しましょう。',
 'The firewall': 'ファイアウォールも黙ってはいません。深い層ほど危険が増し、デーモンコアは反撃してきます。敵の防衛を突破するには、単調な資源集めより効率的なルート選びが重要。地形を覚え、侵入用マシンを強化し、回収と脱出をより素早くこなしましょう。',
 'In the demo': '体験版では侵入チャレンジのクリアを目指し、Defeat Demoランキングでより良いタイムに挑戦できます。Data Breach Inc.の製品版では、Red Sky DefenseやDeepcoreなどのサブ作戦もメインのキャンペーンと連動。そこで獲得した資源や解放要素が、中心となる侵入作戦に役立ちます。',
},
'koreana': {
 'Each flight': '매 출격은 액션과 강화 전략을 함께 시험합니다. 안전한 경로를 뚫거나, 값진 블록을 노리거나, 데몬 코어를 공격하거나, 일찍 돌아와 전리품을 확보하세요. 돈, XP, 루트 커널을 사용해 공격력, 공격 속도, 적재량, 연료, 드론, 사거리, 수익, 코어 공격력을 영구적으로 강화할 수 있습니다.',
 'The firewall': '방화벽도 가만히 있지 않습니다. 깊은 층일수록 위험해지고 데몬 코어는 반격합니다. 적의 방어를 뚫으려면 무작정 자원을 모으기보다 효율적인 경로가 필요합니다. 지형을 익히고 침투 장비를 강화해 자원 회수와 탈출을 더 빠르게 완수하세요.',
 'In the demo': '데모에서는 침투 도전을 완료하고 Defeat Demo 순위표에서 더 빠른 기록에 도전할 수 있습니다. Data Breach Inc. 정식 버전의 캠페인에는 Red Sky Defense와 Deepcore 같은 부가 작전도 연결됩니다. 해당 작전에서 얻은 자원과 해금 요소는 중심이 되는 침투 작전에 도움이 됩니다.',
},
'schinese': {
 'Each flight': '每次出击都结合了动作挑战与强化策略。你可以开辟安全路线、追逐高价值方块、猛攻守护进程核心，或提前返航保住收获。使用金钱、XP 和根内核，永久提升伤害、攻击速度、货舱容量、燃料、无人机、射程、收益以及对核心的破坏力。',
 'The firewall': '防火墙不会坐以待毙。越深的地层威胁越大，守护进程核心会发起反击，层层防御要求你规划高效路线，而不是一味重复刷取资源。熟悉布局、调整入侵装置，让每次资源回收与撤离都更加干净利落。',
 'In the demo': '试玩版以完成入侵挑战为目标，你还可以在 Defeat Demo 排行榜上追求更快的通关时间。Data Breach Inc. 完整版的战役还串联了 Red Sky Defense 和 Deepcore 等支线行动。这些行动中获得的资源与解锁内容将反哺核心入侵任务。',
},
'thai': {
 'Each flight': 'การออกบินแต่ละครั้งผสมทั้งแอ็กชันและการวางแผนอัปเกรด คุณเลือกได้ว่าจะเสี่ยงแค่ไหน จะเจาะทางที่ปลอดภัย ไล่เก็บบล็อกมีค่า โจมตีแกนเดมอน หรือกลับก่อนเพื่อรักษาของที่ได้มา ใช้เงิน XP และรูทเคอร์เนลอัปเกรดความเสียหาย ความเร็วโจมตี ความจุบรรทุก เชื้อเพลิง โดรน ระยะโจมตี รายได้ และพลังทำลายแกนอย่างถาวร',
 'The firewall': 'ไฟร์วอลล์ไม่ได้อยู่นิ่ง ชั้นที่ลึกขึ้นมีอันตรายมากขึ้น แกนเดมอนจะตอบโต้ และการป้องกันของศัตรูบังคับให้คุณเลือกเส้นทางอย่างมีประสิทธิภาพแทนการเก็บทรัพยากรซ้ำไปมา เรียนรู้ผังพื้นที่ ปรับแต่งเครื่องเจาะระบบ แล้วเก็บทรัพยากรและถอนตัวให้รวดเร็วกว่าเดิม',
 'In the demo': 'ในเดโม คุณจะต้องผ่านภารกิจเจาะระบบและพยายามทำเวลาให้ดีขึ้นบนกระดานผู้นำ Defeat Demo ส่วนแคมเปญ Data Breach Inc. ฉบับเต็มยังเชื่อมกับภารกิจเสริมอย่าง Red Sky Defense และ Deepcore ทรัพยากรและสิ่งที่ปลดล็อกจากภารกิจเหล่านั้นจะช่วยเสริมการเจาะระบบหลัก',
},
'german': {
 'Drive the drilling vehicle.': 'Steuere das Bohrfahrzeug. Bringe dein Erz zur Basis. Verbessere deine Ausrüstung für die nächste Expedition.',
 'Manage your power resource': 'Verwalte deine Energieressource für mächtige aktive Fähigkeiten',
 '• Drive a drilling vehicle': '• Steuere ein Bohrfahrzeug durch zerstörbares Gelände unter Tage\n• Behalte Zeitlimit, Bohrerverschleiß und Ladekapazität im Blick\n• Bringe Erz zur Basis und erhalte Geld sowie XP\n• Erschließe tiefere Schichten mit härterem Gestein und besseren Belohnungen\n• Investiere Erträge in dauerhafte Upgrades und Unterstützungsdrohnen',
},
}

TIMING = {
'french': 'Un objectif de victoire dans la démo, avec un temps enregistré pour le classement',
'german': 'Eine Demo-Abschlussherausforderung mit Zeitmessung für die Bestenliste',
'italian': 'Una sfida da completare nella demo, con tempi registrati in classifica',
'spanish': 'Un objetivo de completar la demo con tiempos registrados en la clasificación',
'czech': 'Výzva k dokončení dema s měřením času pro žebříček',
'indonesian': 'Tantangan menamatkan demo dengan catatan waktu untuk papan peringkat',
'japanese': 'クリアタイムをランキングで競える体験版の攻略チャレンジ',
'koreana': '완료 시간을 순위표에서 겨루는 데모 도전',
'polish': 'Cel ukończenia dema z pomiarem czasu do rankingu',
'portuguese': 'Um desafio para concluir a demo, com tempos registados na classificação',
'brazilian': 'Um desafio para concluir a demo, com tempos registrados na classificação',
'russian': 'Задача пройти демоверсию с учётом времени для таблицы лидеров',
'schinese': '以通关试玩版为目标，并记录时间参与排行榜',
'thai': 'เป้าหมายผ่านเดโมพร้อมจับเวลาเพื่อแข่งขันบนกระดานผู้นำ',
'turkish': 'Skor tablosu için süresi kaydedilen demo tamamlama hedefi',
'vietnamese': 'Thử thách hoàn thành bản demo với thời gian được ghi vào bảng xếp hạng',
}


def review_drafts():
    for language in SHORTS:
        path=OUT/(language+'_draft.json')
        data=json.loads(path.read_text(encoding='utf8'))
        if language in CORES:
            for prefix,value in zip(['Data Breach Inc. is','Deepcore is','is built around'],CORES[language]):
                matches=[k for k in data if k.startswith(prefix)]
                assert len(matches)==1,(language,prefix)
                data[matches[0]]=value
        data['Auto battlers'],data['Idle and incremental progression']=LABELS[language]
        data['- A demo completion challenge with timed leaderboard results']='- '+TIMING[language]
        for prefix,value in PREFIX_EDITS.get(language,{}).items():
            for key in data:
                if key.startswith(prefix): data[key]=value
        for key,value in data.items():
            for before,after in TERMS[language]: value=value.replace(before,after)
            data[key]=value.replace('\u200b','')
        path.write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8')


def finish():
    review_drafts()
    build()
    report=[]
    for row in json.loads((OUT/'catalog.json').read_text()):
        if not row.get('download'): continue
        itemid=row['itemid']
        path=OUT/(itemid+'_upload.json')
        data=json.loads(path.read_text(encoding='utf8'))
        source=json.loads((OUT/(itemid+'_before.json')).read_text(encoding='utf8'))['languages']['english']
        title_index={'1161426':0,'1169911':1,'1142593':2,'1156144':2,'1130923':3}.get(itemid)
        for language,fields in data['languages'].items():
            if title_index is not None:
                fields[SHORT]=SHORTS[language][title_index]
            for key,value in list(fields.items()):
                # Normalize translated list line breaks without losing bullets.
                value=re.sub(r'[\r\n]+','\n',value)
                fields[key]=value
                assert value.strip(), (itemid,language,key,'empty')
                assert TAGS.findall(value)==TAGS.findall(source[key]), (itemid,language,key,'markup')
                assert not re.search(r'RFW|WFR|RFP\d',value), (itemid,language,'placeholder')
                if key==SHORT:
                    assert len(value)<=300,(itemid,language,len(value),'length')
                if key==ABOUT:
                    assert value.count('•')==source[key].count('•'),(itemid,language,'bullets')
                    for brand in BRANDS:
                        assert value.count(brand)==source[key].count(brand),(itemid,language,brand,'title')
        path.write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8')
        report.append({'itemid':itemid,'title':row['name'],'languages':len(data['languages']),
                       'fields':sum(map(len,data['languages'].values()))})
    (OUT/'prepared.json').write_text(json.dumps(report,indent=2),encoding='utf8')
    print(json.dumps(report,indent=2))


if __name__=='__main__': finish()
