-- ===========================================
-- 🔬 MOZER HUB v3.2 - REMOTE LAB
-- ⚡ نسخة مبسطة | تعمل 100%
-- ===========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer

-- ===========================================
-- المتغيرات العامة
-- ===========================================
local allRemotes = {}
local selectedRemoteRef = nil
local selectedRemoteName = "None"
local currentTab = "Info"
local mainFrame = nil
local rightContent = nil
local miniBtn = nil

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
-- 2. Method 1 و 6
-- ===========================================
local function executeMethod1()
    if not selectedRemoteRef then
        print("❌ لا يوجد Remote محدد")
        return false
    end
    
    local payload = {
        action = "purchase",
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
            print("🔪 [Method 1] الرد: " .. tostring(response))
        end)
    end
    return true
end

local function executeMethod6()
    if not selectedRemoteRef then
        print("❌ لا يوجد Remote محدد")
        return false
    end
    
    local payload = {
        action = "replay",
        signature = tostring(os.time())
    }
    
    if selectedRemoteRef:IsA("RemoteEvent") then
        pcall(function()
            selectedRemoteRef:FireServer(payload)
            selectedRemoteRef:FireServer({payload})
            print("🔄 [Method 6] تم الإرسال إلى: " .. selectedRemoteName)
        end)
    elseif selectedRemoteRef:IsA("RemoteFunction") then
        pcall(function()
            selectedRemoteRef:InvokeServer(payload)
            print("🔄 [Method 6] تم الاستدعاء: " .. selectedRemoteName)
        end)
    end
    return true
end

-- ===========================================
-- 3. دالة مسح المحتوى
-- ===========================================
local function clearContent()
    if not rightContent then return end
    for _, child in pairs(rightContent:GetChildren()) do
        if child.Name ~= "UICorner" then
            child:Destroy()
        end
    end
end

-- ===========================================
-- 4. صفحة Information
-- ===========================================
local function showInfoPage()
    clearContent()
    if not rightContent then return end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Text = string.format([[
🔬 MOZER HUB v3.2

📡 Remotes detected: %d

🎯 Selected Remote: %s

⚡ Method 1 & 6: Ready

📱 Instructions:
1. Click "Remote" tab
2. Click SELECT on any Remote
3. Click "Buy" tab
4. Click Method 1 or Method 6
    ]], #allRemotes, selectedRemoteName)
    label.Parent = rightContent
end

-- ===========================================
-- 5. صفحة Remote (قائمة بكل الـ Remotes)
-- ===========================================
local function showRemotePage()
    clearContent()
    if not rightContent then return end
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    scroll.ScrollBarThickness = 4
    scroll.Parent = rightContent
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll
    
    for i, remote in ipairs(allRemotes) do
        -- بطاقة الـ Remote
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 65)
        card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        card.Parent = scroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        
        -- اسم الـ Remote
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -80, 0, 18)
        nameLabel.Position = UDim2.new(0, 8, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📡 " .. remote.name .. " (" .. remote.className .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card
        
        -- مسار الـ Remote
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -80, 0, 28)
        pathLabel.Position = UDim2.new(0, 8, 0, 22)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Text = remote.path
        pathLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 8
        pathLabel.TextWrapped = true
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.Parent = card
        
        -- زر SELECT
        local selectBtn = Instance.new("TextButton")
        selectBtn.Size = UDim2.new(0, 55, 0, 28)
        selectBtn.Position = UDim2.new(1, -62, 0, 18)
        selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        selectBtn.Text = "SELECT"
        selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        selectBtn.Font = Enum.Font.GothamBold
        selectBtn.TextSize = 10
        selectBtn.Parent = card
        Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)
        
        selectBtn.MouseButton1Click:Connect(function()
            if selectedRemoteRef == remote.ref then
                -- إلغاء التحديد
                selectedRemoteRef = nil
                selectedRemoteName = "None"
                selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                selectBtn.Text = "SELECT"
                print("❌ Deselected: " .. remote.name)
            else
                -- تحديد جديد
                selectedRemoteRef = remote.ref
                selectedRemoteName = remote.name
                selectBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                selectBtn.Text = "✓ SELECTED"
                print("✅ Selected: " .. remote.name)
                
                -- إعادة تعيين باقي الأزرار
                for _, otherCard in pairs(scroll:GetChildren()) do
                    if otherCard:IsA("Frame") then
                        local otherBtn = otherCard:FindFirstChildWhichIsA("TextButton")
                        if otherBtn and otherBtn ~= selectBtn then
                            otherBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                            otherBtn.Text = "SELECT"
                        end
                    end
                end
            end
        end)
    end
    
    -- تحديث حجم التمرير
    local function updateCanvas()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.wait(0.05)
    updateCanvas()
end

