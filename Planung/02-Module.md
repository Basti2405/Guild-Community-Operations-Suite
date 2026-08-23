# Module

## Attendance — Anwesenheit

**Was es ehrlich kann.** Es sieht nur, was der Spieler sieht, der es
installiert hat: wer in **seiner** Gruppe war, als der Bosskampf begann.

**Was es nicht kann.** Wer an dem Abend gar nicht online kam, taucht **nicht**
als abwesend auf — dazu müsste man wissen, wer eingeplant war, und das weiß
das Spiel nicht. Die vollständige Antwort auf „wer hat gefehlt" entsteht erst
im Abgleich mit einem gepflegten Kader außerhalb des Spiels.

Dieses Modul liefert also **eine Hälfte** — wer da war —, und zwar so, dass
sie sich ausführen lässt (`Ausfuhr`-Haken, bereits angelegt).

**Datenquelle.** `ENCOUNTER_START` / `ENCOUNTER_END` plus Gruppenliste.

**Bewusst nicht enthalten:** eine Bewertung. Ob jemand „unzuverlässig" ist,
entscheidet kein Addon. Ausgegeben werden Rohdaten.

**Aufwand:** klein.

---

## LootAudit — Item-Verteilung

**Zweck.** Dokumentation, was wohin ging — zum Nachlesen, nicht zum Bewerten.

**Datenquelle.** `CHAT_MSG_LOOT` und die Beute-Ereignisse des
Gruppenverteilungssystems.

**Fallstricke:**

- `CHAT_MSG_LOOT` ist **Text**, kein Datensatz. Er ist sprachabhängig und
  ändert sich zwischen Erweiterungen. Wer darauf ein Auswertungssystem baut,
  baut auf Sand — die Itemlinks daraus zu ziehen ist verlässlich, alles
  andere nicht.
- Persönliche Beute sieht man nur bei sich selbst.

**Aufwand:** klein, wenn man sich auf Itemlinks beschränkt. Mittel, sobald
man Set-Vervollständigung nachhalten will (dafür braucht es eine Vorstellung
davon, was ein „Set" ist — die kommt nicht aus dem Spiel).

---

## ChannelSync — Abgleich zwischen Installationen

Das heikelste der drei. Vier Punkte, die **nicht** verhandelbar sind und
deshalb auch im Quelltext stehen:

1. **Ein Addon-Kanal ist kein privater Kanal.** Alles, was darüber geht, kann
   jeder mitlesen, der ein Addon schreibt. „Verdeckt" heißt nur: nicht im
   Chatfenster. Deshalb gehen ausschließlich Daten hinaus, die ohnehin jeder
   in der Gilde sehen kann.
2. **Verschlüsselung löst das nicht.** Der Schlüssel müsste bei allen liegen,
   die mitlesen dürfen — also auch bei dem, der ihn weitergibt.
3. **Addon-Nachrichten sind gedrosselt.** Wer bei jedem Login das ganze
   Roster verschickt, lässt die Verbindung der ganzen Gruppe stocken. Der
   Abgleich ist als **Unterschied** zu bauen, nicht als Vollbild.
4. **Praefixe sind begrenzt.** `RegisterAddonMessagePrefix` kann fehlschlagen,
   wenn der Client seine Obergrenze erreicht hat. Das ist kein Fehler dieses
   Addons — aber ein Grund, still zu sein. Bereits so gebaut.

**Aufwand:** mittel bis groß — nicht wegen des Versendens, sondern wegen
Drosselung, Stückelung und der Frage, welcher Stand gewinnt, wenn zwei
Installationen sich widersprechen.

**Empfehlung:** zuletzt bauen. Die anderen beiden Module sind ohne ihn
nutzbar; er ist ohne sie sinnlos.
