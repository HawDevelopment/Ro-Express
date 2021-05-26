--[[
    Methods Class
    HawDevelopment
    5/11/2021
--]]

--[[
	Method._new(type: string, path: string, callback: (Request, Response)) -> Method
	Methods.__setAttributes(inst: Instance, type: string, path: string)
	
	Method.METHOD(path: string, callback: (Request, Response))
	Method.all(path: string, callback: (Request, Response))
	
	Methods:Build(parent: Instance) -> Instance
--]]
local Methods = {}
Methods.__index = Methods

Methods.Classname = "Method"

function Methods:_run(method, ...)
	return method.callback(...)
end

function Methods._new(type: string, path: string, callback: (any) -> any)
	local self = setmetatable({}, Methods)

	self._type = type
	self._path = path
	self.callback = callback

	return self
end

function Methods.__setAttributes(inst: Instance, type: string, path: string): Instance
	inst:SetAttribute("TYPE", type)
	inst:SetAttribute("PATH", path)
end

function Methods:Build(parent: Instance)
	local path: string = self._path:gsub("^/", "")
	local split: { [number]: string } = path:split("/")

	local curr: RemoteFunction = parent

	if #split < 1 then
		Methods.__setAttributes(parent, self._type, self._path)
	else
		for i = 1, #split, 1 do
			local temp = curr:FindFirstChild(split[i])
			if temp then
				curr = temp
			else
				local inst = Instance.new("RemoteFunction")
				inst.Name = split[i]
				inst.Parent = curr

				Methods.__setAttributes(inst, self._type, self._path)
				curr = inst
			end
		end
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

function Methods.put(_, path, callback)
	path = assert(path, "Need a valid path")
	callback = assert(callback, "Need a valid callback")

	return Methods._new("PUT", path, callback)
end

function Methods.all(_, path, callback)
	path = assert(path, "Need a valid path")
	callback = assert(callback, "Need a valid callback")

	return Methods._new("ALL", path, callback)
end

return Methods
