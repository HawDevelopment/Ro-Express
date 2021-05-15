--[[
    Response class
    HawDevelopment
    15/05/2021
--]]

local Response = {}
Response.__index = Response

function Response._new(default)
	local self = setmetatable({}, Response)

	self.Locals = {}
	self._param = default or {}

	self._status = 200
	self._succes = true

	self._done = false

	return self
end

function Response:done()
	self._done = true
	return self
end

function Response:send(...)
	if not self._done then
		self._params = table.pack(...)
	end

	return self
end

function Response:status(status: number)
	if not self._done then
		local start = tostring(status):match("^%d")
		if start == "4" or start == "5" then
			self._succes = false
		elseif start == "2" then
			self._succes = true
		end

		self._status = status or 200
	end
	return self
end

return Response
