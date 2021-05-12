--[[
    App Class
    HawDevelopment
    5/11/2021
--]]

local Signal = require(script.Parent.Signal)
local Methods = require(script.Parent.Methods)
local Router = require(script.Parent.Router)

local App = {}
App.__index = App

function App.new()
	local self = setmetatable({}, App)

	self._paths = {}
	self._methods = {}
	self._name = {}
	self._newitem = Signal.new()

	self._newitem:Connect(function(path)
		if self._root then
			self:_listenOnPath(path, self._root)
		end
	end)

	return self
end

function App:_newPath(path, parentpath)
	assert(path, "Need a valid path")

	local checkpath = parentpath or self._paths

	if checkpath[path] then
		return
	end

	checkpath[path] = {
		_methods = {},
		_routers = {},
		_paths = {},
	}
end

function App:_addToPath(path, value)
	--TODO: Fix this mess
	local index = (typeof(value) == "table" and value.Classname == "Method") and "_methods" or "_routers"

	table.insert(path[index], value)
	self._newitem:Fire(path)
end

function App:_addRemoteToPath(path, remote)
	if path._remote then
		return
	end

	path._remote = remote
	remote.OnServerInvoke = function(player, ...)
		--TODO: Add response and request and next()!

		for _, router in pairs(path._routers) do
			Router:_run(router, "Hello World!")
		end

		for _, method in pairs(path._methods) do
			Methods:_run(method, "Hello World!")
		end
	end
end

function App:_listenOnPath(path, parent)
	-- building each method
	for _, method in pairs(path._methods) do
		if not method._build then
			local remote = method:Build(parent)

			if remote ~= self._root and not path.remote then
				self:_addRemoteToPath(path, remote)
			end
		end
	end
end

function App:Listen(name: string | number)
	self._name = assert(name, "Expected a name!")
	if self._root or self._build then
		return
	end

	local Root = Instance.new("Folder")
	self._root = Root
	Root.Name = name

	print(self._paths)
	for _, path in pairs(self._paths) do
		self:_listenOnPath(path, Root)
	end

	Root.Parent = game:GetService("ReplicatedStorage")

	return Root
end

function GetPathFromMethod(path, split, index)
	if #split == index then
		return path
	end

	for name, tab in pairs(path._path ~= nil and path._path or path) do
		if split[index] == name then
			return GetPathFromMethod(tab, split, index + 1)
		end
	end

	return path
end

function App:_registerMethod(method)
	print(method)
	local split = method._path:gsub("^/", ""):split("/")
	local path = GetPathFromMethod(self._paths, split, 1)

	if not path[split[#split]] then
		path = self:_newPath(split[#split], path)
	end

	self:_addToPath(path, method)
end

function App:get(...)
	self:_registerMethod(Methods.get(self, ...))
end

function App:post(...)
	self:_registerMethod(Methods.post(self, ...))
end

function App:delete(...)
	self:_registerMethod(Methods.delete(self, ...))
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

return App
