--[[
		Filename: StatsMiniTextPanel.lua
		Written by: dbanks
		Description: Panel that shows title and current value for a given stat.
--]]

--[[ Globals ]]--
local TitleHeightYFraction = 0.4
local ValueHeightYFraction = 0.3
local TitleTopYFraction = (1 - TitleHeightYFraction - 
  ValueHeightYFraction)/2
local LeftMarginPix = 10

local TitlePosition = UDim2.new(0, 
  LeftMarginPix, 
  TitleTopYFraction, 
  0)
local TitleSize = UDim2.new(1, 
  -LeftMarginPix * 2, 
  TitleHeightYFraction, 
  0)
local ValuePosition = UDim2.new(0,
  LeftMarginPix, 
  TitleTopYFraction + TitleHeightYFraction, 
  0)
local ValueSize = UDim2.new(1, 
  -LeftMarginPix * 2,
  ValueHeightYFraction, 
  0)

--[[ Services ]]--
local CoreGuiService = game:GetService('CoreGui')

--[[ Modules ]]--
local StatsUtils = require(CoreGuiService.RobloxGui.Modules.Stats.StatsUtils)
local StatsAggregatorClass = require(CoreGuiService.RobloxGui.Modules.Stats.StatsAggregator)

--[[ Classes ]]--
local StatsMiniTextPanelClass = {}
StatsMiniTextPanelClass.__index = StatsMiniTextPanelClass

function StatsMiniTextPanelClass.new(statType) 
  local self = {}
  setmetatable(self, StatsMiniTextPanelClass)

  self._statType = statType
  
  self._frame = Instance.new("Frame")
  self._frame.Name = "StatsMiniTextPanelClass"
  
  self._frame.BackgroundTransparency = 1.0
  self._frame.ZIndex = StatsUtils.TextPanelZIndex
  
  self._titleLabel = Instance.new("TextLabel")
  self._valueLabel = Instance.new("TextLabel")

  StatsUtils.StyleTextWidget(self._titleLabel)
  StatsUtils.StyleTextWidget(self._valueLabel)
  
  self._titleLabel.FontSize = StatsUtils.MiniPanelTitleFontSize
  self._titleLabel.Text = self:_getTitle()
  self._titleLabel.Parent = self._frame
  self._titleLabel.Size = TitleSize
  self._titleLabel.Position = TitlePosition
  self._titleLabel.TextXAlignment = Enum.TextXAlignment.Left
  
  self._valueLabel.FontSize = StatsUtils.MiniPanelValueFontSize
  self._valueLabel.Text = "0"
  self._valueLabel.Parent = self._frame
  self._valueLabel.Size = ValueSize
  self._valueLabel.Position = ValuePosition
  self._valueLabel.TextXAlignment = Enum.TextXAlignment.Left
  
  return self
end

function StatsMiniTextPanelClass:SetZIndex(zIndex)
  self._frame.ZIndex = zIndex
  self._titleLabel.ZIndex = zIndex
  self.ZIndex = zIndex
end

function StatsMiniTextPanelClass:_getTitle()
  return StatsUtils.TypeToShortName[self._statType]
end

function StatsMiniTextPanelClass:PlaceInParent(parent, size, position) 
  self._frame.Position = position
  self._frame.Size = size
  self._frame.Parent = parent  
end

function StatsMiniTextPanelClass:SetStatsAggregator(aggregator)
  if (self._aggregator) then
    self._aggregator:RemoveListener(self._listenerId)
    self._listenerId = nil
    self._aggregator = nil
  end
  
  self._aggregator = aggregator
  
  if (self._aggregator ~= nil) then
    self._listenerId = aggregator:AddListener(function()
        self:_updateFromAggregator()
    end)
  end
  
  self:_updateFromAggregator()
end

function StatsMiniTextPanelClass:_updateFromAggregator()
  local value
  if self._aggregator ~= nil then 
    value = self._aggregator:GetLatestValue()
  else
    value = 0
  end
  
  self._valueLabel.Text = StatsUtils.FormatTypedValue(value, self._statType)
end

return StatsMiniTextPanelClass