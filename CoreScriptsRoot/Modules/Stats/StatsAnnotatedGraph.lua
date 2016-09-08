--[[
		Filename: StatsAnnotatedGraph.lua
		Written by: dbanks
		Description: A graph plus extra annotations like axis markings, 
      target lines, etc.
--]]

--[[ Services ]]--
local CoreGuiService = game:GetService('CoreGui')

--[[ Globals ]]--
local Margin = 10
local LabelXWidth = 30

--[[ Modules ]]--
local StatsUtils = require(CoreGuiService.RobloxGui.Modules.Stats.StatsUtils)
local BarGraphClass = require(CoreGuiService.RobloxGui.Modules.Stats.BarGraph)

--[[ Classes ]]--
local StatsAnnotatedGraphClass = {}
StatsAnnotatedGraphClass.__index = StatsAnnotatedGraphClass

function StatsAnnotatedGraphClass.new(isMaximized) 
  local self = {}
  setmetatable(self, StatsAnnotatedGraphClass)

  self._isMaximized = isMaximized

  self._frame = Instance.new("Frame")
  self._frame.Name = "PS_AnnotatedGraph"
  self._frame.BackgroundTransparency = 1.0
  
  self._topLabel = Instance.new("TextLabel")
  self._topLabel.Name = "PS_TopAxisLabel"
  StatsUtils.StyleTextWidget(self._topLabel)
  self._topLabel.Parent = self._frame
  self._topLabel.TextXAlignment = Enum.TextXAlignment.Left
  self._topLabel.TextYAlignment = Enum.TextYAlignment.Top
  
  self._midLabel = Instance.new("TextLabel")
  self._midLabel.Name = "PS_MidAxisLabel"
  StatsUtils.StyleTextWidget(self._midLabel)
  self._midLabel.Parent = self._frame
  self._midLabel.TextXAlignment = Enum.TextXAlignment.Left
  self._midLabel.TextYAlignment = Enum.TextYAlignment.Center
  
  self._bottomLabel = Instance.new("TextLabel")
  self._bottomLabel.Name = "PS_BottomAxisLabel"
  StatsUtils.StyleTextWidget(self._bottomLabel)
  self._bottomLabel.Parent = self._frame
  self._bottomLabel.TextXAlignment = Enum.TextXAlignment.Left
  self._bottomLabel.TextYAlignment = Enum.TextYAlignment.Bottom

  
  self._graph = BarGraphClass.new()

  self:_layoutElements()

  return self
end


function StatsAnnotatedGraphClass:_layoutElements()
  local labelWidth
  if (self._isMaximized) then
    labelWidth = LabelXWidth
    
    self._topLabel.Visible = true
    self._midLabel.Visible = true
    self._bottomLabel.Visible = true
  else
    labelWidth = 0
    
    self._topLabel.Visible = false
    self._midLabel.Visible = false
    self._bottomLabel.Visible = false
  end
  
  local GraphFramePosition = UDim2.new(0, Margin, 0, Margin)
  local GraphFrameSize = UDim2.new(1, -(2 * Margin + labelWidth), 1, -2 * Margin)

  local TopLabelFramePosition = UDim2.new(1, -(Margin + labelWidth), 0, Margin)
  local TopLabelFrameSize = UDim2.new(0, labelWidth, 0.333, -2 * Margin)
  local MidLabelFramePosition = UDim2.new(1, -(Margin + labelWidth), 0.333, Margin)
  local MidLabelFrameSize = UDim2.new(0, labelWidth, 0.333, -2 * Margin)
  local BottomLabelFramePosition = UDim2.new(1, -(Margin + labelWidth), 0.666, Margin)
  local BottomLabelFrameSize = UDim2.new(0, labelWidth, 0.333, -2 * Margin)
  
  self._topLabel.Size = TopLabelFrameSize
  self._topLabel.Position = TopLabelFramePosition
  self._midLabel.Size = MidLabelFrameSize
  self._midLabel.Position = MidLabelFramePosition
  self._bottomLabel.Size = BottomLabelFrameSize
  self._bottomLabel.Position = BottomLabelFramePosition
  
  self._graph:PlaceInParent(self._frame, GraphFrameSize, GraphFramePosition)
end

function StatsAnnotatedGraphClass:PlaceInParent(parent, size, position) 
  self._frame.Position = position
  self._frame.Size = size
  self._frame.Parent = parent
end

function StatsAnnotatedGraphClass:SetValues(values)
  local axisMax = self:_calculateAxisMax(values)
  self._graph:Render(values, axisMax)
  
  -- FIXME(dbanks)
  -- Format based on stat type.
  self._topLabel.Text = string.format("%.4f", axisMax)
  self._midLabel.Text = string.format("%.4f", axisMax/2)
  self._bottomLabel.Text = string.format("%.4f", 0,.0)
end

function StatsAnnotatedGraphClass:_calculateAxisMax(values)
  -- Calculate an optimal axis label for this set of values.
  -- We want a final value 'axisMax' s.t. the largest value 'max' in 'values' is
  -- such that:
  -- 0.1 * axisMax <= max < axisMax 
  local max = 0.0
  for i, value in ipairs(values) do
    if value > max then 
      max = value
    end
  end
  
  return self:_recursiveGetAxisMax(1, max)
end

function StatsAnnotatedGraphClass:SetStatsAggregator(aggregator)
  if (self._aggregator) then
    self._aggregator:RemoveListener(self._listenerId)
    self._listenerId = nil
    self._aggregator = nil
  end
  
  self._aggregator = aggregator
  
  if (self._aggregator ~= nil) then
    self._listenerId = aggregator:AddListener(function()
        self:_updateValue()
    end)
  end
  
  self:_updateValue()
end

function StatsAnnotatedGraphClass:_recursiveGetAxisMax(axisMax, max)
  local axisMin = 0.1 * axisMax
  
  if (max < axisMin) then 
    return self:_recursiveGetAxisMax(axisMin, max)
  elseif (max >= axisMax) then 
    return self:_recursiveGetAxisMax(10 * axisMax, max)
  else
    return axisMax
  end
end

function StatsAnnotatedGraphClass:_updateValue()
  local values = {}
  if self._aggregator ~= nil then 
    values = self._aggregator:GetValues()
  else
    values = {}
  end
  
  self:SetValues(values)
end

return StatsAnnotatedGraphClass
