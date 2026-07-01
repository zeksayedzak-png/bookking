--[[
    SCARY BOOK COLLECTOR - PRO ESP (X-RAY)
    - Alphabetical Sorting (A-Z)
    - Enhanced Mobile Dragging
    - Optimized for Delta/Arceus/Vega X
]]

local Player = game.Players.LocalPlayer
local BooksFolder = workspace:WaitForChild("Library"):WaitForChild("Books")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الواجهة
ScreenGui.Name = "BookESP_Pro"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = false -- سنستخدم كود سحب مخصص للموبايل أسفل السكريبت

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BOOK X-RAY (A-Z)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SpecialElite
Title.TextSize = 18

ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.Name -- هذا يضمن الترتيب الأبجدي تلقائياً

local ESP_States = {}

-- وظيفة تشغيل/إيقاف الـ X-Ray
local function ToggleESP(typeName, state)
    for _, book in pairs(BooksFolder:GetChildren()) do
        -- التحقق من اسم الكتاب (يتطابق مع النوع)
        if book.Name:match("^" .. typeName) and book:IsA("BasePart") then
            if state then
                if not book:FindFirstChild("BookHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "BookHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = book
                end
            else
                if book:FindFirstChild("BookHighlight") then
                    book.BookHighlight:Destroy()
                end
            end
        end
    end
end

-- وظيفة إنشاء الأزرار
local function CreateButton(namePrefix)
    if ScrollingFrame:FindFirstChild(namePrefix) then return end
    
    ESP_States[namePrefix] = false
    
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = namePrefix -- لضمان الترتيب الأبجدي بواسطة UIListLayout
    ButtonFrame.Parent = ScrollingFrame
    ButtonFrame.Size = UDim2.new(1, -5, 0, 45)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ButtonFrame.BorderSizePixel = 1
    ButtonFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)

    local TypeName = Instance.new("TextLabel")
    TypeName.Parent = ButtonFrame
    TypeName.Size = UDim2.new(0.65, 0, 1, 0)
    TypeName.BackgroundTransparency = 1
    TypeName.Text = "  " .. namePrefix
    TypeName.TextColor3 = Color3.fromRGB(220, 220, 220)
    TypeName.TextXAlignment = Enum.TextXAlignment.Left
    TypeName.Font = Enum.Font.SourceSansBold
    TypeName.TextSize = 14

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ButtonFrame
    ToggleBtn.Position = UDim2.new(0.65, 5, 0.15, 0)
    ToggleBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 14

    ToggleBtn.MouseButton1Click:Connect(function()
        ESP_States[namePrefix] = not ESP_States[namePrefix]
        if ESP_States[namePrefix] then
            ToggleBtn.Text = "ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            ToggleESP(namePrefix, true)
        else
            ToggleBtn.Text = "OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
            ToggleESP(namePrefix, false)
        end
    end)

    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- تحديث القائمة
local function RefreshList()
    for _, book in pairs(BooksFolder:GetChildren()) do
        -- استخراج النوع (حذف الأرقام والزيادات من الاسم)
        local namePrefix = book.Name:match("^(.-)_%d+$") or book.Name:match("^(.-)%d+$") or book.Name
        CreateButton(namePrefix)
    end
end

RefreshList()
BooksFolder.ChildAdded:Connect(function()
    task.wait(0.5)
    RefreshList()
end)

-- ==========================================
-- نظام سحب الواجهة المطور للموبايل (Touch Friendly)
-- ==========================================
local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

print("Book ESP Script Loaded - A-Z Sorted")
