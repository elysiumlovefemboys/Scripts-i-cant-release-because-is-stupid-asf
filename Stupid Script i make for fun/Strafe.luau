-- first time coding with a keyboard in 60%.. is lwk tuff😉
-- brown swiths :drooling_face: :drooling_face: :drooling_face: :drooling_face:

-- im dying in brazil help

-- Lib

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'FemToByte.su',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visual = Window:AddTab('Visual'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Lib End


-- Services ignore.

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Camera = workspace.CurrentCamera -- thats work for now
local LocalPlayer = Players.LocalPlayer

local Modules = cloneref(game:GetService("ReplicatedStorage")):WaitForChild("Modules")
local Combat = Modules:WaitForChild("Combat")
local CombatTargeting = require(Combat:WaitForChild("CombatTargeting"))
local CombatTeams = require(Combat:WaitForChild("CombatTeams"))

--characters
local CharacterIndex = require(Modules:WaitForChild("CharacterIndex"))
local BodyFolders = require(Modules:WaitForChild("BodyFolders"))
--characters


local fadeinNNNn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- really cool fade in and fadeout1!1!
local FadeoutialrlostNNN = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

-- Services ignore End


-- UI

local VisualGroup = Tabs.Visual:AddLeftGroupbox('Esp')
local CombatGroup = Tabs.Combat:AddLeftGroupbox('Aim')

CombatGroup:AddToggle('Combat // Aim // Enable', { Text = 'Enable', Default = false })
CombatGroup:AddLabel('Aim key'):AddKeyPicker('Combat // Aim // Keybind', { Default = 'MB2', SyncToggleState = false, Mode = 'Hold', Text = 'Aim key', NoUI = false })

CombatGroup:AddDropdown('Combat // Aim // Targets', {
    Values = { 'Humanoid', 'Npc' },
    Default = { 'Humanoid', 'Npc' },
    Multi = true,
    Text = 'Targets to aim',
})

CombatGroup:AddDropdown('Combat // Aim // Priority', {
    Values = { 'Closest', 'Head', 'LowerTorso', 'Torso', 'UpperTorso' },
    Default = 1,
    Multi = false,
    Text = 'Aim priority',
})


CombatGroup:AddToggle('Combat // Aim // TeamCheck', { Text = 'Team Check', Default = true })
CombatGroup:AddToggle('Combat // Aim // WallCheck', { Text = 'Wall Check', Default = true })


CombatGroup:AddSlider('Combat // Aim // Smooth', { Text = 'Smooth', Default = 10, Min = 1, Max = 30, Rounding = 0, Compact = false })
CombatGroup:AddSlider('Combat // Aim // FOV', { Text = 'FOV', Default = 250, Min = 50, Max = 800, Rounding = 0, Compact = false })



VisualGroup:AddToggle('Visual // ESP // Box', { Text = 'Box', Default = false })
VisualGroup:AddToggle('Visual // ESP // Name', { Text = 'Name', Default = false })
VisualGroup:AddToggle('Visual // ESP // TeamCheck', { Text = 'Team Check', Default = true })

VisualGroup:AddDropdown('Visual // ESP // Targets', {
    Values = { 'Humanoid', 'Npc' },
    Default = { 'Humanoid', 'Npc' },
    Multi = true,
    Text = 'Targets to draw',
})

-- we love christ dillinger
-- aegis if are u reading this. i copy ur UI with claude ai and im going to use in FemToByte.su because i hate u❤

-- UI End


-- Font

local Overlay = {}

function Overlay.NewFont(Name, Weight, Style, AssetId, FontUrl)
    if not isfile(AssetId) then
        writefile(AssetId, game:HttpGet(FontUrl))
    end

    if isfile(Name .. ".font") then
        delfile(Name .. ".font")
    end

    local Data = {
        name = Name,
        faces = {
            {
                name = "Regular",
                weight = Weight,
                style = Style,
                assetId = getcustomasset(AssetId)
            }
        }
    }

    writefile(Name .. ".font", cloneref(game:GetService("HttpService")):JSONEncode(Data))
    return getcustomasset(Name .. ".font")
end

local ProggyFontAsset = Overlay.NewFont("proggy",400,"normal","proggy.ttf","https://raw.githubusercontent.com/elysiumlovefemboys/Fonts/main/ToUSE/ProggyCleanBold.ttf")

local font = Font.new(ProggyFontAsset)

-- Font End


-- Gui

local gui = Instance.new("ScreenGui")
gui.Name = "simple_esp" --simple because i dont wanna code everything.
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Gui End


-- Utils

local utils = {}

function utils.getparts(char)
    local list = {}
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") and v.Transparency < 0.99 then
            list[#list + 1] = v
        end
    end
    return list
end

function utils.bounding(snap)
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    local onScreen = false
    for i = 1, #snap do
        local e = snap[i]
        local cf, h = e.cf, e.hs
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    local sp, visible = Camera:WorldToViewportPoint(cf * Vector3.new(x * h.X, y * h.Y, z * h.Z))
                    if visible then onScreen = true end
                    if sp.Z > 0 then
                        if sp.X < minX then minX = sp.X end
                        if sp.X > maxX then maxX = sp.X end
                        if sp.Y < minY then minY = sp.Y end
                        if sp.Y > maxY then maxY = sp.Y end
                    end
                end
            end
        end
    end
    if not onScreen or minX == math.huge then return end
    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

function utils.isSameTeam(model)
    return CombatTeams.passes_through(model) == true
end

function utils.project(pos)
    local s, on = Camera:WorldToViewportPoint(pos)
    return (on and s.Z > 0) and Vector2.new(s.X, s.Y) or nil
end

function utils.predict(part)
    return part.Position + part.AssemblyLinearVelocity / 13 -- 16 and 13 are the best
end


-- i dont know if this is the best way to do this but it works and i dont care. i just want to finish this script and play the game. (i hate coding)
local wallParams = RaycastParams.new()
wallParams.FilterType = Enum.RaycastFilterType.Exclude
wallParams.RespectCanCollide = true

local ignore = {}

function utils.wallchecktest()
    ignore = { Camera }
    local mine = LocalPlayer.Character
    if mine then table.insert(ignore, mine) end
    local own = CharacterIndex.of(LocalPlayer)
    if own and own ~= mine then table.insert(ignore, own) end
    for _, entry in ipairs(utils.collectChar({ Humanoid = true, Npc = true })) do
        table.insert(ignore, entry.model)
    end
end

function utils.visible(from, to)
    local ignore = table.clone(ignore)
    local direction = to - from
    for _ = 1, 4 do
        wallParams.FilterDescendantsInstances = ignore
        local hit = workspace:Raycast(from, direction, wallParams)
        if not hit then return true end
        if hit.Instance.Transparency < 0.95 then return false end
        table.insert(ignore, hit.Instance)
    end
    return false
end
-- i dont know if this is the best way to do this but it works and i dont care. i just want to finish this script and play the game. (i hate coding)

function utils.collectChar(targets) -- hitbox candidates.. npcs live in BodyFolders.get("Crew"), players in CharacterIndex
    local list = {}
    if targets['Humanoid'] then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = CharacterIndex.of(plr) or plr.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        table.insert(list, { model = char, name = plr.Name })
                    end
                end
            end
        end
    end
    if targets['Npc'] then
        local crew = BodyFolders.get("Crew")
        if crew then
            for _, npc in ipairs(crew:GetChildren()) do
                if npc:IsA("Model") then
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        table.insert(list, { model = npc, name = npc.Name })
                    end
                end
            end
        end
    end
    return list
end

-- Utils End


-- Visual

-- 

local visual = {}

function visual.canvas(name)

    -- Main Holder
    local holder = Instance.new("Frame")
    holder.Name = name
    holder.Parent = gui
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, 0, 1, 0)
    holder.Visible = false
    -- Main Holder End

    -- Box
    local box = Instance.new("CanvasGroup")
    box.Name = "Box"
    box.Parent = holder
    box.Size = UDim2.fromScale(1, 1)
    box.BackgroundTransparency = 1
    box.GroupTransparency = 1

    local outline = Instance.new("UIStroke")
    outline.LineJoinMode = Enum.LineJoinMode.Miter
    outline.Thickness = 3
    outline.Color = Color3.fromRGB(0, 0, 0)
    outline.Transparency = 1
    outline.Parent = box

    local inline = Instance.new("UIStroke")
    inline.LineJoinMode = Enum.LineJoinMode.Miter
    inline.BorderOffset = UDim.new(0, 1)
    inline.Color = Color3.fromRGB(255, 255, 255)
    inline.Thickness = 1
    inline.ZIndex = 2
    inline.Transparency = 1
    inline.Parent = box
    -- Box End

    -- Text
    local top = Instance.new("CanvasGroup")
    top.Name = "TopHolder"
    top.Parent = holder
    top.BackgroundTransparency = 1
    top.GroupTransparency = 1
    top.Size = UDim2.new(0, 500, 0, 15)
    top.AnchorPoint = Vector2.new(0.5, 1)
    top.Position = UDim2.new(0.5, 0, 0, -5)
    top.ZIndex = 6

    local shadow = Instance.new("TextLabel") -- shadow to make text more readable😉
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.Position = UDim2.fromOffset(1, 1)
    shadow.FontFace = font
    shadow.Text = ""
    shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    shadow.TextSize = 12
    shadow.TextStrokeTransparency = 1
    shadow.TextTransparency = 1
    shadow.Parent = top

    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.BackgroundTransparency = 1
    text.Size = UDim2.fromScale(1, 1)
    text.Position = UDim2.fromOffset(0, 0)
    text.FontFace = font
    text.Text = ""
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 12
    text.TextStrokeTransparency = 1
    text.TextTransparency = 1
    text.Parent = top
    -- Text End

    -- ew ew ew ignore
    local obj = {
        holder = holder,
        box = box,
        top = top,
        text = text,
        shadow = shadow,
        outline = outline,
        inline = inline,
        fadeValue = 1,
        shown = false,
        snap = {},
    }
    -- ew ew ew ignore

    return obj
end

-- claude AI was used here !
local canvasPool = {}
for i = 1, 256 do
    canvasPool[i] = visual.canvas("pool_" .. i)
end

function visual.acquire(name)
    local obj = table.remove(canvasPool)
    if obj then
        return obj
    end
    return nil
end

function visual.release(obj)
    obj.holder.Visible = false
    obj.box.GroupTransparency = 1
    obj.top.GroupTransparency = 1
    obj.outline.Transparency = 1
    obj.inline.Transparency = 1
    obj.text.TextTransparency = 1
    obj.shadow.TextTransparency = 1
    obj.fadeValue = 1
    obj.shown = false
    table.clear(obj.snap)
    table.insert(canvasPool, obj)
end
-- claude AI was used here !

function visual.trans_parent(obj, dt)
    local target = obj.shown and 0 or 1
    local duration = obj.shown and fadeinNNNn.Time or FadeoutialrlostNNN.Time
    local v = obj.fadeValue
    if v < target then
        v = math.min(v + dt / duration, target)
    elseif v > target then
        v = math.max(v - dt / duration, target)
    end
    obj.fadeValue = v

    obj.box.GroupTransparency = (Toggles['Visual // ESP // Box'].Value and v) or 1
    obj.top.GroupTransparency = 0
    obj.top.Visible = Toggles['Visual // ESP // Name'].Value
    obj.text.TextTransparency = (Toggles['Visual // ESP // Name'].Value and v) or 1
    obj.shadow.TextTransparency = (Toggles['Visual // ESP // Name'].Value and v) or 1
    obj.outline.Transparency = (Toggles['Visual // ESP // Box'].Value and v) or 1
    obj.inline.Transparency = (Toggles['Visual // ESP // Box'].Value and v) or 1
end

-- claude AI was used here !
-- saves the last position of the parts in 3D space, so we can reproject them with the camera later (for fadeout)
function visual.snapshot(obj, parts)
    local snap = obj.snap
    local n = #parts
    for i = 1, n do
        local part = parts[i]
        local e = snap[i]
        if not e then
            e = {}
            snap[i] = e
        end
        e.cf = part.CFrame
        e.hs = part.Size * 0.5
    end
    for i = #snap, n + 1, -1 do
        snap[i] = nil
    end
end

-- remake the last frame bounding box, so we can fade it out if the target is dead or out of sight
function visual.renderLast(obj)
    local pos, size = utils.bounding(obj.snap)
    if not pos then
        obj.holder.Visible = false
        return false
    end
    obj.holder.Position = UDim2.fromOffset(pos.X, pos.Y)
    obj.holder.Size = UDim2.fromOffset(size.X, size.Y)
    return true
end

function visual.fadeIn(obj)
    obj.holder.Visible = true
    obj.shown = true
end

function visual.fadeOut(obj)
    if obj.shown then
        obj.shown = false
    end

    if obj.fadeValue < 1 then
        if visual.renderLast(obj) then
            obj.holder.Visible = true
        end
    else
        obj.holder.Visible = false
    end
end
-- claude AI was used here !
-- Visual End


-- Main

local boxes = {}

local function esp(dt)
    if Toggles['Visual // ESP // Box'].Value or Toggles['Visual // ESP // Name'].Value then
        local seen = {}
        for _, entry in ipairs(utils.collectChar(Options['Visual // ESP // Targets'].Value)) do
            local char, name = entry.model, entry.name
            seen[char] = true
            if not boxes[char] then
                boxes[char] = visual.acquire(name)
            end
            local obj = boxes[char]
            if obj then
                if Toggles['Visual // ESP // TeamCheck'].Value and utils.isSameTeam(char) then
                    visual.fadeOut(obj)
                    visual.trans_parent(obj, dt)
                else
                    visual.snapshot(obj, utils.getparts(char))
                    local pos, size = utils.bounding(obj.snap)
                    if pos then
                        obj.holder.Position = UDim2.fromOffset(pos.X, pos.Y)
                        obj.holder.Size = UDim2.fromOffset(size.X, size.Y)
                        local n = name:lower()
                        if obj.text.Text ~= n then
                            obj.text.Text = n
                            obj.shadow.Text = n
                        end
                        visual.fadeIn(obj)
                        visual.trans_parent(obj, dt)
                    else
                        obj.holder.Visible = false
                    end
                end
            end
        end

        local toRelease = {}
        for char, obj in pairs(boxes) do
            if not seen[char] then
                visual.fadeOut(obj)
                visual.trans_parent(obj, dt)
                if obj.fadeValue >= 1 then
                    table.insert(toRelease, char)
                end
            end
        end
        for _, char in ipairs(toRelease) do
            visual.release(boxes[char])
            boxes[char] = nil
        end
    else
        local toRelease = {}
        for char, obj in pairs(boxes) do
            visual.fadeOut(obj)
            visual.trans_parent(obj, dt)
            if obj.fadeValue >= 1 then
                table.insert(toRelease, char)
            end
        end
        for _, char in ipairs(toRelease) do
            visual.release(boxes[char])
            boxes[char] = nil
        end
    end
end

-- claude AI was used here !
local function step(dt)
    pcall(esp, dt)

    -- Aim

    if not Toggles['Combat // Aim // Enable'].Value then return end
    if not Options['Combat // Aim // Keybind']:GetState() then return end

    local mp = cloneref(game:GetService("UserInputService")):GetMouseLocation()
    local camPos = Camera.CFrame.Position

    local bestPart, bestDist = nil, Options['Combat // Aim // FOV'].Value
    local prioPart, prioDist = nil, Options['Combat // Aim // FOV'].Value

    if Toggles['Combat // Aim // WallCheck'].Value then
        utils.wallchecktest()
    end

    for _, entry in ipairs(utils.collectChar(Options['Combat // Aim // Targets'].Value)) do
        local char = entry.model

        if Toggles['Combat // Aim // TeamCheck'].Value and utils.isSameTeam(char) then
            continue
        end

        for _, part in ipairs(char:GetDescendants()) do
            if not part:IsA("BasePart") then continue end
            if not CombatTargeting.is_damageable_part(part, char) then continue end

            local sp = utils.project(utils.predict(part))
            if not sp then continue end

            local dist = (sp - mp).Magnitude
            local isPrio = part.Name == Options['Combat // Aim // Priority'].Value

            if dist >= bestDist and not (isPrio and dist < prioDist) then continue end
            if Toggles['Combat // Aim // WallCheck'].Value and not utils.visible(camPos, part.Position) then continue end

            if dist < bestDist then
                bestPart, bestDist = part, dist
            end

            if isPrio and dist < prioDist then
                prioPart, prioDist = part, dist
            end
        end
    end

    local target = prioPart or bestPart
    if not target then return end

    local sp = utils.project(utils.predict(target))
    if not sp then return end

    local factor = 1 - math.exp(-(10 / Options['Combat // Aim // Smooth'].Value) * dt * 60) -- i aint coding math, just exp decay

    mousemoverel((sp.X - mp.X) * factor, (sp.Y - mp.Y) * factor)
end



local renderConnection = RunService.RenderStepped:Connect(function(dt)
    pcall(step, dt)
end)
-- claude AI was used here !


-- Main End


-- Menu

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('UI Settings // Menu // Keybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options['UI Settings // Menu // Keybind']

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'UI Settings // Menu // Keybind' })
ThemeManager:SetFolder('FemToByte')
SaveManager:SetFolder('FemToByte/game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

-- Menu End


-- Close

Library:OnUnload(function()
    renderConnection:Disconnect()
    gui:Destroy()
    boxes = {}
end)

-- Close End