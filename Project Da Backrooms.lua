local UserInputService = game:GetService("UserInputService")
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

CurrentRunningTweens = {}

local GUI = Mercury:Create{
    Name = "Da backrooms",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/deeeity/mercury-lib"
}
local MainTab = GUI:Tab{
	Name = "Main",
	Icon = "rbxassetid://11928957615"
}
local ESPTab = GUI:Tab{
    Name = "ESP",
    Icon = "rbxassetid://11932632800"
}


monstersFolder = game:GetService("Workspace").Monsters
itemsFolder = game.Workspace.Items 


function useBandage()
    Bandage = game.Players.LocalPlayer.Backpack:FindFirstChild("Bandage")
    if Bandage then
        Bandage.Parent = game.Players.LocalPlayer.Character
        local args = {
            [1] = game:GetService("Players").LocalPlayer.Character.Bandage
        }
        
        game:GetService("ReplicatedStorage").UseItem:FireServer(unpack(args))
    end
end
function gotoLootSpawner()
    local function TweenCFrame(TargetPart,TargetProperty,Speed)
        local speeed = (TargetPart.Position - Vector3.new(TargetProperty.X,TargetProperty.Y,TargetProperty.Z)).Magnitude/Speed
        local TweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(speeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
        local goal = {}
        goal.CFrame = TargetProperty
        local tween = TweenService:Create(TargetPart,tweenInfo,goal)
        table.insert(CurrentRunningTweens,tween)
        tween:Play()
        tween.Completed:Connect(function(playbackState)
            tweenhasCompleted = true
        end)
    end
    TweenCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart,game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame+Vector3.new(0,50,0),30)
    task.wait(5)
    local PathService = game:GetService("PathfindingService")
    local TextService = game:GetService("TextService")
    local Path = PathService:CreatePath({
        AgentRadius = 1,
        AgentHeight = 1,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 10,
        Costs = {}
    })
    targetPos = Vector3.new(814.4649047851562, 3.154090166091919, -36.087528228759766)
    Path:ComputeAsync(game.Players.LocalPlayer.Character.HumanoidRootPart.Position,targetPos)
    local Waypoints = Path:GetWaypoints()
    for i,v in pairs(Waypoints) do
        tweenhasCompleted = false
        TweenCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart,CFrame.new(v.Position),20)
        repeat task.wait()
            
        until tweenhasCompleted == true
        task.wait()
    end
end
function getVisiblePlayers()
    visiblePlayers = {}
    for i,v in pairs(game.Players:GetPlayers()) do
        if tostring(v) ~= game.Players.LocalPlayer.Name then
            if not v.Character then
            else
                cam = workspace.CurrentCamera
                onscreen = cam:WorldToViewportPoint(v.Character:GetPivot().Position)
                if onscreen then
                    originPos = game.workspace.CurrentCamera.CFrame.Position
                    destPos = v.Character:GetPivot().Position
                    direction = destPos-originPos
                    myRay = Ray.new(originPos,direction)
                    hit,pos = workspace:FindPartOnRayWithIgnoreList(myRay,{game.Players.LocalPlayer.Character,v.Character})
                    if not hit then
                        table.insert(visiblePlayers,v.Character)
                    end 
                end
            end
        end
    end
    return visiblePlayers
end
function getClosestItem(maxRange)
    maxDist = maxRange
    closestItem = nil
    for i,v in pairs(itemsFolder:GetChildren()) do
        pcall(function()
            dist = (v:GetPivot().Position - game.Players.LocalPlayer.Character:GetPivot().Position).Magnitude
            if dist < maxDist then
                maxDist = dist
                closestItem = v
            end
        end)
    end
    return closestItem
end

-- loot esp
lootESP = false
ESPTab:Toggle{
    Name = "Loot esp",
    StartingState = false,
    Description = "ESP for loot",
    Callback = function(state)
        lootESP = state
        repeat task.wait()
            task.spawn(function()
                lootFolder = game:GetService("Workspace").Loot
                for i,v in pairs(lootFolder:GetChildren()) do
                    hasESP = v:FindFirstChild("lootESP") 
                    if not hasESP then
                        local BillboardGui = Instance.new("BillboardGui")
                        local TextLabel = Instance.new("TextLabel")
                        
                        --Properties:
                        
                        BillboardGui.Name = "lootESP"
                        BillboardGui.Parent = v
                        BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                        BillboardGui.Active = true
                        BillboardGui.Adornee = v
                        BillboardGui.MaxDistance = 200
                        BillboardGui.AlwaysOnTop = true
                        BillboardGui.Size = UDim2.new(0, 200, 0, 50)
                        
                        TextLabel.Parent = BillboardGui
                        TextLabel.Active = true
                        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        TextLabel.BackgroundTransparency = 1.000
                        TextLabel.Size = UDim2.new(0, 200, 0, 50)
                        TextLabel.Font = Enum.Font.Code
                        TextLabel.TextColor3 = Color3.fromRGB(170, 153, 0)
                        TextLabel.TextSize = 14.000
                    elseif hasESP then
                        hasESP.TextLabel.Text = "["..tostring(v).."]\n".."["..tostring(math.round((game.Players.LocalPlayer.Character:GetPivot().Position - v:GetPivot().Position).Magnitude)).."]"
                    end
                end
            end)
        until lootESP == false
        lootFolder = game:GetService("Workspace").Loot:GetChildren()
        for i,v in pairs(lootFolder) do
            hasESP = v:FindFirstChild("lootESP") 
            if hasESP then hasESP:Destroy() end
        end
    end
}

