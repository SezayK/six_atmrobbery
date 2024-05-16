local exploit = {}
local cooldowntime = Config.Cooldown
local isCooldown = false

function getCops()
	local xPlayers = ESX.Players
	local policeJobs = {}
	if not Config.newESX then
		xPlayers = ESX.GetPlayers()
	end
    for _, job in ipairs(Config.PoliceJobs) do
        policeJobs[job] = true
    end

	local cops = 0
	for _, xPlayer in pairs(xPlayers) do
		local xPlayer = ESX.GetPlayerFromId(xPlayer.source)
        if xPlayer and policeJobs[xPlayer.getJob().name] then
			cops = cops + 1
		end
    end
	return cops
end

function callCops(coords)
	local xPlayers = ESX.Players
	local policeJobs = {}
	if not Config.newESX then
		xPlayers = ESX.GetPlayers()
	end
    for _, job in ipairs(Config.PoliceJobs) do
        policeJobs[job] = true
    end

    for _, xPlayer in pairs(xPlayers) do
		local xPlayer = ESX.GetPlayerFromId(xPlayer.source)
        if xPlayer and policeJobs[xPlayer.getJob().name] then
            TriggerClientEvent("six_atmrobbery:robberyCall", xPlayer.source, coords)
        end
    end
end

function cooldown()
	isCooldown = true
	cooldowntime = Config.Cooldown

	Citizen.CreateThread(function()
		repeat
			Citizen.Wait(60000)

			cooldowntime = cooldowntime - 1 

			if cooldowntime <= 0 then
				isCooldown = false
			end

		until cooldowntime == 0
	end)
end

ESX.RegisterUsableItem(Config.DrillItem, function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.triggerEvent("six_atmrobbery:checkPosition")
	exploit[source] = true
end)

RegisterServerEvent("six_atmrobbery:RobberyEnd")
AddEventHandler("six_atmrobbery:RobberyEnd",function(success)
	local xPlayer = ESX.GetPlayerFromId(source)
	if success then
		if exploit[source] == true then
			local reward = math.random(Config.Reward.min, Config.Reward.max)
			xPlayer.addAccountMoney(Config.RewardAccount, tonumber(reward))
			Server_Notify(source, text("robbery_success", reward), "success")
		end
	end
	callCops()
	xPlayer.removeInventoryItem(Config.DrillItem, 1)
	xPlayer.addInventoryItem(Config.DrillUsedItem, 1)
	exploit[source] = false
end)

RegisterServerEvent("six_atmrobbery:callCops")
AddEventHandler("six_atmrobbery:callCops",function(coords)
	callCops(coords)
end)

ESX.RegisterServerCallback("six_atmrobbery:getRobberyStatus",function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local CurrentCops = getCops()

	if isCooldown then 
		Server_Notify(source, text("robbery_cooldown", cooldowntime), "error")
		xPlayer.showNotification("Ein ATM-Raub hat kürzlich stattgefunden. Bitte warten Sie "..cooldowntime.." Minuten!") 
		exploit[source] = false
		cb(false)
		return 
	end
	if CurrentCops < Config.RequiredCops then 
		Server_Notify(source, text("robbery_missingCops", CurrentCops, Config.RequiredCops), "error")
		exploit[source] = false
		cb(false)
		return 
	end

	cooldown()
	cb(true)
end)

function text(key, ...)
    local placeholders = {...}
    local text = Config.Locales[Config.Language][key]

    if text then
        return string.format(text, table.unpack(placeholders))
    end
end