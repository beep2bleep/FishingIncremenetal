"""Apply editorial translations to store copy, then rebuild upload packages."""
import json
import re
from localize_store import OUT, ABOUT, SHORT, package


def apply(language, main, demo, main_short, demo_short):
    path = OUT / f'{language}.json'
    data = json.loads(path.read_text(encoding='utf-8'))
    for kind, paragraphs, short in [('main', main, main_short), ('demo', demo, demo_short)]:
        data[kind][ABOUT] = ''.join(f'[p]{p}[/p]' for p in paragraphs.strip().split('\n\n'))
        data[kind][SHORT] = short
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')


apply('french', '''Frayez-vous un chemin sur une voie ferrée maudite, conservez votre butin et revenez plus fort. Railway Fury est un jeu d'action incrémental à la première personne où votre visée, vos déplacements latéraux et le choix de vos améliorations font la différence.

À chaque tentative, cherchez à vaincre un ennemi de plus, à gagner davantage et à avancer encore un peu. Esquivez les projectiles ennemis et les vagues de feu mobiles, récupérez vos récompenses et achetez des améliorations permanentes pour aller toujours plus loin.

PROGRESSEZ GRÂCE AUX AMÉLIORATIONS

Dépensez votre or, vos gemmes et vos couronnes dans un arbre d'améliorations à embranchements. Renforcez votre arbalète, votre santé, votre armure, votre portée de collecte et vos pouvoirs. Débloquez des dagues qui reviennent vers vous et des armes surnaturelles, puis choisissez les améliorations qui vous mèneront plus loin à la prochaine tentative.

QUATRE VOIES FERRÉES À CONQUÉRIR

Battez les boss et traversez un donjon oublié, une citadelle médiévale, une voie ferrée au cœur d'une forêt sauvage et une descente infernale. Chaque niveau propose un nouveau décor et des dangers plus redoutables. Des améliorations vous aideront à surmonter les obstacles de feu.

FAITES COMPTER CHAQUE TENTATIVE

Réclamez les récompenses des succès pour obtenir des ressources supplémentaires, activez vos pouvoirs au bon moment et équilibrez dégâts, survie et revenus. Votre temps de jeu actif en expédition est comptabilisé au fil de votre progression vers les boss et la fin. Achevez votre parcours d'améliorations pour accéder à l'un des deux choix finaux.

Commandes : déplacez-vous à gauche et à droite, visez avec la souris, cliquez pour tirer et appuyez sur Espace pour utiliser votre prochain pouvoir disponible. Maintenez Maj pour doubler la vitesse lorsque vous êtes assez fort pour prendre ce risque.''', '''Lancez vos premières expéditions dans Railway Fury, un jeu d'action incrémental à la première personne où vous avancez toujours plus loin sur une voie ferrée maudite. Visez avec votre arbalète, esquivez les ennemis et les vagues de feu en vous déplaçant latéralement, récupérez du butin et investissez vos gains dans des améliorations permanentes.

La démo comprend la première voie ferrée et son boss. Renforcez vos dégâts, votre santé, votre armure et vos pouvoirs au fil des tentatives. Réclamez les récompenses des succès pour obtenir davantage de ressources d'amélioration. La démo se termine après le premier boss ; les niveaux suivants et les améliorations achetées avec des couronnes sont réservés au jeu complet.

Déplacez-vous à gauche et à droite, visez avec la souris, cliquez pour tirer et appuyez sur Espace pour activer votre prochain pouvoir disponible. Maintenez Maj pour doubler la vitesse lorsque vous êtes prêt à prendre ce risque supplémentaire.

MODE DÉMO

La démo utilise une sauvegarde distincte de celle du jeu complet. La version complète prolonge l'aventure avec quatre voies ferrées thématiques, un arbre d'améliorations plus vaste, des boss plus coriaces et deux fins.''',
"Visez, esquivez et tirez sur une voie ferrée maudite dans ce jeu d'action incrémental. Évitez les vagues de feu, amassez du butin et achetez des améliorations permanentes. Affrontez les boss de quatre niveaux thématiques et progressez vers deux fins.",
"Découvrez la première voie ferrée et son boss dans cette démo d'action incrémentale à la première personne. Tirez à l'arbalète, esquivez les vagues de feu et améliorez-vous. La démo s'arrête après le premier boss et possède sa propre sauvegarde.")

apply('german', '''Kämpfe dich über eine verfluchte Eisenbahnstrecke, behalte deine Beute und kehre stärker zurück. Railway Fury ist ein inkrementelles Actionspiel aus der Egoperspektive, in dem Zielen, seitliches Ausweichen und die Wahl deines nächsten Upgrades zählen.

In jedem Durchlauf willst du einen weiteren Gegner besiegen, mehr Beute machen und ein Stück weiterkommen. Weiche gegnerischen Geschossen und wandernden Feuerwellen aus, sammle Belohnungen und verwandle mit dauerhaften Upgrades kurze Versuche in immer längere Expeditionen.

BAHNE DIR MIT UPGRADES DEINEN WEG

Gib Gold, Edelsteine und Kronen in einem verzweigten Upgrade-Baum aus. Verbessere deine Armbrust, Gesundheit, Rüstung, Sammelreichweite und Kräfte. Schalte zurückkehrende Dolche und übernatürliche Waffen frei und entscheide, welche Upgrades dich im nächsten Durchlauf weiterbringen.

VIER EISENBAHNSTRECKEN ZU EROBERN

Besiege Bosse und durchquere ein vergessenes Verlies, eine mittelalterliche Zitadelle, eine wilde Waldstrecke und einen höllischen Abstieg. Jeder Level bietet neue Schauplätze und größere Gefahren. Upgrades zum Umgang mit Feuer helfen dir dabei, weiter vorzudringen.

NUTZE JEDEN DURCHLAUF

Hole dir zusätzliche Ressourcen durch Erfolge, aktiviere deine Kräfte im richtigen Moment und finde die Balance zwischen Schaden, Überleben und Einkommen. Deine aktive Spielzeit in den Durchläufen wird auf deinem Weg zu den Bossen und zum Ende erfasst. Schließe deine Upgrade-Reise ab und erreiche eine von zwei abschließenden Entscheidungen.

Steuerung: Bewege dich nach links und rechts, ziele mit der Maus, klicke zum Schießen und drücke die Leertaste, um deine nächste bereite Kraft einzusetzen. Halte die Umschalttaste für doppeltes Tempo gedrückt, sobald du stark genug für das Risiko bist.''', '''Starte deine ersten Durchläufe in Railway Fury, einem inkrementellen Actionspiel aus der Egoperspektive, in dem du immer weiter über eine verfluchte Eisenbahnstrecke vordringst. Ziele mit deiner Armbrust, weiche Gegnern und Feuerwellen seitlich aus, sammle Beute und investiere deine Einnahmen in dauerhafte Upgrades.

Die Demo enthält die erste Strecke samt Boss. Steigere über mehrere Durchläufe deinen Schaden, deine Gesundheit, deine Rüstung und deine Kräfte. Hole dir durch Erfolge zusätzliche Ressourcen für Upgrades. Die Demo endet nach dem ersten Boss; spätere Level und Kronen-Upgrades sind der Vollversion vorbehalten.

Bewege dich nach links und rechts, ziele mit der Maus, klicke zum Schießen und drücke die Leertaste, um deine nächste bereite Kraft zu aktivieren. Halte die Umschalttaste für doppeltes Tempo gedrückt, wenn du bereit für das zusätzliche Risiko bist.

DEMO-MODUS

Die Demo verwendet einen eigenen, von der Vollversion getrennten Spielstand. Die Vollversion erweitert die Reise um vier thematische Eisenbahnstrecken, einen größeren Upgrade-Baum, stärkere Bosse und zwei Enden.''',
"Ziele, weiche aus und schieße dich in diesem inkrementellen Actionspiel über eine verfluchte Bahnstrecke. Meide Feuerwellen, sammle Beute und kaufe dauerhafte Upgrades. Besiege Bosse in vier thematischen Levels und arbeite auf zwei Enden hin.",
"Erlebe die erste Bahnstrecke samt Boss in dieser inkrementellen Ego-Action-Demo. Ziele mit der Armbrust, weiche Feuerwellen aus und kaufe dauerhafte Upgrades. Die Demo endet nach dem ersten Boss und nutzt einen eigenen Spielstand.")

