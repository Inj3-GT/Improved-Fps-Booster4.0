// SCRIPT BY Inj3 
// https://steamcommunity.com/id/Inj3/
// General Public License v3.0
// https://github.com/Inj3-GT

local Ipr = {}
local Ipr_Infinity = math.huge

Ipr.Settings = {
    Blur = Material("pp/blurscreen"),
    SetLang = Ipr_Fps_Booster.Settings.Language,
    Debug = false,
    Font = "Ipr_Fps_Booster_Font",
    Status = {
        Name = "FPS Status",
        State = false,
    },
    Fps =  {
        Max = {
            Int = 0,
            Name = "Max : "
        },
        Min = {
            Int = Ipr_Infinity,
            Name = "Min : "},
        Low = {
            Lists = {},
            MaxFrame = 10,
            InProgress = false,
            Name = "Low 1% : ",
        },
    },
    TColor = {
        ["blanc"] = Color(236, 240, 241),
        ["vert"] = Color(39, 174, 96),
        ["rouge"] = Color(192, 57, 43),
        ["orange"] = Color(226, 149, 25),
        ["orangec"] = Color(175, 118, 27),
        ["gvert"] = Color(28, 143, 24, 182),
        ["gvert_"] = Color(28, 143, 24, 232),
        ["bleu"] = Color(52, 73, 94),
        ["bleuc"] = Color(27, 66, 99),
    },
    Country = {
        ["BE"] = true,
        ["FR"] = true,
        ["DZ"] = true,
        ["MA"] = true,
        ["CA"] = true
    },
    Vgui = {
        Primary = false,
        Secondary = false,
        ToolTip = false,
    },
    StartupLaunch = {
        Name = "IprFpsBooster_ApplyToStartup",
        Delay = 300,
    },
    Data = {},
}

Ipr.Func = {}

Ipr.Func.CreateData = function()
    local Ipr_CreateDir = file.Exists(Ipr_Fps_Booster.Settings.Save, "DATA")
    if not Ipr_CreateDir then
        file.CreateDir(Ipr_Fps_Booster.Settings.Save)
    end

    local Ipr_FileLangs, Ipr_TCountry = file.Exists(Ipr_Fps_Booster.Settings.Save.. "language.json", "DATA")
    if not Ipr_FileLangs then
        local Ipr_GCountry = not game.IsDedicated() and system.GetCountry()
        Ipr_TCountry = (Ipr_GCountry) and Ipr.Settings.Country[Ipr_GCountry] and "FR" or Ipr_Fps_Booster.Settings.Language

        file.Write(Ipr_Fps_Booster.Settings.Save.. "language.json", Ipr_TCountry)
    end
    Ipr.Settings.SetLang = Ipr_TCountry or file.Read(Ipr_Fps_Booster.Settings.Save.. "language.json", "DATA")

    local Ipr_FileConvars, Ipr_TData = file.Exists(Ipr_Fps_Booster.Settings.Save.. "convars.json", "DATA")
    if not Ipr_FileConvars then
        Ipr_TData = {}

        local Ipr_ConvarsLists = Ipr_Fps_Booster.DefaultCommands
        for i = 1, #Ipr_ConvarsLists do
            Ipr_TData[#Ipr_TData + 1] = {
                Name = Ipr_ConvarsLists[i].Name,
                Checked = Ipr_ConvarsLists[i].DefaultCheck
            }
        end

        local Ipr_SettingsLists = Ipr_Fps_Booster.DefaultSettings
        for i = 1, #Ipr_SettingsLists do
            Ipr_TData[#Ipr_TData + 1] = {
                Vgui = Ipr_SettingsLists[i].Vgui,
                Name = Ipr_SettingsLists[i].Name,
                Checked = Ipr_SettingsLists[i].DefaultCheck
            }
        end

        file.Write(Ipr_Fps_Booster.Settings.Save.. "convars.json", util.TableToJSON(Ipr_TData))
    end
    Ipr_Fps_Booster.Convars = Ipr_TData or util.JSONToTable(file.Read(Ipr_Fps_Booster.Settings.Save.. "convars.json", "DATA"))
end

Ipr.Func.GetConvar = function(name)
    for i = 1, #Ipr_Fps_Booster.Convars do
        local Ipr_Convars = Ipr_Fps_Booster.Convars[i]

        if (Ipr_Convars.Name == name) then
            return Ipr_Convars.Checked
        end
    end

    if (Ipr.Settings.Debug) then
        print("Convar not found !", " " ..name)
    end
    return nil
end

Ipr.Func.SetConvar = function(name, value, save, exist, copy)
    local Ipr_Convar = (Ipr.Func.GetConvar(name) == nil)

    if (Ipr_Convar) then
        Ipr_Fps_Booster.Convars[#Ipr_Fps_Booster.Convars + 1] = {
            Name = name,
            Checked = value,
        }
        file.Write(Ipr_Fps_Booster.Settings.Save.. "convars.json", util.TableToJSON(Ipr_Fps_Booster.Convars))

        if (Ipr.Settings.Debug) then
            print("Creating a new convar : " ..name, value, save)
        end
        if (copy) then
            Ipr.Func.CopyData()
        end
    else
        if (exist) then
            return
        end

        for i = 1, #Ipr_Fps_Booster.Convars do
            local Ipr_ToggleCount = Ipr_Fps_Booster.Convars[i]

            if (Ipr_ToggleCount.Name == name) then
                Ipr_Fps_Booster.Convars[i].Checked = value
                break
            end
        end

        if (save == 1) then
            local Ipr_SaveConvar = "IprFpsBooster_SetConvar"
            if (timer.Exists(Ipr_SaveConvar)) then
                timer.Remove(Ipr_SaveConvar)
            end

            timer.Create(Ipr_SaveConvar, 1, 1, function()
                file.Write(Ipr_Fps_Booster.Settings.Save.. "convars.json", util.TableToJSON(Ipr_Fps_Booster.Convars))
            end)
        elseif (save == 2) then
            file.Write(Ipr_Fps_Booster.Settings.Save.. "convars.json", util.TableToJSON(Ipr_Fps_Booster.Convars))
        end
    end
end

Ipr.Func.InfoNum = function(cmd, exist)
    local Ipr_InfoNum = LocalPlayer():GetInfoNum(cmd, -99)
    if (exist) then
        return (Ipr_InfoNum == -99)
    end

    return tonumber(Ipr_InfoNum)
end

Ipr.Func.MatchConvar = function(bool)
    local Ipr_ConvarsCheck = bool

    for i = 1, #Ipr_Fps_Booster.DefaultCommands do
        local Ipr_NameCommand = Ipr_Fps_Booster.DefaultCommands[i].Name
        local Ipr_ConvarCommand = Ipr_Fps_Booster.DefaultCommands[i].Convars

        for k, v in pairs(Ipr_ConvarCommand) do
            if isbool(Ipr.Func.GetConvar(Ipr_NameCommand)) then
                if (bool) then
                    Ipr_ConvarsCheck = Ipr.Func.GetConvar(Ipr_NameCommand)
                end

                local Ipr_Toggle = (Ipr_ConvarsCheck) and v.Enabled or v.Disabled
                Ipr_Toggle = tonumber(Ipr_Toggle)

                local Ipr_InfoCmds = Ipr.Func.InfoNum(k)
                if Ipr.Func.InfoNum(k, true) or (Ipr_InfoCmds == Ipr_Toggle) then
                    continue
                end

                return true
            end
        end
    end

    return false
end

Ipr.Func.IsChecked = function()
    for i = 1, #Ipr_Fps_Booster.Convars do
        if not Ipr_Fps_Booster.Convars[i].Vgui and (Ipr_Fps_Booster.Convars[i].Checked == true) then
            return true
        end
    end
    
    return false
end

Ipr.Func.CurrentState = function()
    return Ipr.Settings.Status.State
end

Ipr.Func.Activate = function(bool)
    local Ipr_ConvarsCheck = bool

    for i = 1, #Ipr_Fps_Booster.DefaultCommands do
        local Ipr_NameCommand = Ipr_Fps_Booster.DefaultCommands[i].Name
        local Ipr_ConvarCommand = Ipr_Fps_Booster.DefaultCommands[i].Convars

        for k, v in pairs(Ipr_ConvarCommand) do
            if isbool(Ipr.Func.GetConvar(Ipr_NameCommand)) then
                if (bool) then
                    Ipr_ConvarsCheck = Ipr.Func.GetConvar(Ipr_NameCommand)
                end

                local Ipr_Toggle = (Ipr_ConvarsCheck) and v.Enabled or v.Disabled
                Ipr_Toggle = tonumber(Ipr_Toggle)

                local Ipr_InfoCmds = Ipr.Func.InfoNum(k)
                if Ipr.Func.InfoNum(k, true) or (Ipr_InfoCmds == Ipr_Toggle) then
                    continue
                end

                RunConsoleCommand(k, Ipr_Toggle)

                if (Ipr.Settings.Debug) then
                    print("Updating " ..k.. " set " ..Ipr_InfoCmds.. " to " ..Ipr_Toggle)
                end
            end
        end
    end

    Ipr.Settings.Status.State = bool
