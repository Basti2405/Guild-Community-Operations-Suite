# Fachlogik des Kerns

## Was heute steht

- **Guild Roster lesen** (`Kompat.Roster`). Wichtig und getestet: Ein noch
  nicht geliefertes Roster gibt `nil` zurück, **nicht** eine leere Liste.
  `GuildRoster()` stößt den Abruf nur an; die Daten kommen erst mit
  `GUILD_ROSTER_UPDATE`. Wer den Unterschied nicht macht, meldet „Gilde hat
  0 Mitglieder" und schickt den Offizier auf die falsche Fährte.
- **Eigenes Gear prüfen** (`Kompat.EigeneAusruestung`): fehlende
  Enchants auf den verzauberbaren Plätzen, aus dem Itemlink gelesen.
  Getestet gegen Plätze mit und ohne Enchant.
- **Great Vault** (`Kompat.Schatzkammer`): je Aktivität Fortschritt gegen
  Schwelle.
- **Erhebung mit Abstand** (`Core.lua`): Direkt nach dem Login ist die
  Gear noch nicht vollständig geladen; ein fehlender Enchant wäre
  nicht von einem fehlenden Item zu unterscheiden. Deshalb wird erst ab fünf
  getragenen Teilen erhoben — ein leerer Stand darf einen erhobenen nicht
  überschreiben.
- **JSON-Ausfuhr** samt Fenster zum Herauskopieren.
- **33 Logiktests, alle grün.**

## Noch zu bauen

### Gems und Buffood

Gems stehen im Itemlink an den Stellen 4 bis 7. Der Haken: **Wie viele
Gem-Plätze ein Stück überhaupt hat, steht dort nicht.** Ein leeres Feld heißt
nicht „Gem-Platz leer", sondern kann auch „kein Gem-Platz" heißen. Ohne diese
Unterscheidung meldet das Addon Lücken, die keine sind — das wäre schlimmer
als gar keine Prüfung.

Zu klären: Tooltip auslesen oder eine gepflegte Liste der sockelbaren Plätze.
**Vor dem Bau entscheiden.**

Buffood und Flasks sind einfacher: vorhandene Stückzahl im Beutel über
`C_Item.GetItemCount`, gegen eine gepflegte Liste in `Daten/`.

### Bereitschaftsübersicht

Eine Tabelle statt einer Textfläche, sobald mehr als eine Handvoll Zeilen
zusammenkommt. Erst dann ist AceGUI gerechtfertigt.

### Verlauf

Je Woche ein Stand, damit man Entwicklung sieht statt nur den Augenblick.
Dieselbe Vorsicht wie überall: Ein Verlauf über Monate lässt die
gespeicherte Datei wachsen, und die wird bei jedem Ausloggen vollständig
geschrieben. Eine Obergrenze gehört von Anfang an hinein.
