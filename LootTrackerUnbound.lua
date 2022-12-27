SLASH_LTU1 = '/ltu'

--Fenetre globale
f = CreateFrame("Frame")
mainRollsEntry = {}
secondRollsEntry = {}
listItems = {}
RollNumber = {}
local booleanIsOpen =false

function Init()
    addonName = GetAddOnMetadata("LootTrackerUnbound", "Title")
    LootTrackerUnbound.LootTrackerUnbound_LootsDB = _G["LootTrackerUnbound_LootsDB"] or {}
    LootTrackerUnbound.LootTrackerUnbound_SessionHistory = _G["LootTrackerUnbound_SessionHistory"] or {}
    LootTrackerUnbound.LootTrackerUnboundDB = _G["LootTrackerUnbound.LootTrackerUnboundDB"] or {}
end

local function Event_ADDON_LOADED(self,event,addon)
    -- vérifie si l'addon est bien LootTrackerUnbound
    if addon == TOCNAME then
        Init()
        -- addon loaded
        local libDataBroker = LibStub:GetLibrary("LibDataBroker-1.1")
       -- libClassicSpecs = LibStub:GetLibrary("LibClassicSpecs")

        local miniButton = libDataBroker:NewDataObject("LootTrackerUnbound", {

            type = "data source",

            text = "LootTrackerUnbound",

            icon = "Interface\\Icons\\Inv_ingot_03",

            OnClick = function(self, btn)

                if btn == "LeftButton" then

                    SlashCmdList["LTU"]("ltu")
                elseif btn == "RightButton" then

                    -- utilise la commande /ltu
                    SlashCmdList["LTU"]("help")

                end

            end,

            OnTooltipShow = function(tooltip)

                if not tooltip or not tooltip.AddLine then return end

                tooltip:AddLine("LootTrackerUnbound")
                tooltip:AddLine(WrapTextInColorCode("Clic gauche ","ffffd700")..WrapTextInColorCode("pour afficher/masquer la fenêtre","ff00ff00"))
                tooltip:AddLine(WrapTextInColorCode("Clic droit ","ffffd700")..WrapTextInColorCode("pour afficher les commandes","ff00ff00"))

            end,

        })
        local icon = LibStub("LibDBIcon-1.0")

        icon:Register("LootTrackerUnbound", miniButton, LootTrackerUnboundDB)
        LootTrackerUnboundDB["hide"] = false
        icon:Show("LootTrackerUnbound")
    end

end
local frame = CreateFrame("Frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", Event_ADDON_LOADED)

function LTU_Command(msg)
    if msg == "announce" then
        announceWinner()
    elseif msg == "loots" then
        announceLoots()
    elseif msg == "start" then
        rollStart()
    elseif string.match(msg, "resetroll (.+)") then
        local name = string.match(msg, "resetroll (.+)")
        resetRollPlayer(name)
    elseif msg == "rules" then
        announceRules()
    elseif msg == "history" then
        showLootsHistory()
    elseif msg == "help" then

        print("LootTrackerUnbound Version 1.0.0 by Datyb")
        print("LootTrackerUnbound: /ltu announce - Announce the winner")
        print("LootTrackerUnbound: /ltu loots - Announce the loots")
        print("LootTrackerUnbound: /ltu start - Start the roll")
        print("LootTrackerUnbound: /ltu resetroll <name> - Reset the roll of a player")
        print("LootTrackerUnbound: /ltu rules - Announce the rules")
        print("LootTrackerUnbound: /ltu history - Show the loots history")
        print("LootTrackerUnbound: /ltu reset history - Reset the loots history")
    elseif msg == "reset history" then
        resetLootsHistory()
    else
        ToggleWindow()
    end
end
SlashCmdList["LTU"] = LTU_Command

RollTrackerUnbound = LTU
Version = GetAddOnMetadata(TOCNAME, "Version")
Title = GetAddOnMetadata(TOCNAME, "Title")


loot = {}
-- Création de la fenetre
window = CreateFrame("Frame", "LootTrackerUnbound", UIParent,"BasicFrameTemplateWithInset")

