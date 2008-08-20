

local questtags, tags = {}, {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P", Daily = "\226\128\162"}
--¤®° \194\164 \194\174 \194\176


local function GetTaggedTitle(i)
	local name, level, tag, group, header, _, _, daily = GetQuestLogTitle(i)
	if header or not name then return end

	if not group or group == 0 then group = nil end
	return string.format("[%s%s%s] %s", level, tag and tags[tag] or daily and tags.Daily or "", group or "", name)
end


-- Add tags to the quest log
hooksecurefunc("QuestLog_Update", function()
	local offset, numEntries, numQuests = FauxScrollFrame_GetOffset(QuestLogListScrollFrame), GetNumQuestLogEntries()

	for i=1,QUESTS_DISPLAYED do
		local qi = i + offset
		local questLogTitle, questTitleTag, questNormalText, questCheck = _G["QuestLogTitle"..i], _G["QuestLogTitle"..i.."Tag"], _G["QuestLogTitle"..i.."NormalText"], _G["QuestLogTitle"..i.."Check"]

		if qi <= numEntries then
			local _, _, tag, _, _, _, complete, daily = GetQuestLogTitle(qi)

			local title = GetTaggedTitle(qi)
			if title then
				questLogTitle:SetText("  "..title)
				QuestLogDummyText:SetText("  "..title)
			end

			if tag or complete and complete ~= 0 or daily then
				if not complete then questTitleTag:SetText("") end
				local tempWidth = 275 - 15 - questTitleTag:GetWidth()
				local textWidth = math.min(QuestLogDummyText:GetWidth(), tempWidth)
				questNormalText:SetWidth(tempWidth)
				if IsQuestWatched(qi) then questCheck:SetPoint("LEFT", questLogTitle, "LEFT", textWidth + ((questNormalText:GetWidth() + 24) < 275 and 24 or 10), 0) end
			end
		end
	end
end)


-- Add tags to the quest watcher
hooksecurefunc("QuestWatch_Update", function()
	local questWatchMaxWidth, watchTextIndex = 0, 1

	for i=1,GetNumQuestWatches() do
		local qi = GetQuestIndexForWatch(i)
		if qi then
			local numObjectives = GetNumQuestLeaderBoards(qi)

			if numObjectives > 0 then
				local text = _G["QuestWatchLine"..watchTextIndex]
				text:SetText(GetTaggedTitle(qi))
				local tempWidth = text:GetWidth()
				questWatchMaxWidth = math.max(tempWidth, questWatchMaxWidth)
				watchTextIndex = watchTextIndex + numObjectives + 1
			end
		end
	end

	if watchTextIndex ~= 1 and QuestWatchFrame:GetWidth() < (questWatchMaxWidth + 10) then QuestWatchFrame:SetWidth(questWatchMaxWidth + 10) end
end)


-- Add tags to quest links in chat
local function filter(msg) if msg then return false, msg:gsub("(|c%x+|Hquest:%d+:(%d+))", "(%2) %1") end end
for _,event in pairs{"SAY", "GUILD", "GUILD_OFFICER", "WHISPER", "PARTY", "RAID", "RAID_LEADER", "BATTLEGROUND", "BATTLEGROUND_LEADER"} do ChatFrame_AddMessageEventFilter("CHAT_MSG_"..event, filter) end


-- Add tags to gossip frame
local i
local TRIVIAL, NORMAL = "|cff%02x%02x%02x[%d]|r "..TRIVIAL_QUEST_DISPLAY, "|cff%02x%02x%02x[%d]|r ".. NORMAL_QUEST_DISPLAY
local function helper(step, ...)
	local num = select('#', ...)
	if num == 0 then return end

	for j=1,num,step do
		local title, level, isTrivial = select(j, ...)
		local color = GetDifficultyColor(level)
		_G["GossipTitleButton"..i]:SetFormattedText(step == 3 and isTrivial and TRIVIAL or NORMAL, color.r*255, color.g*255, color.b*255, level, title)
		i = i + 1
	end
	i = i + 1
end

hooksecurefunc("GossipFrameUpdate", function()
	i = 1
	helper(3, GetGossipAvailableQuests())
	helper(2, GetGossipActiveQuests())
end)
