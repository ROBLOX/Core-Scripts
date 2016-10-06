--	// FileName: ChannelEchoSystemMessage.lua
--	// Written by: TheGamer101
--	// Description: Create a message label for a system message being echoed into another channel.

local MESSAGE_TYPE = "ChannelEchoSystemMessage"

local clientChatModules = script.Parent.Parent
local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
local util = require(script.Parent:WaitForChild("Util"))

function CreateChannelEchoSystemMessageLabel(messageData)
	local message = messageData.Message
	local echoChannel = messageData.OriginalChannel

	local extraData = messageData.ExtraData or {}
	local useFont = extraData.Font or Enum.Font.SourceSansBold
	local useFontSize = extraData.FontSize or ChatSettings.ChatWindowTextSize
	local useChatColor = extraData.ChatColor or Color3.new(1, 1, 1)

	local formatChannelName = string.format("{%s}", echoChannel)
	local numNeededSpaces2 = util:GetNumberOfSpaces(formatChannelName, useFont, useFontSize) + 1
	local modifiedMessage = string.rep(" ", numNeededSpaces2) .. message

	local BaseFrame, BaseMessage = util:CreateBaseMessage(modifiedMessage, useFont, useFontSize, useChatColor)
	local ChannelButton = util:AddChannelButtonToBaseMessage(BaseMessage, formatChannelName, BaseMessage.TextColor3)

	local AnimParams = {}
	AnimParams.Text_TargetTransparency = 0
	AnimParams.Text_CurrentTransparency = 0
	AnimParams.TextStroke_TargetTransparency = 0.75
	AnimParams.TextStroke_CurrentTransparency = 0.75

	local function FadeInFunction(duration)
		AnimParams.Text_TargetTransparency = 0
		AnimParams.TextStroke_TargetTransparency = 0.75
	end

	local function FadeOutFunction(duration)
		AnimParams.Text_TargetTransparency = 1
		AnimParams.TextStroke_TargetTransparency = 1
	end

	local function AnimGuiObjects()
		BaseMessage.TextTransparency = AnimParams.Text_CurrentTransparency
		ChannelButton.TextTransparency = AnimParams.Text_CurrentTransparency

		BaseMessage.TextStrokeTransparency = AnimParams.TextStroke_CurrentTransparency
		ChannelButton.TextStrokeTransparency = AnimParams.TextStroke_CurrentTransparency
	end

	local function UpdateAnimFunction(dtScale, CurveUtil)
		AnimParams.Text_CurrentTransparency = CurveUtil:Expt(AnimParams.Text_CurrentTransparency, AnimParams.Text_TargetTransparency, 0.1, dtScale)
		AnimParams.TextStroke_CurrentTransparency = CurveUtil:Expt(AnimParams.TextStroke_CurrentTransparency, AnimParams.TextStroke_TargetTransparency, 0.1, dtScale)

		AnimGuiObjects()
	end

	return {
		[util.KEY_BASE_FRAME] = BaseFrame,
		[util.KEY_BASE_MESSAGE] = BaseMessage,
		[util.KEY_UPDATE_TEXT_FUNC] = nil,
		[util.KEY_FADE_IN] = FadeInFunction,
		[util.KEY_FADE_OUT] = FadeOutFunction,
		[util.KEY_UPDATE_ANIMATION] = UpdateAnimFunction
	}
end

return {
	[util.KEY_MESSAGE_TYPE] = MESSAGE_TYPE,
	[util.KEY_CREATOR_FUNCTION] = CreateChannelEchoSystemMessageLabel
}
