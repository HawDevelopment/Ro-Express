--[[
    Request Class
    HawDevelopment
    15/05/2021
--]]

--[[
	Request.new(path: string, type: string, ...any) -> {any}
	
	Request.get(path: string, ...any) -> {any}
	Request.post(path: string, ...any) -> {any}
	Request.delete(path: string, ...any) -> {any}
	Request.put(path: string, ...any) -> {any}
	
	Request._new(path: string, type: string, player: Player, ...any) -> Request
	
	Request:param(index: name | number)
	
	Request.Player: Player
	Request.Body: any
	Request.Method: string
	Request.Path: string
--]]
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IS_SERVER = RunService:IsServer()

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

local function MatchOrError(str: string, match: string)
	return str:match(match) or error("Invalid path: " .. str, 3)
end

function Request.new(path: string, type: string, ...)
	assert(t.tuple(t.string, t.string)(path, type))

	-- Find the tree
	local tree = ReplicatedStorage:WaitForChild(MatchOrError(path, "[%a%d]+"))
	assert(tree, "Invalid root: " .. path)

	local split = (path:gsub("[%a%d]+://", "")):split("/")
	local inst: RemoteFunction | BindableFunction

	-- If the path is the root
	if split[1] == "" then
		inst = tree
	else
		inst = FindChild(tree, split, 1)
	end
	assert(inst, "Invalid path: " .. path)

	local event
	if inst:IsA("RemoteFunction") then
		event = IS_SERVER and "InvokeClient" or "InvokeServer"
	elseif inst:IsA("BindableFunction") then
		event = "Invoke"
	end

	local pack = table.pack(...)
	local succ, err
	if IS_SERVER then
		local plr = table.remove(pack, 1)
		if not plr or not plr:IsA("Player") then
			error("Bad argument: Expected Player to be argument three!", 2)
		end

		succ, err = pcall(inst[event], inst, plr, type, #pack < 2 and ... or pack)
	else
		succ, err = pcall(inst[event], inst, type, #pack < 2 and ... or pack)
	end

	if not succ then
		warn(debug.traceback(("Failed to call {%s}: %s"):format(inst:GetFullName(), tostring(err)), 2))

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

function Request.get(path: string, ...)
	return Request.new(path, "GET", ...)
end

function Request.post(path: string, ...)
	return Request.new(path, "POST", ...)
end

function Request.delete(path: string, ...)
	return Request.new(path, "DELETE", ...)
end

function Request.put(path: string, ...)
	return Request.new(path, "PUT", ...)
end

-- Used to create the request object used in callbacks.
function Request._new(path, type, player, ...)
	local self = setmetatable({}, Request)

	self.Player = player
	local pack = table.pack(...)
	self.Body = #pack < 2 and ... or pack
	self.Method = type
	self.Path = path

	return self
end

function Request:param(index: string | number, default: any?)
	if type(self.Body) == "table" then
		return self.Body[index] or default
	end
end

return setmetatable({}, {
	__index = Request,
	__call = function(_, ...)
		return Request.new(...)
	end,
})
