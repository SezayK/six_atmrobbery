Config = {}

Config.newESX = true

Config.Language = 'en'
Config.RequiredCops = 0

Config.DrillItem = 'drill' -- Item to start the robbery
Config.DrillUsedItem = 'useddrill'

Config.PoliceJobs = { 'police', "fib" } -- Jobs that can be called to the robbery

Config.Reward = { min = 15000, max = 30000}	-- Min and Max reward for robbing an ATM
Config.RewardAccount = 'money' -- money, black_mone or bank

Config.RobberyTime = 3 -- Minutes
Config.Cooldown = 15 -- Cooldown in Minutes for all ATMs

Config.ATM_Props = {'prop_fleeca_atm', 'prop_atm_02', 'prop_atm_03'}

Config.Locales = {
    ['de'] = {
        ['robbery_failed'] = "Raub fehlgeschlagen! Viel Glück beim nächsten mal! [Überhitzung]",
        ['robbery_time'] = "Verbleibende Zeit:\n~r~%s Minuten %s Sekunden~w~",
        ['robbery_success'] = 'Raubüberfall ~o~erfolgreich~w~! Du hast ~g~%s$ ~w~erbeutet!',
        ['robbery_cooldown'] = 'Du musst noch %s Minuten warten!',
        ['robbery_missingCops'] = "Es sind nicht genügend Polizisten im Dienst! %s von %s im Dienst",
        ['robbery_call'] = 'Ein ATM wird gerade ausgeraubt! [Koordinaten: %s]',

        ['alert_notify_title'] = "~r~ATM-Raub",
        ['alert_notify_started'] = "Ein Überfall auf einen Geldautomaten wurde gemeldet!",
        ['alert_notify_ended'] = "Der Überfall wurde beendet!",
        ['alert_blip_name'] = "Überfall | ATM-Raub",
    },

    ['en'] = {
        ['robbery_failed'] = "Robbery failed! Better luck next time! [Overheating]",
        ['robbery_time'] = "Remaining time:\n~r~%s minutes %s seconds~w~",
        ['robbery_success'] = 'Robbery ~o~successful~w~! You have ~g~%s$ ~w~looted!',
        ['robbery_cooldown'] = 'You have to wait %s minutes!',
        ['robbery_missingCops'] = "There are not enough police officers on duty! %s of %s on duty",
        ['robbery_call'] = 'An ATM is being robbed! [Coordinates: %s]',

        ['alert_notify_title'] = "~r~ATM-Robbery",
        ['alert_notify_started'] = "An ATM robbery has been reported!",
        ['alert_notify_ended'] = "The robbery has ended!",
        ['alert_blip_name'] = "Robbery | ATM-Robbery",
    }

}

function Client_Notify(msg, type) 
    ESX.ShowNotification(msg) -- OR custom notification like TriggerEvent('six_notify', title, msg, type, time)
end

function Server_Notify(source, msg, type) 
    TriggerClientEvent("esx:showNotification", source, msg) -- OR custom notification like TriggerEvent('six_notify', source, title, msg, type, time)
end