apply('spanish', '''Ábrete paso por una vía férrea maldita, conserva tu botín y vuelve más fuerte. Railway Fury es un juego de acción incremental en primera persona donde importan tu puntería, tus movimientos laterales y la elección de tu próxima mejora.

En cada incursión, intenta derrotar a un enemigo más, conseguir una recompensa más y avanzar un tramo más. Esquiva los proyectiles enemigos y las oleadas de fuego en movimiento, recoge las recompensas y usa mejoras permanentes para convertir un intento fugaz en una expedición cada vez más larga.

AVANZA CON TUS MEJORAS

Gasta oro, gemas y coronas en un árbol de mejoras con distintas ramas. Mejora tu ballesta, tu salud, tu armadura, tu alcance de recogida y tus poderes. Desbloquea dagas que regresan a ti y armas sobrenaturales, y decide qué mejoras te llevarán más lejos en tu próxima incursión.

CUATRO VÍAS FÉRREAS QUE CONQUISTAR

Derrota a los jefes y atraviesa una mazmorra olvidada, una ciudadela medieval, una vía férrea en un bosque salvaje y un descenso infernal. Cada nivel presenta un nuevo escenario y peligros más difíciles, con mejoras para afrontar el fuego y seguir avanzando.

HAZ QUE CADA INCURSIÓN CUENTE

Reclama las recompensas de los logros para obtener recursos adicionales, activa tus poderes cuando los necesites y equilibra daño, supervivencia e ingresos. Tu tiempo de juego activo durante las incursiones se registra mientras avanzas hacia los jefes y el final. Completa tu recorrido de mejoras para llegar a una de las dos decisiones finales.

Controles: muévete a izquierda y derecha, apunta con el ratón, haz clic para disparar y pulsa Espacio para usar tu siguiente poder disponible. Mantén pulsada Mayús para duplicar la velocidad cuando seas lo bastante fuerte para asumir el riesgo.''', '''Empieza tus primeras incursiones en Railway Fury, un juego de acción incremental en primera persona donde avanzarás cada vez más por una vía férrea maldita. Apunta con tu ballesta, desplázate lateralmente para esquivar enemigos y oleadas de fuego, recoge botín y gasta tus ganancias en mejoras permanentes.

La demo incluye la primera vía férrea y su jefe. Aumenta tu daño, salud, armadura y poderes a lo largo de varias incursiones, y reclama las recompensas de los logros para conseguir más recursos de mejora. La demo termina tras el primer jefe; los niveles posteriores y las mejoras de coronas están reservados al juego completo.

Muévete a izquierda y derecha, apunta con el ratón, haz clic para disparar y pulsa Espacio para activar tu siguiente poder disponible. Mantén pulsada Mayús para duplicar la velocidad cuando estés preparado para el riesgo adicional.

MODO DEMO

La demo utiliza una partida guardada independiente de la del juego completo. La versión completa amplía el viaje con cuatro vías férreas temáticas, un árbol de mejoras más grande, jefes más difíciles y dos finales.''',
"Apunta, esquiva y dispara por una vía férrea maldita en este juego de acción incremental. Evita oleadas de fuego, recoge botín y compra mejoras permanentes entre incursiones. Derrota a los jefes de cuatro niveles temáticos y avanza hacia dos finales.",
"Prueba la primera vía férrea y su jefe en esta demo de acción incremental en primera persona. Apunta con tu ballesta, esquiva oleadas de fuego y compra mejoras permanentes. La demo termina tras el primer jefe y tiene su propia partida guardada.")

apply('italian', '''Fatti strada lungo una ferrovia maledetta, conserva il bottino e torna più forte. Railway Fury è un gioco d'azione incrementale in prima persona in cui contano la mira, i movimenti laterali e la scelta del prossimo potenziamento.

Ogni spedizione è l'occasione per abbattere un nemico in più, ottenere un'altra ricompensa e percorrere un altro tratto di binari. Schiva i proiettili nemici e le ondate di fuoco in movimento, raccogli le ricompense e usa potenziamenti permanenti per trasformare un breve tentativo in una spedizione sempre più lunga.

AVANZA GRAZIE AI POTENZIAMENTI

Spendi oro, gemme e corone in un albero dei potenziamenti ramificato. Migliora balestra, salute, armatura, raggio di raccolta e poteri. Sblocca pugnali che tornano da te e armi soprannaturali, poi scegli i potenziamenti che ti porteranno più lontano nella prossima spedizione.

QUATTRO FERROVIE DA CONQUISTARE

Sconfiggi i boss e attraversa un sotterraneo dimenticato, una cittadella medievale, una ferrovia in una foresta selvaggia e una discesa infernale. Ogni livello offre una nuova ambientazione e pericoli più insidiosi, con potenziamenti per affrontare il fuoco e continuare ad avanzare.

FAI CONTARE OGNI SPEDIZIONE

Riscatta le ricompense degli obiettivi per ottenere risorse extra, attiva i poteri quando servono e bilancia danni, sopravvivenza e guadagni. Il tempo di gioco attivo nelle spedizioni viene registrato mentre avanzi verso i boss e il finale. Completa il percorso dei potenziamenti per raggiungere una delle due scelte finali.

Comandi: muoviti a sinistra e a destra, mira con il mouse, fai clic per sparare e premi Spazio per usare il prossimo potere disponibile. Tieni premuto Maiusc per raddoppiare la velocità quando sei abbastanza forte da correre il rischio.''', '''Inizia le tue prime spedizioni in Railway Fury, un gioco d'azione incrementale in prima persona in cui ti spingi sempre più lontano lungo una ferrovia maledetta. Mira con la balestra, spostati lateralmente per schivare nemici e ondate di fuoco, raccogli bottino e investi i guadagni in potenziamenti permanenti.

La demo include la prima ferrovia e il suo boss. Aumenta danni, salute, armatura e poteri nel corso di più spedizioni e riscatta le ricompense degli obiettivi per ottenere risorse aggiuntive. La demo termina dopo il primo boss; i livelli successivi e i potenziamenti con le corone sono riservati al gioco completo.

Muoviti a sinistra e a destra, mira con il mouse, fai clic per sparare e premi Spazio per attivare il prossimo potere disponibile. Tieni premuto Maiusc per raddoppiare la velocità quando sei pronto ad affrontare il rischio aggiuntivo.

MODALITÀ DEMO

La demo usa un salvataggio separato da quello del gioco completo. La versione completa amplia il viaggio con quattro ferrovie a tema, un albero dei potenziamenti più vasto, boss più difficili e due finali.''',
"Mira, schiva e spara lungo una ferrovia maledetta in questo gioco d'azione incrementale. Evita ondate di fuoco, raccogli bottino e compra potenziamenti permanenti tra le spedizioni. Sconfiggi i boss di quattro livelli a tema e avanza verso due finali.",
"Prova la prima ferrovia e il suo boss in questa demo d'azione incrementale in prima persona. Mira con la balestra, schiva ondate di fuoco e compra potenziamenti permanenti. La demo termina dopo il primo boss e usa un salvataggio separato.")

