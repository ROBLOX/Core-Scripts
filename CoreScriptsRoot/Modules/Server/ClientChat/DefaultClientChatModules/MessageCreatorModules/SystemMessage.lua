--	// FileName: SystemMessage.lua
--	// Written by: TheGamer101
--	// Description: Create a message label for a system message.

local MESSAGE_TYPE = "SystemMessage"

local clientChatModules = script.Parent.Parent
local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
local util = require(script.Parent:WaitForChild("Util"))

function CreateSystemMessageLabel(messageData)
	local message = messageData.Message
	local extraData = messageData.ExtraData or {}
	local useFont = extraData.Font or Enum.Font.SourceSansBold
	local useFontSize = extraData.FontSize or ChatSettings.ChatWindowTextSize
	local useChatColor = extraData.ChatColor or Color3.new(1, 1, 1)

	local BaseFrame, BaseMessage = util:CreateBaseMessage(message, useFont, useFontSize, useChatColor)

	return {
    [util.KEY_BASE_FRAME] = BaseFrame,
    [util.KEY_BASE_MESSAGE] = BaseMessage,
    [util.KEY_UPDATE_TEXT_FUNC] = nil
  }
end

return {
	[util.KEY_MESSAGE_TYPE] = MESSAGE_TYPE,
	[util.KEY_CREATOR_FUNCTION] = CreateSystemMessageLabel
}