window:SetSize(680, 300)
window:SetPoint("CENTER")
window:SetMovable(true)
window:EnableMouse(true)
window:RegisterForDrag("LeftButton")
window:SetScript("OnDragStart", window.StartMoving)
window:SetScript("OnDragStop", window.StopMovingOrSizing)

window.title = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
window.title:SetPoint("TOP", window, "TOP", 0, -5)
window.title:SetText("LootTrackerUnbound")

itemList1Height = 50
itemList2Height = 50
itemList3Height = 50

contentHeight = 220
-- La zone du milieu
-- Crée le frame de type ScrollFrame
local scrollFrame = CreateFrame("ScrollFrame", "MyScrollFrame", window, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(630, 220)
scrollFrame:SetPoint("TOPLEFT", window, "TOPLEFT", 10, -30)
local content = CreateFrame("Frame", "MyContentFrame", scrollFrame)
content:SetSize(630, scrollFrame:GetHeight())
scrollFrame:SetScrollChild(content)

list1 = CreateFrame("Frame", "MyList1", content)
list1:SetSize(630, 20)
list1:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)

list2 = CreateFrame("Frame", "MyList2", content)
list2:SetPoint("TOPLEFT", list1, "TOPLEFT", 0, -20)

list2:SetSize(630, 20)

list3 = CreateFrame("Frame", "MyList3", content)
list3:SetPoint("TOPLEFT", list2, "TOPLEFT", 0, -20)
list3:SetSize(630, 20)
lists = {list1, list2, list3}
listsButton = {}
listsOrderText ={}
buttons = {}
lists[1].title = lists[1]:CreateFontString("Titre liste 1", "OVERLAY", "GameFontNormal")
lists[1].title:SetText("Personne(s) qui +1")
lists[1].title:SetPoint("TOPLEFT", list1, "TOPLEFT", 0, 0)
table.insert(lists[1], lists[1].title)
lists[2].title = lists[2]:CreateFontString("Titre liste 2", "OVERLAY", "GameFontNormal")
lists[2].title:SetText("Personne(s) qui +1 DL ")
lists[2].title:SetPoint("TOPLEFT", list2, "TOPLEFT", 0, 0)
table.insert(lists[2], lists[2].title)

lists[3].title = lists[3]:CreateFontString("Titre liste 3", "OVERLAY", "GameFontNormal")
lists[3].title:SetText("Personne(s) qui +2 ")
lists[3].title:SetPoint("TOPLEFT", list3, "TOPLEFT", 0, 0)
table.insert(lists[3], lists[3].title)

--Les boutons------------------------------------------------
local btnResetHistory = CreateFrame("Button", "MyButtonResetHistory", window, "UIPanelButtonTemplate")
local btnResetHistoryText = "Reset History"
btnResetHistory:SetPoint("BOTTOMLEFT", 20, 30)
btnResetHistory:SetSize(200, 20)
btnResetHistory:SetText(btnResetHistoryText)

local btnHistory = CreateFrame("Button", "HistoryButton", window, "UIPanelButtonTemplate")
local btnHistoryText = "Historique"
btnHistory:SetSize(200, 20)
btnHistory:SetPoint("LEFT",btnResetHistory,"RIGHT", 10, 0)
btnHistory:SetText(btnHistoryText)

local btnResetRoll = CreateFrame("Button", "HistoryButton", window, "UIPanelButtonTemplate")
local btnResetRollText = "Reset Rolls"
btnResetRoll:SetSize(200, 20)
btnResetRoll:SetPoint("LEFT",btnHistory,"RIGHT", 10, 0)
btnResetRoll:SetText(btnResetRollText)

local btnAnnounceLoot = CreateFrame("Button", "AnnounceLootButton", window, "UIPanelButtonTemplate")
local btnAnnounceLootText = "Annoncer loots"
btnAnnounceLoot:SetSize(200, 20)
btnAnnounceLoot:SetPoint("TOP",btnResetHistory,"BOTTOM", 0, 0)
btnAnnounceLoot:SetText(btnAnnounceLootText)

