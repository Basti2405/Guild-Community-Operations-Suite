-- Locales/deDE.lua - Deutsch
--
-- Ueberschreibt nur einzelne Schluessel. Was hier fehlt, kommt aus enUS.
if GetLocale() ~= "deDE" then return end

local GO = _G.GuildOps
local L = GO.L

L["SLASH_HINT"]        = "/gops oeffnet das Fenster, /gops export gibt die Daten heraus, /gops doctor prueft sich selbst."

L["NO_DATA"]           = "Noch nichts erfasst. Melde dich mit jedem Charakter einmal an."
L["CHARACTERS_KNOWN"]  = "Bekannte Charaktere: %d"
L["LAST_SEEN"]         = "zuletzt gesehen %s"

L["GAPS_NONE"]         = "keine Luecken gefunden"
L["GAPS_SOME"]         = "%d Luecken"
L["VAULT_PROGRESS"]    = "Grosse Schatzkammer: %d von %d Plaetzen frei"

L["EXPORT_TITLE"]      = "Diesen Text kopieren (Strg+A, Strg+C)"
L["EXPORT_EMPTY"]      = "Es gibt noch nichts auszufuehren."

L["DOCTOR_TITLE"]      = "Guild Ops - Selbstdiagnose"
L["DOCTOR_STORAGE_OK"] = "Speicher: bereit (%d Charaktere)."
L["DOCTOR_STORAGE_NO"] = "Speicher: NICHT bereit - die gespeicherten Variablen wurden nicht geladen."
L["DOCTOR_GUILD_NO"]   = "Gilde: dieser Charakter ist in keiner Gilde."
L["DOCTOR_GUILD_OK"]   = "Gildenroster: %d Mitglieder."
L["DOCTOR_GUILD_WAIT"] = "Gildenroster: noch nicht geliefert - gleich noch einmal versuchen."
L["DOCTOR_NO_MODULES"] = "Module: keines installiert."
L["DOCTOR_MODULE_ON"]  = "Modul %s: aktiv."
L["DOCTOR_MODULE_OFF"] = "Modul %s: nicht aktiv (%s)."
L["DOCTOR_NO_REASON"]  = "ohne Angabe"
