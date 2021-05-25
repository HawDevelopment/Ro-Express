--[[
    App Class
    HawDevelopment
    5/11/2021
--]]

local IS_SERVER = game:GetService("RunService"):IsServer()
local REMOTE = IS_SERVER and "RemoteFunction" or "BindableFunction"

local Methods = require(script.Parent.Methods)
local Router = require(script.Parent.Router)

local t = require(script.Parent.t)

local App = {}
App.__index = App

function App.new()
	local self = setmetatable({}, { __index = App })

	self._paths = {}
	self._router = Router._new(false, false)

	self._router._paths = {}

	return self
end

function App:_NewPath(path, parentpath)
	assert(t.tuple(t.string, t.string)(path, parentpath))

	self._paths[path] = path
	self._router:_NewPath(path, parentpath)
end

function App:_AddPath(path, value, type)
	assert(t.tuple(t.string, t.any, t.string)(path, value, type))

	self._router:_AddPath(path, value, type)
end

function App:_ListenPath(path, inst)
	assert(t.tuple(t.string, t.any)(path, inst))
	self._router:_BuildPath(path, inst)
end

function App:Listen(name: string | number)
	assert(t.union(t.string, t.number)(name))
	assert(not self._root, "Cannot build an app already built!")

	self._name = assert(name, "Expected a name!")

	self._root = Instance.new(REMOTE)
	self._root.Name = name

	print(self._router)
	for _, path in pairs(self._paths) do
		self:_ListenPath(path, self._root)
	end

	self._root.Parent = game:GetService("ReplicatedStorage")

	return self._root
end

function App:_RegisterValue(tab: { any }, type)
	assert(t.tuple(t.table, t.string)(tab, type))
	local path = tab._path

	if not self._paths[path] then
		local pathname = string.match(path, "/[%a%d]+$")
		self:_NewPath(path, string.gsub(path, pathname, ""))
	end

	self:_AddPath(path, tab, type)
end

function App:get(...)
	assert(t.tuple(t.string, t.callback)(...))
	self:_RegisterValue(Methods.get(self, ...), "Method")
end

function App:post(...)
	assert(t.tuple(t.string, t.callback)(...))
	self:_RegisterValue(Methods.post(self, ...), "Method")
end

function App:delete(...)
	assert(t.tuple(t.string, t.callback)(...))
	self:_RegisterValue(Methods.delete(self, ...), "Method")
end

function App:put(...)
	assert(t.tuple(t.string, t.callback)(...))
	self:_registerMethod(Methods.put(self, ...), "Method")
end

function App:use(path: string, inst: any)
	assert(t.tuple(t.string, t.any)(path, inst))

	--TODO: Add support for routers
	if type(inst) == "function" then
		return self:_RegisterValue(Router.func(path, inst), "Router")
	end
end

function App:Destroy()
	self._newitem:Destroy()

	if self._root then
		self._root:Destroy()
	end

	table.clear(self)
	setmetatable(self, { __index = function()
		error("This App is destroyed!", 2)
	end })
end

return setmetatable(App, { __call = App.new })
