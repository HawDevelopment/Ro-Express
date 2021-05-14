--[[
    App Class
    HawDevelopment
    5/11/2021
--]]

--local Signal = require(script.Parent.Signal)
local Methods = require(script.Parent.Methods)
local Router = require(script.Parent.Router)

local App = {}
App.__index = App

function App.new()
	local self = setmetatable({}, App)

	self._paths = {}
	self._router = Router._new(false, true)
	--self._newitem = Signal.new()

	--self._newitem:Connect(function(path)
	--	self._router:Handle(path)
	--end)

	return self
end

function App:_NewPath(path, parentpath)
	assert(path, "Need a valid path")

	table.insert(self._paths, path)
	self._router:_NewPath(path, parentpath)
end

function App:_AddPath(path, value, type)
	assert(typeof(value) == "table", "Need a valid value!")

	self._router:_AddPath(path, value, type)
end

function App:_ListenPath(path, inst)
	self._router:_BuildPath(path, inst)
end

function App:Listen(name: string | number)
	assert(not self._root, "Cannot build an app already built!")
	self._name = assert(name, "Expected a name!")

	local Root = Instance.new("Folder")
	self._root = Root
	Root.Name = name

	print(self._router)
	for _, path in pairs(self._paths) do
		self:_ListenPath(path, Root)
	end

	Root.Parent = game:GetService("ReplicatedStorage")

	return Root
end

function App:_RegisterValue(tab: { any }, type)
	local path = tab._path

	if not self._paths[path] then
		self:_NewPath(path, string.gsub(path, string.match(path, "/[%a%d]+$"), ""))
	end

	self:_AddPath(path, tab, type)
end

function App:get(...)
	self:_RegisterValue(Methods.get(self, ...), "Method")
end

function App:post(...)
	self:_RegisterValue(Methods.post(self, ...), "Method")
end

function App:delete(...)
	self:_RegisterValue(Methods.delete(self, ...), "Method")
end

function App:use(path: string, inst: any)
	assert(path, "Need a valid path!")

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

return App
