local script = [[
return function(parent)
	local Raspberry = Instance.new("ScreenGui")
	local Console = Instance.new("Frame")
	local Viewport = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local WindowPadding = Instance.new("Frame")
	local CMD = Instance.new("TextBox")
	local UIPadding = Instance.new("UIPadding")
	local ImageLabel = Instance.new("ImageLabel")
	local Header = Instance.new("TextButton")
    local UIDragDetector = Instance.new("UIDragDetector")
    local DragButton = Instance.new("TextButton")
	
	Raspberry.Name = "Raspberry"
	Raspberry.Parent = parent
	Raspberry.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Raspberry.IgnoreGuiInset = true

	Console.Name = "Console"
	Console.Parent = Raspberry
	Console.Active = true
	Console.AnchorPoint = Vector2.new(0.5, 0.5)
	Console.BackgroundColor3 = Color3.fromRGB(40, 45, 50)
	Console.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Console.BorderSizePixel = 0
	Console.Position = UDim2.new(0.5, 0, 0.5, 0)
	Console.Size = UDim2.new(0, 927, 0, 450)
	Console.ZIndex = 0
	Console.BackgroundTransparency = 0
	
	DragButton.Name = 'DragMe' 
	DragButton.Position = UDim2.new(1, 0, 1, 0)
    DragButton.Size = UDim2.new(0, 15, 0, 15)
    DragButton.Parent = Console
	DragButton.AnchorPoint = Vector2.new(1, 1)
	DragButton.Text = ""
	DragButton.BorderSizePixel = 0
	DragButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	DragButton.ZIndex = 4
	
	UIDragDetector.Name = "UIDragDetector"
	UIDragDetector.Parent = Console
	UIDragDetector.ReferenceUIInstance = Console

	Viewport.Name = "Viewport"
	Viewport.Parent = Console
	Viewport.Active = true
	Viewport.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Viewport.BackgroundTransparency = 1.000
	Viewport.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Viewport.BorderSizePixel = 0
	Viewport.LayoutOrder = 1
	Viewport.Position = UDim2.new(0, 0, 0, 20)
	Viewport.Size = UDim2.new(1, 0, 1, -35)
	Viewport.ZIndex = 2
	Viewport.BottomImage = "rbxassetid://1195495135"
	Viewport.CanvasSize = UDim2.new(0, 0, 0, 8000)
	Viewport.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	Viewport.MidImage = "rbxassetid://1195495135"
	Viewport.ScrollBarThickness = 5
	Viewport.TopImage = "rbxassetid://1195495135"

	UIListLayout.Parent = Viewport
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 2)

	WindowPadding.Name = "WindowPadding"
	WindowPadding.Parent = Viewport
	WindowPadding.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WindowPadding.BackgroundTransparency = 1.000
	WindowPadding.BorderColor3 = Color3.fromRGB(0, 0, 0)
	WindowPadding.BorderSizePixel = 0
	WindowPadding.Size = UDim2.new(1, 0, 0, 0)
	WindowPadding.LayoutOrder = 1
	
	CMD.Name = "CMD"
	CMD.Parent = Console
	CMD.AnchorPoint = Vector2.new(0, 1)
	CMD.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	CMD.BorderColor3 = Color3.fromRGB(0, 0, 0)
	CMD.BorderSizePixel = 0
	CMD.LayoutOrder = 1
	CMD.Position = UDim2.new(0, 0, 1, 0)
	CMD.Size = UDim2.new(1, -15, 0, 15)
	CMD.ZIndex = 2
	CMD.ClearTextOnFocus = false
	CMD.Font = Enum.Font.SourceSansBold
	CMD.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
	CMD.PlaceholderText = "CMD"
	CMD.Text = ""
	CMD.TextColor3 = Color3.fromRGB(255, 255, 255)
	CMD.TextSize = 14.000
	CMD.TextXAlignment = Enum.TextXAlignment.Left

	UIPadding.Parent = CMD
	UIPadding.PaddingBottom = UDim.new(0, 3)
	UIPadding.PaddingLeft = UDim.new(0, 2)
	UIPadding.PaddingRight = UDim.new(0, 2)
	UIPadding.PaddingTop = UDim.new(0, 2)

	ImageLabel.Parent = Console
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0, 0, 0, 20)
	ImageLabel.Size = UDim2.new(1, 0, 1, -35)
	ImageLabel.ZIndex = 0
	ImageLabel.Image = getcustomasset('test.jpg')
	ImageLabel.ScaleType = Enum.ScaleType.Crop
	ImageLabel.ImageTransparency = 0
	
	Header.Name = "Header"
	Header.Parent = Console
	Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Header.BorderSizePixel = 0
	Header.LayoutOrder = 1
	Header.Size = UDim2.new(1, 0, 0, 20)
	Header.ZIndex = 3
	Header.AutoButtonColor = false
	Header.Font = Enum.Font.SourceSansBold
	Header.Text = " <font color=\"#ff5500\" size=\"16\"><b>ラズベリー</b></font>  <font size=\"14\"><b>Console</b></font>"
	Header.TextColor3 = Color3.fromRGB(255, 255, 255)
	Header.TextSize = 13.000
	Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Interactable = false
	Header.RichText = true
	
	return {
		Root = Raspberry,
		Viewport = Viewport,
		CMD = CMD,
		Layout = UIListLayout,
		WindowPadding = WindowPadding,
		DragButton = DragButton,
		Console = Console,
	}
end
]]
return script
