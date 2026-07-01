--[[
    SCARY BOOK COLLECTOR UI - FIXED PHYSICS
    تحسين: إسقاط الكتب من الأعلى بشكل عشوائي وإلغاء التثبيت
]]

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local BooksFolder = workspace.Library.Books

-- إنشاء الواجهة (GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "ScaryBookGui"
ScreenGui.Parent = game.CoreGui 
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Active = true

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "NECROMANCY FINDER"
Title.TextColor3 = Color3.fromRGB(200, 0, 0)
Title.Font = Enum.Font.SpecialElite
Title.TextSize = 18

ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 5)

-- وظيفة جلب الكتب المحسنة
local function TeleportBooks(typeName)
    local count = 0
    for _, item in pairs(BooksFolder:GetChildren()) do
        if item.Name:match("^" .. typeName) then
            if item:IsA("BasePart") then
                -- 1. إلغاء التثبيت لكي يتحرك الكتاب
                item.Anchored = false
                
                -- 2. جعل الكتاب قابل للتصادم لكي لا يسقط تحت الأرض
                item.CanCollide = true
                
                -- 3. حساب موقع عشوائي حول اللاعب (فوق الرأس قليلاً)
                local randomX = math.random(-3, 3) -- إزاحة عشوائية يميناً ويساراً
                local randomZ = math.random(-3, 3) -- إزاحة عشوائية أماماً وخلفاً
                local dropHeight = 5 -- الارتفاع الذي ستسقط منه الكتب
                
                item.CFrame = Root.CFrame * CFrame.new(randomX, dropHeight, randomZ)
                
                count = count + 1
                -- تأخير بسيط جداً بين كل كتاب لمنع الانفجار الفيزيائي
                task.wait(0.05)
            end
        end
    end
    print("تم إسقاط " .. tostring(count) .. " كتب من نوع " .. typeName)
end

-- وظيفة اكتشاف الأنواع تلقائياً
local function DiscoverBookTypes()
    local types = {}
    for _, book in pairs(BooksFolder:GetChildren()) do
        local namePrefix = book.Name:match("^(.-)_%d+$") or book.Name:match("^(.-)%d+$") or book.Name
        
        if not types[namePrefix] then
            types[namePrefix] = true
            
            local Button = Instance.new("TextButton")
            Button.Parent = ScrollingFrame
            Button.Size = UDim2.new(1, -5, 0, 35)
            Button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            Button.Text = namePrefix
            Button.Font = Enum.Font.SourceSansBold
            Button.TextSize = 14
            
            Button.MouseButton1Click:Connect(function()
                Button.TextColor3 = Color3.fromRGB(255, 0, 0)
                TeleportBooks(namePrefix)
                task.wait(0.2)
                Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            end)
            
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        end
    end
end

DiscoverBookTypes()

-- نظام السحب للموبايل (Manual Drag Fix)
local UserInputService = game:GetService("UserInputService")
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

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)
