# Architektur

## Aufbau

```
GuildOps/                Kern  – Audit, Speicher, JSON-Ausfuhr, Modulsystem
GuildOps_Attendance/     Modul – Anwesenheit
GuildOps_LootAudit/      Modul – Item-Verteilung
GuildOps_ChannelSync/    Modul – Abgleich zwischen Installationen
```

Jedes Modul trägt `## Dependencies: GuildOps`. Wirkung: Ohne Kern lädt das
Modul nicht (und WoW sagt, warum), und WoW lädt den Kern zuerst — darauf
verlässt sich das Modulsystem.

Der Kern kennt **kein Modul namentlich**. Er ruft Haken auf:
`Pruefen`, `Start`, `Aktualisieren`, `Kennzahl`, `Ausfuhr`.

Details zum Modulsystem und zum globalen Namensraum stehen in
`Logik/Modulsystem.lua` und `Logik/Kompat.lua` — dort, wo sie beim
Programmieren gebraucht werden.

## Die Ausfuhr ist der eigentliche Zweck

Dieses Addon endet **nicht** im Spiel. Was hier erhoben wird, soll in ein
Web-Dashboard oder zu einem Discord-Bot. Genau dafür gibt es
`Logik/Ausfuhr.lua`.

**Warum nicht einfach die `SavedVariables` einlesen?** Weil das Lua-Quelltext
ist, den ein Server ausführen müsste — und fremden Lua-Quelltext führt man
nicht aus. Deshalb JSON, aus einem Textfeld heraus kopiert.

**Warum ein eigener JSON-Schreiber?** Eine Bibliothek wäre ein weiteres
Fremdteil im Auslieferpaket. Was gebraucht wird — Zahlen, Zeichenketten,
Listen, Tabellen — sind fünfzig Zeilen. Sie sind getestet: Maskierung,
Liste-gegen-Objekt, `nan`/`inf`, und vor allem **stabile Reihenfolge**
(Schlüssel werden sortiert), damit sich zwei Stände überhaupt vergleichen
lassen.

**Was nicht mit hinausgeht:** Fensterpositionen und Modul-Zwischenstände. Die
Ausfuhr wird zusammengestellt, nicht roh abgekippt. Auch das ist getestet.

Ein Addon kann von sich aus **nichts** ins Netz schicken. Das ist eine Grenze
von WoW und bleibt so — es gibt kein „automatisch hochladen".

## Bezug zur vorhandenen Gildenseite

Auf `intern.happy-accident-wow.de` gibt es bereits Anwesenheit, allerdings
aus WarcraftLogs importiert. Dieses Addon ist **kein Ersatz** dafür, sondern
eine zweite Quelle für das, was WarcraftLogs nicht sieht: Verzauberungen,
Sockel, Schatzkammer-Stand — also Vorbereitung statt Kampfverlauf.

Die JSON-Ausfuhr ist so gebaut, dass ein Endpunkt sie ohne Umformung lesen
kann. Ein solcher Endpunkt existiert **noch nicht**; das wäre Arbeit auf der
Web-Seite, nicht hier.

## Was dieses Addon grundsätzlich nicht kann

- **Fremde Charaktere untersuchen.** `Inspect` geht nur in Reichweite, ist
  asynchron und schlägt oft fehl. Deshalb erhebt **jeder Spieler seinen
  eigenen** Stand — das ist die einzige Angabe, die verlässlich ist. Ohne
  ChannelSync sieht ein Offizier also nur seine eigenen Charaktere.
- **Die Schatzkammer anderer sehen.** Nicht abfragbar. Punkt.
- **Wissen, wer eingeplant war.** Das Spiel kennt keinen Kader. Wer gefehlt
  hat, ergibt sich erst aus dem Abgleich mit einer Liste von außen.

Diese drei Punkte gehören in die README — sonst erwartet jemand ein
Roster-Audit über die ganze Gilde, und das kann es nicht sein.
