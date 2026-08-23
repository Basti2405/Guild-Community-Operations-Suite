-- UI/Fenster.lua - das Fenster, bewusst schlicht
--
-- ===========================================================================
-- Ohne Fremdbibliothek gebaut (siehe die Begruendung in der .toc). Fuer das,
-- was hier zu sehen ist - eine Kopfzeile, ein Textbereich, Reiter der Module
-- - reicht CreateFrame vollstaendig aus.
--
-- Die Reiter kommen NICHT von hier. Jedes Modul, das einen Reiter-Haken hat,
-- bekommt einen; diese Datei kennt kein einziges Modul namentlich.
-- ===========================================================================
local GO = _G.GuildOps
local M = GO.Module

GO.UI = GO.UI or {}
local UI = GO.UI

local BREITE, HOEHE = 640, 440

local function bauen()
    local f = CreateFrame("Frame", "GuildOpsFenster", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(BREITE, HOEHE)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Position merken, damit das Fenster dort wieder aufgeht, wo der
        -- Spieler es zuletzt hingeschoben hat.
        local punkt, _, relativ, x, y = self:GetPoint()
        local db = GO.Speicher and GO.Speicher.db
        if db then db.einstellungen.fensterPunkt = { punkt, relativ, x, y } end
    end)

    f.TitleText:SetText(GO.L["WINDOW_TITLE"])

    -- Inhalt
    local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 18, -34)
    text:SetPoint("BOTTOMRIGHT", -18, 18)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    f.Inhalt = text

    -- Gespeicherte Position wiederherstellen.
    local db = GO.Speicher and GO.Speicher.db
    local p = db and db.einstellungen.fensterPunkt
    if p then
        f:ClearAllPoints()
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    end

    f:Hide()
    return f
end

function UI.Fenster()
    if not UI.rahmen then UI.rahmen = bauen() end
    return UI.rahmen
end

-- Was im Fenster steht. Der Kern liefert die Grundzeilen, die Module je eine
-- Kennzahl-Zeile - wer keine hat, taucht nicht auf.
local function inhaltBauen()
    local L = GO.L
    local zeilen = {}

    local alle = GO.Speicher and GO.Speicher.AlleCharaktere() or {}
    local n = 0
    for _ in pairs(alle) do n = n + 1 end

    if n == 0 then
        zeilen[#zeilen + 1] = L["NO_DATA"]
    else
        zeilen[#zeilen + 1] = L["CHARACTERS_KNOWN"]:format(n)
        zeilen[#zeilen + 1] = " "
        for schluessel, eintrag in pairs(alle) do
            local wann = eintrag.aktualisiert
                and date("%d.%m.%Y", eintrag.aktualisiert)
                or "?"
            zeilen[#zeilen + 1] = ("|cffffd100%s|r  (%s)"):format(schluessel, L["LAST_SEEN"]:format(wann))
        end
    end

    local kennzahlen = M.Rufen("Kennzahl")
    if #kennzahlen > 0 then
        zeilen[#zeilen + 1] = " "
        for _, treffer in ipairs(kennzahlen) do
            zeilen[#zeilen + 1] = ("|cff8080ff%s|r  %s"):format(treffer.modul.name, tostring(treffer.wert))
        end
    end

    return table.concat(zeilen, "\n")
end

function UI.Umschalten()
    local f = UI.Fenster()
    if f:IsShown() then
        f:Hide()
    else
        f.Inhalt:SetText(inhaltBauen())
        f:Show()
    end
end

-- ---------------------------------------------------------------------------
-- Ausfuhr-Fenster
-- ---------------------------------------------------------------------------
-- Ein Addon kann von sich aus nichts ins Netz schicken - und das soll auch so
-- bleiben. Also ein Textfeld, aus dem der Spieler selbst kopiert. Der Text
-- wird beim Oeffnen vollstaendig markiert, damit Strg+C sofort greift.
local function ausfuhrBauen()
    local f = CreateFrame("Frame", "GuildOpsAusfuhr", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(560, 380)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f.TitleText:SetText(GO.L["EXPORT_TITLE"])

    local scroll = CreateFrame("ScrollFrame", "GuildOpsAusfuhrScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 14, -34)
    scroll:SetPoint("BOTTOMRIGHT", -34, 14)

    local feld = CreateFrame("EditBox", nil, scroll)
    feld:SetMultiLine(true)
    feld:SetFontObject(ChatFontNormal)
    feld:SetWidth(500)
    feld:SetAutoFocus(false)
    -- Escape schliesst, statt den Text zu verlieren.
    feld:SetScript("OnEscapePressed", function() f:Hide() end)
    scroll:SetScrollChild(feld)
    f.Feld = feld

    f:Hide()
    return f
end

function UI.Ausfuhr()
    if not UI.ausfuhrRahmen then UI.ausfuhrRahmen = ausfuhrBauen() end
    local f = UI.ausfuhrRahmen

    local text = GO.Ausfuhr and GO.Ausfuhr.Text()
    if not text then
        print("|cff40c0f0[GO]|r " .. GO.L["EXPORT_EMPTY"])
        return
    end

    f.Feld:SetText(text)
    f.Feld:HighlightText()
    f.Feld:SetFocus()
    f:Show()
end
