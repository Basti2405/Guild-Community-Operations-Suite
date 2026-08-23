# Gilden- & Community-Operations Suite

**Roster- und Bereitschafts-Audit für Gilden — und eine Ausfuhr, die ein
Server auch lesen kann.**

*[English version](README.en.md)*

> Der Kern heißt im AddOns-Verzeichnis **GuildOps**, der Slash-Befehl ist
> `/gops`.

## Stand: Gerüst mit tragendem Kern

**Noch kein fertiges Addon**, aber mehr als eine Skizze: Roster lesen,
Gear prüfen, Great Vault lesen und die JSON-Ausfuhr **funktionieren
und sind getestet** (33 Logiktests, alle grün). Details in
[`Planung/`](Planung/).

## Aufbau

```
GuildOps/                Kern
GuildOps_Attendance/     Modul – Anwesenheit
GuildOps_LootAudit/      Modul – Item-Verteilung
GuildOps_ChannelSync/    Modul – Abgleich zwischen Installationen
```

Jedes Modul trägt `## Dependencies: GuildOps` und ist einzeln abwählbar.

## Die Ausfuhr

Der eigentliche Zweck: Was hier erhoben wird, soll in ein Web-Dashboard oder
zu einem Discord-Bot.

`/gops export` öffnet ein Textfeld mit **JSON** zum Herauskopieren. Nicht die
`SavedVariables` — das ist Lua-Quelltext, den ein Server ausführen müsste,
und fremden Lua-Quelltext führt man nicht aus.

Die Ausfuhr ist **zusammengestellt**, nicht roh abgekippt: Fensterpositionen
und Zwischenstände bleiben draußen. Die Schlüssel sind sortiert, damit sich
zwei Stände vergleichen lassen. Beides ist getestet.

Ein Addon kann von sich aus **nichts** ins Netz schicken. Das ist eine Grenze
von WoW, kein fehlendes Feature.

## Befehle

| Befehl | Wirkung |
|---|---|
| `/gops` | Fenster anzeigen oder verstecken |
| `/gops export` | Daten als JSON zum Kopieren |
| `/gops doctor` | Selbstdiagnose – bei Problemen zuerst |

## Was es *nicht* kann

- **Fremde Charaktere untersuchen.** `Inspect` geht nur in Reichweite, ist
  asynchron und schlägt oft fehl. Deshalb erhebt **jeder Spieler seinen
  eigenen** Stand. Ohne das Sync-Modul sieht ein Offizier nur seine eigenen
  Charaktere — nicht die halbe Gilde.
- **Den Great Vault anderer sehen.** Nicht abfragbar.
- **Wissen, wer eingeplant war.** Das Spiel kennt keinen Kader. Wer gefehlt
  hat, ergibt sich erst im Abgleich mit einer Liste von außen.
- **Gems prüfen** — noch nicht. Der Itemlink verrät nicht, wie viele
  Gem-Plätze ein Stück überhaupt hat; ein leeres Feld heißt nicht
  zwingend „Gem fehlt". Lieber keine Prüfung als eine, die Lücken
  meldet, die keine sind.

## Entwickeln

```bash
tools/junction.cmd
./tools/test.sh
```

## Lizenz

MIT, siehe [LICENSE](LICENSE).
