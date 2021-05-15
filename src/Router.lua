--[[
    Router Class
    HawDevelopment
    12/05/2021
--]]

local Router = {}
Router.__index = Router

local Runner
do
	local Runners = {
		["function"] = function(_, inst, ...)
			return inst._router(...)
		end,
		["Router"] = function(_, inst, ...)
			--TODO: Add more features!
			return inst._router(...)
		end,
		["Method"] = function(_, inst, ...)
			return inst._callback(...)
		end,
	}

	Runner = function(path, inst, ...)
		-- For methods, since they already have a value assigned to _type (Get or Post etc.)
		if Runners[inst.Classname] then
			return Runners[inst.Classname](path, inst, ...)
		else
			-- We didnt find the type, then we need to guess
			if Runners[type(inst._router)] then
				return Runners[type(inst._router)](path, inst, ...)
			elseif Runners[inst._type] then
				return Runners[inst._type](path, inst, ...)
			end
		end
	end
end

local Index
do
	Index = {
		Method = "_methods",
		Router = "_routers",
		["function"] = "_routers",
	}
end

function Router._new(child, values)
	values = values or true
	local self = setmetatable({}, Router)

	if values then
		if child then
			self._methods = {}
			self._routers = {}
			self._build = false
		else
			self._paths = {}
		end

		self.IsChild = child
	end

	return self
end

function Router.new()
	return Router._new(false, true)
end

function Router.func(path, func)
	local router = Router._new(false, false)

	router._router = func
	router._path = path
	router._type = "function"

	return router
end

function Router:_NewPath(path, parent)
	assert(not self._paths[path], "Path is already made!")

	local newpath = {
		_router = Router._new(true, true),
		_path = path,
		_parent = parent,
	}

	self._paths[path] = newpath
end

function Router:_AddPath(path, value, type)
	assert(not self.IsChild, "Cannot be called by a non app router!")

	if not self._paths[path] or table.find(self._paths[path], value) then
		return
	end

	local index = Index[type or value.Classname or value._type]
	table.insert(self._paths[path]._router[index], value)
end

function Router:_HandleRouter(path, ...)
	for _, router in pairs(self._routers) do
		Runner(path, router, ...)
	end
end

function Router:_HandleMethod(path, ...)
	for _, method in pairs(self._methods) do
		Runner(path, method, ...)
	end
end

function Router:_GetParentMiddleware(path, middleware)
	table.insert(middleware, 1, path._router)
	if path._parent and self._paths[path._parent] then
		self:_GetParentMiddleware(self._paths[path._parent], middleware)
	end
end

function Router:_BuildPath(path, inst)
	path = self._paths[path]
	if not path or not inst then
		return
	end

	if path._build then
		return path._remote
	end

	local parent = self:_BuildPath(path._parent, inst)

	local middleware = {}
	if self._paths[path._parent] then
		self:_GetParentMiddleware(self._paths[path._parent], middleware)
	end

	local temp = Instance.new("RemoteFunction")
	temp.Name = string.match(path._path, "[%a%d]+$")

	temp:SetAttribute("PATH", path._path)

	temp.OnServerInvoke = function(_, ...)
		--TODO: Add Req, Res!

		for _, router in pairs(middleware) do
			router:_HandleRouter(path, ...)
		end

		path._router:_HandleRouter(path, ...)

		path._router:_HandleMethod(path, ...)
	end

	path._build = true
	path._remote = temp
	temp.Parent = parent or inst

	return temp
end

return Router
