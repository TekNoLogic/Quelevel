

local questtags, tags = {}, {
	Elite      = "+",
	Group      = "G",
	Dungeon    = "D",
	Raid       = "R",
	PvP        = "P",
	Daily      = "•",
	Heroic     = "H",
	Repeatable = "∞",
}


local function GetTaggedTitle(i)
	local name, level, tag, group, header, _, complete, daily = GetQuestLogTitle(i)
	if header or not name then return end

	if not group or group == 0 then group = nil end
	local title = string.format("[%s%s%s%s] %s", level, tag and tags[tag] or "",
		                          daily and tags.Daily or "",group or "", name)
	return title, tag, daily, complete
end


-- Add tags to the quest log
local function QuestLog_Update()
	for i,butt in pairs(QuestLogScrollFrame.buttons) do
		local qi = butt:GetID()
		local title, tag, daily, complete = GetTaggedTitle(qi)
		if title then butt:SetText("  "..title) end
		if (tag or daily) and not complete then butt.tag:SetText("") end
		QuestLogTitleButton_Resize(butt)
	end
end
hooksecurefunc("QuestLog_Update", QuestLog_Update)
hooksecurefunc(QuestLogScrollFrame, "update", QuestLog_Update)


-- Add tags to the quest watcher
hooksecurefunc("WatchFrame_Update", function()
	local questWatchMaxWidth, watchTextIndex = 0, 1

	for i=1,GetNumQuestWatches() do
		local qi = GetQuestIndexForWatch(i)
		if qi then
			local numObjectives = GetNumQuestLeaderBoards(qi)

			if numObjectives > 0 then
				for bi,butt in pairs(WATCHFRAME_QUESTLINES) do
					if butt.text:GetText() == GetQuestLogTitle(qi) then
						butt.text:SetText(GetTaggedTitle(qi))
					end
				end
			end
		end
	end
end)


-- Add tags to quest links in chat
local function filter(self, event, msg, ...)
	if msg then
		return false, msg:gsub("(|c%x+|Hquest:%d+:(%d+))", "(%2) %1"), ...
	end
end
local events = {"SAY", "GUILD", "GUILD_OFFICER", "WHISPER", "WHISPER_INFORM",
	"PARTY", "RAID", "RAID_LEADER", "BATTLEGROUND", "BATTLEGROUND_LEADER"}
for _,event in pairs(events) do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..event, filter)
end


-- Add tags to gossip frame
local i
local TRIVIAL = "|cff%02x%02x%02x[%d%s%s]|r "..TRIVIAL_QUEST_DISPLAY
local NORMAL  = "|cff%02x%02x%02x[%d%s%s]|r ".. NORMAL_QUEST_DISPLAY
local function helper(isActive, ...)
	local num = select('#', ...)
	if num == 0 then return end

	local skip = isActive and 5 or 6

	for j=1,num,skip do
		local title, level, isTrivial, daily, repeatable, legendary = select(j, ...)
		if isActive then daily, repeatable = nil end
		if title and level and level ~= -1 then
			local color = GetQuestDifficultyColor(level)
			_G["GossipTitleButton"..i]:SetFormattedText(
				isActive and isTrivial and TRIVIAL or NORMAL,
				color.r*255, color.g*255, color.b*255,
				level,
				repeatable and tags.Repeatable or "",
				daily and tags.Daily or "",
				title)
		end
		i = i + 1
	end
	i = i + 1
end

local function GossipUpdate()
	i = 1
	helper(false, GetGossipAvailableQuests()) -- name, level, trivial, daily, repeatable, legendary
	helper(true, GetGossipActiveQuests()) -- name, level, trivial, complete, legendary
end
hooksecurefunc("GossipFrameUpdate", GossipUpdate)
if GossipFrame:IsShown() then GossipUpdate() end
