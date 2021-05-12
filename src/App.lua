--[[
    App Class
    HawDevelopment
    5/11/2021
--]]

local Signal = require(script.Parent.Signal)
local Methods = require(script.Parent.Methods)

local App = {}
App.__index = App

function App.new()
	local self = setmetatable({}, App)
	
	self._paths = {}
	self._methods = {}
	self._name = {}
	self._newitem = Signal.new()
	
	self.Locals = setmetatable({}, {
		__metatable = "Locked",
	})
	
	self._newitem:Connect(function(path)
		
		if self._root then
			self:_listenOnPath(path, self._root)
		end
	end)

	return self
end

function App:_newPath(path)
	assert(path, "Need a valid path")
	if self._paths[path] then
		return
	end
	
	self._paths[path] = {}
end

function App:_addToPath(path,value)
	
	if self._paths[path] then
		
		table.insert(self._paths[path], value)
		self._newitem:Fire(path)
	end
	
end

function App:_listenOnPath(path, parent)
	
	for _, method in pairs(path) do
		
		if not method._build then
			method:Build(parent)
		end
	end
end

function App:Listen(name: string | number)
	self._name = assert(name, "Expected a name!")
	if self._root or self._build then
		return
	end

	local Root = Instance.new("Folder")
	Root.Name = name

	print(self._paths)
	for _, path in pairs(self._paths) do
		
		self:_listenOnPath(path, Root)
	end

	Root.Parent = game:GetService("ReplicatedStorage")
	self._root = Root

	return Root
end

function App:_registerMethod(method)
	
	if not self._paths[method._path] then
		self:_newPath(method._path)
	end
	
	self:_addToPath(method._path,method)
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
	setmetatable(self, {__index = function()
		error("This App is destroyed!",2)
	end})
end

return App
