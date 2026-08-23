if GetLocale() ~= "deDE" then return end
local GO = _G.GuildOps
if not GO then return end
GO.L["CS_ALONE"] = "Abgleich: noch keine andere Installation gesehen."
GO.L["CS_PEERS"] = "Abgleich: %d andere Installationen gesehen."
