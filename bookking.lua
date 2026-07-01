--[[
    SCARY BOOK COLLECTOR - DYNAMIC ESP (X-RAY)
    Optimized for Mobile (Delta, Arceus, etc.)
]]

local Player = game.Players.LocalPlayer
local BooksFolder = workspace:WaitForChild("Library"):WaitForChild("Books")

-- تخزين حالات الـ ESP (هل النوع مفعل أم لا)
local ESP_States = {}

-- إنشاء الواجهة
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "BookESP_UI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- تصميم الإطار الرئيسي
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true

-- العنوان
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "BOOK X-RAY (ESP)"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.SpecialElite
Title.TextSize = 18

-- قائمة التمرير
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollingFrame.Size = UDim2.new(1, -10, 1, -55)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 8)

-- وظيفة إضافة/إزالة الـ ESP
local function ToggleESP(typeName, state)
    for _, book in pairs(BooksFolder:GetChildren()) do
        if book.Name:match("^" .. typeName) and book:IsA("BasePart") then
            if state then
                -- إنشاء التوهج (Highlight)
                if not book:FindFirstChild("BookHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "BookHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0) -- لون أحمر
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255) -- حدود بيضاء
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- يظهر من خلف الجدران
                    hl.Parent = book
                end
            else
                -- حذف التوهج
                if book:FindFirstChild("BookHighlight") then
                    book.BookHighlight:Destroy()
                end
            end
        end
    end
end

-- وظيفة إنشاء الأزرار تلقائياً
local function CreateButtonForType(namePrefix)
    if ESP_States[namePrefix] ~= nil then return end -- منع التكرار
    
    ESP_States[namePrefix] = false
    
    local ButtonFrame = Instance.new("Frame")
    local TypeName = Instance.new("TextLabel")
    local ToggleBtn = Instance.new("TextButton")

    ButtonFrame.Parent = ScrollingFrame
    ButtonFrame.Size = UDim2.new(1, -5, 0, 40)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ButtonFrame.BorderSizePixel = 1
    ButtonFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)

    TypeName.Parent = ButtonFrame
    TypeName.Size = UDim2.new(0.7, 0, 1, 0)
    TypeName.BackgroundTransparency = 1
    TypeName.Text = "  " .. namePrefix
    TypeName.TextColor3 = Color3.fromRGB(200, 200, 200)
    TypeName.TextXAlignment = Enum.TextXAlignment.Left
    TypeName.Font = Enum.Font.SourceSansBold
    TypeName.TextSize = 14

    ToggleBtn.Parent = ButtonFrame
    ToggleBtn.Position = UDim2.new(0.7, 5, 0.1, 0)
    ToggleBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 12

    ToggleBtn.MouseButton1Click:Connect(function()
        ESP_States[namePrefix] = not ESP_States[namePrefix]
        
        if ESP_States[namePrefix] then
            ToggleBtn.Text = "ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0) -- أخضر عند التشغيل
            ToggleESP(namePrefix, true)
        else
            ToggleBtn.Text = "OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0) -- أحمر داكن عند الإطفاء
            ToggleESP(namePrefix, false)
        end
    end)

    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- اكتشاف الأنواع الحالية والمستقبلية
local function UpdateTypes()
    for _, book in pairs(BooksFolder:GetChildren()) do
        local namePrefix = book.Name:match("^(.-)_%d+$") or book.Name:match("^(.-)%d+$") or book.Name
        CreateButtonForType(namePrefix)
    end
end

UpdateTypes()
-- إذا أُضيفت كتب جديدة أثناء اللعب
BooksFolder.ChildAdded:Connect(function()
    wait(1)
    UpdateTypes()
end)

-- نظام سحب الواجهة باللمس (Mobile Optimized)
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

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
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)