local btnAnnounceWinner = CreateFrame("Button", "AnnounceWinnerButton", window, "UIPanelButtonTemplate")
local btnAnnounceWinnerText = "Annoncer gagnant"
btnAnnounceWinner:SetSize(200, 20)
btnAnnounceWinner:SetPoint("LEFT",btnAnnounceLoot,"RIGHT", 10, 0)
btnAnnounceWinner:SetText(btnAnnounceWinnerText)

local btnStart = CreateFrame("Button", "StartButton", window, "UIPanelButtonTemplate")
local btnStartText = "Démarrer"
btnStart:SetSize(200, 20)
btnStart:SetPoint("LEFT",btnAnnounceWinner,"RIGHT", 10, 0)
btnStart:SetText(btnStartText)



btnAnnounceLoot:SetScript("OnClick", function(self)
    -- Code à exécuter lorsque le bouton "btnAnnounceLoot" est cliqué
    announceLoots()
end)

btnAnnounceWinner:SetScript("OnClick", function(self)
    -- Code à exécuter lorsque le bouton "btnAnnounceWinner" est cliqué
    announceWinner()
end)

btnStart:SetScript("OnClick", function(self)
    -- Code à exécuter lorsque le bouton "btnStart" est cliqué
    rollStart()
end)

btnHistory:SetScript("OnClick", function(self)
    -- Code à exécuter lorsque le bouton "btnHistory" est cliqué
    showLootsHistory()
end)
globalBoolean = false
btnResetHistory:SetScript("OnClick", function(self)
    -- Code à exécuter lorsque le bouton "btnResetHistory" est cliqué
    ShowConfirmationPopup(resetLootsHistory)

end)

btnResetRoll:SetScript("OnClick", function(self)
    -- Code à exécuter lorsque le bouton "btnResetRoll" est cliqué
    --ShowConfirmationPopup(resetRolls)
    popupResetRolls()
end)
-- When close window is clicked
window:SetScript("OnHide", function(self)
booleanIsOpen = false
end)


window:Hide()
-- Fin de création de la fenetre


-- Créez une fonction pour déplacer tous les widgets enfants de la liste vers le bas
function ShiftListDown(list, listTitle, os)
    local offset = 0

    if list == lists[1] then
        offset = os or 0
    else
        local point, relativeTo, relativePoint, xOfs, yOfs = listTitle:GetPoint()
        offset = os or 0 + yOfs
    end
    for _, child in ipairs(list) do
        child:SetPoint("TOPLEFT", list, "TOPLEFT", 0, offset)
            offset = offset - child:GetHeight()
    end

    return offset
end

-- Créez une fonction pour déplacer tous les widgets enfants de la liste vers le haut
function ShiftListUp(list, listTitle, os)
    local offset = 0

    if list == lists[1] then
        offset = os or 0
    else
        local point, relativeTo, relativePoint, xOfs, yOfs = listTitle:GetPoint()
        offset = os or 0 - yOfs
    end
    for _, child in ipairs(list) do
        child:SetPoint("TOPLEFT", list, "TOPLEFT", 0, offset)
        offset = offset + child:GetHeight()
    end
    return offset
end
function deleteButtonHandler(author, posText,posButton)
    return function(self, link, text, button)
        resetRollPlayer(author, self, posText,posButton)
    end