apply('portuguese', '''Abre caminho por uma linha férrea amaldiçoada, guarda o teu saque e regressa mais forte. Railway Fury é um jogo de ação incremental na primeira pessoa em que a pontaria, os movimentos laterais e a escolha da próxima melhoria fazem a diferença.

Em cada incursão, tenta derrotar mais um inimigo, obter mais uma recompensa e percorrer mais um troço de carris. Desvia-te dos projéteis inimigos e das ondas de fogo em movimento, recolhe as recompensas e usa melhorias permanentes para transformar uma tentativa breve numa expedição cada vez mais longa.

AVANÇA COM MELHORIAS

Gasta ouro, gemas e coroas numa árvore de melhorias ramificada. Melhora a tua besta, vida, armadura, alcance de recolha e poderes. Desbloqueia adagas que regressam a ti e armas sobrenaturais, depois escolhe as melhorias que te levarão mais longe na próxima incursão.

QUATRO LINHAS FÉRREAS PARA CONQUISTAR

Derrota os bosses e atravessa uma masmorra esquecida, uma cidadela medieval, uma linha férrea numa floresta selvagem e uma descida infernal. Cada nível apresenta um novo cenário e perigos mais difíceis, com melhorias para enfrentar o fogo e continuar a avançar.

FAZ CADA INCURSÃO VALER A PENA

Reclama as recompensas das proezas para obter recursos extra, ativa os poderes quando precisares e equilibra dano, sobrevivência e rendimentos. O teu tempo de jogo ativo nas incursões é registado enquanto avanças até aos bosses e ao final. Completa o percurso de melhorias para chegar a uma das duas escolhas finais.

Controlos: move-te para a esquerda e para a direita, aponta com o rato, clica para disparar e prime Espaço para usar o próximo poder disponível. Mantém Shift premido para duplicar a velocidade quando fores suficientemente forte para correr o risco.''', '''Começa as tuas primeiras incursões em Railway Fury, um jogo de ação incremental na primeira pessoa em que avanças cada vez mais por uma linha férrea amaldiçoada. Aponta com a besta, move-te lateralmente para evitar inimigos e ondas de fogo, recolhe saque e investe os ganhos em melhorias permanentes.

A demo inclui a primeira linha férrea e o respetivo boss. Aumenta o dano, a vida, a armadura e os poderes ao longo de várias incursões e reclama as recompensas das proezas para obter mais recursos. A demo termina depois do primeiro boss; os níveis seguintes e as melhorias com coroas estão reservados ao jogo completo.

Move-te para a esquerda e para a direita, aponta com o rato, clica para disparar e prime Espaço para ativar o próximo poder disponível. Mantém Shift premido para duplicar a velocidade quando estiveres preparado para o risco adicional.

MODO DEMO

A demo usa um ficheiro de gravação separado do jogo completo. A versão completa expande a viagem com quatro linhas férreas temáticas, uma árvore de melhorias maior, bosses mais difíceis e dois finais.''',
"Aponta, desvia-te e dispara numa linha férrea amaldiçoada neste jogo de ação incremental. Evita ondas de fogo, recolhe saque e compra melhorias permanentes entre incursões. Derrota bosses em quatro níveis temáticos e avança rumo a dois finais.",
"Experimenta a primeira linha férrea e o seu boss nesta demo de ação incremental na primeira pessoa. Usa a besta, evita ondas de fogo e compra melhorias permanentes. A demo termina após o primeiro boss e usa um ficheiro de gravação separado.")

apply('catalan', '''Obre't pas per una via fèrria maleïda, conserva el botí i torna més fort. Railway Fury és un joc d'acció incremental en primera persona en què importen la punteria, els moviments laterals i l'elecció de la pròxima millora.

A cada incursió, intenta derrotar un enemic més, aconseguir una recompensa més i avançar un tram més de via. Esquiva els projectils enemics i les onades de foc en moviment, recull les recompenses i fes servir millores permanents per convertir un intent breu en una expedició cada cop més llarga.

AVANÇA AMB LES MILLORES

Gasta or, gemmes i corones en un arbre de millores ramificat. Millora la ballesta, la salut, l'armadura, l'abast de recollida i els poders. Desbloqueja dagues que tornen cap a tu i armes sobrenaturals, i tria les millores que et portaran més lluny a la pròxima incursió.

QUATRE VIES FÈRRIES PER CONQUERIR

Derrota els caps i travessa una masmorra oblidada, una ciutadella medieval, una via fèrria en un bosc salvatge i un descens infernal. Cada nivell ofereix un nou escenari i perills més difícils, amb millores per afrontar el foc i continuar avançant.

FES QUE CADA INCURSIÓ COMPTI

Reclama les recompenses dels assoliments per obtenir recursos addicionals, activa els poders quan els necessitis i equilibra dany, supervivència i ingressos. El temps de joc actiu durant les incursions queda registrat mentre avances cap als caps i el final. Completa el recorregut de millores per arribar a una de les dues decisions finals.

Controls: mou-te a esquerra i dreta, apunta amb el ratolí, fes clic per disparar i prem Espai per utilitzar el pròxim poder disponible. Mantén premuda Maj per duplicar la velocitat quan siguis prou fort per assumir el risc.''', '''Comença les primeres incursions a Railway Fury, un joc d'acció incremental en primera persona en què avances cada cop més per una via fèrria maleïda. Apunta amb la ballesta, mou-te lateralment per esquivar enemics i onades de foc, recull botí i inverteix els guanys en millores permanents.

La demo inclou la primera via fèrria i el seu cap. Augmenta el dany, la salut, l'armadura i els poders al llarg de diverses incursions, i reclama les recompenses dels assoliments per obtenir més recursos. La demo acaba després del primer cap; els nivells posteriors i les millores amb corones estan reservats al joc complet.

Mou-te a esquerra i dreta, apunta amb el ratolí, fes clic per disparar i prem Espai per activar el pròxim poder disponible. Mantén premuda Maj per duplicar la velocitat quan estiguis preparat per al risc addicional.

MODE DEMO

La demo fa servir una partida desada independent de la del joc complet. La versió completa amplia el viatge amb quatre vies fèrries temàtiques, un arbre de millores més gran, caps més difícils i dos finals.''',
"Apunta, esquiva i dispara per una via fèrria maleïda en aquest joc d'acció incremental. Evita onades de foc, recull botí i compra millores permanents entre incursions. Derrota els caps de quatre nivells temàtics i avança cap a dos finals.",
"Prova la primera via fèrria i el seu cap en aquesta demo d'acció incremental en primera persona. Apunta amb la ballesta, esquiva onades de foc i compra millores permanents. La demo acaba després del primer cap i té la seva pròpia partida desada.")

apply('japanese', '''呪われた鉄道を戦い抜き、戦利品を持ち帰り、さらに強くなって再挑戦。Railway Furyは、狙いを定め、左右に回避し、次の強化を選ぶことが攻略の鍵となる、一人称視点のインクリメンタル・アクションゲームです。

あと一体、あと一つの報酬、あと少し先の線路へ。敵の弾や移動する炎の波をかわして報酬を集め、永続強化を重ねましょう。短い挑戦を繰り返すうちに、より奥まで進めるようになります。

強化を重ねて道を切り開け

ゴールド、ジェム、クラウンを使い、枝分かれする強化ツリーを進めましょう。クロスボウ、体力、アーマー、回収範囲、特殊能力を強化。手元に戻る短剣や超自然的な武器を解放し、次の挑戦でさらに先へ進むための強化を選びましょう。

四つの鉄道を制覇せよ

ボスを倒し、忘れられたダンジョン、中世の城塞、深い森の鉄道、そして地獄へと続く下り道を突破しましょう。ステージごとに景色が変わり、危険も増していきます。炎に対処する強化を活用して、先へ進みましょう。

一回一回の挑戦を力に

実績報酬で追加の資源を獲得し、必要な場面で特殊能力を発動。攻撃力、生存力、収入のバランスを整えましょう。ボス撃破やエンディングを目指す道のりでは、挑戦中の実プレイ時間も記録されます。強化の旅を進めた先には、二つの最終的な選択が待っています。

操作方法：左右に移動し、マウスで狙い、クリックで射撃。スペースキーで次に使用可能な特殊能力を発動します。十分に強くなったら、Shiftキーを押し続けて速度を2倍にし、さらなる危険に挑みましょう。''', '''Railway Furyで最初の挑戦を始めましょう。呪われた鉄道をさらに奥へと進む、一人称視点のインクリメンタル・アクションゲームです。クロスボウで狙いを定め、左右に動いて敵や炎の波をかわし、戦利品を回収。獲得した資源を永続強化に使いましょう。

体験版では最初の鉄道とそのボスに挑めます。挑戦を繰り返して攻撃力、体力、アーマー、特殊能力を強化し、実績報酬で追加の強化資源を獲得しましょう。体験版は最初のボスを倒すと終了します。それ以降のステージとクラウンを使った強化は製品版で楽しめます。

左右に移動し、マウスで狙い、クリックで射撃。スペースキーで次に使用可能な特殊能力を発動します。さらなる危険に挑む準備ができたら、Shiftキーを押し続けると速度が2倍になります。

体験版モード

体験版のセーブデータは製品版とは別です。製品版では、四つのテーマの鉄道、より大きな強化ツリー、手強いボス、二つのエンディングへと冒険が広がります。''',
"狙い、かわし、撃ちながら呪われた鉄道を突き進むインクリメンタル・アクションゲーム。炎の波を避け、戦利品を集め、挑戦の合間に永続強化を購入。四つのテーマのステージでボスを倒し、二つのエンディングを目指しましょう。",
"一人称視点のインクリメンタル・アクション体験版で、最初の鉄道とボスに挑戦。クロスボウで狙い、敵や炎の波をかわし、戦利品を永続強化に使いましょう。最初のボスを倒すと体験版は終了します。セーブデータは製品版とは別です。")

