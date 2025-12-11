local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local JUNKIE_CONFIG = {
    API_KEY = "cc8dca0c-8fcf-45b7-8da3-0e6609411b11",
    SERVICE_ID = "ChronosHUB",
    PROVIDER = "ChronosHUB Keys",
    ENABLE_HWID_CHECK = true,
    ENABLE_KEYLESS_CHECK = true,
}

local ScriptToRun = nil
local JunkieSDK = nil
local JunkieLoaded = false
local isMinimized = false

local function LoadJunkieSDK()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()
    end)
    
    if success and result then
        JunkieSDK = result
        JunkieLoaded = true
        return true
    else
        return false
    end
end

local function GetHWID()
    local hwid = nil
    pcall(function()
        if gethwid then
            hwid = gethwid()
        elseif getexecutorname and identifyexecutor then
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        else
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        end
    end)
    return hwid or "UNKNOWN"
end

local Icons = {
    IconsType = "lucide",
    Icons = {}
}

local success, lucideIcons = pcall(function()
    return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))()
end)

if success and lucideIcons then
    Icons.Icons["lucide"] = lucideIcons
end

function Icons.GetIcon(iconName)
    local iconSet = Icons.Icons["lucide"]
    if not iconSet then return nil end
    
    if iconSet.Icons and iconSet.Icons[iconName] then
        local iconData = iconSet.Icons[iconName]
        return {
            Image = iconSet.Spritesheets and iconSet.Spritesheets[tostring(iconData.Image)] or iconData.Image,
            ImageRectSize = iconData.ImageRectSize,
            ImageRectOffset = iconData.ImageRectPosition
        }
    end
    
    if iconSet[iconName] then
        if type(iconSet[iconName]) == "string" then
            return {
                Image = iconSet[iconName],
                ImageRectSize = Vector2.new(0, 0),
                ImageRectOffset = Vector2.new(0, 0)
            }
        end
    end
    
    return nil
end

local function ApplyIcon(imageLabel, iconName)
    local iconData = Icons.GetIcon(iconName)
    if iconData then
        imageLabel.Image = iconData.Image
        if iconData.ImageRectSize and iconData.ImageRectSize.X > 0 then
            imageLabel.ImageRectSize = iconData.ImageRectSize
            imageLabel.ImageRectOffset = iconData.ImageRectOffset
        end
        return true
    end
    return false
end

local CONFIG = {
    TITLE = "ChronosHUB Key System",
    SUBTITLE = "Secure Authentication",
    VERSION = "©2025",
    AUTHOR = "Junkie-Developments. All rights reserved",
    SCRIPT_URL = "https://github.com/OMchronicwtf/ChronosHUB-MM2/raw/refs/heads/main/Loader",
    
    COLORS = {
        PRIMARY = Color3.fromHex("#FFD700"),
        SECONDARY = Color3.fromHex("#C0A763"),
        ACCENT = Color3.fromHex("#E3C56D"),

        GRADIENT_START = Color3.fromHex("#0A0A0F"),
        GRADIENT_END = Color3.fromHex("#1A0533"),

        CARD = Color3.fromHex("#0D0D12"),
        CARD_LIGHT = Color3.fromHex("#14141B"),

        INPUT_BG = Color3.fromHex("#0A0A0F"),
        BUTTON_SECONDARY = Color3.fromHex("#1A1A24"),

        TEXT = Color3.fromHex("#FFFFFF"),
        TEXT_DIM = Color3.fromHex("#888888"),
        TEXT_MUTED = Color3.fromHex("#666666"),

        SUCCESS = Color3.fromHex("#4ADE80"),
        ERROR = Color3.fromHex("#EF4444"),
        WARNING = Color3.fromHex("#FBBF24"),

        PREMIUM = Color3.fromHex("#FFD700"),
    },
    
    PARTICLES = {
        STAR_SPAWN_MIN = 0.08,
        STAR_SPAWN_MAX = 0.15,
        CRYSTAL_SPAWN_MIN = 0.2,
        CRYSTAL_SPAWN_MAX = 0.4,
        BG_CRYSTAL_COUNT = 15,
        BG_ROTATION_SPEED = 0.8,
    },
}

local function Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 12)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or CONFIG.COLORS.PRIMARY
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, padding)
    pad.PaddingBottom = UDim.new(0, padding)
    pad.PaddingLeft = UDim.new(0, padding)
    pad.PaddingRight = UDim.new(0, padding)
    pad.Parent = parent
    return pad
end

local function DeleteSavedKey()
    pcall(function()
        if isfile and isfile("JunkieKey_Saved.txt") then
            delfile("JunkieKey_Saved.txt")
        end
    end)
end

for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "JunkieKeySystem" then
        gui:Destroy()
    end
end

local KeySystemGui = Instance.new("ScreenGui")
KeySystemGui.Name = "JunkieKeySystem"
KeySystemGui.Parent = CoreGui
KeySystemGui.IgnoreGuiInset = true
KeySystemGui.ResetOnSpawn = false
KeySystemGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeySystemGui.DisplayOrder = 999

local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.fromScale(1, 1)
Background.BackgroundColor3 = CONFIG.COLORS.GRADIENT_START
Background.BorderSizePixel = 0
Background.Parent = KeySystemGui

local GradientOverlay = Instance.new("Frame")
GradientOverlay.Name = "GradientOverlay"
GradientOverlay.Size = UDim2.fromScale(1, 1)
GradientOverlay.BackgroundColor3 = CONFIG.COLORS.GRADIENT_END
GradientOverlay.BorderSizePixel = 0
GradientOverlay.Parent = Background

local BGGradient = Instance.new("UIGradient")
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.COLORS.GRADIENT_START),
    ColorSequenceKeypoint.new(0.5, Color3.fromHex("#120a20")),
    ColorSequenceKeypoint.new(1, CONFIG.COLORS.GRADIENT_END)
})
BGGradient.Rotation = 135
BGGradient.Parent = GradientOverlay

local Vignette = Instance.new("ImageLabel")
Vignette.Name = "Vignette"
Vignette.Size = UDim2.fromScale(1, 1)
Vignette.BackgroundTransparency = 1
Vignette.Image = "rbxassetid://1526405635"
Vignette.ImageColor3 = Color3.new(0, 0, 0)
Vignette.ImageTransparency = 0.15
Vignette.ScaleType = Enum.ScaleType.Stretch
Vignette.ZIndex = 2
Vignette.Parent = Background

local Scanlines = Instance.new("Frame")
Scanlines.Name = "Scanlines"
Scanlines.Size = UDim2.fromScale(1, 1)
Scanlines.BackgroundTransparency = 1
Scanlines.ZIndex = 3
Scanlines.Parent = Background

for i = 1, 100 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.fromScale(0, i / 100)
    line.BackgroundColor3 = Color3.new(0, 0, 0)
    line.BackgroundTransparency = 0.97
    line.BorderSizePixel = 0
    line.Parent = Scanlines
end

local ParticleContainer = Instance.new("Frame")
ParticleContainer.Name = "ParticleContainer"
ParticleContainer.Size = UDim2.fromScale(1, 1)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.ClipsDescendants = true
ParticleContainer.ZIndex = 4
ParticleContainer.Parent = Background

local BGCrystalContainer = Instance.new("Frame")
BGCrystalContainer.Name = "BGCrystalContainer"
BGCrystalContainer.Size = UDim2.fromScale(1, 1)
BGCrystalContainer.BackgroundTransparency = 1
BGCrystalContainer.ZIndex = 1
BGCrystalContainer.Parent = Background

