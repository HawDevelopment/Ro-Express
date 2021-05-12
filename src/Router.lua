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
		return inst._router(...)
	end,
	["router"] = function(inst: any, ...)
		--TODO: Add router instance!
	end,
}

function Router._is(inst: any)
	return type(inst) == "table" and getmetatable(inst) == Router
end

function Router._run(inst: any, ...)
	for classname, func in pairs(Runners) do
		if inst.Classname == classname then
			return func(inst, ...)
		end
	end
end

function Router._new(path: string, inst: any)
	assert(path, "Need a valid path!")
	assert(Router._is(inst) or type(inst) == "function", "Need a valid router!")

	return setmetatable({
		_path = path,
		_router = inst,
		Classname = type(inst) == "function" and "function" or "Router",
	}, Router)
end

return Router
