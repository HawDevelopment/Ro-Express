--[[
    Router Class
    HawDevelopment
    12/05/2021
--]]

local Router = {}
Router.__index = Router

local Runners = {

	["function"] = function(inst: any, ...)
		inst(...)
	end,
	["router"] = function(inst: any, ...)
		--TODO: Add router instance!
	end,
}

function Router:_run(inst: any, ...)
	for classname, func in pairs(Runners) do
		if typeof(inst) == classname or inst.Classname == classname then
			func(inst, ...)
		end
	end

	return inst
end

return Router