local function CreateFloatingCrystal()
    if not KeySystemGui or not KeySystemGui.Parent then return end
    if isMinimized then return end
    local size = math.random(25, 50)
    local transparency = math.random(55, 80) / 100
    
    local crystalHolder = Instance.new("Frame")
    crystalHolder.Name = "FloatingCrystal"
    crystalHolder.Size = UDim2.fromOffset(size, size)
    crystalHolder.Position = UDim2.fromScale(math.random() * 1, 1.1)
    crystalHolder.BackgroundTransparency = 1
    crystalHolder.Rotation = math.random(-30, 30)
    crystalHolder.ZIndex = 4
    crystalHolder.Parent = ParticleContainer
    
    local crystalIcon = Instance.new("ImageLabel")
    crystalIcon.Name = "CrystalImg"
    crystalIcon.Size = UDim2.fromScale(1, 1)
    crystalIcon.BackgroundTransparency = 1
    crystalIcon.ImageColor3 = CONFIG.COLORS.PRIMARY
    crystalIcon.ImageTransparency = transparency
    crystalIcon.ScaleType = Enum.ScaleType.Fit
    crystalIcon.ZIndex = 4
    crystalIcon.Parent = crystalHolder
    
    local iconOptions = {"key", "key-round", "lock", "star", "moon"}
    local selectedIcon = iconOptions[math.random(1, #iconOptions)]
    ApplyIcon(crystalIcon, selectedIcon)
    
    if math.random() > 0.6 then
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.fromScale(2.2, 2.2)
        glow.Position = UDim2.fromScale(0.5, 0.5)
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://5028857084"
        glow.ImageColor3 = CONFIG.COLORS.PRIMARY
        glow.ImageTransparency = 0.88
        glow.ZIndex = 3
        glow.Parent = crystalHolder
    end
    
    local duration = math.random(12, 20)
    local drift = (math.random() - 0.5) * 0.3
    local rotationEnd = crystalHolder.Rotation + math.random(-90, 90)
    
    Tween(crystalHolder, {
        Position = UDim2.fromScale(crystalHolder.Position.X.Scale + drift, -0.15),
        Rotation = rotationEnd
    }, duration, Enum.EasingStyle.Linear)
    
    Tween(crystalIcon, {ImageTransparency = 1}, duration * 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    task.delay(duration, function()
        if crystalHolder and crystalHolder.Parent then crystalHolder:Destroy() end
    end)
end

local function CreateStarParticle()
    if not KeySystemGui or not KeySystemGui.Parent then return end
    if isMinimized then return end
    local size = math.random(2, 6)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.fromOffset(size, size)
    particle.Position = UDim2.fromScale(math.random() * 1, 1.05)
    particle.BackgroundColor3 = CONFIG.COLORS.ACCENT
    particle.BackgroundTransparency = math.random(60, 85) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 4
    particle.Parent = ParticleContainer
    CreateCorner(particle, UDim.new(1, 0))
    
    local duration = math.random(8, 15)
    local drift = (math.random() - 0.5) * 0.4
    
    Tween(particle, {
        Position = UDim2.fromScale(particle.Position.X.Scale + drift, -0.1),
        BackgroundTransparency = 1
    }, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        if particle and particle.Parent then particle:Destroy() end
    end)
end

local bgCrystals = {}
for i = 1, CONFIG.PARTICLES.BG_CRYSTAL_COUNT do
    local size = math.random(50, 100)
    local transparency = math.random(92, 97) / 100
    
    local crystalBG = Instance.new("Frame")
    crystalBG.Name = "BGCrystal" .. i
    crystalBG.Size = UDim2.fromOffset(size, size)
    crystalBG.Position = UDim2.fromScale(math.random() * 1.1 - 0.05, math.random() * 1.1 - 0.05)
    crystalBG.BackgroundTransparency = 1
    crystalBG.Rotation = math.random(0, 360)
    crystalBG.ZIndex = 1
    crystalBG.Parent = BGCrystalContainer
    
    local crystalIcon = Instance.new("ImageLabel")
    crystalIcon.Name = "CrystalImg"
    crystalIcon.Size = UDim2.fromScale(1, 1)
    crystalIcon.BackgroundTransparency = 1
    crystalIcon.ImageColor3 = CONFIG.COLORS.PRIMARY
    crystalIcon.ImageTransparency = transparency
    crystalIcon.ScaleType = Enum.ScaleType.Fit
    crystalIcon.ZIndex = 1
    crystalIcon.Parent = crystalBG
    
    local bgIcons = {"key", "shield", "lock", "fingerprint", "scan"}
    ApplyIcon(crystalIcon, bgIcons[math.random(1, #bgIcons)])
    
    bgCrystals[i] = crystalBG
    
    task.spawn(function()
        local speed = (math.random() - 0.5) * 0.04 * CONFIG.PARTICLES.BG_ROTATION_SPEED
        while crystalBG and crystalBG.Parent and KeySystemGui and KeySystemGui.Parent do
            if not isMinimized then
                crystalBG.Rotation = crystalBG.Rotation + speed
            end
            task.wait(0.03)
        end
    end)
end

local CardContainer = Instance.new("Frame")
CardContainer.Name = "CardContainer"
CardContainer.Size = UDim2.fromOffset(380, 520)
CardContainer.Position = UDim2.fromScale(0.5, 0.5)
CardContainer.AnchorPoint = Vector2.new(0.5, 0.5)
CardContainer.BackgroundTransparency = 1
CardContainer.ZIndex = 10
CardContainer.Parent = Background

local ShadowLayers = {}

local CardShadow1 = Instance.new("Frame")
CardShadow1.Name = "CardShadow1"
CardShadow1.Size = UDim2.new(1, 70, 1, 70)
CardShadow1.Position = UDim2.fromScale(0.5, 0.52)
CardShadow1.AnchorPoint = Vector2.new(0.5, 0.5)
CardShadow1.BackgroundColor3 = Color3.new(0, 0, 0)
CardShadow1.BackgroundTransparency = 0.82
CardShadow1.BorderSizePixel = 0
CardShadow1.ZIndex = 7
CardShadow1.Parent = CardContainer
CreateCorner(CardShadow1, UDim.new(0, 36))
table.insert(ShadowLayers, CardShadow1)

local CardShadow2 = Instance.new("Frame")
CardShadow2.Name = "CardShadow2"
CardShadow2.Size = UDim2.new(1, 45, 1, 45)
CardShadow2.Position = UDim2.fromScale(0.5, 0.51)
CardShadow2.AnchorPoint = Vector2.new(0.5, 0.5)
CardShadow2.BackgroundColor3 = Color3.new(0, 0, 0)
CardShadow2.BackgroundTransparency = 0.72
CardShadow2.BorderSizePixel = 0
CardShadow2.ZIndex = 8
CardShadow2.Parent = CardContainer
CreateCorner(CardShadow2, UDim.new(0, 32))
table.insert(ShadowLayers, CardShadow2)

local CardShadow3 = Instance.new("Frame")
CardShadow3.Name = "CardShadow3"
CardShadow3.Size = UDim2.new(1, 22, 1, 22)
CardShadow3.Position = UDim2.fromScale(0.5, 0.505)
CardShadow3.AnchorPoint = Vector2.new(0.5, 0.5)
CardShadow3.BackgroundColor3 = Color3.new(0, 0, 0)
CardShadow3.BackgroundTransparency = 0.62
CardShadow3.BorderSizePixel = 0
CardShadow3.ZIndex = 9
CardShadow3.Parent = CardContainer
CreateCorner(CardShadow3, UDim.new(0, 30))
table.insert(ShadowLayers, CardShadow3)

local Card = Instance.new("Frame")
Card.Name = "Card"
Card.Size = UDim2.fromScale(1, 1)
Card.Position = UDim2.fromScale(0.5, 0.5)
Card.AnchorPoint = Vector2.new(0.5, 0.5)
Card.BackgroundColor3 = CONFIG.COLORS.CARD
Card.BackgroundTransparency = 0.02
Card.BorderSizePixel = 0
Card.ZIndex = 10
Card.ClipsDescendants = true
Card.Parent = CardContainer

CreateCorner(Card, UDim.new(0, 28))

local CardBorder = CreateStroke(Card, CONFIG.COLORS.PRIMARY, 1.5, 0.5)
CardBorder.Name = "CardBorder"

local InnerGlow = Instance.new("Frame")
InnerGlow.Name = "InnerGlow"
InnerGlow.Size = UDim2.new(1, 0, 0.4, 0)
InnerGlow.Position = UDim2.fromScale(0, 0)
InnerGlow.BackgroundColor3 = CONFIG.COLORS.PRIMARY
InnerGlow.BackgroundTransparency = 0.92
InnerGlow.BorderSizePixel = 0
InnerGlow.ZIndex = 10
InnerGlow.Parent = Card

local InnerGlowGradient = Instance.new("UIGradient")
InnerGlowGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 1)
})
InnerGlowGradient.Rotation = 180
InnerGlowGradient.Parent = InnerGlow

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.fromOffset(36, 36)
MinimizeButton.Position = UDim2.new(1, -12, 0, 12)
MinimizeButton.AnchorPoint = Vector2.new(1, 0)
MinimizeButton.BackgroundColor3 = CONFIG.COLORS.BUTTON_SECONDARY
MinimizeButton.BackgroundTransparency = 0.3
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = ""
MinimizeButton.AutoButtonColor = false
MinimizeButton.ZIndex = 15
MinimizeButton.Parent = Card

CreateCorner(MinimizeButton, UDim.new(0, 10))
local MinimizeStroke = CreateStroke(MinimizeButton, CONFIG.COLORS.TEXT_MUTED, 1, 0.7)

local MinimizeIcon = Instance.new("ImageLabel")
MinimizeIcon.Name = "Icon"
MinimizeIcon.Size = UDim2.fromOffset(18, 18)
MinimizeIcon.Position = UDim2.fromScale(0.5, 0.5)
MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
MinimizeIcon.BackgroundTransparency = 1
MinimizeIcon.ImageColor3 = CONFIG.COLORS.TEXT_DIM
MinimizeIcon.ZIndex = 16
MinimizeIcon.Parent = MinimizeButton

ApplyIcon(MinimizeIcon, "eye")

MinimizeButton.MouseEnter:Connect(function()
    Tween(MinimizeButton, {BackgroundTransparency = 0.1}, 0.2)
    Tween(MinimizeIcon, {ImageColor3 = CONFIG.COLORS.PRIMARY}, 0.2)
    Tween(MinimizeStroke, {Color = CONFIG.COLORS.PRIMARY, Transparency = 0.3}, 0.2)
end)

MinimizeButton.MouseLeave:Connect(function()
    Tween(MinimizeButton, {BackgroundTransparency = 0.3}, 0.2)
    Tween(MinimizeIcon, {ImageColor3 = CONFIG.COLORS.TEXT_DIM}, 0.2)
    Tween(MinimizeStroke, {Color = CONFIG.COLORS.TEXT_MUTED, Transparency = 0.7}, 0.2)
end)

local MinimizedIndicator = Instance.new("TextButton")
MinimizedIndicator.Name = "MinimizedIndicator"
MinimizedIndicator.Size = UDim2.fromOffset(50, 50)
MinimizedIndicator.Position = UDim2.new(1, -20, 0.5, 0)
MinimizedIndicator.AnchorPoint = Vector2.new(1, 0.5)
MinimizedIndicator.BackgroundColor3 = CONFIG.COLORS.PRIMARY
MinimizedIndicator.BackgroundTransparency = 0.15
MinimizedIndicator.BorderSizePixel = 0
MinimizedIndicator.Text = ""
MinimizedIndicator.AutoButtonColor = false
MinimizedIndicator.Visible = false
MinimizedIndicator.ZIndex = 100
MinimizedIndicator.Parent = KeySystemGui

CreateCorner(MinimizedIndicator, UDim.new(1, 0))
local IndicatorStroke = CreateStroke(MinimizedIndicator, CONFIG.COLORS.ACCENT, 2, 0.3)

local IndicatorIcon = Instance.new("ImageLabel")
IndicatorIcon.Name = "Icon"
IndicatorIcon.Size = UDim2.fromOffset(24, 24)
IndicatorIcon.Position = UDim2.fromScale(0.5, 0.5)
IndicatorIcon.AnchorPoint = Vector2.new(0.5, 0.5)
IndicatorIcon.BackgroundTransparency = 1
IndicatorIcon.ImageColor3 = CONFIG.COLORS.TEXT
IndicatorIcon.ZIndex = 101
IndicatorIcon.Parent = MinimizedIndicator

ApplyIcon(IndicatorIcon, "eye-off")

MinimizedIndicator.MouseEnter:Connect(function()
    Tween(MinimizedIndicator, {Size = UDim2.fromOffset(55, 55)}, 0.2, Enum.EasingStyle.Back)
    Tween(IndicatorStroke, {Transparency = 0}, 0.2)
end)

MinimizedIndicator.MouseLeave:Connect(function()
    Tween(MinimizedIndicator, {Size = UDim2.fromOffset(50, 50)}, 0.2)
    Tween(IndicatorStroke, {Transparency = 0.3}, 0.2)
end)

local function ToggleMinimize()
    isMinimized = not isMinimized
    
    if isMinimized then
        ApplyIcon(MinimizeIcon, "eye-off")
        
        Tween(Background, {BackgroundTransparency = 1}, 0.4)
        Tween(GradientOverlay, {BackgroundTransparency = 1}, 0.4)
        Tween(Vignette, {ImageTransparency = 1}, 0.4)
        
        for _, line in ipairs(Scanlines:GetChildren()) do
            if line:IsA("Frame") then
                Tween(line, {BackgroundTransparency = 1}, 0.3)
            end
        end
        
        Tween(CardContainer, {
            Position = UDim2.new(0.5, 0, -0.5, 0),
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        for _, shadow in ipairs(ShadowLayers) do
            Tween(shadow, {BackgroundTransparency = 1}, 0.3)
        end
        
        for _, crystal in ipairs(bgCrystals) do
            if crystal and crystal.Parent then
                for _, child in ipairs(crystal:GetChildren()) do
                    if child:IsA("ImageLabel") then
                        Tween(child, {ImageTransparency = 1}, 0.3)
                    end
                end
            end
        end
        
        for _, child in ipairs(ParticleContainer:GetChildren()) do
            if child:IsA("Frame") then
                Tween(child, {BackgroundTransparency = 1}, 0.3)
                for _, subChild in ipairs(child:GetChildren()) do
                    if subChild:IsA("ImageLabel") then
                        Tween(subChild, {ImageTransparency = 1}, 0.3)
                    end
                end
            end
        end
        
        task.delay(0.3, function()
            MinimizedIndicator.Visible = true
            MinimizedIndicator.Position = UDim2.new(1, 20, 0.5, 0)
            Tween(MinimizedIndicator, {Position = UDim2.new(1, -20, 0.5, 0)}, 0.3, Enum.EasingStyle.Back)
        end)
    else
        ApplyIcon(MinimizeIcon, "eye")
        
        Tween(MinimizedIndicator, {Position = UDim2.new(1, 20, 0.5, 0)}, 0.2)
        task.delay(0.2, function()
            MinimizedIndicator.Visible = false
        end)
        
        Tween(Background, {BackgroundTransparency = 0}, 0.4)
        Tween(GradientOverlay, {BackgroundTransparency = 0}, 0.4)
        Tween(Vignette, {ImageTransparency = 0.15}, 0.4)
        
        for _, line in ipairs(Scanlines:GetChildren()) do
            if line:IsA("Frame") then
                Tween(line, {BackgroundTransparency = 0.97}, 0.3)
            end
        end
        
        Tween(CardContainer, {
            Position = UDim2.fromScale(0.5, 0.5),
        }, 0.5, Enum.EasingStyle.Back)
        
        task.delay(0.2, function()
            for i, shadow in ipairs(ShadowLayers) do
                local targetTransparency = shadow.Name == "CardShadow1" and 0.82 or (shadow.Name == "CardShadow2" and 0.72 or 0.62)
                Tween(shadow, {BackgroundTransparency = targetTransparency}, 0.4)
            end
        end)
        
        for i, crystal in ipairs(bgCrystals) do
            if crystal and crystal.Parent then
                for _, child in ipairs(crystal:GetChildren()) do
                    if child:IsA("ImageLabel") then
                        local transparency = math.random(92, 97) / 100
                        Tween(child, {ImageTransparency = transparency}, 0.4)
                    end
                end
            end
        end
    end
end

MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)
MinimizedIndicator.MouseButton1Click:Connect(ToggleMinimize)

task.spawn(function()
    while KeySystemGui and KeySystemGui.Parent do
        if MinimizedIndicator.Visible then
            Tween(MinimizedIndicator, {BackgroundTransparency = 0.3}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.8)
            if MinimizedIndicator.Visible then
                Tween(MinimizedIndicator, {BackgroundTransparency = 0.1}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            end
            task.wait(0.8)
        else
            task.wait(0.1)
        end
    end
end)

local WelcomeText = Instance.new("TextLabel")
WelcomeText.Name = "WelcomeText"
WelcomeText.Size = UDim2.new(1, 0, 0, 18)
WelcomeText.Position = UDim2.new(0, 0, 0, 12.5)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Text = "Welcome!"
WelcomeText.TextColor3 = CONFIG.COLORS.TEXT_DIM
WelcomeText.TextSize = 11
WelcomeText.Font = Enum.Font.GothamMedium
WelcomeText.ZIndex = 11
WelcomeText.Parent = Card

local LogoContainer = Instance.new("Frame")
LogoContainer.Name = "LogoContainer"
LogoContainer.Size = UDim2.fromOffset(80, 80)
LogoContainer.Position = UDim2.new(0.5, 0, 0, 50)
LogoContainer.AnchorPoint = Vector2.new(0.5, 0)
LogoContainer.BackgroundTransparency = 1
LogoContainer.ZIndex = 11
LogoContainer.Parent = Card

local OuterGlow = Instance.new("Frame")
OuterGlow.Name = "OuterGlow"
OuterGlow.Size = UDim2.fromOffset(90, 90)
OuterGlow.Position = UDim2.fromScale(0.5, 0.5)
OuterGlow.AnchorPoint = Vector2.new(0.5, 0.5)
OuterGlow.BackgroundColor3 = CONFIG.COLORS.PRIMARY
OuterGlow.BackgroundTransparency = 0.88
OuterGlow.BorderSizePixel = 0
OuterGlow.ZIndex = 10
OuterGlow.Parent = LogoContainer
CreateCorner(OuterGlow, UDim.new(1, 0))

local LogoRing = Instance.new("Frame")
LogoRing.Name = "LogoRing"
LogoRing.Size = UDim2.fromOffset(72, 72)
LogoRing.Position = UDim2.fromScale(0.5, 0.5)
LogoRing.AnchorPoint = Vector2.new(0.5, 0.5)
LogoRing.BackgroundColor3 = Color3.fromHex("#18182a")
LogoRing.BackgroundTransparency = 0.2
LogoRing.BorderSizePixel = 0
LogoRing.ZIndex = 11
LogoRing.Parent = LogoContainer
CreateCorner(LogoRing, UDim.new(1, 0))

local LogoRingBorder = CreateStroke(LogoRing, CONFIG.COLORS.PRIMARY, 2.5, 0.15)

local KeyIconContainer = Instance.new("Frame")
KeyIconContainer.Name = "KeyIconContainer"
KeyIconContainer.Size = UDim2.fromOffset(36, 36)
KeyIconContainer.Position = UDim2.fromScale(0.5, 0.5)
KeyIconContainer.AnchorPoint = Vector2.new(0.5, 0.5)
KeyIconContainer.BackgroundTransparency = 1
KeyIconContainer.ZIndex = 12
KeyIconContainer.Parent = LogoRing

local KeyIcon = Instance.new("ImageLabel")
KeyIcon.Name = "KeyIcon"
KeyIcon.Size = UDim2.fromScale(1, 1)
KeyIcon.BackgroundTransparency = 1
KeyIcon.ImageColor3 = CONFIG.COLORS.PRIMARY
KeyIcon.ImageTransparency = 0
KeyIcon.ScaleType = Enum.ScaleType.Fit
KeyIcon.ZIndex = 12
KeyIcon.Parent = KeyIconContainer

ApplyIcon(KeyIcon, "key-round")

local DecoDots = {}
for i = 1, 8 do
    local angle = math.rad((i - 1) * 45 - 90)
    local radius = 48
    local dotSize = 4
    
    local dot = Instance.new("Frame")
    dot.Name = "DecoDot" .. i
    dot.Size = UDim2.fromOffset(dotSize, dotSize)
    dot.Position = UDim2.new(
        0.5, math.cos(angle) * radius - dotSize/2,
        0.5, math.sin(angle) * radius - dotSize/2
    )
    dot.BackgroundColor3 = CONFIG.COLORS.PRIMARY
    dot.BackgroundTransparency = 0.5
    dot.BorderSizePixel = 0
    dot.ZIndex = 10
    dot.Parent = LogoContainer
    CreateCorner(dot, UDim.new(1, 0))
    DecoDots[i] = dot
end

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 36)
TitleLabel.Position = UDim2.new(0, 0, 0, 140)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = CONFIG.TITLE
TitleLabel.TextColor3 = CONFIG.COLORS.TEXT
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 26
TitleLabel.ZIndex = 11
TitleLabel.Parent = Card

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
    ColorSequenceKeypoint.new(0.35, CONFIG.COLORS.PRIMARY),
    ColorSequenceKeypoint.new(0.65, CONFIG.COLORS.PRIMARY),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
})
TitleGradient.Parent = TitleLabel

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Name = "SubtitleLabel"
SubtitleLabel.Size = UDim2.new(1, 0, 0, 18)
SubtitleLabel.Position = UDim2.new(0, 0, 0, 172)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = CONFIG.SUBTITLE
SubtitleLabel.TextColor3 = CONFIG.COLORS.ACCENT
SubtitleLabel.Font = Enum.Font.GothamMedium
SubtitleLabel.TextSize = 13
SubtitleLabel.ZIndex = 11
SubtitleLabel.Parent = Card

local InputLabel = Instance.new("TextLabel")
InputLabel.Name = "InputLabel"
InputLabel.Size = UDim2.new(0.85, 0, 0, 22)
InputLabel.Position = UDim2.new(0.5, 0, 0, 205)
InputLabel.AnchorPoint = Vector2.new(0.5, 0)
InputLabel.BackgroundTransparency = 1
InputLabel.Text = "Enter Your Access Key"
InputLabel.TextColor3 = CONFIG.COLORS.TEXT
InputLabel.TextSize = 14
InputLabel.Font = Enum.Font.GothamSemibold
InputLabel.TextXAlignment = Enum.TextXAlignment.Left
InputLabel.ZIndex = 11
InputLabel.Parent = Card

local InputContainer = Instance.new("Frame")
InputContainer.Name = "InputContainer"
InputContainer.Size = UDim2.new(0.85, 0, 0, 56)
InputContainer.Position = UDim2.new(0.5, 0, 0, 232)
InputContainer.AnchorPoint = Vector2.new(0.5, 0)
InputContainer.BackgroundColor3 = CONFIG.COLORS.INPUT_BG
InputContainer.BorderSizePixel = 0
InputContainer.ZIndex = 11
InputContainer.Parent = Card

CreateCorner(InputContainer, UDim.new(0, 16))

local InputStroke = CreateStroke(InputContainer, CONFIG.COLORS.BUTTON_SECONDARY, 1.5, 0.3)
InputStroke.Name = "InputStroke"

local InputIcon = Instance.new("ImageLabel")
InputIcon.Name = "InputIcon"
InputIcon.Size = UDim2.fromOffset(20, 20)
InputIcon.Position = UDim2.new(0, 16, 0.5, 0)
InputIcon.AnchorPoint = Vector2.new(0, 0.5)
InputIcon.BackgroundTransparency = 1
InputIcon.ImageColor3 = CONFIG.COLORS.TEXT_DIM
InputIcon.ImageTransparency = 0.3
InputIcon.ZIndex = 12
InputIcon.Parent = InputContainer

ApplyIcon(InputIcon, "key")

local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Size = UDim2.new(1, -55, 1, 0)
KeyInput.Position = UDim2.new(0, 45, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Paste or type your key here..."
KeyInput.PlaceholderColor3 = CONFIG.COLORS.TEXT_MUTED
KeyInput.TextColor3 = CONFIG.COLORS.TEXT
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.ClearTextOnFocus = false
KeyInput.ZIndex = 12
KeyInput.Parent = InputContainer

KeyInput.Focused:Connect(function()
    Tween(InputStroke, {Color = CONFIG.COLORS.PRIMARY, Transparency = 0}, 0.25)
    Tween(InputContainer, {BackgroundColor3 = Color3.fromHex("#14141f")}, 0.25)
    Tween(InputIcon, {ImageColor3 = CONFIG.COLORS.PRIMARY, ImageTransparency = 0}, 0.25)
end)

KeyInput.FocusLost:Connect(function()
    Tween(InputStroke, {Color = CONFIG.COLORS.BUTTON_SECONDARY, Transparency = 0.3}, 0.25)
    Tween(InputContainer, {BackgroundColor3 = CONFIG.COLORS.INPUT_BG}, 0.25)
    Tween(InputIcon, {ImageColor3 = CONFIG.COLORS.TEXT_DIM, ImageTransparency = 0.3}, 0.25)
end)

local StatusContainer = Instance.new("Frame")
StatusContainer.Name = "StatusContainer"
StatusContainer.Size = UDim2.new(0.85, 0, 0, 24)
StatusContainer.Position = UDim2.new(0.5, 0, 0, 291)
StatusContainer.AnchorPoint = Vector2.new(0.5, 0)
StatusContainer.BackgroundTransparency = 1
StatusContainer.ZIndex = 11
StatusContainer.Parent = Card

local StatusLayout = Instance.new("UIListLayout")
StatusLayout.FillDirection = Enum.FillDirection.Horizontal
StatusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StatusLayout.VerticalAlignment = Enum.VerticalAlignment.Center
StatusLayout.Padding = UDim.new(0, 6)
StatusLayout.Parent = StatusContainer

local StatusIcon = Instance.new("ImageLabel")
StatusIcon.Name = "StatusIcon"
StatusIcon.Size = UDim2.fromOffset(14, 14)
StatusIcon.BackgroundTransparency = 1
StatusIcon.ImageColor3 = CONFIG.COLORS.ACCENT
StatusIcon.ImageTransparency = 1
StatusIcon.LayoutOrder = 1
StatusIcon.ZIndex = 12
StatusIcon.Parent = StatusContainer

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.fromOffset(0, 20)
StatusLabel.AutomaticSize = Enum.AutomaticSize.X
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = CONFIG.COLORS.ACCENT
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextTransparency = 1
StatusLabel.LayoutOrder = 2
StatusLabel.ZIndex = 11
StatusLabel.Parent = StatusContainer

local function ShowStatus(message, color, duration, iconName)
    StatusLabel.Text = message
    StatusLabel.TextColor3 = color or CONFIG.COLORS.ACCENT
    Tween(StatusLabel, {TextTransparency = 0}, 0.2)
    
    if iconName then
        ApplyIcon(StatusIcon, iconName)
        StatusIcon.ImageColor3 = color or CONFIG.COLORS.ACCENT
        StatusIcon.Size = UDim2.fromOffset(14, 14)
        Tween(StatusIcon, {ImageTransparency = 0}, 0.2)
    else
        StatusIcon.Size = UDim2.fromOffset(0, 0)
        Tween(StatusIcon, {ImageTransparency = 1}, 0.2)
    end
    
    if duration then
        task.delay(duration, function()
            Tween(StatusLabel, {TextTransparency = 1}, 0.4)
            Tween(StatusIcon, {ImageTransparency = 1}, 0.4)
        end)
    end
end

local function HideStatus()
    Tween(StatusLabel, {TextTransparency = 1}, 0.3)
    Tween(StatusIcon, {ImageTransparency = 1}, 0.3)
end

local VerifyButton = Instance.new("TextButton")
VerifyButton.Name = "VerifyButton"
VerifyButton.Size = UDim2.new(0.85, 0, 0, 52)
VerifyButton.Position = UDim2.new(0.5, 0, 0, 320)
VerifyButton.AnchorPoint = Vector2.new(0.5, 0)
VerifyButton.BackgroundColor3 = CONFIG.COLORS.SECONDARY
VerifyButton.BorderSizePixel = 0
VerifyButton.Text = ""
VerifyButton.AutoButtonColor = false
VerifyButton.ZIndex = 11
VerifyButton.Parent = Card

CreateCorner(VerifyButton, UDim.new(0, 16))

local VerifyGradient = Instance.new("UIGradient")
VerifyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.COLORS.SECONDARY),
    ColorSequenceKeypoint.new(1, CONFIG.COLORS.PRIMARY)
})
VerifyGradient.Rotation = 45
VerifyGradient.Parent = VerifyButton

