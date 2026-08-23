if GetLocale() ~= "deDE" then return end
local GO = _G.GuildOps
if not GO then return end
GO.L["LA_NOT_YET"] = "Beute: noch nichts erfasst."
GO.L["LA_ITEMS"]   = "Beute: %d Gegenstaende erfasst."