end

Ipr.Func.FpsCalculator = function()
    local Ipr_SysTime = SysTime()

    if (Ipr_SysTime > (Ipr.CurNext or 0)) then
        local Ipr_AbsoluteFrameTime = engine.AbsoluteFrameTime()
        
        Ipr.Settings.FpsCurrent = math.Round(1 / Ipr_AbsoluteFrameTime)
        Ipr.Settings.FpsCurrent = (Ipr.Settings.FpsCurrent > 999) and 999 or Ipr.Settings.FpsCurrent

        if (Ipr.Settings.FpsCurrent < Ipr.Settings.Fps.Min.Int) then
            Ipr.Settings.Fps.Min.Int = Ipr.Settings.FpsCurrent
        end
        if (Ipr.Settings.FpsCurrent > (Ipr.Settings.Fps.Max.Int ~= Ipr_Infinity and Ipr.Settings.Fps.Max.Int or 0)) then
            Ipr.Settings.Fps.Max.Int = Ipr.Settings.FpsCurrent
        end

        Ipr.Settings.Fps.Low.InProgress  = Ipr.Settings.Fps.Low.InProgress or Ipr.Settings.Fps.Min.Int

        if (#Ipr.Settings.Fps.Low.Lists <= Ipr.Settings.Fps.Low.MaxFrame) then
            Ipr.Settings.Fps.Low.Lists[#Ipr.Settings.Fps.Low.Lists + 1] = Ipr.Settings.FpsCurrent
        else
            table.sort(Ipr.Settings.Fps.Low.Lists, function(a, b) return a < b end)

            Ipr.Settings.Fps.Low.InProgress = Ipr.Settings.Fps.Low.Lists[2]
            Ipr.Settings.Fps.Low.Lists = {}
        end

        Ipr.CurNext = Ipr_SysTime + 0.3
    end

    return Ipr.Settings.FpsCurrent, Ipr.Settings.Fps.Min.Int, Ipr.Settings.Fps.Max.Int, Ipr.Settings.Fps.Low.InProgress
end

Ipr.Func.CopyData = function()
    local Ipr_TypeData = {}
    local Ipr_DataName = {
        ["Startup"] = true,
    }

    for i = 1, #Ipr_Fps_Booster.Convars do
        local Ipr_CopyList = Ipr_Fps_Booster.Convars[i]

        if not Ipr_DataName[Ipr_CopyList.Name] and not Ipr_CopyList.Vgui then
            Ipr_TypeData[#Ipr_TypeData + 1] = Ipr_CopyList
        end
    end

    Ipr.Settings.Data = {
        Copy = table.Copy(Ipr_TypeData), 
        Set = false,
    }
end

Ipr.Func.ResetFps = function()
    Ipr.Settings.Fps.Min.Int = Ipr_Infinity
    Ipr.Settings.Fps.Max.Int = 0
end

Ipr.Func.ColorTransition = function(int)
    return (int <= 30) and Ipr.Settings.TColor["rouge"] or (int > 30 and int <= 50) and Ipr.Settings.TColor["orange"] or Ipr.Settings.TColor["vert"]
end

Ipr.Func.OverridePaint = function(panel)
    local Ipr_PanelChild = panel:GetChildren()

    local Ipr_Override = {
        ["DPanel"] = function(frame)
            frame.Paint = function(self, w, h)
                draw.RoundedBox(12, 9, 6, w - 10, h - 10, Ipr.Settings.TColor["blanc"])
            end
        end,
        ["DSlider"] = function(frame)
            for _, ent in ipairs(Ipr_PanelChild) do
                if (ent:GetName() == "DTextEntry") then
                    ent:SetFont(Ipr.Settings.Font)
                    ent:SetTextColor(Ipr.Settings.TColor["blanc"])
                end
            end

            frame.Knob.Paint = function(self, w, h)
                draw.RoundedBox(3, 5, 2, w - 10, h - 4, Ipr.Settings.TColor["vert"])
            end
            frame.Paint = function(self, w, h)
                draw.RoundedBox(3, 7, 8, 3, h - 16, Ipr.Settings.TColor["rouge"])
                draw.RoundedBox(3, w / 2, 8, 3, h - 16, Ipr.Settings.TColor["rouge"])
                draw.RoundedBox(3, w - 8, 8, 3, h - 16, Ipr.Settings.TColor["rouge"])

                draw.RoundedBox(3, 7, h / 2 - 2, w - 12, h / 2 - 10, Ipr.Settings.TColor["rouge"])
            end
        end,
        ["DCheckBox"] = function(frame)
            frame.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, frame:GetChecked() and Ipr.Settings.TColor["vert"] or Ipr.Settings.TColor["rouge"])
                draw.RoundedBox(12, 7, 7, 2, 2, frame:GetChecked() and Ipr.Settings.TColor["blanc"] or color_black)
            end
        end,
    }

    for _, v in ipairs(Ipr_PanelChild) do
        local Ipr_FindClass = Ipr_Override[v:GetName()]
        if (Ipr_FindClass) then
            Ipr_FindClass(v)
        end
    end
end

local Ipr_Wide = ScrW()
local Ipr_Height = ScrH()

Ipr.Func.RenderBlur = function(panel, colors, border)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(Ipr.Settings.Blur)

    local Ipr_Posx, Ipr_Posy = panel:LocalToScreen(0, 0)
    Ipr.Settings.Blur:SetFloat("$blur", 1.5)
    Ipr.Settings.Blur:Recompute()

    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect(Ipr_Posx * -1, Ipr_Posy * -1, Ipr_Wide, Ipr_Height)

    local Ipr_VguiWide = panel:GetWide()
    local Ipr_VguiHeight = panel:GetTall()

    draw.RoundedBoxEx(border, 0, 0, Ipr_VguiWide, Ipr_VguiHeight, colors, true, true, true, true)
end

Ipr.Func.ClosePanel = function()
    for _, v in pairs(Ipr.Settings.Vgui) do
        if not IsValid(v) then
            continue
        end

        if (v:GetName() == "DFrame") then
            v:AlphaTo(0, 0.3, 0, function()
                if IsValid(v) then
                    v:Remove()
                end
            end)
        else
            v:Remove()
        end
    end
end

Ipr.Func.SetToolTip = function(text, panel, hover)
    if not IsValid(Ipr.Settings.Vgui.ToolTip) then
        Ipr.Settings.Vgui.ToolTip = vgui.Create("DTooltip")
        Ipr.Settings.Vgui.ToolTip:SetText("")
        Ipr.Settings.Vgui.ToolTip:SetTextColor(color_white)
        Ipr.Settings.Vgui.ToolTip:SetFont(Ipr.Settings.Font)

        Ipr.Settings.Vgui.ToolTip.Paint = function(self, w, h)
            Ipr.Func.RenderBlur(self, ColorAlpha(color_black, 130), 6)
        end

        Ipr.Settings.Vgui.ToolTip:SetVisible(false)
    end

    local Ipr_OverrideChildren = panel:GetChildren()
    local Ipr_WhiteListPanel = {
        ["DButton"] = true,
        ["DImageButton"] = true,
    }

    if (Ipr_WhiteListPanel[panel:GetName()]) then
        Ipr_OverrideChildren[#Ipr_OverrideChildren + 1] = panel
    end

    for i = 1, #Ipr_OverrideChildren do
        Ipr_OverrideChildren[i].OnCursorMoved = function(self)
            if not IsValid(Ipr.Settings.Vgui.ToolTip) then
                return
            end

            local ipr_InputX, ipr_InputY = input.GetCursorPos()
            local ipr_Pos = ipr_InputX - Ipr.Settings.Vgui.ToolTip:GetWide() / 2

            Ipr.Settings.Vgui.ToolTip:SetPos(ipr_Pos, ipr_InputY - 30)
        end
        Ipr_OverrideChildren[i].OnCursorExited = function()
            if not IsValid(Ipr.Settings.Vgui.ToolTip) then
                return
            end

            Ipr.Settings.Vgui.ToolTip:SetVisible(false)
        end
        Ipr_OverrideChildren[i].OnCursorEntered = function(self)
            if not IsValid(Ipr.Settings.Vgui.ToolTip) then
                return
            end
            
            Ipr.Settings.Vgui.ToolTip:SetText((hover) and text or text[Ipr.Settings.SetLang])
            Ipr.Settings.Vgui.ToolTip:SetTextColor(color_white)
            Ipr.Settings.Vgui.ToolTip:SetFont(Ipr.Settings.Font)

            Ipr.Settings.Vgui.ToolTip:SetVisible(true)

            Ipr.Settings.Vgui.ToolTip:SetAlpha(0)
            Ipr.Settings.Vgui.ToolTip:AlphaTo(255, 0.8, 0)

            timer.Simple(0.0001, function()
                if IsValid(self) then
                    self:OnCursorMoved()
                end
            end)
        end
    end
end

Ipr.Func.FogActivate = function(bool)
    if not bool then
        hook.Remove("SetupWorldFog", "IprFpsBooster_WorldFog")
        hook.Remove("SetupSkyboxFog", "IprFpsBooster_SkyboxFog")
    else
        hook.Add("SetupWorldFog", "IprFpsBooster_WorldFog", function()
            render.FogMode(MATERIAL_FOG_LINEAR)
            render.FogStart(Ipr.Func.GetConvar("FogStart"))
            render.FogEnd(Ipr.Func.GetConvar("FogEnd"))
            render.FogMaxDensity(0.9)

            render.FogColor(171, 174, 176)

            return true
        end)

        hook.Add("SetupSkyboxFog", "IprFpsBooster_SkyboxFog", function(scale)
            render.FogMode(MATERIAL_FOG_LINEAR)
            render.FogStart(Ipr.Func.GetConvar("FogStart") * scale)
            render.FogEnd(Ipr.Func.GetConvar("FogEnd") * scale)
            render.FogMaxDensity(0.9)

            render.FogColor(171, 174, 176)

            return true
        end)
    end
end

local Ipr_Map = game.GetMap()
local Ipr_Escape = 5

local function Ipr_DrawMultipleTextAligned(tbl)
    local Ipr_OldWide = 0
    local Ipr_NewWide = 0

    for t = 1, #tbl do
        local Ipr_TextTbl = tbl[t]
        local Ipr_Pos = Ipr_TextTbl.Pos

        for i = 1, #Ipr_TextTbl do
            Ipr_NewWide = Ipr_OldWide

            surface.SetFont(Ipr.Settings.Font)

            local Ipr_NameText = Ipr_TextTbl[i].Name
            local Ipr_TWide = surface.GetTextSize(Ipr_NameText)
            
            Ipr_OldWide = Ipr_OldWide + Ipr_TWide + Ipr_Escape

            draw.SimpleText(Ipr_NameText, Ipr.Settings.Font, Ipr_Pos.PWide + Ipr_NewWide, Ipr_Pos.PHeight, Ipr_TextTbl[i].FColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        end

        Ipr_OldWide = 0
    end
end

Ipr.Func.FpsHud = function()
    local Ipr_FpsCurrent, Ipr_FpsMin, Ipr_FpsMax, Ipr_FpsLow = Ipr.Func.FpsCalculator()
    local Ipr_HHeight = Ipr_Height * Ipr.Func.GetConvar("FpsPosHeight") / 100
    local Ipr_HWide = Ipr_Wide * Ipr.Func.GetConvar("FpsPosWidth") / 100
    local Ipr_PlayerPing = LocalPlayer():Ping()
    
    local Ipr_RenderFpsText = {
        {
           {Name = "FPS :", FColor = color_white},
           {Name = Ipr_FpsCurrent, FColor = Ipr.Func.ColorTransition(Ipr_FpsCurrent)},
           {Name = "|", FColor = color_white},
           {Name = "Min :", FColor = color_white},
           {Name = Ipr_FpsMin, FColor = Ipr.Func.ColorTransition(Ipr_FpsMin)},
           {Name = "|", FColor = color_white},
           {Name = "Max :", FColor = color_white},
           {Name = Ipr_FpsMax, FColor = Ipr.Func.ColorTransition(Ipr_FpsMax)},
           {Name = "|", FColor = color_white},
           {Name = "Low 1% :", FColor = color_white},
           {Name = Ipr_FpsLow, FColor = Ipr.Func.ColorTransition(Ipr_FpsLow)},

           Pos = {PWide = Ipr_HWide, PHeight = Ipr_HHeight},
        },

        {
           {Name = "Map :", FColor = color_white},
           {Name = Ipr_Map, FColor = Ipr.Settings.TColor["bleuc"]},
           {Name = "|", FColor = color_white},
           {Name = "Ping :", FColor = color_white},
           {Name = Ipr_PlayerPing, FColor = Ipr.Settings.TColor["bleuc"]},

           Pos = {PWide = Ipr_HWide - 1, PHeight = Ipr_HHeight + 20},
        },
    }

    Ipr_DrawMultipleTextAligned(Ipr_RenderFpsText)
end

local function Ipr_FpsBooster_Options(primary)
    if IsValid(Ipr.Settings.Vgui.Secondary) then
        Ipr.Settings.Vgui.Secondary:Remove()
    end

    local Ipr_SSize = {w = 240, h = 450}
    Ipr.Settings.Vgui.Secondary = vgui.Create("DFrame")
    
    local Ipr_SClose = vgui.Create("DImageButton", Ipr.Settings.Vgui.Secondary)

    Ipr.Settings.Vgui.Secondary:SetTitle("")
    Ipr.Settings.Vgui.Secondary:SetSize(Ipr_SSize.w, Ipr_SSize.h)
    Ipr.Settings.Vgui.Secondary:MakePopup()
    Ipr.Settings.Vgui.Secondary:ShowCloseButton(false)
    Ipr.Settings.Vgui.Secondary:SetDraggable(true)

    if IsValid(primary) then
        local function Ipr_MovedVgui()
            Ipr.Settings.Vgui.Secondary:AlphaTo(255, 1.5, 0)

            local Ipr_CenterSecondaryH = primary:GetY() - (Ipr_SSize.h / 2)
            local Ipr_FirstPosW = primary:GetX() + primary:GetWide()
            Ipr.Settings.Vgui.Secondary:SetPos(Ipr_FirstPosW, Ipr_CenterSecondaryH)

            Ipr_CenterSecondaryH = Ipr_CenterSecondaryH + (primary:GetTall() / 2)
            Ipr.Settings.Vgui.Secondary:MoveTo(Ipr_FirstPosW, Ipr_CenterSecondaryH, 0.5, 0)

            local Ipr_CenterSecondaryW = Ipr_FirstPosW + 10
            Ipr.Settings.Vgui.Secondary:MoveTo(Ipr_CenterSecondaryW, Ipr_CenterSecondaryH, 0.5, 0.5)
        end

        Ipr.Settings.Vgui.Secondary:SetAlpha(0)

        if not primary.PMoved then
            primary:MoveTo(primary:GetX() - (Ipr_SSize.w / 2), primary:GetY(), 0.3, 0, -1, Ipr_MovedVgui)
        else
            Ipr_MovedVgui()
        end
    else
        Ipr.Settings.Vgui.Secondary:Center()
    end
    
    Ipr.Settings.Vgui.Secondary.Paint = function(self, w, h)
        if (self.Dragging) and IsValid(primary) then
            local Ipr_CenterPrimaryW = self:GetX() - primary:GetWide() - 10
            local Ipr_CenterPrimaryH = self:GetY() + (Ipr_SSize.h / 2)
            Ipr_CenterPrimaryH = Ipr_CenterPrimaryH - (primary:GetTall() / 2)

            primary:SetPos(Ipr_CenterPrimaryW, Ipr_CenterPrimaryH)

            if not primary.PMoved then
               primary.PMoved = true
            end
        end

        Ipr.Func.RenderBlur(self, ColorAlpha(color_black, 130), 6)
        
        draw.RoundedBoxEx(6, 0, 0, w, 20, Ipr.Settings.TColor["bleu"], true, true, false, false)
        draw.SimpleText("Options FPS Booster", Ipr.Settings.Font, w / 2, 1, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)

        draw.SimpleText("FPS Limit : ", Ipr.Settings.Font, 5, h - 19, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_LEFT)
        local Ipr_FpsLimit = math.Round(Ipr.Func.InfoNum("fps_max"))
        Ipr_FpsLimit = (Ipr_FpsLimit > 1000) and 1000 or Ipr_FpsLimit

        draw.SimpleText(Ipr_FpsLimit, Ipr.Settings.Font, 67, h - 19, Ipr.Func.ColorTransition(Ipr_FpsLimit), TEXT_ALIGN_LEFT)
        
        draw.SimpleText("v" ..Ipr_Fps_Booster.Settings.Version, Ipr.Settings.Font, w - 39, h - 19, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_RIGHT)
        draw.SimpleText("[" ..Ipr_Fps_Booster.Settings.Developer.. "]", Ipr.Settings.Font, w - 5, h - 19, Ipr.Settings.TColor["vert"], TEXT_ALIGN_RIGHT)
    end

    Ipr_SClose:SetSize(16, 16)
    Ipr_SClose:SetPos(Ipr_SSize.w - Ipr_SClose:GetWide() - 2, 2)
    Ipr_SClose:SetImage("icon16/cross.png")
    Ipr_SClose.Paint = nil
    Ipr_SClose.DoClick = function()
        Ipr.Settings.Vgui.Secondary:AlphaTo(0, 0.3, 0, function()
            if IsValid(Ipr.Settings.Vgui.Secondary) then
                Ipr.Settings.Vgui.Secondary:Remove()
            end

            if IsValid(primary) and not primary.PMoved then
                primary:MoveTo(Ipr_Wide / 2 - primary:GetWide() / 2, Ipr_Height / 2 - primary:GetTall() / 2, 0.3, 0)
            end
        end)
    end

    local Ipr_CenterVgui = Ipr_SSize.w / 2
    Ipr.Settings.Vgui.CheckBox = {}
    
    local function Ipr_SScrollPaint(panel)
        panel.Paint = nil
        
        panel.btnUp.Paint = function(self, w, h)
           draw.RoundedBoxEx(3, 0, 0, w, h, Ipr.Settings.TColor["bleu"], true, true, false, false)
        end
        panel.btnDown.Paint = function(self, w, h)
           draw.RoundedBoxEx(3, 0, 0, w, h, Ipr.Settings.TColor["bleu"], false, false, true, true)
        end
        panel.btnGrip.Paint = function(self, w, h)
           draw.RoundedBox(1, 0, 0, w, h, Ipr.Settings.TColor["bleu"])
        end
    end

    local Ipr_SOpti = vgui.Create("DPanel", Ipr.Settings.Vgui.Secondary)
    Ipr_SOpti:SetSize(232, 165)
    Ipr_SOpti:SetPos(Ipr_CenterVgui - (Ipr_SOpti:GetWide() / 2), 90)
    Ipr_SOpti.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(color_black, 90))
        draw.SimpleText(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].TSettings, Ipr.Settings.Font, w / 2, 1, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)
    end

    local Ipr_Revert = vgui.Create("DImageButton", Ipr_SOpti)
    Ipr_Revert:SetSize(16, 16)
    Ipr_Revert:SetPos(Ipr_SOpti:GetWide() - Ipr_Revert:GetWide() - 2, 2)
    Ipr_Revert:SetImage("icon16/arrow_rotate_clockwise.png")
    Ipr.Func.SetToolTip(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].RevertData, Ipr_Revert, true)
    Ipr_Revert.Paint = nil
    Ipr_Revert.DoClick = function()
        local Ipr_CopyFind = false

        for i = 1, #Ipr_Fps_Booster.Convars do
           local Ipr_ConvarList = Ipr_Fps_Booster.Convars[i]
           local Ipr_ConvarName = Ipr_ConvarList.Name
           local Ipr_ConvarCheck = Ipr_ConvarList.Checked

            for i = 1, #Ipr.Settings.Data.Copy do 
               local Ipr_CopyList = Ipr.Settings.Data.Copy[i]
               local Ipr_CopyName = Ipr_CopyList.Name
               local Ipr_CopyDefault = Ipr_CopyList.Checked

                if (Ipr_ConvarName == Ipr_CopyName) and (Ipr_ConvarCheck ~= Ipr_CopyDefault) then
                    for i = 1, #Ipr.Settings.Vgui.CheckBox do 
                       local Ipr_CheckList = Ipr.Settings.Vgui.CheckBox[i]
                       local Ipr_CheckName = Ipr_CheckList.Name

                        if (Ipr_CopyName == Ipr_CheckName) then
                            Ipr_CheckList.Vgui:SetValue(Ipr_CopyDefault)
                            Ipr_CopyFind = true
                            break
                        end
                    end
                    break
                end
            end
        end

        chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], (Ipr_CopyFind) and Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].RevertDataApply or Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].RevertDataCancel)
    end

    local Ipr_CheckboxState = {
        [true] = {Icon = "icon16/lorry_flatbed.png", PoH = 0},
        [false] = {Icon = "icon16/lorry.png", PoH = 3},
    }

    local Ipr_SUncheck, Ipr_SChecked = vgui.Create("DImageButton", Ipr_SOpti), Ipr.Func.IsChecked()
    Ipr_SUncheck:SetSize(16, 16)
    Ipr_SUncheck:SetPos(5, Ipr_CheckboxState[Ipr_SChecked].PoH)
    Ipr_SUncheck:SetImage(Ipr_CheckboxState[Ipr_SChecked].Icon)
    Ipr_SUncheck.Paint = nil
    Ipr.Func.SetToolTip(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].CheckUncheckAll, Ipr_SUncheck, true)
    Ipr_SUncheck.DoClick = function()
        Ipr_SChecked = not Ipr_SChecked
        for i = 1, #Ipr.Settings.Vgui.CheckBox do 
            if (i > #Ipr_Fps_Booster.DefaultCommands) then
                break
            end

            Ipr.Settings.Vgui.CheckBox[i].Vgui:SetValue(Ipr_SChecked)
        end

        Ipr_SUncheck:SetImage(Ipr_CheckboxState[Ipr_SChecked].Icon)
        Ipr_SUncheck:SetY(Ipr_CheckboxState[Ipr_SChecked].PoH)
    end
      
    local Ipr_SScrollOpti = vgui.Create("DScrollPanel", Ipr_SOpti)
    Ipr_SScrollOpti:Dock(FILL)
    Ipr_SScrollOpti:DockMargin(5, 22, 0, 5)
    local Ipr_SScrollVbarOpti = Ipr_SScrollOpti:GetVBar()
    Ipr_SScrollVbarOpti:SetWide(11)
    Ipr_SScrollPaint(Ipr_SScrollVbarOpti)

    for i = 1, #Ipr_Fps_Booster.DefaultCommands do
        local Ipr_SOptiTbl = Ipr_Fps_Booster.DefaultCommands[i]

        local Ipr_SOptiPanel = vgui.Create("DPanel", Ipr_SScrollOpti)
        Ipr_SOptiPanel:SetSize(225, 25)
        Ipr_SOptiPanel:Dock(TOP)
        Ipr_SOptiPanel.Paint = nil

        local Ipr_SOptiButton = vgui.Create("DCheckBoxLabel", Ipr_SOptiPanel)
        Ipr_SOptiButton:Dock(FILL)
        Ipr_SOptiButton:SetText("")

        Ipr.Func.SetConvar(Ipr_SOptiTbl.Name, Ipr_SOptiTbl.DefaultCheck, nil, true, true)

        Ipr_SOptiButton:SetValue(Ipr.Func.GetConvar(Ipr_SOptiTbl.Name))
        Ipr_SOptiButton:SetWide(200)

        Ipr.Func.SetToolTip(Ipr_Fps_Booster.DefaultCommands[i].Localization.ToolTip, Ipr_SOptiButton)
        Ipr.Func.OverridePaint(Ipr_SOptiButton)
        
        Ipr_SOptiButton.Paint = function(self, w, h)
            draw.SimpleText(Ipr_Fps_Booster.DefaultCommands[i].Localization.Text[Ipr.Settings.SetLang], Ipr.Settings.Font, 22, 5, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_LEFT)
        end
        Ipr_SOptiButton.OnChange = function(self)
            Ipr.Func.SetConvar(Ipr_SOptiTbl.Name, self:GetChecked())

            local Ipr_Compare = Ipr_SOptiTbl.Name
            local Ipr_ConvarsCount = #Ipr_Fps_Booster.Convars
            local Ipr_ConvarFind = false

            for i = 1, #Ipr.Settings.Data.Copy do
                local Ipr_DataName = Ipr.Settings.Data.Copy[i].Name
                local Ipr_DataCheck = Ipr.Settings.Data.Copy[i].Checked

                for c = 1, Ipr_ConvarsCount do
                     if (Ipr_DataName == Ipr_Fps_Booster.Convars[c].Name) and (Ipr_DataCheck ~= Ipr_Fps_Booster.Convars[c].Checked) then
                         Ipr_ConvarFind = true
                         break
                     end
                end
            end

            Ipr.Settings.Data.Set = Ipr_ConvarFind
        end

        Ipr.Settings.Vgui.CheckBox[#Ipr.Settings.Vgui.CheckBox + 1] = {Vgui = Ipr_SOptiButton, Default = Ipr_SOptiTbl.DefaultCheck, Name = Ipr_SOptiTbl.Name, Paired = Ipr_SOptiTbl.Paired}
    end

    local Ipr_SConfig = vgui.Create("DPanel", Ipr.Settings.Vgui.Secondary)
    Ipr_SConfig:SetSize(232, 165)
    Ipr_SConfig:SetPos(Ipr_CenterVgui - (Ipr_SConfig:GetWide() / 2), 260)
    Ipr_SConfig.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(color_black, 90))
        draw.SimpleText("Configuration :", Ipr.Settings.Font, w / 2, 1, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)
    end

    local Ipr_SScrollConfig = vgui.Create("DScrollPanel", Ipr_SConfig)
    Ipr_SScrollConfig:Dock(FILL)
    Ipr_SScrollConfig:DockMargin(5, 22, 0, 5)
    local Ipr_SScrollVbarConfig = Ipr_SScrollConfig:GetVBar()
    Ipr_SScrollVbarConfig:SetWide(11)
    Ipr_SScrollPaint(Ipr_SScrollVbarConfig)

    local Ipr_OverrideVgui = {
        ["DCheckBoxLabel"] = {
            Func = function(panel, tbl, primary)
                panel.Paint = function(self, w, h)
                    draw.SimpleText(tbl.Localization.Text[Ipr.Settings.SetLang], Ipr.Settings.Font, 22, 4, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_LEFT)
                end

                panel:SetValue(Ipr.Func.GetConvar(tbl.Name))
                panel:SetWide(210)
                panel:Dock(FILL)

                Ipr.Func.SetToolTip(tbl.Localization.ToolTip, panel)

                local Ipr_Name = tbl.Name
                panel.OnChange = function(self)
                   local Ipr_GetChecked = self:GetChecked()
                   Ipr.Func.SetConvar(Ipr_Name, Ipr_GetChecked, 1)

                   for i = 1, #Ipr.Settings.Vgui.CheckBox do 
                        if (Ipr.Settings.Vgui.CheckBox[i].Paired == Ipr_Name) then
                            local Ipr_Vgui = Ipr.Settings.Vgui.CheckBox[i].Vgui
                            Ipr_Vgui = Ipr_Vgui:GetParent()

                            if IsValid(Ipr_Vgui) then
                                Ipr_Vgui:SetDisabled(not Ipr_GetChecked)
                            end
                        end
                   end

                   if (tbl.Run_HookFog) then
                        Ipr.Func.FogActivate(Ipr_GetChecked)
                   elseif (tbl.Run_HookFps) then
                        if (Ipr_GetChecked) then
                            hook.Add("PostDrawHUD", "IprFpsBooster_HUD", Ipr.Func.FpsHud)
                        else
                            hook.Remove("PostDrawHUD", "IprFpsBooster_HUD", Ipr.Func.FpsHud)
                        end
                    elseif (tbl.Run_Debug) then
                        Ipr.Settings.Debug = Ipr_GetChecked
                    end
                end
            end,

            Parent = function()
                local Ipr_CheckBoxConfig = vgui.Create("DPanel", Ipr_SScrollConfig)
                Ipr_CheckBoxConfig:SetSize(225, 25)
                Ipr_CheckBoxConfig:Dock(TOP)
                Ipr_CheckBoxConfig.Paint = nil

                return Ipr_CheckBoxConfig
            end,
        },
        ["DNumSlider"] = {
            Func = function(panel, tbl, primary)
                primary.Paint = function(self, w, h)
                    draw.SimpleText(tbl.Localization.Text[Ipr.Settings.SetLang].. " [" ..math.Round(panel:GetValue()).. "]", Ipr.Settings.Font, w / 2, 0, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)
                end

                local Ipr_DNumChildren = panel:GetChildren()
                local Ipr_PrimaryWide = primary:GetWide()

                for _, v in ipairs(Ipr_DNumChildren) do
                    local Ipr_GName = v:GetName()

                    if (Ipr_GName == "DSlider") then
                        v:Dock(FILL)
                        v:SetSize(Ipr_PrimaryWide, 25)
                    elseif (Ipr_GName == "DLabel") then
                        v:GetChildren()[1]:SetVisible(false)
                        v:SetVisible(false)
                    elseif (Ipr_GName == "DTextEntry") then
                        v:SetVisible(false)
                    end
                end

                panel:SetSize(Ipr_PrimaryWide, 25)
                panel:Dock(BOTTOM)
                panel:SetMinMax(0, tbl.Max or 100)
                panel:SetValue(Ipr.Func.GetConvar(tbl.Name))
                panel:SetDecimals(0)

                panel.OnValueChanged = function(self)
                   Ipr.Func.SetConvar(tbl.Name, self:GetValue(), 1)
                end
            end,
            
            Parent = function(int, tbl)
                local Ipr_DNumConfig = vgui.Create("DPanel", Ipr_SScrollConfig)
                Ipr_DNumConfig:SetSize(225, 39)
                Ipr_DNumConfig:Dock(TOP)
                
                return Ipr_DNumConfig
            end,
        },
    }

    for i = 1, #Ipr_Fps_Booster.DefaultSettings do
        local Ipr_SConfigTbl = Ipr_Fps_Booster.DefaultSettings[i]
        local Ipr_SConfigButton = Ipr_OverrideVgui[Ipr_SConfigTbl.Vgui].Parent(i, Ipr_SConfigTbl)
        local Ipr_SConfigCreate = vgui.Create(Ipr_SConfigTbl.Vgui, Ipr_SConfigButton)

        Ipr_SConfigCreate:Dock(TOP)
        Ipr_SConfigCreate:SetText("")

        Ipr.Func.SetConvar(Ipr_SConfigTbl.Name, Ipr_SConfigTbl.DefaultCheck, nil, true)
        Ipr.Func.OverridePaint(Ipr_SConfigCreate)

        Ipr_OverrideVgui[Ipr_SConfigTbl.Vgui].Func(Ipr_SConfigCreate, Ipr_SConfigTbl, Ipr_SConfigButton)
        Ipr.Settings.Vgui.CheckBox[#Ipr.Settings.Vgui.CheckBox + 1] = {Vgui = Ipr_SConfigCreate, Default = Ipr_SConfigTbl.DefaultCheck, Name = Ipr_SConfigTbl.Name, Paired = Ipr_SConfigTbl.Paired}
   
        if (Ipr_SConfigTbl.Paired) then
            Ipr_SConfigButton:SetDisabled(not Ipr.Func.GetConvar(Ipr_SConfigTbl.Paired))
        end
    end

    local Ipr_SManage = vgui.Create("DPanel", Ipr.Settings.Vgui.Secondary)
    Ipr_SManage:SetSize(150, 60)
    Ipr_SManage:SetPos(Ipr_CenterVgui - (Ipr_SManage:GetWide() / 2), 25)
    Ipr_SManage.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(color_black, 90))
    end
    
    local Ipr_SScrollManage = vgui.Create("DScrollPanel", Ipr_SManage)
    Ipr_SScrollManage:Dock(FILL)
    Ipr_SScrollManage:DockMargin(-1, 2, 0, 2)
    local Ipr_SScrollVbarManage = Ipr_SScrollManage:GetVBar()
    Ipr_SScrollVbarManage:SetWide(5)
    Ipr_SScrollPaint(Ipr_SScrollVbarManage)

    local Ipr_SManageDefault = {
        {
            Vgui = "DButton",
            Icon = "icon16/bullet_disk.png",
            Sound = "buttons/button9.wav",
            DrawLine = true,
            Localization = {
                        Text = Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].BSaveOpti,
                        ToolTip = {
                            ["FR"] = "Sauvegarde les paramètres d'optimisation !",
                            ["EN"] = "Save optimization settings !",
                        },
            },
            Func = function()
                if not Ipr.Settings.Data.Set then
                    chat.AddText(Ipr.Settings.TColor["rouge"], "[", "ERROR", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].CheckedBox)
                    return
                end

                local Ipr_CurrentState = Ipr.Func.CurrentState()
                if (Ipr_CurrentState) then
                    Ipr.Func.Activate(true)
                    chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].OptimizationReloaded)
                end

                local Ipr_StartupDelay = timer.Exists(Ipr.Settings.StartupLaunch.Name)
                if (Ipr_StartupDelay) then
                    timer.Remove(Ipr.Settings.StartupLaunch.Name)
                    chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].StartupAbandoned)
                end

                Ipr.Func.SetConvar("Startup", false, 2)
                Ipr.Func.CopyData()

                file.Write(Ipr_Fps_Booster.Settings.Save.. "convars.json", util.TableToJSON(Ipr_Fps_Booster.Convars))
                chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].SettingsSaved)
            end
        },
        {
            Vgui = "DButton",
            Icon = "icon16/bullet_key.png",
            Sound = "buttons/button9.wav",
            DataDelayed = true,
            DrawLine = true,
            Convar = {
                Name = "Startup",
                DefaultCheck = false,
            },
            Localization = {
                        Text = "Apply to startup",
                        ToolTip = {
                            ["FR"] = "Optimisation lancée au démarrage du jeu (orange : en attente, vert : optimisation lancée)",
                            ["EN"] = "Optimization launched at game startup (orange : waiting, green : optimization launched)",
                        },
            },
            Func = function(name, value)
                local Ipr_StartupDelay = timer.Exists(Ipr.Settings.StartupLaunch.Name)
                if (Ipr_StartupDelay) then
                    timer.Remove(Ipr.Settings.StartupLaunch.Name)
                    chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].StartupAbandoned)
                end

                local Ipr_SetStartup = value
                if (Ipr_SetStartup) then
                    local Ipr_CurrentState = Ipr.Func.CurrentState()
                    if not Ipr_CurrentState then
                        Ipr.Func.Activate(true)
                    end
                    Ipr.Func.SetConvar(name, Ipr_SetStartup)

                    timer.Create(Ipr.Settings.StartupLaunch.Name, Ipr.Settings.StartupLaunch.Delay, 1, function()
                        Ipr.Func.SetConvar(name, true, 2)
                        chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["vert"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].StartupEnabled)
                    end)

                    chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].StartupLaunched)
                else
                    Ipr.Func.SetConvar(name, Ipr_SetStartup, 1)
                    chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].StartupDisabled)
                end
            end
        },
        {
            Vgui = "DButton",
            Icon = "icon16/bullet_wrench.png",
            Sound = "buttons/button9.wav",
            DrawLine = false,
            Localization = {
                        Text = "Default settings",
                        ToolTip = {
                            ["FR"] = "Rétablir tout les paramètres par défaut !",
                            ["EN"] = "Set default parameters !",
                        },
            },
            Func = function()
                for i = 1, #Ipr.Settings.Vgui.CheckBox do 
                   Ipr.Settings.Vgui.CheckBox[i].Vgui:SetValue(Ipr.Settings.Vgui.CheckBox[i].Default)
                end

                chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].DefaultConfig)
            end
        },
    }

    for i = 1, #Ipr_SManageDefault do
        local Ipr_SManageTbl = Ipr_SManageDefault[i]
        local Ipr_SManageCreate = vgui.Create(Ipr_SManageTbl.Vgui, Ipr_SScrollManage)

        Ipr_SManageCreate:SetPos(7, i * (1 + 25) - 20)
        Ipr_SManageCreate:SetSize(135, 20)
        Ipr_SManageCreate:SetText("")
        Ipr_SManageCreate:SetImage(Ipr_SManageTbl.Icon)

        Ipr.Func.SetToolTip(Ipr_SManageTbl.Localization.ToolTip, Ipr_SManageCreate)
        if (Ipr_SManageTbl.Convar) then
            Ipr.Func.SetConvar(Ipr_SManageTbl.Convar.Name, Ipr_SManageTbl.Convar.DefaultCheck, nil, true)
        end

        local Ipr_ConvarColor = color_white
        Ipr_SManageCreate.Paint = function(self, w, h)
            local Ipr_Hovered = self:IsHovered()

            if (Ipr_SManageTbl.DrawLine) then
                if (Ipr_SManageTbl.Convar) then
                    draw.RoundedBoxEx(6, 0, 0, w, h, (Ipr_Hovered) and Ipr.Settings.TColor["bleuc"] or Ipr.Settings.TColor["bleu"], true, true, false, false)

                    local Ipr_StartupDelay = timer.Exists(Ipr.Settings.StartupLaunch.Name)
                    Ipr_ConvarColor = (Ipr_StartupDelay) and Ipr.Settings.TColor["orange"] or Ipr.Func.GetConvar(Ipr_SManageTbl.Convar.Name) and Ipr.Settings.TColor["vert"] or Ipr.Settings.TColor["rouge"]
                    
                    draw.RoundedBox(0, 0, h- 1, w, h, Ipr_ConvarColor)
                else
                    if (Ipr.Settings.Data.Set) then
                        local Ipr_SysTime = SysTime()
                        local Ipr_ColorAbs = math.abs(math.sin(Ipr_SysTime * 2.5) * 255)

                        draw.RoundedBoxEx(6, 0, 0, w, h, (Ipr_Hovered) and Ipr.Settings.TColor["bleuc"] or Ipr.Settings.TColor["bleu"], true, true, false, false)
                        draw.RoundedBox(0, 0, h- 1, w, h, Color(Ipr_ColorAbs, Ipr_ColorAbs, 0))
                    else
                        draw.RoundedBox(6, 0, 0, w, h, (Ipr_Hovered) and Ipr.Settings.TColor["bleuc"] or Ipr.Settings.TColor["bleu"])
                    end
                end
            else
               draw.RoundedBox(6, 0, 0, w, h, (Ipr_Hovered) and Ipr.Settings.TColor["gvert_"] or Ipr.Settings.TColor["gvert"])
            end
            
            draw.SimpleText(Ipr_SManageTbl.Localization.Text, Ipr.Settings.Font, w / 2 + 6, 1, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)
        end

        Ipr_SManageCreate.DoClick = function()
            surface.PlaySound(Ipr_SManageTbl.Sound)

            if (Ipr_SManageTbl.Convar) then
                local Ipr_StartupDelay = timer.Exists(Ipr.Settings.StartupLaunch.Name)
                local Ipr_DataBool = false

                if (Ipr_SManageTbl.DataDelayed) and (Ipr_StartupDelay) then
                    Ipr_DataBool = not Ipr_StartupDelay
                else
                    Ipr_DataBool = not Ipr.Func.GetConvar(Ipr_SManageTbl.Convar.Name)
                end

                Ipr_SManageTbl.Func(Ipr_SManageTbl.Convar.Name, Ipr_DataBool)
                return
            end

            Ipr_SManageTbl.Func()
        end
    end
