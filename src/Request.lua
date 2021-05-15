--[[
    Request Class
    HawDevelopment
    15/05/2021
--]]

local Request = {}
Request.__index = Request

function Request._new(path, type, paramstype, ...)
	local self = setmetatable({}, Request)

	self._paramstype = paramstype
	self.Body = paramstype == "table" and table.pack(...)[1] or table.pack(...)
	self.Method = type
	self.Path = path

	return self
end

function Request:param(index: string | number, default: any?)
	if self._paramstype == "table" then
		return self.Body[index] or default
	end
	return default
end

--TODO: Add requests to app!

return Request
