-- Tests/logik-test.lua - prueft die Logik ohne laufendes WoW
--
-- ===========================================================================
-- Aufruf:   ../tools/test.sh
--
-- Schwerpunkt liegt auf zwei Stellen, die im Spiel muehsam zu pruefen sind:
-- dem Modulsystem (wer wird angekoppelt, und was passiert mit einem Modul,
-- das wirft) und dem JSON-Schreiber. Letzterer ist selbst geschriebener Code
-- mit echten Fallstricken - Maskierung, Liste gegen Objekt, stabile
-- Reihenfolge -, und genau dort faellt ein Fehler sonst erst auf, wenn ein
-- Server die Ausfuhr nicht lesen kann.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- WoW nachbauen
-- ---------------------------------------------------------------------------
local ereignisse = {}

_G.UIParent = {}
_G.ChatFontNormal = {}

function _G.CreateFrame()
    local f = {}
    f.RegisterEvent = function(_, e) ereignisse[e] = true end
    f.SetScript = function(self, was, fn) self["_" .. was] = fn end
    f.SetSize = function() end
    f.SetPoint = function() end
    f.ClearAllPoints = function() end
    f.SetMovable = function() end
    f.EnableMouse = function() end
    f.RegisterForDrag = function() end
    f.SetFrameStrata = function() end
    f.SetMultiLine = function() end
    f.SetFontObject = function() end
    f.SetWidth = function() end
    f.SetAutoFocus = function() end
    f.SetScrollChild = function() end
    f.HighlightText = function() end
    f.SetFocus = function() end
    f.SetText = function(self, t) self.text = t end
    f.CreateFontString = function()
        return { SetPoint = function() end, SetJustifyH = function() end,
                 SetJustifyV = function() end, SetText = function() end }
    end
    f.Hide = function(self) self.gezeigt = false end
    f.Show = function(self) self.gezeigt = true end
    f.IsShown = function(self) return self.gezeigt end
    f.GetPoint = function() return "CENTER", nil, "CENTER", 0, 0 end
    f.StartMoving = function() end
    f.StopMovingOrSizing = function() end
    f.TitleText = { SetText = function() end }
    return f
end

