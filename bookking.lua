--[[
    SCARY BOOK COLLECTOR UI - MOBILE OPTIMIZED
    Features: Draggable, Auto-Type Detection, Smart Collection
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
ScreenGui.Parent = game.CoreGui -- للعمل على المشغلات
ScreenGui.ResetOnSpawn = false

-- تصميم الإطار الرئيسي (الواجهة السوداء المرعبة)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- أسود قاتم
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 0) -- حدود حمراء غامقة
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل السحب للإصبع

-- العنوان
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "NECROMANCY FINDER"
Title.TextColor3 = Color3.fromRGB(200, 0, 0)
Title.Font = Enum.Font.SpecialElite
Title.TextSize = 18

-- إطار التمرير للأزرار
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 5)

-- وظيفة جلب الكتب
local function TeleportBooks(typeName)
    local count = 0
    for _, item in pairs(BooksFolder:GetChildren()) do
        -- التحقق إذا كان الاسم يبدأ بنوع الكتاب (مثلاً NecromancyStudies)
        if item.Name:match("^" .. typeName) then
            if item:IsA("BasePart") then
                item.CFrame = Root.CFrame + Vector3.new(0, 2, -3) -- يجلب الكتاب أمامك مباشرة
                count = count + 1
            end
        end
    end
    print("تم جلب " .. tostring(count) .. " كتب من نوع " .. typeName)
end

-- وظيفة اكتشاف الأنواع تلقائياً
local function DiscoverBookTypes()
    local types = {}
    
    for _, book in pairs(BooksFolder:GetChildren()) do
        -- استخراج الاسم بدون الرقم (مثال: يحول NecromancyStudies_8 إلى NecromancyStudies)
        local namePrefix = book.Name:match("^(.-)_%d+$") or book.Name:match("^(.-)%d+$") or book.Name
        
        if not types[namePrefix] then
            types[namePrefix] = true
            
            -- إنشاء زر لهذا النوع
            local Button = Instance.new("TextButton")
            Button.Parent = ScrollingFrame
            Button.Size = UDim2.new(1, -5, 0, 35)
            Button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            Button.BorderSizePixel = 1
            Button.BorderColor3 = Color3.fromRGB(50, 0, 0)
            Button.Text = namePrefix
            Button.Font = Enum.Font.SourceSansBold
            Button.TextSize = 14
            
            -- تأثير عند الضغط
            Button.MouseButton1Click:Connect(function()
                Button.TextColor3 = Color3.fromRGB(255, 0, 0)
                TeleportBooks(namePrefix)
                wait(0.2)
                Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            end)
            
            -- تحديث حجم التمرير
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        end
    end
end

-- تشغيل السكريبت
DiscoverBookTypes()

-- وظيفة لجعل الواجهة قابلة للسحب بسلاسة على الهاتف (Manual Drag)
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
