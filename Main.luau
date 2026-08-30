--// Initialize Raspberry Console API:
local script = [[
local userInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local path = function(name)
	return string.format('Raspberry/%s.txt', name)
end

--// CoreModules:
local Interface     = loadfile(path('Interface'))()
local Renderer      = loadfile(path('Renderer'))()
local Filter        = loadfile(path('Filter'))()
local Output        = loadfile(path('Output'))()
local SystemLogger  = loadfile(path('SystemLogger'))()

--// Command Modules:
local CommandRegistry = loadfile(path('CommandReg'))()
local CommandParser   = loadfile(path('CommandParser'))()
local SetupCommands   = loadfile(path('Commands'))()

--// UtilModules:
local CircularBuffer = loadfile(path('CircularBuffer'))()
local Janitor        = loadfile(path('Janitor'))()
local ResizeModule   = loadfile(path('Resize'))()
local UIPool         = loadfile(path('UIPool'))()
local CommandHandler = loadfile(path('CommandHandler'))()

--// Constants:
local POOL_SIZE = 30
local FONT      = Enum.Font.SourceSansBold
local FONT_SIZE = 14
local MIN_SIZE  = Vector2.new(700, 350)
local MAX_SIZE  = Vector2.new(2000, 1000)

--// Private Helper Function:
local function initializeInternalState(self)
	self.buffer   = CircularBuffer.new(self.buffer_size)
	self.registry = CommandRegistry.new()
	self.janitor  = Janitor.new()
	self.filter   = Filter.new()
	self.systemLogger = SystemLogger.new()
	self.parser   = CommandParser.new(self.registry, self.systemLogger)

	self.output   = nil
	self.renderer = nil
	self.mounted  = false
end

--// Main API Table Definition:
local Raspberry = {}

Raspberry.__index = Raspberry

--// Constructor: Initializes a new Raspberry console instance with an optional maximum buffer size
function Raspberry.new(maxSize)
	local self = setmetatable({}, Raspberry)

	self.buffer_size = maxSize or 100
	self.font     = FONT
	self.fontSize = FONT_SIZE

	initializeInternalState(self)

	return self
end

-- Mounts the console interface onto a target parent object in the UI hierarchy
function Raspberry:mount(parent)
	local systemlog = self.systemLogger
	local buffer = self.buffer
	local filter = self.filter
	local font = self.font
	local fontsize = self.fontSize
	local janitor = self.janitor
	local registry = self.registry
	local parser = self.parser
	
	if self.mounted then
		return systemlog:warn("Raspberry Console is already mounted.")
	end
	
    -- Setup UI and components:
	local ui = Interface(parent)
	local pool = UIPool.create(ui, POOL_SIZE, font, fontsize)
	local renderer = Renderer.new(ui, pool, buffer)
	renderer:bindScroll(janitor)
	
	self.renderer, self.output = renderer, Output.new(buffer, filter, font, fontsize)

	-- Setup system logging and commands:
	systemlog:init(buffer, font, fontsize, function(entry)
		local dirty = renderer:setDirty(true)

		dirty:refresh(filter)
	end)

	CommandHandler.new(ui, parser, janitor, function(err) 
		systemlog:error(err) 
	end)

	SetupCommands(registry, buffer, renderer, filter, self.output, systemlog, self)

	-- Setup UI Rendering:
	janitor:add{
		RunService.Heartbeat:Connect(function()
			if renderer.dirty then
				renderer:refresh(filter)
			end
		end)
	}

	self.output.onOut = function()
		renderer:setDirty()
	end

	-- Setup UI Resizing:
	ResizeModule.new(ui, janitor, userInputService, RunService, MIN_SIZE, MAX_SIZE)

	self.mounted = true
	self.ui = ui.Root
end

for _, level in ipairs({ "out", "info", "warn", "error" }) do
	Raspberry[level] = function(self, raw, tag)
		if self.output then 
			self.output[level](self.output, raw, tag) 
		end

		return nil
	end
end

function Raspberry:destroy()
	if not self.mounted then return end

	self.janitor:cleanup()

	if self.ui then
		self.ui:Destroy()
		self.ui = nil
	end

	self.buffer:reset()
	self.filter:clear()

	self.renderer = nil
	self.output = nil
	self.mounted = false
end

function Raspberry:restart(parent)
	self:destroy()
	initializeInternalState(self)
	self:mount(parent)
end

function Raspberry:toggle_timestamps()
	self.output:toggleTimestamps()
end

return Raspberry
]]
return script
