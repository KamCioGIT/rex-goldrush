local RSGCore = exports['rsg-core']:GetCoreObject()
local SpawnedProps = {}
local isBusy = false
local canPlace = false
local fx_group = "scr_dm_ftb"
local fx_name = "scr_mp_chest_spawn_smoke"
local fx_scale = 1.0

---------------------------------------------
-- spawn props
---------------------------------------------
Citizen.CreateThread(function()
    while true do
        Wait(150)

        local pos = GetEntityCoords(cache.ped)
        local InRange = false

        for i = 1, #Config.PlayerProps do
            local prop = vector3(Config.PlayerProps[i].x, Config.PlayerProps[i].y, Config.PlayerProps[i].z)
            local dist = #(pos - prop)
            if dist >= 50.0 then goto continue end

            local hasSpawned = false
            InRange = true

            for z = 1, #SpawnedProps do
                local p = SpawnedProps[z]

                if p.id == Config.PlayerProps[i].id then
                    hasSpawned = true
                end
            end

            if hasSpawned then goto continue end

            local modelHash = Config.PlayerProps[i].hash
            local data = {}
            
            if not HasModelLoaded(modelHash) then
                RequestModel(modelHash)
                while not HasModelLoaded(modelHash) do
                    Wait(1)
                end
            end
            
            data.id = Config.PlayerProps[i].id
            data.obj = CreateObject(modelHash, Config.PlayerProps[i].x, Config.PlayerProps[i].y, Config.PlayerProps[i].z -1.2, false, false, false)
            SetEntityHeading(data.obj, Config.PlayerProps[i].h)
            SetEntityAsMissionEntity(data.obj, true)
            PlaceObjectOnGroundProperly(data.obj)
            Wait(1000)
            FreezeEntityPosition(data.obj, true)
            SetModelAsNoLongerNeeded(data.obj)

            -- veg modifiy
            if Config.EnableVegModifier then
                local veg_modifier_sphere = 0

                if veg_modifier_sphere == nil or veg_modifier_sphere == 0 then
                    local veg_radius = 3.0
                    local veg_Flags =  1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256
                    local veg_ModType = 1
                    veg_modifier_sphere = Citizen.InvokeNative(0xFA50F79257745E74, Config.PlayerProps[i].x, Config.PlayerProps[i].y, Config.PlayerProps[i].z, veg_radius, veg_ModType, veg_Flags, 0)
                else
                    Citizen.InvokeNative(0x9CF1836C03FB67A2, Citizen.PointerValueIntInitialized(veg_modifier_sphere), 0)
                    veg_modifier_sphere = 0
                end
            end

            if Config.PlayerProps[i].proptype == 'goldrocker' then
                local blip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, 1664425300, data.obj)
                Citizen.InvokeNative(0x74F74D3207ED525C, blip, joaat(Config.Blip.blipSprite), true)
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.Blip.blipName)
                Citizen.InvokeNative(0xD38744167B2FA257, blip, Config.Blip.blipScale)
                Citizen.InvokeNative(0x662D364ABF16DE2F, blip, joaat(Config.Blip.blipColour))
            end

            SpawnedProps[#SpawnedProps + 1] = data
            hasSpawned = false

            -- create target for the entity
            exports['rsg-target']:AddTargetEntity(data.obj, {
                options = {
                    {
                        type = 'client',
                        event = 'rex-goldrush:client:mainmenu',
                        icon = "fa-solid fa-eye",
                        label = Lang:t('client.lang_1'),
                        rockerid = data.id,
                        entity = data.obj,
                    },
                },
                distance = 3
            })
            -- end of target

            ::continue::
        end

        if not InRange then
            Wait(5000)
        end
    end
end)

