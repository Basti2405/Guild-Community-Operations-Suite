-- Modul.lua - Abgleich zwischen Installationen
--
-- ===========================================================================
-- STAND: Geruest. Siehe Planung/02-Module.md - dort steht auch, warum dieses
-- Modul das heikelste der drei ist.
--
-- WORAUF ZU ACHTEN IST
-- ---------------------------------------------------------------------------
-- Ein Addon-Kanal ist kein privater Kanal. Alles, was hier verschickt wird,
-- kann jeder mitlesen, der ein Addon schreibt - "verdeckt" heisst nur, dass
-- es nicht im Chatfenster auftaucht. Deshalb gehen ueber diesen Weg
-- ausschliesslich Daten, die ohnehin jeder in der Gilde sehen kann.
-- Persoenliche Notizen bleiben lokal. Das ist keine Einstellung, die man
-- umlegen kann, sondern eine Entscheidung.
--
-- Ausserdem: Addon-Nachrichten sind gedrosselt. Wer bei jedem Login das
-- ganze Roster verschickt, laesst die Verbindung der ganzen Gruppe stocken.
-- Der Abgleich ist deshalb als Unterschied gedacht, nicht als Vollbild.
-- ===========================================================================
local GO = _G.GuildOps
if not GO or not GO.Module then return end

local Modul = GO.Module.Registrieren("ChannelSync", {})

-- Kanalname. Max. 15 Zeichen, sonst nimmt WoW ihn nicht an.
local KANAL = "GuildOpsSync1"

function Modul:Pruefen()
    if not (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix) then
        return false, "C_ChatInfo steht in diesem Client nicht zur Verfuegung"
    end
    if not GO.Kompat.InGilde() then
        return false, "dieser Charakter ist in keiner Gilde"
    end

    local ok = C_ChatInfo.RegisterAddonMessagePrefix(KANAL)
    if not ok then
        -- WoW begrenzt die Zahl der Praefixe pro Client. Ist sie erschoepft,
        -- ist das kein Fehler dieses Addons - aber ein Grund, still zu sein.
        return false, "Addon-Kanal konnte nicht angemeldet werden"
    end
    return true
end

function Modul:Start()
    self.daten = GO.Speicher.ModulSchublade("channelsync")
    self.daten.gesehen = self.daten.gesehen or {}
end

function Modul:Kennzahl()
    local n = 0
    for _ in pairs(self.daten and self.daten.gesehen or {}) do n = n + 1 end
    if n == 0 then return GO.L["CS_ALONE"] end
    return GO.L["CS_PEERS"]:format(n)
end