local VerifyStroke = CreateStroke(VerifyButton, CONFIG.COLORS.ACCENT, 1, 0.7)

local VerifyContent = Instance.new("Frame")
VerifyContent.Name = "Content"
VerifyContent.Size = UDim2.fromScale(1, 1)
VerifyContent.BackgroundTransparency = 1
VerifyContent.ZIndex = 12
VerifyContent.Parent = VerifyButton

local VerifyIcon = Instance.new("ImageLabel")
VerifyIcon.Name = "Icon"
VerifyIcon.Size = UDim2.fromOffset(20, 20)
VerifyIcon.Position = UDim2.new(0.5, -50, 0.5, 0)
VerifyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
VerifyIcon.BackgroundTransparency = 1
VerifyIcon.ImageColor3 = CONFIG.COLORS.TEXT
VerifyIcon.ZIndex = 13
VerifyIcon.Parent = VerifyContent

ApplyIcon(VerifyIcon, "shield-check")

local VerifyText = Instance.new("TextLabel")
VerifyText.Name = "Text"
VerifyText.Size = UDim2.new(1, -40, 1, 0)
VerifyText.Position = UDim2.new(0.5, 10, 0, 0)
VerifyText.AnchorPoint = Vector2.new(0.5, 0)
VerifyText.BackgroundTransparency = 1
VerifyText.Text = "VERIFY KEY"
VerifyText.TextColor3 = CONFIG.COLORS.TEXT
VerifyText.TextSize = 14
VerifyText.Font = Enum.Font.GothamBlack
VerifyText.ZIndex = 13
VerifyText.Parent = VerifyContent

