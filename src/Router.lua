--[[
    Router Class
    HawDevelopment
    12/05/2021
--]]

--[[
	Router._new(child: boolean, values: boolean) -> Router
	Router.func(path: string, callback: (Request, Response)) -> Path
	
	Router:__newPath(path: string, parentpath: string) -> Path
	Router:__addPath(path: string, value: any, type: string) -> void
	
	Router:__buildPath(path: Path, parent: Instance)
	Router:__bindPath(path: Path, middleware: {any}, root: Instance, parent: Instance)
	
	Router:__isMethod(method: string) -> boolean
--]]

local Router = {}
Router.__index = Router

local IS_SERVER = game:GetService("RunService"):IsServer()
local EVENT = IS_SERVER and "OnServerInvoke" or "OnInvoke"

local METHODS = "GET POST DELETE PUT"

local t = require(script.Parent.t)

local Request = require(script.Parent.Request)
local Response = require(script.Parent.Response)

local Runner
do
	local Runners = {
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
		elseif Runners[inst._type] then
			return Runners[inst._type](path, inst, ...)
		end
	end
end

local Index
do
	Index = {
		Method = "Method",
		Router = "Router",
		["function"] = "Router",
	}
end

-- Constructures

function Router._new(child, values)
	values = values or true
	local self = setmetatable({}, Router)

	if values then
		if child then
			self._methods = {}
			self._routers = {}
		end

		self.IsChild = child or false
	end

	return self
end

function Router.func(path, func)
	assert(t.tuple(t.string, t.callback)(path, func))
	local router = Router._new(false, false)

	router._router = func
	router._path = path
	router._type = "Router"

	return router
end

-- Path

function Router:__newPath(path, parent)
	assert(t.tuple(t.string, t.string)(path, parent))
	assert(not self._paths[path], "Path is already made!")

	local newpath = {
		_router = Router._new(true, true),
		_path = path,
		_parent = parent,
	}

	self._paths[path] = newpath
	return newpath
end

function Router:__addPath(path, value, type)
	assert(t.tuple(t.string, t.any, t.string)(path, value, type))
	assert(not self.IsChild, "Cannot be called by a non app router!")

	path = self._paths[path]
	if not path then
		return
	end

	local index = Index[type or value.Classname or value._type]

	if index == "Method" then
		path._router._methods[value._type] = value
	elseif index == "Router" then
		table.insert(path._router._routers, value)
	end
end

-- Handlers

function Router:__handleRouter(path, ...)
	assert(t.table(path))
	for _, router in pairs(self._routers) do
		Runner(path, router, ...)
	end
end

function Router:__handleMethod(path, type, ...)
	assert(t.table(path))
	assert(t.string(type))

	if path._router._methods.ALL then
		Runner(path, path._router._methods.ALL, ...)
	end

	if path._router._methods[type] then
		return Runner(path, path._router._methods[type], ...)
	end
end

-- Building

function Router:__getParentMiddleware(path, middleware)
	table.insert(middleware, 1, path._router)
	if path._parent and self._paths[path._parent] then
		self:__getParentMiddleware(self._paths[path._parent], middleware)
	end
end

function Router:__buildPath(path, inst)
	path = self._paths[path]

	if not path or not inst then
		return
	elseif path._remote then
		return path._remote
	end

	local parent = self:__buildPath(path._parent, inst)

	local middleware = {}
	if self._paths[path._parent] then
		self:__getParentMiddleware(self._paths[path._parent], middleware)
	end

	return self:__bindPath(path, middleware, inst, parent)
end

function Router:__bindPath(path, middleware, root, parent)
	local temp
	if IS_SERVER then
		temp = Instance.new("RemoteFunction")
	else
		temp = Instance.new("BindableFunction")
	end

	temp.Name = string.match(path._path, "[%a%d]+$")
	temp:SetAttribute("PATH", path._path)

	temp[EVENT] = function(player, type, arg)
		assert(t.tuple(t.string, t.any)(type, arg))
		type = string.upper(type)

		if not Router.__isMethod(type) then
			return error("Bad Request: That method doesnt exist!")
		end

		local req = Request._new(path._path, type, player, arg)
		local res = Response._new()

		for _, router in pairs(middleware) do
			router:__handleRouter(path, req, res)
		end

		path._router:__handleRouter(path, req, res)
		path._router:__handleMethod(path, type, req, res)

		res:done()

		return {
			Status = res._status,
			Succes = res._succes,
			Body = res._param,
		}
	end

	path._remote = temp
	temp.Parent = parent or root

	return temp
end

-- Util

function Router.__isMethod(type: string)
	return METHODS:find(type:upper())
end

return Router
