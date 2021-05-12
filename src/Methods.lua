--[[
    Methods Class
    HawDevelopment
    5/11/2021
--]]

local Methods = {}
Methods.__index = Methods

Methods.Classname = "Method"

function Methods:_run(method, ...)
	return method._callback(...)
end

function Methods._new(type: string, path: string, callback: (any) -> any)
	local self = setmetatable({}, Methods)

	self._type = type
	self._path = path
	self._callback = callback

	return self
end

function Methods.setAttributes(inst: Instance, type: string, path: string): Instance
	inst:SetAttribute("TYPE", type)
	inst:SetAttribute("PATH", path)
end

function Methods.newInstance(parent: Instance, name: string, type: string): Folder
	local inst = Instance.new(type)
	inst.Name = name
	inst.Parent = parent
	return inst
end

function Methods:Build(parent: Folder)
	local path: string = self._path:gsub("^/", "")
	local split: { [number]: string } = path:split("/")

	local curr: RemoteFunction = parent

	if #split < 1 then
		Methods.setAttributes(parent, self._type, self._path)
	else
		for i = 1, #split, 1 do
			local temp = curr:FindFirstChild(split[i])
			if temp then
				curr = temp
			else
				temp = Methods.newInstance(curr, split[i], "RemoteFunction")
				Methods.setAttributes(temp, self._type, self._path)
				curr = temp
			end
		end
	end

	if curr:IsA("RemoteFunction") then
		curr.OnServerInvoke = self._callback
	end

	self._build = true
	return curr
end

function Methods.get(_, path, callback)
	path = assert(path, "Need a valid path")
	callback = assert(callback, "Need a valid callback")

	return Methods._new("GET", path, callback)
end

function Methods.post(_, path, callback)
	path = assert(path, "Need a valid path")
	callback = assert(callback, "Need a valid callback")

	return Methods._new("POST", path, callback)
end

function Methods.delete(_, path, callback)
	path = assert(path, "Need a valid path")
	callback = assert(callback, "Need a valid callback")

	return Methods._new("DELETE", path, callback)
end

return Methods
