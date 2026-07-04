--[[
    SCARY BOOK COLLECTOR - RESEARCHER V3
    1. Toggle ON Pick Mode
    2. Click/Touch a book to capture its type
    3. Press SELECT to apply ESP to all books of that type
    4. Distance Tags + Random TP + Reset
]]

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LibraryBooks = workspace:WaitForChild("Library"):WaitForChild("Books")

-- متغيرات التحكم
local PickModeActive = false
local CapturedTypeName = ""
local HighlightedBooks = {}

-- إعداد الواجهة (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedBookTool"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
Title.Text = "BOOK RESEARCHER PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- زر تشغيل وضع الالتقاط (ON/OFF)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
ToggleBtn.Text = "PICK MODE: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = MainFrame

-- نص لعرض اسم الكتاب الذي تم التقاطه
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 25)
InfoLabel.Position = UDim2.new(0.05, 0, 0.38, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Captured: [None]"
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
InfoLabel.Font = Enum.Font.SourceSansItalic
InfoLabel.TextSize = 14
InfoLabel.Parent = MainFrame

-- زر SELECT (تطبيق على الكل)
local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(0.6, 0, 0, 40)
SelectBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
SelectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
SelectBtn.Text = "SELECT (Apply All)"
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.Font = Enum.Font.SourceSansBold
SelectBtn.Parent = MainFrame

-- زر التلي بورت (مربع صغير)
local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(0.25, 0, 0, 40)
TPBtn.Position = UDim2.new(0.7, 0, 0.55, 0)
TPBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
TPBtn.Text = "TP"
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.Font = Enum.Font.SourceSansBold
TPBtn.Parent = MainFrame

-- زر Reset
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.9, 0, 0, 30)
ResetBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ResetBtn.Text = "RESET EVERYTHING"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.Parent = MainFrame

-----------------------------------------------------------
-- الوظائف البرمجية
-----------------------------------------------------------

local function GetCleanName(name)
    return name:gsub("[%d_]+$", "")
end

-- مسح الـ ESP
local function ClearESP()
    for _, item in pairs(HighlightedBooks) do
        if item.obj:FindFirstChild("BookHighlight") then item.obj.BookHighlight:Destroy() end
        if item.obj:FindFirstChild("DistanceTag") then item.obj.DistanceTag:Destroy() end
    end
    HighlightedBooks = {}
end

-- تشغيل/إطفاء وضع الالتقاط
ToggleBtn.MouseButton1Click:Connect(function()
    PickModeActive = not PickModeActive
    if PickModeActive then
        ToggleBtn.Text = "PICK MODE: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        ToggleBtn.Text = "PICK MODE: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    end
end)

-- التقاط الكتاب عند اللمس
Mouse.Button1Down:Connect(function()
    -- منع الضغط إذا كان فوق الواجهة
    local objects = Player.PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
    for _, obj in pairs(objects) do
        if obj:IsDescendantOf(MainFrame) then return end
    end

    if PickModeActive then
        local target = Mouse.Target
        if target and target:IsDescendantOf(LibraryBooks) then
            CapturedTypeName = GetCleanName(target.Name)
            InfoLabel.Text = "Captured: " .. CapturedTypeName
        end
    end
end)

-- تطبيق الـ ESP على كل الكتب من النوع الملتقط
SelectBtn.MouseButton1Click:Connect(function()
    if CapturedTypeName == "" then return end
    ClearESP()
    
    for _, book in pairs(LibraryBooks:GetChildren()) do
        if GetCleanName(book.Name) == CapturedTypeName and book:IsA("BasePart") then
            -- X-Ray (Highlight)
            local hl = Instance.new("Highlight")
            hl.Name = "BookHighlight"
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = book

            -- مسافة (Distance Tag)
            local bgui = Instance.new("BillboardGui")
            bgui.Name = "DistanceTag"
            bgui.Size = UDim2.new(0, 80, 0, 30)
            bgui.AlwaysOnTop = true
            bgui.ExtentsOffset = Vector3.new(0, 3, 0)
            bgui.Parent = book

            local label = Instance.new("TextLabel")
            label.Parent = bgui
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 16

            table.insert(HighlightedBooks, {obj = book, label = label})
        end
    end
end)

-- تحديث أرقام المسافة
RunService.RenderStepped:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local myPos = char.HumanoidRootPart.Position
        for _, item in pairs(HighlightedBooks) do
            if item.obj and item.obj.Parent then
                local dist = math.floor((item.obj.Position - myPos).Magnitude)
                item.label.Text = dist .. "m"
            end
        end
    end
end)

-- الانتقال لكتاب عشوائي
TPBtn.MouseButton1Click:Connect(function()
    if #HighlightedBooks > 0 then
        local randomEntry = HighlightedBooks[math.random(1, #HighlightedBooks)]
        if randomEntry and randomEntry.obj then
            Player.Character.HumanoidRootPart.CFrame = randomEntry.obj.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- تصفير كل شيء
ResetBtn.MouseButton1Click:Connect(function()
    ClearESP()
    CapturedTypeName = ""
    InfoLabel.Text = "Captured: [None]"
    PickModeActive = false
    ToggleBtn.Text = "PICK MODE: OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
end)

-- سحب الواجهة باللمس
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
