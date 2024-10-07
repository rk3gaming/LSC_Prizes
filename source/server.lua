local currentQuestion
local winner = nil

local getCharacterName, givePrize

if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()

    getCharacterName = function(source)
        return ESX.GetPlayerFromId(source).getName()
    end

    givePrize = function(source, amount)
        exports.ox_inventory:AddItem(source, 'cash', amount)
    end

elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()

    getCharacterName = function(source)
        local player = QBCore.Functions.GetPlayer(source)
        return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end

    givePrize = function(source, amount)
        QBCore.Functions.AddItem(source, 'cash', amount)
    end
end

local function sendQuestion()
    local questionIndex = math.random(1, #Config.Questions)
    currentQuestion = Config.Questions[questionIndex]

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 50, 205, 50 },
        args = { "════════════════════════════" }
    }) 
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 50, 205, 50 },
        args = { "Question: " .. currentQuestion.question }
    })

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 50, 205, 50 },
        args = { "Prize: $" .. currentQuestion.prize }
    })

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 50, 205, 50 },
        args = { "System: Do /answer [answer] to win." }
    })
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 50, 205, 50 },
        args = { "════════════════════════════" }
    })
end

RegisterCommand("answer", function(source, args)
    if winner then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            args = { "You cannot answer anymore. A winner has already been declared." }
        })
        return
    end

    local answer = table.concat(args, " ")
    if answer == currentQuestion.answer then
        winner = source
        local characterName = getCharacterName(source)
        local prizeAmount = currentQuestion.prize

        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 255, 255 }, 
            args = {
                string.format('^4System:^3 %s (ID: %d) ^0got the math question right and ^3won the prize of $%d', characterName, source, prizeAmount)
            }
        })

        givePrize(source, prizeAmount)

        SetTimeout(60000, function() 
            winner = nil
        end)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            args = { "Wrong answer! Try again." }
        })
    end
end)

local function startQuestionTimer()
    Citizen.SetTimeout(Config.Minutes * 60 * 1000, function()
        sendQuestion()
        startQuestionTimer() 
    end)
end

startQuestionTimer()