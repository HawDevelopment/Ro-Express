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

function Methods._new(type: string, path: string, callback: (any) -> any)
	local self = setmetatable({
		_type = type,
		_path = path,
		callback = callback,
	}, Methods)

	return self
end

function setAttributes(inst: Instance, type: string, path: string): Instance
	inst:SetAttribute("TYPE", type)
	inst:SetAttribute("PATH", path)
end

function Methods:Build(parent: Instance)
	local path: string = self._path:gsub("^/", "")
	local split: { [number]: string } = path:split("/")

	local curr: RemoteFunction = parent

	if #split < 1 then
		setAttributes(parent, self._type, self._path)
	else
		for i = 1, #split, 1 do
			local temp = curr:FindFirstChild(split[i])
			if temp then
				curr = temp
			else
				local inst = Instance.new("RemoteFunction")
				inst.Name = split[i]
				inst.Parent = curr

				setAttributes(inst, self._type, self._path)
				curr = inst
			end
		end
	end

	self._build = true
	return curr
end

local METHODS = "GET POST DELETE PUT ALL"

for _, str in pairs(METHODS:split(" ")) do
	Methods[str:lower()] = function(_, path, callback)
		return Methods._new(str, path, callback)
	end
end

return Methods
