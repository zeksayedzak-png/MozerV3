-- ===========================================
-- 🔬 MOZER HUB v3 - REMOTE LAB + BUY
-- ⚡ صفحة Remote (كل الـ Remotes) + صفحة Buy (Method 1&6)
-- 📱 واجهة واحدة | تنقل سريع | لا إعادة تحميل
-- ===========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- ===========================================
-- المتغيرات العامة
-- ===========================================
local allRemotes = {}
local remoteButtons = {}  -- حفظ أزرار Select لكل Remote (للتحكم في لونها)
local selectedRemote = nil
local selectedRemoteRef = nil
local selectedRemoteName = "None"
local currentTab = "Information"

-- ===========================================
-- 1. جلب جميع الـ Remotes
-- ===========================================
local function fetchAllRemotes()
    allRemotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(allRemotes, {
                name = obj.Name,
                path = obj:GetFullName(),
                className = obj.ClassName,
                ref = obj
            })
        end
    end
    return allRemotes
end

-- ===========================================
-- 2. Method 1 المعدل (مفتوح - بلا حدود)
-- ===========================================
local function executeMethod1()
    if not selectedRemoteRef then
        print("❌ لا يوجد Remote محدد")
        return
    end
    
    local payload = {
        action = "purchase",
        gamepassId = 123456,
        playerId = plr.UserId,
        timestamp = os.time(),
        signature = HttpService:GenerateGUID(false)
    }
    
    if selectedRemoteRef:IsA("RemoteEvent") then
        pcall(function() 
            selectedRemoteRef:FireServer(payload)
            print("🔪 [Method 1] تم الإرسال إلى: " .. selectedRemoteName)
        end)
    elseif selectedRemoteRef:IsA("RemoteFunction") then
        pcall(function() 
            local response = selectedRemoteRef:InvokeServer(payload)
            print("🔪 [Method 1] تم الاستدعاء، الرد: " .. tostring(response))
        end)
    end
end

-- ===========================================
-- 3. Method 6 المعدل (مفتوح - بلا حدود)
-- ===========================================
local function executeMethod6()
    if not selectedRemoteRef then
        print("❌ لا يوجد Remote محدد")
        return
    end
    
    local payload = {
        action = "replay",
        signature = tostring(os.time()),
        data = { test = true, value = 1 }
    }
    
    if selectedRemoteRef:IsA("RemoteEvent") then
        pcall(function()
            selectedRemoteRef:FireServer(payload)
            selectedRemoteRef:FireServer({payload})
            selectedRemoteRef:FireServer(payload, 123)
            print("🔄 [Method 6] تم إعادة الإرسال إلى: " .. selectedRemoteName)
        end)
    elseif selectedRemoteRef:IsA("RemoteFunction") then
        pcall(function()
            local response = selectedRemoteRef:InvokeServer(payload)
            selectedRemoteRef:InvokeServer({payload})
            print("🔄 [Method 6] تم الاستدعاء المزدوج، الرد: " .. tostring(response))
        end)
    end
end

-- ===========================================
-- 4. بناء الواجهة الرئيسية (كبيرة، قابلة للسحب)
-- ===========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozerHub_v3"
ScreenGui.Parent = plr:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- الإطار الرئيسي (520x340 - كبير)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- القائمة الجانبية
local LeftSidebar = Instance.new("Frame")
LeftSidebar.Name = "Sidebar"
LeftSidebar.Parent = MainFrame
LeftSidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LeftSidebar.Size = UDim2.new(0, 155, 1, 0)
LeftSidebar.BorderSizePixel = 0
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 12)

