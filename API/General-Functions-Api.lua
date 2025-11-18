local flySpeed = 60
local flying = false
local flyConnection = nil
local Noclipping = nil
local General = {}
local brightLoop = nil

function General:ToggleFlight(enable, speed)
    if speed and type(speed) == "number" then
        flySpeed = speed
    elseif flySpeed == nil then
        flySpeed = 60
    end
    if enable == true then
        if flying then
            return
        end
        flying = true
        local camera = workspace.CurrentCamera
        local controlModule = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'):WaitForChild("ControlModule"))
        local bv = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("VelocityHandler") or Instance.new("BodyVelocity")
        bv.Name = "VelocityHandler"
        bv.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        local bg = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("GyroHandler") or Instance.new("BodyGyro")
        bg.Name = "GyroHandler"
        bg.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 1000
        bg.D = 50
        game:GetService("Players").LocalPlayer.Character.Humanoid.PlatformStand = true
        flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if not flying or not game:GetService("Players").LocalPlayer.Character or not game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or
               not game:GetService("Players").LocalPlayer.Character.Humanoid.RootPart or game:GetService("Players").LocalPlayer.Character.Humanoid.Health <= 0 or
               not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("VelocityHandler") or
               not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("GyroHandler") then
                General:ToggleFlight(false)
                return
            end
            bg.CFrame = camera.CoordinateFrame
            local direction = controlModule:GetMoveVector()
            bv.Velocity = Vector3.new()
            if direction.X ~= 0 then
                bv.Velocity = bv.Velocity + camera.CFrame.RightVector * (direction.X * flySpeed)
            end
            if direction.Z ~= 0 then
                bv.Velocity = bv.Velocity - camera.CFrame.LookVector * (direction.Z * flySpeed)
            end
        end)
    elseif enable == false then
        if not flying then
            return
        end
        flying = false
        if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            game:GetService("Players").LocalPlayer.Character.Humanoid.PlatformStand = false
            local bv = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("VelocityHandler")
            if bv then
                bv.MaxForce = Vector3.new(0, 0, 0)
                bv:Destroy()
            end
            local bg = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("GyroHandler")
            if bg then
                bg.MaxTorque = Vector3.new(0, 0, 0)
                bg:Destroy()
            end
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end
end

function General:ToggleNoclip(enabled)
    if enabled then
        if Noclipping then
            Noclipping:Disconnect()
        end
        Noclipping = game:GetService("RunService").Stepped:Connect(function()
            if game:GetService("Players").LocalPlayer.Character ~= nil then
                for _, child in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true then
                        child.CanCollide = false
                    end
                end
            end
        end)
    else
        if Noclipping then
            Noclipping:Disconnect()
            Noclipping = nil
        end
    end
end

function General:ToogleFullbright(enable)
	if enable then
		if brightLoop then
			brightLoop:Disconnect()
		end
		brightLoop = game:GetService("RunService").RenderStepped:Connect(function()
			game:GetService("Lighting").Brightness = 2
			game:GetService("Lighting").ClockTime = 14
			game:GetService("Lighting").FogEnd = 100000
			game:GetService("Lighting").GlobalShadows = false
			game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end)
    else
		if brightLoop then
			brightLoop:Disconnect()
		end
	end
end

function General:Nofog(enable)
	game:GetService("Lighting").FogEnd = 100000
	for i,v in pairs(game:GetService("Lighting"):GetDescendants()) do
        if v:IsA("Atmosphere") and enable then
            v:Destroy()
        else
            v:Destroy()
        end
	end
end

function General:Help()
print([[

===通用功能API使用帮助===
• ToggleFlight(enable, speed)
  enable: true开启飞行, false关闭飞行
  speed: 可选参数，设置飞行速度，默认60

• ToggleNoclip(enabled)
  enabled: true开启穿墙, false关闭穿墙

• ToogleFullbright(enabled)
  enabled: true开启地图亮度, false关闭地图亮度

• Nofog(enabled)
  enabled: true删除Atmosphere false删除Lighting所有的对象
• Help()
]])
end

print("[通用功能]API初始化成功,使用Help()查看帮助")

return General