end
-- Créez une fonction pour ajouter une ligne à une liste donnée et déplacer les widgets enfants des autres listes vers le bas
function AddLineToListAndShiftOthers(list, lineText,ListNb,author)
    -- Ajouter la ligne à la liste donnée
    local fontString = list:CreateFontString("TextdeRoll", "OVERLAY", "GameFontNormal")

    fontString:SetText(lineText)
    fontString:SetPoint("TOPLEFT", list, "TOPLEFT", 0, 0)
    local icon = CreateFrame("Button", "Icone", list)
    icon:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    icon:SetSize(15, 15)
    icon:SetPoint("LEFT", fontString, "RIGHT")

    table.insert(list, fontString)
    table.insert(listsOrderText,#list)
    table.insert(listsButton,icon)

    icon:SetScript("OnClick", deleteButtonHandler(author, #list,#listsButton))
    -- Positionnez l'icône de suppression à côté de l'élément de texte cliquable
    --deleteIcon:SetPoint("LEFT", textLink, "RIGHT", 5, 0)
    -- Ajouter le widget enfant au tableau list


    -- Déplacer les widgets enfants des autres listes vers le bas



    local offset = ShiftListDown(list, list.title)
    local iterator = 1
    for i, otherList in ipairs(lists) do
        if(iterator>=ListNb) then
            if otherList ~= list then
                offset = ShiftListDown(otherList, otherList.title, offset)
            end
        end
        iterator = iterator + 1
    end
end

-- Créez une fonction pour supprimer tous les widgets enfants de la liste (hors titre de liste) et déplacer les widgets enfants des autres listes vers le haut
function RemoveAllLinesFromListAndShiftOthers(list,listNb)
    -- Supprimer tous les widgets enfants de la liste (hors titre de liste)
    for _,val in ipairs(list) do

        for i = 2, #val, 1 do
            val[i]:Hide()
            val[i] = nil

        end
        for i = 1, #listsButton, 1 do
            listsButton[i]:Hide()
            listsButton[i] = nil
        end
        -- Déplacer les widgets enfants des autres listes vers le haut
        local offset = ShiftListUp(val, val.title)
        local iterator = 1
        for i, otherList in ipairs(lists) do
            if(iterator>=listNb) then
                if otherList ~= list then
                    offset = ShiftListUp(otherList, otherList.title, offset)
                end
            end
            iterator = iterator + 1
        end
    end
end
function RemoveLineFromListAndShiftOthers(list,listNb,posText,posButton)
    list[posText]:Hide()
    list[posText] = nil
    listsButton[posButton]:Hide()
    listsButton[posButton] = nil
    -- Déplacer les widgets enfants des autres listes vers le haut
    local offset = ShiftListUp(list, list.title)
    local iterator = 1
    for i, otherList in ipairs(lists) do
        if(iterator>=listNb) then
            if otherList ~= list then
                offset = ShiftListDown(otherList, otherList.title, offset)
            end
        end
        iterator = iterator + 1
    end
end
function ToggleWindow()
    if window:IsShown() then
        window:Hide()
    else
        window:Show()
    end
end
--Fonction qui enregistre les loots
function getLoot()
    local mobName = UnitName("target")
    local nbMaxLoot = GetNumLootItems()
    local iterator = 1
    for i = 1, nbMaxLoot do
        if GetLootSlotLink(i) ~= nil then
            loot[iterator] = GetLootSlotLink(i)
            iterator = iterator + 1
        end
    end

end

function announceRules()
    table_text ={}
    table_text[1] = "Bienvenue dans le raid des Unbound !"
    table_text[2] = "Les règles de loot sont simples :"
    table_text[3] = "1. +1 / +1 DL / +2"
    table_text[4] = "2. Les loots BiS seront priorisés"
    table_text[5] = "3. Si vous needez un loot en +1, vous lancez un /rand 100"
    table_text[6] = "4. Si vous needez un loot en +2, vous lancez un /rand 50"
    sendInChat(table_text[1])
    local iterator = 2
    C_Timer.NewTicker(3,function(self)
        sendInChat(table_text[iterator])
        iterator = iterator + 1
        if iterator > 6 then
            self:Cancel()
        end
    end)


end

function announceLoots()
    if loot[1] == nil then
        print("LootTrackerUnbound: Il n'y a aucun loot d'enregistré.")
    else
        sendInChat("Liste du butin :")
        for i,value in pairs(loot) do
            sendInChat("["..i.."] -> "..value)
        end
    end

end

--Fonction qui définit le canal de chat
function sendInChat(message)
    --Si en raid
    if IsInRaid() then
        --Si assitant raid ou raid leader
        if UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") then
            SendChatMessage(message, "RAID_WARNING")
        else
            SendChatMessage(message, "RAID")
        end
    elseif IsInGroup() then
        SendChatMessage(message, "PARTY")
    else
        SendChatMessage(message, "SAY")
    end
end

-- Fonction qui définit le début des lancés de dés
mainRolls ={}
SecondaryRolls = {}
thirdRolls = {}
function rollStart()
    if loot[1] == nil then
        print("LootTrackerUnbound: Aucun loot enregistré")
    else

        sendInChat("Lancement de dés pour "..loot[1].." ! Si vous needez en +1 faites un /rand, si c'est pour votre 2nd spé faites /rand 50")
        f:RegisterEvent("CHAT_MSG_SYSTEM")
        f:SetScript("OnEvent",addRolls)
    end

end

-- Récupère la liste des joueurs
function GetPlayerList(unsort)
    local count, start
    local prefix
    local ret = {}
    local retName = {}

    if IsInRaid() then
        prefix = "raid"
        count = MAX_RAID_MEMBERS
        start = 1
    else
        prefix = "party"
        count = MAX_PARTY_MEMBERS
        start = 0
    end

    for index = start, count do
        local guildName, guildRankName
        local id
        if index > 0 then
            id = prefix .. index
        else
            id = "player"
        end
        local name = GetUnitName(id)
        local _, englishClass = UnitClass(id)

        local rank = ""
        if IsInGuild() and UnitIsInMyGuild(id) then
            rank = "<" ..
                    GuildControlGetRankName(
                            C_GuildInfo.GetGuildRankOrder(UnitGUID(id))) .. ">"
        else
            guildName, guildRankName = GetGuildInfo(id)
            if guildName and guildRankName then
                rank = "<" .. guildName .. " / " .. guildRankName .. ">"
            end
        end

        local TankIcon = IconClass("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp", 64, 64, 0, 0+19, 22, 22+19)
        local HealerIcon = IconClass("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp", 64, 64, 19, 19+19, 1, 1+19)
        local DPSIcon = IconClass("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp", 64, 64, 19, 19+19, 22, 22+19)

        if name ~= nil then
            local role = UnitGroupRolesAssigned(id)
            roleIconPath = DPSIcon
            if role == "TANK" then
                roleIconPath = TankIcon
                elseif role == "HEALER" then
                roleIconPath = HealerIcon
                elseif role == "DAMAGER" then
                roleIconPath = DPSIcon
            end

            local entry = {
                ["name"] = name,
                ["rank"] = rank,
                ["class"] = englishClass,
                ["color"] = RAID_CLASS_COLORS[englishClass],
                ["role"] = role,
                ["spec"] = specName,
                ["roleIconPath"] = roleIconPath,
            }
            tinsert(ret, entry)
            retName[name] = entry
        end
    end

    if unsort then
        sort(ret, function(a, b)
            return
            (a.class < b.class or (a.class == b.class and a.name < b.name))
        end)
    end

    return ret, retName
end
tablePlayers, playersName = GetPlayerList()

-- Fonction qui compte un tableau
function countTable(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
--Script qui s'active quand un joueur rejoint le groupe
local frameGroup = CreateFrame("Frame")
frameGroup:RegisterEvent("GROUP_ROSTER_UPDATE")

frameGroup:SetScript("OnEvent", function(self, event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        tablePlayers, playersName = GetPlayerList()
    end
    -- quand un joueur change son role
    if event == "PLAYER_ROLES_ASSIGNED" then
        tablePlayers, playersName = GetPlayerList()
    end
end)
function addRolls(self, event, ...)
    if loot[1] ~=nil then
        if event == "CHAT_MSG_SYSTEM" then
            local message = ...
            local author, rollResult, rollMin, rollMax = string.match(message, "(.+) obtient un (%d+) %((%d+)-(%d+)%)")
            if author then
                if  tonumber(rollMin) == 1 then
                    if  tonumber(rollMax) == 100 then
                        if mainRolls[author] ~= nil then
                            -- envoie en message privé
                            SendChatMessage("Tu as déjà lancé un dé pour ce loot petit coquinou !", "WHISPER", "Common", author)
                        elseif SecondaryRolls[author] ~= nil then
                            SendChatMessage("Tu as déjà lancé un dé pour ce loot petit coquinou !", "WHISPER", "Common", author)
                        elseif thirdRolls[author] ~= nil then
                            SendChatMessage("Tu as déjà lancé un dé pour ce loot petit coquinou !", "WHISPER", "Common", author)
                        else
                            if LootTrackerUnbound.LootTrackerUnbound_SessionHistory[author] == nil then
                                mainRolls[author] = rollResult
                                AddLineToListAndShiftOthers(lists[1], rollResult.." : "..playersName[author]["color"]:WrapTextInColorCode(author)..playersName[author]["roleIconPath"]:GetIconString(),1,author)
                            else
                                AddLineToListAndShiftOthers(lists[2], rollResult.." : "..playersName[author]["color"]:WrapTextInColorCode(author)..playersName[author]["roleIconPath"]:GetIconString(),2,author)
                                SecondaryRolls[author] = rollResult
                            end
                        end

                    elseif tonumber(rollMax) == 50 then
                        if mainRolls[author] ~= nil then
                            -- envoie en message privé
                            SendChatMessage("Tu as déjà lancé un dé pour ce loot petit coquinou !", "WHISPER", "Common", author)
                        elseif SecondaryRolls[author] ~= nil then
                            SendChatMessage("Tu as déjà lancé un dé pour ce loot petit coquinou !", "WHISPER", "Common", author)
                        elseif thirdRolls[author] ~= nil then
                            SendChatMessage("Tu as déjà lancé un dé pour ce loot petit coquinou !", "WHISPER", "Common", author)
                        else
                            if thirdRolls[author] == nil  then
                                thirdRolls[author] = rollResult
                                AddLineToListAndShiftOthers(lists[3], rollResult.." : "..playersName[author]["color"]:WrapTextInColorCode(author)..playersName[author]["roleIconPath"]:GetIconString(),3,author)
                            end
                        end
                    else
                        sendInChat(author..", tu as fait un /rand avec un mauvais paramètre, merci de refaire un /rand ou /rand 50")
                    end
                else
                    sendInChat(author..", tu as fait un /rand avec un mauvais paramètre, merci de refaire un /rand ou /rand 50")
                end
            end
        end
    end
end
-- Fonction qui reset le l'historique d'un joueur
function resetHistorySession(player)
    LootTrackerUnbound.LootTrackerUnbound_SessionHistory[player] = nil
    LootTrackerUnbound_SessionHistory[player] = nil
    sendInChat("Le compteur de loot de "..player.." a été reset")
end
-- fonction qui annule le roll de quelqu'un
function resetRollPlayer(player,button,posText,posButton)
    if mainRolls[player] ~= nil then
        mainRolls[player] = nil


        RemoveLineFromListAndShiftOthers(lists[1],1,posText,posButton)
    end
    if SecondaryRolls[player] ~= nil then
        SecondaryRolls[player] = nil

        RemoveLineFromListAndShiftOthers(lists[2],2,posText,posButton)
    end
    if thirdRolls[player] ~= nil then
        thirdRolls[player] = nil

        RemoveLineFromListAndShiftOthers(lists[3],3,posText,posButton)
    end
    sendInChat("Les lancés de dé de "..player.." ont été annulé. Il doit refaire un /rand ou /rand 50")
end
--function qui annonce le vainqueur

function announceWinner()
    local winner = ""
    local winnerRoll = 0
    local winnerSecondaryRoll = 0
    local winnerThirdRoll = 0
    local boolSecond = true

    for key, value in pairs(mainRolls) do
        if tonumber(value) > winnerRoll then
            winner = key
            winnerRoll = tonumber(value)
            boolSecond = false
            if(LootTrackerUnbound.LootTrackerUnbound_SessionHistory[winner] == nil) then
                LootTrackerUnbound.LootTrackerUnbound_SessionHistory[winner] = 1
            else
                LootTrackerUnbound.LootTrackerUnbound_SessionHistory[winner] = LootTrackerUnbound.LootTrackerUnbound_SessionHistory[winner] + 1
            end
        end
    end
    if boolSecond then
        for key, value in pairs(thirdRolls) do
            if tonumber(value) > winnerThirdRoll then
                winner = key
                winnerRoll = tonumber(value)
                boolSecond = false
            end
        end
    end
    if boolSecond then
        for key, value in pairs(SecondaryRolls) do
            if tonumber(value) > winnerSecondaryRoll then
                winner = key
                winnerRoll = tonumber(value)
            end
        end
    end

    if winner == "" then
        local result = {}

        mainRolls = {}
        SecondaryRolls = {}
        thirdRolls = {}
        mainRollsEntry = {}

        sendInChat("Aucun joueur n'a lancé de dé. Redistribution du loot vers l'enchanteur.")
        result["winner"] = "Enchanteur"
        result["winnerRoll"] = 0
        result["loot"] = loot[1]
        table.insert(LootTrackerUnbound.LootTrackerUnbound_LootsDB,result)

        table.remove(loot,1)

    else
        sendInChat(winner.." a gagné "..loot[1].." avec un lancé à "..winnerRoll.." !")
        RemoveAllLinesFromListAndShiftOthers(lists,1)
        RemoveAllLinesFromListAndShiftOthers(lists,2)
        RemoveAllLinesFromListAndShiftOthers(lists,3)
        boolRollStarted = false
        local result = {}
        result["winner"] = winner
        result["winnerRoll"] = winnerRoll
        result["loot"] = loot[1]
        table.insert(LootTrackerUnbound.LootTrackerUnbound_LootsDB,result)
        table.remove(loot,1)

        mainRolls = {}
        SecondaryRolls = {}
        thirdRolls = {}

    end
    if loot[1] ~= nil then
        rollStart()
    else
        sendInChat("Plus de butin à distribuer !")
        f:RegisterEvent("LOOT_OPENED")
        f:SetScript("OnEvent", getLoot)
    end
end
function showLootsHistory()

    if #LootTrackerUnbound.LootTrackerUnbound_LootsDB == 0 then
        sendInChat("Aucun loot n'a été distribué")
    else
        sendInChat("Loots distribués au cours de cette session:")
        for i = 1, #LootTrackerUnbound.LootTrackerUnbound_LootsDB do
            if LootTrackerUnbound.LootTrackerUnbound_LootsDB[i]["winner"] == "Enchanteur" then
                sendInChat(LootTrackerUnbound.LootTrackerUnbound_LootsDB[i]["loot"].." a été redistribué à l'enchanteur")
            else
                sendInChat(LootTrackerUnbound.LootTrackerUnbound_LootsDB[i]["loot"].." a été distribué à "..LootTrackerUnbound.LootTrackerUnbound_LootsDB[i]["winner"].." avec un lancé à "..LootTrackerUnbound.LootTrackerUnbound_LootsDB[i]["winnerRoll"])
            end
        end
    end
end
function resetLootsHistory()
    LootTrackerUnbound.LootTrackerUnbound_LootsDB = {}
    LootTrackerUnbound_LootsDB = {}
   -- SaveAddOnData(addonName, LootTrackerUnbound.LootTrackerUnbound_SessionHistory)
   -- SaveAddOnData(addonName, LootTrackerUnbound.LootTrackerUnbound_LootsDB)
    print("Historique des loots réinitialisé")
end

function resetRolls()
    LootTrackerUnbound.LootTrackerUnbound_SessionHistory = {}
    LootTrackerUnbound_SessionHistory = {}
    print("Historique des lancés réinitialisé")
end

-- Enregistrez les scripts de fermeture pour la popup de confirmation
 function OnConfirmPopupOK(callbackFunc)
     -- Exécutez l'action souhaitée lorsque l'utilisateur clique sur "OK"
     if type(callbackFunc["data"]) == "function" then
         callbackFunc["data"]()
     end
 end

 function OnConfirmPopupCancel()
    -- Exécutez l'action souhaitée lorsque l'utilisateur clique sur "Annuler"
     StaticPopup_Hide("CONFIRM_ACTION")
     globalBoolean = false
     return false
end

 confirmPopup = {
    text = "Êtes-vous sûr de vouloir effectuer cette action ?",
    button1 = "OK",
    button2 = "Annuler",
    OnAccept = OnConfirmPopupOK,
    OnCancel = OnConfirmPopupCancel,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
function popupResetRolls()
    -- Créez la popup
    if not popup then
        popup = CreateFrame("Frame", "Popup", UIParent, "BasicFrameTemplateWithInset")
        -- Initialisez la popup
    end

    -- Si la popup n'est pas déjà affichée, affichez-la
    if not popup:IsShown() then
        popup:Show()
    else
        popup:SetSize(350, 125)
        popup:SetPoint("CENTER", UIParent, "CENTER")
        popup:SetFrameStrata("DIALOG")

        -- Créez la liste déroulante
        local dropdown = MSA_DropDownMenu_Create("DropDownPlayerList", popup)
        local function InitializeDropDownPlayerList(self)

            local info_init = UIDropDownMenu_CreateInfo()
            info_init.text = "Sélectionnez un joueur"
            info_init.value = 0
            info_init.func = function(self)
                MSA_DropDownMenu_SetSelectedValue(dropdown, info_init.value)
            end
            MSA_DropDownMenu_AddButton(info_init)
            for _,player in pairs(tablePlayers) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = player["name"]
                info.value = player["name"]
                info.func = function(self)
                    MSA_DropDownMenu_SetSelectedValue(dropdown, self.value)
                end
                MSA_DropDownMenu_AddButton(info)
            end

        end
        MSA_DropDownMenu_Initialize(dropdown, InitializeDropDownPlayerList)
        MSA_DropDownMenu_SetWidth(dropdown, 150)
        MSA_DropDownMenu_SetButtonWidth(dropdown, 124)
        MSA_DropDownMenu_SetSelectedID(dropdown, 1)
        MSA_DropDownMenu_JustifyText(dropdown, "LEFT")
        dropdown:SetPoint("TOPLEFT", popup, "TOPLEFT", 75, -30)


        -- Créez les boutons
        local button1 = CreateFrame("Button", "BtnJoueur", popup, "UIPanelButtonTemplate")
        button1:SetSize(100, 30)
        button1:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 15, 10)
        button1:SetText("Un joueur")

        local button2 = CreateFrame("Button", "BtnAll", popup, "UIPanelButtonTemplate")
        button2:SetSize(100, 30)
        button2:SetPoint("LEFT", button1, "RIGHT", 10, 0)
        button2:SetText("Tout")

        local button3 = CreateFrame("Button", "Cancel", popup, "UIPanelButtonTemplate")
        button3:SetSize(100, 30)
        button3:SetPoint("LEFT", button2, "RIGHT", 10, 0)
        button3:SetText("Annuler")

        -- Définissez les fonctions de rappel pour chaque bouton
        button1:SetScript("OnClick", function(self)
            -- votre code pour le bouton "Un joueur"
            if MSA_DropDownMenu_GetSelectedValue(dropdown) ~= 0 then
                resetHistorySession(MSA_DropDownMenu_GetSelectedValue(dropdown))
                popup:Hide()
            else
                print("Veuillez sélectionner un joueur")
            end
        end)

        button2:SetScript("OnClick", function(self)
            -- votre code pour le bouton "Tout"
            resetRolls()
            popup:Hide()
        end)

        button3:SetScript("OnClick", function(self)
            -- votre code pour le bouton "Annuler"
            popup:Hide()

        end)

        -- Affichez la popup
        popup:Show()
    end
end
StaticPopupDialogs["CONFIRM_ACTION"] = confirmPopup

-- Créez la fonction pour afficher la popup de confirmation
 function ShowConfirmationPopup(callbackFunc)
    -- Affichez la popup de confirmation en utilisant StaticPopup_Show
     StaticPopup_Show("CONFIRM_ACTION", nil,nil,callbackFunc)
 end


f:RegisterEvent("LOOT_OPENED")
f:SetScript("OnEvent", getLoot)




