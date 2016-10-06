--	// FileName: MessageLabelCreator.lua
--	// Written by: Xsitsu
--	// Description: Module to handle taking text and creating stylized GUI objects for display in ChatWindow.

local OBJECT_POOL_SIZE = 50

local module = {}
--////////////////////////////// Include
--//////////////////////////////////////
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local clientChatModules = ReplicatedStorage:WaitForChild("ClientChatModules")
local messageCreatorModules = clientChatModules:WaitForChild("MessageCreatorModules")
local messageCreatorUtil = require(messageCreatorModules:WaitForChild("Util"))
local modulesFolder = script.Parent
local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
local moduleObjectPool = require(modulesFolder:WaitForChild("ObjectPool"))
local ClassMaker = require(modulesFolder:WaitForChild("ClassMaker"))
local MessageSender = require(modulesFolder:WaitForChild("MessageSender"))

--////////////////////////////// Methods
--//////////////////////////////////////
local methods = {}

function ReturnToObjectPoolRecursive(instance, objectPool)
	local children = instance:GetChildren()
	for i = 1, #children do
		ReturnToObjectPoolRecursive(children[i], objectPool)
	end
	instance.Parent = nil
	objectPool:ReturnInstance(instance)
end

function GetMessageCreators()
	local typeToFunction = {}
	local creators = messageCreatorModules:GetChildren()
	for i = 1, #creators do
		if creators[i].Name ~= "Util" then
			local creator = require(creators[i])
			typeToFunction[creator[messageCreatorUtil.KEY_MESSAGE_TYPE]] = creator[messageCreatorUtil.KEY_CREATOR_FUNCTION]
		end
	end
	return typeToFunction
end

function methods:WrapIntoMessageObject(messageData, createdMessageObject)
	local BaseFrame = createdMessageObject[messageCreatorUtil.KEY_BASE_FRAME]
	local BaseMessage = createdMessageObject[messageCreatorUtil.KEY_BASE_MESSAGE]
	local UpdateTextFunction = createdMessageObject[messageCreatorUtil.KEY_UPDATE_TEXT_FUNC]
	local FadeInFunction = createdMessageObject[messageCreatorUtil.KEY_FADE_IN]
	local FadeOutFunction = createdMessageObject[messageCreatorUtil.KEY_FADE_OUT]
	local UpdateAnimFunction = createdMessageObject[messageCreatorUtil.KEY_UPDATE_ANIMATION]
	if UpdateAnimFunction == nil then
		print("No update anim function")
	end

	local obj = {}

	obj.ID = id
	obj.BaseFrame = BaseFrame
	obj.BaseMessage = BaseMessage
	obj.UpdateTextFunction = UpdateTextFunction or function() warn("NO MESSAGE RESIZE FUNCTION") end
	obj.FadeInFunction = FadeInFunction
	obj.FadeOutFunction = FadeOutFunction
	obj.UpdateAnimFunction = UpdateAnimFunction
	obj.ObjectPool = self.ObjectPool
	obj.Destroyed = false

	function obj:Destroy()
		ReturnToObjectPoolRecursive(self.BaseFrame, self.ObjectPool)
		self.Destroyed = true
	end

	return obj
end

function methods:CreateMessageLabelFromType(messageData, messageType)
	local message = messageData.Message
	if messageType == "Message" then
		if string.sub(message, 1, 4) == "/me " then
			messageType = "MeCommandMessage"
		end
	elseif messageType == "EchoMessage" then
		if string.sub(message, 1, 4) == "/me " then
			messageType = "MeCommandChannelEchoMessage"
		end
	end
	if self.MessageCreators[messageType] then
		local createdMessageObject = self.MessageCreators[messageType](messageData)
		if createdMessageObject then
			return self:WrapIntoMessageObject(messageData, createdMessageObject)
		end
	elseif self.DefaultCreatorType then
		local createdMessageObject = self.MessageCreators[self.DefaultCreatorType](messageData)
		if createdMessageObject then
			return self:WrapIntoMessageObject(messageData, createdMessageObject)
		end
	else
		error("No message creator available for message type: " ..messageType)
	end
end

--///////////////////////// Constructors
--//////////////////////////////////////
ClassMaker.RegisterClassType("MessageLabelCreator", methods)

function module.new()
	local obj = {}

	obj.ObjectPool = moduleObjectPool.new(OBJECT_POOL_SIZE)
	obj.MessageCreators = GetMessageCreators()
	obj.DefaultCreatorType = messageCreatorUtil.DEFAULT_MESSAGE_CREATOR

	ClassMaker.MakeClass("MessageLabelCreator", obj)

	messageCreatorUtil:RegisterObjectPool(obj.ObjectPool)

	return obj
end

function module:RegisterGuiRoot(root)
	messageCreatorUtil:RegisterGuiRoot(root)
end

function module:GetStringTextBounds(text, font, fontSize, sizeBounds)
	return messageCreatorUtil:GetStringTextBounds(text, font, fontSize, sizeBounds)
end

return module