-- monster esp
monsterESP = false
ESPTab:Toggle{
    Name = "Monster esp",
    StartingState = false,
    Description = "ESP for monsters",
    Callback = function(state)
        monsterESP = state
        repeat task.wait()
            task.spawn(function()
                for i,v in pairs(monstersFolder:GetChildren()) do
                    hasESP = v:FindFirstChild("monsterESP")
                    if not hasESP then
                        local BillboardGui = Instance.new("BillboardGui")
                        local TextLabel = Instance.new("TextLabel")
                        
                        --Properties:
                        
                        BillboardGui.Name = "monsterESP"
                        BillboardGui.Parent = v
                        BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                        BillboardGui.Active = true
                        BillboardGui.Adornee = v
                        BillboardGui.AlwaysOnTop = true
                        BillboardGui.Size = UDim2.new(0, 200, 0, 50)
                        
                        TextLabel.Parent = BillboardGui
                        TextLabel.Active = true
                        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        TextLabel.BackgroundTransparency = 1.000
                        TextLabel.Size = UDim2.new(0, 200, 0, 50)
                        TextLabel.Font = Enum.Font.Code
                        TextLabel.TextColor3 = Color3.fromRGB(170, 0, 0)
                        TextLabel.TextSize = 14.000
                    elseif hasESP then
                        hasESP.TextLabel.Text = "["..tostring(v).."]\n".."["..tostring(math.round((v:GetPivot().Position - game.Players.LocalPlayer.Character:GetPivot().Position).Magnitude)).."]"
                    end
                end
            end)
        until monsterESP == false
        for i,v in pairs(monstersFolder:GetChildren()) do
            hasESP = v:FindFirstChild("monsterESP") 
            if hasESP then hasESP:Destroy() end
        end
    end
}

-- godmode
godmode = false
MainTab:Toggle{
    Name = "Godmode (W.I.P)",
    StartingState = false,
    Description = "Basically godmode",
    Callback = function(state)
        godmode = state
        repeat task.wait()
            task.spawn(function()
                local TextService = game:GetService("TextService")
                revivePrompt = game.Players.LocalPlayer.Character:FindFirstChild("Revive",true)
                if revivePrompt then
                    fireproximityprompt(revivePrompt, 0)
                end
            end)
        until godmode == false
    end
}

-- revive aura
reviveAll = false
MainTab:Toggle{
    Name = "Revive aura",
    StartingState = false,
    Description = "Revive nearby players",
    Callback = function(state)
        reviveAll = state
        repeat task.wait()
            task.spawn(function()
                for i,v in pairs(game.Players:GetPlayers()) do
                    if not v.Character then
                    else
                        revivePrompt = v.Character:FindFirstChild("Revive",true)
                        if revivePrompt then
                            fireproximityprompt(revivePrompt,0)
                        end
                    end
                end
            end)
        until reviveAll == false
    end
}

-- bypassed fly
playerFlight = false
MainTab:Toggle{
    Name = "Flight (W.I.P)",
    StartingState = false,
    Description = "Bypass Fly",
    Callback = function(state)
        playerFlight = state
        repeat task.wait()
            task.spawn(function()
                local function TweenCFrame(TargetPart,TargetProperty,Speed)
                    local speeed = (TargetPart.Position - Vector3.new(TargetProperty.X,TargetProperty.Y,TargetProperty.Z)).Magnitude/Speed
                    local TweenService = game:GetService("TweenService")
                    local tweenInfo = TweenInfo.new(speeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
                    local goal = {}
                    goal.CFrame = TargetProperty
                    local tween = TweenService:Create(TargetPart,tweenInfo,goal)
                    table.insert(CurrentRunningTweens,tween)
                    tween:Play()
                end
                hasNoVelo = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity")
                if not hasNoVelo then
                    NoVelo = Instance.new("BodyVelocity")
                    NoVelo.Name = "NoVelo"
                    NoVelo.Velocity = Vector3.new(0,0,0)
                    NoVelo.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                    NoVelo.P = math.huge
                    NoVelo.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    TweenCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart,game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame+Vector3.new(0,.3,0),30)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    TweenCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart,game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame+Vector3.new(0,-.3,0),30)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    TweenCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart,game.Players.LocalPlayer.Character.HumanoidRootPart:GetPivot()+game.Players.LocalPlayer.Character.HumanoidRootPart:GetPivot().LookVector*2,30)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    TweenCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart,game.Players.LocalPlayer.Character.HumanoidRootPart:GetPivot()+game.Players.LocalPlayer.Character.HumanoidRootPart:GetPivot().LookVector*-2,30)
                end
            end)
        until playerFlight == false
        hasNoVelo = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity")
        if hasNoVelo then hasNoVelo:Destroy() end
    end
}

