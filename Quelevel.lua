

local questtags, tags = {}, {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P"}


local function GetTaggedTitle(i)
	local name, level, tag, group, header = GetQuestLogTitle(i)
	if header or not name then return end

	if not group or group == 0 then group = nil end
	return string.format("[%s%s%s] %s", level, tag and tags[tag] or "", group or "", name)
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