end

local function Ipr_FpsBooster()
    Ipr.Func.ClosePanel()
    Ipr.Func.CopyData()

    local Ipr_PSize = {w = 300, h = 270}
    Ipr.Settings.Vgui.Primary = vgui.Create("DFrame")

    local Ipr_PIcon = vgui.Create("DPanel", Ipr.Settings.Vgui.Primary)
    local Ipr_PLanguage = vgui.Create("DComboBox", Ipr.Settings.Vgui.Primary)
    local Ipr_PClose = vgui.Create("DImageButton", Ipr.Settings.Vgui.Primary)

    local Ipr_PFps = vgui.Create("DButton", Ipr.Settings.Vgui.Primary)
    local Ipr_PEnabled = vgui.Create("DButton", Ipr.Settings.Vgui.Primary)
    local Ipr_PDisabled = vgui.Create("DButton", Ipr.Settings.Vgui.Primary)
    local Ipr_PSettings = vgui.Create("DButton", Ipr.Settings.Vgui.Primary)
    local Ipr_PResetFps = vgui.Create("DButton", Ipr.Settings.Vgui.Primary)

    Ipr.Settings.Vgui.Primary:SetTitle("")
    Ipr.Settings.Vgui.Primary:SetSize(Ipr_PSize.w, Ipr_PSize.h)
    Ipr.Settings.Vgui.Primary:Center()
    Ipr.Settings.Vgui.Primary:MakePopup()
    
    Ipr.Settings.Vgui.Primary:SetMouseInputEnabled(false)

    timer.Simple(0.1, function()
         if not IsValid(Ipr.Settings.Vgui.Primary) then
            return 
         end

         input.SetCursorPos(Ipr.Settings.Vgui.Primary:GetX() + (Ipr_PSize.w / 2), Ipr.Settings.Vgui.Primary:GetY() + (Ipr_PSize.h - 50))
         Ipr.Settings.Vgui.Primary:SetMouseInputEnabled(true)
    end)

    Ipr.Settings.Vgui.Primary:ShowCloseButton(false)
    Ipr.Settings.Vgui.Primary:SetDraggable(true)

    Ipr.Settings.Vgui.Primary:SetAlpha(0)
    Ipr.Settings.Vgui.Primary:AlphaTo(255, 1, 0)
    
    Ipr.Settings.Vgui.Primary.Paint = function(self, w, h)
        if (self.Dragging) then
            if IsValid(Ipr.Settings.Vgui.Secondary) then
                local Ipr_CenterSecondaryW = self:GetX() + Ipr_PSize.w + 10
                local Ipr_CenterSecondaryH = self:GetY() - (Ipr.Settings.Vgui.Secondary:GetTall() / 2)
                Ipr_CenterSecondaryH = Ipr_CenterSecondaryH + (Ipr_PSize.h / 2)
    
                Ipr.Settings.Vgui.Secondary:SetPos(Ipr_CenterSecondaryW, Ipr_CenterSecondaryH)
            end

            if not self.PMoved then
               self.PMoved = true
            end
        end

        Ipr.Func.RenderBlur(self, ColorAlpha(color_black, 130), 6)

        draw.RoundedBoxEx(6, 0, 0, w, 33, Ipr.Settings.TColor["bleu"], true, true, false, false)
        draw.SimpleText(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].TEnabled,Ipr.Settings.Font,w / 2, 1, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)

        local Ipr_CurrentState = Ipr.Func.CurrentState()
        local Ipr_TCurrentStatus = (Ipr_CurrentState) and "On (Boost)" or "Off"
        local ipr_TCurrentColor = (Ipr_CurrentState) and (Ipr.Settings.Data.Set) and Ipr.Settings.TColor["orange"] or (Ipr_CurrentState) and Ipr.Settings.TColor["vert"] or Ipr.Settings.TColor["rouge"]
        
        draw.SimpleText("FPS :",Ipr.Settings.Font, (Ipr_CurrentState) and w / 2 - 25 or w / 2 -10, 16, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)
        draw.SimpleText(Ipr_TCurrentStatus, Ipr.Settings.Font, (Ipr_CurrentState) and w / 2 + 22 or w / 2 + 18, 16, ipr_TCurrentColor, TEXT_ALIGN_CENTER)
    end

    local Ipr_Icon = {
        Computer = Material("icon/Ipr_boost_computer.png", "noclamp smooth"),
        Wrench = Material("icon/Ipr_boost_wrench.png", "noclamp smooth"),
    }
    local Ipr_Rotate = {start = 10, s_end = 35, step = 5}
    local Ipr_Copy = table.Copy(Ipr_Rotate)

    Ipr_Copy.NextStep = 0.2
    Ipr_Copy.Update = 0

    Ipr_Copy.Loop = function()
        local Ipr_SysTime = SysTime()

        if (Ipr_SysTime > Ipr_Copy.Update) then
            for i = Ipr_Copy.start, Ipr_Copy.s_end, Ipr_Copy.step do
                Ipr_Copy.start = i + Ipr_Copy.step

                if (i == Ipr_Copy.s_end) then
                    local Ipr_min = (Ipr_Copy.step < 0)

                    Ipr_Copy.start = Ipr_min and Ipr_Rotate.start or Ipr_Copy.s_end
                    Ipr_Copy.s_end = Ipr_min and Ipr_Rotate.s_end or Ipr_Rotate.start
                    Ipr_Copy.step = Ipr_min and Ipr_Rotate.step or -Ipr_Rotate.step
                end
                break
            end
            Ipr_Copy.Update = Ipr_SysTime + Ipr_Copy.NextStep
        end

        return Ipr_Copy.start
    end

    Ipr_Copy.Draw = function(x, y, w, h, rotate, x0)
        local Ipr_Rad = math.rad(rotate)
        local Ipr_Cos, Ipr_Sin = math.cos(Ipr_Rad), math.sin(Ipr_Rad)
        local Ipr_Newx = Ipr_Sin - x0 * Ipr_Cos
        local Ipr_NewY = Ipr_Cos + x0 * Ipr_Sin

        surface.DrawTexturedRectRotated(x + Ipr_Newx, y + Ipr_NewY, w, h, rotate)
    end

    Ipr_PIcon:Dock(FILL)
    Ipr_PIcon.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Ipr_Icon.Computer)
        surface.DrawTexturedRect(-10, 0, 350, 235)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Ipr_Icon.Wrench)
        local Ipr_Loop = Ipr_Copy.Loop()
        Ipr_Copy.Draw(207, 120, 220, 220, Ipr_Loop, -25)
    end

    Ipr_PFps:SetSize(110, 83)
    Ipr_PFps:SetPos(Ipr_PSize.w / 2 - Ipr_PFps:GetWide() / 2 + 1, Ipr_PSize.h / 2 - Ipr_PFps:GetTall() / 2 - 15)
    Ipr_PFps:SetText("")
    Ipr_PFps.Paint = function(self, w, h)
        local Ipr_FpsCurrent, Ipr_FpsMin, Ipr_FpsMax, Ipr_FpsLow = Ipr.Func.FpsCalculator()

        draw.SimpleText(Ipr.Settings.Status.Name, Ipr.Settings.Font, w / 2, 6, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)

        draw.SimpleText(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].FpsCurrent, Ipr.Settings.Font, w / 2 + 10, 25, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_RIGHT)
        draw.SimpleText(Ipr_FpsCurrent, Ipr.Settings.Font, w / 2 + 15, 25, Ipr.Func.ColorTransition(Ipr_FpsCurrent), TEXT_ALIGN_LEFT)

        draw.SimpleText(Ipr.Settings.Fps.Max.Name, Ipr.Settings.Font, w / 2 + 10, 40, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_RIGHT)
        draw.SimpleText(Ipr_FpsMax, Ipr.Settings.Font, w / 2 + 12, 40, Ipr.Func.ColorTransition(Ipr_FpsMax), TEXT_ALIGN_LEFT)

        draw.SimpleText(Ipr.Settings.Fps.Min.Name, Ipr.Settings.Font, w / 2 + 6, 55, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_RIGHT)
        draw.SimpleText(Ipr_FpsMin, Ipr.Settings.Font, w / 2 + 8, 55, Ipr.Func.ColorTransition(Ipr_FpsMin), TEXT_ALIGN_LEFT)

        draw.SimpleText(Ipr.Settings.Fps.Low.Name, Ipr.Settings.Font, w / 2 + 17, 70, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_RIGHT)
        draw.SimpleText(Ipr_FpsLow, Ipr.Settings.Font, w / 2 + 19, 70, Ipr.Func.ColorTransition(Ipr_FpsLow), TEXT_ALIGN_LEFT)
    end
    Ipr_PFps.DoClick = function()
        gui.OpenURL(Ipr_Fps_Booster.Settings.ExternalLink)
    end

    Ipr_PClose:SetSize(16, 16)
    Ipr_PClose:SetPos(Ipr_PSize.w - Ipr_PClose:GetWide() - 2, 2)
    Ipr_PClose:SetImage("icon16/cross.png")
    Ipr_PClose.Paint = nil
    Ipr_PClose.DoClick = function()
        Ipr.Func.ClosePanel()
    end

    Ipr_PEnabled:SetSize(110, 24)
    Ipr_PEnabled:SetPos(5, Ipr_PSize.h - Ipr_PEnabled:GetTall() - 5)
    Ipr_PEnabled:SetImage("icon16/tick.png")
    Ipr_PEnabled:SetText("")
    Ipr_PEnabled.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Ipr.Settings.TColor["bleuc"] or Ipr.Settings.TColor["bleu"])
        draw.SimpleText(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].VEnabled, Ipr.Settings.Font, w / 2 + 3, 3, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)
    end
    Ipr_PEnabled.DoClick = function()
        local Ipr_CheckBox = Ipr.Func.IsChecked()
        if not Ipr_CheckBox then
            return chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].CheckedBox)
        end

        local Ipr_ConvarsEnabled = Ipr.Func.MatchConvar(true)
        if (Ipr_ConvarsEnabled) then
            Ipr.Func.Activate(true)
            Ipr.Func.ResetFps()

            chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].PreventCrash)
        else
            chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].AEnabled)
        end

        local Ipr_CloseFpsBooster = Ipr.Func.GetConvar("AutoClose")
        if (Ipr_CloseFpsBooster) then
            Ipr.Func.ClosePanel()
        end

        surface.PlaySound("buttons/combine_button7.wav")
    end

    Ipr_PDisabled:SetSize(110, 24)
    Ipr_PDisabled:SetPos(Ipr_PSize.w - Ipr_PDisabled:GetWide() - 5, Ipr_PSize.h - Ipr_PDisabled:GetTall() - 5)
    Ipr_PDisabled:SetImage("icon16/cross.png")
    Ipr_PDisabled:SetText("")
    Ipr_PDisabled.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Ipr.Settings.TColor["bleuc"] or Ipr.Settings.TColor["bleu"])
        draw.SimpleText(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].VDisabled, Ipr.Settings.Font, w / 2 + 6, 3, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)
    end
    Ipr_PDisabled.DoClick = function()
        local Ipr_ConvarsEnabled = Ipr.Func.MatchConvar(false)
        if (Ipr_ConvarsEnabled) then
            Ipr.Func.Activate(false)
            Ipr.Func.ResetFps()

            chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].Optimization)
        else
            chat.AddText(Ipr.Settings.TColor["rouge"], "[", "FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].ADisabled)
        end

        local Ipr_CloseFpsBooster = Ipr.Func.GetConvar("AutoClose")
        if (Ipr_CloseFpsBooster) then
            Ipr.Func.ClosePanel()
        end
        
        surface.PlaySound("buttons/combine_button5.wav")
    end

    Ipr_PResetFps:SetSize(150, 20)
    Ipr_PResetFps:SetPos(Ipr_PSize.w / 2 - Ipr_PResetFps:GetWide() / 2 + 1, 190)
    Ipr_PResetFps:SetText("")
    Ipr_PResetFps:SetImage("icon16/arrow_refresh.png")
    Ipr.Func.SetToolTip(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].TReset, Ipr_PResetFps, true)
    Ipr_PResetFps.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Ipr.Settings.TColor["bleuc"] or Ipr.Settings.TColor["bleu"])
        draw.SimpleText("Reset FPS Max/Min", Ipr.Settings.Font, w / 2 + 5, 1, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)
    end
    Ipr_PResetFps.DoClick = function()
        Ipr.Func.ResetFps()
        surface.PlaySound("buttons/button9.wav")
    end

    Ipr_PSettings:SetSize(85, 20)
    Ipr_PSettings:SetPos(Ipr_PSize.w - Ipr_PSettings:GetWide() - 5, 37)
    Ipr_PSettings:SetText("")
    Ipr.Func.SetToolTip(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].Options, Ipr_PSettings, true)
    local ipr_MatLoading = Material("materials/icon16/cog.png")
    Ipr_PSettings.Paint = function(self, w, h)
        local Ipr_IsHovered = self:IsHovered()
        draw.RoundedBox(6, 0, 0, w, h, (Ipr_IsHovered) and Ipr.Settings.TColor["bleuc"] or Ipr.Settings.TColor["bleu"])

        draw.SimpleText("Options ", Ipr.Settings.Font, w / 2 + 9, 1, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_CENTER)

        surface.SetMaterial(ipr_MatLoading)
        surface.SetDrawColor(color_white)

        local Ipr_PRotation = 0
        if (Ipr_IsHovered) then
            local Ipr_SysTime = SysTime()
            Ipr_PRotation = math.sin(Ipr_SysTime * 80 * math.pi / 180) * 180
        end
        surface.DrawTexturedRectRotated(11, 11, 16, 16, Ipr_PRotation)
    end
    Ipr_PSettings.DoClick = function()
        if IsValid(Ipr.Settings.Vgui.Secondary) then
            return
        end

        Ipr_FpsBooster_Options(Ipr.Settings.Vgui.Primary)
        surface.PlaySound("buttons/button9.wav")
    end

    Ipr_PLanguage:SetSize(80, 20)
    Ipr_PLanguage:SetPos(5, 37)
    Ipr_PLanguage:SetFont(Ipr.Settings.Font)
    Ipr_PLanguage:SetValue(Ipr.Settings.SetLang)
    Ipr_PLanguage:SetTextColor(Ipr.Settings.TColor["blanc"])
    
    for k, v in pairs(Ipr_Fps_Booster.Lang) do
        Ipr_PLanguage:AddChoice(Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].SelectLangue.. " " ..k, k, false, "materials/flags16/" ..v.Icon)
    end

    Ipr_PLanguage:SetImage("materials/flags16/" ..Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].Icon)
    Ipr_PLanguage:SetText("")

    Ipr_PLanguage.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Ipr.Settings.TColor["bleuc"] or Ipr.Settings.TColor["bleu"])

        surface.SetFont(Ipr.Settings.Font)
        local Ipr_TLang = "| " ..Ipr.Settings.SetLang.. " |"
        local Ipr_PTWide = surface.GetTextSize(Ipr_TLang)

        draw.SimpleText(Ipr_TLang, Ipr.Settings.Font, w / 2 - Ipr_PTWide / 2 + 2, 1, Ipr.Settings.TColor["blanc"], TEXT_ALIGN_LEFT)
    end

    Ipr_PLanguage.OnMenuOpened = function(self)
        local Ipr_PLanguageChild = self:GetChildren()

        for _, v in ipairs(Ipr_PLanguageChild) do
            if (v:GetName() == "DMenu") then
                v.Paint = function(p, w, h)
                   draw.RoundedBox(6, 0, 0, w, h, Ipr.Settings.TColor["bleu"])
                end
                
                local Ipr_PLanguageDMenu = v:GetChildren()
                for _, d in ipairs(Ipr_PLanguageDMenu) do

                    if (d:GetName() == "Panel") then
                        local Ipr_PLanguagePanel = d:GetChildren()
                        for _, y in ipairs(Ipr_PLanguagePanel) do
                            local Ipr_GetVal = y:GetValue()
                            Ipr_GetVal = string.find(Ipr_GetVal, Ipr.Settings.SetLang)
           
                            y:SetTextColor(Ipr_GetVal and Ipr.Settings.TColor["vert"] or Ipr.Settings.TColor["blanc"])
                            y:SetFont(Ipr.Settings.Font)
                        end
                    end
                end
            end
        end

        Ipr.Func.OverridePaint(self)
    end
    Ipr_PLanguage.OnSelect = function(self, index, value)
        local Ipr_SetLang = self.Data[index]

        self:Clear()
        self:SetValue(Ipr_SetLang)
        
        for k, v in pairs(Ipr_Fps_Booster.Lang) do
            self:AddChoice(Ipr_Fps_Booster.Lang[Ipr_SetLang].SelectLangue.. " " ..k, k, false, "materials/flags16/" ..v.Icon)
        end

        self:SetImage("materials/flags16/" ..Ipr_Fps_Booster.Lang[Ipr_SetLang].Icon)
        self:SetText("")

        if (Ipr_SetLang ~= Ipr.Settings.SetLang) then
            file.Write(Ipr_Fps_Booster.Settings.Save.. "language.json", Ipr_SetLang)

            Ipr.Settings.SetLang = Ipr_SetLang
            surface.PlaySound("buttons/button9.wav")
        end
    end
    Ipr.Func.OverridePaint(Ipr_PLanguage)
