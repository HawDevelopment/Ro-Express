--[[
    Router Class
    HawDevelopment
    12/05/2021
--]]

local Router = {}
Router.__index = Router

Router.Classname = "Router"

local Runners = {

	["function"] = function(inst: any, ...)
		inst(...)
	end,
	["router"] = function(inst: any, ...)
		--TODO: Add router instance!
	end,
}

function Router._is(inst: any)
	for classname, _ in pairs(Runners) do
		if typeof(inst) == classname or inst.Classname == classname then
			return true
		end
	end
	return false
end

function Router._run(inst: any, ...)
	if type(inst._router) == "function" then
		Runners["function"](inst)
		return inst
	end

	for classname, func in pairs(Runners) do
		if typeof(inst) == classname or inst.Classname == classname then
			func(inst, ...)
		end
	end

	return inst
end

function Router._new(path: string, inst: any)
	assert(path, "Need a valid path!")
	assert(Router._is(inst), "Need a valid router!")

	return setmetatable({
		_path = path,
		_router = inst,
	}, { __index = Router })
end

return Router