VerifyButton.MouseEnter:Connect(function()
    Tween(VerifyButton, {
        Size = UDim2.new(0.88, 0, 0, 56),
        Position = UDim2.new(0.5, 0, 0, 318)
    }, 0.2, Enum.EasingStyle.Back)
    Tween(VerifyStroke, {Transparency = 0.3}, 0.2)
end)

VerifyButton.MouseLeave:Connect(function()
    Tween(VerifyButton, {
        Size = UDim2.new(0.85, 0, 0, 52),
        Position = UDim2.new(0.5, 0, 0, 320)
    }, 0.2)
    Tween(VerifyStroke, {Transparency = 0.7}, 0.2)
end)

local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Name = "GetKeyButton"
GetKeyButton.Size = UDim2.new(0.85, 0, 0, 48)
GetKeyButton.Position = UDim2.new(0.5, 0, 0, 382)
GetKeyButton.AnchorPoint = Vector2.new(0.5, 0)
GetKeyButton.BackgroundColor3 = CONFIG.COLORS.BUTTON_SECONDARY
GetKeyButton.BorderSizePixel = 0
GetKeyButton.Text = ""
GetKeyButton.AutoButtonColor = false
GetKeyButton.ZIndex = 11
GetKeyButton.Parent = Card

CreateCorner(GetKeyButton, UDim.new(0, 16))

