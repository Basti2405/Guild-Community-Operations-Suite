-- Core.lua - startet alles auf und nimmt die Befehle entgegen
--
-- ===========================================================================
-- Laedt als LETZTE Datei des Kerns (siehe .toc).
--
-- Reihenfolge beim Login:
--   1. Speicher aufziehen     - vorher darf niemand hineinschreiben
--   2. Module pruefen         - erst jetzt steht fest, wer mitspielt
--   3. Modul-Start rufen
--   4. eigenen Stand erheben  - mit Abstand, siehe unten
-- ===========================================================================
local GO = _G.GuildOps
local K = GO.Kompat
local M = GO.Module

-- ---------------------------------------------------------------------------
-- Den eigenen Stand erheben
-- ---------------------------------------------------------------------------
-- Direkt nach dem Login ist die Ausruestung des eigenen Charakters noch nicht
-- vollstaendig geladen: GetInventoryItemLink liefert dann teils nichts, und
-- eine fehlende Verzauberung waere nicht von einem fehlenden Item zu
-- unterscheiden. Wir wuerden also Luecken melden, die keine sind. Deshalb mit
-- Abstand, und nur wenn wirklich Ausruestung zu sehen ist.
local function erheben()
    local eintrag = GO.Speicher.EigenerAbschnitt()
    if not eintrag then return end

    local ausruestung = K.EigeneAusruestung()
    if ausruestung.stuecke < 5 then
        -- So wenig getragene Teile heisst: noch nicht geladen. Ein leerer
        -- Stand darf einen erhobenen nicht ueberschreiben.
        return
    end

    eintrag.name   = UnitName("player")
    eintrag.klasse = select(2, UnitClass("player"))
    eintrag.ausruestung = ausruestung

    local kammer = K.Schatzkammer()
    if kammer then eintrag.schatzkammer = kammer end

    GO.Speicher.Stempeln(eintrag)
    M.Rufen("Aktualisieren")
end

-- ---------------------------------------------------------------------------
-- Login
-- ---------------------------------------------------------------------------
K.Horchen("PLAYER_LOGIN", function()
    GO.Speicher.Start()
    M.Pruefen()
    M.Rufen("Start")

    K.Spaeter(5, erheben)

    -- Das Roster nur anfordern - die Daten kommen mit GUILD_ROSTER_UPDATE.
    if K.InGilde() then K.RosterAnfordern() end
end)

-- Ausruestung gewechselt oder Schatzkammer aktualisiert: neu erheben.
K.Horchen("PLAYER_EQUIPMENT_CHANGED", function() K.Spaeter(1, erheben) end)
K.Horchen("WEEKLY_REWARDS_UPDATE", function() K.Spaeter(1, erheben) end)

-- ---------------------------------------------------------------------------
-- Befehle
-- ---------------------------------------------------------------------------
local function befehl(eingabe)
    local wort = strtrim((eingabe or ""):lower())

    if wort == "" then
        GO.UI.Umschalten()
    elseif wort == "doctor" then
        GO.Diagnose.Bericht()
    elseif wort == "export" or wort == "ausfuhr" then
        GO.UI.Ausfuhr()
    elseif wort == "help" or wort == "hilfe" then
        print("|cff40c0f0[GO]|r " .. GO.L["SLASH_HINT"])
    else
        -- Unbekanntes Wort koennte einem Modul gehoeren.
        local behandelt = false
        for _, modul in ipairs(M.Aktive()) do
            if M.RufenAuf(modul, "Befehl", wort) then
                behandelt = true
                break
            end
        end
        if not behandelt then
            print("|cff40c0f0[GO]|r " .. GO.L["SLASH_HINT"])
        end
    end
end

SLASH_GUILDOPS1 = "/gops"
SLASH_GUILDOPS2 = "/guildops"
SlashCmdList["GUILDOPS"] = befehl
