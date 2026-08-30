local script = [[
local ResizeAndMinimizeModule = {}

ResizeAndMinimizeModule.__index = ResizeAndMinimizeModule

function ResizeAndMinimizeModule.new(ui, janitor, userInputService, runService, minSize, maxSize)
	local self = setmetatable({}, ResizeAndMinimizeModule)
	self.ui = ui
	self.janitor = janitor
	self.userInputService = userInputService
	self.runService = runService
	self.MIN_SIZE = minSize 
	self.MAX_SIZE = maxSize
	self.isMinimized = false
	self.originalHeight = ui.Console.AbsoluteSize.Y
	self.originalWidth = ui.Console.AbsoluteSize.X
	self.dragging = false
	self.startMousePos = nil
	self.startSize = ui.Console.AbsoluteSize
	self.startPos = ui.Console.Position
	self.connection = nil
	
	self:init()

	return self
end

function ResizeAndMinimizeModule:init()
	local dragButton = self.ui.DragButton
	local janitor = self.janitor

	janitor:add{dragButton.MouseButton2Down:Connect(function()
		self:Minimize()
	end)}
	
	janitor:add{dragButton.MouseButton1Down:Connect(function()
		self:Resize()
	end)}
	
	janitor:add{self.userInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.dragging = false

			if self.connection then
				self.connection:Disconnect()
				self.connection = nil
			end
		end
	end)}
end

function ResizeAndMinimizeModule:Minimize()
	local ui = self.ui

	self.isMinimized = not self.isMinimized

	local currentSize = ui.Console.AbsoluteSize
	local currentPos = ui.Console.Position
	
	if self.isMinimized then
		self.originalWidth, self.originalHeight = currentSize.X, currentSize.Y

		local widthDiff = self.originalWidth - self.MIN_SIZE.X
		local heightDiff = self.originalHeight - 35
		
		ui.Console.Size = UDim2.new(0, self.MIN_SIZE.X, 0, 35)
		ui.Console.Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset - (widthDiff / 2), currentPos.Y.Scale, currentPos.Y.Offset - (heightDiff / 2))
	else
		local widthDiff = self.originalWidth - self.MIN_SIZE.X
		local heightDiff = self.originalHeight - 35
		
		ui.Console.Size = UDim2.new(0, self.originalWidth, 0, self.originalHeight)
		ui.Console.Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset + (widthDiff / 2), currentPos.Y.Scale, currentPos.Y.Offset + (heightDiff / 2))
	end
end

function ResizeAndMinimizeModule:Resize()
	if self.isMinimized then
		return
	end
	
	local ui = self.ui
	
	self.dragging = true
	self.startMousePos = self.userInputService:GetMouseLocation()
	self.startSize = ui.Console.AbsoluteSize
	self.startPos = ui.Console.Position

	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	self.connection = self.userInputService.InputChanged:Connect(function(input)
		if not self.dragging then
			return
		end
		
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local currentMousePos = self.userInputService:GetMouseLocation()
		local delta = currentMousePos - self.startMousePos

		local targetWidth = self.startSize.X + delta.X
		local targetHeight = self.startSize.Y + delta.Y
		local newWidth = math.clamp(targetWidth, self.MIN_SIZE.X, self.MAX_SIZE.X)
		local newHeight = math.clamp(targetHeight, self.MIN_SIZE.Y, self.MAX_SIZE.Y)

		ui.Console.Size = UDim2.new(0, newWidth, 0, newHeight)

		local widthDelta = newWidth - self.startSize.X
		local heightDelta = newHeight - self.startSize.Y
		
		ui.Console.Position = UDim2.new(self.startPos.X.Scale, self.startPos.X.Offset + (widthDelta / 2), self.startPos.Y.Scale, self.startPos.Y.Offset + (heightDelta / 2))
	end)
end
]]
return ResizeAndMinimizeModule