apply('schinese', '''沿着被诅咒的铁路杀出一条路，带回战利品，再以更强的姿态归来。Railway Fury 是一款第一人称增量动作游戏，精准瞄准、横向闪避以及每次强化的选择都至关重要。

每次出击，都争取多击败一个敌人、多拿一份奖励、多推进一段铁轨。躲避敌人的投射物和移动的火浪，收集奖励，购买永久强化，让短暂的尝试逐渐变成深入险境的远征。

用强化开辟前路

在分支强化树中花费金币、宝石和皇冠。提升弩、生命值、护甲、拾取范围和技能，解锁能够飞回手中的匕首与超自然武器，再选择能让你下次走得更远的强化。

征服四条铁路

击败首领，穿越被遗忘的地牢、中世纪城堡、荒野森林中的铁路，以及通往地狱的下行之路。每个关卡都有全新的景观与更棘手的危险，善用应对火焰的强化，继续向前突破。

让每次出击都有收获

领取成就奖励，获取额外资源，在关键时刻发动技能，并兼顾伤害、生存与收益。在挑战首领、走向结局的过程中，系统会记录你在出击中的实际游玩时间。完成强化之旅，迎接两种最终抉择。

操作：左右移动，用鼠标瞄准，点击射击，按空格键使用下一个就绪的技能。实力足够时，按住 Shift 键将速度提升至两倍，挑战更高风险。''', '''在 Railway Fury 中开启你的首次出击。这是一款第一人称增量动作游戏，你将沿着被诅咒的铁路不断深入。用弩瞄准，横向移动躲避敌人与火浪，收集战利品，并将所得投入永久强化。

试玩版包含第一条铁路及其首领。反复出击，提升伤害、生命值、护甲和技能，领取成就奖励，获得更多强化资源。击败第一位首领后，试玩版即告结束；后续关卡及皇冠强化仅在完整版中开放。

左右移动，用鼠标瞄准，点击射击，按空格键发动下一个就绪的技能。准备好承担额外风险后，按住 Shift 键即可将速度提升至两倍。

试玩模式

试玩版使用独立存档，与完整版分开保存。完整版将旅程扩展至四条不同主题的铁路，并提供更庞大的强化树、更强大的首领和两种结局。''',
"在这款增量动作游戏中，沿着被诅咒的铁路瞄准、闪避、射击。躲过火浪，收集战利品，在每次出击之间购买永久强化。击败四个主题关卡中的首领，一步步走向两种结局。",
"在这款第一人称增量动作试玩版中，挑战第一条铁路及其首领。用弩瞄准，躲避敌人与火浪，收集战利品并购买永久强化。试玩版在击败第一位首领后结束，存档与完整版相互独立。")

apply('koreana', '''저주받은 철도를 따라 싸우고, 전리품을 챙겨 더 강해진 모습으로 돌아오세요. Railway Fury는 조준, 좌우 회피, 다음 강화 선택이 모두 중요한 1인칭 점진적 성장 액션 게임입니다.

매번 출격할 때마다 적을 하나 더 쓰러뜨리고, 보상을 하나 더 얻고, 철로를 조금 더 나아가 보세요. 적의 투사체와 움직이는 화염 파도를 피하고 보상을 모으세요. 영구 강화를 쌓으면 짧았던 도전도 더 깊은 원정으로 이어집니다.

강화로 길을 개척하세요

갈래가 나뉘는 강화 트리에서 골드, 보석, 왕관을 사용하세요. 석궁, 체력, 방어구, 수집 범위, 능력을 강화할 수 있습니다. 손으로 되돌아오는 단검과 초자연적인 무기를 해금하고, 다음 출격에서 더 멀리 나아갈 수 있는 강화를 선택하세요.

네 개의 철도를 정복하세요

보스를 쓰러뜨리고 잊힌 던전, 중세 성채, 야생의 숲속 철도, 지옥으로 내려가는 길을 돌파하세요. 레벨마다 새로운 풍경과 더 까다로운 위험이 기다립니다. 화염에 대응하는 강화를 활용해 앞으로 나아가세요.

매번의 도전을 성장의 기회로

도전 과제 보상으로 추가 자원을 얻고, 필요할 때 능력을 발동하며, 공격력과 생존력, 수입의 균형을 맞추세요. 보스를 물리치고 결말을 향해 나아가는 동안 출격 중 실제 플레이 시간이 기록됩니다. 강화 여정을 완성하고 두 가지 최종 선택 중 하나에 도달하세요.

조작: 좌우로 이동하고, 마우스로 조준하고, 클릭으로 발사하세요. 스페이스 키를 누르면 다음으로 준비된 능력을 사용합니다. 위험을 감당할 만큼 강해졌다면 Shift 키를 길게 눌러 속도를 두 배로 높이세요.''', '''Railway Fury에서 첫 출격을 시작하세요. 저주받은 철도를 따라 더 멀리 전진하는 1인칭 점진적 성장 액션 게임입니다. 석궁으로 조준하고, 좌우로 움직여 적과 화염 파도를 피하고, 전리품을 모아 영구 강화에 투자하세요.

데모에는 첫 번째 철도와 해당 보스가 포함됩니다. 반복해서 출격하며 공격력, 체력, 방어구, 능력을 강화하고, 도전 과제 보상으로 추가 강화 자원을 얻으세요. 데모는 첫 보스를 물리치면 종료됩니다. 이후 레벨과 왕관 강화는 정식 버전에서 이용할 수 있습니다.

좌우로 이동하고, 마우스로 조준하고, 클릭으로 발사하세요. 스페이스 키를 누르면 다음으로 준비된 능력을 발동합니다. 추가 위험을 감수할 준비가 되었다면 Shift 키를 길게 눌러 속도를 두 배로 높이세요.

데모 모드

데모 진행 상황은 정식 버전과 별도의 저장 파일을 사용합니다. 정식 버전에서는 네 가지 테마의 철도, 더 큰 강화 트리, 더욱 강력한 보스, 두 가지 결말로 여정이 확장됩니다.''',
"저주받은 철도를 따라 조준하고, 피하고, 쏘며 전진하는 점진적 성장 액션 게임입니다. 화염 파도를 피하고 전리품을 모아 출격 사이에 영구 강화를 구매하세요. 네 가지 테마의 레벨에서 보스를 쓰러뜨리고 두 가지 결말을 향해 나아가세요.",
"1인칭 점진적 성장 액션 데모에서 첫 번째 철도와 보스에 도전하세요. 석궁으로 조준하고, 적과 화염 파도를 피하고, 전리품을 모아 영구 강화를 구매하세요. 첫 보스를 물리치면 종료되며, 정식 버전과 별도의 저장 파일을 사용합니다.")

