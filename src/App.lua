--[[
    App Class
    HawDevelopment
    5/11/2021
--]]

--[[
	App.new() -> App
	
	App:METHOD(path: string, callback: (Request, Response))
	App:all(path: string, callback: (Request, Response))
	App:use(path: string, callback: (Request, Response))
	
	App:Listen(name: string | number)
	App:Destroy()
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IS_SERVER = game:GetService("RunService"):IsServer()
local REMOTE = IS_SERVER and "RemoteFunction" or "BindableFunction"

local METHODS = "GET POST DELETE PUT ALL"

local Methods = require(script.Parent.Methods)
local Router = require(script.Parent.Router)

local t = require(script.Parent.t)

local App = {}
App.__index = App

function App.new()
	local self = setmetatable({}, {
		__index = function(tab, index: string)
			if METHODS:lower():find(index:lower()) then
				return function(_, ...)
					assert(t.tuple(t.string, t.callback)(...))
					tab:__registerValue(Methods[index:lower()](tab, ...), "Method")
				end
			end

			return rawget(App, index)
		end,
	})

	self._paths = {}
	self._router = Router._new(false)

	self._router.paths = {}

	return self
end

function App:__newPath(path, parentpath)
	assert(t.tuple(t.string)(path))

	self._paths[path] = path
	self._router:__newPath(path, parentpath)
end

function App:Listen(name: string | number)
	assert(t.union(t.string, t.number)(name))
	assert(not self._root, "Cannot build an app already built!")

	self._name = assert(name, "Expected a name!")

	self._root = ReplicatedStorage:FindFirstChild(name) or Instance.new(REMOTE)
	self._root.Name = name

	for _, path in pairs(self._paths) do
		self._router:__buildPath(path, self._root)
	end

	self._root.Parent = game:GetService("ReplicatedStorage")

	return self._root
end

function App:__registerValue(tab: { any }, type)
	assert(t.tuple(t.table, t.string)(tab, type))
	local path = tab.path or tab._path

	if not self._paths[path] then
		local parentname = string.match(path, "/[%a%d]+$")
		parentname = parentname and string.gsub(path, parentname, "") or nil
		self:__newPath(path, parentname == "" and "/" or parentname)
	end

	self._router:__addPath(path, tab, type)
end

function App:use(path: string, inst: any)
	assert(t.tuple(t.string, t.callback)(path, inst))

	self:__registerValue(Router.func(path, inst), "Router")
end

function App:Destroy()
	if self._root then
		self._root:Destroy()
	end

	table.clear(self)
	setmetatable(self, {
		__index = function()
			error("This App is destroyed!", 2)
		end,
	})
end

return setmetatable(App, { __call = App.new })
