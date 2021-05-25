--[[
    Request Class
    HawDevelopment
    15/05/2021
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NOTFOUND = {
	Status = 404,
	Succes = false,
}

local t = require(script.Parent.t)

local Request = {}
Request.__index = Request

function FindChild(inst: Instance, split: { any }, index: number)
	local found = inst:FindFirstChild(split[index])
	if found then
		if index == #split then
			return found
		else
			return FindChild(found, split, index + 1)
		end
	end
	return nil
end

function Request.new(path: string, type: string, ...)
	assert(t.tuple(t.string, t.string)(path, type))

	local treename = path:match("[%a%d]+")
	local tree = ReplicatedStorage:FindFirstChild(treename)

	if not tree then
		return NOTFOUND
	end

	local split = (path:gsub("[%a%d]+://", "")):split("/")
	local inst: RemoteFunction | BindableFunction

	-- If the path is the root
	if split[1] == "" then
		inst = tree
	else
		inst = FindChild(tree, split, 1)
	end

	if not inst then
		return NOTFOUND
	end

	local event = inst:IsA("RemoteFunction") and "InvokeServer" or "Invoke"

	print(inst)
	print(event)
	local succ, err = pcall(inst[event], inst, type, #... < 2 and ... or table.pack(...))

	print(succ)
	print(err)

	if not succ then
		warn(("Failed to call {%s}: %s"):format(inst:GetFullName(), tostring(err)))

		return {
			Status = 500,
			Succes = false,
			Message = err,
		}
	else
		if typeof(err) ~= "table" then
			error(("Failed to call {%s}: Returned %s insted of table!"):format(inst.Name, typeof(err)))
		end

		return err
	end
end

function Request._new(path, type, player, ...)
	local self = setmetatable({}, Request)

	self.Player = player
	self.Body = #... < 2 and ... or table.pack(...)
	self.Method = type
	self.Path = path

	return self
end

function Request:param(index: string | number, default: any?)
	if type(self.Body) == "table" then
		return self.Body[index] or default
	end
end

return setmetatable({}, { __index = Request, __call = Request.new })
