--[[
inversion of control pattern
important benefit: testing...
--]]
local lazy_adapter = require("lazyflex.adapter.lazy")
return require("lazyflex").on_hooked(lazy_adapter)