apply('russian', '''Пробивайтесь по проклятой железной дороге, сохраняйте добычу и возвращайтесь сильнее. Railway Fury — инкрементальная экшен-игра от первого лица, в которой важны меткость, перемещения в стороны и выбор следующего улучшения.

В каждом забеге старайтесь победить ещё одного врага, получить ещё одну награду и пройти ещё один участок пути. Уклоняйтесь от вражеских снарядов и движущихся огненных волн, собирайте награды и покупайте постоянные улучшения, чтобы короткие вылазки превращались в долгие экспедиции.

ПРОКЛАДЫВАЙТЕ ПУТЬ УЛУЧШЕНИЯМИ

Тратьте золото, самоцветы и короны в разветвлённом дереве улучшений. Усиливайте арбалет, здоровье, броню, радиус сбора и способности. Открывайте возвращающиеся кинжалы и сверхъестественное оружие, а затем выбирайте улучшения, которые помогут продвинуться дальше в следующем забеге.

ПОКОРИТЕ ЧЕТЫРЕ ЖЕЛЕЗНЫЕ ДОРОГИ

Побеждайте боссов и пройдите через забытое подземелье, средневековую цитадель, железную дорогу в диком лесу и адский спуск. Каждый уровень предлагает новые пейзажи и более серьёзные опасности. Улучшения для борьбы с огнём помогут прорваться дальше.

ПУСТЬ КАЖДЫЙ ЗАБЕГ ПРИНОСИТ ПОЛЬЗУ

Забирайте награды за достижения, чтобы получить дополнительные ресурсы, вовремя применяйте способности и находите баланс между уроном, выживаемостью и доходом. По мере продвижения к боссам и финалу учитывается время активной игры в забегах. Завершите путь улучшений, чтобы прийти к одному из двух финальных решений.

Управление: двигайтесь влево и вправо, цельтесь мышью, нажимайте кнопку мыши для выстрела и Пробел для применения следующей готовой способности. Удерживайте Shift, чтобы удвоить скорость, когда станете достаточно сильны для такого риска.''', '''Начните свои первые забеги в Railway Fury — инкрементальной экшен-игре от первого лица, в которой предстоит продвигаться всё дальше по проклятой железной дороге. Цельтесь из арбалета, двигайтесь в стороны, уклоняясь от врагов и огненных волн, собирайте добычу и тратьте заработанное на постоянные улучшения.

Демоверсия включает первую железную дорогу и её босса. От забега к забегу повышайте урон, здоровье, броню и способности, а также забирайте награды за достижения, чтобы получить дополнительные ресурсы. Демоверсия заканчивается после первого босса; последующие уровни и улучшения за короны доступны в полной игре.

Двигайтесь влево и вправо, цельтесь мышью, нажимайте кнопку мыши для выстрела и Пробел для применения следующей готовой способности. Удерживайте Shift, чтобы удвоить скорость, когда будете готовы к дополнительному риску.

ДЕМОРЕЖИМ

Прогресс демоверсии хранится отдельно от сохранения полной игры. Полная версия расширяет путешествие до четырёх тематических железных дорог, предлагает большее дерево улучшений, более сильных боссов и две концовки.''',
"Цельтесь, уклоняйтесь и стреляйте на проклятой железной дороге в инкрементальном экшене. Избегайте огненных волн, собирайте добычу и покупайте постоянные улучшения между забегами. Победите боссов четырёх тематических уровней и доберитесь до двух концовок.",
"Опробуйте первую железную дорогу и её босса в демоверсии инкрементального экшена от первого лица. Стреляйте из арбалета, избегайте огненных волн и покупайте улучшения. Демо заканчивается после первого босса и использует отдельное сохранение.")

apply('polish', '''Przebij się przez przeklętą linię kolejową, zachowaj łupy i wróć silniejszy. Railway Fury to pierwszoosobowa gra akcji z przyrostowym rozwojem, w której liczą się celowanie, ruchy na boki i wybór kolejnego ulepszenia.

W każdej wyprawie spróbuj pokonać jeszcze jednego wroga, zdobyć kolejną nagrodę i przebyć następny odcinek torów. Unikaj pocisków i ruchomych fal ognia, zbieraj nagrody i kupuj trwałe ulepszenia, aby krótkie próby zmieniały się w coraz dalsze wyprawy.

TORUJ SOBIE DROGĘ ULEPSZENIAMI

Wydawaj złoto, klejnoty i korony w rozgałęzionym drzewku ulepszeń. Wzmacniaj kuszę, zdrowie, pancerz, zasięg zbierania i moce. Odblokuj powracające sztylety i nadnaturalną broń, a potem wybierz ulepszenia, które pozwolą ci dotrzeć dalej w następnej wyprawie.

PODBIJ CZTERY LINIE KOLEJOWE

Pokonuj bossów i przemierzaj zapomniane lochy, średniowieczną cytadelę, linię kolejową w dzikim lesie oraz piekielny zjazd. Każdy poziom to nowa sceneria i groźniejsze przeszkody. Ulepszenia pomagające radzić sobie z ogniem pozwolą ci przedrzeć się dalej.

NIECH KAŻDA WYPRAWA MA ZNACZENIE

Odbieraj nagrody za osiągnięcia, by zdobywać dodatkowe zasoby, używaj mocy w odpowiednim momencie i dbaj o równowagę między obrażeniami, przetrwaniem i dochodem. W drodze do pokonania bossów i zakończenia rejestrowany jest czas aktywnej gry podczas wypraw. Ukończ ścieżkę ulepszeń, aby dotrzeć do jednego z dwóch ostatecznych wyborów.

Sterowanie: poruszaj się w lewo i w prawo, celuj myszą, klikaj, by strzelać, i naciskaj Spację, aby użyć kolejnej gotowej mocy. Przytrzymaj Shift, by podwoić prędkość, gdy będziesz dość silny, aby podjąć ryzyko.''', '''Rozpocznij pierwsze wyprawy w Railway Fury — pierwszoosobowej grze akcji z przyrostowym rozwojem, w której docierasz coraz dalej wzdłuż przeklętej linii kolejowej. Celuj kuszą, przemieszczaj się na boki, by unikać wrogów i fal ognia, zbieraj łupy i inwestuj zarobki w trwałe ulepszenia.

Demo zawiera pierwszą linię kolejową i jej bossa. Podczas kolejnych wypraw rozwijaj obrażenia, zdrowie, pancerz i moce. Odbieraj nagrody za osiągnięcia, by zdobyć dodatkowe zasoby na ulepszenia. Demo kończy się po pierwszym bossie; dalsze poziomy i ulepszenia za korony są dostępne w pełnej grze.

Poruszaj się w lewo i w prawo, celuj myszą, klikaj, by strzelać, i naciskaj Spację, aby aktywować kolejną gotową moc. Przytrzymaj Shift, by podwoić prędkość, gdy będziesz gotowy na dodatkowe ryzyko.

TRYB DEMO

Demo korzysta z osobnego zapisu, niezależnego od pełnej gry. Pełna wersja rozszerza podróż o cztery tematyczne linie kolejowe, większe drzewko ulepszeń, trudniejszych bossów i dwa zakończenia.''',
"Celuj, unikaj i strzelaj na przeklętej linii kolejowej w grze akcji z przyrostowym rozwojem. Omijaj fale ognia, zbieraj łupy i kupuj trwałe ulepszenia między wyprawami. Pokonaj bossów czterech tematycznych poziomów i dotrzyj do dwóch zakończeń.",
"Wypróbuj pierwszą linię kolejową i jej bossa w demie pierwszoosobowej gry akcji z przyrostowym rozwojem. Strzelaj z kuszy, unikaj fal ognia i kupuj trwałe ulepszenia. Demo kończy się po pierwszym bossie i ma osobny zapis gry.")

apply('czech', '''Probojuj se po prokleté železnici, uchovej si kořist a vrať se silnější. Railway Fury je inkrementální akční hra z pohledu první osoby, ve které záleží na míření, pohybu do stran i volbě dalšího vylepšení.

Při každé výpravě se pokus porazit ještě jednoho nepřítele, získat další odměnu a urazit další kus trati. Vyhýbej se nepřátelským projektilům a pohybujícím se ohnivým vlnám, sbírej odměny a nakupuj trvalá vylepšení, která promění krátké pokusy v delší výpravy.

PROBOJUJ SE DÁL DÍKY VYLEPŠENÍM

Utrácej zlato, drahokamy a koruny v rozvětveném stromu vylepšení. Zlepšuj kuši, zdraví, brnění, dosah sbírání a schopnosti. Odemkni vracející se dýky a nadpřirozené zbraně a rozhodni, která vylepšení tě při příští výpravě dostanou dál.

ČTYŘI ŽELEZNICE K DOBYTÍ

Porážej bossy a postupuj zapomenutým podzemím, středověkou citadelou, železnicí v divokém lese a sestupem do pekla. Každá úroveň přináší nové prostředí a nebezpečnější nástrahy. Vylepšení pro zvládání ohně ti pomohou prorazit dál.

AŤ SE KAŽDÁ VÝPRAVA POČÍTÁ

Vyzvedávej odměny za achievementy a získávej další suroviny, používej schopnosti ve správnou chvíli a vyvažuj poškození, přežití a příjem. Na cestě za poražením bossů a dosažením konce se zaznamenává tvůj aktivní herní čas ve výpravách. Dokonči cestu vylepšení a dojdi k jedné ze dvou závěrečných voleb.

Ovládání: pohybuj se doleva a doprava, miř myší, kliknutím střílej a mezerníkem použij další připravenou schopnost. Podržením klávesy Shift zdvojnásobíš rychlost, až budeš dost silný na takové riziko.''', '''Vydej se na první výpravy v Railway Fury, inkrementální akční hře z pohledu první osoby, ve které postupuješ stále dál po prokleté železnici. Miř kuší, pohybem do stran se vyhýbej nepřátelům a ohnivým vlnám, sbírej kořist a investuj výdělky do trvalých vylepšení.

Demo obsahuje první železnici a jejího bosse. Při opakovaných výpravách zlepšuj poškození, zdraví, brnění a schopnosti a vyzvedávej odměny za achievementy pro další suroviny na vylepšení. Demo končí po prvním bossovi; další úrovně a vylepšení za koruny jsou vyhrazeny plné hře.

Pohybuj se doleva a doprava, miř myší, kliknutím střílej a mezerníkem aktivuj další připravenou schopnost. Podržením klávesy Shift zdvojnásobíš rychlost, až budeš připravený na vyšší riziko.

REŽIM DEMA

Demo používá vlastní uloženou pozici oddělenou od plné hry. Plná verze rozšiřuje cestu na čtyři tematické železnice, větší strom vylepšení, těžší bossy a dva konce.''',
"Miř, uhýbej a střílej na prokleté železnici v této inkrementální akční hře. Vyhýbej se ohnivým vlnám, sbírej kořist a mezi výpravami kupuj trvalá vylepšení. Poraz bossy ve čtyřech tematických úrovních a dopracuj se ke dvěma koncům.",
"Vyzkoušej první železnici a jejího bosse v demu inkrementální akce z pohledu první osoby. Miř kuší, vyhýbej se ohnivým vlnám a kupuj trvalá vylepšení. Demo končí po prvním bossovi a používá vlastní uloženou pozici.")

