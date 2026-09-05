local UIPool = {}

function UIPool.create(ui, poolSize, font, fontSize)
	local pool = {}
	for i = 1, poolSize do
		local label = Instance.new("TextBox")
		label.Name = tostring(i)
		label.Parent = ui.Viewport
		label.BackgroundTransparency = 1
		label.Font = font
		label.TextSize = fontSize
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.Visible = false
		label.ClearTextOnFocus = false
		label.LayoutOrder = i
		
		pool[i] = label
	end
	return pool
end
return UIPool
