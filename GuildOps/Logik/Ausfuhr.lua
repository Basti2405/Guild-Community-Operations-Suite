-- Logik/Ausfuhr.lua - Daten herausgeben, ohne dass jemand Lua lesen muss
--
-- ===========================================================================
-- WOZU
-- ---------------------------------------------------------------------------
-- Der Zweck dieses Addons endet nicht im Spiel. Was hier erhoben wird, soll
-- in ein Web-Dashboard oder zu einem Discord-Bot koennen. Die SavedVariables
-- sind dafuer unbrauchbar: Sie sind Lua-Quelltext, den ein Server erst
-- ausfuehren muesste - und fremden Lua-Quelltext fuehrt man nicht aus.
--
-- Deshalb JSON. Der Spieler kopiert es aus einem Textfeld heraus; ein Addon
-- kann von sich aus nichts ins Netz schicken, und das soll auch so bleiben.
--
-- WARUM EIN EIGENER JSON-SCHREIBER
-- ---------------------------------------------------------------------------
-- Eine JSON-Bibliothek waere ein weiteres Fremdteil im Ausliefer-Paket. Was
-- hier gebraucht wird - Zahlen, Zeichenketten, Listen, Tabellen - sind
-- fuenfzig Zeilen. Der Rest von JSON kommt in unseren Daten nicht vor.
-- ===========================================================================
local GO = _G.GuildOps

GO.Ausfuhr = GO.Ausfuhr or {}
local A = GO.Ausfuhr

-- Steuerzeichen, die in JSON maskiert werden muessen.
local FLUCHT = {
    ['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b',
    ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t',
}

local function text(s)
    s = tostring(s):gsub('[%c"\\]', function(z)
        return FLUCHT[z] or ("\\u%04x"):format(z:byte())
    end)
    return '"' .. s .. '"'
end

-- Ist die Tabelle eine Liste (1..n ohne Luecke) oder ein Objekt? JSON
-- unterscheidet das, Lua nicht - also muessen wir nachsehen.
local function istListe(t)
    local n = 0
    for schluessel in pairs(t) do
        if type(schluessel) ~= "number" then return false end
        n = n + 1
    end
    return n == #t
end

local schreibe

local function schreibeTabelle(t, tiefe)
    -- Eine Tabelle, die sich selbst enthaelt, wuerde hier ewig laufen. In
    -- unseren Daten kommt das nicht vor - eine Grenze steht trotzdem da,
    -- weil ein Absturz beim Ausfuehren des Spielers teuer ist.
    if tiefe > 12 then return '"..."' end

    local teile = {}
    if istListe(t) then
        for _, wert in ipairs(t) do
            teile[#teile + 1] = schreibe(wert, tiefe + 1)
        end
        return "[" .. table.concat(teile, ",") .. "]"
    end

    -- Schluessel sortiert ausgeben. Sonst sieht dieselbe Ausfuhr bei jedem
    -- Aufruf anders aus, und ein Vergleich zweier Staende wird unmoeglich.
    local schluessel = {}
    for k in pairs(t) do schluessel[#schluessel + 1] = tostring(k) end
    table.sort(schluessel)

    for _, k in ipairs(schluessel) do
        local wert = t[k] ~= nil and t[k] or t[tonumber(k)]
        teile[#teile + 1] = text(k) .. ":" .. schreibe(wert, tiefe + 1)
    end
    return "{" .. table.concat(teile, ",") .. "}"
end

schreibe = function(wert, tiefe)
    tiefe = tiefe or 0
    local art = type(wert)

    if wert == nil then return "null" end
    if art == "boolean" then return tostring(wert) end
    if art == "number" then
        -- JSON kennt weder inf noch nan.
        if wert ~= wert or wert == math.huge or wert == -math.huge then return "null" end
        return tostring(wert)
    end
    if art == "string" then return text(wert) end
    if art == "table" then return schreibeTabelle(wert, tiefe) end

    -- Funktionen und Benutzerdaten gehoeren nicht in eine Ausfuhr.
    return "null"
end

A.NachJSON = schreibe

-- ---------------------------------------------------------------------------
-- Was ausgefuehrt wird
-- ---------------------------------------------------------------------------
-- Bewusst zusammengestellt statt "die ganze Datenbank": In den
-- SavedVariables stehen auch Fensterpositionen und Modul-Zwischenstaende,
-- die auf einem Server nichts verloren haben.
function A.Sammeln()
    local db = GO.Speicher and GO.Speicher.db
    if not db then return nil end

    local paket = {
        erzeugt = GO.Kompat.Datum(),
        version = GO.version,
        charaktere = {},
    }

    for schluessel, eintrag in pairs(db.charaktere) do
        paket.charaktere[schluessel] = {
            name = eintrag.name,
            klasse = eintrag.klasse,
            aktualisiert = eintrag.aktualisiert,
            ausruestung = eintrag.ausruestung,
            schatzkammer = eintrag.schatzkammer,
        }
    end

    -- Module duerfen etwas beisteuern. Der Kern kennt sie nicht namentlich -
    -- wer etwas beizutragen hat, hat einen Ausfuhr-Haken.
    local beitraege = GO.Module.Rufen("Ausfuhr")
    if #beitraege > 0 then
        paket.module = {}
        for _, treffer in ipairs(beitraege) do
            paket.module[treffer.modul.name] = treffer.wert
        end
    end

    return paket
end

function A.Text()
    local paket = A.Sammeln()
    if not paket then return nil end
    return schreibe(paket)
end