-----------------------------------------------------------------
-- gold rush main menu
-----------------------------------------------------------------
RegisterNetEvent('rex-goldrush:client:mainmenu', function(data)

    RSGCore.Functions.TriggerCallback('rex-goldrush:server:getallrockerdata', function(result)

        local quality = result[1].quality
        local repaircost = (100 - result[1].quality) * Config.RepairCost

        lib.registerContext(
            {
                id = 'main_menu',
                title = Lang:t('client.lang_2'),
                position = 'top-right',
                options = {
                    {
                        title = Lang:t('client.lang_3'),
                        icon = 'fa-solid fa-circle-info',
                        event = 'rex-goldrush:client:checkrocker',
                        args = { rockerid = data.rockerid },
                        arrow = true
                    },
                    {
                        title = Lang:t('client.lang_4'),
                        icon = 'fa-solid fa-trowel',
                        event = 'rex-goldrush:client:addpaydirt',
                        args = { rockerid = data.rockerid }
                    },
                    {
                        title = Lang:t('client.lang_5'),
                        icon = 'fa-solid fa-droplet',
                        event = 'rex-goldrush:client:addwater',
                        args = { rockerid = data.rockerid }
                    },
                    {
                        title = Lang:t('client.lang_6'),
                        icon = 'fa-solid fa-land-mine-on',
                        event = 'rex-goldrush:client:emptygoldrocker',
                        args = { rockerid = data.rockerid }
                    },
                    {
                        title = Lang:t('client.lang_7')..repaircost..Lang:t('client.lang_8'),
                        icon = 'fa-solid fa-screwdriver-wrench',
                        event = 'rex-goldrush:client:repairrocker',
                        args = { rockerid = data.rockerid }
                    },
                    {
                        title = Lang:t('client.lang_9'),
                        icon = 'fa-solid fa-box-open',
                        event = 'rex-goldrush:client:packuprocker',
                        args = { rockerid = data.rockerid, entity = data.entity}
                    },
                }
            }
        )
        lib.showContext('main_menu')
    
    end, data.rockerid)
end)

---------------------------------------------
-- equipment info menu
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:checkrocker', function(data)

    RSGCore.Functions.TriggerCallback('rex-goldrush:server:getallrockerdata', function(result)
        local id = result[1].id
        local propid = result[1].propid
        local citizenid = result[1].citizenid
        local owner = result[1].owner
        local smallnugget = result[1].smallnugget
        local mediumnugget = result[1].mediumnugget
        local largenugget = result[1].largenugget
        local paydirt = result[1].paydirt
        local water = result[1].water
        local quality = result[1].quality
        local repaircost = (100 - result[1].quality) * Config.RepairCost

        lib.registerContext({
            id = 'equipmentinfo',
            title = Lang:t('client.lang_10'),
            menu = 'main_menu',
            onBack = function() end,
            options = {
                {
                    title = Lang:t('client.lang_11')..propid,
                    icon = 'fa-solid fa-fingerprint',
                },
                {
                    title = Lang:t('client.lang_12')..owner..Lang:t('client.lang_13')..citizenid..Lang:t('client.lang_14'),
                    icon = 'fa-solid fa-user',
                },
                {
                    title = Lang:t('client.lang_15')..quality..Lang:t('client.lang_16')..repaircost..Lang:t('client.lang_17'),
                    progress = quality,
                    colorScheme = 'green',
                    icon = 'fa-solid fa-screwdriver-wrench',
                },
                {
                    title = Lang:t('client.lang_18')..water,
                    progress = water,
                    colorScheme = 'blue',
                    icon = 'fa-solid fa-droplet',
                },
                {
                    title = Lang:t('client.lang_19')..paydirt,
                    progress = paydirt,
                    colorScheme = 'orange',
                    icon = 'fa-solid fa-hill-rockslide',
                },
                {
                    title = Lang:t('client.lang_20').. smallnugget,
                    progress = smallnugget,
                    colorScheme = 'yellow',
                    icon = 'fa-solid fa-land-mine-on',
                },
                {
                    title = Lang:t('client.lang_21').. mediumnugget,
                    progress = mediumnugget,
                    colorScheme = 'yellow',
                    icon = 'fa-solid fa-land-mine-on',
                },
                {
                    title = Lang:t('client.lang_22').. largenugget,
                    progress = largenugget,
                    colorScheme = 'yellow',
                    icon = 'fa-solid fa-land-mine-on',
                },
            }
        })
        lib.showContext('equipmentinfo')

    end, data.rockerid)
end)

