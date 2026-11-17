local funkmoon = require "funkmoon"

-- This fixture must remain incompatible with a numeric result annotation.
---@type boolean[]
local flags = { true, false }

---@type funkmoon.FunctionalTable<number>
local invalidMaximum = funkmoon.max(flags)

---@type funkmoon.FunctionalTable<number>
local invalidMinimum = funkmoon.min(flags)