-- pick up aura
pickUpAura = false
MainTab:Toggle{
    Name = "Pickup aura",
    StartingState = false,
    Description = "Picks up nearby items in your soroundings",
    Callback = function(state)
        pickUpAura = state
        repeat task.wait(.1)
            pcall(function()
                if getClosestItem(40) ~= nil then
                    local args = {
                        [1] = "Pickup",
                        [2] = getClosestItem(40)
                    }
                    
                    game:GetService("ReplicatedStorage").Inventory:FireServer(unpack(args))
                end
            end)
        until pickUpAura == false
    end
}

playerToAutoKill = nil
-- select player to autokill
MainTab:Textbox{
    Name = "Select player to autokill (W.I.P)",
    Callback = function(text) 
        for i,v in pairs(game.Players:GetPlayers()) do
            if string.find(v.Name,text) then
                playerToAutoKill = v.Character
            end
        end
    end
}

-- autokill player
autoKillPlayer = false
MainTab:Toggle{
    Name = "Kill Player (W.I.P)",
    StartingState = false,
    Description = "Automatically kills the selected player",
    Callback = function(state)
        autoKillPlayer = state
        tweenhasCompleted = true
        repeat task.wait()
            task.spawn(function()
                hasNoVelo = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity")
                if not hasNoVelo then
                    NoVelo = Instance.new("BodyVelocity")
                    NoVelo.Name = "NoVelo"
                    NoVelo.Velocity = Vector3.new(0,0,0)
                    NoVelo.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                    NoVelo.P = math.huge
                    NoVelo.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
                end
                local function TweenCFrame(TargetPart,TargetProperty,Speed)
                    local speeed = (TargetPart.Position - Vector3.new(TargetProperty.X,TargetProperty.Y,TargetProperty.Z)).Magnitude/Speed
                    local TweenService = game:GetService("TweenService")
                    local tweenInfo = TweenInfo.new(speeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
                    local goal = {}
                    goal.CFrame = TargetProperty
                    local tween = TweenService:Create(TargetPart,tweenInfo,goal)
                    table.insert(CurrentRunningTweens,tween)
                    tween:Play()
                    tween.Completed:Connect(function()
                        tweenhasCompleted = true
                    end)
                end
                if playerToAutoKill ~= nil then
                    if tweenhasCompleted == true then
                        tweenhasCompleted = false
                        TweenCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart,playerToAutoKill:GetPivot()+Vector3.new(0,5,0),25)
                    end
                end
            end)
        until autoKillPlayer == false
        pcall(function()
        end)
        hasNoVelo = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity")
        if hasNoVelo then hasNoVelo:Destroy() end
    end
}

-- goto loot spawner
MainTab:Button{
    Name = "Goto Item Spawner",
    Callback = function()
        gotoLootSpawner()
    end
}

abuseItemSpawner = false
MainTab:Toggle{
    Name = "For Item Spawner use this",
    StartingState = false,
    Description = "OP",
    Callback = function(state)
        abuseItemSpawner = state
        repeat task.wait(.1)
            task.spawn(function()
                lootFolder = game:GetService("Workspace").Containers
                tool = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                if tool then
                    tool.Parent = game.Players.LocalPlayer.Backpack
                end
                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetDescendants()) do
                    pcall(function()
                        v.Massless = true
                        v.Anchored = false
                    end)
                end
            end)
        until abuseItemSpawner == false
    end
}

-- set health at what to autoheal
healthRequiredToAutoHeal = 50
MainTab:Slider{
    Name = "Health to start autohealing",
    Default = 50,
    Min = 0,
    Max = 100,
    Callback = function(value)
        healthRequiredToAutoHeal = value
    end
}

-- auto heal at ... health
autoHeal = false
MainTab:Toggle{
    Name = "Auto heal at ... health",
    StartingState = false,
    Description = "Automatically uses a medkit or bandage if health is below wanted value",
    Callback = function(state)
        autoHeal = state
        repeat task.wait()
            task.spawn(function()
                if game.Players.LocalPlayer.Character.Humanoid.Health < healthRequiredToAutoHeal then
                    useBandage()
                end
            end)
        until autoHeal == false
    end
}

-- disable anticheat
acDisabler = false
MainTab:Toggle{
    Name = "Disable anticheat (W.I.P)",
    StartingState = false,
    Description = "Disables the anticheat",
    Callback = function(state)
        acDisabler = state
        repeat task.wait()
            ac1 = game.Players.LocalPlayer.Character:FindFirstChild("CheckPart")
            ac2 = game.Players.LocalPlayer.Character:FindFirstChild("AntiCheat")
            if ac1 then
                ac1:ClearAllChildren()
            elseif ac2 then
                ac2.Pause.Value = true
            end
        until acDisabler == false
    end
}