-- العنوان "Be Mozer"
local Title = Instance.new("TextLabel")
Title.Parent = LeftSidebar
Title.Text = "Be Mozer"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 15, 0, 10)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- زر الإغلاق (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22

-- تبويبات جانبية
local TabContainer = Instance.new("Frame")
TabContainer.Parent = LeftSidebar
TabContainer.Position = UDim2.new(0, 10, 0, 65)
TabContainer.Size = UDim2.new(1, -20, 0.55, 0)
TabContainer.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabContainer

-- بروفايل المستخدم
local UserProfile = Instance.new("Frame")
UserProfile.Parent = LeftSidebar
UserProfile.Size = UDim2.new(1, -12, 0, 50)
UserProfile.Position = UDim2.new(0, 6, 1, -60)
UserProfile.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", UserProfile).CornerRadius = UDim.new(0, 10)

local UserIcon = Instance.new("ImageLabel")
UserIcon.Parent = UserProfile
UserIcon.Size = UDim2.new(0, 34, 0, 34)
UserIcon.Position = UDim2.new(0, 8, 0.5, -17)
UserIcon.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
Instance.new("UICorner", UserIcon).CornerRadius = UDim.new(1, 0)

local UserName = Instance.new("TextLabel")
UserName.Parent = UserProfile
UserName.Text = plr.DisplayName
UserName.Size = UDim2.new(1, -50, 0, 15)
UserName.Position = UDim2.new(0, 48, 0.3, -2)
UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 11
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.BackgroundTransparency = 1

local UserID = Instance.new("TextLabel")
UserID.Parent = UserProfile
UserID.Text = "@" .. plr.Name
UserID.Size = UDim2.new(1, -50, 0, 15)
UserID.Position = UDim2.new(0, 48, 0.6, -2)
UserID.TextColor3 = Color3.fromRGB(130, 130, 130)
UserID.Font = Enum.Font.Gotham
UserID.TextSize = 9
UserID.TextXAlignment = Enum.TextXAlignment.Left
UserID.BackgroundTransparency = 1

-- منطقة المحتوى (اليمين)
local RightContent = Instance.new("Frame")
RightContent.Name = "Content"
RightContent.Parent = MainFrame
RightContent.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
RightContent.Position = UDim2.new(0, 165, 0, 50)
RightContent.Size = UDim2.new(1, -175, 1, -60)
Instance.new("UICorner", RightContent).CornerRadius = UDim.new(0, 12)

-- ===========================================
-- 5. زر التصغير (دائرة M)
-- ===========================================
local MinimizedFrame = Instance.new("TextButton")
MinimizedFrame.Name = "MinimizedFrame"
MinimizedFrame.Parent = ScreenGui
MinimizedFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MinimizedFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MinimizedFrame.Size = UDim2.new(0, 55, 0, 55)
MinimizedFrame.Visible = false
MinimizedFrame.Text = "M"
MinimizedFrame.Font = Enum.Font.FredokaOne
MinimizedFrame.TextSize = 32
MinimizedFrame.BorderSizePixel = 0
Instance.new("UICorner", MinimizedFrame).CornerRadius = UDim.new(0, 12)

-- تأثير قوس قزح
task.spawn(function()
    while true do
        MinimizedFrame.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        task.wait(0.15)
    end
end)

-- ===========================================
-- 6. وظائف تبديل المحتوى (بدون إعادة تحميل)
-- ===========================================
local function clearContent()
    for _, child in pairs(RightContent:GetChildren()) do
        if child.Name ~= "UICorner" then
            child:Destroy()
        end
    end
end

-- صفحة Information
local function showInformation()
    clearContent()
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 0.9, 0)
    infoText.Position = UDim2.new(0, 10, 0.05, 0)
    infoText.BackgroundTransparency = 1
    infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 13
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Text = [[
🔬 MOZER HUB v3 - REMOTE LAB

📡 Remotes detected: ]] .. #allRemotes .. [[

🎯 Selected Remote: ]] .. selectedRemoteName .. [[

⚡ Method 1 & 6: Ready (Unlimited)

📱 Instructions:
- Go to "Remote" tab to see all Remotes
- Click SELECT on any Remote to target it
- Go to "Buy" tab to execute Method 1 or 6
- Green SELECT = Active | Red SELECT = Inactive
    ]]
    infoText.Parent = RightContent
end

-- صفحة Remote (كل الـ Remotes مع أزرار Select)
local function showRemotePage()
    clearContent()
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.Parent = RightContent
    Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame
    
    remoteButtons = {}
    
    for i, remote in ipairs(allRemotes) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 70)
        card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        card.Parent = scrollFrame
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -90, 0, 20)
        nameLabel.Position = UDim2.new(0, 8, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📡 " .. remote.name .. " (" .. remote.className .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card
        
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -90, 0, 30)
        pathLabel.Position = UDim2.new(0, 8, 0, 24)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Text = remote.path
        pathLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 9
        pathLabel.TextWrapped = true
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.Parent = card
        
        -- زر Select (أخضر = نشط، أحمر = غير نشط)
        local selectBtn = Instance.new("TextButton")
        selectBtn.Size = UDim2.new(0, 55, 0, 30)
        selectBtn.Position = UDim2.new(1, -65, 0, 20)
        selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)  -- أخضر (نشط افتراضياً)
        selectBtn.Text = "SELECT"
        selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        selectBtn.Font = Enum.Font.GothamBold
        selectBtn.TextSize = 10
        selectBtn.Parent = card
        Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)
        
        -- حالة الزر (نشط افتراضياً)
        local isActive = true
        
        selectBtn.MouseButton1Click:Connect(function()
            isActive = not isActive
            if isActive then
                selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)  -- أخضر
                selectBtn.Text = "SELECT"
                selectedRemote = remote.name
                selectedRemoteRef = remote.ref
                selectedRemoteName = remote.name
                print("✅ Selected: " .. remote.name)
            else
                selectBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)  -- أحمر
                selectBtn.Text = "OFF"
                if selectedRemoteRef == remote.ref then
                    selectedRemoteRef = nil
                    selectedRemoteName = "None"
                    print("❌ Deselected: " .. remote.name)
                end
            end
        end)
    end
    
    local function updateCanvas()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.wait(0.1)
    updateCanvas()
end