local GetKeyStroke = CreateStroke(GetKeyButton, CONFIG.COLORS.TEXT_MUTED, 1, 0.7)

local GetKeyContent = Instance.new("Frame")
GetKeyContent.Name = "Content"
GetKeyContent.Size = UDim2.fromScale(1, 1)
GetKeyContent.BackgroundTransparency = 1
GetKeyContent.ZIndex = 12
GetKeyContent.Parent = GetKeyButton

local GetKeyIcon = Instance.new("ImageLabel")
GetKeyIcon.Name = "Icon"
GetKeyIcon.Size = UDim2.fromOffset(18, 18)
GetKeyIcon.Position = UDim2.new(0.5, -55, 0.5, 0)
GetKeyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
GetKeyIcon.BackgroundTransparency = 1
GetKeyIcon.ImageColor3 = CONFIG.COLORS.TEXT_DIM
GetKeyIcon.ZIndex = 13
GetKeyIcon.Parent = GetKeyContent

ApplyIcon(GetKeyIcon, "external-link")

local GetKeyText = Instance.new("TextLabel")
GetKeyText.Name = "Text"
GetKeyText.Size = UDim2.new(1, -40, 1, 0)
GetKeyText.Position = UDim2.new(0.5, 5, 0, 0)
GetKeyText.AnchorPoint = Vector2.new(0.5, 0)
GetKeyText.BackgroundTransparency = 1
GetKeyText.Text = "GET KEY LINK"
GetKeyText.TextColor3 = CONFIG.COLORS.TEXT_DIM
GetKeyText.TextSize = 13
GetKeyText.Font = Enum.Font.GothamBold
GetKeyText.ZIndex = 13
GetKeyText.Parent = GetKeyContent

local Underline = Instance.new("Frame")
Underline.Name = "Underline"
Underline.Size = UDim2.new(0, 0, 0, 2)
Underline.Position = UDim2.new(0.5, 0, 1, -8)
Underline.AnchorPoint = Vector2.new(0.5, 0)
Underline.BackgroundColor3 = CONFIG.COLORS.PRIMARY
Underline.BorderSizePixel = 0
Underline.ZIndex = 13
Underline.Parent = GetKeyButton
CreateCorner(Underline, UDim.new(1, 0))

GetKeyButton.MouseEnter:Connect(function()
    Tween(Underline, {Size = UDim2.new(0.5, 0, 0, 2)}, 0.3)
    Tween(GetKeyText, {TextColor3 = CONFIG.COLORS.TEXT}, 0.2)
    Tween(GetKeyIcon, {ImageColor3 = CONFIG.COLORS.PRIMARY}, 0.2)
end)

GetKeyButton.MouseLeave:Connect(function()
    Tween(Underline, {Size = UDim2.new(0, 0, 0, 2)}, 0.3)
    Tween(GetKeyText, {TextColor3 = CONFIG.COLORS.TEXT_DIM}, 0.2)
    Tween(GetKeyIcon, {ImageColor3 = CONFIG.COLORS.TEXT_DIM}, 0.2)
end)

local RememberSection = Instance.new("Frame")
RememberSection.Name = "RememberSection"
RememberSection.Size = UDim2.new(0.85, 0, 0, 40)
RememberSection.Position = UDim2.new(0.5, 0, 0, 440)
RememberSection.AnchorPoint = Vector2.new(0.5, 0)
RememberSection.BackgroundTransparency = 1
RememberSection.ZIndex = 11
RememberSection.Parent = Card

