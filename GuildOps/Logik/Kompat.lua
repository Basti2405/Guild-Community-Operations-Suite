-- Logik/Kompat.lua - Bruecke zu den Schnittstellen des Spiels
--
-- ===========================================================================
-- WOZU DIESE DATEI
-- ---------------------------------------------------------------------------
-- Blizzard benennt Funktionen um und verschiebt sie in C_-Tabellen. Steht der
-- Zugriff an EINER Stelle, ist ein Patch eine Aenderung hier statt einer
-- Suche durch das ganze Addon.
--
-- DER NAMENSRAUM
-- ---------------------------------------------------------------------------
-- Diese Datei laedt als erste und legt den Namensraum GLOBAL an. Das ist
-- keine Bequemlichkeit: Die Module sind eigene Addons mit eigenem Vararg und
-- kaemen an eine addon-lokale Tabelle nicht heran.
-- ===========================================================================
local addonName = ...

_G.GuildOps = _G.GuildOps or {}
local GO = _G.GuildOps

GO.name = addonName
GO.version = "0.1.0"

GO.Kompat = GO.Kompat or {}
local K = GO.Kompat

K.Zeit = GetTime
K.Datum = time

function K.CharakterSchluessel()
    local name = UnitName("player")
    if not name then return nil end
    local realm = GetRealmName and GetRealmName() or ""
    realm = (realm or ""):gsub("%s+", "")
    if realm == "" then return name end
    return name .. "-" .. realm
end

-- ---------------------------------------------------------------------------
-- Gilde
-- ---------------------------------------------------------------------------
function K.InGilde()
    return IsInGuild and IsInGuild() and true or false
end

-- Das Gildenroster kommt NICHT sofort. GuildRoster()/C_GuildInfo.GuildRoster()
-- stossen den Abruf nur an; die Daten stehen erst beim Ereignis
-- GUILD_ROSTER_UPDATE. Wer direkt danach GetGuildRosterInfo aufruft, bekommt
-- regelmaessig eine leere Liste - und wuerde daraus faelschlich "Gilde hat
-- keine Mitglieder" schliessen.
function K.RosterAnfordern()
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif _G.GuildRoster then
        _G.GuildRoster()
    end
end

-- Gibt nil zurueck, wenn das Roster noch nicht steht - ausdruecklich NICHT
-- eine leere Liste, damit der Aufrufer beides auseinanderhalten kann.
function K.Roster()
    if not K.InGilde() then return nil end
    local anzahl = GetNumGuildMembers and GetNumGuildMembers() or 0
    if anzahl == 0 then return nil end

    local ergebnis = {}
    for i = 1, anzahl do
        local name, rangName, rangIndex, stufe, _, _, _, _, online, _, klasse = GetGuildRosterInfo(i)
        if name then
            ergebnis[#ergebnis + 1] = {
                name = name,
                rang = rangName,
                rangIndex = rangIndex,
                stufe = stufe,
                online = online and true or false,
                klasse = klasse,
            }
        end
    end
    return ergebnis
end

-- ---------------------------------------------------------------------------
-- Grosse Schatzkammer
-- ---------------------------------------------------------------------------
-- Beantwortet nur die eigene Kammer. Die eines Mitspielers ist nicht
-- abfragbar - was dort steht, kann nur der Spieler selbst beisteuern. Genau
-- deshalb sammelt dieses Addon ueber die Charaktere des Accounts und, mit
-- dem ChannelSync-Modul, ueber die, die es ebenfalls installiert haben.
function K.Schatzkammer()
    if not (C_WeeklyRewards and C_WeeklyRewards.GetActivities) then return nil end

    local ok, aktivitaeten = pcall(C_WeeklyRewards.GetActivities)
    if not ok or type(aktivitaeten) ~= "table" then return nil end

    local ergebnis = {}
    for _, a in ipairs(aktivitaeten) do
        ergebnis[#ergebnis + 1] = {
            art = a.type,
            stufe = a.level,
            fortschritt = a.progress,
            noetig = a.threshold,
            erledigt = (a.progress or 0) >= (a.threshold or 0),
        }
    end
    return ergebnis
end

-- ---------------------------------------------------------------------------
-- Ausruestung des eigenen Charakters
-- ---------------------------------------------------------------------------
-- Fremde Spieler zu untersuchen (Inspect) geht nur in Reichweite, ist
-- asynchron und schlaegt oft fehl. Deshalb erhebt jeder Spieler seinen
-- EIGENEN Stand - das ist die Angabe, die verlaesslich ist.
local VERZAUBERBAR = {
    [5] = "Brust", [8] = "Fuesse", [9] = "Handgelenk", [10] = "Haende",
    [11] = "Ring 1", [12] = "Ring 2", [15] = "Ruecken", [16] = "Waffe",
}

function K.EigeneAusruestung()
    local luecken = {}
    local stuecke = 0

    for platz = 1, 17 do
        local link = GetInventoryItemLink and GetInventoryItemLink("player", platz)
        if link then
            stuecke = stuecke + 1

            -- Der Itemlink traegt Verzauberung und Sockel in sich. Aufbau:
            --   item:itemID:enchantID:gem1:gem2:gem3:gem4:...
            local teile = { strsplit(":", link) }
            local enchant = tonumber(teile[3])

            if VERZAUBERBAR[platz] and not enchant then
                luecken[#luecken + 1] = { platz = platz, was = "verzauberung",
                                          name = VERZAUBERBAR[platz] }
            end
        end
    end

    return { stuecke = stuecke, luecken = luecken }
end

-- ---------------------------------------------------------------------------
-- Ereignisse
-- ---------------------------------------------------------------------------
local rahmen = CreateFrame("Frame")
local horcher = {}

rahmen:SetScript("OnEvent", function(_, ereignis, ...)
    local liste = horcher[ereignis]
    if not liste then return end
    for _, fn in ipairs(liste) do
        local ok, fehler = pcall(fn, ereignis, ...)
        if not ok then GO.letzterFehler = tostring(fehler) end
    end
end)

function K.Horchen(ereignis, fn)
    if not horcher[ereignis] then
        horcher[ereignis] = {}
        rahmen:RegisterEvent(ereignis)
    end
    local liste = horcher[ereignis]
    liste[#liste + 1] = fn
end

function K.Spaeter(sekunden, fn)
    if C_Timer and C_Timer.After then
        C_Timer.After(sekunden, fn)
    else
        fn()
    end
end
