local script = [[
local TextService = game:GetService("TextService")
local os_date = os.date
local vector2 = Vector2.new
local from_rgb = Color3.fromRGB

local SYSTEM_COLORS = {
	System = from_rgb(200, 100, 255),
	Info = from_rgb(50, 181, 255),
	Warning = from_rgb(255, 218, 68),
	Error = from_rgb(255, 90, 74),
}

local InternalLogger = {}

InternalLogger.__index = InternalLogger

function InternalLogger.new()
	return setmetatable({
		buffer = nil,
		font = nil,
		fontSize = nil,
		onOut = nil,
	}, InternalLogger)
end

function InternalLogger:init(targetBuffer, targetFont, targetSize, callback)
	self.buffer = targetBuffer
	self.font = targetFont
	self.fontSize = targetSize
	self.onOut = callback
end

function InternalLogger:out(raw, tag)
	if not self.buffer then
		return
	end
	
	local tagName = tag or "System"
	local formatted = `[SYSTEM] [{os_date("%H:%M:%S")}] {raw}`
	local color = SYSTEM_COLORS[tagName] or SYSTEM_COLORS.System
	local entry = {
		Message = formatted,
		Raw = raw,
		Type = tagName,
		Color = color,
		Dims = TextService:GetTextSize(formatted, self.fontSize, self.font, vector2()),
	}
	
	self.buffer:push_back(entry)
	
	if self.onOut then
		self.onOut(entry)
	end
end

function InternalLogger:info(raw)
	self:out(raw, "Info")
end

function InternalLogger:warn(raw)
	self:out(raw, "Warning")
end

function InternalLogger:error(raw)
	self:out(raw, "Error")
	
	return nil
end
return InternalLogger
]]
return script