local RememberIcon = Instance.new("ImageLabel")
RememberIcon.Name = "Icon"
RememberIcon.Size = UDim2.fromOffset(16, 16)
RememberIcon.Position = UDim2.new(0, 0, 0.5, 0)
RememberIcon.AnchorPoint = Vector2.new(0, 0.5)
RememberIcon.BackgroundTransparency = 1
RememberIcon.ImageColor3 = CONFIG.COLORS.TEXT_DIM
RememberIcon.ZIndex = 12
RememberIcon.Parent = RememberSection

ApplyIcon(RememberIcon, "bookmark")

local RememberLabel = Instance.new("TextLabel")
RememberLabel.Name = "Label"
RememberLabel.Size = UDim2.new(0.6, 0, 1, 0)
RememberLabel.Position = UDim2.new(0, 24, 0, 0)
RememberLabel.BackgroundTransparency = 1
RememberLabel.Text = "Remember Key"
RememberLabel.TextColor3 = CONFIG.COLORS.TEXT_DIM
RememberLabel.TextSize = 13
RememberLabel.Font = Enum.Font.GothamMedium
RememberLabel.TextXAlignment = Enum.TextXAlignment.Left
RememberLabel.ZIndex = 12
RememberLabel.Parent = RememberSection

local ToggleTrack = Instance.new("Frame")
ToggleTrack.Name = "ToggleTrack"
ToggleTrack.Size = UDim2.fromOffset(50, 28)
ToggleTrack.Position = UDim2.new(1, 0, 0.5, 0)
ToggleTrack.AnchorPoint = Vector2.new(1, 0.5)
ToggleTrack.BackgroundColor3 = Color3.fromHex("#2a2a3a")
ToggleTrack.BorderSizePixel = 0
ToggleTrack.ZIndex = 12
ToggleTrack.Parent = RememberSection
CreateCorner(ToggleTrack, UDim.new(1, 0))

local ToggleKnob = Instance.new("Frame")
ToggleKnob.Name = "Knob"
ToggleKnob.Size = UDim2.fromOffset(22, 22)
ToggleKnob.Position = UDim2.new(0, 3, 0.5, 0)
ToggleKnob.AnchorPoint = Vector2.new(0, 0.5)
ToggleKnob.BackgroundColor3 = CONFIG.COLORS.TEXT
ToggleKnob.BorderSizePixel = 0
ToggleKnob.ZIndex = 13
ToggleKnob.Parent = ToggleTrack
CreateCorner(ToggleKnob, UDim.new(1, 0))

local KnobStroke = CreateStroke(ToggleKnob, Color3.new(0, 0, 0), 1, 0.85)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleHitbox"
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = ""
ToggleButton.ZIndex = 14
ToggleButton.Parent = ToggleTrack

local rememberEnabled = false