_G.GetTime = os.clock
_G.time = os.time
_G.date = os.date
_G.strtrim = function(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end
-- strsplit muss GENAU nachgebaut werden: WoW liefert bei "a::c" drei Werte,
-- davon einen leeren. Ein gmatch mit "*" gibt dagegen zusaetzliche
-- Leertreffer zurueck und verschiebt damit alle Feldnummern - im Itemlink
-- steht die Verzauberung dann nicht mehr an Stelle 3, und der Test wuerde
-- einen Fehler melden, den der Code gar nicht hat.
_G.strsplit = function(trenner, s)
    s = tostring(s)
    local teile, start = {}, 1
    while true do
        local pos = string.find(s, trenner, start, true)
        if not pos then
            teile[#teile + 1] = string.sub(s, start)
            break
        end
        teile[#teile + 1] = string.sub(s, start, pos - 1)
        start = pos + 1
    end
    return unpack(teile)
end
_G.GetLocale = function() return "enUS" end
_G.UnitName = function() return "Testchar" end
_G.UnitClass = function() return "Priest", "PRIEST" end
_G.GetRealmName = function() return "Antonidas" end
_G.SlashCmdList = {}
_G.C_Timer = { After = function(_, fn) fn() end }

_G.IsInGuild = function() return true end
_G.GetNumGuildMembers = function() return 2 end
_G.GetGuildRosterInfo = function(i)
    if i == 1 then return "Anfuehrer-Antonidas", "Gildenmeister", 0, 80, nil, nil, nil, nil, true, nil, "PRIEST" end
    return "Zweiter-Antonidas", "Offizier", 1, 80, nil, nil, nil, nil, false, nil, "MAGE"
end

-- Ausruestung: Platz 5 (Brust) OHNE Verzauberung, Platz 8 (Fuesse) MIT.
_G.GetInventoryItemLink = function(_, platz)
    if platz == 5 then return "|Hitem:1000::::::::80:::::|h[Brust]|h" end
    if platz == 8 then return "|Hitem:1001:6210::::::::80:::::|h[Fuesse]|h" end
    if platz <= 12 then return "|Hitem:1002:6210::::::::80:::::|h[Teil]|h" end
    return nil
end

_G.C_WeeklyRewards = {
    GetActivities = function()
        return {
            { type = 1, level = 10, progress = 8, threshold = 8 },
            { type = 1, level = 6,  progress = 3, threshold = 8 },
        }
    end,
}

-- ---------------------------------------------------------------------------
-- Testgeruest
-- ---------------------------------------------------------------------------
local bestanden, gefallen = 0, 0
local function pruefe(bedingung, was)
    if bedingung then
        bestanden = bestanden + 1
        print(("  ok    %s"):format(was))
    else
        gefallen = gefallen + 1
        print(("  FEHLT %s"):format(was))
    end
end

-- ---------------------------------------------------------------------------
-- Kern laden, in der Reihenfolge der .toc
-- ---------------------------------------------------------------------------
local hier = (arg and arg[0] or ""):match("(.*)Tests[/\\]") or "./"
local function lade(pfad)
    local fn, fehler = loadfile(hier .. pfad)
    if not fn then error("kann " .. pfad .. " nicht laden: " .. tostring(fehler)) end
    fn("GuildOps", {})
end

lade("Logik/Kompat.lua")
lade("Locales/enUS.lua")
lade("Locales/deDE.lua")
lade("Logik/Speicher.lua")
lade("Logik/Ausfuhr.lua")
lade("Logik/Modulsystem.lua")
lade("Logik/Diagnose.lua")
lade("UI/Fenster.lua")
lade("Core.lua")

local GO = _G.GuildOps

print("Kern")
pruefe(GO ~= nil, "Namensraum ist global erreichbar")
pruefe(ereignisse["PLAYER_LOGIN"], "PLAYER_LOGIN ist angemeldet")
pruefe(_G.SlashCmdList["GUILDOPS"] ~= nil, "Slash-Befehl ist angemeldet")

print("Gilde")
local roster = GO.Kompat.Roster()
pruefe(roster and #roster == 2, "Roster wird gelesen")
pruefe(roster and roster[1].rang == "Gildenmeister", "Rang kommt mit")
pruefe(roster and roster[2].online == false, "Offline-Zustand kommt mit")

_G.GetNumGuildMembers = function() return 0 end
pruefe(GO.Kompat.Roster() == nil, "noch nicht geliefertes Roster gibt nil, NICHT eine leere Liste")
_G.GetNumGuildMembers = function() return 2 end

print("Ausruestung")
local a = GO.Kompat.EigeneAusruestung()
pruefe(a.stuecke == 12, "getragene Teile werden gezaehlt")
local brustLuecke = false
for _, l in ipairs(a.luecken) do
    if l.platz == 5 and l.was == "verzauberung" then brustLuecke = true end
end
pruefe(brustLuecke, "fehlende Verzauberung auf der Brust wird erkannt")
local fuesseLuecke = false
for _, l in ipairs(a.luecken) do
    if l.platz == 8 then fuesseLuecke = true end
end
pruefe(not fuesseLuecke, "vorhandene Verzauberung wird NICHT als Luecke gemeldet")

print("Schatzkammer")
local kammer = GO.Kompat.Schatzkammer()
pruefe(kammer and #kammer == 2, "Aktivitaeten werden gelesen")
pruefe(kammer and kammer[1].erledigt == true, "erfuellte Stufe gilt als erledigt")
pruefe(kammer and kammer[2].erledigt == false, "unerfuellte Stufe gilt nicht als erledigt")

print("JSON")
local J = GO.Ausfuhr.NachJSON
pruefe(J(nil) == "null", "nil wird null")
pruefe(J(true) == "true", "Wahrheitswert")
pruefe(J(42) == "42", "Zahl")
pruefe(J("hallo") == '"hallo"', "Zeichenkette")
pruefe(J('sagt "hallo"') == '"sagt \\"hallo\\""', "Anfuehrungszeichen werden maskiert")
pruefe(J("a\nb") == '"a\\nb"', "Zeilenumbruch wird maskiert")
pruefe(J("pfad\\weg") == '"pfad\\\\weg"', "Rueckstrich wird maskiert")
pruefe(J({ 1, 2, 3 }) == "[1,2,3]", "Liste wird zu einem JSON-Array")
pruefe(J({}) == "[]", "leere Tabelle wird zum Array")
pruefe(J({ b = 1, a = 2 }) == '{"a":2,"b":1}', "Objekt-Schluessel werden sortiert (stabile Ausfuhr)")
pruefe(J(0 / 0) == "null", "nan wird null, statt kaputtes JSON zu erzeugen")
pruefe(J(math.huge) == "null", "unendlich wird null")
pruefe(J(function() end) == "null", "Funktion landet nicht in der Ausfuhr")

-- Zweimal dasselbe muss zeichengleich sein, sonst kann man Staende nicht
-- vergleichen.
local t = { z = 1, a = 2, m = { 3, 4 } }
pruefe(J(t) == J(t), "dieselbe Tabelle ergibt zweimal denselben Text")

print("Speicher und Ausfuhr")
GO.Speicher.Start()
GO.Module.Pruefen()

local eintrag = GO.Speicher.EigenerAbschnitt()
eintrag.name = "Testchar"
eintrag.ausruestung = a
GO.Speicher.Stempeln(eintrag)

local paket = GO.Ausfuhr.Sammeln()
pruefe(paket ~= nil, "Ausfuhr-Paket wird gebaut")
pruefe(paket.charaktere["Testchar-Antonidas"] ~= nil, "eigener Charakter ist enthalten")

-- Was NICHT mit darf.
GO.Speicher.db.einstellungen.fensterPunkt = { "CENTER", "CENTER", 5, 5 }
local text = GO.Ausfuhr.Text()
pruefe(type(text) == "string" and #text > 0, "Ausfuhr liefert Text")
pruefe(not text:find("fensterPunkt"), "Fensterposition landet NICHT in der Ausfuhr")

-- Ein Modul darf beisteuern.
GO.Module.Registrieren("Beispiel", {
    Pruefen = function() return true end,
    Ausfuhr = function() return { zeilen = 7 } end,
})
GO.Module.Pruefen()
local paket2 = GO.Ausfuhr.Sammeln()
pruefe(paket2.module and paket2.module["Beispiel"], "Modul-Beitrag landet im Paket")
pruefe(paket2.module["Beispiel"].zeilen == 7, "Modul-Beitrag kommt unveraendert an")

print("")
print(("bestanden: %d   gefallen: %d"):format(bestanden, gefallen))
if gefallen > 0 then os.exit(1) end
os.exit(0)
