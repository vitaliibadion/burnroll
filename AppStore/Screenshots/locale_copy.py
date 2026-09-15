"""App Store 6.9\" marketing copy per locale."""

from __future__ import annotations

# keep/burn/delete words used to color subtitles
EMPHASIS = {
    "en": {"keep": {"keep", "kept"}, "burn": {"burn", "delete", "deleted"}},
    "nl": {"keep": {"bewaren", "bewaar"}, "burn": {"wissen", "wis", "verwijderen"}},
    "fr": {"keep": {"garde", "garder"}, "burn": {"brûle", "brûler", "effacer"}},
    "de": {"keep": {"behalte", "behalten"}, "burn": {"brennen", "löschen", "lösche"}},
    "it": {"keep": {"tieni", "tenere"}, "burn": {"brucia", "elimina", "eliminare"}},
    "ja": {"keep": {"残す"}, "burn": {"削除"}},
    "ko": {"keep": {"유지"}, "burn": {"삭제"}},
    "pl": {"keep": {"zachowaj"}, "burn": {"usuń", "usunięcia"}},
    "pt-BR": {"keep": {"manter", "mantenha"}, "burn": {"queimar", "excluir"}},
    "zh-Hans": {"keep": {"保留"}, "burn": {"清除", "删除"}},
    "es": {"keep": {"conserva", "conservar"}, "burn": {"elimina", "eliminar", "borrar"}},
    "uk": {"keep": {"зберегти", "зберігайте"}, "burn": {"видалити", "спаліть"}},
}