apply('turkish', '''Lanetli bir demiryolunda savaşarak ilerle, ganimetini sakla ve daha güçlü dön. Railway Fury; nişan almanın, yana hareket ederek kaçınmanın ve bir sonraki yükseltmeni seçmenin önem taşıdığı, birinci şahıs bakış açısına sahip bir artımlı aksiyon oyunudur.

Her seferde bir düşman daha yenmeye, bir ödül daha kazanmaya ve raylarda biraz daha ilerlemeye çalış. Düşman mermilerinden ve hareketli ateş dalgalarından kaç, ödülleri topla ve kalıcı yükseltmelerle kısa denemelerini daha uzun keşiflere dönüştür.

YÜKSELTMELERLE YOLUNU AÇ

Dallanan bir yükseltme ağacında altın, mücevher ve taç harca. Arbaletini, canını, zırhını, toplama menzilini ve güçlerini geliştir. Sana geri dönen hançerleri ve doğaüstü silahları aç, ardından bir sonraki seferde seni daha ileri taşıyacak yükseltmeleri seç.

FETHEDİLECEK DÖRT DEMİRYOLU

Boss'ları yenerek unutulmuş bir zindandan, Orta Çağ kalesinden, vahşi bir orman demiryolundan ve cehenneme iniş yolundan geç. Her bölüm yeni bir ortam ve daha zorlu tehlikeler sunar. Ateşle başa çıkmanı sağlayan yükseltmelerle yoluna devam et.

HER SEFERİNİ DEĞERLENDİR

Ek kaynaklar için başarım ödüllerini al, ihtiyaç duyduğunda güçlerini etkinleştir ve hasar, hayatta kalma ve gelir arasında denge kur. Boss'ları yenip sona doğru ilerlerken seferlerdeki aktif oyun süren kaydedilir. Yükseltme yolculuğunu tamamlayarak iki nihai seçimden birine ulaş.

Kontroller: Sağa ve sola hareket et, fareyle nişan al, ateş etmek için tıkla ve sıradaki hazır gücünü kullanmak için Boşluk tuşuna bas. Riski göze alabilecek kadar güçlendiğinde, hızı ikiye katlamak için Shift tuşunu basılı tut.''', '''Lanetli bir demiryolunda daha da ileri gitmeyi hedeflediğin, birinci şahıs bakış açılı artımlı aksiyon oyunu Railway Fury'de ilk seferlerine çık. Arbaletinle nişan al, düşmanlardan ve ateş dalgalarından kaçmak için yana hareket et, ganimet topla ve kazancını kalıcı yükseltmelere harca.

Demo, ilk demiryolunu ve boss'unu içerir. Tekrarlanan seferlerde hasarını, canını, zırhını ve güçlerini geliştir; ek yükseltme kaynakları için başarım ödüllerini al. Demo ilk boss'tan sonra sona erer. Sonraki bölümler ve taç yükseltmeleri tam oyuna ayrılmıştır.

Sağa ve sola hareket et, fareyle nişan al, ateş etmek için tıkla ve sıradaki hazır gücünü etkinleştirmek için Boşluk tuşuna bas. Ek riske hazır olduğunda hızı ikiye katlamak için Shift tuşunu basılı tut.

DEMO MODU

Demo ilerlemesi, tam oyundan ayrı bir kayıt dosyasında tutulur. Tam sürüm; dört temalı demiryolu, daha büyük bir yükseltme ağacı, daha zorlu boss'lar ve iki son ile yolculuğu genişletir.''',
"Bu artımlı aksiyon oyununda lanetli bir demiryolunda nişan al, kaçın ve ateş et. Ateş dalgalarından kaç, ganimet topla ve seferler arasında kalıcı yükseltmeler al. Dört temalı bölümde boss'ları yen ve iki sona doğru ilerle.",
"Birinci şahıs artımlı aksiyon demosunda ilk demiryolunu ve boss'unu dene. Arbaletinle nişan al, ateş dalgalarından kaç ve kalıcı yükseltmeler al. Demo ilk boss'tan sonra biter ve tam oyundan ayrı bir kayıt kullanır.")

apply('indonesian', '''Terobos jalur kereta terkutuk, simpan hasil jarahanmu, dan kembali dengan kekuatan baru. Railway Fury adalah game aksi inkremental bersudut pandang orang pertama. Bidikan, gerakan menyamping, dan pilihan peningkatan berikutnya sama-sama menentukan keberhasilanmu.

Dalam setiap ekspedisi, berusahalah mengalahkan satu musuh lagi, meraih satu hadiah lagi, dan menempuh satu bagian rel lagi. Hindari proyektil musuh dan gelombang api yang bergerak, kumpulkan hadiah, lalu gunakan peningkatan permanen untuk mengubah percobaan singkat menjadi ekspedisi yang semakin jauh.

BUKA JALAN DENGAN PENINGKATAN

Belanjakan emas, permata, dan mahkota di pohon peningkatan bercabang. Tingkatkan busur silang, kesehatan, zirah, jangkauan pengumpulan, dan kekuatanmu. Buka belati yang kembali kepadamu dan senjata supernatural, lalu pilih peningkatan yang akan membawamu lebih jauh pada ekspedisi berikutnya.

TAKLUKKAN EMPAT JALUR KERETA

Kalahkan bos dan jelajahi ruang bawah tanah yang terlupakan, benteng abad pertengahan, jalur kereta di hutan liar, dan turunan menuju neraka. Setiap level menghadirkan pemandangan baru dan bahaya yang lebih sulit. Manfaatkan peningkatan untuk menghadapi api agar dapat terus maju.

JADIKAN SETIAP EKSPEDISI BERARTI

Klaim hadiah pencapaian untuk memperoleh sumber daya tambahan, aktifkan kekuatan saat dibutuhkan, dan seimbangkan daya serang, ketahanan, serta pendapatan. Waktu bermain aktif selama ekspedisi dicatat seiring kemajuanmu mengalahkan bos dan mencapai akhir. Tuntaskan perjalanan peningkatan untuk mencapai salah satu dari dua pilihan terakhir.

Kontrol: bergerak ke kiri dan kanan, bidik dengan mouse, klik untuk menembak, dan tekan Spasi untuk menggunakan kekuatan berikutnya yang siap. Tahan Shift untuk menggandakan kecepatan saat kamu sudah cukup kuat menghadapi risikonya.''', '''Mulai ekspedisi pertamamu di Railway Fury, game aksi inkremental bersudut pandang orang pertama yang menantangmu menjelajah semakin jauh di jalur kereta terkutuk. Bidik dengan busur silang, bergerak menyamping untuk menghindari musuh dan gelombang api, kumpulkan jarahan, lalu belanjakan hasilnya untuk peningkatan permanen.

Demo mencakup jalur kereta pertama beserta bosnya. Tingkatkan daya serang, kesehatan, zirah, dan kekuatan melalui ekspedisi berulang. Klaim hadiah pencapaian untuk memperoleh sumber daya peningkatan tambahan. Demo berakhir setelah bos pertama; level berikutnya dan peningkatan dengan mahkota tersedia dalam game lengkap.

Bergerak ke kiri dan kanan, bidik dengan mouse, klik untuk menembak, dan tekan Spasi untuk mengaktifkan kekuatan berikutnya yang siap. Tahan Shift untuk menggandakan kecepatan saat kamu siap menghadapi risiko tambahan.

MODE DEMO

Progres demo menggunakan berkas simpanan terpisah dari game lengkap. Versi lengkap memperluas perjalanan dengan empat jalur kereta bertema, pohon peningkatan yang lebih besar, bos yang lebih tangguh, dan dua akhir cerita.''',
"Bidik, menghindar, dan tembak di jalur kereta terkutuk dalam game aksi inkremental ini. Hindari gelombang api, kumpulkan jarahan, dan beli peningkatan permanen di antara ekspedisi. Kalahkan bos di empat level bertema dan raih dua akhir cerita.",
"Coba jalur kereta pertama dan bosnya dalam demo aksi inkremental orang pertama ini. Bidik dengan busur silang, hindari gelombang api, dan beli peningkatan permanen. Demo berakhir setelah bos pertama dan menggunakan simpanan terpisah dari game lengkap.")