end

local Ipr_DefaultCommands = {
    ["/boost"] = {
        Func = function()
            Ipr.Func.CreateData()
            Ipr_FpsBooster()

            return true
        end
    },
    ["/reset"] = {
        Func = function()
            Ipr.Func.Activate(false)
            Ipr.Func.ResetFps()

            chat.AddText(Ipr.Settings.TColor["rouge"], "[", "Improved FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].SReset)
            surface.PlaySound("buttons/combine_button5.wav")

            return true
        end
    },
}

local function Ipr_ChatCmds(ply, text)
    if (ply == LocalPlayer()) then
        text = string.lower(text)

        if (Ipr_DefaultCommands[text]) then
            Ipr_DefaultCommands[text].Func()
        end
    end
end

local function Ipr_InitPostPlayer()
    timer.Simple(5, function()
        Ipr.Func.CreateData()

        local Ipr_DebugEnable = Ipr.Func.GetConvar("EnableDebug")
        if (Ipr_DebugEnable) then
            Ipr.Settings.Debug = true
        end

        local Ipr_Startup = Ipr.Func.GetConvar("Startup")
        if (Ipr_Startup) then
            Ipr.Func.Activate(true)
            chat.AddText(Ipr.Settings.TColor["rouge"], "[", "Improved FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].StartupEnabled)
        end

        local Ipr_ForcedOpen = Ipr.Func.GetConvar("ForcedOpen")
        if not IsValid(Ipr.Settings.Vgui.Primary) then
            if (Ipr_ForcedOpen) then
                Ipr_FpsBooster()
            else
                chat.AddText(Ipr.Settings.TColor["rouge"], "[", "Improved FPS Booster", "] : ", Ipr.Settings.TColor["blanc"], Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].CForcedOpen)
            end
        end

        local Ipr_HudEnable = Ipr.Func.GetConvar("FpsView")
        if (Ipr_HudEnable) then
            hook.Add("PostDrawHUD", "IprFpsBooster_HUD", Ipr.Func.FpsHud)
        end

        local Ipr_EnabledFog = Ipr.Func.GetConvar("EnabledFog")
        if (Ipr_EnabledFog) then
            Ipr.Func.FogActivate(true)
        end
    end)
end

local function Ipr_PlayerShutDown()
    local Ipr_ServerLeave = Ipr.Func.GetConvar("ServerLeaveConvars")
    if (Ipr_ServerLeave) then
        Ipr.Func.Activate(false)
    end

    local Ipr_StartupDelay = timer.Exists(Ipr.Settings.StartupLaunch.Name)
    if (Ipr_StartupDelay) then
        MsgC(Ipr.Settings.TColor["orange"], "[Improved FPS Booster] : " ..Ipr_Fps_Booster.Lang[Ipr.Settings.SetLang].StartupAbandoned.. "\n")
    end
end

local function Ipr_OnScreenSize()
    Ipr_Wide, Ipr_Height = ScrW(), ScrH()
end

hook.Add("ShutDown", "IprFpsBooster_ShutDown", Ipr_PlayerShutDown)
hook.Add("OnScreenSizeChanged", "IprFpsBooster_OnScreen", Ipr_OnScreenSize)
hook.Add("InitPostEntity", "IprFpsBooster_InitPlayer", Ipr_InitPostPlayer)
hook.Add("OnPlayerChat", "IprFpsBooster_ChatCmds", Ipr_ChatCmds)