---------------------------------------------
-- repair gold rocker
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:repairrocker', function(data)

    RSGCore.Functions.TriggerCallback('rex-goldrush:server:getallrockerdata', function(result)

        local repaircost = (100 - result[1].quality) * Config.RepairCost

        RSGCore.Functions.TriggerCallback('rex-goldrush:server:cashcallback', function(cash)

            if cash > repaircost then
                LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
                lib.progressBar({
                    duration = Config.RepairTime,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = false,
                    disableControl = true,
                    disable = {
                        move = true,
                        mouse = true,
                    },
                    label = Lang:t('client.lang_23'),
                })
                TriggerServerEvent('rex-goldrush:server:repairrocker', data.rockerid, repaircost)
                LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
            else
                lib.notify({ title = Lang:t('client.lang_24'), type = 'error', duration = 7000 })
            end

        end)

    end, data.rockerid)

end)

---------------------------------------------
-- add paydirt
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:addpaydirt', function(data)

    RSGCore.Functions.TriggerCallback('rex-goldrush:server:getallrockerdata', function(result)

        local paydirt = result[1].paydirt

        if paydirt >= 100 then
            lib.notify({ title = Lang:t('client.lang_25'), type = 'info', duration = 7000 })
            return
        end

        local hasItem = RSGCore.Functions.HasItem('paydirt', 1)
        local newpaydirt = paydirt + Config.AddPaydirtAmount

        if hasItem then
            LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
            lib.progressBar({
                duration = Config.AddPaydirtTime,
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disableControl = true,
                disable = {
                    move = true,
                    mouse = true,
                },
                label = Lang:t('client.lang_26'),
            })
            TriggerServerEvent('rex-goldrush:server:addpaydirt', data.rockerid, newpaydirt)
            LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
        else
            lib.notify({ title = Lang:t('client.lang_27'), type = 'error', duration = 7000 })
        end

    end, data.rockerid)

end)

---------------------------------------------
-- add water
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:addwater', function(data)

    RSGCore.Functions.TriggerCallback('rex-goldrush:server:getallrockerdata', function(result)

        local water = result[1].water

        if water >= 100 then
            lib.notify({ title = Lang:t('client.lang_28'), type = 'info', duration = 7000 })
            return
        end

        local hasItem = RSGCore.Functions.HasItem('water', 1)
        local newwater = water + Config.AddWaterAmount

        if hasItem then
            LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
            lib.progressBar({
                duration = Config.AddWaterTime,
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disableControl = true,
                disable = {
                    move = true,
                    mouse = true,
                },
                label = Lang:t('client.lang_29'),
            })
            TriggerServerEvent('rex-goldrush:server:addwater', data.rockerid, newwater)
            LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
        else
            lib.notify({ title = Lang:t('client.lang_30'), type = 'error', duration = 7000 })
        end

    end, data.rockerid)

end)

-----------------------------------------------------------------
-- emtpy gold rocker
-----------------------------------------------------------------
RegisterNetEvent('rex-goldrush:client:emptygoldrocker', function(data)

    RSGCore.Functions.TriggerCallback('rex-goldrush:server:getallrockerdata', function(result)

        local smallnugget = result[1].smallnugget
        local mediumnugget = result[1].mediumnugget
        local largenugget = result[1].largenugget

        LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
        lib.progressBar({
            duration = Config.CollectGoldTime,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disableControl = true,
            disable = {
                move = true,
                mouse = true,
            },
            label = Lang:t('client.lang_31'),
        })
        TriggerServerEvent('rex-goldrush:server:emptygold', smallnugget, mediumnugget, largenugget, data.rockerid)
        LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory

    end, data.rockerid)

end)