apply('vietnamese', '''Chiến đấu dọc tuyến đường sắt bị nguyền rủa, giữ lấy chiến lợi phẩm và trở lại mạnh hơn. Railway Fury là game hành động tăng tiến góc nhìn thứ nhất, nơi khả năng ngắm bắn, di chuyển ngang và lựa chọn nâng cấp tiếp theo đều quan trọng.

Mỗi chuyến đi là cơ hội hạ thêm một kẻ địch, nhận thêm một phần thưởng và tiến thêm một đoạn đường ray. Né đạn địch và những đợt sóng lửa di chuyển, thu thập phần thưởng rồi dùng các nâng cấp vĩnh viễn để biến những lần thử ngắn ngủi thành các chuyến thám hiểm ngày càng xa.

MỞ LỐI BẰNG NÂNG CẤP

Chi vàng, đá quý và vương miện trong cây nâng cấp phân nhánh. Cải thiện nỏ, máu, giáp, phạm vi thu thập và năng lực. Mở khóa dao găm quay về tay cùng các vũ khí siêu nhiên, rồi chọn những nâng cấp giúp chuyến đi tiếp theo tiến xa hơn.

CHINH PHỤC BỐN TUYẾN ĐƯỜNG SẮT

Đánh bại trùm và băng qua hầm ngục bị lãng quên, thành trì thời trung cổ, đường sắt trong rừng hoang và con dốc xuống địa ngục. Mỗi màn mang đến khung cảnh mới cùng hiểm họa khó hơn. Hãy tận dụng nâng cấp đối phó với lửa để tiếp tục tiến lên.

ĐỂ MỖI CHUYẾN ĐI ĐỀU CÓ GIÁ TRỊ

Nhận thưởng thành tựu để có thêm tài nguyên, kích hoạt năng lực khi cần và cân bằng sát thương, khả năng sinh tồn cùng thu nhập. Thời gian chơi chủ động trong các chuyến đi được ghi lại khi bạn tiến tới việc hạ trùm và đạt kết thúc. Hoàn thành hành trình nâng cấp để đi đến một trong hai lựa chọn cuối cùng.

Điều khiển: di chuyển sang trái và phải, ngắm bằng chuột, nhấp để bắn và nhấn phím Cách để dùng năng lực sẵn sàng tiếp theo. Giữ Shift để tăng gấp đôi tốc độ khi bạn đủ mạnh để chấp nhận rủi ro.''', '''Bắt đầu những chuyến đi đầu tiên trong Railway Fury, game hành động tăng tiến góc nhìn thứ nhất, nơi bạn tiến ngày càng xa dọc tuyến đường sắt bị nguyền rủa. Ngắm bằng nỏ, di chuyển ngang để né kẻ địch và sóng lửa, thu thập chiến lợi phẩm rồi dùng thu nhập để mua nâng cấp vĩnh viễn.

Bản chơi thử gồm tuyến đường sắt đầu tiên và trùm của tuyến đó. Tăng sát thương, máu, giáp và năng lực qua nhiều chuyến đi, đồng thời nhận thưởng thành tựu để có thêm tài nguyên nâng cấp. Bản chơi thử kết thúc sau trùm đầu tiên; các màn tiếp theo và nâng cấp bằng vương miện dành cho bản đầy đủ.

Di chuyển sang trái và phải, ngắm bằng chuột, nhấp để bắn và nhấn phím Cách để kích hoạt năng lực sẵn sàng tiếp theo. Giữ Shift để tăng gấp đôi tốc độ khi bạn sẵn sàng chấp nhận rủi ro lớn hơn.

CHẾ ĐỘ CHƠI THỬ

Tiến trình bản chơi thử dùng tệp lưu riêng, tách biệt với bản đầy đủ. Bản đầy đủ mở rộng hành trình qua bốn tuyến đường sắt theo chủ đề, cây nâng cấp lớn hơn, các trùm khó hơn và hai kết thúc.''',
"Ngắm, né và bắn trên tuyến đường sắt bị nguyền rủa trong game hành động tăng tiến này. Né sóng lửa, nhặt chiến lợi phẩm và mua nâng cấp vĩnh viễn giữa các chuyến đi. Hạ trùm ở bốn màn theo chủ đề và tiến tới hai kết thúc.",
"Thử tuyến đường sắt đầu tiên và trùm trong bản chơi thử hành động tăng tiến góc nhìn thứ nhất. Ngắm nỏ, né sóng lửa và mua nâng cấp vĩnh viễn. Bản chơi thử kết thúc sau trùm đầu tiên và dùng tệp lưu riêng với bản đầy đủ.")

