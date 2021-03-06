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
local REMOTE = IS_SERVER and "RemoteFunction" or "BindableFunction"
local METHODS = "GET POST DELETE PUT"

local NOT_FOUND = {
	Status = 404,
	Succes = false,
}

local t = require(script.Parent.t)

local Request = require(script.Parent.Request)
local Response = require(script.Parent.Response)

local Runner, Index
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
	Index = {
		Method = "Method",
		Router = "Router",
		["function"] = "Router",
	}

	Runner = function(path, inst, ...)
		-- For methods, since they already have a value assigned to type (Get or Post etc.)
		local func = Runners[inst.Classname or inst._type]
		local succes, err = pcall(func, path, inst, ...)
		if not succes then
			error("Path: " .. tostring(path.path) .. " had an error!\n" .. tostring(err), 3)
		end
	end
end

-- Constructors

function Router._new(child: boolean?)
	local self = setmetatable({
		IsChild = child or false,
	}, Router)

	if child then
		self.methods = {}
		self.routers = {}
	end

	return self
end

function Router.func(path, func)
	assert(t.tuple(t.string, t.callback)(path, func))
	local router = Router._new(false)

	router.router = func
	router.path = path
	router._type = "Router"

	return router
end

-- Path

function Router:__newPath(path, parent)
	assert(t.tuple(t.string)(path))
	assert(not self.paths[path], "Path is already made!")

	self.paths[path] = {
		router = Router._new(true),
		path = path,
		parent = parent,
	}

	return self.paths[path]
end

function Router:__addPath(path, value, type)
	assert(t.tuple(t.string, t.any, t.string)(path, value, type))
	assert(not self.IsChild, "Cannot be called by a non app router!")

	path = self.paths[path]
	if not path then
		return
	end

	local index = Index[type or value.Classname or value._type or error(
		"Value of type: " .. typeof(value) .. " has no type or Classname!"
	)]

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
	assert(t.tuple(t.table, t.string)(path, type))

	if path.router.methods.ALL then
		Runner(path, path.router.methods.ALL, ...)
	end
	Runner(path, path.router.methods[type], ...)
end

-- Building

function Router:__getParentMiddleware(path, middleware)
	table.insert(middleware, 1, path.router)
	if path.parent and self.paths[path.parent] then
		self:__getParentMiddleware(self.paths[path.parent], middleware)
	end
	return middleware
end

function Router:__buildPath(path, inst)
	path = self.paths[path]

	if not path or not inst then
		return
	elseif path.remote then
		return path.remote
	end

	local parent = path.path == "/" and inst or self:__buildPath(path.parent, inst)
	return self:__bindPath(path, inst, parent)
end

local function Copy(tab)
	local new = {}
	for i, v in pairs(tab) do
		new[i] = v
	end
	return new
end

local function isMethod(type: string)
	return METHODS:find(type:upper())
end

function Router:__bindPath(path, root, parent)
	local temp
	if path.path == "/" then
		temp = root
	else
		local name = string.match(path.path, "[%a%d]+$")
		temp = (root and root:FindFirstChild(name)) or (parent and parent:FindFirstChild(name)) or Instance.new(REMOTE)
		temp.Name = name
		temp.Parent = parent or root
	end
	path.remote = temp

	local event
	if temp:IsA("RemoteFunction") then
		event = IS_SERVER and "OnServerInvoke" or "OnClientInvoke"
	elseif temp:IsA("BindableFunction") then
		event = "OnInvoke"
	end

	temp[event] = function(...)
		local player, type, arg
		if IS_SERVER then
			player, type, arg = ...
		else
			player, type, arg = game.Players.LocalPlayer, ...
		end

		assert(t.tuple(t.string, t.any)(type, arg))
		assert(isMethod(type), "Bad Request: That method doesnt exist!")

		type = string.upper(type)
		if not path.router.methods[type] then
			return Copy(NOT_FOUND)
		end

		local req = Request._new(path.path, type, player, arg)
		local res = Response._new()

		for _, router in pairs(self:__getParentMiddleware(path, {})) do
			router:__handleRouter(path, req, res)
		end

		path.router:__handleMethod(path, type, req, res)
		res:done()

		return {
			Status = res._status,
			Succes = res._succes,
			Body = res._param,
		}
	end

	return temp
end

return Router
