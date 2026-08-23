-- Locales/enUS.lua - the base language
--
-- One sentence per line: a translator should never have to reassemble a
-- sentence from fragments. enUS is the fallback and must be COMPLETE.
_G.GuildOps = _G.GuildOps or {}
local GO = _G.GuildOps

GO.L = GO.L or {}
local L = GO.L

L["ADDON_NAME"]        = "Guild Ops"
L["SLASH_HINT"]        = "Type /gops for the window, /gops export for the data, /gops doctor for a self-check."

L["WINDOW_TITLE"]      = "Guild Ops"
L["NO_DATA"]           = "Nothing recorded yet. Log in on each character once."
L["CHARACTERS_KNOWN"]  = "Characters known: %d"
L["LAST_SEEN"]         = "last seen %s"

L["GAPS_NONE"]         = "no gaps found"
L["GAPS_SOME"]         = "%d gaps"
L["VAULT_PROGRESS"]    = "Great Vault: %d of %d slots unlocked"

L["EXPORT_TITLE"]      = "Copy this text (Ctrl+A, Ctrl+C)"
L["EXPORT_EMPTY"]      = "Nothing to export yet."

L["DOCTOR_TITLE"]      = "Guild Ops - self-check"
L["DOCTOR_STORAGE_OK"] = "Storage: ready (%d characters)."
L["DOCTOR_STORAGE_NO"] = "Storage: NOT ready - saved variables did not load."
L["DOCTOR_GUILD_NO"]   = "Guild: this character is not in a guild."
L["DOCTOR_GUILD_OK"]   = "Guild roster: %d members."
L["DOCTOR_GUILD_WAIT"] = "Guild roster: not delivered yet - try again in a moment."
L["DOCTOR_NO_MODULES"] = "Modules: none installed."
L["DOCTOR_MODULE_ON"]  = "Module %s: active."
L["DOCTOR_MODULE_OFF"] = "Module %s: inactive (%s)."
L["DOCTOR_NO_REASON"]  = "no reason given"