apply('thai', '''ฝ่าฟันไปตามทางรถไฟต้องคำสาป เก็บของที่ได้มา แล้วกลับไปลุยด้วยพลังที่มากกว่าเดิม Railway Fury คือเกมแอ็กชันมุมมองบุคคลที่หนึ่งที่คุณจะค่อย ๆ สะสมพลังให้แข็งแกร่งขึ้น ทั้งการเล็ง การเคลื่อนที่หลบไปด้านข้าง และการเลือกอัปเกรดครั้งต่อไปล้วนสำคัญ

ในการออกลุยแต่ละครั้ง พยายามกำจัดศัตรูเพิ่มอีกหนึ่งตัว รับรางวัลเพิ่มอีกหนึ่งชิ้น และเดินหน้าไปอีกช่วงราง หลบกระสุนของศัตรูและคลื่นไฟที่เคลื่อนเข้ามา เก็บรางวัล แล้วใช้อัปเกรดถาวรเปลี่ยนการลุยสั้น ๆ ให้กลายเป็นการเดินทางที่ไปได้ไกลกว่าเดิม

เปิดทางด้วยการอัปเกรด

ใช้ทอง อัญมณี และมงกุฎในผังอัปเกรดที่แตกแขนง พัฒนาหน้าไม้ พลังชีวิต เกราะ ระยะเก็บของ และพลังพิเศษ ปลดล็อกมีดสั้นที่ย้อนกลับมาหาคุณและอาวุธเหนือธรรมชาติ แล้วเลือกอัปเกรดที่จะช่วยให้การลุยครั้งต่อไปไปได้ไกลขึ้น

พิชิตทางรถไฟทั้งสี่สาย

เอาชนะบอสแล้วฝ่าดันเจี้ยนที่ถูกลืม ป้อมปราการยุคกลาง ทางรถไฟในป่าดงดิบ และทางลาดลงสู่ขุมนรก แต่ละด่านมีฉากใหม่และอันตรายที่ยากขึ้น ใช้อัปเกรดสำหรับรับมือกับไฟเพื่อบุกต่อไป

ทำให้การลุยทุกครั้งมีความหมาย

รับรางวัลจากความสำเร็จเพื่อหาทรัพยากรเพิ่ม ใช้พลังพิเศษเมื่อจำเป็น และสร้างสมดุลระหว่างความเสียหาย การเอาตัวรอด และรายได้ ระบบจะบันทึกเวลาที่คุณเล่นจริงระหว่างออกลุย ขณะที่คุณคืบหน้าไปสู่การปราบบอสและตอนจบ พัฒนาอัปเกรดจนสุดเส้นทางเพื่อไปถึงหนึ่งในสองทางเลือกสุดท้าย

การควบคุม: เคลื่อนที่ไปทางซ้ายและขวา เล็งด้วยเมาส์ คลิกเพื่อยิง และกด Space เพื่อใช้พลังพิเศษถัดไปที่พร้อมใช้งาน กด Shift ค้างไว้เพื่อเพิ่มความเร็วเป็นสองเท่า เมื่อคุณแข็งแกร่งพอที่จะรับความเสี่ยง''', '''เริ่มออกลุยครั้งแรกใน Railway Fury เกมแอ็กชันมุมมองบุคคลที่หนึ่งที่ให้คุณสะสมพลังและรุกไปตามทางรถไฟต้องคำสาปให้ไกลขึ้นเรื่อย ๆ เล็งด้วยหน้าไม้ เคลื่อนที่ไปด้านข้างเพื่อหลบศัตรูและคลื่นไฟ เก็บของ แล้วนำรายได้ไปซื้ออัปเกรดถาวร

เดโมมีทางรถไฟสายแรกพร้อมบอส พัฒนาความเสียหาย พลังชีวิต เกราะ และพลังพิเศษผ่านการออกลุยซ้ำ ๆ พร้อมรับรางวัลจากความสำเร็จเพื่อหาทรัพยากรอัปเกรดเพิ่ม เดโมจะจบหลังปราบบอสตัวแรก ส่วนด่านถัดไปและอัปเกรดด้วยมงกุฎมีให้เล่นในเกมฉบับเต็ม

เคลื่อนที่ไปทางซ้ายและขวา เล็งด้วยเมาส์ คลิกเพื่อยิง และกด Space เพื่อใช้พลังพิเศษถัดไปที่พร้อมใช้งาน กด Shift ค้างไว้เพื่อเพิ่มความเร็วเป็นสองเท่า เมื่อคุณพร้อมรับความเสี่ยงที่มากขึ้น

โหมดเดโม

ความคืบหน้าในเดโมใช้ไฟล์บันทึกแยกจากเกมฉบับเต็ม ฉบับเต็มจะขยายการเดินทางไปยังทางรถไฟสี่ธีม พร้อมผังอัปเกรดที่ใหญ่ขึ้น บอสที่แข็งแกร่งกว่าเดิม และตอนจบสองแบบ''',
"เล็ง หลบ และยิงฝ่าทางรถไฟต้องคำสาปในเกมแอ็กชันที่ให้คุณสะสมพลังให้เก่งขึ้นเรื่อย ๆ หลบคลื่นไฟ เก็บของ และซื้ออัปเกรดถาวรระหว่างการลุย ปราบบอสในด่านสี่ธีมแล้วมุ่งสู่ตอนจบสองแบบ",
"ลองทางรถไฟสายแรกและบอสในเดโมแอ็กชันมุมมองบุคคลที่หนึ่งที่เน้นสะสมพลัง เล็งหน้าไม้ หลบศัตรูและคลื่นไฟ เก็บของและซื้ออัปเกรดถาวร เดโมจบหลังปราบบอสตัวแรก และใช้ไฟล์บันทึกแยกจากฉบับเต็ม")

requirements = {
    'catalan': ('Windows 10 / 11 (64 bits)', 'Processador de quatre nuclis, 2.5 GHz', 'Targeta gràfica compatible amb Vulkan 1.2, 2 GB de VRAM', 'Teclat i ratolí o comandament compatible.'),
    'czech': ('Windows 10 / 11 (64bitový)', 'Čtyřjádrový procesor, 2.5 GHz', 'Grafická karta kompatibilní s Vulkan 1.2, 2 GB VRAM', 'Klávesnice a myš nebo kompatibilní gamepad.'),
    'french': ('Windows 10 / 11 (64 bits)', 'Processeur quadricœur, 2.5 GHz', 'Carte graphique compatible Vulkan 1.2, 2 Go de VRAM', 'Clavier et souris ou manette compatible.'),
    'german': ('Windows 10 / 11 (64-Bit)', 'Vierkernprozessor, 2.5 GHz', 'Mit Vulkan 1.2 kompatible Grafikkarte, 2 GB VRAM', 'Tastatur und Maus oder kompatibles Gamepad.'),
    'indonesian': ('Windows 10 / 11 (64-bit)', 'Prosesor empat inti, 2.5 GHz', 'Kartu grafis yang mendukung Vulkan 1.2, 2 GB VRAM', 'Keyboard dan mouse atau gamepad yang kompatibel.'),
    'italian': ('Windows 10 / 11 (64 bit)', 'Processore quad-core, 2.5 GHz', 'Scheda grafica compatibile con Vulkan 1.2, 2 GB di VRAM', 'Tastiera e mouse o gamepad compatibile.'),
    'japanese': ('Windows 10 / 11（64ビット）', 'クアッドコアプロセッサ、2.5 GHz', 'Vulkan 1.2対応グラフィックカード、VRAM 2 GB', 'キーボードとマウス、または対応ゲームパッド。'),
    'koreana': ('Windows 10 / 11 (64비트)', '쿼드 코어 프로세서, 2.5 GHz', 'Vulkan 1.2 호환 그래픽 카드, VRAM 2 GB', '키보드와 마우스 또는 호환 게임패드.'),
    'polish': ('Windows 10 / 11 (64-bitowy)', 'Procesor czterordzeniowy, 2.5 GHz', 'Karta graficzna zgodna z Vulkan 1.2, 2 GB VRAM', 'Klawiatura i mysz lub kompatybilny gamepad.'),
    'portuguese': ('Windows 10 / 11 (64 bits)', 'Processador de quatro núcleos, 2.5 GHz', 'Placa gráfica compatível com Vulkan 1.2, 2 GB de VRAM', 'Teclado e rato ou comando compatível.'),
    'russian': ('Windows 10 / 11 (64-разрядная)', 'Четырёхъядерный процессор, 2.5 GHz', 'Видеокарта с поддержкой Vulkan 1.2, 2 GB видеопамяти', 'Клавиатура и мышь или совместимый геймпад.'),
    'schinese': ('Windows 10 / 11（64位）', '四核处理器，2.5 GHz', '支持 Vulkan 1.2 的显卡，2 GB 显存', '键盘和鼠标，或兼容的游戏手柄。'),
    'spanish': ('Windows 10 / 11 (64 bits)', 'Procesador de cuatro núcleos, 2.5 GHz', 'Tarjeta gráfica compatible con Vulkan 1.2, 2 GB de VRAM', 'Teclado y ratón o mando compatible.'),
    'thai': ('Windows 10 / 11 (64 บิต)', 'โปรเซสเซอร์สี่คอร์, 2.5 GHz', 'การ์ดจอที่รองรับ Vulkan 1.2 พร้อม VRAM 2 GB', 'คีย์บอร์ดและเมาส์ หรือเกมแพดที่รองรับ'),
    'turkish': ('Windows 10 / 11 (64 bit)', 'Dört çekirdekli işlemci, 2.5 GHz', 'Vulkan 1.2 uyumlu ekran kartı, 2 GB VRAM', 'Klavye ve fare veya uyumlu oyun kumandası.'),
    'vietnamese': ('Windows 10 / 11 (64-bit)', 'Bộ xử lý bốn nhân, 2.5 GHz', 'Card đồ họa hỗ trợ Vulkan 1.2, 2 GB VRAM', 'Bàn phím và chuột hoặc tay cầm tương thích.'),
}
for language, values in requirements.items():
    path = OUT / f'{language}.json'
    data = json.loads(path.read_text(encoding='utf-8'))
    for field, value in zip(['osversion', 'processor', 'graphics', 'notes'], values):
        data['main'][f'app[content][sysreqs][windows][min][{field}]'] = value
    data['demo']['app[content][sysreqs][windows][min][notes]'] = values[-1]
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')

package()
