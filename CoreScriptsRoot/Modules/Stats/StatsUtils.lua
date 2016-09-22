--[[
		Filename: StatsUtils.lua
		Written by: dbanks
		Description: Common work in the performance stats world.
--]]

--[[ Services ]]--
local CoreGuiService = game:GetService('CoreGui')


--[[ Modules ]]--
local TopbarConstants = require(CoreGuiService.RobloxGui.Modules.TopbarConstants)
local StyleWidgets = require(CoreGuiService.RobloxGui.Modules.StyleWidgets)

--[[ Classes ]]--
local StatsUtils = {}

-- Colors
StatsUtils.SelectedBackgroundColor = Color3.new(0.4, 0.4, 0.4)
StatsUtils.FontColor = Color3.new(1, 1, 1)
StatsUtils.GraphBarGreenColor = Color3.new(126/255.0, 211/255.0, 33/255.0)
StatsUtils.GraphBarYellowColor = Color3.new(209/255.0, 211/255.0, 33/255.0)
StatsUtils.GraphBarRedColor = Color3.new(211/255.0, 88/255.0, 33/255.0)
StatsUtils.GraphAverageLineColor = Color3.new(208/255.0, 1/255.0, 27/255.0)
StatsUtils.GraphAverageLineBorderColor = Color3.new(1, 1, 1)
StatsUtils.NormalColor = TopbarConstants.TOPBAR_BACKGROUND_COLOR
StatsUtils.Transparency = TopbarConstants.TOPBAR_TRANSLUCENT_TRANSPARENCY;

-- Font Sizes
StatsUtils.MiniPanelTitleFontSize = Enum.FontSize.Size12
StatsUtils.MiniPanelValueFontSize = Enum.FontSize.Size10
StatsUtils.PanelTitleFontSize = Enum.FontSize.Size24
StatsUtils.PanelValueFontSize = Enum.FontSize.Size14
StatsUtils.PanelGraphFontSize = Enum.FontSize.Size10

-- Layout
-- Layout: Buttons
StatsUtils.ButtonHeight = 36 + StyleWidgets.TabSelectionHeight

-- Layout: Viewer
StatsUtils.ViewerTopMargin = 10
StatsUtils.ViewerHeight = 144
StatsUtils.ViewerWidth = 306

StatsUtils.TextZIndex =  5
StatsUtils.GraphZIndex = 2

-- Layout: Graph
StatsUtils.GraphTargetLineInnerThickness = 2
StatsUtils.GraphAverageLineInnerThickness = 2
StatsUtils.GraphAverageLineBorderThickness = 1
StatsUtils.GraphAverageLineTotalThickness = (StatsUtils.GraphAverageLineInnerThickness + 
  2 * StatsUtils.GraphAverageLineBorderThickness)
      
-- Layout: Main Text Panel
StatsUtils.TextPanelTitleHeightY = 52
StatsUtils.TextPanelLegendItemHeightY = 20

StatsUtils.TextPanelLeftMarginPix = 10
StatsUtils.TextPanelTopMarginPix = 10

-- Layout: Graph Legend
StatsUtils.DecorationSize = 12
StatsUtils.OvalKeySize = 8
StatsUtils.TargetKeyWidth = 11
StatsUtils.TargetKeyHeight = 2
StatsUtils.DecorationMargin = 6


-- Enums
StatsUtils.StatType_Memory =            "st_Memory"
StatsUtils.StatType_CPU =               "st_CPU"
StatsUtils.StatType_GPU =               "st_GPU"
StatsUtils.StatType_NetworkSent =       "st_NetworkSent"
StatsUtils.StatType_NetworkReceived =   "st_NetworkReceived"
StatsUtils.StatType_Physics =           "st_Physics"
      
StatsUtils.AllStatTypes = {
  StatsUtils.StatType_Memory,
  StatsUtils.StatType_CPU,
  StatsUtils.StatType_GPU,
  StatsUtils.StatType_NetworkSent,
  StatsUtils.StatType_NetworkReceived,
  StatsUtils.StatType_Physics,
}

