local blip, ATMCoords, soundId, drillcoords, RobbingATM, robTime = nil, nil, nil, nil, false, 0

function text(key, ...)
    local placeholders = {...}
    local text = Config.Locales[Config.Language][key]

    if text then
        return string.format(text, table.unpack(placeholders))
    end
end

function startRobbingATM(atm)
	ESX.TriggerServerCallback("six_atmrobbery:getRobberyStatus", function(canRob)
		if canRob then
			RobbingATM = true
			TriggerServerEvent("six_atmrobbery:callCops", ATMCoords)
			SetPedCoordsToAtm(atm)
			robTimer()
			beginnDrilling()
		end
	end)
end

function beginnDrilling()
    local ped = PlayerPedId()
    local animDict = "anim@heists@fleeca_bank@drilling"
    local animLib = "drill_straight_idle"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(50)
    end
    
    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
    Citizen.Wait(500)

    local drillProp = GetHashKey('hei_prop_heist_drill')
    local boneIndex = GetPedBoneIndex(ped, 28422)

    RequestModel(drillProp)
    while not HasModelLoaded(drillProp) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(ped, animDict, animLib, 1.0, -1.0, -1, 2, 0, 0, 0, 0)
    attachedDrill = CreateObject(drillProp, 1.0, 1.0, 1.0, true, true, false)
    AttachEntityToEntity(attachedDrill, ped, boneIndex, 0.0, 0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
    SetEntityAsMissionEntity(attachedDrill, true, true)

	loadDrillSound()
	Wait(100)
	soundId = GetSoundId()
	PlaySoundFromEntity(soundId, "Drill", attachedDrill, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)

	-- Cam Shake
	ShakeGameplayCam("SKY_DIVING_SHAKE", 0.6)

	Drilling.Type = 'VAULT_LASER'
	Drilling.Start(function(status)
		if status then
			DeleteObject(attachedDrill)
			DeleteEntity(attachedDrill)
			ClearPedTasksImmediately(ped)
			StopSound(soundId)
			StopGameplayCamShaking(true)

			stopDrilling(true)
		else
			DeleteObject(attachedDrill)
			DeleteEntity(attachedDrill)
			ClearPedTasksImmediately(ped)
			StopSound(soundId)
			StopGameplayCamShaking(true)

			stopDrilling(false)
		end
	end)	
				
end

function robTimer()
	robTime = Config.RobberyTime * 60

	Citizen.CreateThread(function()
		repeat
			Citizen.Wait(1000)
			robTime = robTime - 1
		until robTime == 0
	end)
end

function stopDrilling(success)
	local ped = PlayerPedId()
    FreezeEntityPosition(ped,false)
	ClearPedTasks(ped)
	ClearPedSecondaryTask(ped)
	robTime = 0
	RobbingATM = false	
    if success then
		TriggerServerEvent("six_atmrobbery:RobberyEnd", true)	
    else
		TriggerServerEvent("six_atmrobbery:RobberyEnd", false)	
		Client_Notify(text('robbery_failed'), "error")
	end
end

function DrawText3Ds(x, y, z, msg)
	AddTextEntry('atm', msg)
	SetFloatingHelpTextWorldPosition(1, vector3(x, y, z))
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('atm')
	EndTextCommandDisplayHelp(2, false, false, -1)
end

function SetPedCoordsToAtm(atm)
	local ped = PlayerPedId()
	local pedCoords = GetEntityCoords(ped)
	local entityHeading = GetEntityHeading(atm)
	local xOffset = 0.4 * math.sin(math.rad(entityHeading))
	local yOffset = -0.85 * math.cos(math.rad(entityHeading))

	FreezeEntityPosition(ped, true)
	SetEntityCoords(ped, ATMCoords.x + xOffset, ATMCoords.y + yOffset, ATMCoords.z)

	SetEntityHeading(ped, entityHeading)
end

function loadDrillSound()
	RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
end

Citizen.CreateThread(function()
	while true do 
		local sleep = 1000
		
		if robTime > 0 then
			sleep = 0
			local minutes = math.floor(robTime/60)
			local seconds = robTime - (minutes * 60)
			DrawText3Ds(ATMCoords.x,ATMCoords.y,ATMCoords.z + 2.25, text('robbery_time', minutes, seconds))
		end

		Citizen.Wait(sleep)
	end
end)

RegisterNetEvent('six_atmrobbery:checkPosition')
AddEventHandler('six_atmrobbery:checkPosition', function()
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	if not RobbingATM then
		if IsPedOnFoot(ped) then
			for i = 1, #Config.ATM_Props do
				local atm = GetClosestObjectOfType(pos.x, pos.y, pos.z, 0.7, Config.ATM_Props[i], false, false, false)
				if atm ~= 0 then
					if #(pos - GetEntityCoords(atm)) < 1.5 then
						ATMCoords = GetEntityCoords(atm)
						startRobbingATM(atm)
					end
				end
			end
		end
	end
end)

RegisterNetEvent("six_atmrobbery:robberyCall")
AddEventHandler("six_atmrobbery:robberyCall", function(coords)
	ESX.ShowAdvancedNotification("Fleeca Bank", text("alert_notify_title"), text("alert_notify_started"), "CHAR_CALL911", 1)

	if not coords then
		RemoveBlip(blip)
		ESX.ShowAdvancedNotification("Fleeca Bank", text("alert_notify_title"), text("alert_notify_ended"), "CHAR_CALL911", 1)

		blip = nil
		return
	end

	blip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(blip, 161)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 1)
	SetBlipAsShortRange(blip, false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text("alert_blip_name"))
	EndTextCommandSetBlipName(blip)
end)

AddEventHandler("onResourceStop", function(resource)
	if resource == GetCurrentResourceName() then
		if RobbingATM then
			local ped = PlayerPedId()
			DeleteObject(attachedDrill)
			DeleteEntity(attachedDrill)
			ClearPedTasksImmediately(ped)
			StopSound(soundId)
			StopGameplayCamShaking(true)
		end
	end
end)
