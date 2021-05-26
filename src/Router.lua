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
local REMOTE = IS_SERVER and "RemoteFunction" or "BindableFunction"

local METHODS = "GET POST DELETE PUT"

local t = require(script.Parent.t)

local Request = require(script.Parent.Request)
local Response = require(script.Parent.Response)

local Runner
do
	local Runners = {
		["Router"] = function(_, inst, ...)
			--TODO: Add more features!
			return inst.router(...)
		end,
		["Method"] = function(_, inst, ...)
			return inst.callback(...)
		end,
	}

	Runner = function(path, inst, ...)
		-- For methods, since they already have a value assigned to type (Get or Post etc.)
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
			self.methods = {}
			self.routers = {}
		end

		self.IsChild = child or false
	end

	return self
end

function Router.func(path, func)
	assert(t.tuple(t.string, t.callback)(path, func))
	local router = Router._new(false, false)

	router.router = func
	router.path = path
	router.type = "Router"

	return router
end

-- Path

function Router:__newPath(path, parent)
	assert(t.tuple(t.string, t.string)(path, parent))
	assert(not self.paths[path], "Path is already made!")

	local newpath = {
		router = Router._new(true, true),
		path = path,
		parent = parent,
	}

	self.paths[path] = newpath
	return newpath
end

function Router:__addPath(path, value, type)
	assert(t.tuple(t.string, t.any, t.string)(path, value, type))
	assert(not self.IsChild, "Cannot be called by a non app router!")

	path = self.paths[path]
	if not path then
		return
	end

	local index = Index[type or value.Classname or value._type]

	if index == "Method" then
		path.router.methods[value._type] = value
	elseif index == "Router" then
		table.insert(path.router.routers, value)
	end
end

-- Handlers

function Router:__handleRouter(path, ...)
	assert(t.table(path))
	for _, router in pairs(self.routers) do
		Runner(path, router, ...)
	end
end

function Router:__handleMethod(path, type, ...)
	assert(t.table(path))
	assert(t.string(type))

	if path.router.methods.ALL then
		Runner(path, path.router.methods.ALL, ...)
	end

	if path.router.methods[type] then
		return Runner(path, path.router.methods[type], ...)
	end
end

-- Building

function Router:__getParentMiddleware(path, middleware)
	table.insert(middleware, 1, path.router)
	if path.parent and self.paths[path.parent] then
		self:__getParentMiddleware(self.paths[path.parent], middleware)
	end
end

function Router:__buildPath(path, inst)
	path = self.paths[path]

	if not path or not inst then
		return
	elseif path.remote then
		return path.remote
	end

	local parent = self:__buildPath(path.parent, inst)

	local middleware = {}
	if self.paths[path.parent] then
		self:__getParentMiddleware(self.paths[path.parent], middleware)
	end

	return self:__bindPath(path, middleware, inst, parent)
end

function Router:__bindPath(path, middleware, root, parent)
	local temp = Instance.new(REMOTE)

	temp.Name = string.match(path.path, "[%a%d]+$")
	temp:SetAttribute("PATH", path.path)

	temp[EVENT] = function(...)
		local player, type, arg
		if IS_SERVER then
			player, type, arg = ...
		else
			type, arg = ...
		end

		assert(t.tuple(t.string, t.any)(type, arg))
		type = string.upper(type)

		if not Router.__isMethod(type) then
			return error("Bad Request: That method doesnt exist!")
		end

		local req = Request._new(path.path, type, player, arg)
		local res = Response._new()

		for _, router in pairs(middleware) do
			router:__handleRouter(path, req, res)
		end

		path.router:__handleRouter(path, req, res)
		path.router:__handleMethod(path, type, req, res)

		res:done()

		return {
			Status = res._status,
			Succes = res._succes,
			Body = res._param,
		}
	end

	path.remote = temp
	temp.Parent = parent or root

	return temp
end

-- Util

function Router.__isMethod(type: string)
	return METHODS:find(type:upper())
end

return Router