ToggleButton.MouseButton1Click:Connect(function()
    rememberEnabled = not rememberEnabled
    
    if rememberEnabled then
        Tween(ToggleKnob, {Position = UDim2.new(1, -25, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
        Tween(ToggleTrack, {BackgroundColor3 = CONFIG.COLORS.PRIMARY}, 0.25)
        Tween(RememberIcon, {ImageColor3 = CONFIG.COLORS.PRIMARY}, 0.2)
    else
        Tween(ToggleKnob, {Position = UDim2.new(0, 3, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
        Tween(ToggleTrack, {BackgroundColor3 = Color3.fromHex("#2a2a3a")}, 0.25)
        Tween(RememberIcon, {ImageColor3 = CONFIG.COLORS.TEXT_DIM}, 0.2)
        DeleteSavedKey()
    end
end)

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Size = UDim2.new(1, 0, 0, 16)
VersionLabel.Position = UDim2.new(0, 0, 1, -20)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = CONFIG.VERSION .. " | " .. CONFIG.AUTHOR
VersionLabel.TextColor3 = Color3.fromHex("#3a3a4a")
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 10
VersionLabel.ZIndex = 11
VersionLabel.Parent = Card

for _, shadow in ipairs(ShadowLayers) do
    shadow.BackgroundTransparency = 1
end

CardContainer.Position = UDim2.fromScale(0.5, 0.55)
Card.BackgroundTransparency = 1
CardBorder.Transparency = 1
InnerGlow.BackgroundTransparency = 1
LogoRing.BackgroundTransparency = 1
LogoRingBorder.Transparency = 1
OuterGlow.BackgroundTransparency = 1
KeyIcon.ImageTransparency = 1
WelcomeText.TextTransparency = 1
TitleLabel.TextTransparency = 1
SubtitleLabel.TextTransparency = 1
InputLabel.TextTransparency = 1
InputContainer.BackgroundTransparency = 1
InputStroke.Transparency = 1
InputIcon.ImageTransparency = 1
KeyInput.TextTransparency = 1
VerifyButton.BackgroundTransparency = 1
VerifyStroke.Transparency = 1
VerifyIcon.ImageTransparency = 1
VerifyText.TextTransparency = 1
GetKeyButton.BackgroundTransparency = 1
GetKeyStroke.Transparency = 1
GetKeyIcon.ImageTransparency = 1
GetKeyText.TextTransparency = 1
RememberSection.Visible = false
VersionLabel.TextTransparency = 1
MinimizeButton.BackgroundTransparency = 1
MinimizeIcon.ImageTransparency = 1
MinimizeStroke.Transparency = 1

for _, dot in ipairs(DecoDots) do
    dot.BackgroundTransparency = 1
end

task.spawn(function()
    local rotation = 135
    while KeySystemGui and KeySystemGui.Parent do
        if not isMinimized then
            rotation = (rotation + 0.08) % 360
            BGGradient.Rotation = rotation
        end
        task.wait(0.03)
    end
end)

task.spawn(function()
    while KeySystemGui and KeySystemGui.Parent do
        CreateFloatingCrystal()
        task.wait(math.random(CONFIG.PARTICLES.CRYSTAL_SPAWN_MIN * 100, CONFIG.PARTICLES.CRYSTAL_SPAWN_MAX * 100) / 100)
    end
end)

task.spawn(function()
    while KeySystemGui and KeySystemGui.Parent do
        CreateStarParticle()
        task.wait(math.random(CONFIG.PARTICLES.STAR_SPAWN_MIN * 100, CONFIG.PARTICLES.STAR_SPAWN_MAX * 100) / 100)
    end
end)

task.spawn(function()
    while KeySystemGui and KeySystemGui.Parent do
        if not isMinimized then
            Tween(LogoContainer, {Position = UDim2.new(0.5, 0, 0, 48)}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
            if not KeySystemGui or not KeySystemGui.Parent or isMinimized then break end
            Tween(LogoContainer, {Position = UDim2.new(0.5, 0, 0, 52)}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while KeySystemGui and KeySystemGui.Parent do
        if not isMinimized then
            Tween(KeyIconContainer, {Size = UDim2.fromOffset(39, 39)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            if not KeySystemGui or not KeySystemGui.Parent or isMinimized then break end
            Tween(KeyIconContainer, {Size = UDim2.fromOffset(34, 34)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    local offset = 0
    while KeySystemGui and KeySystemGui.Parent do
        if not isMinimized then
            offset = (offset + 0.005) % 1
            TitleGradient.Offset = Vector2.new(offset - 0.5, 0)
        end
        task.wait(0.03)
    end
end)

task.spawn(function()
    while KeySystemGui and KeySystemGui.Parent do
        if not isMinimized then
            Tween(CardBorder, {Transparency = 0.6}, 1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.8)
            if not KeySystemGui or not KeySystemGui.Parent or isMinimized then break end
            Tween(CardBorder, {Transparency = 0.25}, 1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.8)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while KeySystemGui and KeySystemGui.Parent do
        if not isMinimized then
            Tween(OuterGlow, {BackgroundTransparency = 0.82}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
            if not KeySystemGui or not KeySystemGui.Parent or isMinimized then break end
            Tween(OuterGlow, {BackgroundTransparency = 0.92}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while KeySystemGui and KeySystemGui.Parent do
        if not isMinimized then
            for i, dot in ipairs(DecoDots) do
                task.delay(i * 0.08, function()
                    if not KeySystemGui or not KeySystemGui.Parent or isMinimized then return end
                    Tween(dot, {BackgroundTransparency = 0.25}, 0.4)
                    task.wait(0.4)
                    if not KeySystemGui or not KeySystemGui.Parent or isMinimized then return end
                    Tween(dot, {BackgroundTransparency = 0.65}, 0.4)
                end)
            end
            task.wait(1.5)
        else
            task.wait(0.1)
        end
    end
end)

local function ShakeCard()
    local originalPos = CardContainer.Position
    for i = 1, 6 do
        CardContainer.Position = UDim2.new(0.5, math.random(-10, 10), 0.5, math.random(-4, 4))
        task.wait(0.04)
    end
    Tween(CardContainer, {Position = originalPos}, 0.15)
end

local function ExecuteScript(url)
    if url and url ~= "" then
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet(url))()
            end)
        end)
    end
end

local function SuccessClose()
    for i = 1, 10 do
        local burst = Instance.new("ImageLabel")
        burst.Size = UDim2.fromOffset(24, 24)
        burst.Position = UDim2.fromScale(0.5, 0.3)
        burst.AnchorPoint = Vector2.new(0.5, 0.5)
        burst.BackgroundTransparency = 1
        burst.ImageColor3 = CONFIG.COLORS.SUCCESS
        burst.ZIndex = 20
        burst.Parent = Card
        
        ApplyIcon(burst, "sparkles")
        
        local angle = (i / 10) * math.pi * 2
        local distance = 140
        
        task.spawn(function()
            Tween(burst, {
                Position = UDim2.new(0.5, math.cos(angle) * distance, 0.3, math.sin(angle) * distance),
                ImageTransparency = 1,
                Rotation = 360
            }, 0.7)
            task.wait(0.7)
            if burst and burst.Parent then burst:Destroy() end
        end)
    end
    
    task.wait(0.9)
    
    local fadeTime = 0.45
    
    Tween(CardContainer, {Position = UDim2.fromScale(0.5, 0.45)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Tween(Card, {BackgroundTransparency = 1}, fadeTime)
    
    for _, shadow in ipairs(ShadowLayers) do
        Tween(shadow, {BackgroundTransparency = 1}, fadeTime)
    end
    
    Tween(CardBorder, {Transparency = 1}, fadeTime)
    Tween(InnerGlow, {BackgroundTransparency = 1}, fadeTime)
    Tween(LogoRing, {BackgroundTransparency = 1}, fadeTime)
    Tween(LogoRingBorder, {Transparency = 1}, fadeTime)
    Tween(OuterGlow, {BackgroundTransparency = 1}, fadeTime)
    Tween(KeyIcon, {ImageTransparency = 1}, fadeTime)
    Tween(WelcomeText, {TextTransparency = 1}, fadeTime)
    Tween(TitleLabel, {TextTransparency = 1}, fadeTime)
    Tween(SubtitleLabel, {TextTransparency = 1}, fadeTime)
    Tween(InputLabel, {TextTransparency = 1}, fadeTime)
    Tween(InputContainer, {BackgroundTransparency = 1}, fadeTime)
    Tween(InputStroke, {Transparency = 1}, fadeTime)
    Tween(InputIcon, {ImageTransparency = 1}, fadeTime)
    Tween(KeyInput, {TextTransparency = 1}, fadeTime)
    Tween(VerifyButton, {BackgroundTransparency = 1}, fadeTime)
    Tween(VerifyStroke, {Transparency = 1}, fadeTime)
    Tween(VerifyIcon, {ImageTransparency = 1}, fadeTime)
    Tween(VerifyText, {TextTransparency = 1}, fadeTime)
    Tween(GetKeyButton, {BackgroundTransparency = 1}, fadeTime)
    Tween(GetKeyStroke, {Transparency = 1}, fadeTime)
    Tween(GetKeyIcon, {ImageTransparency = 1}, fadeTime)
    Tween(GetKeyText, {TextTransparency = 1}, fadeTime)
    Tween(StatusLabel, {TextTransparency = 1}, fadeTime)
    Tween(StatusIcon, {ImageTransparency = 1}, fadeTime)
    Tween(VersionLabel, {TextTransparency = 1}, fadeTime)
    Tween(MinimizeButton, {BackgroundTransparency = 1}, fadeTime)
    Tween(MinimizeIcon, {ImageTransparency = 1}, fadeTime)
    
    for _, dot in ipairs(DecoDots) do
        Tween(dot, {BackgroundTransparency = 1}, fadeTime)
    end
    
    task.wait(fadeTime)
    
    Tween(GradientOverlay, {BackgroundTransparency = 1}, 0.5)
    Tween(Background, {BackgroundTransparency = 1}, 0.5)
    Tween(Vignette, {ImageTransparency = 1}, 0.5)
    
    for _, crystal in ipairs(bgCrystals) do
        if crystal and crystal.Parent then
            for _, child in ipairs(crystal:GetChildren()) do
                if child:IsA("ImageLabel") then
                    Tween(child, {ImageTransparency = 1}, 0.4)
                end
            end
        end
    end
    
    task.wait(0.6)
    
    local scriptUrl = CONFIG.SCRIPT_URL
    
    if KeySystemGui and KeySystemGui.Parent then
        KeySystemGui:Destroy()
    end
    
    task.wait(0.2)
    
    ExecuteScript(scriptUrl)
end

local function CheckHWIDBan()
    if not JUNKIE_CONFIG.ENABLE_HWID_CHECK then
        return false, nil
    end
    
    local hwid = GetHWID()
    
    if JunkieSDK then
        local checkFunc = JunkieSDK.IsHwidBanned or JunkieSDK.isHwidBanned
        if checkFunc then
            local success, result = pcall(function()
                return checkFunc(JUNKIE_CONFIG.API_KEY, hwid, JUNKIE_CONFIG.SERVICE_ID)
            end)
            
            if success and result then
                if type(result) == "table" and result.is_banned then
                    return true, result.ban_reason or "No reason provided"
                elseif result == true then
                    return true, "HWID Banned"
                end
            end
        end
    end
    
    return false, nil
end

local function CheckKeylessMode()
    if not JUNKIE_CONFIG.ENABLE_KEYLESS_CHECK then
        return false
    end
    
    if JunkieSDK and JunkieSDK.isKeylessMode then
        local success, result = pcall(function()
            return JunkieSDK.isKeylessMode(
                JUNKIE_CONFIG.API_KEY,
                JUNKIE_CONFIG.SERVICE_ID
            )
        end)
        
        if success then
            if type(result) == "boolean" then
                return result
            elseif type(result) == "table" then
                return result.keyless_mode or result.keyless or result.enabled or false
            elseif type(result) == "string" then
                return result == "true" or result == "enabled"
            end
        end
    end
    
    return false
end

local function GetKeyLink()
    if JunkieSDK and JunkieSDK.getLink then
        local success, link = pcall(function()
            return JunkieSDK.getLink(
                JUNKIE_CONFIG.API_KEY,
                JUNKIE_CONFIG.PROVIDER,
                JUNKIE_CONFIG.SERVICE_ID
            )
        end)
        
        if success and link and link ~= "" then
            return link
        end
    end
    
    return nil
end

local function ValidateKeyAPI(key)
    if not JunkieSDK or not JunkieSDK.verifyKey then
        return false
    end
    
    local success, result = pcall(function()
        return JunkieSDK.verifyKey(
            JUNKIE_CONFIG.API_KEY,
            key,
            JUNKIE_CONFIG.SERVICE_ID
        )
    end)
    
    if success then
        if type(result) == "boolean" then
            return result
        elseif type(result) == "string" then
            return result == "valid" or result == "true"
        elseif type(result) == "table" then
            return result.valid == true or result.success == true
        end
    end
    
    return false
end

local function CheckPremiumStatus()
    return false
end

local function GetKeyExpiration()
    return nil
end

local function VerifyKey(key, isAutoVerify)
    if key == "" then
        if not isAutoVerify then
            ShowStatus("Please enter a key!", CONFIG.COLORS.WARNING, 2.5, "alert-triangle")
            ShakeCard()
        end
        return
    end
    
    ShowStatus("Verifying key...", CONFIG.COLORS.ACCENT, nil, "loader-2")
    VerifyText.Text = "VERIFYING..."
    ApplyIcon(VerifyIcon, "loader-2")
    
    task.wait(0.8)
    
    if JUNKIE_CONFIG.ENABLE_HWID_CHECK then
        ShowStatus("Checking HWID...", CONFIG.COLORS.ACCENT, nil, "fingerprint")
        task.wait(0.3)
        
        local isBanned, banReason = CheckHWIDBan()
        if isBanned then
            ShowStatus("Hardware Banned: " .. banReason, CONFIG.COLORS.ERROR, 5, "ban")
            VerifyText.Text = "BANNED"
            ApplyIcon(VerifyIcon, "ban")
            ShakeCard()
            
            VerifyGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CONFIG.COLORS.ERROR),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#dc2626"))
            })
            
            task.wait(3)
            Players.LocalPlayer:Kick("Hardware banned: " .. banReason)
            return
        end
    end
    
    ShowStatus("Validating key...", CONFIG.COLORS.ACCENT, nil, "shield")
    task.wait(0.5)
    
    local isValid = ValidateKeyAPI(key)
    
    if isValid then
        local isPremium = CheckPremiumStatus()
        local expiresAt = GetKeyExpiration()
        
        local successMessage = "Access Granted!"
        local successColor = CONFIG.COLORS.SUCCESS
        local successIcon = "check-circle"
        
        if isPremium then
            successMessage = "Premium Access Granted!"
            successColor = CONFIG.COLORS.PREMIUM
            successIcon = "crown"
        end
        
        if expiresAt then
            local currentTime = os.time()
            if currentTime < expiresAt then
                local timeLeft = expiresAt - currentTime
                local daysLeft = math.floor(timeLeft / 86400)
                local hoursLeft = math.floor((timeLeft % 86400) / 3600)
                
                if daysLeft > 0 then
                    successMessage = successMessage .. " (" .. daysLeft .. " days left)"
                elseif hoursLeft > 0 then
                    successMessage = successMessage .. " (" .. hoursLeft .. " hours left)"
                else
                    successMessage = successMessage .. " (Expires soon!)"
                end
            end
        end
        
        ShowStatus(successMessage, successColor, 2.5, successIcon)
        VerifyText.Text = "SUCCESS"
        ApplyIcon(VerifyIcon, "check")
        
        if isPremium then
            VerifyGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CONFIG.COLORS.PREMIUM),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#f59e0b"))
            })
        else
            VerifyGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CONFIG.COLORS.SUCCESS),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#22c55e"))
            })
        end
        
        if rememberEnabled then
            pcall(function()
                writefile("JunkieKey_Saved.txt", key)
            end)
        end
        
        task.wait(2)
        
        SuccessClose()
        
    else
        ShowStatus("Invalid Key!", CONFIG.COLORS.ERROR, 3, "x-circle")
        VerifyText.Text = "VERIFY KEY"
        ApplyIcon(VerifyIcon, "shield-check")
        ShakeCard()
        
        VerifyGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CONFIG.COLORS.ERROR),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#dc2626"))
        })
        
        task.wait(0.35)
        
        VerifyGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CONFIG.COLORS.SECONDARY),
            ColorSequenceKeypoint.new(1, CONFIG.COLORS.PRIMARY)
        })
    end
