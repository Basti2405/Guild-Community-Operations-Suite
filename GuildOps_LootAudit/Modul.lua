-- Modul.lua - Item-Verteilung dokumentieren
--
-- ===========================================================================
-- STAND: Geruest. Siehe Planung/02-Module.md.
--
-- Zweck ist Dokumentation, nicht Bewertung: festhalten, was wohin ging,
-- damit man es spaeter nachlesen kann. Wer wie viel "verdient" hat,
-- entscheidet keine Tabelle.
-- ===========================================================================
local GO = _G.GuildOps
if not GO or not GO.Module then return end

local Modul = GO.Module.Registrieren("LootAudit", {})

function Modul:Pruefen()
    -- Die Beute-Ereignisse gibt es in jedem Client; ohne Gruppe ist das Modul
    -- aber sinnlos, und ohne Gilde gibt es niemanden, mit dem man das teilt.
    if not GO.Kompat.InGilde() then
        return false, "dieser Charakter ist in keiner Gilde"
    end
    return true
end

function Modul:Start()
    self.daten = GO.Speicher.ModulSchublade("lootaudit")
    self.daten.vergaben = self.daten.vergaben or {}
end

function Modul:Kennzahl()
    local n = #(self.daten and self.daten.vergaben or {})
    if n == 0 then return GO.L["LA_NOT_YET"] end
    return GO.L["LA_ITEMS"]:format(n)
end

function Modul:Ausfuhr()
    return { vergaben = self.daten and self.daten.vergaben or {} }
end
