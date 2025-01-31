---@diagnostic disable: inject-field, deprecated
function AlterEgo:GetCharacterInfo()
    local dungeons = self:GetDungeons()
    return {
        {
            label = CHARACTER,
            value = function(character)
                local name = "-"
                local nameColor = "ffffffff"
                if character.info.name ~= nil then
                    name = character.info.name
                end
                if character.info.class.file ~= nil then
                    local classColor = C_ClassColor.GetClassColor(character.info.class.file)
                    if classColor ~= nil then
                        nameColor = classColor.GenerateHexColor(classColor)
                    end
                end
                return "|c" .. nameColor .. name .. "|r"
            end,
            OnEnter = function(character)
                local name = "-"
                local nameColor = "ffffffff"
                if character.info.name ~= nil then
                    name = character.info.name
                end
                if character.info.class.file ~= nil then
                    local classColor = C_ClassColor.GetClassColor(character.info.class.file)
                    if classColor ~= nil then
                        nameColor = classColor.GenerateHexColor(classColor)
                    end
                end
                name = "|c" .. nameColor .. name .. "|r"
                if not self.db.global.showRealms then
                    name = name .. format(" (%s)", character.info.realm)
                end
                GameTooltip:AddLine(name, 1, 1, 1);
                GameTooltip:AddLine(format("Level %d %s", character.info.level, character.info.race ~= nil and character.info.race.name or ""), 1, 1, 1);
                if character.info.factionGroup ~= nil and character.info.factionGroup.localized ~= nil then
                    GameTooltip:AddLine(character.info.factionGroup.localized, 1, 1, 1);
                end
                if character.currencies ~= nil and AE_table_count(character.currencies) > 0 then
                    local dataCurrencies = self:GetCurrencies()
                    GameTooltip:AddLine(" ");
                    GameTooltip:AddDoubleLine("Currencies:", "Maximum:")
                    AE_table_foreach(dataCurrencies, function(dataCurrency)
                        local currency = AE_table_get(character.currencies, "id", dataCurrency.id)
                        if currency then
                            if currency.useTotalEarnedForMaxQty then
                                GameTooltip:AddDoubleLine(CreateSimpleTextureMarkup(currency.iconFileID) .. " " .. currency.quantity, format("%d/%d", currency.totalEarned, currency.maxQuantity), 1, 1, 1, 1, 1, 1)
                            else
                                GameTooltip:AddDoubleLine(CreateSimpleTextureMarkup(currency.iconFileID) .. " " .. currency.quantity, format("%d", currency.maxQuantity), 1, 1, 1, 1, 1, 1)
                            end
                        end
                    end)
                end
                if character.lastUpdate ~= nil then
                    GameTooltip:AddLine(" ");
                    GameTooltip:AddLine(format("Last update:\n|cffffffff%s|r", date("%c", character.lastUpdate)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                end
                if type(character.equipment) == "table" then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("<Click to View Equipment>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                end
            end,
            OnClick = function(character)
                local windowCharacter = self:GetWindow("Character")
                local data = {
                    columns = {
                        {width = 100},
                        {width = 280},
                        {width = 80, align = "CENTER"},
                        {width = 120},
                    },
                    rows = {
                        {
                            cols = {
                                {text = "Slot",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                                {text = "Item",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                                {text = "iLevel",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                                {text = "Upgrade Level", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                            }
                        }
                    }
                }
                if type(character.equipment) == "table" then
                    AE_table_foreach(character.equipment, function(item)
                        local upgradeLevel = ""
                        if item.itemUpgradeTrack ~= "" then
                            upgradeLevel = format("%s %d/%d", item.itemUpgradeTrack, item.itemUpgradeLevel, item.itemUpgradeMax)
                            if item.itemUpgradeLevel == item.itemUpgradeMax then
                                upgradeLevel = GREEN_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
                            end
                        end
                        local row = {
                            cols = {
                                {text = _G[item.itemSlotName]},
                                {
                                    text = "|T" .. item.itemTexture .. ":0|t " .. item.itemLink,
                                    OnEnter = function()
                                        GameTooltip:SetHyperlink(item.itemLink)
                                        GameTooltip:AddLine(" ")
                                        GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                                    end,
                                    OnClick = function()
                                        if IsModifiedClick("CHATLINK") then
                                            if not ChatEdit_InsertLink(item.itemLink) then
                                                ChatFrame_OpenChat(item.itemLink);
                                            end
                                        end
                                    end
                                },
                                {text = WrapTextInColorCode(item.itemLevel, select(4, GetItemQualityColor(item.itemQuality)))},
                                {text = upgradeLevel},
                            }
                        }
                        table.insert(data.rows, row)
                    end)
                    windowCharacter.Body.Table:SetData(data)
                    local w, h = windowCharacter.Body.Table:GetSize()
                    windowCharacter:SetSize(w, h + self.constants.sizes.titlebar.height)
                    local nameColor = "ffffffff"
                    if character.info.class.file ~= nil then
                        local classColor = C_ClassColor.GetClassColor(character.info.class.file)
                        if classColor ~= nil then
                            nameColor = classColor.GenerateHexColor(classColor)
                        end
                    end
                    windowCharacter.TitleBar.Text:SetText(WrapTextInColorCode(character.info.name, nameColor))
                    windowCharacter:Show()
                end
            end,
            enabled = true,
        },
        {
            label = "Realm",
            value = function(character)
                local realm = "-"
                local realmColor = "ffffffff"
                if character.info.realm ~= nil then
                    realm = character.info.realm
                end
                return "|c" .. realmColor .. realm .. "|r"
            end,
            tooltip = false,
            enabled = self.db.global.showRealms,
        },
        {
            label = STAT_AVERAGE_ITEM_LEVEL,
            value = function(character)
                local itemLevel = ""
                local itemLevelColor = "ffffffff"
                if character.info.ilvl ~= nil then
                    if character.info.ilvl.level ~= nil then
                        itemLevel = tostring(floor(character.info.ilvl.level))
                    end
                    if character.info.ilvl.color then
                        itemLevelColor = character.info.ilvl.color
                    end
                end
                return "|c" .. itemLevelColor .. itemLevel .. "|r"
            end,
            OnEnter = function(character)
                local itemLevelTooltip = ""
                local itemLevelTooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
                if character.info.ilvl ~= nil then
                    if character.info.ilvl.level ~= nil then
                        itemLevelTooltip = itemLevelTooltip .. HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL) .. " " .. floor(character.info.ilvl.level)
                    end
                    if character.info.ilvl.level ~= nil and character.info.ilvl.equipped ~= nil and character.info.ilvl.level ~= character.info.ilvl.equipped then
                        itemLevelTooltip = itemLevelTooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, character.info.ilvl.equipped);
                    end
                    if character.info.ilvl.level ~= nil then
                        itemLevelTooltip = itemLevelTooltip .. FONT_COLOR_CODE_CLOSE
                    end
                    if character.info.ilvl.level ~= nil and character.info.ilvl.pvp ~= nil and floor(character.info.ilvl.level) ~= character.info.ilvl.pvp then
                        itemLevelTooltip2 = itemLevelTooltip2 .. "\n\n" .. STAT_AVERAGE_PVP_ITEM_LEVEL:format(tostring(floor(character.info.ilvl.pvp)));
                    end
                end
                GameTooltip:AddLine(itemLevelTooltip, 1, 1, 1);
                GameTooltip:AddLine(itemLevelTooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
            end,
            enabled = true,
        },
        {
            label = "Rating",
            value = function(character)
                local rating = "-"
                local ratingColor = "ffffffff"
                if character.mythicplus.rating ~= nil then
                    local color = C_ChallengeMode.GetDungeonScoreRarityColor(character.mythicplus.rating)
                    if color ~= nil then
                        ratingColor = color.GenerateHexColor(color)
                    end
                    rating = tostring(character.mythicplus.rating)
                end
                return "|c" .. ratingColor .. rating .. "|r"
            end,
            OnEnter = function(character)
                local rating = "-"
                local ratingColor = "ffffffff"
                local bestSeasonScore = nil
                local bestSeasonScoreColor = "ffffffff"
                local bestSeasonNumber = nil
                if character.mythicplus.bestSeasonScore ~= nil then
                    bestSeasonScore = character.mythicplus.bestSeasonScore
                    local color = C_ChallengeMode.GetDungeonScoreRarityColor(bestSeasonScore)
                    if color ~= nil then
                        bestSeasonScoreColor = color.GenerateHexColor(color)
                    end
                end
                if character.mythicplus.bestSeasonNumber ~= nil then
                    bestSeasonNumber = character.mythicplus.bestSeasonNumber
                end
                if character.mythicplus.rating ~= nil then
                    local color = C_ChallengeMode.GetDungeonScoreRarityColor(character.mythicplus.rating)
                    if color ~= nil then
                        ratingColor = color.GenerateHexColor(color)
                    end
                    rating = tostring(character.mythicplus.rating)
                end
                GameTooltip:AddLine("Mythic+ Rating", 1, 1, 1);
                GameTooltip:AddLine("Current Season: " .. "|c" .. ratingColor .. rating .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                GameTooltip:AddLine("Runs this Season: " .. "|cffffffff" .. (#character.mythicplus.runHistory or 0) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                if bestSeasonScore ~= nil then
                    local score = "|c" .. bestSeasonScoreColor .. bestSeasonScore .. "|r"
                    if bestSeasonNumber ~= nil then
                        score = score .. LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(" (Season " .. bestSeasonNumber .. ")")
                    end
                    GameTooltip:AddLine("Best Season: " .. score, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                end
                if character.mythicplus.dungeons ~= nil and AE_table_count(character.mythicplus.dungeons) > 0 then
                    GameTooltip:AddLine(" ")
                    for _, dungeon in pairs(character.mythicplus.dungeons) do
                        local dungeonName = C_ChallengeMode.GetMapUIInfo(dungeon.challengeModeID)
                        if dungeonName ~= nil then
                            if dungeon.level > 0 then
                                GameTooltip:AddDoubleLine(dungeonName, "+" .. tostring(dungeon.level), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
                            else
                                GameTooltip:AddDoubleLine(dungeonName, "-", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, LIGHTGRAY_FONT_COLOR.r, LIGHTGRAY_FONT_COLOR.g, LIGHTGRAY_FONT_COLOR.b)
                            end
                        end
                    end
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                end
            end,
            OnClick = function(character)
                if character.mythicplus.dungeons ~= nil and AE_table_count(character.mythicplus.dungeons) > 0 then
                    if IsModifiedClick("CHATLINK") then
                        local dungeonScoreDungeonTable = {};
                        for _, dungeon in pairs(character.mythicplus.dungeons) do
                            table.insert(dungeonScoreDungeonTable, dungeon.challengeModeID);
                            table.insert(dungeonScoreDungeonTable, dungeon.finishedSuccess and 1 or 0);
                            table.insert(dungeonScoreDungeonTable, dungeon.level);
                        end
                        local dungeonScoreTable = {
                            character.mythicplus.rating,
                            character.GUID,
                            character.info.name,
                            character.info.class.id,
                            math.ceil(character.info.ilvl.level),
                            character.info.level,
                            character.mythicplus.runHistory and AE_table_count(character.mythicplus.runHistory) or 0,
                            character.mythicplus.bestSeasonScore,
                            character.mythicplus.bestSeasonNumber,
                            unpack(dungeonScoreDungeonTable)
                        };
                        local link = NORMAL_FONT_COLOR:WrapTextInColorCode(LinkUtil.FormatLink("dungeonScore", DUNGEON_SCORE_LINK, unpack(dungeonScoreTable)));
                        if not ChatEdit_InsertLink(link) then
                            ChatFrame_OpenChat(link);
                        end
                    end
                end
            end,
            enabled = true,
        },
        {
            label = "Current Keystone",
            value = function(character)
                local currentKeystone = WrapTextInColorCode("-", LIGHTGRAY_FONT_COLOR:GenerateHexColor())
                if character.mythicplus.keystone ~= nil then
                    local dungeon
                    if type(character.mythicplus.keystone.challengeModeID) == "number" and character.mythicplus.keystone.challengeModeID > 0 then
                        dungeon = AE_table_get(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
                    elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
                        dungeon = AE_table_get(dungeons, "mapId", character.mythicplus.keystone.mapId)
                    end
                    if dungeon then
                        currentKeystone = dungeon.abbr
                        if type(character.mythicplus.keystone.level) == "number" and character.mythicplus.keystone.level > 0 then
                            currentKeystone = currentKeystone .. " +" .. tostring(character.mythicplus.keystone.level)
                        end
                    end
                end
                return currentKeystone
            end,
            enabled = true,
            OnEnter = function(character)
                if character.mythicplus.keystone ~= nil and type(character.mythicplus.keystone.itemLink) == "string" and character.mythicplus.keystone.itemLink ~= "" then
                    GameTooltip:SetHyperlink(character.mythicplus.keystone.itemLink)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                end
            end,
            OnClick = function(character)
                if character.mythicplus.keystone ~= nil and type(character.mythicplus.keystone.itemLink) == "string" and character.mythicplus.keystone.itemLink ~= "" then
                    if IsModifiedClick("CHATLINK") then
                        if not ChatEdit_InsertLink(character.mythicplus.keystone.itemLink) then
                            ChatFrame_OpenChat(character.mythicplus.keystone.itemLink);
                        end
                    end
                end
            end,
        },
        {
            label = "Vault",
            value = function(character)
                if character.vault.hasAvailableRewards == true then
                    return WrapTextInColorCode("Rewards", GREEN_FONT_COLOR:GenerateHexColor())
                end
                return ""
            end,
            OnEnter = function(character)
                if character.vault.hasAvailableRewards == true then
                    GameTooltip:AddLine("It's payday!", 1, 1, 1)
                    GameTooltip:AddLine(GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, true)
                end
            end,
            backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
        },
        {
            label = WrapTextInColorCode("Raids", "ffffffff"),
            value = function(character)
                local vaultLevels = ""
                if character.vault.slots ~= nil then
                    for _, slot in ipairs(character.vault.slots) do
                        if slot.type == Enum.WeeklyRewardChestThresholdType.Raid then
                            local name = "-"
                            local nameColor = LIGHTGRAY_FONT_COLOR
                            if slot.level > 0 then
                                local dataDifficulty = AE_table_get(self:GetRaidDifficulties(), "id", slot.level)
                                if dataDifficulty and dataDifficulty.abbr then
                                    name = dataDifficulty.abbr
                                else
                                    local difficultyName = GetDifficultyInfo(slot.level)
                                    if difficultyName then
                                        name = tostring(difficultyName):sub(1, 1)
                                    end
                                end
                                if self.db.global.raids.colors and dataDifficulty and dataDifficulty.color then
                                    nameColor = dataDifficulty.color
                                else
                                    nameColor = UNCOMMON_GREEN_COLOR
                                end
                            end
                            vaultLevels = vaultLevels .. WrapTextInColorCode(name, nameColor:GenerateHexColor()) .. "  "
                        end
                    end
                end
                if vaultLevels == "" then
                    vaultLevels = WrapTextInColorCode("-  -  -", LIGHTGRAY_FONT_COLOR:GenerateHexColor())
                end
                return strtrim(vaultLevels)
            end,
            OnEnter = function(character)
                GameTooltip:AddLine("Vault Progress", 1, 1, 1)
                if character.vault.slots ~= nil then
                    local slots = AE_table_filter(character.vault.slots, function(slot)
                        return slot.type == Enum.WeeklyRewardChestThresholdType.Raid
                    end)
                    for _, slot in ipairs(slots) do
                        local color = LIGHTGRAY_FONT_COLOR
                        local result = "Locked"
                        if slot.progress >= slot.threshold then
                            color = WHITE_FONT_COLOR
                            if slot.exampleRewardLink ~= nil and slot.exampleRewardLink ~= "" then
                                local itemLevel = GetDetailedItemLevelInfo(slot.exampleRewardLink)
                                local difficultyName = GetDifficultyInfo(slot.level)
                                local dataDifficulty = AE_table_get(self:GetRaidDifficulties(), "id", slot.level)
                                if dataDifficulty then
                                    difficultyName = dataDifficulty.short and dataDifficulty.short or dataDifficulty.name
                                end
                                result = format("%s (%d+)", difficultyName, itemLevel)
                            else
                                result = "?"
                            end
                        end
                        GameTooltip:AddDoubleLine(format("%d boss kills:", slot.threshold), result, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
                    end

                    local incompleteSlots = AE_table_filter(character.vault.slots, function(slot)
                        return slot.type == Enum.WeeklyRewardChestThresholdType.Raid and slot.progress < slot.threshold
                    end)
                    if AE_table_count(incompleteSlots) > 0 then
                        table.sort(incompleteSlots, function(a, b) return a.threshold < b.threshold end)
                        GameTooltip:AddLine(" ")
                        local tooltip = ""
                        if AE_table_count(incompleteSlots) == AE_table_count(slots) then
                            tooltip = format("Defeat %d bosses this week to unlock your first Great Vault reward.", incompleteSlots[1].threshold)
                        else
                            local diff = incompleteSlots[1].threshold - incompleteSlots[1].progress
                            if diff == 1 then
                                tooltip = format("Defeat %d more boss this week to unlock another Great Vault reward.", diff)
                            else
                                tooltip = format("Defeat another %d bosses this week to unlock another Great Vault reward.", diff)
                            end
                        end
                        GameTooltip:AddLine(tooltip, nil, nil, nil, true)
                    end
                end
            end,
            enabled = self.db.global.raids.enabled,
        },
        {
            label = WrapTextInColorCode("Dungeons", "ffffffff"),
            value = function(character)
                local vaultLevels = ""
                if character.vault.slots ~= nil then
                    local slots = AE_table_filter(character.vault.slots, function(slot) return slot.type == Enum.WeeklyRewardChestThresholdType.Activities end)
                    for _, slot in ipairs(slots) do
                        local level = "-"
                        local color = LIGHTGRAY_FONT_COLOR
                        if slot.progress >= slot.threshold then
                            level = tostring(slot.level)
                            color = UNCOMMON_GREEN_COLOR
                        end
                        vaultLevels = vaultLevels .. WrapTextInColorCode(level, color:GenerateHexColor()) .. "  "
                    end
                end
                if vaultLevels == "" then
                    vaultLevels = WrapTextInColorCode("-  -  -", LIGHTGRAY_FONT_COLOR:GenerateHexColor())
                end
                return strtrim(vaultLevels)
            end,
            OnEnter = function(character)
                local weeklyRuns = AE_table_filter(character.mythicplus.runHistory, function(run) return run.thisWeek == true end)
                local weeklyRunsCount = AE_table_count(weeklyRuns) or 0
                GameTooltip:AddLine("Vault Progress", 1, 1, 1);
                -- GameTooltip:AddLine("Runs this Week: " .. "|cffffffff" .. tostring(weeklyRunsCount) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

                if character.mythicplus ~= nil and character.mythicplus.numCompletedDungeonRuns ~= nil then
                    local numHeroic = character.mythicplus.numCompletedDungeonRuns.heroic or 0
                    if numHeroic > 0 then
                        GameTooltip:AddLine("Heroic runs this Week: " .. "|cffffffff" .. tostring(numHeroic) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                    end
                    local numMythic = character.mythicplus.numCompletedDungeonRuns.mythic or 0
                    if numMythic > 0 then
                        GameTooltip:AddLine("Mythic runs this Week: " .. "|cffffffff" .. tostring(numMythic) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                    end
                    local numMythicPlus = character.mythicplus.numCompletedDungeonRuns.mythicPlus or 0
                    if numMythicPlus > 0 then
                        GameTooltip:AddLine("Mythic+ runs this Week: " .. "|cffffffff" .. tostring(numMythicPlus) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                    end
                end
                GameTooltip_AddBlankLineToTooltip(GameTooltip);

                local lastCompletedActivityInfo, nextActivityInfo = AE_GetActivitiesProgress(character);
                if not lastCompletedActivityInfo then
                    GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);
                else
                    if nextActivityInfo then
                        local globalString = (lastCompletedActivityInfo.index == 1) and GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST or GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
                        GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivityInfo.threshold - nextActivityInfo.progress));
                    else
                        GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_THIRD);
                        local level, count = AE_GetLowestLevelInTopDungeonRuns(character, lastCompletedActivityInfo.threshold);
                        if level == WeeklyRewardsUtil.HeroicLevel then
                            GameTooltip_AddBlankLineToTooltip(GameTooltip);
                            GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
                            GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_HEROIC_IMPROVE:format(count));
                        else
                            local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(level);
                            if nextLevel < 20 then
                                GameTooltip_AddBlankLineToTooltip(GameTooltip);
                                GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
                                GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_IMPROVE:format(count, nextLevel));
                            end
                        end
                    end
                end

                if weeklyRunsCount > 0 then
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    table.sort(weeklyRuns, function(a, b) return a.level > b.level end)
                    for runIndex, run in ipairs(weeklyRuns) do
                        local threshold = AE_table_find(character.vault.slots, function(slot) return slot.type == Enum.WeeklyRewardChestThresholdType.Activities and runIndex == slot.threshold end)
                        local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level)
                        local dungeon = AE_table_get(dungeons, "challengeModeID", run.mapChallengeModeID)
                        local color = WHITE_FONT_COLOR
                        if threshold then
                            color = GREEN_FONT_COLOR
                        end
                        if dungeon then
                            GameTooltip:AddDoubleLine(dungeon.short and dungeon.short or dungeon.name, string.format("+%d (%d)", run.level, rewardLevel), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
                        end
                        if runIndex == 8 then
                            break
                        end
                    end
                end
            end,
            enabled = true,
        },
    }
end

function AlterEgo:SetBackgroundColor(parent, r, g, b, a)
    if not parent.Background then
        parent.Background = parent:CreateTexture(parent:GetName() .. "Background", "BACKGROUND")
        parent.Background:SetTexture(self.constants.media.WhiteSquare)
        parent.Background:SetAllPoints()
    end

    parent.Background:SetVertexColor(r, g, b, a)
end

function AlterEgo:CreateCharacterColumn(parent, index)
    local affixes = self:GetAffixes(true)
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local anchorFrame

    local CharacterColumn = CreateFrame("Frame", "$parentCharacterColumn" .. index, parent)
    CharacterColumn:SetWidth(self.constants.sizes.column)
    self:SetBackgroundColor(CharacterColumn, 1, 1, 1, index % 2 == 0 and 0.01 or 0)
    anchorFrame = CharacterColumn

    -- Character info
    do
        local labels = self:GetCharacterInfo()
        for labelIndex, info in ipairs(labels) do
            local CharacterFrame = CreateFrame(info.OnClick and "Button" or "Frame", "$parentInfo" .. labelIndex, CharacterColumn)
            if labelIndex > 1 then
                CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            else
                CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
            end

            CharacterFrame:SetHeight(self.constants.sizes.row)
            CharacterFrame.Text = CharacterFrame:CreateFontString(CharacterFrame:GetName() .. "Text", "OVERLAY")
            CharacterFrame.Text:SetPoint("LEFT", CharacterFrame, "LEFT", self.constants.sizes.padding, 0)
            CharacterFrame.Text:SetPoint("RIGHT", CharacterFrame, "RIGHT", -self.constants.sizes.padding, 0)
            CharacterFrame.Text:SetJustifyH("CENTER")
            CharacterFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
            if info.backgroundColor then
                self:SetBackgroundColor(CharacterFrame, info.backgroundColor.r, info.backgroundColor.g, info.backgroundColor.b, info.backgroundColor.a)
            end

            anchorFrame = CharacterFrame
        end
    end

    CharacterColumn.AffixHeader = CreateFrame("Frame", "$parentAffixes", CharacterColumn)
    CharacterColumn.AffixHeader:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    CharacterColumn.AffixHeader:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    CharacterColumn.AffixHeader:SetHeight(self.constants.sizes.row)
    self:SetBackgroundColor(CharacterColumn.AffixHeader, 0, 0, 0, 0.3)
    anchorFrame = CharacterColumn.AffixHeader

    -- Affix header icons
    for affixIndex, affix in ipairs(affixes) do
        local AffixFrame = CreateFrame("Frame", CharacterColumn.AffixHeader:GetName() .. affixIndex, CharacterColumn)
        if affixIndex == 1 then
            AffixFrame:SetPoint("TOPLEFT", CharacterColumn.AffixHeader:GetName(), "TOPLEFT")
            AffixFrame:SetPoint("BOTTOMRIGHT", CharacterColumn.AffixHeader:GetName(), "BOTTOM")
        else
            AffixFrame:SetPoint("TOPLEFT", CharacterColumn.AffixHeader:GetName(), "TOP")
            AffixFrame:SetPoint("BOTTOMRIGHT", CharacterColumn.AffixHeader:GetName(), "BOTTOMRIGHT")
        end
        AffixFrame.Icon = AffixFrame:CreateTexture(AffixFrame:GetName() .. "Icon", "ARTWORK")
        AffixFrame.Icon:SetTexture(affix.fileDataID)
        AffixFrame.Icon:SetSize(16, 16)
        AffixFrame.Icon:SetPoint("CENTER", AffixFrame, "CENTER", 0, 0)
        AffixFrame:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(AffixFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(affix.name, 1, 1, 1, 1, true);
            GameTooltip:AddLine(affix.description, nil, nil, nil, true);
            GameTooltip:Show()
        end)
        AffixFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    -- Dungeon rows
    for dungeonIndex in ipairs(dungeons) do
        local DungeonFrame = CreateFrame("Frame", "$parentDungeons" .. dungeonIndex, CharacterColumn)
        DungeonFrame:SetHeight(self.constants.sizes.row)
        DungeonFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        DungeonFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        self:SetBackgroundColor(DungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
        anchorFrame = DungeonFrame

        -- Affix values
        for affixIndex, affix in ipairs(affixes) do
            local AffixFrame = CreateFrame("Frame", "$parentAffix" .. affixIndex, DungeonFrame)
            if affixIndex == 1 then
                AffixFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                AffixFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOM")
            else
                AffixFrame:SetPoint("TOPLEFT", anchorFrame, "TOP")
                AffixFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT")
            end

            AffixFrame.Text = AffixFrame:CreateFontString(AffixFrame:GetName() .. "Text", "OVERLAY")
            AffixFrame.Text:SetPoint("TOPLEFT", AffixFrame, "TOPLEFT", 1, -1)
            AffixFrame.Text:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOM", -1, 1)
            AffixFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
            AffixFrame.Text:SetJustifyH("RIGHT")
            AffixFrame.Tier = AffixFrame:CreateFontString(AffixFrame:GetName() .. "Tier", "OVERLAY")
            AffixFrame.Tier:SetPoint("TOPLEFT", AffixFrame, "TOP", 1, -1)
            AffixFrame.Tier:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOMRIGHT", -1, 1)
            AffixFrame.Tier:SetFontObject("GameFontHighlight_NoShadow")
            AffixFrame.Tier:SetJustifyH("LEFT")
        end
        anchorFrame = DungeonFrame
    end

    -- Raid Rows
    for raidIndex, raid in ipairs(raids) do
        local RaidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, CharacterColumn)
        RaidFrame:SetHeight(self.constants.sizes.row)
        RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        self:SetBackgroundColor(RaidFrame, 0, 0, 0, 0.3)
        anchorFrame = RaidFrame

        for difficultyIndex in pairs(AlterEgo:GetRaidDifficulties()) do
            local DifficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, RaidFrame)
            DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
            DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            DifficultyFrame:SetHeight(self.constants.sizes.row)
            self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, difficultyIndex % 2 == 0 and 0.01 or 0)
            anchorFrame = DifficultyFrame

            for encounterIndex in ipairs(raid.encounters) do
                local EncounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, DifficultyFrame)
                local size = self.constants.sizes.column
                size = size - self.constants.sizes.padding -- left/right cell padding
                size = size - (raid.numEncounters - 1) * 4 -- gaps
                size = size / raid.numEncounters           -- box sizes
                EncounterFrame:SetPoint("LEFT", anchorFrame, encounterIndex > 1 and "RIGHT" or "LEFT", self.constants.sizes.padding / 2, 0)
                EncounterFrame:SetSize(size, self.constants.sizes.row - 12)
                self:SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
                anchorFrame = EncounterFrame
            end
            anchorFrame = DifficultyFrame
        end
    end

    return CharacterColumn
end

local CharacterColumns = {}
function AlterEgo:GetCharacterColumn(parent, index)
    if CharacterColumns[index] == nil then
        CharacterColumns[index] = self:CreateCharacterColumn(parent, index)
    end
    CharacterColumns[index]:Show()
    return CharacterColumns[index]
end

function AlterEgo:HideCharacterColumns()
    for _, CharacterColumn in ipairs(CharacterColumns) do
        CharacterColumn:Hide()
    end
end

function AlterEgo:IsScrollbarNeeded()
    local characters = self:GetCharacters()
    local numCharacters = AE_table_count(characters)
    return numCharacters > 0 and self.constants.sizes.sidebar.width + numCharacters * self.constants.sizes.column > self:GetMaxWindowWidth()
end

function AlterEgo:GetWindowSize()
    local characters = self:GetCharacters()
    local numCharacters = AE_table_count(characters)
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()
    local width = 0
    local maxWidth = self:GetMaxWindowWidth()
    local height = 0

    -- Width
    if numCharacters == 0 then
        width = 500
    else
        width = width + self.constants.sizes.sidebar.width
        width = width + numCharacters * self.constants.sizes.column
    end
    if width > maxWidth then
        width = maxWidth
        if numCharacters > 0 then
            height = height + self.constants.sizes.footer.height -- Shoes?
        end
    end

    -- Height
    height = height + self.constants.sizes.titlebar.height                                                                                                                  -- Titlebar duh
    height = height + AE_table_count(AE_table_filter(self:GetCharacterInfo(), function(label) return label.enabled == nil or label.enabled end)) * self.constants.sizes.row -- Character info
    height = height + self.constants.sizes.row                                                                                                                              -- DungeonHeader
    height = height + AE_table_count(dungeons) * self.constants.sizes.row                                                                                                   -- Dungeon rows
    if self.db.global.raids.enabled then
        height = height + AE_table_count(raids) * (AE_table_count(difficulties) + 1) * self.constants.sizes.row                                                             -- Raids
    end

    return width, height
end

function AlterEgo:CreateUI()
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()
    local labels = self:GetCharacterInfo()
    local anchorFrame

    local winMain = self:CreateWindow("Main", "AlterEgo", UIParent)
    local winEquipment = self:CreateWindow("Character", "Character", UIParent)
    local winAffixRotation = self:CreateWindow("Affixes", "Affixes", UIParent)
    local winKeyManager = self:CreateWindow("KeyManager", "KeyManager", UIParent)

    winEquipment.Body.Table = self.Table:New()
    winEquipment.Body.Table.frame:SetParent(winEquipment.Body)
    winEquipment.Body.Table.frame:SetPoint("TOPLEFT", winEquipment.Body, "TOPLEFT")

    winAffixRotation.Body.Table = self.Table:New()
    winAffixRotation.Body.Table.frame:SetParent(winAffixRotation.Body)
    winAffixRotation.Body.Table.frame:SetPoint("TOPLEFT", winAffixRotation.Body, "TOPLEFT")
    winAffixRotation.TitleBar.Text:SetText("Weekly Affixes")

    do -- TitleBar
        anchorFrame = winMain.TitleBar
        winMain.TitleBar.Affixes = CreateFrame("Button", "$parentAffixes", winMain.TitleBar)
        for i = 1, 3 do
            local affixButton = CreateFrame("Button", "$parent" .. i, winMain.TitleBar.Affixes)
            affixButton:SetSize(20, 20)
            affixButton:SetScript("OnClick", function()
                local currentAffixes = C_MythicPlus.GetCurrentAffixes()
                local affixRotation = self:GetAffixRotation()
                local activeWeek = self:GetActiveAffixRotation(currentAffixes)
                local affixes = self:GetAffixes()
                local data = {
                    columns = {
                        {width = 120},
                        {width = 120},
                        {width = 120},
                        {width = 120},
                    },
                    rows = {
                        {
                            cols = {
                                {text = "+2",         backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                                {text = "+7",         backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                                {text = "+14",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                                {text = "Difficulty", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                            }
                        }
                    }
                }

                AE_table_foreach(affixRotation, function(affixValues, weekIndex)
                    local row = {cols = {}}
                    AE_table_foreach(affixValues, function(affixValue)
                        if type(affixValue) == "number" then
                            local affix = AE_table_get(affixes, "id", affixValue)
                            if affix then
                                local name = weekIndex < activeWeek and LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(affix.name) or affix.name
                                table.insert(row.cols, {
                                    text = "|T" .. affix.fileDataID .. ":0|t " .. name,
                                    backgroundColor = weekIndex == activeWeek and {r = 0, g = 0, b = 0, a = 0.5} or nil,
                                    OnEnter = function()
                                        GameTooltip:SetText(affix.name, 1, 1, 1, 1, true);
                                        GameTooltip:AddLine(affix.description, nil, nil, nil, true);
                                    end,
                                })
                            end
                        else
                            table.insert(row.cols, {
                                text = affixValue,
                                backgroundColor = weekIndex == activeWeek and {r = 0, g = 0, b = 0, a = 0.5} or nil,
                            })
                        end
                    end)
                    table.insert(data.rows, row)
                end)
                winAffixRotation.Body.Table:SetData(data)
                local w, h = winAffixRotation.Body.Table:GetSize()
                winAffixRotation:SetSize(w, h + self.constants.sizes.titlebar.height)
                self:ToggleWindow("Affixes")
            end)
        end
        winMain.TitleBar.SettingsButton = CreateFrame("Button", "$parentSettingsButton", winMain.TitleBar)
        winMain.TitleBar.SettingsButton:SetPoint("RIGHT", winMain.TitleBar.CloseButton, "LEFT", 0, 0)
        winMain.TitleBar.SettingsButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        winMain.TitleBar.SettingsButton:RegisterForClicks("AnyUp")
        winMain.TitleBar.SettingsButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, winMain.TitleBar.SettingsButton.Dropdown) end)
        winMain.TitleBar.SettingsButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.SettingsButton:GetName() .. "Icon", "ARTWORK")
        winMain.TitleBar.SettingsButton.Icon:SetPoint("CENTER", winMain.TitleBar.SettingsButton, "CENTER")
        winMain.TitleBar.SettingsButton.Icon:SetSize(12, 12)
        winMain.TitleBar.SettingsButton.Icon:SetTexture(self.constants.media.IconSettings)
        winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        winMain.TitleBar.SettingsButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.SettingsButton:GetName() .. "Dropdown", winMain.TitleBar, "UIDropDownMenuTemplate")
        winMain.TitleBar.SettingsButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.SettingsButton, "CENTER", 0, -6)
        winMain.TitleBar.SettingsButton.Dropdown.Button:Hide()
        UIDropDownMenu_SetWidth(winMain.TitleBar.SettingsButton.Dropdown, self.constants.sizes.titlebar.height)
        UIDropDownMenu_Initialize(
            winMain.TitleBar.SettingsButton.Dropdown,
            function(frame, level, subMenuName)
                if subMenuName == "windowscale" then
                    for i = 80, 200, 10 do
                        UIDropDownMenu_AddButton(
                            {
                                text = i .. "%",
                                value = i,
                                checked = self.db.global.interface.windowScale == i,
                                func = function(button)
                                    self.db.global.interface.windowScale = button.value
                                    self:UpdateUI()
                                end
                            },
                            level
                        )
                    end
                elseif level == 1 then
                    UIDropDownMenu_AddButton({text = "General", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Show the weekly affixes",
                        checked = self.db.global.showAffixHeader,
                        isNotRadio = true,
                        tooltipTitle = "Show the weekly affixes",
                        tooltipText = "The affixes will be shown at the top.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.showAffixHeader = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Show characters with zero rating",
                        checked = self.db.global.showZeroRatedCharacters,
                        isNotRadio = true,
                        tooltipTitle = "Show characters with zero rating",
                        tooltipText = "Too many alts?",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.showZeroRatedCharacters = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Show realm names",
                        checked = self.db.global.showRealms,
                        isNotRadio = true,
                        tooltipTitle = "Show realm names",
                        tooltipText = "One big party!",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.showRealms = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Announce instance resets",
                        checked = self.db.global.announceResets,
                        isNotRadio = true,
                        tooltipTitle = "Announce instance resets",
                        tooltipText = "Let others in your group know when you've reset the instances.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.announceResets = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Keystone Announcements", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Announce new keystones (Party)",
                        checked = self.db.global.announceKeystones.autoParty,
                        isNotRadio = true,
                        tooltipTitle = "New keystones (Party)",
                        tooltipText = "Announce to your party when you loot a new keystone.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.announceKeystones.autoParty = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Announce new keystones (Guild)",
                        checked = self.db.global.announceKeystones.autoGuild,
                        isNotRadio = true,
                        tooltipTitle = "New keystones (Guild)",
                        tooltipText = "Announce to your guild when you loot a new keystone.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.announceKeystones.autoGuild = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Announce keystones in one message",
                        checked = not self.db.global.announceKeystones.multiline,
                        isNotRadio = true,
                        tooltipTitle = "Announce keystones in one message",
                        tooltipText = "With too many alts it could get spammy.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.announceKeystones.multiline = checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Dungeons", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Show timed icons",
                        checked = self.db.global.showTiers,
                        isNotRadio = true,
                        tooltipTitle = "Show timed icons",
                        tooltipText = "Show the timed icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a).",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.showTiers = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Show score colors",
                        checked = self.db.global.showAffixColors,
                        isNotRadio = true,
                        tooltipTitle = "Show score colors",
                        tooltipText = "Show some colors!",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.showAffixColors = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Raids", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Show raid progress",
                        checked = self.db.global.raids and self.db.global.raids.enabled,
                        isNotRadio = true,
                        tooltipTitle = "Show raid progress",
                        tooltipText = "Because Mythic Plus ain't enough!",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.raids.enabled = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Show difficulty colors",
                        checked = self.db.global.raids and self.db.global.raids.colors,
                        isNotRadio = true,
                        tooltipTitle = "Show difficulty colors",
                        tooltipText = "Argharhggh! So much greeeen!",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.raids.colors = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Minimap", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Show the minimap button",
                        checked = not self.db.global.minimap.hide,
                        isNotRadio = true,
                        tooltipTitle = "Show the minimap button",
                        tooltipText = "It does get crowded around the minimap sometimes.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.minimap.hide = checked
                            self.Libs.LDBIcon:Refresh("AlterEgo", self.db.global.minimap)
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Lock the minimap button",
                        checked = self.db.global.minimap.lock,
                        isNotRadio = true,
                        tooltipTitle = "Lock the minimap button",
                        tooltipText = "No more moving the button around accidentally!",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.minimap.lock = not checked
                            self.Libs.LDBIcon:Refresh("AlterEgo", self.db.global.minimap)
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Interface", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Window color",
                        notCheckable = true,
                        hasColorSwatch = true,
                        r = self.db.global.interface.windowColor.r,
                        g = self.db.global.interface.windowColor.g,
                        b = self.db.global.interface.windowColor.b,
                        -- notClickable = true,
                        hasOpacity = false,
                        func = UIDropDownMenuButton_OpenColorPicker,
                        swatchFunc = function()
                            local r, g, b = ColorPickerFrame:GetColorRGB();
                            self.db.global.interface.windowColor.r = r
                            self.db.global.interface.windowColor.g = g
                            self.db.global.interface.windowColor.b = b
                            self:SetBackgroundColor(winMain, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
                        end,
                        cancelFunc = function(color)
                            self.db.global.interface.windowColor.r = color.r
                            self.db.global.interface.windowColor.g = color.g
                            self.db.global.interface.windowColor.b = color.b
                            self:SetBackgroundColor(winMain, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Window scale", notCheckable = true, hasArrow = true, menuList = "windowscale"})
                end
            end,
            "MENU"
        )
        winMain.TitleBar.SettingsButton:SetScript("OnEnter", function()
            winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
            self:SetBackgroundColor(winMain.TitleBar.SettingsButton, 1, 1, 1, 0.05)
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(winMain.TitleBar.SettingsButton, "ANCHOR_TOP")
            GameTooltip:SetText("Settings", 1, 1, 1, 1, true);
            GameTooltip:AddLine("Let's customize things a bit", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            GameTooltip:Show()
        end)
        winMain.TitleBar.SettingsButton:SetScript("OnLeave", function()
            winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
            self:SetBackgroundColor(winMain.TitleBar.SettingsButton, 1, 1, 1, 0)
            GameTooltip:Hide()
        end)
        winMain.TitleBar.SortingButton = CreateFrame("Button", "$parentSorting", winMain.TitleBar)
        winMain.TitleBar.SortingButton:SetPoint("RIGHT", winMain.TitleBar.SettingsButton, "LEFT", 0, 0)
        winMain.TitleBar.SortingButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        winMain.TitleBar.SortingButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, winMain.TitleBar.SortingButton.Dropdown) end)
        winMain.TitleBar.SortingButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.SortingButton:GetName() .. "Icon", "ARTWORK")
        winMain.TitleBar.SortingButton.Icon:SetPoint("CENTER", winMain.TitleBar.SortingButton, "CENTER")
        winMain.TitleBar.SortingButton.Icon:SetSize(16, 16)
        winMain.TitleBar.SortingButton.Icon:SetTexture(self.constants.media.IconSorting)
        winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        winMain.TitleBar.SortingButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.SortingButton:GetName() .. "Dropdown", winMain.TitleBar.SortingButton, "UIDropDownMenuTemplate")
        winMain.TitleBar.SortingButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.SortingButton, "CENTER", 0, -6)
        winMain.TitleBar.SortingButton.Dropdown.Button:Hide()
        UIDropDownMenu_SetWidth(winMain.TitleBar.SortingButton.Dropdown, self.constants.sizes.titlebar.height)
        UIDropDownMenu_Initialize(
            winMain.TitleBar.SortingButton.Dropdown,
            function()
                for _, option in ipairs(self.constants.sortingOptions) do
                    UIDropDownMenu_AddButton({
                        text = option.text,
                        checked = self.db.global.sorting == option.value,
                        arg1 = option.value,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.sorting = arg1
                            self:UpdateUI()
                        end
                    })
                end
            end,
            "MENU"
        )
        winMain.TitleBar.SortingButton:SetScript("OnEnter", function()
            winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
            self:SetBackgroundColor(winMain.TitleBar.SortingButton, 1, 1, 1, 0.05)
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(winMain.TitleBar.SortingButton, "ANCHOR_TOP")
            GameTooltip:SetText("Sorting", 1, 1, 1, 1, true);
            GameTooltip:AddLine("Sort your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            GameTooltip:Show()
        end)
        winMain.TitleBar.SortingButton:SetScript("OnLeave", function()
            winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
            self:SetBackgroundColor(winMain.TitleBar.SortingButton, 1, 1, 1, 0)
            GameTooltip:Hide()
        end)
        winMain.TitleBar.CharactersButton = CreateFrame("Button", "$parentCharacters", winMain.TitleBar)
        winMain.TitleBar.CharactersButton:SetPoint("RIGHT", winMain.TitleBar.SortingButton, "LEFT", 0, 0)
        winMain.TitleBar.CharactersButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        winMain.TitleBar.CharactersButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, winMain.TitleBar.CharactersButton.Dropdown) end)
        winMain.TitleBar.CharactersButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.CharactersButton:GetName() .. "Icon", "ARTWORK")
        winMain.TitleBar.CharactersButton.Icon:SetPoint("CENTER", winMain.TitleBar.CharactersButton, "CENTER")
        winMain.TitleBar.CharactersButton.Icon:SetSize(14, 14)
        winMain.TitleBar.CharactersButton.Icon:SetTexture(self.constants.media.IconCharacters)
        winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        winMain.TitleBar.CharactersButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.CharactersButton:GetName() .. "Dropdown", winMain.TitleBar.CharactersButton, "UIDropDownMenuTemplate")
        winMain.TitleBar.CharactersButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.CharactersButton, "CENTER", 0, -6)
        winMain.TitleBar.CharactersButton.Dropdown.Button:Hide()
        UIDropDownMenu_SetWidth(winMain.TitleBar.CharactersButton.Dropdown, self.constants.sizes.titlebar.height)
        UIDropDownMenu_Initialize(
            winMain.TitleBar.CharactersButton.Dropdown,
            function()
                local charactersUnfilteredList = self:GetCharacters(true)
                for _, character in ipairs(charactersUnfilteredList) do
                    local nameColor = "ffffffff"
                    if character.info.class.file ~= nil then
                        local classColor = C_ClassColor.GetClassColor(character.info.class.file)
                        if classColor ~= nil then
                            nameColor = classColor.GenerateHexColor(classColor)
                        end
                    end
                    UIDropDownMenu_AddButton({
                        text = "|c" .. nameColor .. character.info.name .. "|r (" .. character.info.realm .. ")",
                        checked = character.enabled,
                        isNotRadio = true,
                        arg1 = character.GUID,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.characters[arg1].enabled = not checked
                            self:UpdateUI()
                        end
                    })
                end
            end,
            "MENU"
        )
        winMain.TitleBar.CharactersButton:SetScript("OnEnter", function()
            winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
            self:SetBackgroundColor(winMain.TitleBar.CharactersButton, 1, 1, 1, 0.05)
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(winMain.TitleBar.CharactersButton, "ANCHOR_TOP")
            GameTooltip:SetText("Characters", 1, 1, 1, 1, true);
            GameTooltip:AddLine("Enable/Disable your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            GameTooltip:Show()
        end)
        winMain.TitleBar.CharactersButton:SetScript("OnLeave", function()
            winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
            self:SetBackgroundColor(winMain.TitleBar.CharactersButton, 1, 1, 1, 0)
            GameTooltip:Hide()
        end)
        winMain.TitleBar.AnnounceButton = CreateFrame("Button", "$parentCharacters", winMain.TitleBar)
        winMain.TitleBar.AnnounceButton:SetPoint("RIGHT", winMain.TitleBar.CharactersButton, "LEFT", 0, 0)
        winMain.TitleBar.AnnounceButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        winMain.TitleBar.AnnounceButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, winMain.TitleBar.AnnounceButton.Dropdown) end)
        winMain.TitleBar.AnnounceButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.AnnounceButton:GetName() .. "Icon", "ARTWORK")
        winMain.TitleBar.AnnounceButton.Icon:SetPoint("CENTER", winMain.TitleBar.AnnounceButton, "CENTER")
        winMain.TitleBar.AnnounceButton.Icon:SetSize(12, 12)
        winMain.TitleBar.AnnounceButton.Icon:SetTexture(self.constants.media.IconAnnounce)
        winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        winMain.TitleBar.AnnounceButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.AnnounceButton:GetName() .. "Dropdown", winMain.TitleBar.AnnounceButton, "UIDropDownMenuTemplate")
        winMain.TitleBar.AnnounceButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.AnnounceButton, "CENTER", 0, -6)
        winMain.TitleBar.AnnounceButton.Dropdown.Button:Hide()
        UIDropDownMenu_SetWidth(winMain.TitleBar.AnnounceButton.Dropdown, self.constants.sizes.titlebar.height)
        UIDropDownMenu_Initialize(
            winMain.TitleBar.AnnounceButton.Dropdown,
            function()
                UIDropDownMenu_AddButton({
                    text = "Send to Party Chat",
                    isNotRadio = true,
                    notCheckable = true,
                    tooltipTitle = "Party",
                    tooltipText = "Announce all your keystones to the party chat",
                    tooltipOnButton = true,
                    func = function()
                        if not IsInGroup() then
                            self:Print("No announcement. You are not in a party.")
                            return
                        end
                        self:AnnounceKeystones("PARTY", self.db.global.announceKeystones.multiline)
                    end
                })
                UIDropDownMenu_AddButton({
                    text = "Send to Guild Chat",
                    isNotRadio = true,
                    notCheckable = true,
                    tooltipTitle = "Guild",
                    tooltipText = "Announce all your keystones to the guild chat",
                    tooltipOnButton = true,
                    func = function()
                        if not IsInGuild() then
                            self:Print("No announcement. You are not in a guild.")
                            return
                        end
                        self:AnnounceKeystones("GUILD", self.db.global.announceKeystones.multiline)
                    end
                })
            end,
            "MENU"
        )
        winMain.TitleBar.AnnounceButton:SetScript("OnEnter", function()
            winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
            self:SetBackgroundColor(winMain.TitleBar.AnnounceButton, 1, 1, 1, 0.05)
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(winMain.TitleBar.AnnounceButton, "ANCHOR_TOP")
            GameTooltip:SetText("Announce Keystones", 1, 1, 1, 1, true);
            GameTooltip:AddLine("Sharing is caring.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            GameTooltip:Show()
        end)
        winMain.TitleBar.AnnounceButton:SetScript("OnLeave", function()
            winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
            self:SetBackgroundColor(winMain.TitleBar.AnnounceButton, 1, 1, 1, 0)
            GameTooltip:Hide()
        end)
    end

    -- do -- Body
    --     window.Body = CreateFrame("Frame", "$parentBody", window)
    --     window.Body:SetPoint("TOPLEFT", window.TitleBar, "BOTTOMLEFT")
    --     window.Body:SetPoint("TOPRIGHT", window.TitleBar, "BOTTOMRIGHT")
    --selfAlterEgo:SetBackgroundColor(window.Body, 0, 0, 0, 0)
    -- end

    do -- No characters enabled
        winMain.Body.NoCharacterText = winMain.Body:CreateFontString("$parentNoCharacterText", "ARTWORK")
        winMain.Body.NoCharacterText:SetPoint("TOPLEFT", winMain.Body, "TOPLEFT", 50, -50)
        winMain.Body.NoCharacterText:SetPoint("BOTTOMRIGHT", winMain.Body, "BOTTOMRIGHT", -50, 50)
        winMain.Body.NoCharacterText:SetJustifyH("CENTER")
        winMain.Body.NoCharacterText:SetJustifyV("CENTER")
        winMain.Body.NoCharacterText:SetFontObject("GameFontHighlight_NoShadow")
        winMain.Body.NoCharacterText:SetText("|cffffffffHi there :-)|r\n\nYou need to enable a max level character for this addon to show you some goodies!")
        winMain.Body.NoCharacterText:SetVertexColor(1.0, 0.82, 0.0, 1)
        winMain.Body.NoCharacterText:Hide()
    end

    do -- Sidebar
        winMain.Body.Sidebar = CreateFrame("Frame", "$parentSidebar", winMain.Body)
        winMain.Body.Sidebar:SetPoint("TOPLEFT", winMain.Body, "TOPLEFT")
        winMain.Body.Sidebar:SetPoint("BOTTOMLEFT", winMain.Body, "BOTTOMLEFT")
        winMain.Body.Sidebar:SetWidth(self.constants.sizes.sidebar.width)
        self:SetBackgroundColor(winMain.Body.Sidebar, 0, 0, 0, 0.3)
        anchorFrame = winMain.Body.Sidebar
    end

    do -- Character info
        for labelIndex, info in ipairs(labels) do
            local Label = CreateFrame("Frame", "$parentLabel" .. labelIndex, winMain.Body.Sidebar)
            if labelIndex > 1 then
                Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            else
                Label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                Label:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
            end
            Label:SetHeight(self.constants.sizes.row)
            Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
            Label.Text:SetPoint("LEFT", Label, "LEFT", self.constants.sizes.padding, 0)
            Label.Text:SetPoint("RIGHT", Label, "RIGHT", -self.constants.sizes.padding, 0)
            Label.Text:SetJustifyH("LEFT")
            Label.Text:SetFontObject("GameFontHighlight_NoShadow")
            Label.Text:SetText(info.label)
            Label.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
            anchorFrame = Label
        end
    end

    do -- MythicPlus Label
        local Label = CreateFrame("Frame", "$parentMythicPlusLabel", winMain.Body.Sidebar)
        Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        Label:SetHeight(self.constants.sizes.row)
        Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
        Label.Text:SetPoint("TOPLEFT", Label, "TOPLEFT", self.constants.sizes.padding, 0)
        Label.Text:SetPoint("BOTTOMRIGHT", Label, "BOTTOMRIGHT", -self.constants.sizes.padding, 0)
        Label.Text:SetFontObject("GameFontHighlight_NoShadow")
        Label.Text:SetJustifyH("LEFT")
        Label.Text:SetText("Mythic Plus")
        Label.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
        anchorFrame = Label
    end

    do -- Dungeon Labels
        for dungeonIndex, dungeon in ipairs(dungeons) do
            local Label = CreateFrame("Button", "$parentDungeon" .. dungeonIndex, winMain.Body.Sidebar, "InsecureActionButtonTemplate")
            Label:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
            Label:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
            Label:SetHeight(self.constants.sizes.row)
            Label.Icon = Label:CreateTexture(Label:GetName() .. "Icon", "ARTWORK")
            Label.Icon:SetSize(16, 16)
            Label.Icon:SetPoint("LEFT", Label:GetName(), "LEFT", self.constants.sizes.padding, 0)
            Label.Icon:SetTexture(dungeon.icon)
            Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
            Label.Text:SetPoint("TOPLEFT", Label:GetName(), "TOPLEFT", 16 + self.constants.sizes.padding * 2, -3)
            Label.Text:SetPoint("BOTTOMRIGHT", Label:GetName(), "BOTTOMRIGHT", -self.constants.sizes.padding, 3)
            Label.Text:SetJustifyH("LEFT")
            Label.Text:SetFontObject("GameFontHighlight_NoShadow")
            Label.Text:SetText(dungeon.short and dungeon.short or dungeon.name)
            anchorFrame = Label
        end
    end

    do -- Raids & Difficulties
        for raidIndex, raid in ipairs(raids) do
            local RaidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, winMain.Body.Sidebar)
            RaidFrame:SetHeight(self.constants.sizes.row)
            RaidFrame:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
            RaidFrame:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
            RaidFrame:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(RaidFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText(raid.name, 1, 1, 1);
                GameTooltip:Show()
            end)
            RaidFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
            RaidFrame.Text = RaidFrame:CreateFontString(RaidFrame:GetName() .. "Text", "OVERLAY")
            RaidFrame.Text:SetPoint("TOPLEFT", RaidFrame, "TOPLEFT", self.constants.sizes.padding, 0)
            RaidFrame.Text:SetPoint("BOTTOMRIGHT", RaidFrame, "BOTTOMRIGHT", -self.constants.sizes.padding, 0)
            RaidFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
            RaidFrame.Text:SetJustifyH("LEFT")
            RaidFrame.Text:SetText(raid.short and raid.short or raid.name)
            RaidFrame.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
            anchorFrame = RaidFrame

            for difficultyIndex, difficulty in ipairs(difficulties) do
                local DifficultFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, RaidFrame)
                DifficultFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                DifficultFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                DifficultFrame:SetHeight(self.constants.sizes.row)
                DifficultFrame:SetScript("OnEnter", function()
                    GameTooltip:ClearAllPoints()
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(DifficultFrame, "ANCHOR_RIGHT")
                    GameTooltip:SetText(difficulty.name, 1, 1, 1);
                    GameTooltip:Show()
                end)
                DifficultFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
                DifficultFrame.Text = DifficultFrame:CreateFontString(DifficultFrame:GetName() .. "Text", "OVERLAY")
                DifficultFrame.Text:SetPoint("TOPLEFT", DifficultFrame, "TOPLEFT", self.constants.sizes.padding, -3)
                DifficultFrame.Text:SetPoint("BOTTOMRIGHT", DifficultFrame, "BOTTOMRIGHT", -self.constants.sizes.padding, 3)
                DifficultFrame.Text:SetJustifyH("LEFT")
                DifficultFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
                DifficultFrame.Text:SetText(difficulty.short and difficulty.short or difficulty.name)
                -- RaidLabel.Icon = RaidLabel:CreateTexture(RaidLabel:GetName() .. "Icon", "ARTWORK")
                -- RaidLabel.Icon:SetSize(16, 16)
                -- RaidLabel.Icon:SetPoint("LEFT", RaidLabel, "LEFT", self.constants.sizes.padding, 0)
                -- RaidLabel.Icon:SetTexture(raid.icon)
                anchorFrame = DifficultFrame
            end
        end
    end

    winMain.Body.ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", winMain.Body)
    winMain.Body.ScrollFrame:SetPoint("TOPLEFT", winMain.Body, "TOPLEFT", self.constants.sizes.sidebar.width, 0)
    winMain.Body.ScrollFrame:SetPoint("BOTTOMLEFT", winMain.Body, "BOTTOMLEFT", self.constants.sizes.sidebar.width, 0)
    winMain.Body.ScrollFrame:SetPoint("BOTTOMRIGHT", winMain.Body, "BOTTOMRIGHT")
    winMain.Body.ScrollFrame:SetPoint("TOPRIGHT", winMain.Body, "TOPRIGHT")
    winMain.Body.ScrollFrame.ScrollChild = CreateFrame("Frame", "$parentScrollChild", winMain.Body.ScrollFrame)
    winMain.Body.ScrollFrame:SetScrollChild(winMain.Body.ScrollFrame.ScrollChild)

    winMain.Footer = CreateFrame("Frame", "$parentFooter", winMain)
    winMain.Footer:SetHeight(self.constants.sizes.footer.height)
    winMain.Footer:SetPoint("BOTTOMLEFT", winMain, "BOTTOMLEFT")
    winMain.Footer:SetPoint("BOTTOMRIGHT", winMain, "BOTTOMRIGHT")
    self:SetBackgroundColor(winMain.Footer, 0, 0, 0, .3)

    winMain.Footer.Scrollbar = CreateFrame("Slider", "$parentScrollbar", winMain.Footer, "UISliderTemplate")
    winMain.Footer.Scrollbar:SetPoint("TOPLEFT", winMain.Footer, "TOPLEFT", self.constants.sizes.sidebar.width, 0)
    winMain.Footer.Scrollbar:SetPoint("BOTTOMRIGHT", winMain.Footer, "BOTTOMRIGHT", -self.constants.sizes.padding / 2, 0)
    winMain.Footer.Scrollbar:SetMinMaxValues(0, 100)
    winMain.Footer.Scrollbar:SetValue(0)
    winMain.Footer.Scrollbar:SetValueStep(1)
    winMain.Footer.Scrollbar:SetOrientation("HORIZONTAL")
    winMain.Footer.Scrollbar:SetObeyStepOnDrag(true)
    winMain.Footer.Scrollbar.NineSlice:Hide()
    winMain.Footer.Scrollbar.thumb = winMain.Footer.Scrollbar:GetThumbTexture()
    winMain.Footer.Scrollbar.thumb:SetPoint("CENTER")
    winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
    winMain.Footer.Scrollbar.thumb:SetHeight(self.constants.sizes.footer.height - 10)
    winMain.Footer.Scrollbar:SetScript("OnValueChanged", function(_, value)
        winMain.Body.ScrollFrame:SetHorizontalScroll(value)
    end)
    winMain.Footer.Scrollbar:SetScript("OnEnter", function()
        winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.2)
    end)
    winMain.Footer.Scrollbar:SetScript("OnLeave", function()
        winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
    end)
    winMain.Body.ScrollFrame:SetScript("OnMouseWheel", function(_, delta)
        winMain.Footer.Scrollbar:SetValue(winMain.Footer.Scrollbar:GetValue() - delta * ((winMain.Body.ScrollFrame.ScrollChild:GetWidth() - winMain.Body.ScrollFrame:GetWidth()) * 0.1))
    end)

    winMain.Body:SetPoint("BOTTOMLEFT", winMain.Footer, "TOPLEFT")
    winMain.Body:SetPoint("BOTTOMRIGHT", winMain.Footer, "TOPRIGHT")
    self:UpdateUI()
