if GetLocale() ~= "deDE" then return end
local GO = _G.GuildOps
if not GO then return end
GO.L["AT_NOT_YET"] = "Anwesenheit: noch kein Raidabend erfasst."
GO.L["AT_NIGHTS"]  = "Anwesenheit: %d Raidabende erfasst."