-- صفحة Buy (Method 1 و 6 المعدلين)
local function showBuyPage()
    clearContent()
    
    -- عرض الـ Remote المحدد حالياً
    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(0.9, 0, 0, 50)
    targetFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    targetFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    targetFrame.Parent = RightContent
    Instance.new("UICorner", targetFrame).CornerRadius = UDim.new(0, 8)
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -10, 1, 0)
    targetLabel.Position = UDim2.new(0, 5, 0, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "🎯 Current Target: " .. selectedRemoteName
    targetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = 12
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = targetFrame
    
    -- زر Method 1
    local method1Btn = Instance.new("TextButton")
    method1Btn.Size = UDim2.new(0.85, 0, 0, 60)
    method1Btn.Position = UDim2.new(0.075, 0, 0.25, 0)
    method1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    method1Btn.Text = "🔪 METHOD 1\nClient Bypass (Unlimited)"
    method1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    method1Btn.Font = Enum.Font.GothamBold
    method1Btn.TextSize = 13
    method1Btn.Parent = RightContent
    Instance.new("UICorner", method1Btn).CornerRadius = UDim.new(0, 10)
    
    method1Btn.MouseButton1Click:Connect(function()
        if selectedRemoteRef then
            executeMethod1()
            method1Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(0.5, function()
                if method1Btn then method1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50) end
            end)
        else
            print("❌ يرجى تحديد Remote أولاً من صفحة Remote")
            method1Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            task.delay(0.5, function()
                if method1Btn then method1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50) end
            end)
        end
    end)
    
    -- زر Method 6
    local method6Btn = Instance.new("TextButton")
    method6Btn.Size = UDim2.new(0.85, 0, 0, 60)
    method6Btn.Position = UDim2.new(0.075, 0, 0.55, 0)
    method6Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    method6Btn.Text = "🔄 METHOD 6\nRemote Replay (Unlimited)"
    method6Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    method6Btn.Font = Enum.Font.GothamBold
    method6Btn.TextSize = 13
    method6Btn.Parent = RightContent
    Instance.new("UICorner", method6Btn).CornerRadius = UDim.new(0, 10)
    
    method6Btn.MouseButton1Click:Connect(function()
        if selectedRemoteRef then
            executeMethod6()
            method6Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(0.5, function()
                if method6Btn then method6Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50) end
            end)
        else
            print("❌ يرجى تحديد Remote أولاً من صفحة Remote")
            method6Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            task.delay(0.5, function()
                if method6Btn then method6Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50) end
            end)
        end
    end)
end

-- ===========================================
-- 7. إنشاء الأزرار الجانبية (مع التنقل السريع)
-- ===========================================
local function createSidebarButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createSidebarButton("Information", function()
    currentTab = "Information"
    showInformation()
end)

createSidebarButton("Remote", function()
    currentTab = "Remote"
    showRemotePage()
end)

createSidebarButton("Buy", function()
    currentTab = "Buy"
    showBuyPage()
end)

-- ===========================================
-- 8. وظائف السحب والتصغير
-- ===========================================
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

makeDraggable(MainFrame)
makeDraggable(MinimizedFrame)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinimizedFrame.Visible = true
end)

MinimizedFrame.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinimizedFrame.Visible = false
    -- تحديث العرض حسب آخر تبويب
    if currentTab == "Information" then showInformation()
    elseif currentTab == "Remote" then showRemotePage()
    elseif currentTab == "Buy" then showBuyPage()
    else showInformation() end
end)

-- ===========================================
-- 9. رسالة الترحيب
-- ===========================================
local function showWelcome()
    local WelcomeGui = Instance.new("ScreenGui")
    WelcomeGui.Parent = plr.PlayerGui
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.Parent = WelcomeGui
    
    local mozerLabel = Instance.new("TextLabel")
    mozerLabel.Size = UDim2.new(1, 0, 0.3, 0)
    mozerLabel.Position = UDim2.new(0, 0, 0.3, 0)
    mozerLabel.BackgroundTransparency = 1
    mozerLabel.Text = "MOZER"
    mozerLabel.TextSize = 80
    mozerLabel.TextScaled = true
    mozerLabel.Font = Enum.Font.FredokaOne
    mozerLabel.Parent = bg
    
    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(1, 0, 0.15, 0)
    welcomeLabel.Position = UDim2.new(0, 0, 0.55, 0)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.Text = "welcome"
    welcomeLabel.TextSize = 50
    welcomeLabel.TextScaled = true
    welcomeLabel.Font = Enum.Font.FredokaOne
    welcomeLabel.Parent = bg
    
    task.spawn(function()
        for i = 1, 25 do
            local hue = tick() % 5 / 5
            mozerLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            welcomeLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.12)
        end
    end)
    
    task.wait(2.5)
    WelcomeGui:Destroy()
end

-- ===========================================
-- 10. بدء التشغيل
-- ===========================================
fetchAllRemotes()
showWelcome()
task.wait(0.5)
showInformation()

print("\n🔬 MOZER HUB v3 - REMOTE LAB")
print("📡 " .. #allRemotes .. " Remotes detected")
print("📋 Go to 'Remote' tab to select a target")
print("🔪 Go to 'Buy' tab to execute Method 1 or 6 (Unlimited)")