end

VerifyButton.MouseButton1Click:Connect(function()
    VerifyKey(KeyInput.Text, false)
end)

GetKeyButton.MouseButton1Click:Connect(function()
    ShowStatus("Generating key link...", CONFIG.COLORS.ACCENT, nil, "link")
    
    task.spawn(function()
        local link = GetKeyLink()
        
        if link then
            local copied = false
            pcall(function()
                setclipboard(link)
                copied = true
            end)
            
            if copied then
                ShowStatus("Key link copied to clipboard!", CONFIG.COLORS.SUCCESS, 3, "clipboard-check")
            else
                ShowStatus("Link: " .. link, CONFIG.COLORS.ACCENT, 8, "link")
            end
        else
            ShowStatus("Failed to generate link. Try again!", CONFIG.COLORS.ERROR, 3, "alert-circle")
        end
    end)
end)

KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        VerifyKey(KeyInput.Text, false)
    end
end)

local savedKeyLoaded = false
local savedKeyValue = nil

pcall(function()
    if isfile and isfile("JunkieKey_Saved.txt") then
        local savedKey = readfile("JunkieKey_Saved.txt")
        if savedKey and savedKey ~= "" then
            KeyInput.Text = savedKey
            savedKeyValue = savedKey
            savedKeyLoaded = true
            rememberEnabled = true
            ToggleKnob.Position = UDim2.new(1, -25, 0.5, 0)
            ToggleTrack.BackgroundColor3 = CONFIG.COLORS.PRIMARY
            RememberIcon.ImageColor3 = CONFIG.COLORS.PRIMARY
        end
    end
end)

task.spawn(function()
    ShowStatus("Loading SDK...", CONFIG.COLORS.ACCENT, nil, "download")
    local sdkLoaded = LoadJunkieSDK()
    
    if not sdkLoaded then
        ShowStatus("SDK failed to load", CONFIG.COLORS.WARNING, 4, "alert-triangle")
        task.wait(2)
        HideStatus()
        return
    end
    
    if JUNKIE_CONFIG.ENABLE_KEYLESS_CHECK then
        task.wait(0.3)
        ShowStatus("Checking keyless mode...", CONFIG.COLORS.ACCENT, nil, "unlock")
        
        local isKeyless = CheckKeylessMode()
        if isKeyless then
            ShowStatus("Keyless mode enabled!", CONFIG.COLORS.SUCCESS, 2, "sparkles")
            task.wait(2)
            SuccessClose()
            return
        end
    end
    
    if JUNKIE_CONFIG.ENABLE_HWID_CHECK then
        task.wait(0.3)
        ShowStatus("Checking HWID status...", CONFIG.COLORS.ACCENT, nil, "fingerprint")
        
        local isBanned, banReason = CheckHWIDBan()
        if isBanned then
            ShowStatus("Hardware Banned!", CONFIG.COLORS.ERROR, nil, "ban")
            task.wait(2)
            Players.LocalPlayer:Kick("Hardware banned: " .. (banReason or "No reason provided"))
            return
        end
    end
    
    task.wait(0.5)
    
    if savedKeyLoaded and savedKeyValue and savedKeyValue ~= "" then
        ShowStatus("Auto-verifying saved key...", CONFIG.COLORS.ACCENT, nil, "key")
        task.wait(0.5)
        VerifyKey(savedKeyValue, true)
    else
        HideStatus()
    end
end)

task.spawn(function()
    task.wait(0.2)
    
    Tween(CardContainer, {Position = UDim2.fromScale(0.5, 0.5)}, 0.9, Enum.EasingStyle.Back)
    Tween(Card, {BackgroundTransparency = 0.02}, 0.7)
    
    for i, shadow in ipairs(ShadowLayers) do
        local targetTransparency = shadow.Name == "CardShadow1" and 0.82 or (shadow.Name == "CardShadow2" and 0.72 or 0.62)
        task.delay(i * 0.05, function()
            Tween(shadow, {BackgroundTransparency = targetTransparency}, 0.7)
        end)
    end
    
    Tween(CardBorder, {Transparency = 0.4}, 0.7)
    Tween(InnerGlow, {BackgroundTransparency = 0.92}, 0.7)
    
    task.wait(0.1)
    
    Tween(LogoRing, {BackgroundTransparency = 0.2}, 0.5)
    Tween(LogoRingBorder, {Transparency = 0.15}, 0.5)
    Tween(OuterGlow, {BackgroundTransparency = 0.88}, 0.5)
    Tween(KeyIcon, {ImageTransparency = 0}, 0.6)
    
    Tween(MinimizeButton, {BackgroundTransparency = 0.3}, 0.5)
    Tween(MinimizeIcon, {ImageTransparency = 0}, 0.5)
    Tween(MinimizeStroke, {Transparency = 0.7}, 0.5)
    
    for i, dot in ipairs(DecoDots) do
        task.delay(i * 0.05, function()
            Tween(dot, {BackgroundTransparency = 0.5}, 0.4)
        end)
    end
    
    task.wait(0.15)
    
    Tween(WelcomeText, {TextTransparency = 0}, 0.5)
    Tween(TitleLabel, {TextTransparency = 0}, 0.6)
    Tween(SubtitleLabel, {TextTransparency = 0}, 0.5)
    
    task.wait(0.1)
    
    Tween(InputLabel, {TextTransparency = 0}, 0.5)
    Tween(InputContainer, {BackgroundTransparency = 0}, 0.5)
    Tween(InputStroke, {Transparency = 0.3}, 0.5)
    Tween(InputIcon, {ImageTransparency = 0.3}, 0.5)
    Tween(KeyInput, {TextTransparency = 0}, 0.5)
    
    task.wait(0.1)
    
    Tween(VerifyButton, {BackgroundTransparency = 0}, 0.5)
    Tween(VerifyStroke, {Transparency = 0.7}, 0.5)
    Tween(VerifyIcon, {ImageTransparency = 0}, 0.5)
    Tween(VerifyText, {TextTransparency = 0}, 0.5)
    
    task.wait(0.08)
    
    Tween(GetKeyButton, {BackgroundTransparency = 0}, 0.5)
    Tween(GetKeyStroke, {Transparency = 0.7}, 0.5)
    Tween(GetKeyIcon, {ImageTransparency = 0}, 0.5)
    Tween(GetKeyText, {TextTransparency = 0}, 0.5)
    
    task.wait(0.1)
    
    RememberSection.Visible = true
    
    Tween(VersionLabel, {TextTransparency = 0}, 0.5)
end)
