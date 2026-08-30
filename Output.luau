local script = [[
local TextService = game:GetService("TextService")
local from_rgb = Color3.fromRGB
local vector2 = Vector2.new
local os_date = os.date

local COLORS = {
	Default = from_rgb(255, 255, 255),
	Error = from_rgb(255, 90, 74),
	Warning = from_rgb(255, 218, 68),
	Info = from_rgb(50, 181, 255),
}

local Output = {}
Output.__index = Output

function Output.new(buffer, filter, font, fontSize)
	local self = setmetatable({}, Output)

	self.buffer = buffer
	self.filter = filter
	self.font = font
	self.fontSize = fontSize
	self.onOut = nil
	self.Paused = false
	self.showTimestamps = true -- toggle with :setShowTimestamps() / :toggleTimestamps()
	return self
end

function Output:pause()
	self.Paused = true
end

function Output:resume()
	self.Paused = false
end

function Output:isPaused()
	return self.Paused or (self.filter and self.filter.active)
end

-- Explicitly set whether timestamps are prefixed to future log entries.
function Output:setShowTimestamps(shouldShow)
	self.showTimestamps = shouldShow
end

function Output:toggleTimestamps()
	self.showTimestamps = not self.showTimestamps
	
	return self.showTimestamps
end

function Output:out(raw, tag)
	if self:isPaused() then
		return
	end
	
	local formatted = self.showTimestamps and `[{os_date("%H:%M:%S")}] {raw}` or tostring(raw)
	local color = COLORS[tag] or COLORS.Default
	
	local entry = {
		Message = formatted,
		Raw = raw,
		Type = tag,
		Color = color,
		Dims = TextService:GetTextSize(formatted, self.fontSize, self.font, vector2()),
	}
	
	self.buffer:push_back(entry)
	
	if self.onOut then
		self.onOut(entry)
	end
end

function Output:info(raw)
	self:out(raw, "Info")
end

function Output:warn(raw)
	self:out(raw, "Warning")
end

function Output:error(raw)
	self:out(raw, "Error")
end
]]

return script
