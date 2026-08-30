local script = [[
local TextService = game:GetService("TextService")

local udim2 = UDim2.new
local vector2 = Vector2.new
local math_max = math.max
local math_ceil = math.ceil

local Renderer = {}

Renderer.__index = Renderer

function Renderer.new(ui, pool, buffer)
	local self = setmetatable({}, Renderer)

	self.viewport = ui.Viewport
	self.layout = ui.Layout
	self.windowPadding = ui.WindowPadding

	self.pool = pool
	self.poolSize = #pool
	self.buffer = buffer

	self.dirty = false
	self.autoScroll = true
	self.font = Enum.Font.SourceSansBold
	self.fontSize = 14

	return self
end

function Renderer:setDirty(bool)
	self.dirty = bool or true
	
	return self
end

function Renderer:ensurePoolCapacity(requiredCount)
	if requiredCount <= #self.pool then
		return
	end

	for i = #self.pool + 1, requiredCount do
		local label = Instance.new("TextBox")
		label.Name = tostring(i)
		label.Parent = self.viewport
		label.BackgroundTransparency = 1
		label.Font = self.font
		label.TextSize = self.fontSize
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.Visible = false
		label.ClearTextOnFocus = false

		table.insert(self.pool, label)
	end

	self.poolSize = #self.pool
end

function Renderer:refresh(filter)
	local viewport = self.viewport
	local viewSize = viewport.AbsoluteSize
	local canvasY = viewport.CanvasPosition.Y
	local layoutPadding = self.layout.Padding.Offset
	local minRowHeight = self.fontSize + 15
	local estimatedVisibleCount = math_ceil(viewSize.Y / (minRowHeight + layoutPadding)) + 30
	
	self:ensurePoolCapacity(estimatedVisibleCount)

	local currentY = 0
	local uiIndex = 1
	local paddingHeight = -1

	local it = self.buffer:iterator()

	local log = it:next()
	while log do
		if filter:run(log) then
			local rowHeight = log.Dims.Y
			local rowBottom = currentY + rowHeight

			if rowBottom >= canvasY and currentY <= (canvasY + viewSize.Y) and uiIndex <= #self.pool then
				local label = self.pool[uiIndex]

				if label then
					if paddingHeight < 0 then
						paddingHeight = currentY
					end

					label.Text = log.Message
					label.TextColor3 = log.Color
					label.Size = udim2(1, 0, 0, rowHeight)
					label.Visible = true
					label.LayoutOrder = uiIndex + 1

					uiIndex += 1
				end
			end

			currentY += (rowHeight + layoutPadding)
		end

		log = it:next()
	end

	for i = self.poolSize, uiIndex, -1 do
		local label = self.pool[i]
		
		if label then
			label:Destroy()
			table.remove(self.pool, i)
		end
	end
	
	self.poolSize = #self.pool

	self.windowPadding.Size = udim2(1, 0, 0, math_max(0, paddingHeight))
	viewport.CanvasSize = udim2(0, 0, 0, currentY)

	if self.autoScroll then
		viewport.CanvasPosition = vector2(0, math_max(0, currentY - viewSize.Y))
	end

	self.dirty = false

	return self
end

function Renderer:bindScroll(janitor)
	janitor:add{
		self.viewport:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			local cp = self.viewport.CanvasPosition.Y
			local cs = self.viewport.CanvasSize.Y.Offset
			local vs = self.viewport.AbsoluteSize.Y

			self.autoScroll = cp >= (cs - vs)
			self.dirty = true
		end),

		self.viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self.dirty = true
		end)
	}
end
]]
return script
