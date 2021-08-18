--[[
    Response class
    HawDevelopment
    15/05/2021
--]]

--[[
	Response._new(defualt: any) -> Response
	
	Response:done() -> Response
	Response:send(...any) -> Response
	Response:status(status: number) -> Response
	
	Response.Locals: {}
--]]

local ERROR_STATUS = "45"

local Response = {}
Response.__index = Response

function Response._new(default: any)
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
		local pack = table.pack(...)
		self._param = #pack < 2 and ... or pack
	end
	return self
end

function Response:status(status: number?)
	if not self._done then
		-- Find out if it's a succes.
		local start = tostring(status):match("^%d")
		if ERROR_STATUS:find(start) then
			self._succes = false
		else
			self._succes = true
		end

		self._status = status or 200
	end
	return self
end

return Response
