--[[
    ═══════════════════════════════════════════════════════════
    SorpwonHUB - Premium UI Library for Roblox
    Dark Mode · Cyan Accent · Full Components
    ═══════════════════════════════════════════════════════════
]]--

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ── Utilities ──
local function GetGuiContainer()
    local s, core = pcall(function()
        return (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if s and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function Tween(instance, properties, duration, style, direction)
    duration = duration or 0.22
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function EnableDragging(dragFrame, targetFrame)
    local dragging = false
    local hasMoved = false
    local dragInput, dragStart, startPos
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = targetFrame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then hasMoved = true end
            if hasMoved then
                Tween(targetFrame, {
                    Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                }, 0.08, Enum.EasingStyle.Linear)
            end
        end
    end)
end

local function SetupFloatToggle(button, onToggle)
    local dragging = false
    local hasMoved = false
    local dragInput, dragStart, startPos
    local lastToggleTime = 0

    local function SafeToggle()
        if os.clock() - lastToggleTime < 0.25 then return end
        lastToggleTime = os.clock()
        onToggle()
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = button.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                    if not hasMoved then SafeToggle() end
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then hasMoved = true end
            if hasMoved then
                Tween(button, {
                    Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                }, 0.06, Enum.EasingStyle.Linear)
            end
        end
    end)

    button.Activated:Connect(function()
        if not hasMoved then SafeToggle() end
    end)
    button.MouseButton1Click:Connect(function()
        if not hasMoved then SafeToggle() end
    end)
end

-- ── Theme Colors ──
local Theme = {
    Background      = Color3.fromRGB(13, 10, 21),
    Surface         = Color3.fromRGB(20, 17, 32),
    SurfaceLight    = Color3.fromRGB(28, 24, 42),
    Border          = Color3.fromRGB(42, 36, 62),
    BorderLight     = Color3.fromRGB(55, 48, 78),
    Accent          = Color3.fromRGB(0, 212, 255),
    AccentDark      = Color3.fromRGB(0, 150, 180),
    AccentGlow      = Color3.fromRGB(0, 180, 220),
    TextPrimary     = Color3.fromRGB(230, 235, 245),
    TextSecondary   = Color3.fromRGB(140, 145, 165),
    TextMuted       = Color3.fromRGB(90, 95, 115),
    Success         = Color3.fromRGB(34, 197, 94),
    Danger          = Color3.fromRGB(239, 68, 68),
    Warning         = Color3.fromRGB(250, 204, 21),
    ToggleOff       = Color3.fromRGB(50, 45, 68),
    ToggleOn        = Color3.fromRGB(0, 212, 255),
    SliderTrack     = Color3.fromRGB(40, 36, 58),
    SliderFill      = Color3.fromRGB(0, 212, 255),
}

-- ══════════════════════════════════════════════════════════
-- SorpwonHUB LIBRARY
-- ══════════════════════════════════════════════════════════
local SorpwonHUB = {}

