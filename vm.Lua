-- OnlineWatermark.lua
-- Модуль создания Watermark-панели (показывает "Online: X").
-- Особенности: тёмный фон, скруглённые углы, тонкая обводка, изменение ширины по тексту, перетаскивание, методы API.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local OnlineWatermark = {}
OnlineWatermark.__index = OnlineWatermark

-- Default constants (можно переопределить при необходимости):
OnlineWatermark.DefaultFont = Enum.Font.SourceSansSemibold
OnlineWatermark.DefaultFontSize = 14
OnlineWatermark.DefaultTextColor = Color3.new(1, 1, 1)                -- белый
OnlineWatermark.DefaultBackgroundColor = Color3.fromRGB(30, 30, 30)  -- тёмно-серый фон
OnlineWatermark.DefaultAccentColor = Color3.fromRGB(0, 170, 255)     -- акцент (синий)
OnlineWatermark.DefaultPadding = 8
OnlineWatermark.DefaultCornerRadius = UDim.new(0, 6)
OnlineWatermark.DefaultStrokeThickness = 1

-- Вспомогательная функция: создаёт объект GUI с заданными свойствами
local function createGuiObject(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- Конструктор
function OnlineWatermark.new(parent)
    local self = setmetatable({}, OnlineWatermark)

    -- Создаем ScreenGui и помещаем в PlayerGui (или переданный parent)
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OnlineWatermark"
    screenGui.Parent = parent or playerGui

    -- Создаём фрейм Watermark
    local frame = createGuiObject("Frame", {
        Name = "WatermarkFrame",
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 10, 0, 10),  -- левый верхний угол с отступом (10,10)
        BackgroundColor3 = OnlineWatermark.DefaultBackgroundColor,
        Size = UDim2.new(0, 0, 0, 0),       -- начальная ширина 0, потом будет подгоняться
        ZIndex = 1,
        ClipsDescendants = true,
    })
    frame.Parent = screenGui

    -- Скругление углов
    createGuiObject("UICorner", {
        CornerRadius = OnlineWatermark.DefaultCornerRadius,
        Parent = frame,
    })
    -- Обводка (тонкая рамка)
    local stroke = createGuiObject("UIStroke", {
        Color = OnlineWatermark.DefaultAccentColor,
        Thickness = OnlineWatermark.DefaultStrokeThickness,
        LineJoinMode = Enum.LineJoinMode.Round,
        Parent = frame,
    })

    -- Текстовая метка
    local label = createGuiObject("TextLabel", {
        Name = "WatermarkLabel",
        BackgroundTransparency = 1,
        TextColor3 = OnlineWatermark.DefaultTextColor,
        Text = "",
        Font = OnlineWatermark.DefaultFont,
        TextSize = OnlineWatermark.DefaultFontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Position = UDim2.new(0, OnlineWatermark.DefaultPadding, 0, OnlineWatermark.DefaultPadding),
        Size = UDim2.new(1, -OnlineWatermark.DefaultPadding*2, 1, -OnlineWatermark.DefaultPadding*2),
        Parent = frame,
    })
    -- Ограничение максимального размера текста (чтобы не превышать заданный шрифт)
    createGuiObject("UITextSizeConstraint", {
        MaxTextSize = OnlineWatermark.DefaultFontSize,
        Parent = label,
    })

    -- Сохраняем объекты в self
    self._screenGui = screenGui
    self._frame = frame
    self._label = label
    self._stroke = stroke
    self._visible = true

    -- Метод: установить произвольный текст
    function self:SetText(text)
        assert(type(text) == "string", "SetText ожидал строку, а получил "..typeof(text))
        self._label.Text = text
        -- Вычисляем пиксельный размер текста
        local size = TextService:GetTextSize(text, label.TextSize, label.Font, Vector2.new(math.huge, math.huge))
        local newWidth = size.X + OnlineWatermark.DefaultPadding * 2
        local newHeight = size.Y + OnlineWatermark.DefaultPadding * 2
        -- Плавно изменяем размер фрейма
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(frame, tweenInfo, {Size = UDim2.new(0, newWidth, 0, newHeight)}):Play()
    end

    -- Метод: установить "Online: N"
    function self:SetOnline(n)
        assert(typeof(n) == "number" or typeof(n) == "string", "SetOnline ожидал число или строку, а получил "..typeof(n))
        self:SetText("Online: " .. tostring(n))
    end

    function self:Show()
        self._frame.Visible = true
        self._visible = true
    end

    function self:Hide()
        self._frame.Visible = false
        self._visible = false
    end

    function self:Destroy()
        self._screenGui:Destroy()
    end

    -- Установить акцентный цвет (меняет цвет рамки)
    function self:SetAccentColor(color)
        assert(typeof(color) == "Color3", "SetAccentColor ожидал Color3, а получил "..typeof(color))
        stroke.Color = color
        -- label.TextColor3 = color  -- Можно также менять цвет текста, при желании
    end

    -- Перетаскивание мышью
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and dragInput and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Установим начальный текст и размеры сразу (без анимации)
    label.Text = "Online: 0"
    local initSize = TextService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(math.huge, math.huge))
    frame.Size = UDim2.new(0, initSize.X + OnlineWatermark.DefaultPadding * 2,
                           0, initSize.Y + OnlineWatermark.DefaultPadding * 2)

    return self
end

return OnlineWatermark
