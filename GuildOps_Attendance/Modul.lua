-- Modul.lua - Anwesenheit und Zuverlaessigkeit
--
-- ===========================================================================
-- STAND: Geruest. Die Haken stehen, die Fachlogik ist in Planung/02-Module.md
-- beschrieben.
--
-- WAS DIESES MODUL EHRLICHERWEISE KANN
-- ---------------------------------------------------------------------------
-- Es sieht nur, was der Spieler sieht, der es installiert hat: wer in SEINER
-- Gruppe war, als der Bosskampf begann. Wer an dem Abend gar nicht erst
-- online kam, taucht hier NICHT als "abwesend" auf - dazu muesste man wissen,
-- wer eingeplant war, und das weiss das Spiel nicht.
--
-- Die vollstaendige Antwort auf "wer hat gefehlt" kommt deshalb aus dem
-- Abgleich mit einem gepflegten Kader ausserhalb des Spiels. Dieses Modul
-- liefert die eine Haelfte - wer da WAR - und zwar so, dass sie sich
-- ausfuehren laesst.
-- ===========================================================================
local GO = _G.GuildOps
if not GO or not GO.Module then return end

local Modul = GO.Module.Registrieren("Attendance", {})

function Modul:Pruefen()
    -- Braucht nichts Fremdes. Nur eine Gilde ergibt Sinn - ohne sie gibt es
    -- keinen Kader, gegen den man abgleichen koennte.
    if not GO.Kompat.InGilde() then
        return false, "dieser Charakter ist in keiner Gilde"
    end
    return true
end

function Modul:Start()
    self.daten = GO.Speicher.ModulSchublade("attendance")
    self.daten.abende = self.daten.abende or {}
end

function Modul:Kennzahl()
    local n = 0
    for _ in pairs(self.daten and self.daten.abende or {}) do n = n + 1 end
    if n == 0 then return GO.L["AT_NOT_YET"] end
    return GO.L["AT_NIGHTS"]:format(n)
end

-- Was in die Ausfuhr des Kerns einfliesst. Bewusst die Rohdaten - die
-- Bewertung ("unzuverlaessig") gehoert nicht in ein Addon, sondern zu den
-- Menschen, die den Kader fuehren.
function Modul:Ausfuhr()
    return { abende = self.daten and self.daten.abende or {} }
end
