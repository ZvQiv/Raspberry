local script = [[
local Filter = {}

Filter.__index = Filter

function Filter.new()
	local self = setmetatable({}, Filter)

	self.active = false
	self.query = ""

	return self
end

function Filter:set(query)
	self.query = query or ""
	self.active = self.query ~= "" and self.query ~= "All" and self.query ~= "-a"
end

function Filter:clear()
	self.query = ""
	self.active = false
end

function Filter:run(log)
	if not self.active then
		return true
	end

	local q = self.query:lower()
	local messageMatch = log.Message:lower():find(q)
	local typeMatch = log.Type and log.Type:lower():find(q)

	return messageMatch or typeMatch
end
]]

return Filter