# title lines: list of (text, role) where role is ink/burn/keep/paper
FRAMES = {
    "en": {
        "01": {
            "title": [[("SWIPE. ", "ink"), ("DECIDE.", "burn")], [("DONE.", "keep")]],
            "subtitle": "Keep or burn with one gesture. Nothing deletes until you confirm.",
        },
        "02": {
            "title": [[("BURN", "burn"), (" THE", "paper")], [("CLUTTER.", "paper")]],
            "subtitle": "Swipe left. The photo joins your burn list - not the trash.",
        },
        "03": {
            "title": [[("KEEP", "keep"), (" WHAT", "paper")], [("MATTERS.", "paper")]],
            "subtitle": "Swipe right to keep the shot. Your place is saved for later.",
        },
        "04": {
            "title": [[("REVIEW", "ember")], [("BEFORE YOU", "ink")], [("DELETE.", "burn")]],
            "subtitle": "See every thumbnail. Drop anything you still want. Then confirm.",
        },
        "05": {
            "title": [[("YOUR PHOTOS", "paper")], [("STAY ON YOUR", "paper")], [("IPHONE.", "keep")]],
            "subtitle": "On-device. No cloud photo uploads. No account required.",
        },
        "06": {
            "title": [[("CLEAR ", "paper"), ("SPACE", "ember")], [("YOUR WAY.", "paper")]],
            "subtitle": "Watch the storage you selected add up before anything is burned.",
        },
    },
    "nl": {
        "01": {
            "title": [[("VEEG. ", "ink"), ("KIES.", "burn")], [("KLAAR.", "keep")]],
            "subtitle": "Bewaren of wissen met één gebaar. Niets verdwijnt tot je bevestigt.",
        },
        "02": {
            "title": [[("WIS ", "burn")], [("DE ROMMEL.", "paper")]],
            "subtitle": "Veeg naar links. De foto gaat op je wislijst - niet meteen de prullenbak in.",
        },
        "03": {
            "title": [[("BEWAAR ", "keep")], [("WAT TELT.", "paper")]],
            "subtitle": "Veeg naar rechts om de foto te bewaren. Je plek blijft onthouden.",
        },
        "04": {
            "title": [[("KIJK NA", "ember")], [("VOOR JE", "ink")], [("WIST.", "burn")]],
            "subtitle": "Zie elke thumbnail. Haal weg wat je wilt houden. Daarna bevestigen.",
        },
        "05": {
            "title": [[("FOTO’S BLIJVEN", "paper")], [("OP JE IPHONE.", "keep")]],
            "subtitle": "Op het apparaat. Geen cloudfoto-uploads. Geen account nodig.",
        },
        "06": {
            "title": [[("RUIMTE VRIJ", "ember")], [("OP JOUW MANIER.", "paper")]],
            "subtitle": "Zie de gekozen opslag optellen voordat iets wordt gewist.",
        },
    },
    "fr": {
        "01": {
            "title": [[("GLISSE. ", "ink"), ("DÉCIDE.", "burn")], [("TERMINÉ.", "keep")]],
            "subtitle": "Garde ou brûle d’un geste. Rien n’est supprimé avant confirmation.",
        },
        "02": {
            "title": [[("BRÛLE ", "burn")], [("LE FATRAS.", "paper")]],
            "subtitle": "Glisse à gauche. La photo rejoint ta liste à brûler - pas la corbeille.",
        },
        "03": {
            "title": [[("GARDE ", "keep")], [("L’ESSENTIEL.", "paper")]],
            "subtitle": "Glisse à droite pour garder la photo. Ta place est enregistrée.",
        },
        "04": {
            "title": [[("VÉRIFIE", "ember")], [("AVANT", "ink")], [("D’EFFACER.", "burn")]],
            "subtitle": "Vois chaque miniature. Retire ce que tu veux garder. Puis confirme.",
        },
        "05": {
            "title": [[("TES PHOTOS", "paper")], [("RESTENT SUR", "paper")], [("L’IPHONE.", "keep")]],
            "subtitle": "Sur l’appareil. Pas d’envoi cloud. Pas de compte.",
        },
        "06": {
            "title": [[("LIBÈRE", "ember")], [("L’ESPACE À TA FAÇON.", "paper")]],
            "subtitle": "Vois s’additionner l’espace choisi avant toute suppression.",
        },
    },
    "de": {
        "01": {
            "title": [[("WISCHEN. ", "ink"), ("ENTSCHEIDEN.", "burn")], [("FERTIG.", "keep")]],
            "subtitle": "Behalten oder brennen mit einer Geste. Nichts wird gelöscht, bis du bestätigst.",
        },
        "02": {
            "title": [[("BRENN ", "burn")], [("DIE UNORDNUNG.", "paper")]],
            "subtitle": "Wische nach links. Das Foto kommt auf die Brennliste - nicht in den Papierkorb.",
        },
        "03": {
            "title": [[("BEHALTE ", "keep")], [("WAS ZÄHLT.", "paper")]],
            "subtitle": "Wische nach rechts, um das Foto zu behalten. Dein Platz bleibt gespeichert.",
        },
        "04": {
            "title": [[("PRÜFEN", "ember")], [("VOR DEM", "ink")], [("LÖSCHEN.", "burn")]],
            "subtitle": "Sieh jedes Vorschaubild. Nimm runter, was du behalten willst. Dann bestätigen.",
        },
        "05": {
            "title": [[("FOTOS BLEIBEN", "paper")], [("AUF DEM IPHONE.", "keep")]],
            "subtitle": "Auf dem Gerät. Keine Cloud-Uploads. Kein Konto.",
        },
        "06": {
            "title": [[("SPEICHER FREI", "ember")], [("AUF DEINE ART.", "paper")]],
            "subtitle": "Sieh den gewählten Speicher wachsen, bevor etwas brennt.",
        },
    },
    "it": {
        "01": {
            "title": [[("SCORRI. ", "ink"), ("DECIDI.", "burn")], [("FATTO.", "keep")]],
            "subtitle": "Tieni o brucia con un gesto. Niente si elimina finché non confermi.",
        },
        "02": {
            "title": [[("BRUCIA ", "burn")], [("IL SUPERFLUO.", "paper")]],
            "subtitle": "Scorri a sinistra. La foto entra nella lista da bruciare - non nel cestino.",
        },
        "03": {
            "title": [[("TIENI ", "keep")], [("L’ESSENZIALE.", "paper")]],
            "subtitle": "Scorri a destra per tenere lo scatto. Il tuo punto resta salvato.",
        },
        "04": {
            "title": [[("RIVEDI", "ember")], [("PRIMA DI", "ink")], [("ELIMINARE.", "burn")]],
            "subtitle": "Vedi ogni miniatura. Togli ciò che vuoi tenere. Poi conferma.",
        },
        "05": {
            "title": [[("LE TUE FOTO", "paper")], [("RESTANO SULL’IPHONE.", "keep")]],
            "subtitle": "Sul dispositivo. Nessun upload cloud. Nessun account.",
        },
        "06": {
            "title": [[("LIBERA SPAZIO", "ember")], [("A MODO TUO.", "paper")]],
            "subtitle": "Guarda lo spazio scelto accumularsi prima di qualsiasi bruciatura.",
        },
    },
    "ja": {
        "01": {
            "title": [[("スワイプ。", "ink")], [("選んで。", "burn")], [("完了。", "keep")]],
            "subtitle": "一手で残すか削除。確認するまで消えません。",
        },
        "02": {
            "title": [[("不要な写真を", "paper")], [("削除。", "burn")]],
            "subtitle": "左にスワイプ。写真は削除リストへ。ゴミ箱ではありません。",
        },
        "03": {
            "title": [[("大切な一枚は", "paper")], [("残す。", "keep")]],
            "subtitle": "右にスワイプして残す。続きの位置はそのまま保存されます。",
        },
        "04": {
            "title": [[("削除の前に", "ember")], [("確認。", "burn")]],
            "subtitle": "サムネイルを全部見て、残したいものは外してから確定。",
        },
        "05": {
            "title": [[("写真はiPhoneの中。", "keep")]],
            "subtitle": "端末内で処理。クラウドに写真は上げません。アカウント不要。",
        },
        "06": {
            "title": [[("空き容量は", "ember")], [("あなたのペースで。", "paper")]],
            "subtitle": "削除の前に、選んだ容量が積み上がるのを確認できます。",
        },
    },
    "ko": {
        "01": {
            "title": [[("스와이프. ", "ink"), ("결정.", "burn")], [("끝.", "keep")]],
            "subtitle": "한 제스처로 유지 또는 삭제. 확인 전에는 지워지지 않습니다.",
        },
        "02": {
            "title": [[("잡동사니는", "paper")], [("삭제.", "burn")]],
            "subtitle": "왼쪽으로 밀면 삭제 목록에 들어갑니다. 바로 휴지통이 아닙니다.",
        },
        "03": {
            "title": [[("중요한 샷은", "paper")], [("유지.", "keep")]],
            "subtitle": "오른쪽으로 밀어 사진을 남기세요. 위치는 나중에 이어집니다.",
        },
        "04": {
            "title": [[("삭제 전에", "ember")], [("검토.", "burn")]],
            "subtitle": "모든 미리보기를 보고, 남길 것은 뺀 다음 확인하세요.",
        },
        "05": {
            "title": [[("사진은", "paper")], [("아이폰에.", "keep")]],
            "subtitle": "기기 안에서 처리. 클라우드 업로드 없음. 계정 불필요.",
        },
        "06": {
            "title": [[("용량은", "ember")], [("내 방식대로.", "paper")]],
            "subtitle": "삭제하기 전에 선택한 용량이 쌓이는 것을 확인하세요.",
        },
    },
    "pl": {
        "01": {
            "title": [[("PRZESUŃ. ", "ink"), ("ZDECYDUJ.", "burn")], [("GOTOWE.", "keep")]],
            "subtitle": "Zachowaj lub usuń jednym gestem. Nic nie znika, dopóki nie potwierdzisz.",
        },
        "02": {
            "title": [[("USUŃ ", "burn")], [("BAŁAGAN.", "paper")]],
            "subtitle": "Przesuń w lewo. Zdjęcie trafia na listę do usunięcia - nie do kosza.",
        },
        "03": {
            "title": [[("ZACHOWAJ ", "keep")], [("TO, CO WAŻNE.", "paper")]],
            "subtitle": "Przesuń w prawo, aby zachować zdjęcie. Twoje miejsce zostaje zapisane.",
        },
        "04": {
            "title": [[("SPRAWDŹ", "ember")], [("PRZED", "ink")], [("USUNIĘCIEM.", "burn")]],
            "subtitle": "Zobacz każdą miniaturę. Odrzuć to, co chcesz zostawić. Potem potwierdź.",
        },
        "05": {
            "title": [[("ZDJĘCIA ZOSTAJĄ", "paper")], [("NA IPHONE.", "keep")]],
            "subtitle": "Na urządzeniu. Bez wysyłki do chmury. Bez konta.",
        },
        "06": {
            "title": [[("WOLNE MIEJSCE", "ember")], [("PO TWOJEMU.", "paper")]],
            "subtitle": "Patrz, jak sumuje się wybrana pamięć, zanim cokolwiek zniknie.",
        },
    },
    "pt-BR": {
        "01": {
            "title": [[("DESLIZE. ", "ink"), ("DECIDA.", "burn")], [("PRONTO.", "keep")]],
            "subtitle": "Mantenha ou queime com um gesto. Nada some até você confirmar.",
        },
        "02": {
            "title": [[("QUEIME ", "burn")], [("A BAGUNÇA.", "paper")]],
            "subtitle": "Deslize à esquerda. A foto entra na lista de queima - não no lixo.",
        },
        "03": {
            "title": [[("MANTENHA ", "keep")], [("O QUE IMPORTA.", "paper")]],
            "subtitle": "Deslize à direita para manter a foto. Seu lugar fica salvo.",
        },
        "04": {
            "title": [[("REVISE", "ember")], [("ANTES DE", "ink")], [("EXCLUIR.", "burn")]],
            "subtitle": "Veja cada miniatura. Tire o que ainda quer. Depois confirme.",
        },
        "05": {
            "title": [[("SUAS FOTOS", "paper")], [("FICAM NO IPHONE.", "keep")]],
            "subtitle": "No dispositivo. Sem upload para a nuvem. Sem conta.",
        },
        "06": {
            "title": [[("LIBERE ESPAÇO", "ember")], [("DO SEU JEITO.", "paper")]],
            "subtitle": "Veja o armazenamento escolhido somar antes de qualquer queima.",
        },
    },
    "zh-Hans": {
        "01": {
            "title": [[("轻滑。", "ink")], [("决定。", "burn")], [("完成。", "keep")]],
            "subtitle": "一个手势即可保留或清除。确认前不会删除。",
        },
        "02": {
            "title": [[("清掉杂乱。", "burn")]],
            "subtitle": "向左滑，照片进入清除列表，而不是立刻进废纸篓。",
        },
        "03": {
            "title": [[("留下重要的。", "keep")]],
            "subtitle": "向右滑保留这张。位置会记住，方便下次继续。",
        },
        "04": {
            "title": [[("删除前再看一遍。", "ember")]],
            "subtitle": "查看每张缩略图，拿掉还想留的，然后再确认。",
        },
        "05": {
            "title": [[("照片留在", "paper")], [("iPhone 上。", "keep")]],
            "subtitle": "设备端处理。不上云。无需账户。",
        },
        "06": {
            "title": [[("按你的方式", "ember")], [("清出空间。", "paper")]],
            "subtitle": "清除前，先看你选中的容量一点点累加。",
        },
    },
    "es": {
        "01": {
            "title": [[("DESLIZA. ", "ink"), ("DECIDE.", "burn")], [("LISTO.", "keep")]],
            "subtitle": "Conserva o elimina con un gesto. Nada se borra hasta que confirmes.",
        },
        "02": {
            "title": [[("ELIMINA ", "burn")], [("EL DESORDEN.", "paper")]],
            "subtitle": "Desliza a la izquierda. La foto entra en tu lista - no en la papelera.",
        },
        "03": {
            "title": [[("CONSERVA ", "keep")], [("LO QUE IMPORTA.", "paper")]],
            "subtitle": "Desliza a la derecha para conservar la foto. Tu sitio queda guardado.",
        },
        "04": {
            "title": [[("REVISA", "ember")], [("ANTES DE", "ink")], [("BORRAR.", "burn")]],
            "subtitle": "Mira cada miniatura. Quita lo que aún quieres. Luego confirma.",
        },
        "05": {
            "title": [[("TUS FOTOS", "paper")], [("SE QUEDAN EN EL IPHONE.", "keep")]],
            "subtitle": "En el dispositivo. Sin subidas a la nube. Sin cuenta.",
        },
        "06": {
            "title": [[("LIBERA ESPACIO", "ember")], [("A TU MANERA.", "paper")]],
            "subtitle": "Mira cómo suma el almacenamiento elegido antes de eliminar nada.",
        },
    },
    "uk": {
        "01": {
            "title": [[("ГОРТАЙ. ", "ink"), ("ОБИРАЙ.", "burn")], [("ГОТОВО.", "keep")]],
            "subtitle": "Збережіть або видаліть одним жестом. Нічого не зникне, доки ви не підтвердите.",
        },
        "02": {
            "title": [[("ПРИБЕРІТЬ ", "burn")], [("ЗАЙВЕ.", "paper")]],
            "subtitle": "Вліво. Фото потрапляє в список видалення - не одразу в кошик.",
        },
        "03": {
            "title": [[("ЗБЕРЕЖІТЬ ", "keep")], [("ВАЖЛИВЕ.", "paper")]],
            "subtitle": "Вправо, щоб зберегти знімок. Ваше місце лишається записаним.",
        },
        "04": {
            "title": [[("ПЕРЕВІРТЕ", "ember")], [("ПЕРЕД", "ink")], [("ВИДАЛЕННЯМ.", "burn")]],
            "subtitle": "Побачте кожну мініатюру. Приберіть те, що хочете лишити. Потім підтвердіть.",
        },
        "05": {
            "title": [[("ФОТО ЛИШАЮТЬСЯ", "paper")], [("НА IPHONE.", "keep")]],
            "subtitle": "На пристрої. Без хмарних завантажень. Без облікового запису.",
        },
        "06": {
            "title": [[("ЗВІЛЬНІТЬ МІСЦЕ", "ember")], [("ПО-СВОЄМУ.", "paper")]],
            "subtitle": "Дивіться, як накопичується обраний обсяг, перш ніж щось зникне.",
        },
    },
}

OUTPUT_NAMES = {
    "01": "01-swipe-decide-done.png",
    "02": "02-burn-the-clutter.png",
    "03": "03-keep-what-matters.png",
    "04": "04-review-before-delete.png",
    "05": "05-photos-stay-on-iphone.png",
    "06": "06-clear-space-your-way.png",
}

STORE_LOCALES = [
    "en",
    "nl",
    "fr",
    "de",
    "it",
    "ja",
    "ko",
    "pl",
    "pt-BR",
    "zh-Hans",
    "es",
    "uk",
]
