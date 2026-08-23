# Fahrplan

## Reihenfolge

| # | Schritt | Warum diese Stelle |
|---|---|---|
| 1 | Gem-Frage klären | Entscheidet, ob das Gearsprüfung vollständig sein kann. |
| 2 | Buffood/Flasks | Klein, sofort sichtbar. |
| 3 | Bereitschaftsübersicht als Tabelle | Erst wenn genug Zeilen zusammenkommen. |
| 4 | Modul Attendance | Klein, und liefert der Gildenseite sofort etwas. |
| 5 | Endpunkt auf der Gildenseite | Arbeit **außerhalb** dieses Repos. |
| 6 | Modul LootAudit | |
| 7 | Modul ChannelSync | Zuletzt — siehe `02-Module.md`. |

## Offene Fragen

1. **Gem-Plätze.** Tooltip auslesen oder gepflegte Liste? Ohne Antwort
   meldet die Prüfung Lücken, die keine sind.
2. **Endpunkt.** Soll die Gildenseite die JSON-Ausfuhr entgegennehmen, und
   wer darf sie einspielen? Das ist eine Frage an die Web-App
   (`intern.happy-accident-wow.de`), nicht an das Addon.
3. **Verhältnis zur WarcraftLogs-Anwesenheit.** Zwei Quellen für dieselbe
   Frage sind eine Quelle zu viel, wenn niemand festlegt, welche gewinnt.
   **Vor Schritt 4 entscheiden.**

## Was heute steht

Kern lädt, Roster wird gelesen, Gear wird geprüft, Great Vault wird
gelesen, JSON-Ausfuhr funktioniert und ist getestet. Drei Modul-Gerüste
melden sich an. **33 Logiktests, alle grün.**
