local RSGCore = exports['rsg-core']:GetCoreObject()
local SpawnedGoldAgentBilps = {}

-----------------------------------------------------------------
-- blips
-----------------------------------------------------------------
Citizen.CreateThread(function()
    for _,v in pairs(Config.GoldAgentLocations) do
        if v.showblip == true then
            local GoldAgentBlip = BlipAddForCoords(1664425300, v.coords)
            SetBlipSprite(GoldAgentBlip, joaat(Config.GoldAgentBlip.blipSprite), true)
            SetBlipScale(GoldAgentBlip, Config.GoldAgentBlip.blipScale)
            SetBlipName(GoldAgentBlip, Config.GoldAgentBlip.blipName)
            table.insert(SpawnedGoldAgentBilps, GoldAgentBlip)
        end
    end
end)

RegisterNetEvent('rex-goldrush:client:goldagentmainmenu', function()

    lib.registerContext(
        {
            id = 'agent_main_menu',
            title = Lang:t('client.lang_42'),
            position = 'top-right',
            options = {
                {
                    title = Lang:t('client.lang_43'),
                    description = Lang:t('client.lang_44'),
                    icon = 'fa-solid fa-fire',
                    event = 'rex-goldrush:client:smeltnuggets'
                },
                {
                    title = Lang:t('client.lang_67'),
                    description = Lang:t('client.lang_68'),
                    icon = 'fa-solid fa-basket-shopping',
                    event = 'rex-goldrush:client:openshop'
                },
            }
        }
    )
    lib.showContext('agent_main_menu')

end)

---------------------------------------------
-- smelt gold bars
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:smeltnuggets', function()

    local input = lib.inputDialog(Lang:t('client.lang_47'), {
        {
            label = Lang:t('client.lang_48'),
            type = 'select',
            options = {
                { value = 'smallnugget', label = Lang:t('client.lang_49')..Config.SmallNuggetSmelt..Lang:t('client.lang_52') },
                { value = 'mediumnugget', label = Lang:t('client.lang_50')..Config.MediumNuggetSmelt..Lang:t('client.lang_52') },
                { value = 'largenugget', label = Lang:t('client.lang_51')..Config.LargeNuggetSmelt..Lang:t('client.lang_52') },
            },
            icon = 'fa-solid fa-land-mine-on',
            required = true
        },
        { 
            label = Lang:t('client.lang_53'),
            description = Lang:t('client.lang_54'),
            type = 'input',
            icon = 'fa-solid fa-hashtag',
            required = true
        },
    })
    
    if not input then
        return
    end
    
    if input[1] == 'smallnugget' then

        local amount = Config.SmallNuggetSmelt * input[2]
        local hasItem = RSGCore.Functions.HasItem('smallnugget', amount)

        if hasItem then

            LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
            lib.progressBar({
                duration = Config.SmeltTime * input[2],
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disableControl = true,
                disable = {
                    move = true,
                    mouse = true,
                },
                label = Lang:t('client.lang_55')..input[2]..Lang:t('client.lang_56'),
            })
            TriggerServerEvent('rex-goldrush:server:finishsmelt', input[1], input[2], amount)
            LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
        else
            lib.notify({ title = Lang:t('client.lang_57'), description = Lang:t('client.lang_58'), type = 'error', duration = 7000 })
        end

    end
    
    if input[1] == 'mediumnugget' then

        local amount = Config.MediumNuggetSmelt * input[2]
        local hasItem = RSGCore.Functions.HasItem('mediumnugget', amount)

        if hasItem then

            LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
            lib.progressBar({
                duration = Config.SmeltTime * input[2],
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disableControl = true,
                disable = {
                    move = true,
                    mouse = true,
                },
                label = Lang:t('client.lang_55')..input[2]..Lang:t('client.lang_56'),
            })
            TriggerServerEvent('rex-goldrush:server:finishsmelt', input[1], input[2], amount)
            LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
        else
            lib.notify({ title = Lang:t('client.lang_57'), description = Lang:t('client.lang_59'), type = 'error', duration = 7000 })
        end

    end
    
    if input[1] == 'largenugget' then

        local amount = Config.LargeNuggetSmelt * input[2]
        local hasItem = RSGCore.Functions.HasItem('largenugget', amount)

        if hasItem then

            LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
            lib.progressBar({
                duration = Config.SmeltTime * input[2],
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disableControl = true,
                disable = {
                    move = true,
                    mouse = true,
                },
                label = Lang:t('client.lang_55')..input[2]..Lang:t('client.lang_56'),
            })
            TriggerServerEvent('rex-goldrush:server:finishsmelt', input[1], input[2], amount)
            LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
        else
            lib.notify({ title = Lang:t('client.lang_57'), description = Lang:t('client.lang_60'), type = 'error', duration = 7000 })
        end

    end

end)

-----------------------------------------------------------------
-- goldrush shop
-----------------------------------------------------------------
RegisterNetEvent('rex-goldrush:client:openshop')
AddEventHandler('rex-goldrush:client:openshop', function()
    local ShopItems = {}
    ShopItems.label = Lang:t('client.lang_67')
    ShopItems.items = Config.GoldRushShop
    ShopItems.slots = #Config.GoldRushShop
    TriggerServerEvent('inventory:server:OpenInventory', 'shop', 'GoldRushShop_'..math.random(1, 99), ShopItems)
end)
