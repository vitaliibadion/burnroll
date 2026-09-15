#!/usr/bin/env python3
"""Generate BurnRoll/Localizable.xcstrings and InfoPlist.xcstrings."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LOCALES = ["nl", "fr", "de", "it", "ja", "ko", "pl", "pt-BR", "zh-Hans", "es", "uk"]

# English key -> translations in LOCALES order.
STRINGS: dict[str, list[str]] = {}


def add(en: str, *values: str) -> None:
    if len(values) != len(LOCALES):
        raise ValueError(f"{en!r} has {len(values)} translations, expected {len(LOCALES)}")
    STRINGS[en] = list(values)


def t(en: str, nl: str, fr: str, de: str, it: str, ja: str, ko: str, pl: str, pt: str, zh: str, es: str, uk: str) -> None:
    add(en, nl, fr, de, it, ja, ko, pl, pt, zh, es, uk)


# Keep / Burn and core chrome
t("Keep", "Bewaren", "Garder", "Behalten", "Tieni", "残す", "유지", "Zachowaj", "Manter", "保留", "Conservar", "Зберегти")
t("Burn", "Wissen", "Brûler", "Brennen", "Brucia", "削除", "삭제", "Usuń", "Queimar", "清除", "Eliminar", "Видалити")
t("KEEP", "BEWAREN", "GARDER", "BEHALTEN", "TIENI", "残す", "유지", "ZACHOWAJ", "MANTER", "保留", "CONSERVAR", "ЗБЕРЕГТИ")
t("BURN", "WISSEN", "BRÛLER", "BRENNEN", "BRUCIA", "削除", "삭제", "USUŃ", "QUEIMAR", "清除", "ELIMINAR", "ВИДАЛИТИ")
t("Undo last decision", "Laatste keuze ongedaan maken", "Annuler le dernier choix", "Letzte Entscheidung rückgängig", "Annulla l’ultima scelta", "直前の選択を取り消す", "마지막 선택 취소", "Cofnij ostatnią decyzję", "Desfazer a última decisão", "撤销上一次选择", "Deshacer la última decisión", "Скасувати останнє рішення")
t("Settings", "Instellingen", "Réglages", "Einstellungen", "Impostazioni", "設定", "설정", "Ustawienia", "Ajustes", "设置", "Ajustes", "Налаштування")
t("Done", "Gereed", "OK", "Fertig", "Fine", "完了", "완료", "Gotowe", "OK", "完成", "Hecho", "Готово")
t("Cancel", "Annuleren", "Annuler", "Abbrechen", "Annulla", "キャンセル", "취소", "Anuluj", "Cancelar", "取消", "Cancelar", "Скасувати")
t("Close", "Sluiten", "Fermer", "Schließen", "Chiudi", "閉じる", "닫기", "Zamknij", "Fechar", "关闭", "Cerrar", "Закрити")
t("Continue", "Doorgaan", "Continuer", "Weiter", "Continua", "続ける", "계속", "Dalej", "Continuar", "继续", "Continuar", "Продовжити")
t("OK", "OK", "OK", "OK", "OK", "OK", "확인", "OK", "OK", "好", "OK", "OK")
t("Photo", "Foto", "Photo", "Foto", "Foto", "写真", "사진", "Zdjęcie", "Foto", "照片", "Foto", "Фото")
t("Video", "Video", "Vidéo", "Video", "Video", "ビデオ", "동영상", "Wideo", "Vídeo", "视频", "Vídeo", "Відео")
t("All", "Alles", "Tout", "Alle", "Tutto", "すべて", "전체", "Wszystkie", "Tudo", "全部", "Todo", "Усе")
t("Recent", "Recent", "Récent", "Zuletzt", "Recenti", "最近", "최근", "Ostatnie", "Recentes", "最近", "Recientes", "Недавні")
t("Total", "Totaal", "Total", "Gesamt", "Totale", "合計", "전체", "Razem", "Total", "总计", "Total", "Усього")
t("Processed", "Verwerkt", "Traités", "Erledigt", "Elaborati", "処理済み", "완료", "Przejrzane", "Processados", "已处理", "Procesados", "Опрацьовано")
t("Remaining", "Resterend", "Restants", "Übrig", "Rimanenti", "残り", "남음", "Pozostało", "Restantes", "剩余", "Restantes", "Залишилось")
t("Reviewed", "Bekeken", "Déjà vus", "Geprüft", "Già visti", "確認済み", "검토됨", "Przejrzane", "Revisados", "已审阅", "Revisados", "Переглянуто")
t("Not reviewed", "Niet bekeken", "Non vus", "Ungesehen", "Da vedere", "未確認", "미검토", "Nieprzejrzane", "Não revisados", "未审阅", "Sin revisar", "Не переглянуто")
t("All items", "Alle items", "Tous les éléments", "Alle Elemente", "Tutti gli elementi", "すべての項目", "전체 항목", "Wszystkie elementy", "Todos os itens", "全部项目", "Todos los elementos", "Усі елементи")
t("Recents", "Recente", "Récents", "Zuletzt", "Recenti", "最近", "최근 항목", "Ostatnie", "Recentes", "最近项目", "Recientes", "Недавні")
t("Recently Added", "Onlangs toegevoegd", "Ajoutés récemment", "Zuletzt hinzugefügt", "Aggiunti di recente", "最近追加", "최근 추가됨", "Ostatnio dodane", "Adicionados recentemente", "最近添加", "Añadidos recientemente", "Нещодавно додані")
t("Favorites", "Favorieten", "Favoris", "Favoriten", "Preferiti", "お気に入り", "즐겨찾기", "Ulubione", "Favoritos", "个人收藏", "Favoritos", "Обране")
t("Photos", "Foto’s", "Photos", "Fotos", "Foto", "写真", "사진", "Zdjęcia", "Fotos", "照片", "Fotos", "Фото")
t("Videos", "Video’s", "Vidéos", "Videos", "Video", "ビデオ", "동영상", "Filmy", "Vídeos", "视频", "Vídeos", "Відео")
t("Library", "Bibliotheek", "Bibliothèque", "Mediathek", "Libreria", "ライブラリ", "보관함", "Biblioteka", "Biblioteca", "资料库", "Fototeca", "Бібліотека")
t("Media Types", "Mediatypen", "Types de médias", "Medientypen", "Tipi di media", "メディアの種類", "미디어 유형", "Typy multimediów", "Tipos de mídia", "媒体类型", "Tipos de contenido", "Типи медіа")
t("Albums", "Albums", "Albums", "Alben", "Album", "アルバム", "앨범", "Albumy", "Álbuns", "相簿", "Álbumes", "Альбоми")
t("Album", "Album", "Album", "Album", "Album", "アルバム", "앨범", "Album", "Álbum", "相簿", "Álbum", "Альбом")
t("Selfies", "Selfies", "Selfies", "Selfies", "Selfie", "セルフィー", "셀카", "Selfie", "Selfies", "自拍", "Selfies", "Селфі")
t("Live Photos", "Live Photos", "Live Photos", "Live Photos", "Live Photo", "Live Photos", "Live Photos", "Live Photos", "Live Photos", "实况照片", "Live Photos", "Live Photos")
t("Portrait", "Portret", "Portrait", "Porträt", "Ritratto", "ポートレート", "인물 사진", "Portret", "Retrato", "人像", "Retrato", "Портрет")
t("Panoramas", "Panorama’s", "Panoramas", "Panoramen", "Panorami", "パノラマ", "파노라마", "Panoramy", "Panoramas", "全景", "Panorámicas", "Панорами")
t("Time-lapse", "Time-lapse", "Accéléré", "Zeitraffer", "Time-lapse", "タイムラプス", "타임랩스", "Time-lapse", "Time-lapse", "延时摄影", "Cámara rápida", "Таймлапс")
t("Slo-mo", "Slo-mo", "Ralenti", "Slo-Mo", "Slow motion", "スローモーション", "슬로모션", "Slo-mo", "Câmera lenta", "慢动作", "Cámara lenta", "Уповільнена зйомка")
t("Cinematic", "Cinematic", "Cinématique", "Cinematic", "Cinematiche", "シネマティック", "시네마틱", "Kinowe", "Cinemático", "电影效果", "Cinemático", "Кінематографічні")
t("Bursts", "Burst", "Rafales", "Serien", "Raffiche", "バースト", "버스트", "Serie", "Rajadas", "连拍", "Ráfagas", "Серії")
t("Screenshots", "Schermafbeeldingen", "Captures d’écran", "Screenshots", "Screenshot", "スクリーンショット", "스크린샷", "Zrzuty ekranu", "Capturas de tela", "截屏", "Capturas de pantalla", "Знімки екрана")
t("Screen Recordings", "Schermopnamen", "Enregistrements d’écran", "Bildschirmaufnahmen", "Registrazioni schermo", "画面収録", "화면 기록", "Nagrania ekranu", "Gravações de tela", "屏幕录制", "Grabaciones de pantalla", "Записи екрана")
t("Spatial", "Spatial", "Spatiales", "Spatial", "Spatial", "空間", "공간", "Przestrzenne", "Espacial", "空间", "Espacial", "Просторові")
t("RAW", "RAW", "RAW", "RAW", "RAW", "RAW", "RAW", "RAW", "RAW", "RAW", "RAW", "RAW")
t("Animated", "Geanimeerd", "Animées", "Animiert", "Animate", "アニメーション", "움직이는 항목", "Animowane", "Animados", "动图", "Animadas", "Анімовані")
t("Long Exposures", "Lange belichting", "Poses longues", "Langzeitbelichtung", "Lunga esposizione", "長時間露光", "장노출", "Długie naświetlanie", "Longa exposição", "长曝光", "Larga exposición", "Довга витримка")

t("All caught up. No items left to review.", "Helemaal bij. Niets meer om te bekijken.", "Tout est à jour. Plus rien à revoir.", "Alles erledigt. Nichts mehr zu prüfen.", "Tutto in pari. Niente da rivedere.", "すべて完了。確認するものはありません。", "모두 따라잡았습니다. 검토할 항목이 없습니다.", "Wszystko aktualne. Nie ma nic do przejrzenia.", "Tudo em dia. Nada mais para revisar.", "已经全部完成。没有待审阅的内容。", "Todo al día. No queda nada por revisar.", "Усе актуально. Немає що переглядати.")
t("%lld items left to review.", "Nog %lld items te bekijken.", "%lld éléments à revoir.", "Noch %lld Elemente zu prüfen.", "%lld elementi da rivedere.", "未確認が%lld件あります。", "검토할 항목이 %lld개 남았습니다.", "Zostało %lld elementów do przejrzenia.", "%lld itens para revisar.", "还有 %lld 项待审阅。", "Quedan %lld elementos por revisar.", "Залишилось переглянути %lld елементів.")
t("Last cleanup", "Laatste opruiming", "Dernier nettoyage", "Letzte Bereinigung", "Ultima pulizia", "前回の整理", "최근 정리", "Ostatnie czyszczenie", "Última limpeza", "上次清理", "Última limpieza", "Останнє очищення")
t("potential", "potentieel", "potentiel", "potenziell", "potenziale", "見込み", "예상", "potencjalnie", "potencial", "预计", "potencial", "орієнтовно")
t("Review", "Beoordelen", "Revoir", "Prüfen", "Rivedi", "確認", "검토", "Przegląd", "Revisar", "审阅", "Revisar", "Перегляд")
t("Capture date unavailable", "Opnamedatum onbekend", "Date de capture indisponible", "Aufnahmedatum unbekannt", "Data di scatto non disponibile", "撮影日不明", "촬영일 없음", "Brak daty zdjęcia", "Data da captura indisponível", "拍摄日期不可用", "Fecha de captura no disponible", "Дата зйомки недоступна")
t("Your latest choices will appear here", "Je laatste keuzes verschijnen hier", "Tes derniers choix apparaîtront ici", "Deine letzten Entscheidungen erscheinen hier", "Le tue ultime scelte compariranno qui", "最新の選択がここに表示されます", "최근 선택이 여기에 나타납니다", "Tutaj pojawią się ostatnie decyzje", "Suas últimas escolhas aparecem aqui", "你最近的选择会显示在这里", "Tus últimas decisiones aparecerán aquí", "Тут з’являться ваші останні рішення")

# Onboarding
t("A quick refresher.", "Even opfrissen.", "Un petit rappel.", "Eine kurze Auffrischung.", "Un rapido ripasso.", "おさらいです。", "간단히 다시 보기.", "Krótkie przypomnienie.", "Uma revisão rápida.", "快速回顾。", "Un recordatorio rápido.", "Коротке нагадування.")
t("Burn the clutter.\nKeep the memories.", "Wis de rommel.\nBewaar de herinneringen.", "Brûle le superflu.\nGarde les souvenirs.", "Brenn das Überflüssige.\nBehalte die Erinnerungen.", "Togli il superfluo.\nTieni i ricordi.", "不要な写真は削除。\n思い出は残す。", "잡동사니는 지우고\n추억은 남기세요.", "Usuń bałagan.\nZachowaj wspomnienia.", "Queime a bagunça.\nMantenha as memórias.", "清掉杂乱。\n留下回忆。", "Elimina el desorden.\nConserva los recuerdos.", "Приберіть зайве.\nЗбережіть спогади.")
t("Your reviewed items stay marked. This is just a reminder of how BurnRoll works.", "Je bekeken items blijven gemarkeerd. Dit is alleen een herinnering hoe BurnRoll werkt.", "Tes éléments déjà vus restent marqués. C’est juste un rappel du fonctionnement de BurnRoll.", "Bereits geprüfte Elemente bleiben markiert. Das ist nur eine Erinnerung, wie BurnRoll funktioniert.", "Gli elementi già visti restano contrassegnati. È solo un ripasso di come funziona BurnRoll.", "確認済みの項目はそのままです。BurnRollの使い方の再確認です。", "이미 검토한 항목은 그대로 유지됩니다. BurnRoll 사용 방법만 다시 안내합니다.", "Przejrzane elementy pozostają oznaczone. To tylko przypomnienie, jak działa BurnRoll.", "Itens já revisados continuam marcados. Isto é só um lembrete de como o BurnRoll funciona.", "已审阅的项目仍会保留标记。这只是提醒 BurnRoll 的用法。", "Tus elementos revisados siguen marcados. Es solo un recordatorio de cómo funciona BurnRoll.", "Переглянуті елементи залишаються позначеними. Це лише нагадування, як працює BurnRoll.")
t("Swipe through your camera roll one decision at a time. Your library and settings stay as they are.", "Veeg door je camerastream, één keuze tegelijk. Je bibliotheek en instellingen blijven zoals ze zijn.", "Fais défiler ta pellicule, une décision à la fois. Ta bibliothèque et tes réglages restent inchangés.", "Wische dich durch die Mediathek, eine Entscheidung nach der anderen. Mediathek und Einstellungen bleiben unverändert.", "Scorri il rullino una decisione alla volta. Libreria e impostazioni restano com’è.", "カメラロールを一枚ずつ判断します。ライブラリと設定はそのままです。", "카메라 롤을 한 장씩 결정하세요. 보관함과 설정은 그대로입니다.", "Przeglądaj rolkę zdjęcie po zdjęciu. Biblioteka i ustawienia zostają bez zmian.", "Passe o rolo uma decisão de cada vez. A biblioteca e os ajustes ficam como estão.", "一张一张地划过相册。资料库和设置保持不变。", "Desliza el carrete, una decisión cada vez. Tu fototeca y ajustes no cambian.", "Гортайте стрічку по одному рішенню. Бібліотека й налаштування залишаються як є.")
t("Clear your camera roll one thoughtful decision at a time.", "Ruim je camerastream op, één bewuste keuze tegelijk.", "Range ta pellicule, une décision réfléchie à la fois.", "Räume die Mediathek auf – eine bewusste Entscheidung nach der anderen.", "Riordina il rullino, una decisione consapevole alla volta.", "カメラロールを、一枚ずつ丁寧に整理。", "카메라 롤을 한 장씩 신중하게 정리하세요.", "Posprzątaj rolkę, jedna przemyślana decyzja na raz.", "Limpe o rolo, uma decisão consciente de cada vez.", "一张一张地认真整理相册。", "Limpia el carrete, una decisión consciente cada vez.", "Очищайте стрічку — по одному обдуманому рішенню.")
t("Swipe. Decide. Done.", "Veeg. Kies. Klaar.", "Glisse. Décide. Terminé.", "Wischen. Entscheiden. Fertig.", "Scorri. Decidi. Fatto.", "スワイプ。選ぶ。完了。", "스와이프. 결정. 끝.", "Przesuń. Zdecyduj. Gotowe.", "Deslize. Decida. Pronto.", "轻滑。决定。完成。", "Desliza. Decide. Listo.", "Гортай. Обирай. Готово.")
t("Swipe left to Burn. Swipe right to Keep. The first photo will show you both.", "Veeg naar links om te wissen. Veeg naar rechts om te bewaren. De eerste foto toont beide.", "Glisse à gauche pour brûler. Glisse à droite pour garder. La première photo montre les deux.", "Wische nach links zum Brennen. Wische nach rechts zum Behalten. Das erste Foto zeigt beides.", "Scorri a sinistra per bruciare. A destra per tenere. La prima foto mostra entrambi.", "左にスワイプで削除、右で残す。最初の写真で両方を案内します。", "왼쪽으로 밀면 삭제, 오른쪽으로 밀면 유지. 첫 사진에서 둘 다 보여 줍니다.", "W lewo, aby usunąć. W prawo, aby zachować. Pierwsze zdjęcie pokaże oba gesty.", "Deslize à esquerda para queimar. À direita para manter. A primeira foto mostra os dois.", "向左滑清除，向右滑保留。第一张照片会示范两种手势。", "Desliza a la izquierda para eliminar. A la derecha para conservar. La primera foto muestra ambos.", "Вліво — видалити. Вправо — зберегти. Перше фото покаже обидва жести.")
t("Keep or burn with one gesture. Nothing deletes until you confirm.", "Bewaren of wissen met één gebaar. Niets verdwijnt tot je bevestigt.", "Garde ou brûle d’un geste. Rien n’est supprimé avant confirmation.", "Behalten oder brennen mit einer Geste. Nichts wird gelöscht, bis du bestätigst.", "Tieni o brucia con un gesto. Niente si elimina finché non confermi.", "一手で残すか削除。確認するまで消えません。", "한 제스처로 유지 또는 삭제. 확인 전에는 지워지지 않습니다.", "Zachowaj lub usuń jednym gestem. Nic nie znika, dopóki nie potwierdzisz.", "Mantenha ou queime com um gesto. Nada some até você confirmar.", "一个手势即可保留或清除。确认前不会删除。", "Conserva o elimina con un gesto. Nada se borra hasta que confirmes.", "Збережіть або видаліть одним жестом. Нічого не зникне, доки ви не підтвердите.")
t("Undo a Keep or Burn.", "Maak Bewaren of Wissen ongedaan.", "Annule un Garder ou un Brûler.", "Behalten oder Brennen rückgängig.", "Annulla un Tieni o un Brucia.", "残す／削除を取り消す。", "유지 또는 삭제를 취소하세요.", "Cofnij Zachowaj lub Usuń.", "Desfaça um Manter ou Queimar.", "撤销保留或清除。", "Deshaz un Conservar o Eliminar.", "Скасуйте «Зберегти» або «Видалити».")
t("The middle button takes back your last decision. That item leaves Reviewed and the burn list, so you can choose again.", "De middelste knop maakt je laatste keuze ongedaan. Dat item verlaat Bekeken en de wislijst, zodat je opnieuw kunt kiezen.", "Le bouton du milieu annule ton dernier choix. L’élément quitte Déjà vus et la liste à brûler, pour que tu puisses choisir à nouveau.", "Die mittlere Taste nimmt die letzte Entscheidung zurück. Das Element verlässt Geprüft und die Brennliste, damit du neu wählen kannst.", "Il pulsante centrale annulla l’ultima scelta. L’elemento esce da Già visti e dalla lista da bruciare, così puoi decidere di nuovo.", "中央のボタンで直前の判断を取り消します。確認済みと削除リストから外れ、もう一度選べます。", "가운데 버튼이 마지막 선택을 되돌립니다. 해당 항목은 검토됨과 삭제 목록에서 빠져 다시 고를 수 있습니다.", "Środkowy przycisk cofa ostatnią decyzję. Element znika z Przejrzanych i listy do usunięcia, żebyś mógł wybrać ponownie.", "O botão do meio desfaz a última decisão. O item sai de Revisados e da lista de queima, para você escolher de novo.", "中间的按钮撤销上一次选择。该项目会离开已审阅和清除列表，你可以再选一次。", "El botón del centro deshace la última decisión. El elemento sale de Revisados y de la lista de eliminación para que elijas otra vez.", "Середня кнопка скасовує останнє рішення. Елемент зникає з «Переглянуто» і списку видалення, тож можна обрати знову.")
t("Nothing burns by accident.", "Niets wordt per ongeluk gewist.", "Rien ne brûle par accident.", "Nichts brennt aus Versehen.", "Niente si brucia per sbaglio.", "誤って削除されることはありません。", "실수로 삭제되지 않습니다.", "Nic nie znika przez przypadek.", "Nada é queimado por acidente.", "不会误删。", "Nada se elimina por accidente.", "Нічого не зникне випадково.")
t("Items you've already reviewed stay marked. Confirm again before anything is deleted.", "Items die je al hebt bekeken blijven gemarkeerd. Bevestig opnieuw voordat iets wordt verwijderd.", "Les éléments déjà vus restent marqués. Confirme encore avant toute suppression.", "Bereits geprüfte Elemente bleiben markiert. Bestätige erneut, bevor etwas gelöscht wird.", "Gli elementi già visti restano contrassegnati. Conferma di nuovo prima di qualsiasi eliminazione.", "確認済みの項目はマークされたままです。削除の前に再確認します。", "이미 검토한 항목은 표시가 유지됩니다. 삭제 전에 다시 확인하세요.", "Przejrzane elementy zostają oznaczone. Potwierdź ponownie, zanim cokolwiek zostanie usunięte.", "Itens já revisados continuam marcados. Confirme de novo antes de qualquer exclusão.", "已审阅的项目仍会保留标记。删除前会再次确认。", "Los elementos que ya revisaste siguen marcados. Confirma otra vez antes de borrar nada.", "Переглянуті елементи лишаються позначеними. Підтвердіть ще раз, перш ніж щось видалиться.")
t("Review everything before deletion.", "Bekijk alles vóór verwijdering.", "Passe tout en revue avant suppression.", "Prüfe alles vor dem Löschen.", "Rivedi tutto prima dell’eliminazione.", "削除の前にすべて確認します。", "삭제 전에 모두 검토하세요.", "Przejrzyj wszystko przed usunięciem.", "Revise tudo antes de excluir.", "删除前请全部审阅。", "Revisa todo antes de borrar.", "Перегляньте все перед видаленням.")
t("Review before you delete.", "Kijk na voor je wist.", "Vérifie avant d’effacer.", "Prüfen vor dem Löschen.", "Rivedi prima di eliminare.", "削除の前に確認。", "삭제 전에 검토.", "Sprawdź przed usunięciem.", "Revise antes de excluir.", "删除前再看一遍。", "Revisa antes de borrar.", "Перевірте перед видаленням.")
t("See every thumbnail. Drop anything you still want. Then confirm.", "Zie elke thumbnail. Haal weg wat je wilt houden. Daarna bevestigen.", "Vois chaque miniature. Retire ce que tu veux garder. Puis confirme.", "Sieh jedes Vorschaubild. Nimm runter, was du behalten willst. Dann bestätigen.", "Vedi ogni miniatura. Togli ciò che vuoi tenere. Poi conferma.", "サムネイルを全部見て、残したいものは外してから確定。", "모든 미리보기를 보고, 남길 것은 뺀 다음 확인하세요.", "Zobacz każdą miniaturę. Odrzuć to, co chcesz zostawić. Potem potwierdź.", "Veja cada miniatura. Tire o que ainda quer. Depois confirme.", "查看每张缩略图，拿掉还想留的，然后再确认。", "Mira cada miniatura. Quita lo que aún quieres. Luego confirma.", "Побачте кожну мініатюру. Приберіть те, що хочете лишити. Потім підтвердіть.")
t("Clear space your way.", "Ruimte vrij op jouw manier.", "Libère l’espace à ta façon.", "Speicher frei auf deine Art.", "Libera spazio a modo tuo.", "空き容量はあなたのペースで。", "용량은 내 방식대로.", "Wolne miejsce po twojemu.", "Libere espaço do seu jeito.", "按你的方式清出空间。", "Libera espacio a tu manera.", "Звільніть місце по-своєму.")
t("Watch the storage you selected add up before anything is burned.", "Zie de gekozen opslag optellen voordat iets wordt gewist.", "Vois s’additionner l’espace choisi avant toute suppression.", "Sieh den gewählten Speicher wachsen, bevor etwas brennt.", "Guarda lo spazio scelto accumularsi prima di qualsiasi bruciatura.", "削除の前に、選んだ容量が積み上がるのを確認できます。", "삭제하기 전에 선택한 용량이 쌓이는 것을 확인하세요.", "Patrz, jak sumuje się wybrana pamięć, zanim cokolwiek zniknie.", "Veja o armazenamento escolhido somar antes de qualquer queima.", "清除前，先看你选中的容量一点点累加。", "Mira cómo suma el almacenamiento elegido antes de eliminar nada.", "Дивіться, як накопичується обраний обсяг, перш ніж щось зникне.")
t("Got it", "Begrepen", "Compris", "Verstanden", "Capito", "了解", "알겠어요", "Rozumiem", "Entendi", "知道了", "Entendido", "Зрозуміло")
t("Continue to Photos", "Verder naar Foto’s", "Continuer vers Photos", "Weiter zu Fotos", "Continua verso Foto", "写真へ進む", "사진으로 계속", "Przejdź do Zdjęć", "Continuar para Fotos", "继续前往照片", "Continuar a Fotos", "Перейти до Фото")

# Paywall
t("Keep what matters.", "Bewaar wat telt.", "Garde l’essentiel.", "Behalte, was zählt.", "Tieni l’essenziale.", "大切な一枚は残す。", "중요한 샷은 유지.", "Zachowaj to, co ważne.", "Mantenha o que importa.", "留下重要的。", "Conserva lo que importa.", "Збережіть важливе.")
t("Try BurnRoll free for 3 days.", "Probeer BurnRoll 3 dagen gratis.", "Essaie BurnRoll gratuitement pendant 3 jours.", "Teste BurnRoll 3 Tage kostenlos.", "Prova BurnRoll gratis per 3 giorni.", "BurnRollを3日間無料で試す。", "BurnRoll을 3일간 무료로 써 보세요.", "Wypróbuj BurnRoll za darmo przez 3 dni.", "Experimente o BurnRoll grátis por 3 dias.", "免费试用 BurnRoll 3 天。", "Prueba BurnRoll gratis 3 días.", "Спробуйте BurnRoll безкоштовно 3 дні.")
t("No payment now. Unlimited Keep and Burn while you clear space your way.", "Nu niks betalen. Onbeperkt Bewaren en Wissen terwijl je ruimte vrijmaakt op jouw manier.", "Rien à payer maintenant. Garder et Brûler en illimité pendant que tu libères de l’espace à ta façon.", "Jetzt nichts zahlen. Unbegrenzt Behalten und Brennen, während du Speicher auf deine Art freigibst.", "Niente da pagare ora. Tieni e Brucia senza limiti mentre liberi spazio a modo tuo.", "今は支払い不要。自分のペースで整理しながら、残す／削除を無制限に。", "지금은 결제 없음. 내 방식대로 공간을 비우며 유지와 삭제를 무제한으로.", "Nic nie płacisz teraz. Bez limitu Zachowaj i Usuń, gdy zwalniasz miejsce po swojemu.", "Nada a pagar agora. Manter e Queimar sem limite enquanto você libera espaço do seu jeito.", "现在无需付款。按你的方式清出空间，无限保留或清除。", "Nada que pagar ahora. Conserva y elimina sin límite mientras liberas espacio a tu manera.", "Зараз нічого не платите. Необмежені «Зберегти» й «Видалити», поки звільняєте місце по-своєму.")
t("How the free trial works.", "Zo werkt de proefperiode.", "Comment fonctionne l’essai gratuit.", "So funktioniert die Testphase.", "Come funziona la prova gratuita.", "無料トライアルのしくみ。", "무료 체험 이용 방법.", "Jak działa darmowy okres.", "Como funciona o teste grátis.", "免费试用如何运作。", "Cómo funciona la prueba gratis.", "Як працює безкоштовний період.")
t("Unlimited access from today. You're charged in 2 days unless you cancel first.", "Vanaf vandaag onbeperkte toegang. Over 2 dagen wordt er afgeschreven tenzij je eerder opzegt.", "Accès illimité dès aujourd’hui. Tu es facturé dans 2 jours sauf si tu annules avant.", "Unbegrenzter Zugriff ab heute. In 2 Tagen wird abgebucht, wenn du nicht vorher kündigst.", "Accesso illimitato da oggi. Ti addebitiamo tra 2 giorni, salvo disdetta prima.", "今すぐ無制限。2日後に課金されます。それまでに解約できます。", "오늘부터 무제한. 먼저 취소하지 않으면 2일 후 결제됩니다.", "Nieograniczony dostęp od dziś. Obciążenie za 2 dni, chyba że wcześniej anulujesz.", "Acesso ilimitado a partir de hoje. A cobrança é em 2 dias, a menos que você cancele antes.", "即日起无限使用。若未取消，将在 2 天后扣款。", "Acceso ilimitado desde hoy. Se cobra en 2 días salvo que canceles antes.", "Необмежений доступ від сьогодні. Списання за 2 дні, якщо раніше не скасуєте.")
t("3 days free. Then the plan you pick. Cancel anytime before you're billed.", "3 dagen gratis. Daarna het plan dat je kiest. Zeg op vóór de betaling.", "3 jours gratuits. Ensuite le forfait choisi. Annule avant d’être facturé.", "3 Tage kostenlos. Dann der gewählte Plan. Vor der Abbuchung kündbar.", "3 giorni gratis. Poi il piano che scegli. Disdici prima dell’addebito.", "3日間無料。その後は選んだプラン。課金前ならいつでも解約。", "3일 무료. 그다음 선택한 요금제. 결제 전에 언제든 취소.", "3 dni za darmo. Potem wybrany plan. Anuluj przed obciążeniem.", "3 dias grátis. Depois o plano escolhido. Cancele antes da cobrança.", "3 天免费，随后按所选方案。扣款前可随时取消。", "3 días gratis. Luego el plan que elijas. Cancela antes del cobro.", "3 дні безкоштовно. Потім обраний план. Скасуйте до списання.")
t("Choose your plan.", "Kies je plan.", "Choisis ton forfait.", "Wähle deinen Plan.", "Scegli il tuo piano.", "プランを選ぶ。", "요금제를 선택하세요.", "Wybierz plan.", "Escolha seu plano.", "选择你的方案。", "Elige tu plan.", "Оберіть план.")
t("Weekly", "Wekelijks", "Hebdomadaire", "Wöchentlich", "Settimanale", "週ごと", "주간", "Tygodniowo", "Semanal", "每周", "Semanal", "Щотижня")
t("Monthly", "Maandelijks", "Mensuel", "Monatlich", "Mensile", "月ごと", "월간", "Miesięcznie", "Mensal", "每月", "Mensual", "Щомісяця")
t("Annually", "Jaarlijks", "Annuel", "Jährlich", "Annuale", "年ごと", "연간", "Rocznie", "Anual", "每年", "Anual", "Щороку")
t("per week", "per week", "par semaine", "pro Woche", "a settimana", "週あたり", "매주", "tygodniowo", "por semana", "每周", "por semana", "на тиждень")
t("per month", "per maand", "par mois", "pro Monat", "al mese", "月あたり", "매월", "miesięcznie", "por mês", "每月", "al mes", "на місяць")
t("per year", "per jaar", "par an", "pro Jahr", "all’anno", "年あたり", "매년", "rocznie", "por ano", "每年", "al año", "на рік")
t("Best value", "Beste deal", "Meilleur tarif", "Bestes Angebot", "Più conveniente", "いちばんお得", "최고 혜택", "Najlepsza oferta", "Melhor valor", "最划算", "Mejor precio", "Найвигідніше")
t("Free trial selected", "Proefperiode gekozen", "Essai gratuit choisi", "Testphase gewählt", "Prova gratuita selezionata", "無料トライアルを選択中", "무료 체험 선택됨", "Wybrano darmowy okres", "Teste grátis selecionado", "已选择免费试用", "Prueba gratis seleccionada", "Обрано безкоштовний період")
t("3 days only. Cancel anytime.", "Slechts 3 dagen. Zeg wanneer je wilt op.", "3 jours seulement. Annule à tout moment.", "Nur 3 Tage. Jederzeit kündbar.", "Solo 3 giorni. Disdici quando vuoi.", "3日間のみ。いつでも解約できます。", "3일만. 언제든 취소하세요.", "Tylko 3 dni. Anuluj w dowolnej chwili.", "Apenas 3 dias. Cancele quando quiser.", "仅限 3 天。可随时取消。", "Solo 3 días. Cancela cuando quieras.", "Лише 3 дні. Скасуйте будь-коли.")
t("3 days free, then %@ per week", "3 dagen gratis, daarna %@ per week", "3 jours gratuits, puis %@ par semaine", "3 Tage gratis, dann %@ pro Woche", "3 giorni gratis, poi %@ a settimana", "3日間無料、その後%@ / 週", "3일 무료, 이후 매주 %@", "3 dni za darmo, potem %@ tygodniowo", "3 dias grátis, depois %@ por semana", "3 天免费，随后每周 %@", "3 días gratis, luego %@ por semana", "3 дні безкоштовно, потім %@ на тиждень")
t("Pay now · %@", "Nu betalen · %@", "Payer maintenant · %@", "Jetzt kaufen · %@", "Acquista ora · %@", "今すぐ購入 · %@", "지금 구매 · %@", "Kup teraz · %@", "Pagar agora · %@", "立即购买 · %@", "Pagar ahora · %@", "Купити зараз · %@")
t("Subscribe now", "Nu abonneren", "S’abonner maintenant", "Jetzt abonnieren", "Abbonati ora", "今すぐ登録", "지금 구독", "Subskrybuj teraz", "Assinar agora", "立即订阅", "Suscribirse ahora", "Підписатися зараз")
t("Start 3-day free trial", "Start 3 dagen gratis", "Commencer l’essai de 3 jours", "3 Tage testen", "Avvia prova di 3 giorni", "3日間の無料トライアルを開始", "3일 무료 체험 시작", "Zacznij 3 dni za darmo", "Começar teste de 3 dias", "开始 3 天免费试用", "Empezar prueba de 3 días", "Почати 3 дні безкоштовно")
t("Starting…", "Starten…", "Démarrage…", "Startet…", "Avvio…", "開始中…", "시작 중…", "Uruchamianie…", "Iniciando…", "正在开始…", "Empezando…", "Запуск…")
t("Restore purchases", "Aankopen herstellen", "Restaurer les achats", "Käufe wiederherstellen", "Ripristina acquisti", "購入を復元", "구입 항목 복원", "Przywróć zakupy", "Restaurar compras", "恢复购买", "Restaurar compras", "Відновити покупки")
t("3 days free", "3 dagen gratis", "3 jours gratuits", "3 Tage gratis", "3 giorni gratis", "3日間無料", "3일 무료", "3 dni za darmo", "3 dias grátis", "3 天免费", "3 días gratis", "3 дні безкоштовно")
t("No payment now", "Nu niks betalen", "Rien à payer", "Nichts zahlen", "Niente da pagare", "今は無料", "지금 결제 없음", "Bez opłat teraz", "Nada a pagar", "现在无需付款", "Nada que pagar", "Зараз без оплати")
t("Unlimited access", "Onbeperkte toegang", "Accès illimité", "Unbegrenzter Zugriff", "Accesso illimitato", "無制限アクセス", "무제한 이용", "Nieograniczony dostęp", "Acesso ilimitado", "无限使用", "Acceso ilimitado", "Необмежений доступ")
t("Today", "Vandaag", "Aujourd’hui", "Heute", "Oggi", "今日", "오늘", "Dziś", "Hoje", "今天", "Hoy", "Сьогодні")
t("Unlimited Keep and Burn. Nothing to pay.", "Onbeperkt Bewaren en Wissen. Niets te betalen.", "Garder et Brûler en illimité. Rien à payer.", "Unbegrenzt Behalten und Brennen. Nichts zu zahlen.", "Tieni e Brucia senza limiti. Niente da pagare.", "残す／削除は無制限。支払いは不要。", "유지와 삭제 무제한. 결제 없음.", "Bez limitu Zachowaj i Usuń. Nic nie płacisz.", "Manter e Queimar sem limite. Nada a pagar.", "无限保留或清除。无需付款。", "Conserva y elimina sin límite. Nada que pagar.", "Необмежені «Зберегти» й «Видалити». Нічого не платите.")
t("In 2 days", "Over 2 dagen", "Dans 2 jours", "In 2 Tagen", "Tra 2 giorni", "2日後", "2일 후", "Za 2 dni", "Em 2 dias", "2 天后", "En 2 días", "За 2 дні")
t("A reminder before charging. Cancel if you want.", "Een herinnering vóór afschrijving. Zeg op als je wilt.", "Un rappel avant facturation. Annule si tu veux.", "Eine Erinnerung vor der Abbuchung. Kündige, wenn du willst.", "Un promemoria prima dell’addebito. Disdici se vuoi.", "課金前にお知らせ。不要なら解約できます。", "결제 전 알림. 원하면 취소하세요.", "Przypomnienie przed obciążeniem. Anuluj, jeśli chcesz.", "Um lembrete antes da cobrança. Cancele se quiser.", "扣款前会提醒。不想继续可取消。", "Un aviso antes del cobro. Cancela si quieres.", "Нагадування перед списанням. Скасуйте, якщо треба.")
t("Unless you cancel", "Tenzij je opzegt", "Sauf annulation", "Wenn du nicht kündigst", "Se non disdici", "解約しない場合", "취소하지 않으면", "Jeśli nie anulujesz", "Se não cancelar", "若未取消", "Si no cancelas", "Якщо не скасуєте")
t("Your plan starts. Cancel earlier in Subscriptions.", "Je plan start. Zeg eerder op via Abonnementen.", "Ton forfait commence. Annule avant dans Abonnements.", "Dein Plan startet. Kündige früher unter Abos.", "Il piano parte. Disdici prima in Abbonamenti.", "プランが始まります。サブスクリプションで先に解約できます。", "요금제가 시작됩니다. 구독에서 먼저 취소하세요.", "Plan się zaczyna. Anuluj wcześniej w Subskrypcjach.", "Seu plano começa. Cancele antes em Assinaturas.", "方案将开始。可提前在“订阅”中取消。", "Empieza tu plan. Cancela antes en Suscripciones.", "План почнеться. Скасуйте раніше в «Підписках».")
t("Payment is charged to your Apple Account after the 3-day trial. The plan renews automatically unless you cancel at least 24 hours before the period ends. Cancel in Settings → Apple Account → Subscriptions.", "Na 3 dagen wordt je Apple Account belast. Het plan verlengt automatisch tenzij je minstens 24 uur voor het einde opzegt. Zeg op in Instellingen → Apple Account → Abonnementen.", "Le paiement est débité sur ton compte Apple après 3 jours. Le forfait se renouvelle sauf annulation au moins 24 h avant la fin. Annule dans Réglages → Compte Apple → Abonnements.", "Nach 3 Tagen wird dein Apple-Account belastet. Der Plan verlängert sich automatisch, wenn du nicht mindestens 24 Stunden vorher kündigst. Kündigen in Einstellungen → Apple-Account → Abos.", "L’addebito sul tuo Apple Account avviene dopo 3 giorni. Il piano si rinnova salvo disdetta almeno 24 ore prima. Disdici in Impostazioni → Account Apple → Abbonamenti.", "3日後にApple Accountへ請求されます。期間終了の24時間前までに解約しないと自動更新されます。設定 → Apple Account → サブスクリプションで解約。", "3일 후 Apple 계정으로 결제됩니다. 기간 종료 최소 24시간 전에 취소하지 않으면 자동 갱신됩니다. 설정 → Apple 계정 → 구독에서 취소하세요.", "Po 3 dniach obciążymy Twoje konto Apple. Plan odnawia się automatycznie, chyba że anulujesz co najmniej 24 godziny wcześniej. Anuluj w Ustawieniach → Konto Apple → Subskrypcje.", "A cobrança vai para sua Conta Apple após 3 dias. O plano renova automaticamente se você não cancelar pelo menos 24 horas antes. Cancele em Ajustes → Conta Apple → Assinaturas.", "3 天试用后将从你的 Apple 账户扣款。除非至少提前 24 小时取消，否则会自动续订。在“设置 → Apple 账户 → 订阅”中取消。", "El cobro se carga a tu cuenta Apple tras 3 días. El plan se renueva si no cancelas al menos 24 horas antes. Cancela en Ajustes → Cuenta de Apple → Suscripciones.", "Після 3 днів кошти спишуться з облікового запису Apple. План поновлюється автоматично, якщо не скасувати щонайменше за 24 години. Скасуйте в Параметрах → Обліковий запис Apple → Підписки.")
t("Payment is charged to your Apple Account at confirmation. The plan renews automatically unless you cancel at least 24 hours before the period ends. Cancel in Settings → Apple Account → Subscriptions.", "Bij bevestiging wordt je Apple Account belast. Het plan verlengt automatisch tenzij je minstens 24 uur voor het einde opzegt. Zeg op in Instellingen → Apple Account → Abonnementen.", "Le paiement est débité sur ton compte Apple à la confirmation. Le forfait se renouvelle sauf annulation au moins 24 h avant la fin. Annule dans Réglages → Compte Apple → Abonnements.", "Bei Bestätigung wird dein Apple-Account belastet. Der Plan verlängert sich automatisch, wenn du nicht mindestens 24 Stunden vorher kündigst. Kündigen in Einstellungen → Apple-Account → Abos.", "L’addebito sul tuo Apple Account avviene alla conferma. Il piano si rinnova salvo disdetta almeno 24 ore prima. Disdici in Impostazioni → Account Apple → Abbonamenti.", "確認時にApple Accountへ請求されます。期間終了の24時間前までに解約しないと自動更新されます。設定 → Apple Account → サブスクリプションで解約。", "확인 시 Apple 계정으로 결제됩니다. 기간 종료 최소 24시간 전에 취소하지 않으면 자동 갱신됩니다. 설정 → Apple 계정 → 구독에서 취소하세요.", "Przy potwierdzeniu obciążymy Twoje konto Apple. Plan odnawia się automatycznie, chyba że anulujesz co najmniej 24 godziny wcześniej. Anuluj w Ustawieniach → Konto Apple → Subskrypcje.", "A cobrança vai para sua Conta Apple na confirmação. O plano renova automaticamente se você não cancelar pelo menos 24 horas antes. Cancele em Ajustes → Conta Apple → Assinaturas.", "确认时将从你的 Apple 账户扣款。除非至少提前 24 小时取消，否则会自动续订。在“设置 → Apple 账户 → 订阅”中取消。", "El cobro se carga a tu cuenta Apple al confirmar. El plan se renueva si no cancelas al menos 24 horas antes. Cancela en Ajustes → Cuenta de Apple → Suscripciones.", "Під час підтвердження кошти спишуться з облікового запису Apple. План поновлюється автоматично, якщо не скасувати щонайменше за 24 години. Скасуйте в Параметрах → Обліковий запис Apple → Підписки.")
t("Terms of Use", "Gebruiksvoorwaarden", "Conditions d’utilisation", "Nutzungsbedingungen", "Termini di utilizzo", "利用規約", "이용 약관", "Warunki użytkowania", "Termos de uso", "使用条款", "Términos de uso", "Умови використання")
t("Couldn't load plans. Check your connection and try again.", "Plannen laden mislukt. Controleer je verbinding en probeer opnieuw.", "Impossible de charger les forfaits. Vérifie la connexion et réessaie.", "Pläne konnten nicht geladen werden. Prüfe die Verbindung und versuche es erneut.", "Impossibile caricare i piani. Controlla la connessione e riprova.", "プランを読み込めません。接続を確認してもう一度試してください。", "요금제를 불러오지 못했습니다. 연결을 확인하고 다시 시도하세요.", "Nie udało się wczytać planów. Sprawdź połączenie i spróbuj ponownie.", "Não foi possível carregar os planos. Verifique a conexão e tente de novo.", "无法加载方案。请检查网络后重试。", "No se pudieron cargar los planes. Comprueba la conexión e inténtalo de nuevo.", "Не вдалося завантажити плани. Перевірте з’єднання й спробуйте знову.")
t("Purchase couldn't be verified. Try again.", "Aankoop kon niet worden geverifieerd. Probeer opnieuw.", "L’achat n’a pas pu être vérifié. Réessaie.", "Kauf konnte nicht bestätigt werden. Versuche es erneut.", "Acquisto non verificato. Riprova.", "購入を確認できませんでした。もう一度試してください。", "구입을 확인하지 못했습니다. 다시 시도하세요.", "Nie udało się zweryfikować zakupu. Spróbuj ponownie.", "Não foi possível verificar a compra. Tente de novo.", "无法验证购买。请重试。", "No se pudo verificar la compra. Inténtalo de nuevo.", "Не вдалося підтвердити покупку. Спробуйте ще раз.")
t("Purchase is pending approval.", "Aankoop wacht op goedkeuring.", "L’achat est en attente d’approbation.", "Kauf wartet auf Freigabe.", "Acquisto in attesa di approvazione.", "購入は承認待ちです。", "구입이 승인 대기 중입니다.", "Zakup oczekuje na zatwierdzenie.", "A compra está aguardando aprovação.", "购买正在等待批准。", "La compra está pendiente de aprobación.", "Покупка очікує схвалення.")
t("Purchase couldn't be completed. Try again.", "Aankoop niet voltooid. Probeer opnieuw.", "L’achat n’a pas pu aboutir. Réessaie.", "Kauf konnte nicht abgeschlossen werden. Versuche es erneut.", "Acquisto non completato. Riprova.", "購入を完了できませんでした。もう一度試してください。", "구입을 완료하지 못했습니다. 다시 시도하세요.", "Nie udało się dokończyć zakupu. Spróbuj ponownie.", "Não foi possível concluir a compra. Tente de novo.", "无法完成购买。请重试。", "No se pudo completar la compra. Inténtalo de nuevo.", "Не вдалося завершити покупку. Спробуйте ще раз.")
t("No purchases to restore.", "Geen aankopen om te herstellen.", "Aucun achat à restaurer.", "Keine Käufe zum Wiederherstellen.", "Nessun acquisto da ripristinare.", "復元する購入はありません。", "복원할 구입 항목이 없습니다.", "Brak zakupów do przywrócenia.", "Não há compras para restaurar.", "没有可恢复的购买。", "No hay compras que restaurar.", "Немає покупок для відновлення.")
t("Couldn't restore purchases. Try again.", "Aankopen herstellen mislukt. Probeer opnieuw.", "Impossible de restaurer les achats. Réessaie.", "Käufe konnten nicht wiederhergestellt werden. Versuche es erneut.", "Impossibile ripristinare gli acquisti. Riprova.", "購入を復元できませんでした。もう一度試してください。", "구입을 복원하지 못했습니다. 다시 시도하세요.", "Nie udało się przywrócić zakupów. Spróbuj ponownie.", "Não foi possível restaurar as compras. Tente de novo.", "无法恢复购买。请重试。", "No se pudieron restaurar las compras. Inténtalo de nuevo.", "Не вдалося відновити покупки. Спробуйте ще раз.")
t("Purchases restored.", "Aankopen hersteld.", "Achats restaurés.", "Käufe wiederhergestellt.", "Acquisti ripristinati.", "購入を復元しました。", "구입을 복원했습니다.", "Przywrócono zakupy.", "Compras restauradas.", "已恢复购买。", "Compras restauradas.", "Покупки відновлено.")
t("Bring back a trial or plan bought with this Apple Account", "Zet een proef of plan van dit Apple Account terug", "Récupère un essai ou forfait acheté avec ce compte Apple", "Hole Test oder Plan dieses Apple-Accounts zurück", "Ripristina prova o piano di questo Apple Account", "このApple Accountで購入したトライアルやプランを戻す", "이 Apple 계정으로 구매한 체험 또는 요금제 복원", "Przywróć okres próbny lub plan z tego konta Apple", "Trazer de volta um teste ou plano desta Conta Apple", "恢复此 Apple 账户购买的试用或方案", "Recupera una prueba o plan de esta cuenta de Apple", "Повернути пробний період або план цього облікового запису Apple")
t("Apple’s standard licensed application end user license", "Apple’s standaard licentie voor gelicentieerde apps", "Licence standard Apple pour les apps sous licence", "Apples Standard-EULA für lizenzierte Apps", "Licenza standard Apple per le app con licenza", "Appleの標準ライセンスドアプリケーション使用許諾", "Apple 표준 라이선스 앱 사용권", "Standardowa licencja Apple na aplikacje licencjonowane", "Licença padrão da Apple para apps licenciados", "Apple 标准许可应用程序最终用户许可协议", "Licencia estándar de Apple para apps con licencia", "Стандартна ліцензія Apple для ліцензованих програм")

# Permission
t("Your memories stay yours.", "Jouw herinneringen blijven van jou.", "Tes souvenirs restent les tiens.", "Deine Erinnerungen bleiben bei dir.", "I tuoi ricordi restano tuoi.", "思い出はあなたのまま。", "추억은 당신의 것입니다.", "Twoje wspomnienia zostają u Ciebie.", "Suas memórias continuam suas.", "回忆只属于你。", "Tus recuerdos se quedan contigo.", "Ваші спогади лишаються вашими.")
t("BurnRoll processes your library on this iPhone. Photos access is needed to show items and delete only after you confirm.", "BurnRoll verwerkt je bibliotheek op deze iPhone. Toegang tot Foto’s is nodig om items te tonen en pas na bevestiging te verwijderen.", "BurnRoll traite ta bibliothèque sur cet iPhone. L’accès à Photos est nécessaire pour afficher les éléments et supprimer seulement après confirmation.", "BurnRoll verarbeitet deine Mediathek auf diesem iPhone. Fotos-Zugriff ist nötig, um Elemente zu zeigen und erst nach Bestätigung zu löschen.", "BurnRoll elabora la libreria su questo iPhone. Serve l’accesso a Foto per mostrare gli elementi ed eliminarli solo dopo la conferma.", "BurnRollはこのiPhone上でライブラリを処理します。表示と、確認後の削除のために写真へのアクセスが必要です。", "BurnRoll은 이 iPhone에서 보관함을 처리합니다. 항목을 보여주고 확인 후에만 삭제하려면 사진 접근 권한이 필요합니다.", "BurnRoll przetwarza bibliotekę na tym iPhonie. Dostęp do Zdjęć jest potrzebny, aby pokazać elementy i usuwać je dopiero po potwierdzeniu.", "O BurnRoll processa a biblioteca neste iPhone. O acesso a Fotos é necessário para mostrar itens e excluir só depois da confirmação.", "BurnRoll 在此 iPhone 上处理资料库。需要照片权限才能显示项目，并仅在你确认后删除。", "BurnRoll procesa tu fototeca en este iPhone. Se necesita acceso a Fotos para mostrar elementos y borrar solo después de confirmar.", "BurnRoll обробляє бібліотеку на цьому iPhone. Потрібен доступ до Фото, щоб показувати елементи й видаляти лише після підтвердження.")
t("Open Settings", "Open Instellingen", "Ouvrir Réglages", "Einstellungen öffnen", "Apri Impostazioni", "設定を開く", "설정 열기", "Otwórz Ustawienia", "Abrir Ajustes", "打开设置", "Abrir Ajustes", "Відкрити Налаштування")
t("Requesting Access…", "Toegang vragen…", "Demande d’accès…", "Zugriff wird angefragt…", "Richiesta di accesso…", "アクセスを要求中…", "접근 권한 요청 중…", "Prośba o dostęp…", "Solicitando acesso…", "正在请求访问…", "Solicitando acceso…", "Запит доступу…")
t("Allow Photos Access", "Sta Foto’s-toegang toe", "Autoriser l’accès à Photos", "Fotos-Zugriff erlauben", "Consenti accesso a Foto", "写真へのアクセスを許可", "사진 접근 허용", "Zezwól na dostęp do Zdjęć", "Permitir acesso a Fotos", "允许访问照片", "Permitir acceso a Fotos", "Дозволити доступ до Фото")
t("100% ON-DEVICE PROCESSING", "100% OP HET APPARAAT", "TRAITEMENT 100 % SUR L’APPAREIL", "100 % AUF DEM GERÄT", "ELABORAZIONE 100% SUL DISPOSITIVO", "100%端末内で処理", "100% 기기 내 처리", "100% NA URZĄDZENIU", "100% NO DISPOSITIVO", "100% 设备端处理", "PROCESADO 100% EN EL DISPOSITIVO", "100% НА ПРИСТРОЇ")
t("BurnRoll never uploads your photos to its servers.", "BurnRoll uploadt je foto’s nooit naar eigen servers.", "BurnRoll n’envoie jamais tes photos vers ses serveurs.", "BurnRoll lädt deine Fotos nie auf eigene Server hoch.", "BurnRoll non carica mai le tue foto sui propri server.", "BurnRollが写真を自社サーバーにアップロードすることはありません。", "BurnRoll은 사진을 자체 서버에 업로드하지 않습니다.", "BurnRoll nigdy nie wysyła Twoich zdjęć na własne serwery.", "O BurnRoll nunca envia suas fotos para os próprios servidores.", "BurnRoll 绝不会把照片上传到自己的服务器。", "BurnRoll nunca sube tus fotos a sus servidores.", "BurnRoll ніколи не завантажує ваші фото на свої сервери.")
t("No photo contents in analytics.  •  No account required.", "Geen foto-inhoud in analytics.  •  Geen account nodig.", "Aucun contenu photo dans les analyses.  •  Aucun compte requis.", "Keine Fotoinhalte in der Analyse.  •  Kein Konto nötig.", "Nessun contenuto foto nelle analisi.  •  Nessun account richiesto.", "分析に写真内容は含まれません。  •  アカウント不要。", "분석에 사진 내용 없음.  •  계정 불필요.", "Brak treści zdjęć w analityce.  •  Konto nie jest wymagane.", "Nenhum conteúdo de foto nas análises.  •  Sem conta.", "分析不含照片内容。  •  无需账户。", "Sin contenido de fotos en analítica.  •  Sin cuenta.", "Немає вмісту фото в аналітиці.  •  Обліковий запис не потрібен.")
t("BurnRoll needs Photos access so you can review and safely delete the items you choose.", "BurnRoll heeft toegang tot Foto’s nodig om items te bekijken en veilig te verwijderen.", "BurnRoll a besoin de l’accès à Photos pour que tu puisses revoir et supprimer en toute sécurité.", "BurnRoll braucht Fotos-Zugriff, damit du Elemente prüfen und sicher löschen kannst.", "BurnRoll necessita dell’accesso a Foto per rivedere ed eliminare in sicurezza gli elementi che scegli.", "選んだ項目を確認し安全に削除するには、写真へのアクセスが必要です。", "선택한 항목을 검토하고 안전하게 삭제하려면 사진 접근 권한이 필요합니다.", "BurnRoll potrzebuje dostępu do Zdjęć, abyś mógł przeglądać i bezpiecznie usuwać wybrane elementy.", "O BurnRoll precisa de acesso a Fotos para você revisar e excluir com segurança os itens escolhidos.", "BurnRoll 需要照片权限，以便你审阅并安全删除所选项目。", "BurnRoll necesita acceso a Fotos para que revises y borres con seguridad lo que elijas.", "BurnRoll потребує доступу до Фото, щоб ви могли переглядати й безпечно видаляти обрані елементи.")
t("Photos access is not available.", "Toegang tot Foto’s is niet beschikbaar.", "L’accès à Photos n’est pas disponible.", "Fotos-Zugriff ist nicht verfügbar.", "L’accesso a Foto non è disponibile.", "写真へのアクセスは利用できません。", "사진 접근을 사용할 수 없습니다.", "Dostęp do Zdjęć jest niedostępny.", "O acesso a Fotos não está disponível.", "无法使用照片权限。", "El acceso a Fotos no está disponible.", "Доступ до Фото недоступний.")

# Welcome
t("Nothing is deleted until you review and confirm.", "Niets wordt verwijderd tot je bekijkt en bevestigt.", "Rien n’est supprimé tant que tu n’as pas revu et confirmé.", "Nichts wird gelöscht, bis du prüfst und bestätigst.", "Niente viene eliminato finché non rivedi e confermi.", "確認するまで削除されません。", "검토하고 확인하기 전에는 삭제되지 않습니다.", "Nic nie zostanie usunięte, dopóki nie przejrzysz i nie potwierdzisz.", "Nada é excluído até você revisar e confirmar.", "在你审阅并确认之前不会删除。", "Nada se borra hasta que revises y confirmes.", "Нічого не видалиться, доки ви не переглянете й не підтвердите.")
t("No media to review", "Geen media om te bekijken", "Aucun média à revoir", "Keine Medien zum Prüfen", "Nessun elemento da rivedere", "確認するメディアがありません", "검토할 미디어 없음", "Brak multimediów do przejrzenia", "Nenhuma mídia para revisar", "没有可审阅的媒体", "No hay contenido que revisar", "Немає медіа для перегляду")
t("Review all again", "Alles opnieuw bekijken", "Tout revoir", "Alles erneut prüfen", "Rivedi tutto di nuovo", "すべて再確認", "전체 다시 검토", "Przejrzyj wszystko ponownie", "Revisar tudo de novo", "再次全部审阅", "Revisar todo otra vez", "Переглянути все знову")
t("Start burning", "Beginnen met wissen", "Commencer à brûler", "Mit Brennen starten", "Inizia a bruciare", "整理を始める", "정리 시작", "Zacznij usuwać", "Começar a queimar", "开始清理", "Empezar a eliminar", "Почати видалення")
t("Continue burning", "Doorgaan met wissen", "Continuer à brûler", "Weiter brennen", "Continua a bruciare", "整理を続ける", "정리 계속", "Kontynuuj usuwanie", "Continuar a queimar", "继续清理", "Seguir eliminando", "Продовжити видалення")
t("all caught up", "helemaal bij", "tout est à jour", "alles erledigt", "tutto in pari", "すべて完了", "모두 따라잡음", "wszystko zrobione", "tudo em dia", "已全部完成", "todo al día", "усе актуально")
t("left to review", "nog te bekijken", "à revoir", "noch zu prüfen", "da rivedere", "未確認", "검토 남음", "do przejrzenia", "para revisar", "待审阅", "por revisar", "ще переглянути")
t("New photos will appear automatically.", "Nieuwe foto’s verschijnen automatisch.", "Les nouvelles photos apparaissent automatiquement.", "Neue Fotos erscheinen automatisch.", "Le nuove foto compaiono automaticamente.", "新しい写真は自動で表示されます。", "새 사진은 자동으로 나타납니다.", "Nowe zdjęcia pojawią się automatycznie.", "Novas fotos aparecem automaticamente.", "新照片会自动出现。", "Las fotos nuevas aparecen solas.", "Нові фото з’являться автоматично.")
t("Your bookmark keeps your place between cleanups.", "Je bladwijzer onthoudt waar je was tussen opruimingen.", "Ton signet garde ta place entre les nettoyages.", "Dein Lesezeichen merkt sich den Stand zwischen Bereinigungen.", "Il segnalibro ricorda il punto tra una pulizia e l’altra.", "ブックマークが整理の続きを覚えます。", "북마크가 정리 사이 위치를 기억합니다.", "Zakładka zapamiętuje miejsce między czyszczeniami.", "O marcador guarda seu lugar entre limpezas.", "书签会记住两次清理之间的位置。", "El marcador guarda tu sitio entre limpiezas.", "Закладка пам’ятає місце між очищеннями.")
t("Library checkpoint", "Bibliotheek-checkpoint", "Point de contrôle", "Checkpoint", "Punto di controllo", "しおり", "체크포인트", "Punkt kontrolny", "Ponto da biblioteca", "资料库检查点", "Punto de la fototeca", "Контрольна точка")
t("%lld percent reviewed", "%lld procent bekeken", "%lld pour cent déjà vus", "%lld Prozent geprüft", "%lld percento già visti", "%lldパーセント確認済み", "%lld% 완료", "%lld procent przejrzane", "%lld por cento revisados", "已审阅 %lld%", "%lld por ciento revisado", "%lld% переглянуто")
t("item burned", "item gewist", "élément brûlé", "Element gebrannt", "elemento bruciato", "件を削除", "항목 삭제됨", "element usunięty", "item queimado", "项已清除", "elemento eliminado", "елемент видалено")
t("items burned", "items gewist", "éléments brûlés", "Elemente gebrannt", "elementi bruciati", "件を削除", "항목 삭제됨", "elementy usunięte", "itens queimados", "项已清除", "elementos eliminados", "елементи видалено")
t("potential space", "potentiële ruimte", "espace potentiel", "potenzieller Speicher", "spazio potenziale", "見込み容量", "예상 용량", "potencjalne miejsce", "espaço potencial", "预计空间", "espacio potencial", "орієнтовний простір")

# Cleaner empty / review
t("Checkpoint saved", "Checkpoint opgeslagen", "Point de contrôle enregistré", "Checkpoint gespeichert", "Punto di controllo salvato", "しおりを保存しました", "체크포인트 저장됨", "Zapisano punkt kontrolny", "Ponto salvo", "检查点已保存", "Punto guardado", "Контрольну точку збережено")
t("You’re all caught up", "Je bent helemaal bij", "Tout est à jour", "Du bist auf dem neuesten Stand", "Sei in pari", "すべて完了です", "모두 따라잡았습니다", "Wszystko aktualne", "Você está em dia", "已经全部完成", "Estás al día", "Усе актуально")
t("Nothing left to review", "Niets meer om te bekijken", "Plus rien à revoir", "Nichts mehr zu prüfen", "Niente da rivedere", "確認するものはありません", "검토할 항목이 없습니다", "Nie ma nic do przejrzenia", "Nada mais para revisar", "没有待审阅的内容", "No queda nada por revisar", "Немає що переглядати")
t("No reviewed items", "Geen bekeken items", "Aucun élément déjà vu", "Keine geprüften Elemente", "Nessun elemento già visto", "確認済みの項目はありません", "검토한 항목 없음", "Brak przejrzanych elementów", "Nenhum item revisado", "没有已审阅项目", "No hay elementos revisados", "Немає переглянутих елементів")
t("No media found", "Geen media gevonden", "Aucun média trouvé", "Keine Medien gefunden", "Nessun media trovato", "メディアが見つかりません", "미디어를 찾을 수 없음", "Nie znaleziono multimediów", "Nenhuma mídia encontrada", "未找到媒体", "No se encontró contenido", "Медіа не знайдено")
t("Choose another media type or album from the top-left button.", "Kies een ander mediatype of album via de knop linksboven.", "Choisis un autre type de média ou album avec le bouton en haut à gauche.", "Wähle einen anderen Medientyp oder ein Album über die Taste oben links.", "Scegli un altro tipo di media o album dal pulsante in alto a sinistra.", "左上のボタンから別の種類やアルバムを選んでください。", "왼쪽 위 버튼에서 다른 미디어 유형이나 앨범을 선택하세요.", "Wybierz inny typ multimediów lub album przyciskiem u góry po lewej.", "Escolha outro tipo de mídia ou álbum no botão superior esquerdo.", "点左上角按钮选择其他媒体类型或相簿。", "Elige otro tipo de contenido o álbum con el botón de arriba a la izquierda.", "Оберіть інший тип медіа або альбом кнопкою зліва вгорі.")
t("Make a Keep or Burn decision first, or choose Not reviewed or All items.", "Maak eerst een Bewaren- of Wissen-keuze, of kies Niet bekeken of Alle items.", "Fais d’abord un choix Garder ou Brûler, ou choisis Non vus ou Tous les éléments.", "Triff zuerst eine Behalten- oder Brennen-Entscheidung oder wähle Ungesehen oder Alle Elemente.", "Fai prima una scelta Tieni o Brucia, oppure scegli Da vedere o Tutti gli elementi.", "先に残すか削除するかを選ぶか、未確認またはすべての項目を選んでください。", "먼저 유지 또는 삭제를 선택하거나, 미검토 또는 전체 항목을 고르세요.", "Najpierw wybierz Zachowaj lub Usuń albo włącz Nieprzejrzane lub Wszystkie elementy.", "Faça primeiro uma decisão Manter ou Queimar, ou escolha Não revisados ou Todos os itens.", "请先做出保留或清除的决定，或选择未审阅或全部项目。", "Haz primero una decisión Conservar o Eliminar, o elige Sin revisar o Todos los elementos.", "Спочатку оберіть «Зберегти» чи «Видалити», або виберіть «Не переглянуто» чи «Усі елементи».")
t("Choose review status, media type, or album", "Kies beoordelingsstatus, mediatype of album", "Choisir le statut, le type de média ou l’album", "Prüfstatus, Medientyp oder Album wählen", "Scegli stato di revisione, tipo di media o album", "確認状況、メディアの種類、アルバムを選ぶ", "검토 상태, 미디어 유형 또는 앨범 선택", "Wybierz status, typ multimediów lub album", "Escolher status, tipo de mídia ou álbum", "选择审阅状态、媒体类型或相簿", "Elige estado de revisión, tipo de contenido o álbum", "Оберіть статус перегляду, тип медіа або альбом")
t("Makes the same decision as swiping the current item", "Zelfde keuze als vegen bij het huidige item", "Même décision que le geste sur l’élément actuel", "Dieselbe Entscheidung wie beim Wischen des aktuellen Elements", "La stessa scelta dello swipe sull’elemento attuale", "現在の項目をスワイプしたときと同じ判断です", "현재 항목을 스와이프한 것과 같은 결정입니다", "Ta sama decyzja co gest na bieżącym elemencie", "A mesma decisão que deslizar o item atual", "与滑动当前项目相同的决定", "La misma decisión que al deslizar el elemento actual", "Те саме рішення, що й жест на поточному елементі")
t("Swipe left to burn or right to keep. Double tap to open fullscreen.", "Veeg naar links om te wissen of naar rechts om te bewaren. Dubbeltik voor volledig scherm.", "Glisse à gauche pour brûler ou à droite pour garder. Double toucher pour le plein écran.", "Wische nach links zum Brennen oder nach rechts zum Behalten. Doppeltippen öffnet Vollbild.", "Scorri a sinistra per bruciare o a destra per tenere. Tocca due volte per lo schermo intero.", "左スワイプで削除、右で残す。ダブルタップで全画面。", "왼쪽 스와이프는 삭제, 오른쪽은 유지. 두 번 탭하면 전체 화면.", "W lewo, aby usunąć, w prawo, aby zachować. Podwójne stuknięcie otwiera pełny ekran.", "Deslize à esquerda para queimar ou à direita para manter. Toque duas vezes para tela cheia.", "向左滑清除，向右滑保留。点两下打开全屏。", "Desliza a la izquierda para eliminar o a la derecha para conservar. Toca dos veces para pantalla completa.", "Вліво — видалити, вправо — зберегти. Двічі торкніться для повного екрана.")

# Review sheet
t("Review decisions", "Keuzes bekijken", "Revoir les décisions", "Entscheidungen prüfen", "Rivedi le decisioni", "判断を確認", "결정 검토", "Przegląd decyzji", "Revisar decisões", "审阅决定", "Revisar decisiones", "Перегляд рішень")
t("Decision filter", "Keuzefilter", "Filtre de décision", "Entscheidungsfilter", "Filtro decisioni", "判断フィルター", "결정 필터", "Filtr decyzji", "Filtro de decisão", "决定筛选", "Filtro de decisiones", "Фільтр рішень")
t("Kept", "Bewaard", "Gardés", "Behalten", "Tenuti", "残した", "유지됨", "Zachowane", "Mantidos", "已保留", "Conservados", "Збережено")
t("Nothing reviewed yet", "Nog niets bekeken", "Rien n’a encore été revu", "Noch nichts geprüft", "Ancora niente da rivedere", "まだ確認していません", "아직 검토한 항목이 없습니다", "Nie przejrzano jeszcze nic", "Nada revisado ainda", "还没有审阅任何内容", "Aún no hay nada revisado", "Ще нічого не переглянуто")
t("Keep swiping. Every Keep and Burn decision will appear here.", "Blijf vegen. Elke Bewaren- en Wissen-keuze verschijnt hier.", "Continue à glisser. Chaque Garder et Brûler apparaîtra ici.", "Wische weiter. Jede Behalten- und Brennen-Entscheidung erscheint hier.", "Continua a scorrere. Ogni Tieni e Brucia comparirà qui.", "スワイプを続けてください。残す／削除の判断がここに表示されます。", "계속 스와이프하세요. 유지와 삭제 결정이 여기에 나타납니다.", "Przesuwaj dalej. Każda decyzja Zachowaj i Usuń pojawi się tutaj.", "Continue deslizando. Cada Manter e Queimar aparece aqui.", "继续滑动。每次保留和清除都会显示在这里。", "Sigue deslizando. Cada Conservar y Eliminar aparecerá aquí.", "Гортайте далі. Кожне «Зберегти» й «Видалити» з’явиться тут.")
t("Change the filter to review your other decisions.", "Wijzig het filter om je andere keuzes te bekijken.", "Change le filtre pour voir tes autres décisions.", "Ändere den Filter, um die anderen Entscheidungen zu sehen.", "Cambia il filtro per rivedere le altre decisioni.", "フィルターを切り替えて他の判断を確認できます。", "필터를 바꿔 다른 결정을 검토하세요.", "Zmień filtr, aby zobaczyć pozostałe decyzje.", "Mude o filtro para ver as outras decisões.", "更改筛选以查看其他决定。", "Cambia el filtro para ver el resto de decisiones.", "Змініть фільтр, щоб переглянути інші рішення.")
t("Nothing marked to burn", "Niets gemarkeerd om te wissen", "Rien à brûler", "Nichts zum Brennen markiert", "Niente da bruciare", "削除対象はありません", "삭제할 항목 없음", "Nic nieoznaczone do usunięcia", "Nada marcado para queimar", "没有标记要清除的项目", "Nada marcado para eliminar", "Нічого не позначено для видалення")
t("Deleting…", "Verwijderen…", "Suppression…", "Wird gelöscht…", "Eliminazione…", "削除中…", "삭제 중…", "Usuwanie…", "Excluindo…", "正在删除…", "Eliminando…", "Видалення…")
t("Couldn’t delete items", "Items verwijderen mislukt", "Impossible de supprimer", "Elemente konnten nicht gelöscht werden", "Impossibile eliminare gli elementi", "項目を削除できませんでした", "항목을 삭제할 수 없음", "Nie udało się usunąć elementów", "Não foi possível excluir os itens", "无法删除项目", "No se pudieron eliminar los elementos", "Не вдалося видалити елементи")
t("Please try again, and confirm Delete when Photos asks.", "Probeer het opnieuw en bevestig Verwijderen wanneer Foto’s daarom vraagt.", "Réessaie et confirme Supprimer lorsque Photos le demande.", "Versuche es erneut und bestätige Löschen, wenn Fotos danach fragt.", "Riprova e conferma Elimina quando Foto lo chiede.", "もう一度試し、写真アプリが確認したら「削除」を選んでください。", "다시 시도하고, 사진 앱이 물으면 삭제를 확인하세요.", "Spróbuj ponownie i potwierdź Usuń, gdy Zdjęcia o to poproszą.", "Tente de novo e confirme Apagar quando Fotos pedir.", "请重试，并在“照片”询问时确认删除。", "Inténtalo de nuevo y confirma Borrar cuando Fotos te lo pida.", "Спробуйте ще раз і підтвердіть «Видалити», коли Фото запитає.")
t("These items move to Recently Deleted for up to 30 days. Photos will ask you to confirm.", "Deze items gaan tot 30 dagen naar Recent verwijderd. Foto’s vraagt om bevestiging.", "Ces éléments vont dans Récemment supprimés jusqu’à 30 jours. Photos te demandera confirmation.", "Diese Elemente landen bis zu 30 Tage in Zuletzt gelöscht. Fotos fragt zur Bestätigung.", "Questi elementi restano in Eliminati di recente fino a 30 giorni. Foto chiederà conferma.", "これらの項目は最大30日間「最近削除した項目」に入ります。写真アプリが確認を求めます。", "이 항목은 최대 30일 동안 최근 삭제된 항목으로 이동합니다. 사진 앱이 확인을 요청합니다.", "Te elementy trafią do Ostatnio usuniętych na maksymalnie 30 dni. Zdjęcia poproszą o potwierdzenie.", "Estes itens vão para Apagados recentemente por até 30 dias. Fotos pedirá confirmação.", "这些项目会进入“最近删除”最多 30 天。“照片”会要求你确认。", "Estos elementos irán a Eliminados hace poco hasta 30 días. Fotos te pedirá confirmación.", "Ці елементи потраплять у «Нещодавно видалені» до 30 днів. Фото попросить підтвердження.")
t("Cleaning complete", "Opruimen voltooid", "Nettoyage terminé", "Bereinigung abgeschlossen", "Pulizia completata", "整理が完了しました", "정리 완료", "Czyszczenie zakończone", "Limpeza concluída", "清理完成", "Limpieza completada", "Очищення завершено")
t("review time", "beoordeeltijd", "temps de revue", "Prüfzeit", "tempo di revisione", "確認時間", "검토 시간", "czas przeglądu", "tempo de revisão", "审阅用时", "tiempo de revisión", "час перегляду")
t("Opens this item so you can change Keep or Burn", "Opent dit item zodat je Bewaren of Wissen kunt wijzigen", "Ouvre cet élément pour changer Garder ou Brûler", "Öffnet dieses Element, damit du Behalten oder Brennen ändern kannst", "Apre questo elemento per cambiare Tieni o Brucia", "この項目を開き、残す／削除を変更できます", "이 항목을 열어 유지 또는 삭제를 바꿀 수 있습니다", "Otwiera ten element, aby zmienić Zachowaj lub Usuń", "Abre este item para mudar Manter ou Queimar", "打开此项目以更改保留或清除", "Abre este elemento para cambiar Conservar o Eliminar", "Відкриває цей елемент, щоб змінити «Зберегти» чи «Видалити»")
t("Opens this item so you can change the decision", "Opent dit item zodat je de keuze kunt wijzigen", "Ouvre cet élément pour changer la décision", "Öffnet dieses Element, damit du die Entscheidung ändern kannst", "Apre questo elemento per cambiare la decisione", "この項目を開き、判断を変更できます", "이 항목을 열어 결정을 바꿀 수 있습니다", "Otwiera ten element, aby zmienić decyzję", "Abre este item para mudar a decisão", "打开此项目以更改决定", "Abre este elemento para cambiar la decisión", "Відкриває цей елемент, щоб змінити рішення")
t("marked to burn", "gemarkeerd om te wissen", "marqué à brûler", "zum Brennen markiert", "contrassegnato da bruciare", "削除予定", "삭제 예정", "oznaczone do usunięcia", "marcado para queimar", "已标记清除", "marcado para eliminar", "позначено до видалення")
t("kept", "bewaard", "gardé", "behalten", "tenuto", "残した", "유지됨", "zachowane", "mantido", "已保留", "conservado", "збережено")
t("unknown date", "onbekende datum", "date inconnue", "unbekanntes Datum", "data sconosciuta", "日付不明", "날짜 없음", "nieznana data", "data desconhecida", "未知日期", "fecha desconocida", "невідома дата")

# Viewer
t("Mark as %@", "%@ markeren", "Marquer comme %@", "Als %@ markieren", "Segna come %@", "%@にする", "%@(으)로 표시", "Oznacz jako %@", "Marcar como %@", "标记为%@", "Marcar como %@", "Позначити як %@")
t("Selected", "Geselecteerd", "Sélectionné", "Ausgewählt", "Selezionato", "選択中", "선택됨", "Wybrano", "Selecionado", "已选择", "Seleccionado", "Вибрано")
t("Not selected", "Niet geselecteerd", "Non sélectionné", "Nicht ausgewählt", "Non selezionato", "未選択", "선택 안 됨", "Nie wybrano", "Não selecionado", "未选择", "No seleccionado", "Не вибрано")
t("Close fullscreen viewer", "Volledig scherm sluiten", "Fermer le plein écran", "Vollbild schließen", "Chiudi schermo intero", "全画面を閉じる", "전체 화면 닫기", "Zamknij pełny ekran", "Fechar tela cheia", "关闭全屏查看", "Cerrar pantalla completa", "Закрити повний екран")
t("Release to close", "Loslaten om te sluiten", "Relâche pour fermer", "Loslassen zum Schließen", "Rilascia per chiudere", "離して閉じる", "놓으면 닫힘", "Puść, aby zamknąć", "Solte para fechar", "松开即可关闭", "Suelta para cerrar", "Відпустіть, щоб закрити")
t("Swipe up", "Veeg omhoog", "Glisse vers le haut", "Nach oben wischen", "Scorri in alto", "上にスワイプ", "위로 스와이프", "Przesuń w górę", "Deslize para cima", "向上滑", "Desliza hacia arriba", "Гортніть угору")
t("Swipe down", "Veeg omlaag", "Glisse vers le bas", "Nach unten wischen", "Scorri in basso", "下にスワイプ", "아래로 스와이프", "Przesuń w dół", "Deslize para baixo", "向下滑", "Desliza hacia abajo", "Гортніть униз")
t("Fullscreen photo", "Foto volledig scherm", "Photo en plein écran", "Foto im Vollbild", "Foto a schermo intero", "全画面の写真", "전체 화면 사진", "Zdjęcie na pełnym ekranie", "Foto em tela cheia", "全屏照片", "Foto a pantalla completa", "Фото на весь екран")
t("Pinch or double tap to zoom. Swipe up or down to close when not zoomed.", "Knijp of dubbeltik om te zoomen. Veeg omhoog of omlaag om te sluiten als je niet ingezoomd bent.", "Pince ou double-touche pour zoomer. Glisse haut ou bas pour fermer hors zoom.", "Zum Zoomen kneifen oder doppeltippen. Nach oben oder unten wischen zum Schließen, wenn nicht gezoomt.", "Pizzica o tocca due volte per lo zoom. Scorri su o giù per chiudere se non sei ingrandito.", "ピンチまたはダブルタップでズーム。ズームしていなければ上下スワイプで閉じます。", "핀치 또는 두 번 탭하여 확대. 확대하지 않은 상태에서는 위나 아래로 밀어 닫습니다.", "Ściśnij lub stuknij dwukrotnie, aby powiększyć. Przesuń w górę lub w dół, aby zamknąć bez powiększenia.", "Belisque ou toque duas vezes para zoom. Deslize para cima ou para baixo para fechar sem zoom.", "捏合或点两下缩放。未放大时可上下滑动关闭。", "Pellizca o toca dos veces para zoom. Desliza arriba o abajo para cerrar si no hay zoom.", "Зведіть пальці або двічі торкніться для масштабу. Без збільшення проведіть угору чи вниз, щоб закрити.")
t("Preparing video…", "Video voorbereiden…", "Préparation de la vidéo…", "Video wird vorbereitet…", "Preparazione video…", "ビデオを準備中…", "동영상 준비 중…", "Przygotowywanie wideo…", "Preparando o vídeo…", "正在准备视频…", "Preparando el vídeo…", "Підготовка відео…")

# Picker / bookmark
t("Choose media", "Kies media", "Choisir les médias", "Medien wählen", "Scegli i media", "メディアを選ぶ", "미디어 선택", "Wybierz multimedia", "Escolher mídia", "选择媒体", "Elegir contenido", "Обрати медіа")
t("Review status", "Beoordelingsstatus", "Statut de revue", "Prüfstatus", "Stato di revisione", "確認状況", "검토 상태", "Status przeglądu", "Status da revisão", "审阅状态", "Estado de revisión", "Статус перегляду")
t("Bookmark", "Bladwijzer", "Signet", "Lesezeichen", "Segnalibro", "ブックマーク", "북마크", "Zakładka", "Marcador", "书签", "Marcador", "Закладка")
t("Review checkpoint", "Beoordelingscheckpoint", "Point de contrôle de revue", "Prüf-Checkpoint", "Punto di controllo della revisione", "確認のしおり", "검토 체크포인트", "Punkt kontrolny przeglądu", "Ponto de revisão", "审阅检查点", "Punto de revisión", "Контрольна точка перегляду")
t("Reset reviewed bookmark", "Bekeken-bladwijzer resetten", "Réinitialiser le signet déjà vus", "Geprüft-Lesezeichen zurücksetzen", "Reimposta il segnalibro già visti", "確認済みしおりをリセット", "검토 북마크 재설정", "Resetuj zakładkę przejrzanych", "Redefinir marcador revisado", "重置已审阅书签", "Restablecer marcador revisado", "Скинути закладку переглянутих")
t("Do you really want to reset your bookmark?", "Wil je je bladwijzer echt resetten?", "Tu veux vraiment réinitialiser le signet ?", "Willst du das Lesezeichen wirklich zurücksetzen?", "Vuoi davvero reimpostare il segnalibro?", "しおりを本当にリセットしますか？", "북마크를 정말 재설정할까요?", "Na pewno zresetować zakładkę?", "Quer mesmo redefinir o marcador?", "确定要重置书签吗？", "¿Seguro que quieres restablecer el marcador?", "Справді скинути закладку?")
t("Every item will become Not reviewed again. Your current Keep and Burn decisions will remain available in Review until this session ends.", "Elk item wordt weer Niet bekeken. Je huidige Bewaren- en Wissen-keuzes blijven in Beoordelen tot deze sessie eindigt.", "Chaque élément redevient Non vu. Tes Garder et Brûler restent dans Revoir jusqu’à la fin de cette session.", "Jedes Element wird wieder Ungesehen. Deine aktuellen Behalten- und Brennen-Entscheidungen bleiben unter Prüfen, bis die Sitzung endet.", "Ogni elemento torna Da vedere. Le scelte Tieni e Brucia restano in Rivedi fino alla fine di questa sessione.", "すべての項目が未確認に戻ります。現在の残す／削除は、このセッションが終わるまで確認画面で残ります。", "모든 항목이 다시 미검토가 됩니다. 현재 유지/삭제 결정은 이 세션이 끝날 때까지 검토에 남아 있습니다.", "Każdy element znów będzie Nieprzejrzany. Bieżące decyzje Zachowaj i Usuń zostaną w Przeglądzie do końca sesji.", "Cada item volta a Não revisados. Suas decisões Manter e Queimar ficam em Revisar até o fim desta sessão.", "所有项目会再次变为未审阅。当前的保留和清除决定在本会话结束前仍可在审阅中查看。", "Todos los elementos volverán a Sin revisar. Tus Conservar y Eliminar seguirán en Revisar hasta que termine esta sesión.", "Кожен елемент знову стане «Не переглянуто». Поточні «Зберегти» й «Видалити» лишаться в Перегляді до кінця сесії.")
t("Reset bookmark", "Bladwijzer resetten", "Réinitialiser le signet", "Lesezeichen zurücksetzen", "Reimposta segnalibro", "しおりをリセット", "북마크 재설정", "Resetuj zakładkę", "Redefinir marcador", "重置书签", "Restablecer marcador", "Скинути закладку")
t("The review bookmark could not be reset.", "De beoordelingsbladwijzer kon niet worden gereset.", "Le signet de revue n’a pas pu être réinitialisé.", "Das Prüf-Lesezeichen konnte nicht zurückgesetzt werden.", "Il segnalibro di revisione non è stato reimpostato.", "確認のしおりをリセットできませんでした。", "검토 북마크를 재설정할 수 없습니다.", "Nie udało się zresetować zakładki przeglądu.", "Não foi possível redefinir o marcador de revisão.", "无法重置审阅书签。", "No se pudo restablecer el marcador de revisión.", "Не вдалося скинути закладку перегляду.")
t("Bookmark wasn’t reset", "Bladwijzer is niet gereset", "Le signet n’a pas été réinitialisé", "Lesezeichen wurde nicht zurückgesetzt", "Il segnalibro non è stato reimpostato", "しおりはリセットされませんでした", "북마크가 재설정되지 않음", "Zakładka nie została zresetowana", "O marcador não foi redefinido", "书签未重置", "El marcador no se restableció", "Закладку не скинуто")
t("item remembered", "item onthouden", "élément mémorisé", "Element gemerkt", "elemento ricordato", "件を記憶", "항목 기억됨", "element zapamiętany", "item lembrado", "项已记住", "elemento recordado", "елемент запам’ятовано")
t("items remembered", "items onthouden", "éléments mémorisés", "Elemente gemerkt", "elementi ricordati", "件を記憶", "항목 기억됨", "elementy zapamiętane", "itens lembrados", "项已记住", "elementos recordados", "елементи запам’ятовано")
t("selected", "geselecteerd", "sélectionné", "ausgewählt", "selezionato", "選択中", "선택됨", "wybrano", "selecionado", "已选中", "seleccionado", "вибрано")
t("BurnRoll opens Not reviewed by default, so you continue where you stopped and new photos appear automatically. Categories and albums come from your Photos library. Hidden and Recently Deleted items are excluded.", "BurnRoll opent standaard Niet bekeken, zodat je verdergaat waar je stopte en nieuwe foto’s automatisch verschijnen. Categorieën en albums komen uit je Fotobibliotheek. Verborgen en Recent verwijderde items zijn uitgesloten.", "BurnRoll ouvre Non vus par défaut, pour reprendre où tu t’es arrêté, et les nouvelles photos apparaissent seules. Catégories et albums viennent de ta photothèque. Les éléments masqués et Récemment supprimés sont exclus.", "BurnRoll öffnet standardmäßig Ungesehen, damit du weitermachst, und neue Fotos erscheinen automatisch. Kategorien und Alben stammen aus der Mediathek. Ausgeblendete und Zuletzt gelöschte sind ausgeschlossen.", "BurnRoll apre Da vedere per impostazione predefinita, così riprendi da dove hai lasciato e le nuove foto compaiono da sole. Categorie e album arrivano dalla libreria Foto. Nascosti ed Eliminati di recente sono esclusi.", "BurnRollは標準で未確認を開くので、中断したところから続き、新しい写真は自動で現れます。カテゴリとアルバムは写真ライブラリからです。非表示と最近削除した項目は含まれません。", "BurnRoll은 기본적으로 미검토를 열어 멈춘 곳부터 이어가고 새 사진은 자동으로 나타납니다. 카테고리와 앨범은 사진 보관함에서 옵니다. 가려진 항목과 최근 삭제된 항목은 제외됩니다.", "BurnRoll domyślnie otwiera Nieprzejrzane, więc wracasz tam, gdzie skończyłeś, a nowe zdjęcia pojawiają się same. Kategorie i albumy pochodzą z biblioteki Zdjęć. Ukryte i Ostatnio usunięte są wykluczone.", "O BurnRoll abre Não revisados por padrão, para continuar de onde parou, e fotos novas aparecem sozinhas. Categorias e álbuns vêm da biblioteca de Fotos. Ocultos e Apagados recentemente ficam de fora.", "BurnRoll 默认打开未审阅，方便接着上次继续，新照片会自动出现。分类和相簿来自照片图库。已隐藏和最近删除的项目不包括在内。", "BurnRoll abre Sin revisar por defecto para seguir donde lo dejaste, y las fotos nuevas aparecen solas. Categorías y álbumes salen de tu fototeca. Ocultos y Eliminados hace poco quedan fuera.", "BurnRoll типово відкриває «Не переглянуто», тож ви продовжуєте з місця зупинки, а нові фото з’являються самі. Категорії й альбоми з бібліотеки Фото. Приховані та Нещодавно видалені виключено.")

# Settings
t("Storage insights", "Opslaginzichten", "Aperçu du stockage", "Speicher-Einblicke", "Statistiche di spazio", "ストレージの概要", "저장 공간 인사이트", "Podsumowanie pamięci", "Insights de armazenamento", "存储洞察", "Resumen de almacenamiento", "Огляд сховища")
t("Experience", "Beleving", "Expérience", "Erlebnis", "Esperienza", "操作感", "사용 경험", "Doświadczenie", "Experiência", "体验", "Experiencia", "Враження")
t("Haptic feedback", "Haptische feedback", "Retour haptique", "Haptisches Feedback", "Feedback aptico", "触覚フィードバック", "햅틱 피드백", "Haptyka", "Resposta tátil", "触感反馈", "Respuesta háptica", "Тактильний відгук")
t("Feel decisions, undo, and successful deletion", "Voel keuzes, ongedaan maken en geslaagde verwijdering", "Ressens les décisions, l’annulation et une suppression réussie", "Spüre Entscheidungen, Rückgängig und erfolgreiches Löschen", "Senti decisioni, annulla ed eliminazione riuscita", "判断、取り消し、削除完了を感触で知らせます", "결정, 실행 취소, 삭제 완료를 진동으로 느껴 보세요", "Poczuj decyzje, cofnięcie i udane usunięcie", "Sinta decisões, desfazer e exclusão concluída", "用触感感受决定、撤销和删除成功", "Siente las decisiones, deshacer y un borrado correcto", "Відчувайте рішення, скасування й успішне видалення")
t("How to use BurnRoll", "BurnRoll gebruiken", "Comment utiliser BurnRoll", "BurnRoll verwenden", "Come usare BurnRoll", "BurnRollの使い方", "BurnRoll 사용 방법", "Jak używać BurnRoll", "Como usar o BurnRoll", "如何使用 BurnRoll", "Cómo usar BurnRoll", "Як користуватися BurnRoll")
t("Replay the intro. Your reviews and Photos access stay as they are.", "Speel de intro opnieuw. Je beoordelingen en Foto’s-toegang blijven hetzelfde.", "Revois l’intro. Tes revues et l’accès à Photos restent inchangés.", "Intro erneut abspielen. Prüfungen und Fotos-Zugriff bleiben gleich.", "Rivedi l’introduzione. Revisioni e accesso a Foto restano com’è.", "イントロを再生します。確認状況と写真アクセスはそのままです。", "인트로를 다시 봅니다. 검토와 사진 접근 권한은 그대로입니다.", "Odtwórz wstęp. Przeglądy i dostęp do Zdjęć zostają bez zmian.", "Reveja a introdução. Revisões e acesso a Fotos continuam iguais.", "重看简介。审阅记录和照片权限保持不变。", "Vuelve a ver la intro. Tus revisiones y el acceso a Fotos no cambian.", "Повторіть вступ. Перегляди й доступ до Фото лишаються як є.")
t("Reminders", "Herinneringen", "Rappels", "Erinnerungen", "Promemoria", "リマインダー", "알림", "Przypomnienia", "Lembretes", "提醒", "Recordatorios", "Нагадування")
t("Smart reminder", "Slimme herinnering", "Rappel intelligent", "Intelligente Erinnerung", "Promemoria intelligente", "スマートリマインダー", "스마트 알림", "Inteligentne przypomnienie", "Lembrete inteligente", "智能提醒", "Recordatorio inteligente", "Розумне нагадування")
t("REMIND ME WHEN", "HERINNEREN WANNEER", "ME RAPPELER QUAND", "ERINNERN WENN", "RICORDAMI QUANDO", "通知するタイミング", "알림 시점", "PRZYPOMNIJ GDY", "LEMBRAR QUANDO", "提醒时机", "RECORDAR CUANDO", "НАГАДАТИ КОЛИ")
t("NOTIFICATION PREVIEW", "VOORBEELDMELDING", "APERÇU DE NOTIFICATION", "BENACHRICHTIGUNGSVORSCHAU", "ANTEPRIMA NOTIFICA", "通知プレビュー", "알림 미리보기", "PODGLĄD POWIADOMIENIA", "PRÉVIA DA NOTIFICAÇÃO", "通知预览", "VISTA PREVIA", "ПЕРЕДПЕРЕГЛЯД СПОВІЩЕННЯ")
t("PHOTO THRESHOLD", "FOTO-DREMPEL", "SEUIL DE PHOTOS", "FOTO-SCHWELLENWERT", "SOGLIA FOTO", "写真のしきい値", "사진 기준", "PRÓG ZDJĘĆ", "LIMITE DE FOTOS", "照片阈值", "UMBRAL DE FOTOS", "Поріг фото")
t("Photo reminder threshold", "Drempel fotoherinnering", "Seuil du rappel photo", "Schwellenwert der Foto-Erinnerung", "Soglia del promemoria foto", "写真リマインダーのしきい値", "사진 알림 기준", "Próg przypomnienia o zdjęciach", "Limite do lembrete de fotos", "照片提醒阈值", "Umbral del recordatorio de fotos", "Поріг нагадування про фото")
t("Photos access", "Toegang tot Foto’s", "Accès à Photos", "Fotos-Zugriff", "Accesso a Foto", "写真へのアクセス", "사진 접근", "Dostęp do Zdjęć", "Acesso a Fotos", "照片权限", "Acceso a Fotos", "Доступ до Фото")
t("Privacy & data", "Privacy en gegevens", "Confidentialité et données", "Datenschutz & Daten", "Privacy e dati", "プライバシーとデータ", "개인정보 및 데이터", "Prywatność i dane", "Privacidade e dados", "隐私与数据", "Privacidad y datos", "Приватність і дані")
t("Privacy policy", "Privacybeleid", "Politique de confidentialité", "Datenschutzrichtlinie", "Informativa sulla privacy", "プライバシーポリシー", "개인정보 처리방침", "Polityka prywatności", "Política de privacidade", "隐私政策", "Política de privacidad", "Політика конфіденційності")
t("How BurnRoll uses Photos, on-device state, analytics, and notifications", "Hoe BurnRoll Foto’s, lokale status, analytics en meldingen gebruikt", "Comment BurnRoll utilise Photos, l’état sur l’appareil, les analyses et les notifications", "Wie BurnRoll Fotos, den Gerätestatus, Analysen und Mitteilungen nutzt", "Come BurnRoll usa Foto, lo stato sul dispositivo, le analisi e le notifiche", "BurnRollによる写真、端末内状態、分析、通知の扱い", "BurnRoll의 사진, 기기 내 상태, 분석, 알림 사용 방식", "Jak BurnRoll korzysta ze Zdjęć, stanu na urządzeniu, analityki i powiadomień", "Como o BurnRoll usa Fotos, estado no dispositivo, análises e notificações", "BurnRoll 如何使用照片、设备端状态、分析和通知", "Cómo BurnRoll usa Fotos, el estado en el dispositivo, analítica y notificaciones", "Як BurnRoll використовує Фото, стан на пристрої, аналітику й сповіщення")
t("Support", "Ondersteuning", "Assistance", "Support", "Supporto", "サポート", "지원", "Wsparcie", "Suporte", "支持", "Soporte", "Підтримка")
t("Email us", "Mail ons", "Écris-nous", "Schreib uns", "Scrivici", "メールする", "이메일 보내기", "Napisz do nas", "Envie um e-mail", "发邮件给我们", "Escríbenos", "Напишіть нам")
t("Support on the web", "Ondersteuning op het web", "Assistance sur le web", "Support im Web", "Supporto sul web", "ウェブのサポート", "웹 지원", "Wsparcie w sieci", "Suporte na web", "网页支持", "Soporte en la web", "Підтримка в інтернеті")
t("Public contact page for App Review and users", "Openbare contactpagina voor App Review en gebruikers", "Page de contact publique pour App Review et les utilisateurs", "Öffentliche Kontaktseite für App Review und Nutzer", "Pagina di contatto pubblica per App Review e gli utenti", "App Reviewとユーザー向けの公開連絡ページ", "App Review와 사용자를 위한 공개 연락 페이지", "Publiczna strona kontaktowa dla App Review i użytkowników", "Página pública de contato para App Review e usuários", "供 App Review 和用户使用的公开联系页", "Página de contacto pública para App Review y usuarios", "Публічна сторінка контакту для App Review і користувачів")
t("Open privacy policy on the web", "Open privacybeleid op het web", "Ouvrir la politique de confidentialité sur le web", "Datenschutzrichtlinie im Web öffnen", "Apri l’informativa sul web", "ウェブでプライバシーポリシーを開く", "웹에서 개인정보 처리방침 열기", "Otwórz politykę prywatności w sieci", "Abrir a política de privacidade na web", "在网页打开隐私政策", "Abrir la política de privacidad en la web", "Відкрити політику конфіденційності в інтернеті")
t("App icon", "App-icoon", "Icône de l’app", "App-Symbol", "Icona dell’app", "アプリアイコン", "앱 아이콘", "Ikona aplikacji", "Ícone do app", "App 图标", "Icono de la app", "Іконка програми")
t("Choose how BurnRoll looks on your Home Screen. iOS will ask you to confirm.", "Kies hoe BurnRoll eruitziet op het beginscherm. iOS vraagt om bevestiging.", "Choisis l’apparence de BurnRoll sur l’écran d’accueil. iOS demandera confirmation.", "Wähle, wie BurnRoll auf dem Home-Bildschirm aussieht. iOS fragt zur Bestätigung.", "Scegli come appare BurnRoll nella schermata Home. iOS chiederà conferma.", "ホーム画面のBurnRollの見た目を選びます。iOSが確認します。", "홈 화면에서 BurnRoll 모양을 고르세요. iOS가 확인을 요청합니다.", "Wybierz wygląd BurnRoll na ekranie początkowym. iOS poprosi o potwierdzenie.", "Escolha como o BurnRoll aparece na Tela de Início. O iOS pedirá confirmação.", "选择 BurnRoll 在主屏幕上的外观。iOS 会要求确认。", "Elige cómo se ve BurnRoll en la pantalla de inicio. iOS te pedirá confirmación.", "Оберіть вигляд BurnRoll на Початковому екрані. iOS попросить підтвердження.")
t("Classic", "Klassiek", "Classique", "Klassisch", "Classica", "クラシック", "클래식", "Klasyczna", "Clássico", "经典", "Clásico", "Класична")
t("Paper", "Papier", "Papier", "Papier", "Carta", "ペーパー", "페이퍼", "Papier", "Papel", "纸感", "Papel", "Папір")
t("Ember", "Gloed", "Braise", "Glut", "Brace", "エンバー", "엠버", "Żar", "Brasa", "余烬", "Ascua", "Жаринка")
t("Couldn't change the Home Screen icon. Try again on a device.", "Beginschermicoon wijzigen mislukt. Probeer het op een apparaat.", "Impossible de changer l’icône d’accueil. Réessaie sur un appareil.", "Home-Bildschirm-Symbol konnte nicht geändert werden. Versuche es auf einem Gerät.", "Impossibile cambiare l’icona Home. Riprova su un dispositivo.", "ホーム画面のアイコンを変更できませんでした。実機で試してください。", "홈 화면 아이콘을 바꿀 수 없습니다. 실제 기기에서 다시 시도하세요.", "Nie udało się zmienić ikony ekranu początkowego. Spróbuj na urządzeniu.", "Não foi possível mudar o ícone da Tela de Início. Tente em um dispositivo.", "无法更改主屏幕图标。请在真机上重试。", "No se pudo cambiar el icono de inicio. Prueba en un dispositivo.", "Не вдалося змінити іконку Початкового екрана. Спробуйте на пристрої.")
t("Enable smart reminder?", "Slimme herinnering inschakelen?", "Activer le rappel intelligent ?", "Intelligente Erinnerung aktivieren?", "Attivare il promemoria intelligente?", "スマートリマインダーをオンにしますか？", "스마트 알림을 켤까요?", "Włączyć inteligentne przypomnienie?", "Ativar lembrete inteligente?", "要开启智能提醒吗？", "¿Activar el recordatorio inteligente?", "Увімкнути розумне нагадування?")
t("Continue", "Doorgaan", "Continuer", "Weiter", "Continua", "続ける", "계속", "Dalej", "Continuar", "继续", "Continuar", "Продовжити")
t("Not now", "Niet nu", "Pas maintenant", "Nicht jetzt", "Non ora", "後で", "나중에", "Nie teraz", "Agora não", "暂不", "Ahora no", "Не зараз")
t("Notifications are off", "Meldingen staan uit", "Les notifications sont désactivées", "Mitteilungen sind aus", "Le notifiche sono disattivate", "通知がオフです", "알림이 꺼져 있습니다", "Powiadomienia są wyłączone", "As notificações estão desativadas", "通知已关闭", "Las notificaciones están desactivadas", "Сповіщення вимкнено")
t("Allow notifications for BurnRoll in iOS Settings to use cleanup reminders.", "Sta meldingen voor BurnRoll toe in iOS-instellingen om opruimherinneringen te gebruiken.", "Autorise les notifications BurnRoll dans Réglages iOS pour les rappels de nettoyage.", "Erlaube Mitteilungen für BurnRoll in den iOS-Einstellungen für Bereinigungserinnerungen.", "Consenti le notifiche di BurnRoll in Impostazioni iOS per i promemoria di pulizia.", "整理リマインダーを使うには、iOS設定でBurnRollの通知を許可してください。", "정리 알림을 쓰려면 iOS 설정에서 BurnRoll 알림을 허용하세요.", "Zezwól na powiadomienia BurnRoll w Ustawieniach iOS, aby korzystać z przypomnień o czyszczeniu.", "Permita notificações do BurnRoll nos Ajustes do iOS para usar lembretes de limpeza.", "要使用清理提醒，请在 iOS 设置中允许 BurnRoll 通知。", "Permite las notificaciones de BurnRoll en Ajustes de iOS para usar recordatorios de limpieza.", "Дозвольте сповіщення BurnRoll у Налаштуваннях iOS, щоб користуватися нагадуваннями про очищення.")
t("Reminder couldn’t be scheduled", "Herinnering kon niet worden gepland", "Le rappel n’a pas pu être planifié", "Erinnerung konnte nicht geplant werden", "Impossibile programmare il promemoria", "リマインダーを予約できませんでした", "알림을 예약할 수 없음", "Nie udało się zaplanować przypomnienia", "Não foi possível agendar o lembrete", "无法安排提醒", "No se pudo programar el recordatorio", "Не вдалося запланувати нагадування")
t("Checking recent photos…", "Recente foto’s controleren…", "Vérification des photos récentes…", "Aktuelle Fotos werden geprüft…", "Controllo delle foto recenti…", "最近の写真を確認中…", "최근 사진을 확인하는 중…", "Sprawdzanie ostatnich zdjęć…", "Verificando fotos recentes…", "正在检查最近的照片…", "Comprobando fotos recientes…", "Перевірка недавніх фото…")
t("Off", "Uit", "Désactivé", "Aus", "Disattivato", "オフ", "끔", "Wył.", "Desligado", "关", "Desactivado", "Вимкнено")
t("Due now", "Nu aan de beurt", "À faire maintenant", "Jetzt fällig", "Scade ora", "今すぐ", "지금 해당", "Teraz", "Agora", "现在到期", "Ahora", "Зараз")
t("Waiting for growth", "Wachten op groei", "En attente de croissance", "Wartet auf Wachstum", "In attesa di crescita", "増加を待っています", "증가 대기 중", "Oczekiwanie na wzrost", "Aguardando crescimento", "等待增长", "Esperando crecimiento", "Очікування зростання")
t("Timing varies", "Tijdstip varieert", "L’horaire varie", "Zeitpunkt variiert", "I tempi variano", "タイミングは変動します", "시기는 달라질 수 있음", "Termin bywa różny", "O horário varia", "时间不固定", "El momento varía", "Час може змінюватися")
t("No photos · skipped", "Geen foto’s · overgeslagen", "Aucune photo · ignoré", "Keine Fotos · übersprungen", "Nessuna foto · saltato", "写真なし · スキップ", "사진 없음 · 건너뜀", "Brak zdjęć · pominięto", "Sem fotos · ignorado", "无照片 · 已跳过", "Sin fotos · omitido", "Немає фото · пропущено")
t("Photo count", "Aantal foto’s", "Nombre de photos", "Fotoanzahl", "Conteggio foto", "写真枚数", "사진 수", "Liczba zdjęć", "Contagem de fotos", "照片数量", "Recuento de fotos", "Кількість фото")
t("5 GB", "5 GB", "5 Go", "5 GB", "5 GB", "5 GB", "5 GB", "5 GB", "5 GB", "5 GB", "5 GB", "5 ГБ")
t("30 days", "30 dagen", "30 jours", "30 Tage", "30 giorni", "30日", "30일", "30 dni", "30 dias", "30 天", "30 días", "30 днів")
t("Camera roll grows by a photo count", "Camerastream groeit met een aantal foto’s", "La pellicule augmente d’un nombre de photos", "Die Mediathek wächst um eine Fotoanzahl", "Il rullino cresce di un numero di foto", "カメラロールが指定枚数増えたとき", "카메라 롤이 지정한 장수만큼 늘면", "Rolka urośnie o określoną liczbę zdjęć", "O rolo cresce por uma quantidade de fotos", "相册增加指定数量的照片时", "El carrete crece en un número de fotos", "Стрічка зросте на певну кількість фото")
t("Camera roll grows by about 5 GB", "Camerastream groeit met ongeveer 5 GB", "La pellicule augmente d’environ 5 Go", "Die Mediathek wächst um etwa 5 GB", "Il rullino cresce di circa 5 GB", "カメラロールが約5 GB増えたとき", "카메라 롤이 약 5 GB 늘면", "Rolka urośnie o około 5 GB", "O rolo cresce cerca de 5 GB", "相册大约增加 5 GB 时", "El carrete crece unos 5 GB", "Стрічка зросте приблизно на 5 ГБ")
t("30 days have passed", "Er zijn 30 dagen verstreken", "30 jours se sont écoulés", "30 Tage sind vergangen", "Sono passati 30 giorni", "30日が経過したとき", "30일이 지났을 때", "Minęło 30 dni", "Passaram-se 30 dias", "已过 30 天", "Han pasado 30 días", "Минуло 30 днів")
t("A selected number of new photos", "Een gekozen aantal nieuwe foto’s", "Un nombre choisi de nouvelles photos", "Eine gewählte Anzahl neuer Fotos", "Un numero scelto di nuove foto", "指定した枚数の新しい写真", "선택한 수의 새 사진", "Wybrana liczba nowych zdjęć", "Um número escolhido de fotos novas", "指定数量的新照片", "Un número elegido de fotos nuevas", "Обрана кількість нових фото")
t("Around 5 GB of new media", "Ongeveer 5 GB nieuwe media", "Environ 5 Go de nouveaux médias", "Etwa 5 GB neue Medien", "Circa 5 GB di nuovi media", "約5 GBの新しいメディア", "새 미디어 약 5 GB", "Około 5 GB nowych multimediów", "Cerca de 5 GB de mídia nova", "大约 5 GB 新媒体", "Unos 5 GB de contenido nuevo", "Приблизно 5 ГБ нових медіа")
t("30 days after your last check-in", "30 dagen na je laatste check-in", "30 jours après ta dernière visite", "30 Tage nach deinem letzten Check-in", "30 giorni dopo il tuo ultimo controllo", "前回の確認から30日後", "마지막 확인 후 30일", "30 dni po ostatnim sprawdzeniu", "30 dias após sua última verificação", "距上次查看 30 天", "30 días después de tu última visita", "Через 30 днів після останньої перевірки")
t("Space recovered", "Teruggewonnen ruimte", "Espace récupéré", "Freigegebener Speicher", "Spazio recuperato", "確保した容量", "확보한 공간", "Odzyskane miejsce", "Espaço recuperado", "已回收空间", "Espacio recuperado", "Звільнений простір")
t("Photos burned", "Foto’s gewist", "Photos brûlées", "Fotos gebrannt", "Foto bruciate", "削除した写真", "삭제한 사진", "Usunięte zdjęcia", "Fotos queimadas", "已清除照片", "Fotos eliminadas", "Видалені фото")
t("Videos removed", "Video’s verwijderd", "Vidéos retirées", "Videos entfernt", "Video rimossi", "削除したビデオ", "삭제한 동영상", "Usunięte filmy", "Vídeos removidos", "已移除视频", "Vídeos eliminados", "Видалені відео")
t("Cleanup streak", "Opruimreeks", "Série de nettoyages", "Bereinigungs-Serie", "Serie di pulizie", "整理連続日数", "정리 연속", "Seria czyszczeń", "Sequência de limpeza", "连续清理", "Racha de limpieza", "Серія очищень")
t("day", "dag", "jour", "Tag", "giorno", "日", "일", "dzień", "dia", "天", "día", "день")
t("days", "dagen", "jours", "Tage", "giorni", "日", "일", "dni", "dias", "天", "días", "дні")
t("* Space is estimated. Items remain recoverable in Apple Photos’ Recently Deleted album for up to 30 days.", "* Ruimte is een schatting. Items blijven tot 30 dagen herstelbaar in Recent verwijderd van Apple Foto’s.", "* L’espace est une estimation. Les éléments restent récupérables dans Récemment supprimés d’Apple Photos jusqu’à 30 jours.", "* Speicher ist geschätzt. Elemente bleiben bis zu 30 Tage in Zuletzt gelöscht von Apple Fotos wiederherstellbar.", "* Lo spazio è una stima. Gli elementi restano recuperabili in Eliminati di recente di Foto Apple fino a 30 giorni.", "*容量は概算です。項目は最大30日間、Appleの写真の「最近削除した項目」から復元できます。", "* 공간은 추정치입니다. 항목은 최대 30일 동안 Apple 사진의 최근 삭제된 항목에서 복구할 수 있습니다.", "* Miejsce jest szacunkowe. Elementy można odzyskać z Ostatnio usuniętych w Zdjęciach Apple do 30 dni.", "* O espaço é uma estimativa. Os itens continuam recuperáveis em Apagados recentemente do Fotos da Apple por até 30 dias.", "* 空间为估算。项目在 Apple 照片的“最近删除”中最多可恢复 30 天。", "* El espacio es estimado. Los elementos se pueden recuperar en Eliminados hace poco de Fotos de Apple hasta 30 días.", "* Простір орієнтовний. Елементи можна відновити з «Нещодавно видалені» в Фото Apple до 30 днів.")
t("ESTIMATED SPACE RECOVERABLE", "GESCHATTE TERUG TE WINNEN RUIMTE", "ESPACE RÉCUPÉRABLE ESTIMÉ", "GESCHÄTZTER FREIER SPEICHER", "SPAZIO RECUPERABILE STIMATO", "回復見込みの容量", "예상 확보 공간", "SZACOWANE MIEJSCE DO ODZYSKANIA", "ESPAÇO RECUPERÁVEL ESTIMADO", "预计可回收空间", "ESPACIO RECUPERABLE ESTIMADO", "ОРІЄНТОВНИЙ ПРОСТІР ДЛЯ ЗВІЛЬНЕННЯ")
t("Full library access", "Volledige bibliotheektoegang", "Accès à toute la bibliothèque", "Voller Mediathek-Zugriff", "Accesso all’intera libreria", "ライブラリ全体にアクセス", "전체 보관함 접근", "Pełny dostęp do biblioteki", "Acesso à biblioteca inteira", "完整资料库访问", "Acceso a toda la fototeca", "Повний доступ до бібліотеки")
t("Selected photos access", "Toegang tot geselecteerde foto’s", "Accès aux photos sélectionnées", "Zugriff auf ausgewählte Fotos", "Accesso alle foto selezionate", "選択した写真へのアクセス", "선택한 사진 접근", "Dostęp do wybranych zdjęć", "Acesso às fotos selecionadas", "仅限所选照片", "Acceso a fotos seleccionadas", "Доступ до вибраних фото")
t("Photos access is off", "Toegang tot Foto’s staat uit", "L’accès à Photos est désactivé", "Fotos-Zugriff ist aus", "L’accesso a Foto è disattivato", "写真アクセスはオフです", "사진 접근이 꺼져 있습니다", "Dostęp do Zdjęć jest wyłączony", "O acesso a Fotos está desativado", "照片权限已关闭", "El acceso a Fotos está desactivado", "Доступ до Фото вимкнено")
t("Photos access is restricted", "Toegang tot Foto’s is beperkt", "L’accès à Photos est restreint", "Fotos-Zugriff ist eingeschränkt", "L’accesso a Foto è limitato", "写真アクセスは制限されています", "사진 접근이 제한됨", "Dostęp do Zdjęć jest ograniczony", "O acesso a Fotos está restrito", "照片权限受限", "El acceso a Fotos está restringido", "Доступ до Фото обмежено")
t("Photos access not requested", "Toegang tot Foto’s niet gevraagd", "Accès à Photos non demandé", "Fotos-Zugriff nicht angefragt", "Accesso a Foto non richiesto", "写真アクセス未要求", "사진 접근을 요청하지 않음", "Nie poproszono o dostęp do Zdjęć", "Acesso a Fotos não solicitado", "尚未请求照片权限", "No se ha pedido acceso a Fotos", "Доступ до Фото не запрошено")
t("Photos access unavailable", "Toegang tot Foto’s niet beschikbaar", "Accès à Photos indisponible", "Fotos-Zugriff nicht verfügbar", "Accesso a Foto non disponibile", "写真アクセスは利用できません", "사진 접근 불가", "Dostęp do Zdjęć niedostępny", "Acesso a Fotos indisponível", "无法使用照片权限", "Acceso a Fotos no disponible", "Доступ до Фото недоступний")
t("BurnRoll can show your full library", "BurnRoll kan je hele bibliotheek tonen", "BurnRoll peut afficher toute ta bibliothèque", "BurnRoll kann deine gesamte Mediathek zeigen", "BurnRoll può mostrare l’intera libreria", "BurnRollはライブラリ全体を表示できます", "BurnRoll이 전체 보관함을 표시할 수 있습니다", "BurnRoll może pokazać całą bibliotekę", "O BurnRoll pode mostrar a biblioteca inteira", "BurnRoll 可以显示完整资料库", "BurnRoll puede mostrar toda tu fototeca", "BurnRoll може показати всю бібліотеку")
t("Only photos selected in iOS are available", "Alleen in iOS geselecteerde foto’s zijn beschikbaar", "Seules les photos choisies dans iOS sont disponibles", "Nur in iOS ausgewählte Fotos sind verfügbar", "Sono disponibili solo le foto scelte in iOS", "iOSで選んだ写真のみ利用できます", "iOS에서 선택한 사진만 사용할 수 있습니다", "Dostępne są tylko zdjęcia wybrane w iOS", "Só as fotos selecionadas no iOS estão disponíveis", "仅可使用在 iOS 中选择的照片", "Solo están disponibles las fotos elegidas en iOS", "Доступні лише фото, вибрані в iOS")
t("Enable access to continue reviewing", "Schakel toegang in om verder te beoordelen", "Active l’accès pour continuer à revoir", "Aktiviere den Zugriff, um weiter zu prüfen", "Attiva l’accesso per continuare a rivedere", "確認を続けるにはアクセスを許可してください", "검토를 계속하려면 접근을 허용하세요", "Włącz dostęp, aby kontynuować przegląd", "Ative o acesso para continuar revisando", "请开启权限以继续审阅", "Activa el acceso para seguir revisando", "Увімкніть доступ, щоб продовжити перегляд")
t("This device prevents Photos access", "Dit apparaat blokkeert toegang tot Foto’s", "Cet appareil empêche l’accès à Photos", "Dieses Gerät verhindert Fotos-Zugriff", "Questo dispositivo impedisce l’accesso a Foto", "このデバイスでは写真アクセスが制限されています", "이 기기는 사진 접근을 막습니다", "To urządzenie blokuje dostęp do Zdjęć", "Este dispositivo impede o acesso a Fotos", "此设备阻止访问照片", "Este dispositivo impide el acceso a Fotos", "Цей пристрій блокує доступ до Фото")
t("Choose access when iOS asks", "Kies toegang wanneer iOS vraagt", "Choisis l’accès lorsque iOS le demande", "Wähle den Zugriff, wenn iOS fragt", "Scegli l’accesso quando iOS lo chiede", "iOSの確認でアクセスを選んでください", "iOS가 물을 때 접근을 선택하세요", "Wybierz dostęp, gdy iOS o to poprosi", "Escolha o acesso quando o iOS pedir", "在 iOS 询问时选择权限", "Elige el acceso cuando iOS te lo pida", "Оберіть доступ, коли iOS запитає")
t("Check the app’s iOS settings", "Controleer de iOS-instellingen van de app", "Vérifie les réglages iOS de l’app", "Prüfe die iOS-Einstellungen der App", "Controlla le impostazioni iOS dell’app", "アプリのiOS設定を確認してください", "앱의 iOS 설정을 확인하세요", "Sprawdź ustawienia iOS aplikacji", "Confira os ajustes de iOS do app", "请检查此 App 的 iOS 设置", "Revisa los ajustes de iOS de la app", "Перевірте налаштування iOS програми")
t("FULL", "VOLLEDIG", "COMPLET", "VOLL", "COMPLETO", "全体", "전체", "PEŁNY", "TOTAL", "完整", "COMPLETO", "ПОВНИЙ")
t("LIMITED", "BEPERKT", "LIMITÉ", "EINGESCHRÄNKT", "LIMITATO", "制限", "제한", "OGRANICZONY", "LIMITADO", "受限", "LIMITADO", "ОБМЕЖЕНИЙ")
t("OFF", "UIT", "DÉSACTIVÉ", "AUS", "OFF", "オフ", "끔", "WYŁ.", "OFF", "关", "OFF", "ВИМК")
t("RESTRICTED", "GEBLOKKEERD", "RESTREINT", "GESPERRT", "RISTRETTO", "制限", "제한됨", "ZABLOKOWANY", "RESTRITO", "受限", "RESTRINGIDO", "ОБМЕЖЕНО")
t("PENDING", "IN AFWACHTING", "EN ATTENTE", "AUSSTEHEND", "IN SOSPESO", "保留", "대기", "OCZEKUJE", "PENDENTE", "待处理", "PENDIENTE", "ОЧІКУЄ")
t("UNKNOWN", "ONBEKEND", "INCONNU", "UNBEKANNT", "SCONOSCIUTO", "不明", "알 수 없음", "NIEZNANY", "DESCONHECIDO", "未知", "DESCONOCIDO", "НЕВІДОМО")
t("Review Photos Access", "Foto’s-toegang bekijken", "Voir l’accès à Photos", "Fotos-Zugriff prüfen", "Rivedi accesso a Foto", "写真アクセスを確認", "사진 접근 검토", "Sprawdź dostęp do Zdjęć", "Revisar acesso a Fotos", "查看照片权限", "Revisar acceso a Fotos", "Переглянути доступ до Фото")
t("Manage Selected Photos", "Geselecteerde foto’s beheren", "Gérer les photos sélectionnées", "Ausgewählte Fotos verwalten", "Gestisci foto selezionate", "選択した写真を管理", "선택한 사진 관리", "Zarządzaj wybranymi zdjęciami", "Gerenciar fotos selecionadas", "管理所选照片", "Gestionar fotos seleccionadas", "Керувати вибраними фото")
t("Open Photos Settings", "Open Foto’s-instellingen", "Ouvrir les réglages Photos", "Fotos-Einstellungen öffnen", "Apri impostazioni Foto", "写真の設定を開く", "사진 설정 열기", "Otwórz ustawienia Zdjęć", "Abrir ajustes de Fotos", "打开照片设置", "Abrir ajustes de Fotos", "Відкрити налаштування Фото")
t("Choose Photos Access", "Kies Foto’s-toegang", "Choisir l’accès à Photos", "Fotos-Zugriff wählen", "Scegli accesso a Foto", "写真アクセスを選ぶ", "사진 접근 선택", "Wybierz dostęp do Zdjęć", "Escolher acesso a Fotos", "选择照片权限", "Elegir acceso a Fotos", "Обрати доступ до Фото")
t("Open App Settings", "Open app-instellingen", "Ouvrir les réglages de l’app", "App-Einstellungen öffnen", "Apri impostazioni app", "アプリ設定を開く", "앱 설정 열기", "Otwórz ustawienia aplikacji", "Abrir ajustes do app", "打开 App 设置", "Abrir ajustes de la app", "Відкрити налаштування програми")
t("BurnRoll is loading", "BurnRoll wordt geladen", "BurnRoll charge", "BurnRoll wird geladen", "BurnRoll si sta caricando", "BurnRollを読み込み中", "BurnRoll 불러오는 중", "Ładowanie BurnRoll", "BurnRoll está carregando", "正在加载 BurnRoll", "BurnRoll se está cargando", "BurnRoll завантажується")
t(
    "BurnRoll counts new photos when you open the app, and when your library changes while BurnRoll is open. iOS cannot watch the camera roll after you leave, so open BurnRoll after taking photos to get the reminder. The 30-day option still shows a scheduled date.",
    "BurnRoll telt nieuwe foto’s wanneer je de app opent, en wanneer je bibliotheek verandert terwijl BurnRoll open is. iOS kan de camerastream niet volgen nadat je weggaat, dus open BurnRoll na het maken van foto’s voor de herinnering. De 30-dagenoptie toont nog steeds een geplande datum.",
    "BurnRoll compte les nouvelles photos à l’ouverture, et quand ta bibliothèque change tant que l’app est ouverte. iOS ne surveille pas la pellicule après ton départ : ouvre BurnRoll après avoir pris des photos pour le rappel. L’option 30 jours affiche toujours une date.",
    "BurnRoll zählt neue Fotos beim Öffnen und wenn sich die Mediathek ändert, solange die App offen ist. iOS überwacht die Mediathek nicht, nachdem du gehst – öffne BurnRoll nach dem Fotografieren für die Erinnerung. Die 30-Tage-Option zeigt weiter ein Datum.",
    "BurnRoll conta le nuove foto all’apertura e quando la libreria cambia con l’app aperta. iOS non osserva il rullino dopo che esci: apri BurnRoll dopo aver scattato per il promemoria. L’opzione a 30 giorni mostra comunque una data.",
    "BurnRollはアプリを開いたときと、開いている間にライブラリが変わったときに新しい写真を数えます。離れたあとはiOSがカメラロールを監視できないため、撮影後にBurnRollを開くとリマインダーが届きます。30日オプションは予定日を表示します。",
    "BurnRoll은 앱을 열 때, 그리고 앱이 열린 동안 보관함이 바뀔 때 새 사진을 셉니다. 나가면 iOS가 카메라 롤을 보지 못하므로, 사진을 찍은 뒤 BurnRoll을 열어야 알림을 받습니다. 30일 옵션은 예정 날짜를 보여 줍니다.",
    "BurnRoll liczy nowe zdjęcia przy otwarciu aplikacji i gdy biblioteka zmieni się, gdy aplikacja jest otwarta. iOS nie obserwuje rolki po wyjściu — otwórz BurnRoll po zrobieniu zdjęć, by dostać przypomnienie. Opcja 30 dni nadal pokazuje datę.",
    "O BurnRoll conta fotos novas ao abrir o app e quando a biblioteca muda com o app aberto. O iOS não observa o rolo depois que você sai: abra o BurnRoll após fotografar para receber o lembrete. A opção de 30 dias ainda mostra uma data.",
    "BurnRoll 会在你打开 App 时计数新照片，也会在 App 打开期间资料库变化时计数。离开后 iOS 无法监视相册，所以拍完照请再打开 BurnRoll 才能收到提醒。30 天选项仍会显示计划日期。",
    "BurnRoll cuenta fotos nuevas al abrir la app y cuando la fototeca cambia con la app abierta. iOS no vigila el carrete al salir: abre BurnRoll después de fotografiar para el recordatorio. La opción de 30 días sigue mostrando una fecha.",
    "BurnRoll рахує нові фото, коли ви відкриваєте програму, і коли бібліотека змінюється, поки вона відкрита. iOS не стежить за стрічкою після виходу — відкрийте BurnRoll після зйомки, щоб отримати нагадування. Варіант на 30 днів і далі показує дату.",
)
t(
    "100 percent on-device photo processing. BurnRoll never uploads your photos to its servers. No photo contents in analytics. No account required.",
    "Foto’s worden 100 procent op het apparaat verwerkt. BurnRoll uploadt je foto’s nooit naar eigen servers. Geen foto-inhoud in analytics. Geen account nodig.",
    "Traitement photo 100 % sur l’appareil. BurnRoll n’envoie jamais tes photos vers ses serveurs. Aucun contenu photo dans les analyses. Aucun compte requis.",
    "Fotos werden zu 100 Prozent auf dem Gerät verarbeitet. BurnRoll lädt Fotos nie auf eigene Server. Keine Fotoinhalte in der Analyse. Kein Konto nötig.",
    "Elaborazione foto al 100% sul dispositivo. BurnRoll non carica mai le foto sui propri server. Nessun contenuto foto nelle analisi. Nessun account richiesto.",
    "写真は100%この端末で処理されます。BurnRollが写真を自社サーバーにアップロードすることはありません。分析に写真内容は含まれません。アカウント不要。",
    "사진은 100% 기기에서 처리됩니다. BurnRoll은 사진을 자체 서버에 올리지 않습니다. 분석에 사진 내용이 없고 계정이 필요 없습니다.",
    "Zdjęcia są przetwarzane w 100% na urządzeniu. BurnRoll nigdy nie wysyła ich na własne serwery. Brak treści zdjęć w analityce. Konto nie jest wymagane.",
    "As fotos são processadas 100% no dispositivo. O BurnRoll nunca envia suas fotos aos próprios servidores. Nenhum conteúdo de foto nas análises. Sem conta.",
    "照片 100% 在设备上处理。BurnRoll 绝不会把照片上传到自己的服务器。分析不含照片内容。无需账户。",
    "Las fotos se procesan al 100% en el dispositivo. BurnRoll nunca sube tus fotos a sus servidores. Sin contenido de fotos en analítica. Sin cuenta.",
    "Фото обробляються на 100% на пристрої. BurnRoll ніколи не завантажує їх на свої сервери. Немає вмісту фото в аналітиці. Обліковий запис не потрібен.",
)

# Notifications
t("Ready for a quick cleanup?", "Klaar voor een snelle opruiming?", "Prêt pour un petit nettoyage ?", "Bereit für eine schnelle Bereinigung?", "Pronto per una pulizia veloce?", "さっと整理しませんか？", "잠깐 정리할까요?", "Gotowy na szybkie czyszczenie?", "Pronto para uma limpeza rápida?", "准备快速清理一下吗？", "¿Listo para una limpieza rápida?", "Готові швидко прибрати?")
t("New photos may be waiting. Open BurnRoll for a quick cleanup.", "Er wachten misschien nieuwe foto’s. Open BurnRoll voor een snelle opruiming.", "De nouvelles photos t’attendent peut-être. Ouvre BurnRoll pour un nettoyage rapide.", "Neue Fotos warten vielleicht. Öffne BurnRoll für eine schnelle Bereinigung.", "Potrebbero esserci nuove foto. Apri BurnRoll per una pulizia veloce.", "新しい写真があるかもしれません。BurnRollを開いてさっと整理しましょう。", "새 사진이 기다리고 있을 수 있습니다. BurnRoll을 열어 빠르게 정리하세요.", "Mogą czekać nowe zdjęcia. Otwórz BurnRoll na szybkie czyszczenie.", "Novas fotos podem estar esperando. Abra o BurnRoll para uma limpeza rápida.", "可能有新照片在等你。打开 BurnRoll 快速清理。", "Puede que haya fotos nuevas. Abre BurnRoll para una limpieza rápida.", "Можливо, чекають нові фото. Відкрийте BurnRoll для швидкого очищення.")
t("up to 5 minutes", "maximaal 5 minuten", "jusqu’à 5 minutes", "bis zu 5 Minuten", "fino a 5 minuti", "最大5分", "최대 5분", "do 5 minut", "até 5 minutos", "最多 5 分钟", "hasta 5 minutos", "до 5 хвилин")
t("Notifications are disabled for BurnRoll. Enable them in iOS Settings to use cleanup reminders.", "Meldingen voor BurnRoll staan uit. Schakel ze in iOS-instellingen in voor opruimherinneringen.", "Les notifications BurnRoll sont désactivées. Active-les dans Réglages iOS pour les rappels.", "Mitteilungen für BurnRoll sind aus. Aktiviere sie in den iOS-Einstellungen für Erinnerungen.", "Le notifiche di BurnRoll sono disattivate. Attivale in Impostazioni iOS per i promemoria.", "BurnRollの通知はオフです。整理リマインダーを使うにはiOS設定でオンにしてください。", "BurnRoll 알림이 꺼져 있습니다. 정리 알림을 쓰려면 iOS 설정에서 켜 주세요.", "Powiadomienia BurnRoll są wyłączone. Włącz je w Ustawieniach iOS, aby korzystać z przypomnień.", "As notificações do BurnRoll estão desativadas. Ative-as nos Ajustes do iOS para lembretes.", "BurnRoll 通知已关闭。要使用清理提醒，请在 iOS 设置中开启。", "Las notificaciones de BurnRoll están desactivadas. Actívalas en Ajustes de iOS para los recordatorios.", "Сповіщення BurnRoll вимкнено. Увімкніть їх у Налаштуваннях iOS для нагадувань.")

# Deletion errors
t("The selected items could not be found in the Photos library.", "De geselecteerde items zijn niet in de Fotobibliotheek gevonden.", "Les éléments sélectionnés sont introuvables dans la photothèque.", "Die ausgewählten Elemente wurden in der Mediathek nicht gefunden.", "Gli elementi selezionati non sono stati trovati nella libreria Foto.", "選択した項目が写真ライブラリに見つかりませんでした。", "선택한 항목을 사진 보관함에서 찾을 수 없습니다.", "Nie znaleziono wybranych elementów w bibliotece Zdjęć.", "Os itens selecionados não foram encontrados na biblioteca de Fotos.", "在照片图库中找不到所选项目。", "No se encontraron los elementos seleccionados en la fototeca.", "Вибрані елементи не знайдено в бібліотеці Фото.")
t("Deletion was cancelled. Your burn queue is unchanged.", "Verwijderen is geannuleerd. Je wislijst is ongewijzigd.", "La suppression a été annulée. Ta liste à brûler est inchangée.", "Löschen wurde abgebrochen. Deine Brennliste ist unverändert.", "L’eliminazione è stata annullata. La lista da bruciare è invariata.", "削除はキャンセルされました。削除リストはそのままです。", "삭제가 취소되었습니다. 삭제 대기열은 그대로입니다.", "Usuwanie anulowano. Lista do usunięcia jest bez zmian.", "A exclusão foi cancelada. Sua fila de queima não mudou.", "已取消删除。清除队列未更改。", "Se canceló el borrado. Tu lista de eliminación no cambia.", "Видалення скасовано. Черга видалення без змін.")
t("Photos couldn’t complete the deletion. Try again, and confirm Delete on the system sheet.", "Foto’s kon verwijderen niet voltooien. Probeer opnieuw en bevestig Verwijderen in het systeemvenster.", "Photos n’a pas pu terminer la suppression. Réessaie et confirme Supprimer dans la feuille système.", "Fotos konnte das Löschen nicht abschließen. Versuche es erneut und bestätige Löschen im Systemdialog.", "Foto non ha completato l’eliminazione. Riprova e conferma Elimina nel foglio di sistema.", "写真アプリが削除を完了できませんでした。もう一度試し、システムのシートで「削除」を確認してください。", "사진 앱이 삭제를 완료하지 못했습니다. 다시 시도하고 시스템 시트에서 삭제를 확인하세요.", "Zdjęcia nie dokończyły usuwania. Spróbuj ponownie i potwierdź Usuń na arkuszu systemowym.", "O Fotos não concluiu a exclusão. Tente de novo e confirme Apagar na folha do sistema.", "“照片”未能完成删除。请重试，并在系统表单中确认删除。", "Fotos no pudo completar el borrado. Inténtalo de nuevo y confirma Borrar en la hoja del sistema.", "Фото не завершило видалення. Спробуйте ще раз і підтвердіть «Видалити» в системному аркуші.")

# Legal
t("Apple Photos keeps deleted items in Recently Deleted for up to 30 days. Empty that album to recover storage immediately.", "Apple Foto’s bewaart verwijderde items tot 30 dagen in Recent verwijderd. Leeg dat album om meteen ruimte vrij te maken.", "Apple Photos conserve les éléments supprimés dans Récemment supprimés jusqu’à 30 jours. Vide cet album pour libérer de l’espace tout de suite.", "Apple Fotos behält gelöschte Elemente bis zu 30 Tage in Zuletzt gelöscht. Leere dieses Album, um Speicher sofort freizugeben.", "Foto di Apple tiene gli elementi eliminati in Eliminati di recente fino a 30 giorni. Svuota quell’album per liberare spazio subito.", "Appleの写真は削除した項目を最大30日間「最近削除した項目」に保管します。すぐに容量を空けるにはそのアルバムを空にしてください。", "Apple 사진은 삭제한 항목을 최대 30일 동안 최근 삭제된 항목에 보관합니다. 바로 공간을 확보하려면 해당 앨범을 비우세요.", "Zdjęcia Apple trzymają usunięte elementy w Ostatnio usuniętych do 30 dni. Opróżnij ten album, aby od razu odzyskać miejsce.", "O Fotos da Apple guarda itens apagados em Apagados recentemente por até 30 dias. Esvazie esse álbum para liberar espaço imediatamente.", "Apple 照片会将删除的项目保留在“最近删除”中最多 30 天。清空该相簿可立即回收空间。", "Fotos de Apple guarda lo eliminado en Eliminados hace poco hasta 30 días. Vacía ese álbum para liberar espacio al momento.", "Фото Apple зберігає видалені елементи в «Нещодавно видалені» до 30 днів. Очистіть той альбом, щоб одразу звільнити місце.")
t("Photos and videos", "Foto’s en video’s", "Photos et vidéos", "Fotos und Videos", "Foto e video", "写真とビデオ", "사진 및 동영상", "Zdjęcia i filmy", "Fotos e vídeos", "照片和视频", "Fotos y vídeos", "Фото та відео")
t("iCloud Photos", "iCloud-foto’s", "Photos iCloud", "iCloud-Fotos", "Foto di iCloud", "iCloud写真", "iCloud 사진", "Zdjęcia iCloud", "Fotos do iCloud", "iCloud 照片", "Fotos de iCloud", "Фото iCloud")
t("Reviewed state", "Bekeken status", "État déjà vu", "Geprüft-Status", "Stato già visti", "確認済みの状態", "검토 상태", "Stan przejrzanych", "Estado revisado", "已审阅状态", "Estado revisado", "Стан перегляду")
t("On-device preferences", "Voorkeuren op het apparaat", "Préférences sur l’appareil", "Einstellungen auf dem Gerät", "Preferenze sul dispositivo", "端末内の設定", "기기 내 설정", "Preferencje na urządzeniu", "Preferências no dispositivo", "设备端偏好", "Preferencias en el dispositivo", "Налаштування на пристрої")
t("Analytics", "Analytics", "Analyses", "Analysen", "Analisi", "分析", "분석", "Analityka", "Análises", "分析", "Analítica", "Аналітика")
t("Crash reporting", "Crashrapportage", "Rapports de plantage", "Absturzberichte", "Segnalazione crash", "クラッシュ報告", "충돌 보고", "Raporty awarii", "Relatórios de falha", "崩溃报告", "Informes de fallos", "Звіти про збої")
t("Notifications", "Meldingen", "Notifications", "Mitteilungen", "Notifiche", "通知", "알림", "Powiadomienia", "Notificações", "通知", "Notificaciones", "Сповіщення")
t("Your controls", "Jouw keuzes", "Tes contrôles", "Deine Kontrollen", "I tuoi controlli", "あなたの操作", "내 컨트롤", "Twoje ustawienia", "Seus controles", "你的控制项", "Tus controles", "Ваші елементи керування")
t("Contact", "Contact", "Contact", "Kontakt", "Contatti", "お問い合わせ", "문의", "Kontakt", "Contato", "联系", "Contacto", "Контакт")

t(
    "BurnRoll requires Photo Library access for its core functionality. With your permission, it uses Apple’s Photos framework to display the library you make available, calculate local counts and estimates, and move only the items you confirm to Recently Deleted. Photos are processed locally on this device. BurnRoll does not upload your photos or videos to BurnRoll servers, and photo contents are not sent to Firebase Analytics.",
    "BurnRoll heeft toegang tot de Fotobibliotheek nodig voor de kernfuncties. Met jouw toestemming gebruikt het het Photos-framework van Apple om de bibliotheek te tonen, lokale aantallen en schattingen te berekenen en alleen bevestigde items naar Recent verwijderd te verplaatsen. Foto’s worden lokaal op dit apparaat verwerkt. BurnRoll uploadt je foto’s of video’s niet naar BurnRoll-servers en foto-inhoud gaat niet naar Firebase Analytics.",
    "BurnRoll a besoin de l’accès à la photothèque pour fonctionner. Avec ta permission, il utilise le framework Photos d’Apple pour afficher la bibliothèque, calculer des totaux et estimations locaux, et déplacer uniquement les éléments confirmés vers Récemment supprimés. Les photos sont traitées localement. BurnRoll n’envoie pas tes photos ou vidéos vers ses serveurs, et leur contenu n’est pas envoyé à Firebase Analytics.",
    "BurnRoll braucht Mediathek-Zugriff für die Kernfunktionen. Mit deiner Erlaubnis nutzt es Apples Photos-Framework, um die Mediathek zu zeigen, lokale Zählungen und Schätzungen zu berechnen und nur bestätigte Elemente nach Zuletzt gelöscht zu verschieben. Fotos werden lokal verarbeitet. BurnRoll lädt keine Fotos oder Videos auf BurnRoll-Server und sendet keine Fotoinhalte an Firebase Analytics.",
    "BurnRoll richiede l’accesso alla libreria Foto per le funzioni principali. Con il tuo permesso usa il framework Foto di Apple per mostrare la libreria, calcolare conteggi e stime locali e spostare solo gli elementi confermati in Eliminati di recente. Le foto sono elaborate in locale. BurnRoll non carica foto o video sui server BurnRoll e i contenuti non vanno a Firebase Analytics.",
    "BurnRollの中核機能には写真ライブラリへのアクセスが必要です。許可があればAppleのPhotosフレームワークで表示、件数と見積もりの算出、確認した項目のみ「最近削除した項目」へ移動します。写真はこの端末で処理されます。BurnRollは写真やビデオを自社サーバーにアップロードせず、内容をFirebase Analyticsに送りません。",
    "BurnRoll의 핵심 기능에는 사진 보관함 접근이 필요합니다. 허가를 받으면 Apple Photos 프레임워크로 보관함을 표시하고 로컬 개수와 추정치를 계산하며, 확인한 항목만 최근 삭제된 항목으로 옮깁니다. 사진은 이 기기에서 처리됩니다. BurnRoll은 사진이나 동영상을 BurnRoll 서버에 올리지 않으며 내용을 Firebase Analytics로 보내지 않습니다.",
    "BurnRoll potrzebuje dostępu do biblioteki Zdjęć. Za Twoją zgodą korzysta z frameworku Photos Apple, aby pokazać bibliotekę, policzyć elementy, oszacować rozmiar i przenieść tylko potwierdzone elementy do Ostatnio usuniętych. Zdjęcia są przetwarzane lokalnie. BurnRoll nie wysyła zdjęć ani filmów na serwery BurnRoll i nie przesyła treści do Firebase Analytics.",
    "O BurnRoll precisa de acesso à biblioteca de Fotos. Com sua permissão, usa o framework Photos da Apple para mostrar a biblioteca, calcular contagens e estimativas locais e mover só os itens confirmados para Apagados recentemente. As fotos são processadas neste dispositivo. O BurnRoll não envia fotos ou vídeos aos servidores BurnRoll e o conteúdo não vai para o Firebase Analytics.",
    "BurnRoll 的核心功能需要照片图库权限。经你许可后，它使用 Apple 的 Photos 框架显示你开放的图库、计算本地数量与估算，并仅将你确认的项目移到“最近删除”。照片在本机处理。BurnRoll 不会把照片或视频上传到 BurnRoll 服务器，也不会把照片内容发送到 Firebase Analytics。",
    "BurnRoll necesita acceso a la fototeca. Con tu permiso usa el framework Fotos de Apple para mostrar la biblioteca, calcular recuentos y estimaciones locales y mover solo lo que confirmes a Eliminados hace poco. Las fotos se procesan en este dispositivo. BurnRoll no sube fotos ni vídeos a sus servidores ni envía su contenido a Firebase Analytics.",
    "BurnRoll потребує доступу до бібліотеки Фото. З вашого дозволу він використовує фреймворк Photos Apple, щоб показувати бібліотеку, рахувати елементи, оцінювати розмір і переміщувати лише підтверджені елементи в «Нещодавно видалені». Фото обробляються на цьому пристрої. BurnRoll не завантажує фото чи відео на сервери BurnRoll і не надсилає вміст у Firebase Analytics.",
)

t(
    "If you use iCloud Photos, Apple may download or synchronize library items according to your iCloud settings. Deletions made through BurnRoll may also synchronize across devices signed in to the same Apple Account. This Apple service is separate from BurnRoll and is controlled by your device and iCloud settings.",
    "Als je iCloud-foto’s gebruikt, kan Apple items downloaden of synchroniseren volgens je iCloud-instellingen. Verwijderingen via BurnRoll kunnen synchroniseren op apparaten met hetzelfde Apple Account. Deze Apple-dienst is los van BurnRoll en wordt bepaald door je apparaat- en iCloud-instellingen.",
    "Si tu utilises Photos iCloud, Apple peut télécharger ou synchroniser des éléments selon tes réglages iCloud. Les suppressions via BurnRoll peuvent se synchroniser sur les appareils du même compte Apple. Ce service Apple est distinct de BurnRoll et dépend de tes réglages.",
    "Wenn du iCloud-Fotos nutzt, kann Apple Elemente gemäß deinen iCloud-Einstellungen laden oder synchronisieren. Löschungen über BurnRoll können sich auf Geräte mit demselben Apple Account übertragen. Dieser Apple-Dienst ist unabhängig von BurnRoll.",
    "Se usi Foto di iCloud, Apple può scaricare o sincronizzare elementi in base alle impostazioni iCloud. Le eliminazioni da BurnRoll possono sincronizzarsi sui dispositivi con lo stesso Apple Account. Questo servizio Apple è separato da BurnRoll.",
    "iCloud写真を使う場合、AppleはiCloud設定に従って項目をダウンロードまたは同期します。BurnRollでの削除も同じApple Accountのデバイスに同期されることがあります。このAppleサービスはBurnRollとは別で、端末とiCloudの設定で管理されます。",
    "iCloud 사진을 쓰면 Apple이 iCloud 설정에 따라 항목을 다운로드하거나 동기화할 수 있습니다. BurnRoll에서 삭제한 항목도 같은 Apple 계정 기기에 동기화될 수 있습니다. 이 Apple 서비스는 BurnRoll과 별개이며 기기와 iCloud 설정으로 제어됩니다.",
    "Jeśli używasz Zdjęć iCloud, Apple może pobierać lub synchronizować elementy według ustawień iCloud. Usunięcia w BurnRoll mogą się zsynchronizować na urządzeniach z tym samym kontem Apple. Ta usługa Apple jest oddzielna od BurnRoll.",
    "Se você usa Fotos do iCloud, a Apple pode baixar ou sincronizar itens conforme seus ajustes do iCloud. Exclusões no BurnRoll também podem sincronizar em dispositivos com a mesma Conta Apple. Este serviço da Apple é separado do BurnRoll.",
    "若使用 iCloud 照片，Apple 可能按你的 iCloud 设置下载或同步图库项目。通过 BurnRoll 删除的内容也可能同步到同一 Apple 账户下的设备。该 Apple 服务独立于 BurnRoll，由设备和 iCloud 设置控制。",
    "Si usas Fotos de iCloud, Apple puede descargar o sincronizar elementos según tus ajustes de iCloud. Los borrados con BurnRoll pueden sincronizarse en dispositivos con la misma cuenta de Apple. Este servicio de Apple es independiente de BurnRoll.",
    "Якщо ви користуєтеся Фото iCloud, Apple може завантажувати або синхронізувати елементи згідно з налаштуваннями iCloud. Видалення через BurnRoll можуть синхронізуватися на пристроях з одним Apple Account. Ця служба Apple окрема від BurnRoll.",
)

t(
    "BurnRoll stores a local checkpoint of Apple Photos identifiers so it can remember which items you have already reviewed and show All, Reviewed, and Not Reviewed collections. That checkpoint contains no photo or video data and remains on this device unless a future release adds optional cloud sync. Review history, deletion choices, filenames, and other photo-library metadata are not uploaded to Firebase.",
    "BurnRoll bewaart lokaal een checkpoint van Apple Foto’s-ID’s om te onthouden wat je al hebt bekeken en Alle, Bekeken en Niet bekeken te tonen. Dat checkpoint bevat geen foto- of videodata en blijft op dit apparaat, tenzij een latere versie optionele cloudsync toevoegt. Beoordelingsgeschiedenis, verwijderkeuzes, bestandsnamen en andere metagegevens gaan niet naar Firebase.",
    "BurnRoll stocke un point de contrôle local d’identifiants Photos Apple pour se souvenir de ce que tu as déjà vu et afficher Tout, Déjà vus et Non vus. Ce point ne contient pas de données photo ou vidéo et reste sur l’appareil, sauf sync cloud optionnelle plus tard. L’historique, les choix de suppression, les noms de fichiers et autres métadonnées n’entrent pas dans Firebase.",
    "BurnRoll speichert lokal einen Checkpoint von Apple-Fotos-Kennungen, um Geprüftes zu merken und Alle, Geprüft und Ungesehen zu zeigen. Der Checkpoint enthält keine Foto- oder Videodaten und bleibt auf dem Gerät, außer eine spätere Version bietet optionale Cloud-Sync. Verlauf, Löschentscheidungen, Dateinamen und andere Metadaten gehen nicht an Firebase.",
    "BurnRoll memorizza in locale un checkpoint di identificatori Foto Apple per ricordare cosa hai già visto e mostrare Tutti, Già visti e Da vedere. Non contiene dati foto o video e resta sul dispositivo, salvo una futura sync cloud opzionale. Cronologia, scelte di eliminazione, nomi file e altri metadati non vanno su Firebase.",
    "BurnRollは確認済みを覚えるため、Apple写真の識別子のローカルチェックポイントを保存し、すべて／確認済み／未確認を表示します。写真やビデオのデータは含まれず、将来の任意のクラウド同期がない限りこの端末に残ります。履歴、削除の選択、ファイル名などのメタデータはFirebaseに送られません。",
    "BurnRoll은 이미 검토한 항목을 기억하고 전체, 검토됨, 미검토를 보여 주려고 Apple 사진 식별자의 로컬 체크포인트를 저장합니다. 사진·동영상 데이터는 없으며 이후 선택적 클라우드 동기화가 추가되지 않는 한 이 기기에 남습니다. 검토 기록, 삭제 선택, 파일 이름 등 메타데이터는 Firebase로 올라가지 않습니다.",
    "BurnRoll zapisuje lokalny punkt kontrolny identyfikatorów Zdjęć Apple, aby pamiętać, co już przejrzano, i pokazywać Wszystkie, Przejrzane i Nieprzejrzane. Nie zawiera danych zdjęć ani filmów i zostaje na urządzeniu, chyba że przyszła wersja doda opcjonalną synchronizację w chmurze. Historia, decyzje usuwania, nazwy plików i inne metadane nie trafiają do Firebase.",
    "O BurnRoll guarda um ponto local de identificadores do Fotos da Apple para lembrar o que você já revisou e mostrar Tudo, Revisados e Não revisados. Não contém dados de foto ou vídeo e fica neste dispositivo, salvo uma futura sincronização opcional na nuvem. Histórico, escolhas de exclusão, nomes de arquivo e outros metadados não vão para o Firebase.",
    "BurnRoll 会在本地保存 Apple 照片标识符检查点，以记住已审阅项目并显示全部、已审阅和未审阅。检查点不含照片或视频数据，除非日后可选云同步，否则只留在本机。审阅历史、删除选择、文件名和其他图库元数据不会上传到 Firebase。",
    "BurnRoll guarda un punto de control local de identificadores de Fotos de Apple para recordar lo revisado y mostrar Todo, Revisados y Sin revisar. No contiene datos de foto o vídeo y permanece en este dispositivo, salvo una futura sincronización opcional en la nube. El historial, las decisiones de borrado, nombres de archivo y demás metadatos no se suben a Firebase.",
    "BurnRoll зберігає локальну контрольну точку ідентифікаторів Фото Apple, щоб пам’ятати переглянуте й показувати Усі, Переглянуто та Не переглянуто. Вона не містить даних фото чи відео й лишається на пристрої, доки майбутня версія не додасть хмарну синхронізацію. Історія, вибір видалення, імена файлів та інші метадані не потрапляють у Firebase.",
)

t(
    "BurnRoll also stores onboarding status, whether the first-run swipe hint has been shown, haptic and reminder choices, cleanup counts, size estimates and review durations, and the date of your last confirmed cleanup for streak calculation. The Home Screen icon you pick is stored by iOS on this device. There is no BurnRoll account. These preferences remain on the device until you change them, reset the review bookmark, reset the app, or delete the app.",
    "BurnRoll bewaart ook onboardingstatus, of de swipehint is getoond, haptiek- en herinneringskeuzes, opruimtellingen, schattingen, beoordelingsduur en de datum van de laatste bevestigde opruiming voor reeksen. Het beginschermicoon bewaart iOS op dit apparaat. Er is geen BurnRoll-account. Deze voorkeuren blijven tot je ze wijzigt, de bladwijzer reset, de app reset of verwijdert.",
    "BurnRoll stocke aussi le statut d’accueil, si l’indice de glissement a été montré, les choix haptiques et de rappel, les totaux de nettoyage, estimations, durées de revue et la date du dernier nettoyage confirmé. L’icône d’accueil est stockée par iOS. Il n’y a pas de compte BurnRoll. Ces préférences restent jusqu’à modification, réinitialisation du signet, de l’app ou suppression.",
    "BurnRoll speichert auch den Onboarding-Status, ob der Wischhinweis gezeigt wurde, Haptik- und Erinnerungswahlen, Bereinigungszahlen, Schätzungen, Prüfzeiten und das Datum der letzten bestätigten Bereinigung. Das Home-Bildschirm-Symbol speichert iOS. Es gibt kein BurnRoll-Konto. Diese Einstellungen bleiben, bis du sie änderst, das Lesezeichen oder die App zurücksetzt oder die App löschst.",
    "BurnRoll memorizza anche lo stato dell’introduzione, se il suggerimento swipe è stato mostrato, scelte aptiche e di promemoria, conteggi, stime, durate di revisione e la data dell’ultima pulizia confermata. L’icona Home è salvata da iOS. Non esiste un account BurnRoll. Restano sul dispositivo finché non le cambi, reimposti il segnalibro o l’app, o elimini l’app.",
    "BurnRollはオンボーディング状態、初回スワイプ案内の表示、触覚とリマインダーの選択、整理回数、見積もり、確認時間、連続日数用の最終確認日も保存します。ホーム画面アイコンはiOSがこの端末に保存します。BurnRollアカウントはありません。変更、しおりリセット、アプリのリセットまたは削除まで端末に残ります。",
    "BurnRoll은 온보딩 상태, 첫 스와이프 힌트 표시 여부, 햅틱과 알림 선택, 정리 횟수, 추정치, 검토 시간, 연속 기록을 위한 마지막 확인 날짜도 저장합니다. 홈 화면 아이콘은 iOS가 이 기기에 저장합니다. BurnRoll 계정은 없습니다. 변경, 북마크 재설정, 앱 재설정 또는 삭제 전까지 기기에 남습니다.",
    "BurnRoll zapisuje też stan wprowadzenia, czy pokazano podpowiedź gestu, wybory haptyki i przypomnień, liczby czyszczeń, szacunki, czasy przeglądu i datę ostatniego potwierdzonego czyszczenia. Ikonę ekranu początkowego zapisuje iOS. Nie ma konta BurnRoll. Preferencje zostają do zmiany, resetu zakładki, resetu lub usunięcia aplikacji.",
    "O BurnRoll também guarda o status da introdução, se a dica de deslizar foi mostrada, escolhas de tátil e lembrete, contagens, estimativas, durações de revisão e a data da última limpeza confirmada. O ícone da Tela de Início é guardado pelo iOS. Não há conta BurnRoll. As preferências ficam no dispositivo até você alterá-las, redefinir o marcador, redefinir ou apagar o app.",
    "BurnRoll 还会存储引导状态、是否已显示首次滑动提示、触感与提醒选项、清理次数、估算、审阅时长，以及用于连续记录的上次确认清理日期。主屏幕图标由 iOS 保存在本机。没有 BurnRoll 账户。这些偏好会保留到你更改、重置审阅书签、重置或删除 App。",
    "BurnRoll también guarda el estado de la intro, si se mostró la pista de deslizamiento, opciones hápticas y de recordatorio, recuentos, estimaciones, duraciones de revisión y la fecha de la última limpieza confirmada. El icono de inicio lo guarda iOS. No hay cuenta BurnRoll. Las preferencias se quedan hasta que las cambies, restablezcas el marcador, restablezcas o borres la app.",
    "BurnRoll також зберігає стан ознайомлення, чи показано підказку жесту, вибір тактильності й нагадувань, лічильники очищення, оцінки, тривалість перегляду та дату останнього підтвердженого очищення. Іконку Початкового екрана зберігає iOS. Облікового запису BurnRoll немає. Налаштування лишаються, доки ви їх не зміните, не скинете закладку чи програму або не видалите програму.",
)

t(
    "BurnRoll uses Firebase Analytics to understand aggregate product usage, such as app launches, session activity, onboarding and permission outcomes, filter selection, and counts of review actions. Firebase may also receive technical app and device information. Analytics do not include your photos, image thumbnails, filenames, file paths, EXIF metadata, or identifiers that uniquely identify a photo.",
    "BurnRoll gebruikt Firebase Analytics voor geaggregeerd gebruik, zoals starts, sessies, onboarding en toestemmingen, filterkeuze en aantallen beoordelingen. Firebase kan ook technische app- en apparaatinformatie ontvangen. Analytics bevat geen foto’s, miniaturen, bestandsnamen, paden, EXIF of unieke foto-ID’s.",
    "BurnRoll utilise Firebase Analytics pour l’usage agrégé : lancements, sessions, accueil et permissions, filtres et comptes d’actions. Firebase peut aussi recevoir des infos techniques. Les analyses n’incluent pas tes photos, miniatures, noms, chemins, EXIF ni identifiants uniques de photo.",
    "BurnRoll nutzt Firebase Analytics für aggregierte Nutzung: Starts, Sitzungen, Onboarding und Berechtigungen, Filter und Aktionszahlen. Firebase kann auch technische App- und Geräteinfos erhalten. Analysen enthalten keine Fotos, Miniaturen, Dateinamen, Pfade, EXIF oder eindeutige Foto-IDs.",
    "BurnRoll usa Firebase Analytics per l’uso aggregato: avvii, sessioni, onboarding e autorizzazioni, filtri e conteggi. Firebase può ricevere anche dati tecnici. Le analisi non includono foto, miniature, nomi, percorsi, EXIF o identificatori unici di una foto.",
    "BurnRollは起動、セッション、オンボーディングと許可、フィルター選択、確認操作の件数など集計利用状況を把握するためFirebase Analyticsを使います。技術的なアプリ・端末情報も送られることがあります。写真、サムネイル、ファイル名、パス、EXIF、写真を特定するIDは含まれません。",
    "BurnRoll은 실행, 세션, 온보딩과 권한, 필터 선택, 검토 횟수 등 집계된 사용을 파악하려고 Firebase Analytics를 씁니다. 기술적 앱·기기 정보도 받을 수 있습니다. 분석에는 사진, 미리보기, 파일 이름, 경로, EXIF, 사진을 식별하는 ID가 포함되지 않습니다.",
    "BurnRoll używa Firebase Analytics do zagregowanego użycia: uruchomienia, sesje, wprowadzenie i uprawnienia, filtry i liczby działań. Firebase może też dostać dane techniczne. Analityka nie zawiera zdjęć, miniaturek, nazw, ścieżek, EXIF ani unikalnych identyfikatorów zdjęć.",
    "O BurnRoll usa o Firebase Analytics para uso agregado: aberturas, sessões, introdução e permissões, filtros e contagens. O Firebase também pode receber dados técnicos. As análises não incluem fotos, miniaturas, nomes, caminhos, EXIF nem identificadores únicos de foto.",
    "BurnRoll 使用 Firebase Analytics 了解汇总使用情况，例如启动、会话、引导与权限结果、筛选选择和审阅操作次数。Firebase 也可能收到技术和设备信息。分析不含照片、缩略图、文件名、路径、EXIF 或可唯一识别照片的标识符。",
    "BurnRoll usa Firebase Analytics para el uso agregado: aperturas, sesiones, intro y permisos, filtros y recuentos. Firebase también puede recibir datos técnicos. La analítica no incluye fotos, miniaturas, nombres, rutas, EXIF ni identificadores únicos de una foto.",
    "BurnRoll використовує Firebase Analytics для зведеного використання: запуски, сесії, ознайомлення й дозволи, фільтри та лічильники. Firebase також може отримувати технічні дані. Аналітика не містить фото, мініатюр, імен, шляхів, EXIF чи унікальних ідентифікаторів фото.",
)

t(
    "BurnRoll uses Firebase Crashlytics for crash diagnostics and application stability. Crash reports describe the app’s technical state. They are not used to send your photos or photo-library contents.",
    "BurnRoll gebruikt Firebase Crashlytics voor crashdiagnose en stabiliteit. Rapporten beschrijven de technische staat van de app. Ze worden niet gebruikt om foto’s of bibliotheekinhoud te versturen.",
    "BurnRoll utilise Firebase Crashlytics pour les diagnostics de plantage et la stabilité. Les rapports décrivent l’état technique. Ils n’envoient pas tes photos ni le contenu de la photothèque.",
    "BurnRoll nutzt Firebase Crashlytics für Absturzdiagnosen und Stabilität. Berichte beschreiben den technischen Zustand. Damit werden keine Fotos oder Mediathekinhalte gesendet.",
    "BurnRoll usa Firebase Crashlytics per diagnostica crash e stabilità. I report descrivono lo stato tecnico. Non servono a inviare foto o contenuti della libreria.",
    "BurnRollはクラッシュ診断と安定性のためFirebase Crashlyticsを使います。報告はアプリの技術状態です。写真やライブラリ内容の送信には使いません。",
    "BurnRoll은 충돌 진단과 안정성을 위해 Firebase Crashlytics를 씁니다. 보고서는 앱의 기술 상태를 담습니다. 사진이나 보관함 내용을 보내는 데 쓰이지 않습니다.",
    "BurnRoll używa Firebase Crashlytics do diagnostyki awarii i stabilności. Raporty opisują stan techniczny. Nie służą do wysyłania zdjęć ani zawartości biblioteki.",
    "O BurnRoll usa o Firebase Crashlytics para diagnóstico de falhas e estabilidade. Os relatórios descrevem o estado técnico. Não servem para enviar fotos ou o conteúdo da biblioteca.",
    "BurnRoll 使用 Firebase Crashlytics 进行崩溃诊断与稳定性分析。报告描述 App 的技术状态，不会用来发送照片或图库内容。",
    "BurnRoll usa Firebase Crashlytics para diagnósticos de fallos y estabilidad. Los informes describen el estado técnico. No se usan para enviar fotos ni el contenido de la fototeca.",
    "BurnRoll використовує Firebase Crashlytics для діагностики збоїв і стабільності. Звіти описують технічний стан. Вони не надсилають фото чи вміст бібліотеки.",
)

t(
    "Cleanup reminders are optional and require your permission. If you opt in, BurnRoll stores an on-device library baseline and schedules a local reminder for your selected threshold of 20–500 additional photos, approximately 5 GB of estimated media growth, or an exact 30-day interval. iOS does not continuously wake BurnRoll to inspect Photos while the app is closed, so BurnRoll evaluates accumulation when the app opens and schedules a conservative local reminder. You can turn reminders off in BurnRoll Settings, or change notification permission in iOS Settings.",
    "Opruimherinneringen zijn optioneel en vragen toestemming. Als je meedoet, bewaart BurnRoll lokaal een basislijn en plant een lokale herinnering voor 20–500 extra foto’s, ongeveer 5 GB groei of exact 30 dagen. iOS wekt BurnRoll niet continu om Foto’s te controleren als de app dicht is; bij openen wordt groei beoordeeld. Zet herinneringen uit in BurnRoll of wijzig meldingen in iOS.",
    "Les rappels de nettoyage sont facultatifs et demandent ta permission. En t’inscrivant, BurnRoll stocke une base locale et programme un rappel pour 20–500 photos de plus, environ 5 Go, ou 30 jours exacts. iOS ne réveille pas BurnRoll en continu. L’app évalue à l’ouverture. Désactive les rappels dans BurnRoll ou change les notifications iOS.",
    "Bereinigungserinnerungen sind optional und brauchen Erlaubnis. Bei Opt-in speichert BurnRoll eine lokale Basis und plant eine Erinnerung für 20–500 zusätzliche Fotos, etwa 5 GB oder genau 30 Tage. iOS weckt BurnRoll nicht dauerhaft. Die App prüft beim Öffnen. Erinnerungen kannst du in BurnRoll oder in den iOS-Mitteilungen ändern.",
    "I promemoria di pulizia sono facoltativi e richiedono il permesso. Se aderisci, BurnRoll salva una baseline locale e programma un promemoria per 20–500 foto in più, circa 5 GB o 30 giorni esatti. iOS non riattiva BurnRoll in continuo. All’apertura valuta l’accumulo. Puoi disattivare i promemoria in BurnRoll o cambiare le notifiche iOS.",
    "整理リマインダーは任意で許可が必要です。オンにすると端末内の基準を保存し、追加20〜500枚、約5 GB、または正確な30日でローカル通知を予約します。アプリが閉じている間、iOSはPhotosを常時検査するためにBurnRollを起こしません。開いたときに増加を評価します。BurnRoll設定かiOSの通知許可でオフにできます。",
    "정리 알림은 선택 사항이며 권한이 필요합니다. 동의하면 BurnRoll이 기기 내 기준을 저장하고 추가 사진 20–500장, 약 5GB, 또는 정확히 30일 기준으로 로컬 알림을 예약합니다. 앱이 닫혀 있는 동안 iOS는 사진을 계속 검사하려고 BurnRoll을 깨우지 않습니다. 열 때 증가량을 평가합니다. BurnRoll 설정이나 iOS 알림 권한에서 끌 수 있습니다.",
    "Przypomnienia o czyszczeniu są opcjonalne i wymagają zgody. Po włączeniu BurnRoll zapisuje lokalną bazę i planuje przypomnienie na 20–500 dodatkowych zdjęć, ok. 5 GB lub dokładnie 30 dni. iOS nie budzi BurnRoll non stop. Aplikacja ocenia przy otwarciu. Wyłączysz przypomnienia w BurnRoll lub w powiadomieniach iOS.",
    "Lembretes de limpeza são opcionais e pedem permissão. Se você aderir, o BurnRoll guarda uma base no dispositivo e agenda um lembrete local para 20–500 fotos a mais, cerca de 5 GB ou 30 dias exatos. O iOS não acorda o BurnRoll o tempo todo. O app avalia ao abrir. Desligue lembretes no BurnRoll ou mude as notificações do iOS.",
    "清理提醒为可选项，需要你的许可。若开启，BurnRoll 会在设备上保存资料库基线，并按你选择的阈值安排本地提醒：额外 20–500 张照片、约 5 GB 增长，或正好 30 天。应用关闭时 iOS 不会持续唤醒 BurnRoll 检查照片；打开应用时再评估增长。可在 BurnRoll 设置中关闭，或在 iOS 设置中更改通知权限。",
    "Los recordatorios de limpieza son opcionales y piden permiso. Si te apuntas, BurnRoll guarda una base en el dispositivo y programa un recordatorio local para 20–500 fotos más, unos 5 GB o 30 días exactos. iOS no despierta BurnRoll sin parar. La app evalúa al abrir. Apaga los recordatorios en BurnRoll o cambia el permiso en iOS.",
    "Нагадування про очищення необов’язкові й потребують дозволу. Якщо ви погоджуєтесь, BurnRoll зберігає локальну базову лінію й планує нагадування на 20–500 додаткових фото, приблизно 5 ГБ або рівно 30 днів. iOS не будить BurnRoll постійно. Програма оцінює при відкритті. Вимкніть нагадування в BurnRoll або змініть дозвіл у iOS.",
)

t(
    "You can limit or revoke Photos and notification access at any time in iOS Settings. BurnRoll does not retain a server copy of your library or preferences, so there is no remote personal-data account to delete.",
    "Je kunt toegang tot Foto’s en meldingen altijd beperken of intrekken in iOS-instellingen. BurnRoll bewaart geen serverkopie van je bibliotheek of voorkeuren, dus er is geen remote account met persoonsgegevens om te verwijderen.",
    "Tu peux limiter ou révoquer l’accès à Photos et aux notifications à tout moment dans Réglages iOS. BurnRoll ne conserve pas de copie serveur, donc il n’y a pas de compte distant à supprimer.",
    "Fotos- und Mitteilungszugriff kannst du jederzeit in den iOS-Einstellungen einschränken oder widerrufen. BurnRoll behält keine Serverkopie, es gibt kein entferntes Konto zum Löschen.",
    "Puoi limitare o revocare l’accesso a Foto e alle notifiche in qualsiasi momento in Impostazioni iOS. BurnRoll non tiene una copia sui server, quindi non c’è un account remoto da eliminare.",
    "iOS設定でいつでも写真と通知のアクセスを制限または取り消せます。BurnRollはライブラリや設定のサーバーコピーを持たないため、削除する遠隔アカウントはありません。",
    "iOS 설정에서 언제든지 사진과 알림 접근을 제한하거나 철회할 수 있습니다. BurnRoll은 보관함이나 설정의 서버 사본을 두지 않아 삭제할 원격 계정이 없습니다.",
    "Dostęp do Zdjęć i powiadomień ograniczysz lub cofniesz w dowolnej chwili w Ustawieniach iOS. BurnRoll nie trzyma kopii na serwerze, więc nie ma zdalnego konta do usunięcia.",
    "Você pode limitar ou revogar o acesso a Fotos e notificações a qualquer momento nos Ajustes do iOS. O BurnRoll não guarda cópia no servidor, então não há conta remota para apagar.",
    "你可以随时在 iOS 设置中限制或撤销照片与通知权限。BurnRoll 不在服务器保留图库或偏好副本，因此没有需要删除的远程个人数据账户。",
    "Puedes limitar o revocar el acceso a Fotos y notificaciones en cualquier momento en Ajustes de iOS. BurnRoll no guarda una copia en servidores, así que no hay una cuenta remota que borrar.",
    "Доступ до Фото й сповіщень можна обмежити або відкликати будь-коли в Налаштуваннях iOS. BurnRoll не зберігає серверну копію бібліотеки чи налаштувань, тож віддаленого облікового запису для видалення немає.",
)

t(
    "For privacy or support questions, email burnrollsupport@gmail.com.",
    "Voor privacy- of supportvragen: burnrollsupport@gmail.com.",
    "Pour les questions de confidentialité ou d’assistance : burnrollsupport@gmail.com.",
    "Bei Datenschutz- oder Supportfragen: burnrollsupport@gmail.com.",
    "Per domande su privacy o supporto: burnrollsupport@gmail.com.",
    "プライバシーやサポートは burnrollsupport@gmail.com へ。",
    "개인정보 또는 지원 문의: burnrollsupport@gmail.com",
    "Pytania o prywatność lub wsparcie: burnrollsupport@gmail.com.",
    "Dúvidas de privacidade ou suporte: burnrollsupport@gmail.com.",
    "隐私或支持问题请发邮件至 burnrollsupport@gmail.com。",
    "Para privacidad o soporte: burnrollsupport@gmail.com.",
    "З питань приватності чи підтримки: burnrollsupport@gmail.com.",
)

USAGE = (
    "BurnRoll needs access to your photo library so you can review, organize, and remove unwanted photos directly on your device.",
    "BurnRoll heeft toegang tot je fotobibliotheek nodig zodat je ongewenste foto’s op dit apparaat kunt bekijken, ordenen en verwijderen.",
    "BurnRoll a besoin d’accéder à ta photothèque pour que tu puisses revoir, ranger et supprimer des photos indésirables directement sur cet appareil.",
    "BurnRoll braucht Zugriff auf deine Mediathek, damit du unerwünschte Fotos direkt auf diesem Gerät prüfen, ordnen und entfernen kannst.",
    "BurnRoll necessita dell’accesso alla libreria Foto per rivedere, organizzare e rimuovere le foto indesiderate direttamente sul dispositivo.",
    "不要な写真をこのデバイス上で確認・整理・削除できるよう、BurnRollは写真ライブラリへのアクセスを必要とします。",
    "이 기기에서 원치 않는 사진을 검토, 정리, 삭제할 수 있도록 BurnRoll에 사진 보관함 접근 권한이 필요합니다.",
    "BurnRoll potrzebuje dostępu do biblioteki zdjęć, abyś mógł przeglądać, porządkować i usuwać niechciane zdjęcia bezpośrednio na urządzeniu.",
    "O BurnRoll precisa de acesso à sua biblioteca de fotos para você revisar, organizar e remover fotos indesejadas neste dispositivo.",
    "BurnRoll 需要访问你的照片图库，以便你在本机审阅、整理并删除不需要的照片。",
    "BurnRoll necesita acceso a tu fototeca para que revises, organices y elimines fotos no deseadas en este dispositivo.",
    "BurnRoll потребує доступу до бібліотеки фото, щоб ви могли переглядати, впорядковувати й видаляти непотрібні фото на цьому пристрої.",
)


def unit(value: str, state: str = "translated") -> dict:
    return {"stringUnit": {"state": state, "value": value}}


def localizations_for(en: str, values: list[str]) -> dict:
    out = {}
    if en.startswith("%") or "%lld" in en or "%@" in en:
        out["en"] = unit(en)
    for locale, value in zip(LOCALES, values):
        out[locale] = unit(value)
    return out


def plural_entry(spec: str, forms: dict[str, dict[str, str]]) -> dict:
    loc = {}
    for locale, cats in forms.items():
        loc[locale] = {
            "variations": {
                "plural": {cat: unit(value) for cat, value in cats.items()}
            }
        }
    return loc


def build_catalog() -> dict:
    strings: dict[str, dict] = {}
    for en, values in STRINGS.items():
        strings[en] = {
            "extractionState": "manual",
            "localizations": localizations_for(en, values),
        }

    strings["%lld items"] = {
        "extractionState": "manual",
        "localizations": plural_entry(
            "%lld items",
            {
                "en": {"one": "%lld item", "other": "%lld items"},
                "nl": {"one": "%lld item", "other": "%lld items"},
                "fr": {"one": "%lld élément", "other": "%lld éléments"},
                "de": {"one": "%lld Element", "other": "%lld Elemente"},
                "it": {"one": "%lld elemento", "other": "%lld elementi"},
                "ja": {"other": "%lld件"},
                "ko": {"other": "%lld개 항목"},
                "pl": {
                    "one": "%lld element",
                    "few": "%lld elementy",
                    "many": "%lld elementów",
                    "other": "%lld elementu",
                },
                "pt-BR": {"one": "%lld item", "other": "%lld itens"},
                "zh-Hans": {"other": "%lld 项"},
                "es": {"one": "%lld elemento", "other": "%lld elementos"},
                "uk": {
                    "one": "%lld елемент",
                    "few": "%lld елементи",
                    "many": "%lld елементів",
                    "other": "%lld елемента",
                },
            },
        ),
    }
    strings["%lld photos"] = {
        "extractionState": "manual",
        "localizations": plural_entry(
            "%lld photos",
            {
                "en": {"one": "%lld photo", "other": "%lld photos"},
                "nl": {"one": "%lld foto", "other": "%lld foto’s"},
                "fr": {"one": "%lld photo", "other": "%lld photos"},
                "de": {"one": "%lld Foto", "other": "%lld Fotos"},
                "it": {"one": "%lld foto", "other": "%lld foto"},
                "ja": {"other": "%lld枚"},
                "ko": {"other": "사진 %lld장"},
                "pl": {
                    "one": "%lld zdjęcie",
                    "few": "%lld zdjęcia",
                    "many": "%lld zdjęć",
                    "other": "%lld zdjęcia",
                },
                "pt-BR": {"one": "%lld foto", "other": "%lld fotos"},
                "zh-Hans": {"other": "%lld 张照片"},
                "es": {"one": "%lld foto", "other": "%lld fotos"},
                "uk": {
                    "one": "%lld фото",
                    "few": "%lld фото",
                    "many": "%lld фото",
                    "other": "%lld фото",
                },
            },
        ),
    }
    strings["about %lld seconds"] = {
        "extractionState": "manual",
        "localizations": plural_entry(
            "about %lld seconds",
            {
                "en": {"one": "about %lld second", "other": "about %lld seconds"},
                "nl": {"one": "ongeveer %lld seconde", "other": "ongeveer %lld seconden"},
                "fr": {"one": "environ %lld seconde", "other": "environ %lld secondes"},
                "de": {"one": "etwa %lld Sekunde", "other": "etwa %lld Sekunden"},
                "it": {"one": "circa %lld secondo", "other": "circa %lld secondi"},
                "ja": {"other": "約%lld秒"},
                "ko": {"other": "약 %lld초"},
                "pl": {
                    "one": "ok. %lld sekundy",
                    "few": "ok. %lld sekundy",
                    "many": "ok. %lld sekund",
                    "other": "ok. %lld sekundy",
                },
                "pt-BR": {"one": "cerca de %lld segundo", "other": "cerca de %lld segundos"},
                "zh-Hans": {"other": "约 %lld 秒"},
                "es": {"one": "unos %lld segundo", "other": "unos %lld segundos"},
                "uk": {
                    "one": "близько %lld секунди",
                    "few": "близько %lld секунди",
                    "many": "близько %lld секунд",
                    "other": "близько %lld секунди",
                },
            },
        ),
    }
    strings["about %lld minutes"] = {
        "extractionState": "manual",
        "localizations": plural_entry(
            "about %lld minutes",
            {
                "en": {"one": "about %lld minute", "other": "about %lld minutes"},
                "nl": {"one": "ongeveer %lld minuut", "other": "ongeveer %lld minuten"},
                "fr": {"one": "environ %lld minute", "other": "environ %lld minutes"},
                "de": {"one": "etwa %lld Minute", "other": "etwa %lld Minuten"},
                "it": {"one": "circa %lld minuto", "other": "circa %lld minuti"},
                "ja": {"other": "約%lld分"},
                "ko": {"other": "약 %lld분"},
                "pl": {
                    "one": "ok. %lld minuty",
                    "few": "ok. %lld minuty",
                    "many": "ok. %lld minut",
                    "other": "ok. %lld minuty",
                },
                "pt-BR": {"one": "cerca de %lld minuto", "other": "cerca de %lld minutos"},
                "zh-Hans": {"other": "约 %lld 分钟"},
                "es": {"one": "unos %lld minuto", "other": "unos %lld minutos"},
                "uk": {
                    "one": "близько %lld хвилини",
                    "few": "близько %lld хвилини",
                    "many": "близько %lld хвилин",
                    "other": "близько %lld хвилини",
                },
            },
        ),
    }
    strings["about %lld min %lld sec"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("about %lld min %lld sec"),
            "nl": unit("ongeveer %lld min %lld sec"),
            "fr": unit("environ %lld min %lld s"),
            "de": unit("etwa %lld Min %lld Sek"),
            "it": unit("circa %lld min %lld s"),
            "ja": unit("約%lld分%lld秒"),
            "ko": unit("약 %lld분 %lld초"),
            "pl": unit("ok. %lld min %lld s"),
            "pt-BR": unit("cerca de %lld min %lld s"),
            "zh-Hans": unit("约 %lld 分 %lld 秒"),
            "es": unit("unos %lld min %lld s"),
            "uk": unit("близько %lld хв %lld с"),
        },
    }
    strings["You have %lld new photos. Want to clean them up? Reviewing should take %@."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("You have %lld new photos. Want to clean them up? Reviewing should take %@."),
            "nl": unit("Je hebt %lld nieuwe foto’s. Wil je ze opruimen? Beoordelen duurt ongeveer %@."),
            "fr": unit("Tu as %lld nouvelles photos. Tu veux les ranger ? La revue devrait prendre %@."),
            "de": unit("Du hast %lld neue Fotos. Willst du aufräumen? Das Prüfen dauert etwa %@."),
            "it": unit("Hai %lld nuove foto. Vuoi riordinarle? La revisione dovrebbe richiedere %@."),
            "ja": unit("新しい写真が%lld枚あります。整理しますか？確認は%@かかります。"),
            "ko": unit("새 사진 %lld장이 있습니다. 정리할까요? 검토에는 %@ 걸립니다."),
            "pl": unit("Masz %lld nowych zdjęć. Posprzątać? Przegląd zajmie %@."),
            "pt-BR": unit("Você tem %lld fotos novas. Quer limpar? A revisão deve levar %@."),
            "zh-Hans": unit("你有 %lld 张新照片。要清理吗？审阅大约需要%@。"),
            "es": unit("Tienes %lld fotos nuevas. ¿Las limpiamos? Revisar debería llevar %@."),
            "uk": unit("У вас %lld нових фото. Прибрати? Перегляд займе %@."),
        },
    }
    strings["Next: %@"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Next: %@"),
            "nl": unit("Volgende: %@"),
            "fr": unit("Suivant : %@"),
            "de": unit("Als Nächstes: %@"),
            "it": unit("Prossimo: %@"),
            "ja": unit("次: %@"),
            "ko": unit("다음: %@"),
            "pl": unit("Następne: %@"),
            "pt-BR": unit("Próximo: %@"),
            "zh-Hans": unit("下次：%@"),
            "es": unit("Siguiente: %@"),
            "uk": unit("Далі: %@"),
        },
    }
    strings["After %@ new photos"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("After %@ new photos"),
            "nl": unit("Na %@ nieuwe foto’s"),
            "fr": unit("Après %@ nouvelles photos"),
            "de": unit("Nach %@ neuen Fotos"),
            "it": unit("Dopo %@ nuove foto"),
            "ja": unit("新しい写真%@枚のあと"),
            "ko": unit("새 사진 %@장 후"),
            "pl": unit("Po %@ nowych zdjęciach"),
            "pt-BR": unit("Após %@ fotos novas"),
            "zh-Hans": unit("新增 %@ 张照片后"),
            "es": unit("Tras %@ fotos nuevas"),
            "uk": unit("Після %@ нових фото"),
        },
    }
    strings["%@ of %@"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("%@ of %@"),
            "nl": unit("%@ van %@"),
            "fr": unit("%@ sur %@"),
            "de": unit("%@ von %@"),
            "it": unit("%@ di %@"),
            "ja": unit("%@ / %@"),
            "ko": unit("%@ / %@"),
            "pl": unit("%@ z %@"),
            "pt-BR": unit("%@ de %@"),
            "zh-Hans": unit("%@ / %@"),
            "es": unit("%@ de %@"),
            "uk": unit("%@ з %@"),
        },
    }
    strings["This disclosure describes BurnRoll version %@."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("This disclosure describes BurnRoll version %@."),
            "nl": unit("Deze toelichting geldt voor BurnRoll versie %@."),
            "fr": unit("Cette notice décrit BurnRoll version %@."),
            "de": unit("Dieser Hinweis gilt für BurnRoll Version %@."),
            "it": unit("Questa informativa descrive BurnRoll versione %@."),
            "ja": unit("この説明はBurnRollバージョン%@に関するものです。"),
            "ko": unit("이 안내는 BurnRoll 버전 %@에 해당합니다."),
            "pl": unit("To oświadczenie dotyczy BurnRoll w wersji %@."),
            "pt-BR": unit("Este aviso descreve o BurnRoll versão %@."),
            "zh-Hans": unit("本说明适用于 BurnRoll 版本 %@。"),
            "es": unit("Esta información describe BurnRoll versión %@."),
            "uk": unit("Це розкриття стосується BurnRoll версії %@."),
        },
    }
    strings["No items in %@"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("No items in %@"),
            "nl": unit("Geen items in %@"),
            "fr": unit("Aucun élément dans %@"),
            "de": unit("Keine Elemente in %@"),
            "it": unit("Nessun elemento in %@"),
            "ja": unit("%@に項目がありません"),
            "ko": unit("%@에 항목이 없습니다"),
            "pl": unit("Brak elementów w %@"),
            "pt-BR": unit("Nenhum item em %@"),
            "zh-Hans": unit("%@ 中没有项目"),
            "es": unit("No hay elementos en %@"),
            "uk": unit("Немає елементів у %@"),
        },
    }
    strings["You reviewed everything in %@."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("You reviewed everything in %@."),
            "nl": unit("Je hebt alles in %@ bekeken."),
            "fr": unit("Tu as tout revu dans %@."),
            "de": unit("Du hast alles in %@ geprüft."),
            "it": unit("Hai riveduto tutto in %@."),
            "ja": unit("%@のすべてを確認しました。"),
            "ko": unit("%@의 모든 항목을 검토했습니다."),
            "pl": unit("Przejrzałeś wszystko w %@."),
            "pt-BR": unit("Você revisou tudo em %@."),
            "zh-Hans": unit("你已审阅 %@ 中的全部内容。"),
            "es": unit("Has revisado todo en %@."),
            "uk": unit("Ви переглянули все в %@."),
        },
    }
    strings["You reviewed everything in %@. Come back later and new items will appear here automatically."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("You reviewed everything in %@. Come back later and new items will appear here automatically."),
            "nl": unit("Je hebt alles in %@ bekeken. Kom later terug; nieuwe items verschijnen automatisch."),
            "fr": unit("Tu as tout revu dans %@. Reviens plus tard, les nouveaux éléments apparaîtront seuls."),
            "de": unit("Du hast alles in %@ geprüft. Komm später wieder; neue Elemente erscheinen automatisch."),
            "it": unit("Hai riveduto tutto in %@. Torna più tardi: i nuovi elementi compariranno da soli."),
            "ja": unit("%@のすべてを確認しました。後で戻ると新しい項目が自動で表示されます。"),
            "ko": unit("%@의 모든 항목을 검토했습니다. 나중에 돌아오면 새 항목이 자동으로 나타납니다."),
            "pl": unit("Przejrzałeś wszystko w %@. Wróć później — nowe elementy pojawią się same."),
            "pt-BR": unit("Você revisou tudo em %@. Volte depois: itens novos aparecem sozinhos."),
            "zh-Hans": unit("你已审阅 %@ 中的全部内容。稍后再来，新项目会自动出现。"),
            "es": unit("Has revisado todo en %@. Vuelve luego y los elementos nuevos aparecerán solos."),
            "uk": unit("Ви переглянули все в %@. Зайдіть пізніше — нові елементи з’являться самі."),
        },
    }
    strings["Your bookmark is up to date. New photos will appear here automatically, or choose Reviewed or All items from the top-left button."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Your bookmark is up to date. New photos will appear here automatically, or choose Reviewed or All items from the top-left button."),
            "nl": unit("Je bladwijzer is bij. Nieuwe foto’s verschijnen automatisch, of kies Bekeken of Alle items via de knop linksboven."),
            "fr": unit("Ton signet est à jour. Les nouvelles photos apparaissent seules, ou choisis Déjà vus ou Tous les éléments en haut à gauche."),
            "de": unit("Dein Lesezeichen ist aktuell. Neue Fotos erscheinen automatisch, oder wähle Geprüft oder Alle Elemente oben links."),
            "it": unit("Il segnalibro è aggiornato. Le nuove foto compaiono da sole, oppure scegli Già visti o Tutti gli elementi in alto a sinistra."),
            "ja": unit("しおりは最新です。新しい写真は自動で表示されます。左上から確認済みまたはすべての項目も選べます。"),
            "ko": unit("북마크가 최신입니다. 새 사진은 자동으로 나타나거나, 왼쪽 위에서 검토됨 또는 전체 항목을 고르세요."),
            "pl": unit("Zakładka jest aktualna. Nowe zdjęcia pojawią się same albo wybierz Przejrzane lub Wszystkie elementy u góry po lewej."),
            "pt-BR": unit("Seu marcador está em dia. Fotos novas aparecem sozinhas, ou escolha Revisados ou Todos os itens no botão superior esquerdo."),
            "zh-Hans": unit("书签已是最新。新照片会自动出现，也可点左上角选择已审阅或全部项目。"),
            "es": unit("Tu marcador está al día. Las fotos nuevas aparecen solas, o elige Revisados o Todos los elementos arriba a la izquierda."),
            "uk": unit("Закладка актуальна. Нові фото з’являться самі, або оберіть «Переглянуто» чи «Усі елементи» зліва вгорі."),
        },
    }
    strings["%@ - %@ - will free"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("%@ - %@ - will free"),
            "nl": unit("%@ - %@ - maakt vrij"),
            "fr": unit("%@ - %@ - libérera"),
            "de": unit("%@ - %@ - gibt frei"),
            "it": unit("%@ - %@ - libererà"),
            "ja": unit("%@ - %@ - 解放予定"),
            "ko": unit("%@ - %@ - 확보 예정"),
            "pl": unit("%@ - %@ - zwolni"),
            "pt-BR": unit("%@ - %@ - liberará"),
            "zh-Hans": unit("%@ - %@ - 将释放"),
            "es": unit("%@ - %@ - liberará"),
            "uk": unit("%@ - %@ - звільнить"),
        },
    }
    strings["Review %lld"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Review %lld"),
            "nl": unit("Beoordelen %lld"),
            "fr": unit("Revoir %lld"),
            "de": unit("Prüfen %lld"),
            "it": unit("Rivedi %lld"),
            "ja": unit("確認 %lld"),
            "ko": unit("검토 %lld"),
            "pl": unit("Przegląd %lld"),
            "pt-BR": unit("Revisar %lld"),
            "zh-Hans": unit("审阅 %lld"),
            "es": unit("Revisar %lld"),
            "uk": unit("Перегляд %lld"),
        },
    }
    strings["Burn %lld · %@"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Burn %lld · %@"),
            "nl": unit("Wissen %lld · %@"),
            "fr": unit("Brûler %lld · %@"),
            "de": unit("Brennen %lld · %@"),
            "it": unit("Brucia %lld · %@"),
            "ja": unit("削除 %lld · %@"),
            "ko": unit("삭제 %lld · %@"),
            "pl": unit("Usuń %lld · %@"),
            "pt-BR": unit("Queimar %lld · %@"),
            "zh-Hans": unit("清除 %lld · %@"),
            "es": unit("Eliminar %lld · %@"),
            "uk": unit("Видалити %lld · %@"),
        },
    }
    strings["Delete %lld photos and videos?"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Delete %lld photos and videos?"),
            "nl": unit("%lld foto’s en video’s verwijderen?"),
            "fr": unit("Supprimer %lld photos et vidéos ?"),
            "de": unit("%lld Fotos und Videos löschen?"),
            "it": unit("Eliminare %lld foto e video?"),
            "ja": unit("写真とビデオを%lld件削除しますか？"),
            "ko": unit("사진과 동영상 %lld개를 삭제할까요?"),
            "pl": unit("Usunąć %lld zdjęć i filmów?"),
            "pt-BR": unit("Excluir %lld fotos e vídeos?"),
            "zh-Hans": unit("删除 %lld 张照片和视频？"),
            "es": unit("¿Borrar %lld fotos y vídeos?"),
            "uk": unit("Видалити %lld фото й відео?"),
        },
    }
    strings["Delete %lld"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Delete %lld"),
            "nl": unit("Verwijder %lld"),
            "fr": unit("Supprimer %lld"),
            "de": unit("%lld löschen"),
            "it": unit("Elimina %lld"),
            "ja": unit("%lld件を削除"),
            "ko": unit("%lld개 삭제"),
            "pl": unit("Usuń %lld"),
            "pt-BR": unit("Apagar %lld"),
            "zh-Hans": unit("删除 %lld"),
            "es": unit("Borrar %lld"),
            "uk": unit("Видалити %lld"),
        },
    }
    strings["No %@ items"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("No %@ items"),
            "nl": unit("Geen %@ items"),
            "fr": unit("Aucun élément %@"),
            "de": unit("Keine %@-Elemente"),
            "it": unit("Nessun elemento %@"),
            "ja": unit("%@の項目はありません"),
            "ko": unit("%@ 항목 없음"),
            "pl": unit("Brak elementów: %@"),
            "pt-BR": unit("Nenhum item %@"),
            "zh-Hans": unit("没有%@项目"),
            "es": unit("No hay elementos %@"),
            "uk": unit("Немає елементів: %@"),
        },
    }
    strings["All %lld"] = {
        "extractionState": "manual",
        "localizations": {locale: unit(f"{label} %lld") for locale, label in [
            ("en", "All"), ("nl", "Alles"), ("fr", "Tout"), ("de", "Alle"),
            ("it", "Tutti"), ("ja", "すべて"), ("ko", "전체"), ("pl", "Wszystkie"),
            ("pt-BR", "Tudo"), ("zh-Hans", "全部"), ("es", "Todos"), ("uk", "Усі"),
        ]},
    }
    strings["Kept %lld"] = {
        "extractionState": "manual",
        "localizations": {locale: unit(f"{label} %lld") for locale, label in [
            ("en", "Kept"), ("nl", "Bewaard"), ("fr", "Gardés"), ("de", "Behalten"),
            ("it", "Tenuti"), ("ja", "残した"), ("ko", "유지됨"), ("pl", "Zachowane"),
            ("pt-BR", "Mantidos"), ("zh-Hans", "已保留"), ("es", "Conservados"), ("uk", "Збережено"),
        ]},
    }
    strings["Burn %lld"] = {
        "extractionState": "manual",
        "localizations": {locale: unit(f"{label} %lld") for locale, label in [
            ("en", "Burn"), ("nl", "Wissen"), ("fr", "Brûler"), ("de", "Brennen"),
            ("it", "Brucia"), ("ja", "削除"), ("ko", "삭제"), ("pl", "Usuń"),
            ("pt-BR", "Queimar"), ("zh-Hans", "清除"), ("es", "Eliminar"), ("uk", "Видалити"),
        ]},
    }
    strings["Camera roll grows by %@ photos"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Camera roll grows by %@ photos"),
            "nl": unit("Camerastream groeit met %@ foto’s"),
            "fr": unit("La pellicule augmente de %@ photos"),
            "de": unit("Die Mediathek wächst um %@ Fotos"),
            "it": unit("Il rullino cresce di %@ foto"),
            "ja": unit("カメラロールが%@枚増えたとき"),
            "ko": unit("카메라 롤이 사진 %@장 늘면"),
            "pl": unit("Rolka urośnie o %@ zdjęć"),
            "pt-BR": unit("O rolo cresce %@ fotos"),
            "zh-Hans": unit("相册增加 %@ 张照片时"),
            "es": unit("El carrete crece %@ fotos"),
            "uk": unit("Стрічка зросте на %@ фото"),
        },
    }
    strings["BurnRoll will schedule a local reminder for %@. The prediction is calculated on-device and BurnRoll never uploads your photos."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("BurnRoll will schedule a local reminder for %@. The prediction is calculated on-device and BurnRoll never uploads your photos."),
            "nl": unit("BurnRoll plant een lokale herinnering voor %@. De voorspelling gebeurt op het apparaat; BurnRoll uploadt je foto’s nooit."),
            "fr": unit("BurnRoll programmera un rappel local pour %@. La prévision est calculée sur l’appareil et BurnRoll n’envoie jamais tes photos."),
            "de": unit("BurnRoll plant eine lokale Erinnerung für %@. Die Prognose entsteht auf dem Gerät; Fotos werden nicht hochgeladen."),
            "it": unit("BurnRoll programmerà un promemoria locale per %@. La previsione è calcolata sul dispositivo e BurnRoll non carica mai le foto."),
            "ja": unit("BurnRollは%@のローカルリマインダーを予約します。予測はこの端末で行われ、写真はアップロードされません。"),
            "ko": unit("BurnRoll이 %@에 대한 로컬 알림을 예약합니다. 예측은 기기에서 계산되며 사진은 업로드되지 않습니다."),
            "pl": unit("BurnRoll zaplanuje lokalne przypomnienie dla %@. Prognoza jest liczona na urządzeniu; zdjęcia nie są wysyłane."),
            "pt-BR": unit("O BurnRoll agendará um lembrete local para %@. A previsão é calculada no dispositivo e suas fotos nunca são enviadas."),
            "zh-Hans": unit("BurnRoll 将为%@安排本地提醒。预测在设备上计算，绝不会上传照片。"),
            "es": unit("BurnRoll programará un recordatorio local para %@. La predicción se calcula en el dispositivo y nunca sube tus fotos."),
            "uk": unit("BurnRoll запланує локальне нагадування для %@. Прогноз рахується на пристрої, фото не завантажуються."),
        },
    }
    strings["From %@ items moved to Recently Deleted"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("From %@ items moved to Recently Deleted"),
            "nl": unit("Van %@ items verplaatst naar Recent verwijderd"),
            "fr": unit("Depuis %@ éléments déplacés vers Récemment supprimés"),
            "de": unit("Von %@ Elementen nach Zuletzt gelöscht verschoben"),
            "it": unit("Da %@ elementi spostati in Eliminati di recente"),
            "ja": unit("%@件を「最近削除した項目」へ移動"),
            "ko": unit("%@개 항목을 최근 삭제된 항목으로 이동"),
            "pl": unit("Z %@ elementów przeniesionych do Ostatnio usuniętych"),
            "pt-BR": unit("De %@ itens movidos para Apagados recentemente"),
            "zh-Hans": unit("来自移至“最近删除”的 %@ 项"),
            "es": unit("De %@ elementos movidos a Eliminados hace poco"),
            "uk": unit("З %@ елементів, переміщених у «Нещодавно видалені»"),
        },
    }
    strings["Media source, %@, %@"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Media source, %@, %@"),
            "nl": unit("Mediabron, %@, %@"),
            "fr": unit("Source média, %@, %@"),
            "de": unit("Medienquelle, %@, %@"),
            "it": unit("Origine media, %@, %@"),
            "ja": unit("メディアソース、%@、%@"),
            "ko": unit("미디어 소스, %@, %@"),
            "pl": unit("Źródło multimediów, %@, %@"),
            "pt-BR": unit("Origem de mídia, %@, %@"),
            "zh-Hans": unit("媒体来源，%@，%@"),
            "es": unit("Origen de contenido, %@, %@"),
            "uk": unit("Джерело медіа, %@, %@"),
        },
    }
    strings["%@ app icon"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("%@ app icon"),
            "nl": unit("%@-app-icoon"),
            "fr": unit("Icône %@"),
            "de": unit("%@-App-Symbol"),
            "it": unit("Icona %@"),
            "ja": unit("%@のアプリアイコン"),
            "ko": unit("%@ 앱 아이콘"),
            "pl": unit("Ikona %@"),
            "pt-BR": unit("Ícone %@"),
            "zh-Hans": unit("%@ 图标"),
            "es": unit("Icono %@"),
            "uk": unit("Іконка %@"),
        },
    }
    strings["BurnRoll %@"] = {
        "extractionState": "manual",
        "localizations": {
            locale: unit("BurnRoll %@")
            for locale in ["en"] + LOCALES
        },
    }
    strings["%@, %@, approximately %@"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("%@, %@, approximately %@"),
            "nl": unit("%@, %@, ongeveer %@"),
            "fr": unit("%@, %@, environ %@"),
            "de": unit("%@, %@, etwa %@"),
            "it": unit("%@, %@, circa %@"),
            "ja": unit("%@、%@、約%@"),
            "ko": unit("%@, %@, 약 %@"),
            "pl": unit("%@, %@, ok. %@"),
            "pt-BR": unit("%@, %@, cerca de %@"),
            "zh-Hans": unit("%@，%@，约 %@"),
            "es": unit("%@, %@, aproximadamente %@"),
            "uk": unit("%@, %@, приблизно %@"),
        },
    }
    strings["Review history, %lld decisions"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Review history, %lld decisions"),
            "nl": unit("Beoordelingsgeschiedenis, %lld keuzes"),
            "fr": unit("Historique de revue, %lld décisions"),
            "de": unit("Prüfverlauf, %lld Entscheidungen"),
            "it": unit("Cronologia revisioni, %lld decisioni"),
            "ja": unit("確認履歴、%lld件"),
            "ko": unit("검토 기록, 결정 %lld개"),
            "pl": unit("Historia przeglądu, %lld decyzji"),
            "pt-BR": unit("Histórico de revisão, %lld decisões"),
            "zh-Hans": unit("审阅记录，%lld 项决定"),
            "es": unit("Historial de revisión, %lld decisiones"),
            "uk": unit("Історія перегляду, %lld рішень"),
        },
    }
    strings["Library progress, %lld total, %lld processed, %lld remaining"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Library progress, %lld total, %lld processed, %lld remaining"),
            "nl": unit("Voortgang bibliotheek, %lld totaal, %lld verwerkt, %lld resterend"),
            "fr": unit("Progression, %lld au total, %lld traités, %lld restants"),
            "de": unit("Mediathek-Fortschritt, %lld insgesamt, %lld erledigt, %lld übrig"),
            "it": unit("Avanzamento libreria, %lld totali, %lld elaborati, %lld rimanenti"),
            "ja": unit("ライブラリの進捗、合計%lld、処理済み%lld、残り%lld"),
            "ko": unit("보관함 진행, 전체 %lld, 완료 %lld, 남음 %lld"),
            "pl": unit("Postęp biblioteki, %lld łącznie, %lld przejrzane, %lld pozostało"),
            "pt-BR": unit("Progresso da biblioteca, %lld no total, %lld processados, %lld restantes"),
            "zh-Hans": unit("资料库进度，共 %lld，已处理 %lld，剩余 %lld"),
            "es": unit("Progreso de la fototeca, %lld en total, %lld procesados, %lld restantes"),
            "uk": unit("Прогрес бібліотеки, усього %lld, опрацьовано %lld, залишилось %lld"),
        },
    }
    strings["Last cleanup selected approximately %@ from %lld items"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Last cleanup selected approximately %@ from %lld items"),
            "nl": unit("Laatste opruiming selecteerde ongeveer %@ uit %lld items"),
            "fr": unit("Dernier nettoyage : environ %@ pour %lld éléments"),
            "de": unit("Letzte Bereinigung: etwa %@ aus %lld Elementen"),
            "it": unit("Ultima pulizia: circa %@ da %lld elementi"),
            "ja": unit("前回の整理で%lld件から約%@を選択"),
            "ko": unit("최근 정리에서 항목 %lld개의 약 %@을 선택함"),
            "pl": unit("Ostatnie czyszczenie wybrało ok. %@ z %lld elementów"),
            "pt-BR": unit("Última limpeza selecionou cerca de %@ de %lld itens"),
            "zh-Hans": unit("上次清理从 %lld 项中选出约 %@"),
            "es": unit("La última limpieza seleccionó unos %@ de %lld elementos"),
            "uk": unit("Останнє очищення вибрало приблизно %@ з %lld елементів"),
        },
    }
    strings["Recent decisions, %lld shown"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Recent decisions, %lld shown"),
            "nl": unit("Recente keuzes, %lld getoond"),
            "fr": unit("Décisions récentes, %lld affichées"),
            "de": unit("Letzte Entscheidungen, %lld angezeigt"),
            "it": unit("Decisioni recenti, %lld visibili"),
            "ja": unit("最近の判断、%lld件表示"),
            "ko": unit("최근 결정 %lld개 표시"),
            "pl": unit("Ostatnie decyzje, pokazano %lld"),
            "pt-BR": unit("Decisões recentes, %lld exibidas"),
            "zh-Hans": unit("最近决定，显示 %lld 项"),
            "es": unit("Decisiones recientes, %lld visibles"),
            "uk": unit("Недавні рішення, показано %lld"),
        },
    }
    strings["Estimated recoverable space, approximately %@ from %lld items"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Estimated recoverable space, approximately %@ from %lld items"),
            "nl": unit("Geschatte terug te winnen ruimte, ongeveer %@ uit %lld items"),
            "fr": unit("Espace récupérable estimé, environ %@ pour %lld éléments"),
            "de": unit("Geschätzter freier Speicher, etwa %@ aus %lld Elementen"),
            "it": unit("Spazio recuperabile stimato, circa %@ da %lld elementi"),
            "ja": unit("回復見込みの容量、%lld件から約%@"),
            "ko": unit("예상 확보 공간, 항목 %lld개의 약 %@"),
            "pl": unit("Szacowane miejsce do odzyskania, ok. %@ z %lld elementów"),
            "pt-BR": unit("Espaço recuperável estimado, cerca de %@ de %lld itens"),
            "zh-Hans": unit("预计可回收空间，约 %@，来自 %lld 项"),
            "es": unit("Espacio recuperable estimado, unos %@ de %lld elementos"),
            "uk": unit("Орієнтовний простір для звільнення, приблизно %@ з %lld елементів"),
        },
    }
    strings["Library checkpoint. %lld total items, %lld reviewed, %lld not reviewed, %lld percent complete."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Library checkpoint. %lld total items, %lld reviewed, %lld not reviewed, %lld percent complete."),
            "nl": unit("Bibliotheek-checkpoint. %lld items totaal, %lld bekeken, %lld niet bekeken, %lld procent klaar."),
            "fr": unit("Point de contrôle. %lld éléments au total, %lld déjà vus, %lld non vus, %lld pour cent."),
            "de": unit("Mediathek-Checkpoint. %lld Elemente insgesamt, %lld geprüft, %lld ungesehen, %lld Prozent fertig."),
            "it": unit("Punto di controllo. %lld elementi in totale, %lld già visti, %lld da vedere, %lld percento."),
            "ja": unit("ライブラリのしおり。合計%lld件、確認済み%lld、未確認%lld、%lldパーセント完了。"),
            "ko": unit("보관함 체크포인트. 전체 %lld개, 검토됨 %lld, 미검토 %lld, %lld퍼센트 완료."),
            "pl": unit("Punkt kontrolny biblioteki. %lld elementów, %lld przejrzane, %lld nieprzejrzane, ukończono %lld procent."),
            "pt-BR": unit("Ponto da biblioteca. %lld itens no total, %lld revisados, %lld não revisados, %lld por cento."),
            "zh-Hans": unit("资料库检查点。共 %lld 项，已审阅 %lld，未审阅 %lld，完成 %lld%。"),
            "es": unit("Punto de la fototeca. %lld elementos, %lld revisados, %lld sin revisar, %lld por ciento."),
            "uk": unit("Контрольна точка бібліотеки. Усього %lld, переглянуто %lld, не переглянуто %lld, %lld відсотка."),
        },
    }
    strings["Last cleanup: %lld items burned, approximately %@ potentially recoverable"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("Last cleanup: %lld items burned, approximately %@ potentially recoverable"),
            "nl": unit("Laatste opruiming: %lld items gewist, ongeveer %@ mogelijk terug te winnen"),
            "fr": unit("Dernier nettoyage : %lld éléments brûlés, environ %@ potentiellement récupérable"),
            "de": unit("Letzte Bereinigung: %lld Elemente gebrannt, etwa %@ potenziell frei"),
            "it": unit("Ultima pulizia: %lld elementi bruciati, circa %@ potenzialmente recuperabile"),
            "ja": unit("前回の整理：%lld件を削除、約%@を回復できる見込み"),
            "ko": unit("최근 정리: %lld개 삭제, 약 %@ 확보 가능"),
            "pl": unit("Ostatnie czyszczenie: usunięto %lld elementów, ok. %@ do odzyskania"),
            "pt-BR": unit("Última limpeza: %lld itens queimados, cerca de %@ potencialmente recuperável"),
            "zh-Hans": unit("上次清理：已清除 %lld 项，预计可回收约 %@"),
            "es": unit("Última limpieza: %lld elementos eliminados, unos %@ potencialmente recuperables"),
            "uk": unit("Останнє очищення: видалено %lld елементів, орієнтовно %@ можна повернути"),
        },
    }
    strings["%lld reviewed, %lld kept, %lld marked to burn"] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("%lld reviewed, %lld kept, %lld marked to burn"),
            "nl": unit("%lld bekeken, %lld bewaard, %lld gemarkeerd om te wissen"),
            "fr": unit("%lld déjà vus, %lld gardés, %lld à brûler"),
            "de": unit("%lld geprüft, %lld behalten, %lld zum Brennen markiert"),
            "it": unit("%lld già visti, %lld tenuti, %lld da bruciare"),
            "ja": unit("確認%lld、残す%lld、削除予定%lld"),
            "ko": unit("검토 %lld, 유지 %lld, 삭제 예정 %lld"),
            "pl": unit("%lld przejrzane, %lld zachowane, %lld do usunięcia"),
            "pt-BR": unit("%lld revisados, %lld mantidos, %lld marcados para queimar"),
            "zh-Hans": unit("已审阅 %lld，已保留 %lld，待清除 %lld"),
            "es": unit("%lld revisados, %lld conservados, %lld marcados para eliminar"),
            "uk": unit("переглянуто %lld, збережено %lld, позначено до видалення %lld"),
        },
    }
    strings["%lld earlier item is included in space recovered but predates photo/video tracking."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("%lld earlier item is included in space recovered but predates photo/video tracking."),
            "nl": unit("%lld eerder item zit in de teruggewonnen ruimte, maar was er vóór foto-/videotracking."),
            "fr": unit("%lld élément plus ancien est inclus dans l’espace récupéré, avant le suivi photo/vidéo."),
            "de": unit("%lld früheres Element steckt im freigegebenen Speicher, stammt aber von vor der Foto-/Video-Zählung."),
            "it": unit("%lld elemento precedente è incluso nello spazio recuperato, ma è anteriore al conteggio foto/video."),
            "ja": unit("以前の%lld件は確保容量に含まれますが、写真/ビデオの内訳より前です。"),
            "ko": unit("이전 항목 %lld개가 확보 공간에 포함되지만 사진/동영상 집계 이전입니다."),
            "pl": unit("%lld wcześniejszy element jest w odzyskanym miejscu, ale sprzed śledzenia zdjęć/filmów."),
            "pt-BR": unit("%lld item anterior entra no espaço recuperado, mas é de antes do rastreio de foto/vídeo."),
            "zh-Hans": unit("另有 %lld 项计入已回收空间，但早于照片/视频分类统计。"),
            "es": unit("%lld elemento anterior está en el espacio recuperado, pero es de antes del recuento de foto/vídeo."),
            "uk": unit("%lld раніший елемент входить у звільнений простір, але був до обліку фото/відео."),
        },
    }
    strings["%lld earlier items are included in space recovered but predate photo/video tracking."] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit("%lld earlier items are included in space recovered but predate photo/video tracking."),
            "nl": unit("%lld eerdere items zitten in de teruggewonnen ruimte, maar waren er vóór foto-/videotracking."),
            "fr": unit("%lld éléments plus anciens sont inclus dans l’espace récupéré, avant le suivi photo/vidéo."),
            "de": unit("%lld frühere Elemente stecken im freigegebenen Speicher, stammen aber von vor der Foto-/Video-Zählung."),
            "it": unit("%lld elementi precedenti sono inclusi nello spazio recuperato, ma sono anteriori al conteggio foto/video."),
            "ja": unit("以前の%lld件は確保容量に含まれますが、写真/ビデオの内訳より前です。"),
            "ko": unit("이전 항목 %lld개가 확보 공간에 포함되지만 사진/동영상 집계 이전입니다."),
            "pl": unit("%lld wcześniejszych elementów jest w odzyskanym miejscu, ale sprzed śledzenia zdjęć/filmów."),
            "pt-BR": unit("%lld itens anteriores entram no espaço recuperado, mas são de antes do rastreio de foto/vídeo."),
            "zh-Hans": unit("另有 %lld 项计入已回收空间，但早于照片/视频分类统计。"),
            "es": unit("%lld elementos anteriores están en el espacio recuperado, pero son de antes del recuento de foto/vídeo."),
            "uk": unit("%lld раніших елементів входять у звільнений простір, але були до обліку фото/відео."),
        },
    }
    strings["Keep photo"] = {
        "extractionState": "manual",
        "localizations": {
            locale: unit(value) for locale, value in zip(
                ["en"] + LOCALES,
                ["Keep photo", "Foto bewaren", "Garder la photo", "Foto behalten", "Tieni la foto", "写真を残す", "사진 유지", "Zachowaj zdjęcie", "Manter foto", "保留照片", "Conservar foto", "Зберегти фото"],
            )
        },
    }
    strings["Burn photo"] = {
        "extractionState": "manual",
        "localizations": {
            locale: unit(value) for locale, value in zip(
                ["en"] + LOCALES,
                ["Burn photo", "Foto wissen", "Brûler la photo", "Foto brennen", "Brucia la foto", "写真を削除", "사진 삭제", "Usuń zdjęcie", "Queimar foto", "清除照片", "Eliminar foto", "Видалити фото"],
            )
        },
    }

    return {"sourceLanguage": "en", "strings": strings, "version": "1.1"}


def build_infoplist() -> dict:
    loc = {"en": unit(USAGE[0])}
    for locale, value in zip(LOCALES, USAGE[1:]):
        loc[locale] = unit(value)
    return {
        "sourceLanguage": "en",
        "strings": {
            "NSPhotoLibraryUsageDescription": {
                "extractionState": "manual",
                "localizations": loc,
            }
        },
        "version": "1.1",
    }


def main() -> None:
    catalog = build_catalog()
    info = build_infoplist()
    out_dir = ROOT / "BurnRoll"
    (out_dir / "Localizable.xcstrings").write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    (out_dir / "InfoPlist.xcstrings").write_text(
        json.dumps(info, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(catalog['strings'])} keys to Localizable.xcstrings")


if __name__ == "__main__":
    main()