function SorpwonHUB:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "SorpwonHUB"
    local Subtitle = config.Subtitle or "Premium Script Hub"
    local Keybind = config.Keybind or Enum.KeyCode.RightControl

    local container = GetGuiContainer()
    if container:FindFirstChild("SorpwonHUBGui") then
        container.SorpwonHUBGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SorpwonHUBGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = container

    -- Float Toggle
    local FloatToggle = Instance.new("TextButton")
    FloatToggle.Name = "FloatToggle"
    FloatToggle.Size = UDim2.new(0, 100, 0, 32)
    FloatToggle.Position = UDim2.new(0.02, 0, 0.45, 0)
    FloatToggle.BackgroundColor3 = Theme.Background
    FloatToggle.Text = "⚡ Sorpwon"
    FloatToggle.TextColor3 = Theme.Accent
    FloatToggle.Font = Enum.Font.GothamBold
    FloatToggle.TextSize = 13
    FloatToggle.Parent = ScreenGui
    Instance.new("UICorner", FloatToggle).CornerRadius = UDim.new(0, 8)
    local fStroke = Instance.new("UIStroke", FloatToggle)
    fStroke.Color = Theme.AccentDark
    fStroke.Thickness = 1

    -- Main Window
    local Main = Instance.new("Frame")
    Main.Name = "MainWindow"
    Main.Size = UDim2.new(0, 700, 0, 450)
    Main.Position = UDim2.new(0.5, -350, 0.5, -225)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    local mStroke = Instance.new("UIStroke", Main)
    mStroke.Color = Theme.Border
    mStroke.Thickness = 1

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 52)
    Topbar.BackgroundColor3 = Theme.Background
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)

    local TopbarLine = Instance.new("Frame")
    TopbarLine.Size = UDim2.new(1, 0, 0, 1)
    TopbarLine.Position = UDim2.new(0, 0, 1, -1)
    TopbarLine.BackgroundColor3 = Theme.Border
    TopbarLine.BorderSizePixel = 0
    TopbarLine.Parent = Topbar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 16, 0, 8)
    TitleLabel.Size = UDim2.new(0.5, 0, 0, 20)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Text = Subtitle
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 11
    SubLabel.TextColor3 = Theme.TextMuted
    SubLabel.BackgroundTransparency = 1
    SubLabel.Position = UDim2.new(0, 16, 0, 30)
    SubLabel.Size = UDim2.new(0.5, 0, 0, 16)
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = Topbar

    EnableDragging(Topbar, Main)

    -- Tab Bar (Left)
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, 140, 1, -52)
    TabBar.Position = UDim2.new(0, 0, 0, 52)
    TabBar.BackgroundColor3 = Theme.Surface
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 12)

    local TabBarCover = Instance.new("Frame")
    TabBarCover.Size = UDim2.new(0, 12, 1, 0)
    TabBarCover.Position = UDim2.new(1, -12, 0, 0)
    TabBarCover.BackgroundColor3 = Theme.Surface
    TabBarCover.BorderSizePixel = 0
    TabBarCover.Parent = TabBar

    local TabBarLine = Instance.new("Frame")
    TabBarLine.Size = UDim2.new(0, 1, 1, 0)
    TabBarLine.Position = UDim2.new(1, 0, 0, 0)
    TabBarLine.BackgroundColor3 = Theme.Border
    TabBarLine.BorderSizePixel = 0
    TabBarLine.Parent = TabBar

    -- Container for tab buttons (isolated from decorative frames)
    local TabButtonContainer = Instance.new("Frame")
    TabButtonContainer.Name = "TabButtonContainer"
    TabButtonContainer.Size = UDim2.new(1, 0, 1, 0)
    TabButtonContainer.BackgroundTransparency = 1
    TabButtonContainer.BorderSizePixel = 0
    TabButtonContainer.Parent = TabBar

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)
    TabList.Parent = TabButtonContainer

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 8)
    TabPadding.PaddingLeft = UDim.new(0, 6)
    TabPadding.PaddingRight = UDim.new(0, 6)
    TabPadding.Parent = TabButtonContainer

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -142, 1, -54)
    ContentArea.Position = UDim2.new(0, 142, 0, 54)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = Main

    -- Notification Container
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "Notifications"
    NotifContainer.Size = UDim2.new(0, 280, 1, 0)
    NotifContainer.Position = UDim2.new(1, -290, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui
    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.Padding = UDim.new(0, 6)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifLayout.Parent = NotifContainer

    -- State
    local tabs = {}
    local activeTab = nil
    local guiVisible = true
    local WindowObj = {}

    local function ToggleGUI()
        guiVisible = not guiVisible
        if guiVisible then
            Main.Visible = true
            Tween(Main, { Size = UDim2.new(0, 700, 0, 450) }, 0.3)
        else
            Tween(Main, { Size = UDim2.new(0, 700, 0, 0) }, 0.25)
            task.delay(0.25, function()
                if not guiVisible then Main.Visible = false end
            end)
        end
    end

    SetupFloatToggle(FloatToggle, ToggleGUI)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Keybind then
            ToggleGUI()
        end
    end)

    task.delay(0.5, function()
        WindowObj:Notify({ Title = "SorpwonHUB", Content = "Press [Right Control] to toggle the GUI on/off anytime!", Duration = 4 })
    end)

    -- ═══ NOTIFY ═══
    function WindowObj:Notify(toast)
        toast = toast or {}
        local nTitle = toast.Title or "Notification"
        local nContent = toast.Content or ""
        local nDuration = toast.Duration or 4

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(1, 0, 0, 70)
        NotifFrame.BackgroundColor3 = Theme.Surface
        NotifFrame.BorderSizePixel = 0
        NotifFrame.BackgroundTransparency = 1
        NotifFrame.Parent = NotifContainer
        Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 10)
        local nStroke = Instance.new("UIStroke", NotifFrame)
        nStroke.Color = Theme.AccentDark
        nStroke.Thickness = 1
        nStroke.Transparency = 1

        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 3, 1, -10)
        AccentBar.Position = UDim2.new(0, 6, 0, 5)
        AccentBar.BackgroundColor3 = Theme.Accent
        AccentBar.BorderSizePixel = 0
        AccentBar.Parent = NotifFrame
        Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0, 2)

        local nTitleLabel = Instance.new("TextLabel")
        nTitleLabel.Text = nTitle
        nTitleLabel.Font = Enum.Font.GothamBold
        nTitleLabel.TextSize = 13
        nTitleLabel.TextColor3 = Theme.Accent
        nTitleLabel.BackgroundTransparency = 1
        nTitleLabel.Position = UDim2.new(0, 18, 0, 8)
        nTitleLabel.Size = UDim2.new(1, -26, 0, 18)
        nTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        nTitleLabel.Parent = NotifFrame

        local nContentLabel = Instance.new("TextLabel")
        nContentLabel.Text = nContent
        nContentLabel.Font = Enum.Font.Gotham
        nContentLabel.TextSize = 11
        nContentLabel.TextColor3 = Theme.TextSecondary
        nContentLabel.BackgroundTransparency = 1
        nContentLabel.Position = UDim2.new(0, 18, 0, 28)
        nContentLabel.Size = UDim2.new(1, -26, 0, 36)
        nContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        nContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        nContentLabel.TextWrapped = true
        nContentLabel.Parent = NotifFrame

        Tween(NotifFrame, { BackgroundTransparency = 0 }, 0.3)
        Tween(nStroke, { Transparency = 0 }, 0.3)

        task.delay(nDuration, function()
            Tween(NotifFrame, { BackgroundTransparency = 1 }, 0.4)
            Tween(nStroke, { Transparency = 1 }, 0.4)
            task.delay(0.45, function()
                pcall(function() NotifFrame:Destroy() end)
            end)
        end)
    end

    -- ═══ CREATE TAB ═══
    function WindowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or ""

        local TabButton = Instance.new("TextButton")
        TabButton.Name = "Tab_" .. tabName
        TabButton.Size = UDim2.new(1, 0, 0, 34)
        TabButton.BackgroundColor3 = Theme.Surface
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.Parent = TabButtonContainer
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)

        local TabIconLabel = Instance.new("TextLabel")
        TabIconLabel.Text = tabIcon
        TabIconLabel.Font = Enum.Font.Gotham
        TabIconLabel.TextSize = 14
        TabIconLabel.BackgroundTransparency = 1
        TabIconLabel.Size = UDim2.new(0, 28, 1, 0)
        TabIconLabel.Position = UDim2.new(0, 6, 0, 0)
        TabIconLabel.TextColor3 = Theme.TextSecondary
        TabIconLabel.Parent = TabButton

        local TabNameLabel = Instance.new("TextLabel")
        TabNameLabel.Text = tabName
        TabNameLabel.Font = Enum.Font.GothamSemibold
        TabNameLabel.TextSize = 12
        TabNameLabel.BackgroundTransparency = 1
        TabNameLabel.Size = UDim2.new(1, -40, 1, 0)
        TabNameLabel.Position = UDim2.new(0, 36, 0, 0)
        TabNameLabel.TextColor3 = Theme.TextSecondary
        TabNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabNameLabel.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "Content_" .. tabName
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Theme.AccentDark
        TabContent.BorderSizePixel = 0
        TabContent.Visible = false
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Parent = ContentArea

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 6)
        ContentLayout.Parent = TabContent

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 6)
        ContentPadding.PaddingLeft = UDim.new(0, 8)
        ContentPadding.PaddingRight = UDim.new(0, 8)
        ContentPadding.PaddingBottom = UDim.new(0, 8)
        ContentPadding.Parent = TabContent

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)

        local function ActivateTab()
            for _, t in pairs(tabs) do
                t.Content.Visible = false
                Tween(t.Button, { BackgroundTransparency = 1 }, 0.15)
                t.NameLabel.TextColor3 = Theme.TextSecondary
                t.IconLabel.TextColor3 = Theme.TextSecondary
            end
            TabContent.Visible = true
            Tween(TabButton, { BackgroundTransparency = 0.85 }, 0.15)
            TabButton.BackgroundColor3 = Theme.Accent
            TabNameLabel.TextColor3 = Theme.Accent
            TabIconLabel.TextColor3 = Theme.Accent
            activeTab = tabName
        end

        TabButton.MouseButton1Click:Connect(ActivateTab)

        local tabEntry = {
            Button = TabButton,
            Content = TabContent,
            NameLabel = TabNameLabel,
            IconLabel = TabIconLabel,
        }
        table.insert(tabs, tabEntry)

        if #tabs == 1 then ActivateTab() end

        local TabObj = {}

        -- ═══ CREATE SECTION ═══
        function TabObj:CreateSection(sectionName)
            sectionName = sectionName or "Section"

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section_" .. sectionName
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.BackgroundColor3 = Theme.Surface
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = TabContent
            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 10)
            local sStroke = Instance.new("UIStroke", SectionFrame)
            sStroke.Color = Theme.Border
            sStroke.Thickness = 1

            local SectionHeader = Instance.new("TextLabel")
            SectionHeader.Text = "  " .. sectionName
            SectionHeader.Font = Enum.Font.GothamBold
            SectionHeader.TextSize = 12
            SectionHeader.TextColor3 = Theme.Accent
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Size = UDim2.new(1, 0, 0, 30)
            SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
            SectionHeader.Parent = SectionFrame

            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Items"
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.Position = UDim2.new(0, 0, 0, 30)
            SectionContent.BackgroundTransparency = 1
            SectionContent.Parent = SectionFrame

            local ItemLayout = Instance.new("UIListLayout")
            ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemLayout.Padding = UDim.new(0, 2)
            ItemLayout.Parent = SectionContent

            local ItemPadding = Instance.new("UIPadding")
            ItemPadding.PaddingLeft = UDim.new(0, 8)
            ItemPadding.PaddingRight = UDim.new(0, 8)
            ItemPadding.PaddingBottom = UDim.new(0, 8)
            ItemPadding.Parent = SectionContent

            local SectionObj = {}

            -- ═══ TOGGLE ═══
            function SectionObj:CreateToggle(tc)
                tc = tc or {}
                local tName = tc.Name or "Toggle"
                local tDefault = tc.Default or false
                local tCallback = tc.Callback or function() end
                local toggled = tDefault

                local TF = Instance.new("Frame")
                TF.Size = UDim2.new(1, 0, 0, 32)
                TF.BackgroundTransparency = 1
                TF.Parent = SectionContent

                local TL = Instance.new("TextLabel")
                TL.Text = tName
                TL.Font = Enum.Font.Gotham
                TL.TextSize = 12
                TL.TextColor3 = Theme.TextPrimary
                TL.BackgroundTransparency = 1
                TL.Size = UDim2.new(1, -60, 1, 0)
                TL.Position = UDim2.new(0, 4, 0, 0)
                TL.TextXAlignment = Enum.TextXAlignment.Left
                TL.Parent = TF

                local TB = Instance.new("TextButton")
                TB.Size = UDim2.new(0, 40, 0, 20)
                TB.Position = UDim2.new(1, -48, 0.5, -10)
                TB.BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff
                TB.Text = ""
                TB.Parent = TF
                Instance.new("UICorner", TB).CornerRadius = UDim.new(1, 0)

                local TC = Instance.new("Frame")
                TC.Size = UDim2.new(0, 16, 0, 16)
                TC.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                TC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TC.Parent = TB
                Instance.new("UICorner", TC).CornerRadius = UDim.new(1, 0)

                TB.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Tween(TB, { BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                    Tween(TC, { Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.2)
                    pcall(tCallback, toggled)
                end)

                if tDefault then
                    task.defer(function() pcall(tCallback, true) end)
                end
            end

            -- ═══ BUTTON ═══
            function SectionObj:CreateButton(bc)
                bc = bc or {}
                local bName = bc.Name or "Button"
                local bCallback = bc.Callback or function() end

                local BF = Instance.new("TextButton")
                BF.Size = UDim2.new(1, 0, 0, 32)
                BF.BackgroundColor3 = Theme.SurfaceLight
                BF.Text = bName
                BF.Font = Enum.Font.GothamSemibold
                BF.TextSize = 12
                BF.TextColor3 = Theme.TextPrimary
                BF.Parent = SectionContent
                Instance.new("UICorner", BF).CornerRadius = UDim.new(0, 6)

                BF.MouseEnter:Connect(function()
                    Tween(BF, { BackgroundColor3 = Theme.BorderLight }, 0.15)
                end)
                BF.MouseLeave:Connect(function()
                    Tween(BF, { BackgroundColor3 = Theme.SurfaceLight }, 0.15)
                end)
                BF.MouseButton1Click:Connect(function()
                    Tween(BF, { BackgroundColor3 = Theme.Accent }, 0.1)
                    task.delay(0.15, function()
                        Tween(BF, { BackgroundColor3 = Theme.SurfaceLight }, 0.2)
                    end)
                    pcall(bCallback)
                end)
            end

            -- ═══ SLIDER ═══
            function SectionObj:CreateSlider(sc)
                sc = sc or {}
                local sName = sc.Name or "Slider"
                local sMin = sc.Min or 0
                local sMax = sc.Max or 100
                local sDefault = sc.Default or sMin
                local sCallback = sc.Callback or function() end

                local SF = Instance.new("Frame")
                SF.Size = UDim2.new(1, 0, 0, 44)
                SF.BackgroundTransparency = 1
                SF.Parent = SectionContent

                local SL = Instance.new("TextLabel")
                SL.Text = sName
                SL.Font = Enum.Font.Gotham
                SL.TextSize = 12
                SL.TextColor3 = Theme.TextPrimary
                SL.BackgroundTransparency = 1
                SL.Size = UDim2.new(0.7, 0, 0, 18)
                SL.Position = UDim2.new(0, 4, 0, 0)
                SL.TextXAlignment = Enum.TextXAlignment.Left
                SL.Parent = SF

                local VL = Instance.new("TextLabel")
                VL.Text = tostring(sDefault)
                VL.Font = Enum.Font.GothamBold
                VL.TextSize = 12
                VL.TextColor3 = Theme.Accent
                VL.BackgroundTransparency = 1
                VL.Size = UDim2.new(0.3, -4, 0, 18)
                VL.Position = UDim2.new(0.7, 0, 0, 0)
                VL.TextXAlignment = Enum.TextXAlignment.Right
                VL.Parent = SF

                local ST = Instance.new("Frame")
                ST.Size = UDim2.new(1, -8, 0, 8)
                ST.Position = UDim2.new(0, 4, 0, 26)
                ST.BackgroundColor3 = Theme.SliderTrack
                ST.BorderSizePixel = 0
                ST.Parent = SF
                Instance.new("UICorner", ST).CornerRadius = UDim.new(1, 0)

                local initFill = math.clamp((sDefault - sMin) / (sMax - sMin), 0, 1)
                local SFill = Instance.new("Frame")
                SFill.Size = UDim2.new(initFill, 0, 1, 0)
                SFill.BackgroundColor3 = Theme.SliderFill
                SFill.BorderSizePixel = 0
                SFill.Parent = ST
                Instance.new("UICorner", SFill).CornerRadius = UDim.new(1, 0)

                local SK = Instance.new("Frame")
                SK.Size = UDim2.new(0, 14, 0, 14)
                SK.Position = UDim2.new(initFill, -7, 0.5, -7)
                SK.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SK.BorderSizePixel = 0
                SK.Parent = ST
                Instance.new("UICorner", SK).CornerRadius = UDim.new(1, 0)

                local sliding = false

                local function UpdateSlider(inputX)
                    local trackPos = ST.AbsolutePosition.X
                    local trackSize = ST.AbsoluteSize.X
                    local pct = math.clamp((inputX - trackPos) / trackSize, 0, 1)
                    local value = math.floor(sMin + (sMax - sMin) * pct + 0.5)
                    pct = (value - sMin) / (sMax - sMin)
                    Tween(SFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.06, Enum.EasingStyle.Linear)
                    Tween(SK, { Position = UDim2.new(pct, -7, 0.5, -7) }, 0.06, Enum.EasingStyle.Linear)
                    VL.Text = tostring(value)
                    pcall(sCallback, value)
                end

                ST.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        UpdateSlider(input.Position.X)
                    end
                end)
                SK.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                task.defer(function() pcall(sCallback, sDefault) end)
            end

            -- ═══ DROPDOWN ═══
            function SectionObj:CreateDropdown(dc)
                dc = dc or {}
                local dName = dc.Name or "Dropdown"
                local dOptions = dc.Options or {}
                local dDefault = dc.Default or (dOptions[1] or "")
                local dCallback = dc.Callback or function() end
                local selected = dDefault
                local isOpen = false

                local DF = Instance.new("Frame")
                DF.Size = UDim2.new(1, 0, 0, 32)
                DF.BackgroundTransparency = 1
                DF.ClipsDescendants = false
                DF.Parent = SectionContent

                local DL = Instance.new("TextLabel")
                DL.Text = dName
                DL.Font = Enum.Font.Gotham
                DL.TextSize = 12
                DL.TextColor3 = Theme.TextPrimary
                DL.BackgroundTransparency = 1
                DL.Size = UDim2.new(0.45, 0, 0, 32)
                DL.Position = UDim2.new(0, 4, 0, 0)
                DL.TextXAlignment = Enum.TextXAlignment.Left
                DL.Parent = DF

                local DB = Instance.new("TextButton")
                DB.Size = UDim2.new(0.5, 0, 0, 28)
                DB.Position = UDim2.new(0.5, -4, 0, 2)
                DB.BackgroundColor3 = Theme.SurfaceLight
                DB.Text = selected .. " ▼"
                DB.Font = Enum.Font.GothamSemibold
                DB.TextSize = 11
                DB.TextColor3 = Theme.TextPrimary
                DB.Parent = DF
                Instance.new("UICorner", DB).CornerRadius = UDim.new(0, 6)

                local DList = Instance.new("Frame")
                DList.Size = UDim2.new(0.5, 0, 0, 0)
                DList.Position = UDim2.new(0.5, -4, 0, 32)
                DList.BackgroundColor3 = Theme.Surface
                DList.BorderSizePixel = 0
                DList.Visible = false
                DList.ZIndex = 50
                DList.ClipsDescendants = true
                DList.Parent = DF
                Instance.new("UICorner", DList).CornerRadius = UDim.new(0, 6)
                local dlS = Instance.new("UIStroke", DList)
                dlS.Color = Theme.Border
                dlS.Thickness = 1

                local DListLayout = Instance.new("UIListLayout")
                DListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DListLayout.Parent = DList

                for _, opt in pairs(dOptions) do
                    local OB = Instance.new("TextButton")
                    OB.Size = UDim2.new(1, 0, 0, 26)
                    OB.BackgroundColor3 = Theme.Surface
                    OB.Text = opt
                    OB.Font = Enum.Font.Gotham
                    OB.TextSize = 11
                    OB.TextColor3 = (opt == selected) and Theme.Accent or Theme.TextPrimary
                    OB.ZIndex = 51
                    OB.Parent = DList

                    OB.MouseEnter:Connect(function() Tween(OB, { BackgroundColor3 = Theme.SurfaceLight }, 0.1) end)
                    OB.MouseLeave:Connect(function() Tween(OB, { BackgroundColor3 = Theme.Surface }, 0.1) end)
                    OB.MouseButton1Click:Connect(function()
                        selected = opt
                        DB.Text = opt .. " ▼"
                        for _, c in pairs(DList:GetChildren()) do
                            if c:IsA("TextButton") then
                                c.TextColor3 = (c.Text == opt) and Theme.Accent or Theme.TextPrimary
                            end
                        end
                        isOpen = false
                        DList.Visible = false
                        Tween(DF, { Size = UDim2.new(1, 0, 0, 32) }, 0.15)
                        pcall(dCallback, opt)
                    end)
                end

                DB.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local lh = #dOptions * 26
                        DList.Visible = true
                        Tween(DF, { Size = UDim2.new(1, 0, 0, 32 + lh + 4) }, 0.2)
                        DList.Size = UDim2.new(0.5, 0, 0, lh)
                    else
                        DList.Visible = false
                        Tween(DF, { Size = UDim2.new(1, 0, 0, 32) }, 0.15)
                    end
                end)

                task.defer(function() pcall(dCallback, dDefault) end)

                local DropdownObj = {}
                function DropdownObj:Refresh(newOptions)
                    -- Clear old option buttons
                    for _, c in pairs(DList:GetChildren()) do
                        if c:IsA("TextButton") then
                            c:Destroy()
                        end
                    end
                    dOptions = newOptions or {}
                    selected = dOptions[1] or ""
                    DB.Text = selected .. " ▼"
                    -- Recreate option buttons
                    for _, opt in pairs(dOptions) do
                        local OB = Instance.new("TextButton")
                        OB.Size = UDim2.new(1, 0, 0, 26)
                        OB.BackgroundColor3 = Theme.Surface
                        OB.Text = opt
                        OB.Font = Enum.Font.Gotham
                        OB.TextSize = 11
                        OB.TextColor3 = (opt == selected) and Theme.Accent or Theme.TextPrimary
                        OB.ZIndex = 51
                        OB.Parent = DList

                        OB.MouseEnter:Connect(function() Tween(OB, { BackgroundColor3 = Theme.SurfaceLight }, 0.1) end)
                        OB.MouseLeave:Connect(function() Tween(OB, { BackgroundColor3 = Theme.Surface }, 0.1) end)
                        OB.MouseButton1Click:Connect(function()
                            selected = opt
                            DB.Text = opt .. " ▼"
                            for _, c2 in pairs(DList:GetChildren()) do
                                if c2:IsA("TextButton") then
                                    c2.TextColor3 = (c2.Text == opt) and Theme.Accent or Theme.TextPrimary
                                end
                            end
                            isOpen = false
                            DList.Visible = false
                            Tween(DF, { Size = UDim2.new(1, 0, 0, 32) }, 0.15)
                            pcall(dCallback, opt)
                        end)
                    end
                    -- Close if open
                    if isOpen then
                        isOpen = false
                        DList.Visible = false
                        Tween(DF, { Size = UDim2.new(1, 0, 0, 32) }, 0.15)
                    end
                    pcall(dCallback, selected)
                end
                return DropdownObj
            end

            -- ═══ INPUT ═══
            function SectionObj:CreateInput(ic)
                ic = ic or {}
                local iName = ic.Name or "Input"
                local iDefault = ic.Default or ""
                local iCallback = ic.Callback or function() end

                local IF = Instance.new("Frame")
                IF.Size = UDim2.new(1, 0, 0, 32)
                IF.BackgroundTransparency = 1
                IF.Parent = SectionContent

                local IL = Instance.new("TextLabel")
                IL.Text = iName
                IL.Font = Enum.Font.Gotham
                IL.TextSize = 12
                IL.TextColor3 = Theme.TextPrimary
                IL.BackgroundTransparency = 1
                IL.Size = UDim2.new(0.45, 0, 1, 0)
                IL.Position = UDim2.new(0, 4, 0, 0)
                IL.TextXAlignment = Enum.TextXAlignment.Left
                IL.Parent = IF

                local IB = Instance.new("TextBox")
                IB.Size = UDim2.new(0.5, 0, 0, 26)
                IB.Position = UDim2.new(0.5, -4, 0, 3)
                IB.BackgroundColor3 = Theme.SurfaceLight
                IB.Text = iDefault
                IB.Font = Enum.Font.Gotham
                IB.TextSize = 11
                IB.TextColor3 = Theme.TextPrimary
                IB.PlaceholderText = "Enter..."
                IB.PlaceholderColor3 = Theme.TextMuted
                IB.ClearTextOnFocus = false
                IB.Parent = IF
                Instance.new("UICorner", IB).CornerRadius = UDim.new(0, 6)
                local ibP = Instance.new("UIPadding", IB)
                ibP.PaddingLeft = UDim.new(0, 8)
                ibP.PaddingRight = UDim.new(0, 8)

                IB.FocusLost:Connect(function(enter)
                    if enter then pcall(iCallback, IB.Text) end
                end)
            end

            -- ═══ LABEL ═══
            function SectionObj:CreateLabel(lc)
                -- Support both string and table: CreateLabel("text") or CreateLabel({Text = "text"})
                if type(lc) == "string" then
                    lc = { Text = lc }
                end
                lc = lc or {}
                local lText = lc.Text or lc.Name or "Label"

                local LF = Instance.new("TextLabel")
                LF.Size = UDim2.new(1, 0, 0, 24)
                LF.BackgroundTransparency = 1
                LF.Text = lText
                LF.Font = Enum.Font.Gotham
                LF.TextSize = 11
                LF.TextColor3 = Theme.TextSecondary
                LF.TextXAlignment = Enum.TextXAlignment.Left
                LF.Parent = SectionContent

                local LObj = {}
                function LObj:SetText(newText) LF.Text = newText end
                return LObj
            end

            -- ═══ COLOR PICKER ═══
            function SectionObj:CreateColorPicker(cc)
                cc = cc or {}
                local cpName = cc.Name or "Color"
                local cpDefault = cc.Default or Color3.fromRGB(0, 212, 255)
                local cpCallback = cc.Callback or function() end
                local currentColor = cpDefault

                local CPF = Instance.new("Frame")
                CPF.Size = UDim2.new(1, 0, 0, 32)
                CPF.BackgroundTransparency = 1
                CPF.Parent = SectionContent

                local CPL = Instance.new("TextLabel")
                CPL.Text = cpName
                CPL.Font = Enum.Font.Gotham
                CPL.TextSize = 12
                CPL.TextColor3 = Theme.TextPrimary
                CPL.BackgroundTransparency = 1
                CPL.Size = UDim2.new(1, -50, 1, 0)
                CPL.Position = UDim2.new(0, 4, 0, 0)
                CPL.TextXAlignment = Enum.TextXAlignment.Left
                CPL.Parent = CPF

                local CPP = Instance.new("TextButton")
                CPP.Size = UDim2.new(0, 32, 0, 20)
                CPP.Position = UDim2.new(1, -40, 0.5, -10)
                CPP.BackgroundColor3 = currentColor
                CPP.Text = ""
                CPP.Parent = CPF
                Instance.new("UICorner", CPP).CornerRadius = UDim.new(0, 6)
                Instance.new("UIStroke", CPP).Color = Theme.Border

                local pickerOpen = false

                local PP = Instance.new("Frame")
                PP.Size = UDim2.new(1, 0, 0, 80)
                PP.BackgroundColor3 = Theme.SurfaceLight
                PP.Visible = false
                PP.Parent = SectionContent
                Instance.new("UICorner", PP).CornerRadius = UDim.new(0, 8)

                local HT = Instance.new("Frame")
                HT.Size = UDim2.new(1, -16, 0, 14)
                HT.Position = UDim2.new(0, 8, 0, 8)
                HT.BorderSizePixel = 0
                HT.Parent = PP
                Instance.new("UICorner", HT).CornerRadius = UDim.new(1, 0)
                local hG = Instance.new("UIGradient", HT)
                hG.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                })

                local HK = Instance.new("Frame")
                HK.Size = UDim2.new(0, 6, 0, 18)
                HK.Position = UDim2.new(0, 0, 0.5, -9)
                HK.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HK.BorderSizePixel = 0
                HK.ZIndex = 2
                HK.Parent = HT
                Instance.new("UICorner", HK).CornerRadius = UDim.new(1, 0)

                local SatT = Instance.new("Frame")
                SatT.Size = UDim2.new(1, -16, 0, 10)
                SatT.Position = UDim2.new(0, 8, 0, 32)
                SatT.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                SatT.BorderSizePixel = 0
                SatT.Parent = PP
                Instance.new("UICorner", SatT).CornerRadius = UDim.new(1, 0)

                local BrtT = Instance.new("Frame")
                BrtT.Size = UDim2.new(1, -16, 0, 10)
                BrtT.Position = UDim2.new(0, 8, 0, 52)
                BrtT.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                BrtT.BorderSizePixel = 0
                BrtT.Parent = PP
                Instance.new("UICorner", BrtT).CornerRadius = UDim.new(1, 0)

                local h, s, v = Color3.toHSV(cpDefault)
                local function ApplyColor()
                    currentColor = Color3.fromHSV(h, s, v)
                    CPP.BackgroundColor3 = currentColor
                    SatT.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    pcall(cpCallback, currentColor)
                end

                local hueDrag, satDrag, brtDrag = false, false, false
                HT.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true; h = math.clamp((inp.Position.X - HT.AbsolutePosition.X) / HT.AbsoluteSize.X, 0, 1); HK.Position = UDim2.new(h, -3, 0.5, -9); ApplyColor() end end)
                SatT.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then satDrag = true; s = math.clamp((inp.Position.X - SatT.AbsolutePosition.X) / SatT.AbsoluteSize.X, 0, 1); ApplyColor() end end)
                BrtT.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then brtDrag = true; v = math.clamp((inp.Position.X - BrtT.AbsolutePosition.X) / BrtT.AbsoluteSize.X, 0, 1); ApplyColor() end end)

                UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement then
                        if hueDrag then h = math.clamp((inp.Position.X - HT.AbsolutePosition.X) / HT.AbsoluteSize.X, 0, 1); HK.Position = UDim2.new(h, -3, 0.5, -9); ApplyColor() end
                        if satDrag then s = math.clamp((inp.Position.X - SatT.AbsolutePosition.X) / SatT.AbsoluteSize.X, 0, 1); ApplyColor() end
                        if brtDrag then v = math.clamp((inp.Position.X - BrtT.AbsolutePosition.X) / BrtT.AbsoluteSize.X, 0, 1); ApplyColor() end
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false; satDrag = false; brtDrag = false end
                end)

                CPP.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    PP.Visible = pickerOpen
                end)
                ApplyColor()
            end

            -- ═══ KEYBIND ═══
            function SectionObj:CreateKeybind(kc)
                kc = kc or {}
                local kbName = kc.Name or "Keybind"
                local kbDefault = kc.Default or Enum.KeyCode.F
                local kbCallback = kc.Callback or function() end
                local currentKey = kbDefault
                local listening = false

                local KF = Instance.new("Frame")
                KF.Size = UDim2.new(1, 0, 0, 32)
                KF.BackgroundTransparency = 1
                KF.Parent = SectionContent

                local KL = Instance.new("TextLabel")
                KL.Text = kbName
                KL.Font = Enum.Font.Gotham
                KL.TextSize = 12
                KL.TextColor3 = Theme.TextPrimary
                KL.BackgroundTransparency = 1
                KL.Size = UDim2.new(1, -80, 1, 0)
                KL.Position = UDim2.new(0, 4, 0, 0)
                KL.TextXAlignment = Enum.TextXAlignment.Left
                KL.Parent = KF

                local KB = Instance.new("TextButton")
                KB.Size = UDim2.new(0, 65, 0, 24)
                KB.Position = UDim2.new(1, -72, 0.5, -12)
                KB.BackgroundColor3 = Theme.SurfaceLight
                KB.Text = currentKey.Name
                KB.Font = Enum.Font.GothamSemibold
                KB.TextSize = 11
                KB.TextColor3 = Theme.Accent
                KB.Parent = KF
                Instance.new("UICorner", KB).CornerRadius = UDim.new(0, 6)

                KB.MouseButton1Click:Connect(function()
                    listening = true
                    KB.Text = "..."
                    KB.TextColor3 = Theme.Warning
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        currentKey = input.KeyCode
                        KB.Text = currentKey.Name
                        KB.TextColor3 = Theme.Accent
                        pcall(kbCallback, currentKey)
                    elseif not listening and not processed and input.KeyCode == currentKey then
                        pcall(kbCallback, currentKey)
                    end
                end)
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

return SorpwonHUB