-- ===========================================
-- 6. صفحة Buy (Method 1 و 6)
-- ===========================================
local function showBuyPage()
    clearContent()
    if not rightContent then return end
    
    -- عرض الـ Remote المختار
    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(0.9, 0, 0, 50)
    targetFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    targetFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    targetFrame.Parent = rightContent
    Instance.new("UICorner", targetFrame).CornerRadius = UDim.new(0, 8)
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -10, 1, 0)
    targetLabel.Position = UDim2.new(0, 5, 0, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "🎯 Target: " .. selectedRemoteName
    targetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = 12
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = targetFrame
    
    -- زر Method 1
    local m1Btn = Instance.new("TextButton")
    m1Btn.Size = UDim2.new(0.85, 0, 0, 60)
    m1Btn.Position = UDim2.new(0.075, 0, 0.3, 0)
    m1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    m1Btn.Text = "🔪 METHOD 1\nClient Bypass"
    m1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    m1Btn.Font = Enum.Font.GothamBold
    m1Btn.TextSize = 13
    m1Btn.Parent = rightContent
    Instance.new("UICorner", m1Btn).CornerRadius = UDim.new(0, 10)
    
    m1Btn.MouseButton1Click:Connect(function()
        if selectedRemoteRef then
            executeMethod1()
            m1Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(0.5, function()
                if m1Btn then m1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50) end
            end)
        else
            print("❌ Please select a Remote first from 'Remote' tab")
            m1Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            task.delay(0.8, function()
                if m1Btn then m1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50) end
            end)
        end
    end)
    
    -- زر Method 6
    local m6Btn = Instance.new("TextButton")
    m6Btn.Size = UDim2.new(0.85, 0, 0, 60)
    m6Btn.Position = UDim2.new(0.075, 0, 0.6, 0)
    m6Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    m6Btn.Text = "🔄 METHOD 6\nRemote Replay"
    m6Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    m6Btn.Font = Enum.Font.GothamBold
    m6Btn.TextSize = 13
    m6Btn.Parent = rightContent
    Instance.new("UICorner", m6Btn).CornerRadius = UDim.new(0, 10)
    
    m6Btn.MouseButton1Click:Connect(function()
        if selectedRemoteRef then
            executeMethod6()
            m6Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(0.5, function()
                if m6Btn then m6Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50) end
            end)
        else
            print("❌ Please select a Remote first from 'Remote' tab")
            m6Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            task.delay(0.8, function()
                if m6Btn then m6Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50) end
            end)
        end
    end)
end

-- ===========================================
-- 7. بناء الواجهة الرئيسية
-- ===========================================
local function buildUI()
    -- تنظيف أي واجهة قديمة
    local oldGui = plr.PlayerGui:FindFirstChild("MozerHub")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MozerHub"
    screenGui.Parent = plr.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- الإطار الرئيسي
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 340)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    -- القائمة الجانبية
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 140, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 15, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Be Mozer"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = sidebar
    
    -- زر الإغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = mainFrame
    
    -- حاوية الأزرار الجانبية
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -20, 0, 120)
    tabContainer.Position = UDim2.new(0, 10, 0, 60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tabContainer
    
    -- منطقة المحتوى
    rightContent = Instance.new("Frame")
    rightContent.Size = UDim2.new(1, -155, 1, -20)
    rightContent.Position = UDim2.new(0, 150, 0, 10)
    rightContent.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    rightContent.Parent = mainFrame
    Instance.new("UICorner", rightContent).CornerRadius = UDim.new(0, 12)
    
    -- زر التصغير M
    miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(0, 55, 0, 55)
    miniBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
    miniBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    miniBtn.Text = "M"
    miniBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
    miniBtn.Font = Enum.Font.FredokaOne
    miniBtn.TextSize = 32
    miniBtn.Visible = false
    miniBtn.Parent = screenGui
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 12)
    
    -- تأثير قوس قزح
    task.spawn(function()
        while true do
            local hue = tick() % 5 / 5
            miniBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.15)
        end
    end)
    
    -- ===========================================
    -- إنشاء أزرار التبويبات
    -- ===========================================
    local function createTabBtn(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        btn.Text = "   " .. name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = tabContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(callback)
    end
    
    createTabBtn("Information", function()
        currentTab = "Info"
        showInfoPage()
    end)
    
    createTabBtn("Remote", function()
        currentTab = "Remote"
        showRemotePage()
    end)
    
    createTabBtn("Buy", function()
        currentTab = "Buy"
        showBuyPage()
    end)
    
    -- ===========================================
    -- السحب
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
    
    makeDraggable(mainFrame)
    makeDraggable(miniBtn)
    
    -- ===========================================
    -- التصغير والتكبير
    -- ===========================================
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniBtn.Visible = true
    end)
    
    miniBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniBtn.Visible = false
        -- تحديث الصفحة الحالية
        if currentTab == "Info" then showInfoPage()
        elseif currentTab == "Remote" then showRemotePage()
        elseif currentTab == "Buy" then showBuyPage()
        else showInfoPage() end
    end)
end

-- ===========================================
-- 8. رسالة الترحيب
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
-- 9. بدء التشغيل
-- ===========================================
fetchAllRemotes()
buildUI()
showWelcome()
task.wait(0.5)
showInfoPage()

print("\n🔬 MOZER HUB v3.2")
print("📡 " .. #allRemotes .. " Remotes detected")
print("✅ Ready. Click 'Remote' tab to select a target")