end

function AlterEgo:UpdateUI()
    local winMain = self:GetWindow("Main")
    if not winMain then return end

    local affixes = self:GetAffixes(true)
    local characters = self:GetCharacters()
    local numCharacters = AE_table_count(self:GetCharacters())
    local charactersUnfiltered = self:GetCharacters(true)
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()
    local labels = self:GetCharacterInfo()
    local anchorFrame

    if numCharacters == 0 then
        winMain.Body.Sidebar:Hide()
        winMain.Body.ScrollFrame:Hide()
        winMain.Footer:Hide()
        winMain.Body.NoCharacterText:Show()
    else
        winMain.Body.Sidebar:Show()
        winMain.Body.ScrollFrame:Show()
        winMain.Footer:Show()
        winMain.Body.NoCharacterText:Hide()
    end

    winMain:SetSize(self:GetWindowSize())
    winMain:SetScale(self.db.global.interface.windowScale / 100)
    winMain.Body.ScrollFrame.ScrollChild:SetSize(numCharacters * self.constants.sizes.column, winMain.Body.ScrollFrame:GetHeight())
    self:SetBackgroundColor(winMain, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)

    if self:IsScrollbarNeeded() then
        winMain.Footer.Scrollbar:SetMinMaxValues(0, winMain.Body.ScrollFrame.ScrollChild:GetWidth() - winMain.Body.ScrollFrame:GetWidth())
        winMain.Footer.Scrollbar.thumb:SetWidth(winMain.Footer.Scrollbar:GetWidth() / 10)
        winMain.Body:SetPoint("BOTTOMLEFT", winMain.Footer, "TOPLEFT")
        winMain.Body:SetPoint("BOTTOMRIGHT", winMain.Footer, "TOPRIGHT")
        winMain.Footer:Show()
    else
        winMain.Body.ScrollFrame:SetHorizontalScroll(0)
        winMain.Body:SetPoint("BOTTOMLEFT", winMain, "BOTTOMLEFT")
        winMain.Body:SetPoint("BOTTOMRIGHT", winMain, "BOTTOMRIGHT")
        winMain.Footer:Hide()
    end

    local currentAffixes = C_MythicPlus.GetCurrentAffixes();
    anchorFrame = winMain.TitleBar
    for i = 1, 3 do
        local affixButton = _G[winMain.TitleBar.Affixes:GetName() .. i]
        if affixButton then
            if currentAffixes then
                local name, desc, fileDataID = C_ChallengeMode.GetAffixInfo(currentAffixes[i].id);
                affixButton:SetNormalTexture(fileDataID)
                affixButton:SetScript("OnEnter", function()
                    GameTooltip:ClearAllPoints()
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(affixButton, "ANCHOR_TOP")
                    GameTooltip:SetText(name, 1, 1, 1);
                    GameTooltip:AddLine(desc, nil, nil, nil, true)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("<Click to View Weekly Affixes>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                    GameTooltip:Show()
                end)
                affixButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end
            if i == 1 then
                affixButton:ClearAllPoints()
                if numCharacters == 1 then
                    affixButton:SetPoint("LEFT", winMain.TitleBar.Icon, "RIGHT", 6, 0)
                    winMain.TitleBar.Text:Hide()
                else
                    affixButton:SetPoint("CENTER", anchorFrame, "CENTER", -26, 0)
                    winMain.TitleBar.Text:Show()
                end
            else
                affixButton:SetPoint("LEFT", anchorFrame, "RIGHT", 6, 0)
            end
            if self.db.global.showAffixHeader then
                affixButton:Show()
            else
                affixButton:Hide()
            end
            anchorFrame = affixButton
        end
    end

    self:HideCharacterColumns()

    do -- Character Labels
        anchorFrame = winMain.Body.Sidebar
        for labelIndex, info in ipairs(labels) do
            local Label = _G[winMain.Body.Sidebar:GetName() .. "Label" .. labelIndex]
            if info.enabled ~= nil and not info.enabled then
                Label:Hide()
            else
                if labelIndex > 1 then
                    Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                    Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                else
                    Label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                    Label:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
                end
                Label:Show()
                anchorFrame = Label
            end
        end
    end

    do -- MythicPlus Label
        -- local Label = _G[winMain.Body.Sidebar:GetName() .. "MythicPlusLabel"]
        -- if Label then
        -- end
    end

    do -- Dungeon Labels
        for dungeonIndex, dungeon in ipairs(dungeons) do
            local Label = _G[winMain.Body.Sidebar:GetName() .. "Dungeon" .. dungeonIndex]
            Label.Icon:SetTexture(dungeon.icon)
            Label.Text:SetText(dungeon.short and dungeon.short or dungeon.name)
            Label.Icon:SetTexture(tostring(dungeon.texture))
            if dungeon.spellID and IsSpellKnown(dungeon.spellID) and not InCombatLockdown() then
                Label:SetAttribute("type", "spell")
                Label:SetAttribute("spell", dungeon.spellID)
                Label:RegisterForClicks("AnyUp", "AnyDown")
                Label:EnableMouse(true)
            end
            Label:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(Label, "ANCHOR_RIGHT")
                GameTooltip:SetText(dungeon.name, 1, 1, 1);
                if dungeon.spellID then
                    if IsSpellKnown(dungeon.spellID) then
                        GameTooltip:ClearLines()
                        GameTooltip:SetSpellByID(dungeon.spellID)
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("<Click to Teleport>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                        _G[GameTooltip:GetName() .. "TextLeft1"]:SetText(dungeon.name)
                    else
                        GameTooltip:AddLine("Time this dungeon on level 20 or above to unlock teleportation.", nil, nil, nil, true)
                    end
                end
                GameTooltip:Show()
            end)
            Label:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
    end

    do -- Raids & Difficulties
        for raidIndex in ipairs(raids) do
            local Label = _G[winMain.Body.Sidebar:GetName() .. "Raid" .. raidIndex]
            if self.db.global.raids.enabled then
                Label:Show()
            else
                Label:Hide()
            end
            -- for difficultyIndex, difficulty in ipairs(difficulties) do
            --     local DifficultFrame = _G[Label:GetName() .. "Difficulty" .. difficultyIndex]
            --     if DifficultFrame then
            --     end
            -- end
        end
    end

    do -- Characters
        anchorFrame = winMain.Body.ScrollFrame.ScrollChild
        for characterIndex, character in ipairs(characters) do
            local CharacterColumn = self:GetCharacterColumn(winMain.Body.ScrollFrame.ScrollChild, characterIndex)
            if characterIndex > 1 then
                CharacterColumn:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT")
                CharacterColumn:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT")
            else
                CharacterColumn:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                CharacterColumn:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMLEFT")
            end
            self:SetBackgroundColor(CharacterColumn, 1, 1, 1, characterIndex % 2 == 0 and 0.01 or 0)
            anchorFrame = CharacterColumn

            do -- Character info
                anchorFrame = CharacterColumn
                for labelIndex, info in ipairs(labels) do
                    local CharacterFrame = _G[CharacterColumn:GetName() .. "Info" .. labelIndex]
                    CharacterFrame.Text:SetText(info.value(character))
                    if info.OnEnter then
                        CharacterFrame:SetScript("OnEnter", function()
                            GameTooltip:ClearAllPoints()
                            GameTooltip:ClearLines()
                            GameTooltip:SetOwner(CharacterFrame, "ANCHOR_RIGHT")
                            info.OnEnter(character)
                            GameTooltip:Show()
                            if not info.backgroundColor then
                                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0.05)
                            end
                        end)
                        CharacterFrame:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                            if not info.backgroundColor then
                                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0)
                            end
                        end)
                    else
                        if not info.backgroundColor then
                            CharacterFrame:SetScript("OnEnter", function()
                                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0.05)
                            end)
                            CharacterFrame:SetScript("OnLeave", function()
                                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0)
                            end)
                        end
                    end
                    if info.OnClick then
                        CharacterFrame:SetScript("OnClick", function()
                            info.OnClick(character)
                        end)
                    end
                    if info.enabled ~= nil and not info.enabled then
                        CharacterFrame:Hide()
                    else
                        if labelIndex > 1 then
                            CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                            CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                        else
                            CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                            CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
                        end
                        anchorFrame = CharacterFrame
                        CharacterFrame:Show()
                    end
                end
            end

            do -- Dungeon rows
                -- Todo: Look into C_ChallengeMode.GetKeystoneLevelRarityColor(level)
                for dungeonIndex, dungeon in ipairs(dungeons) do
                    local DungeonFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. dungeonIndex]
                    local characterDungeon = AE_table_get(character.mythicplus.dungeons, "challengeModeID", dungeon.challengeModeID)
                    local scoreColor = HIGHLIGHT_FONT_COLOR
                    if characterDungeon and characterDungeon.affixScores and AE_table_count(characterDungeon.affixScores) > 0 then
                        if (characterDungeon.rating) then
                            local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(characterDungeon.rating);
                            if color then
                                scoreColor = color
                            end
                        end
                    end
                    DungeonFrame:SetScript("OnEnter", function()
                        GameTooltip:ClearAllPoints()
                        GameTooltip:ClearLines()
                        GameTooltip:SetOwner(DungeonFrame, "ANCHOR_RIGHT")
                        GameTooltip:SetText(dungeon.name, 1, 1, 1);
                        if characterDungeon and characterDungeon.affixScores and AE_table_count(characterDungeon.affixScores) > 0 then
                            if (characterDungeon.rating) then
                                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(scoreColor:WrapTextInColorCode(characterDungeon.rating)), GREEN_FONT_COLOR);
                            end
                            for _, affixInfo in ipairs(characterDungeon.affixScores) do
                                GameTooltip_AddBlankLineToTooltip(GameTooltip);
                                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_BEST_AFFIX:format(affixInfo.name));
                                GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(affixInfo.level), HIGHLIGHT_FONT_COLOR);
                                if (affixInfo.overTime) then
                                    if (affixInfo.durationSec >= SECONDS_PER_HOUR) then
                                        GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, true)), LIGHTGRAY_FONT_COLOR);
                                    else
                                        GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, false)), LIGHTGRAY_FONT_COLOR);
                                    end
                                else
                                    if (affixInfo.durationSec >= SECONDS_PER_HOUR) then
                                        GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, true), HIGHLIGHT_FONT_COLOR);
                                    else
                                        GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, false), HIGHLIGHT_FONT_COLOR);
                                    end
                                end
                            end
                        end
                        GameTooltip:Show()
                        self:SetBackgroundColor(DungeonFrame, 1, 1, 1, 0.05)
                    end)
                    DungeonFrame:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                        self:SetBackgroundColor(DungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
                    end)

                    for affixIndex, affix in ipairs(affixes) do
                        local AffixFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. dungeonIndex .. "Affix" .. affixIndex]
                        if AffixFrame then
                            local level = "-"
                            local levelColor = "ffffffff"
                            local tier = ""

                            if characterDungeon == nil or characterDungeon.affixScores == nil then
                                level = "-"
                                levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                            else
                                for _, affixScore in ipairs(characterDungeon.affixScores) do
                                    if affixScore.name == affix.name then
                                        level = affixScore.level

                                        if affixScore.durationSec <= dungeon.time * 0.6 then
                                            tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a"
                                        elseif affixScore.durationSec <= dungeon.time * 0.8 then
                                            tier = "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a"
                                        elseif affixScore.durationSec <= dungeon.time then
                                            tier = "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:-1|a"
                                        end

                                        if tier == "" then
                                            levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                                        elseif self.db.global.showAffixColors then
                                            levelColor = scoreColor:GenerateHexColor()
                                        end
                                    end
                                end
                            end

                            AffixFrame.Text:SetText("|c" .. levelColor .. level .. "|r")
                            AffixFrame.Tier:SetText(tier)
                            if self.db.global.showTiers then
                                AffixFrame.Text:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOM", -1, 1)
                                AffixFrame.Text:SetJustifyH("RIGHT")
                                AffixFrame.Tier:Show()
                            else
                                AffixFrame.Text:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOMRIGHT", -1, 1)
                                AffixFrame.Text:SetJustifyH("CENTER")
                                AffixFrame.Tier:Hide()
                            end
                        end
                    end
                end
            end

            do -- Raid Rows
                for raidIndex, raid in ipairs(raids) do
                    local RaidFrame = _G[CharacterColumn:GetName() .. "Raid" .. raidIndex]
                    if self.db.global.raids.enabled then
                        RaidFrame:Show()
                    else
                        RaidFrame:Hide()
                    end
                    for difficultyIndex, difficulty in pairs(difficulties) do
                        local DifficultyFrame = _G[RaidFrame:GetName() .. "Difficulty" .. difficultyIndex]
                        DifficultyFrame:SetScript("OnEnter", function()
                            GameTooltip:ClearAllPoints()
                            GameTooltip:ClearLines()
                            GameTooltip:SetOwner(DifficultyFrame, "ANCHOR_RIGHT")
                            GameTooltip:SetText("Raid Progress", 1, 1, 1, 1, true);
                            GameTooltip:AddLine(format("Difficulty: |cffffffff%s|r", difficulty.short and difficulty.short or difficulty.name));
                            if character.raids.savedInstances ~= nil then
                                local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                                    return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                                end)
                                if savedInstance ~= nil then
                                    GameTooltip:AddLine(format("Expires: |cffffffff%s|r", date("%c", savedInstance.expires)))
                                end
                            end
                            GameTooltip:AddLine(" ")
                            for _, encounter in ipairs(raid.encounters) do
                                local color = LIGHTGRAY_FONT_COLOR
                                if character.raids.savedInstances then
                                    local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                                        return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                                    end)
                                    if savedInstance ~= nil then
                                        local savedEncounter = AE_table_find(savedInstance.encounters, function(enc)
                                            return enc.instanceEncounterID == encounter.instanceEncounterID and enc.killed == true
                                        end)
                                        if savedEncounter ~= nil then
                                            color = GREEN_FONT_COLOR
                                        end
                                    end
                                end
                                GameTooltip:AddLine(WrapTextInColorCode(encounter.name, color:GenerateHexColor()))
                            end
                            GameTooltip:Show()
                            self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, 0.05)
                        end)
                        DifficultyFrame:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                            self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, 0)
                        end)
                        anchorFrame = DifficultyFrame
                        for encounterIndex, encounter in ipairs(raid.encounters) do
                            local color = {r = 1, g = 1, b = 1}
                            local alpha = 0.1
                            local EncounterFrame = _G[DifficultyFrame:GetName() .. "Encounter" .. encounterIndex]
                            if not EncounterFrame then
                                EncounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, DifficultyFrame)
                                local size = self.constants.sizes.column
                                size = size - self.constants.sizes.padding -- left/right cell padding
                                size = size - (raid.numEncounters - 1) * 4 -- gaps
                                size = size / raid.numEncounters           -- box sizes
                                EncounterFrame:SetPoint("LEFT", anchorFrame, encounterIndex > 1 and "RIGHT" or "LEFT", self.constants.sizes.padding / 2, 0)
                                EncounterFrame:SetSize(size, self.constants.sizes.row - 12)
                                self:SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
                                anchorFrame = EncounterFrame
                            end
                            if character.raids.savedInstances then
                                local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                                    return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                                end)
                                if savedInstance ~= nil then
                                    local savedEncounter = AE_table_find(savedInstance.encounters, function(enc)
                                        return enc.instanceEncounterID == encounter.instanceEncounterID and enc.killed == true
                                    end)
                                    if savedEncounter ~= nil then
                                        color = UNCOMMON_GREEN_COLOR
                                        if self.db.global.raids.colors then
                                            color = difficulty.color
                                        end
                                        alpha = 0.5
                                    end
                                end
                            end
                            self:SetBackgroundColor(EncounterFrame, color.r, color.g, color.b, alpha)
                        end
                        anchorFrame = CharacterColumn
                    end
                end
            end
            anchorFrame = CharacterColumn
        end
    end
end