---------------------------------------------
-- packup gold rocker
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:packuprocker', function(data)

    RSGCore.Functions.TriggerCallback('rex-goldrush:server:getallrockerdata', function(result)

        local smallnugget = result[1].smallnugget
        local mediumnugget = result[1].mediumnugget
        local largenugget = result[1].largenugget
        local quality = result[1].quality

        if quality ~= 100 then
            lib.notify({ title = Lang:t('client.lang_32'), type = 'info', duration = 7000 })
            return
        end

        LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
        lib.progressBar({
            duration = Config.CollectGoldTime,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disableControl = true,
            disable = {
                move = true,
                mouse = true,
            },
            label = Lang:t('client.lang_33'),
        })
        LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory

        local propcoords = GetEntityCoords(data.entity)
        local fxcoords = vector3(propcoords.x, propcoords.y, propcoords.z)
        UseParticleFxAsset(fx_group)
        smoke = StartParticleFxNonLoopedAtCoord(fx_name, fxcoords, 0.0, 0.0, 0.0, fx_scale, false, false, false, true)

        TriggerServerEvent('rex-goldrush:server:emptygold', smallnugget, mediumnugget, largenugget, data.rockerid)
        TriggerServerEvent('rex-goldrush:server:destroyProp', data.rockerid, 'goldrocker')

    end, data.rockerid)
end)

---------------------------------------------
-- place gold rocker
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:placeNewProp')
AddEventHandler('rex-goldrush:client:placeNewProp', function(proptype, pHash, item, pos, heading)

    RSGCore.Functions.TriggerCallback('rex-goldrush:server:countprop', function(result)

        local inwater = IsEntityInWater(cache.ped)

        if inwater then
            lib.notify({ title = Lang:t('client.lang_34'), type = 'error', duration = 7000 })
            return
        end

        if proptype == 'goldrocker' and result >= Config.MaxGoldRockers then
            lib.notify({ title = Lang:t('client.lang_35'), type = 'error', duration = 7000 })
            return
        end

        if not isBusy then

            isBusy = true
            LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
            local anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
            FreezeEntityPosition(cache.ped, true)
            TaskStartScenarioInPlace(cache.ped, anim1, 0, true)
            Wait(10000)
            ClearPedTasks(cache.ped)
            FreezeEntityPosition(cache.ped, false)
            TriggerServerEvent('rex-goldrush:server:newProp', proptype, pos, heading, pHash)
            LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
            isBusy = false

        else
            lib.notify({ title = Lang:t('client.lang_36'), type = 'error', duration = 7000 })
        end

    end, proptype)

end)

---------------------------------------------
-- update props
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:updatePropData')
AddEventHandler('rex-goldrush:client:updatePropData', function(data)
    Config.PlayerProps = data
end)

---------------------------------------------
-- remove prop object
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:removePropObject')
AddEventHandler('rex-goldrush:client:removePropObject', function(prop)
    for i = 1, #SpawnedProps do
        local o = SpawnedProps[i]

        if o.id == prop then
            SetEntityAsMissionEntity(o.obj, false)
            FreezeEntityPosition(o.obj, false)
            DeleteObject(o.obj)
        end
    end
end)

---------------------------------------------
-- collecting paydirt
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:digpaydirt', function()

    local inwater = IsEntityInWater(cache.ped)

    if not inwater then
        lib.notify({ title = Lang:t('client.lang_37'), type = 'error', duration = 7000 })
        return
    end

    LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
    lib.progressBar({
        duration = Config.CollectPaydirtTime,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disableControl = true,
        disable = {
            move = true,
            mouse = true,
        },
        label = Lang:t('client.lang_38'),
    })
    TriggerServerEvent('rex-goldrush:server:giveitem', 'paydirt', Config.CollectPaydirtAmount)
    LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
end)

---------------------------------------------
-- collecting water
---------------------------------------------
RegisterNetEvent('rex-goldrush:client:collectwater', function()

    local inwater = IsEntityInWater(cache.ped)

    if not inwater then
        lib.notify({ title = Lang:t('client.lang_39'), type = 'error', duration = 7000 })
        return
    end

    LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
    lib.progressBar({
        duration = Config.CollectWaterTime,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disableControl = true,
        disable = {
            move = true,
            mouse = true,
        },
        label = Lang:t('client.lang_40'),
    })
    TriggerServerEvent('rex-goldrush:server:giveitem', 'water', Config.CollectWaterAmount)
    LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
end)

---------------------------------------------
-- clean up
---------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for i = 1, #SpawnedProps do
        local props = SpawnedProps[i].obj

        SetEntityAsMissionEntity(props, false)
        FreezeEntityPosition(props, false)
        DeleteObject(props)
    end
end)
