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

function App:_newPath(path, parentpath, parents)
	assert(path, "Need a valid path")

	local checkpath = parentpath or self._paths

	if checkpath[path] then
		return checkpath[path]
	end

	checkpath[path] = {
		_methods = {},
		_routers = {},
		_paths = {},
		_parents = parents or {},
	}

	return checkpath[path]
end

function App:_addToPath(path, value)
	assert(type(value) == "table", "Need a valid value!")

	--TODO: Fix this mess
	local index
	if value.Classname == "Method" then
		index = "_methods"
	elseif Router._is(value) then
		index = "_routers"
	end

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

		for _, parent in pairs(path._parents) do
			if parent._routers then
				for _, router in pairs(parent._routers) do
					Router._run(router, ...)
				end
			end
		end

		for _, router in pairs(path._routers) do
			Router._run(router, ...)
		end

		for _, method in pairs(path._methods) do
			Methods:_run(method, ...)
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

	for _, newpath in pairs(path._paths) do
		self:_listenOnPath(newpath, parent)
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

function GetPathFromMethod(path, split, index, parents)
	parents = parents or {}
	local checkpath = path._path ~= nil and path._path or path

	for name, tab in pairs(checkpath) do
		if split[index] == name then
			if #split == index then
				return tab, parents
			else
				parents[#parents + 1] = tab
				return GetPathFromMethod(tab._paths, split, index + 1), parents
			end
		end
	end
end

function App:_registerValue(tab: { any })
	local split = tab._path:gsub("^/", ""):split("/")
	local path, parents = GetPathFromMethod(self._paths, split, 1, { self._paths })

	if not path then
		path = self:_newPath(split[#split], path, parents)
	end

	self:_addToPath(path, tab)
end

function App:get(...)
	self:_registerValue(Methods.get(self, ...))
end

function App:post(...)
	self:_registerValue(Methods.post(self, ...))
end

function App:delete(...)
	self:_registerValue(Methods.delete(self, ...))
end

function App:use(path: string, inst: any)
	assert(path, "Need a valid path!")

	if Router._is(inst) or type(inst) == "function" then
		return self:_registerValue(Router._new(path, inst))
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

return App