StatsUtils.StatNames = {
  [StatsUtils.StatType_Memory] = "Memory",
  [StatsUtils.StatType_CPU] = "CPU",
  [StatsUtils.StatType_GPU] = "GPU",
  [StatsUtils.StatType_NetworkSent] = "NetworkSent",
  [StatsUtils.StatType_NetworkReceived] = "NetworkReceived",
  [StatsUtils.StatType_Physics] = "Physics",
}

StatsUtils.StatMaxNames = {
  [StatsUtils.StatType_Memory] = "MaxMemory",
  [StatsUtils.StatType_CPU] = "MaxCPU",
  [StatsUtils.StatType_GPU] = "MaxGPU",
  [StatsUtils.StatType_NetworkSent] = "MaxNetworkSent",
  [StatsUtils.StatType_NetworkReceived] = "MaxNetworkReceived",
  [StatsUtils.StatType_Physics] = "MaxPhysics",
}

StatsUtils.NumButtonTypes = table.getn(StatsUtils.AllStatTypes)

StatsUtils.TypeToName = {
  [StatsUtils.StatType_Memory] = "Memory",
  [StatsUtils.StatType_CPU] = "CPU",
  [StatsUtils.StatType_GPU] = "GPU",
  [StatsUtils.StatType_NetworkSent] = "Sent\n(Network)",
  [StatsUtils.StatType_NetworkReceived] = "Received\n(Network)",
  [StatsUtils.StatType_Physics] = "Physics",
}

StatsUtils.TypeToShortName = {
  [StatsUtils.StatType_Memory] = "Mem",
  [StatsUtils.StatType_CPU] = "CPU",
  [StatsUtils.StatType_GPU] = "GPU",
  [StatsUtils.StatType_NetworkSent] = "Sent",
  [StatsUtils.StatType_NetworkReceived] = "Recv",
  [StatsUtils.StatType_Physics] = "Phys",
}

function StatsUtils.StyleFrame(frame)
  frame.BackgroundColor3 = StatsUtils.NormalColor
  frame.BackgroundTransparency = StatsUtils.Transparency
end

function StatsUtils.StyleButton(button)
  button.BackgroundColor3 = StatsUtils.NormalColor
  button.BackgroundTransparency = StatsUtils.Transparency
end

function StatsUtils.StyleTextWidget(textLabel)
  textLabel.BackgroundTransparency = 1.0
  textLabel.TextColor3 = StatsUtils.FontColor
  textLabel.Font = Enum.Font.SourceSansBold
end

function StatsUtils.StyleButtonSelected(frame, isSelected)
  StatsUtils.StyleButton(frame)
  if (isSelected) then 
    frame.BackgroundColor3 = StatsUtils.SelectedBackgroundColor
  end
end

function StatsUtils.FormatTypedValue(value, statType)   
  if statType == StatsUtils.StatType_Memory then 
    return string.format("%.2f MB", value)
  elseif statType == StatsUtils.StatType_CPU then
    return string.format("%.2f ms", value)
  elseif statType == StatsUtils.StatType_GPU then
    return string.format("%.2f ms", value)
  elseif statType == StatsUtils.StatType_NetworkSent then
    return string.format("%.2f KB/s", value)
  elseif statType == StatsUtils.StatType_NetworkReceived then
    return string.format("%.2f KB/s", value)
  elseif statType == StatsUtils.StatType_Physics then
    return string.format("%.2f ms", value)
  end
end

function StatsUtils.StyleAverageLine(frame)
  frame.BackgroundColor3 = StatsUtils.GraphAverageLineColor
  frame.BorderSizePixel = StatsUtils.GraphAverageLineBorderThickness
  frame.BorderColor3 = StatsUtils.GraphAverageLineBorderColor
end
  
function StatsUtils.GetColorForValue(value, target) 
  if value < 0.666 * target then 
    return StatsUtils.GraphBarGreenColor
  elseif value < 1.333 * target then 
    return StatsUtils.GraphBarYellowColor
  else
    return StatsUtils.GraphBarRedColor
  end
end
  
return StatsUtils