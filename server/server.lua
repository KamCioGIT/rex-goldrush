local RSGCore = exports['rsg-core']:GetCoreObject()
local PropsLoaded = false

---------------------------------------------
-- use prop
---------------------------------------------
RSGCore.Functions.CreateUseableItem("goldrocker", function(source)
    local src = source
    TriggerClientEvent('rex-goldrush:client:createprop', src, 'goldrocker', Config.GoldRocker, 'goldrocker')
end)

---------------------------------------------
-- use shovel
---------------------------------------------
RSGCore.Functions.CreateUseableItem("gr_shovel", function(source)
    local src = source
    TriggerClientEvent('rex-goldrush:client:digpaydirt', src)
end)

---------------------------------------------
-- use bucket
---------------------------------------------
RSGCore.Functions.CreateUseableItem("gr_bucket", function(source)
    local src = source
    TriggerClientEvent('rex-goldrush:client:collectwater', src)
end)

---------------------------------------------
-- count props
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-goldrush:server:countprop', function(source, cb, proptype)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM rex_goldrush WHERE citizenid = ? AND proptype = ?", { citizenid, proptype })
    if result then
        cb(result)
    else
        cb(nil)
    end
end)

---------------------------------------------
-- cash callback
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-goldrush:server:cashcallback', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local playercash = Player.PlayerData.money['cash']
    if playercash then
        cb(playercash)
    else
        cb(nil)
    end
end)

---------------------------------------------
-- get all trap data
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-goldrush:server:getallrockerdata', function(source, cb, propid)
    MySQL.query('SELECT * FROM rex_goldrush WHERE propid = ?', {propid}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

---------------------------------------------
-- new prop
---------------------------------------------
RegisterServerEvent('rex-goldrush:server:newProp')
AddEventHandler('rex-goldrush:server:newProp', function(proptype, location, heading, hash)
    local src = source
    local propId = math.random(111111, 999999)
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
    local owner = firstname .. ' ' .. lastname

    local PropData =
    {
        id = propId,
        proptype = proptype,
        x = location.x,
        y = location.y,
        z = location.z,
        h = heading,
        hash = hash,
        builder = Player.PlayerData.citizenid,
        buildttime = os.time()
    }

    local PropCount = 0

    for _, v in pairs(Config.PlayerProps) do
        if v.builder == Player.PlayerData.citizenid then
            PropCount = PropCount + 1
        end
    end

    if PropCount >= Config.MaxGoldRockers then
        TriggerClientEvent('ox_lib:notify', src, {title = Lang:t('server.lang_1'), type = 'inform', duration = 5000 })
    else
        table.insert(Config.PlayerProps, PropData)
        Player.Functions.RemoveItem(proptype, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[proptype], "remove")
        TriggerEvent('rex-goldrush:server:saveProp', PropData, propId, citizenid, owner, proptype)
        TriggerEvent('rex-goldrush:server:updateProps')
    end
end)

---------------------------------------------
-- save props
---------------------------------------------
RegisterServerEvent('rex-goldrush:server:saveProp')
AddEventHandler('rex-goldrush:server:saveProp', function(data, propId, citizenid, owner, proptype)
    local datas = json.encode(data)

    MySQL.Async.execute('INSERT INTO rex_goldrush (properties, propid, citizenid, owner, proptype) VALUES (@properties, @propid, @citizenid, @owner, @proptype)',
    {
        ['@properties'] = datas,
        ['@propid'] = propId,
        ['@citizenid'] = citizenid,
        ['@owner'] = owner,
        ['@proptype'] = proptype
    })
end)

---------------------------------------------
-- update props
---------------------------------------------
RegisterServerEvent('rex-goldrush:server:updateProps')
AddEventHandler('rex-goldrush:server:updateProps', function()
    local src = source
    TriggerClientEvent('rex-goldrush:client:updatePropData', src, Config.PlayerProps)
end)

---------------------------------------------
-- update prop data
---------------------------------------------
CreateThread(function()
    while true do
        Wait(5000)
        if PropsLoaded then
            TriggerClientEvent('rex-goldrush:client:updatePropData', -1, Config.PlayerProps)
        end
    end
end)

---------------------------------------------
-- get props
---------------------------------------------
CreateThread(function()
    TriggerEvent('rex-goldrush:server:getProps')
    PropsLoaded = true
end)

---------------------------------------------
-- get props
---------------------------------------------
RegisterServerEvent('rex-goldrush:server:getProps')
AddEventHandler('rex-goldrush:server:getProps', function()
    local result = MySQL.query.await('SELECT * FROM rex_goldrush')

    if not result[1] then return end

    for i = 1, #result do
        local propData = json.decode(result[i].properties)
        print('loading '..propData.proptype..' prop with ID: '..propData.id)
        table.insert(Config.PlayerProps, propData)
    end
end)

---------------------------------------------
-- distory prop
---------------------------------------------
RegisterServerEvent('rex-goldrush:server:destroyProp')
AddEventHandler('rex-goldrush:server:destroyProp', function(propid, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    for k, v in pairs(Config.PlayerProps) do
        if v.id == propid then
            table.remove(Config.PlayerProps, k)
        end
    end

    TriggerClientEvent('rex-goldrush:client:removePropObject', src, propid)
    TriggerEvent('rex-goldrush:server:PropRemoved', propid)
    TriggerEvent('rex-goldrush:server:updateProps')
    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[item], "add")
end)

---------------------------------------------
-- remove props
---------------------------------------------
RegisterServerEvent('rex-goldrush:server:PropRemoved')
AddEventHandler('rex-goldrush:server:PropRemoved', function(propId)
    local result = MySQL.query.await('SELECT * FROM rex_goldrush')

    if not result then return end

    for i = 1, #result do
        local propData = json.decode(result[i].properties)

        if propData.id == propId then
            MySQL.Async.execute('DELETE FROM rex_goldrush WHERE id = @id',
            {
                ['@id'] = result[i].id
            })

            for k, v in pairs(Config.PlayerProps) do
                if v.id == propId then
                    table.remove(Config.PlayerProps, k)
                end
            end
        end
    end
end)

---------------------------------------------
-- add paydirt
---------------------------------------------
RegisterNetEvent('rex-goldrush:server:addpaydirt', function(propid, newpaydirt)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    -- remove paydirt from player
    Player.Functions.RemoveItem('paydirt', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['paydirt'], 'remove')
    -- sql update
    MySQL.update('UPDATE rex_goldrush SET paydirt = ? WHERE propid = ?', {newpaydirt, propid})
end)

---------------------------------------------
-- add water
---------------------------------------------
RegisterNetEvent('rex-goldrush:server:addwater', function(propid, newwater)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    -- remove water from player
    Player.Functions.RemoveItem('water', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['water'], 'remove')
    -- sql update
    MySQL.update('UPDATE rex_goldrush SET water = ? WHERE propid = ?', {newwater, propid})
end)

---------------------------------------------
-- repair gold rocker
---------------------------------------------
RegisterNetEvent('rex-goldrush:server:repairrocker', function(propid, repaircost)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney('cash', repaircost, 'repair-equipment')
    MySQL.update('UPDATE rex_goldrush SET quality = ? WHERE propid = ?', {100, propid})
end)

---------------------------------------------
-- empty gold
---------------------------------------------
RegisterServerEvent('rex-goldrush:server:emptygold')
AddEventHandler('rex-goldrush:server:emptygold', function(smallnugget, mediumnugget, largenugget, propid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if smallnugget > 0 then
        Player.Functions.AddItem('smallnugget', smallnugget)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['smallnugget'], "add")
        MySQL.update('UPDATE rex_goldrush SET smallnugget = ? WHERE propid = ?', {0, propid})
    end
    if mediumnugget > 0 then
        Player.Functions.AddItem('mediumnugget', mediumnugget)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['mediumnugget'], "add")
        MySQL.update('UPDATE rex_goldrush SET mediumnugget = ? WHERE propid = ?', {0, propid})
    end
    if largenugget > 0 then
        Player.Functions.AddItem('largenugget', largenugget)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['largenugget'], "add")
        MySQL.update('UPDATE rex_goldrush SET largenugget = ? WHERE propid = ?', {0, propid})
    end
end)

---------------------------------------------
-- standard give item
---------------------------------------------
RegisterServerEvent('rex-goldrush:server:giveitem')
AddEventHandler('rex-goldrush:server:giveitem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[item], "add")
end)

---------------------------------------------
-- give gold bars
---------------------------------------------
RegisterNetEvent('rex-goldrush:server:finishsmelt', function(nuggettype, amountbars, amountnuggets)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    -- remove nuggets from player
    Player.Functions.RemoveItem(nuggettype, amountnuggets)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[nuggettype], 'remove')
    -- give gold bars
    Player.Functions.AddItem('goldbar', amountbars)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['goldbar'], 'add')
end)

---------------------------------------------
-- sell gold bars
---------------------------------------------
RegisterNetEvent('rex-goldrush:server:sellgoldbars', function(goldamount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    totalvalue = (goldamount * Config.GoldBarPrice)
    Player.Functions.AddMoney('cash', totalvalue)
    Player.Functions.RemoveItem('goldbar', goldamount)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['goldbar'], "remove")
end)

---------------------------------------------
-- gold system upkeep
---------------------------------------------
lib.cron.new(Config.CronJob, function ()

    local goldchance = math.random(1,100)
    local degradechance = math.random(1,100)
    local nuggetsize = math.random(1,3)
    local result = MySQL.query.await('SELECT * FROM rex_goldrush')

    if not result then goto continue end

    for i = 1, #result do

        local quality = result[i].quality
        local propid = result[i].propid
        local owner = result[i].owner
        local smallnugget = result[i].smallnugget
        local mediumnugget = result[i].mediumnugget
        local largenugget = result[i].largenugget
        local paydirt = result[i].paydirt
        local water = result[i].water

        -- degrade equipment
        if quality > 0 and degradechance > 100-Config.DegradeChance  then
            MySQL.update('UPDATE rex_goldrush SET quality = ? WHERE propid = ?', {quality-1, propid})
        end

        -- remove equipment if degraded
        if quality == 0 then
            for k, v in pairs(Config.PlayerProps) do
                if v.id == propid then
                    table.remove(Config.PlayerProps, k)
                end
            end
            TriggerEvent('rex-goldrush:server:updateProps')
            TriggerEvent('rsg-log:server:CreateLog', 'rexgoldrush', 'Gold Equipment Lost', 'red', 'Gold Rocker with ID:'..propid..' belonging to '..owner..' was lost due to non maintanance!')
            MySQL.Async.execute('DELETE FROM rex_goldrush WHERE propid = ?', {propid})
        end

        if nuggetsize == 1 then
            if smallnugget < 100 and goldchance > 100-Config.GoldChance and paydirt > 0 and water > 0 then
                MySQL.update('UPDATE rex_goldrush SET smallnugget = ? WHERE propid = ?', {smallnugget+1, propid})
            end
        end

        if nuggetsize == 2 then
            if mediumnugget < 100 and goldchance > 100-Config.GoldChance and paydirt > 0 and water > 0 then
                MySQL.update('UPDATE rex_goldrush SET mediumnugget = ? WHERE propid = ?', {mediumnugget+1, propid})
            end
        end

        if nuggetsize == 3 then
            if largenugget < 100 and goldchance > 100-Config.GoldChance and paydirt > 0 and water > 0 then
                MySQL.update('UPDATE rex_goldrush SET largenugget = ? WHERE propid = ?', {largenugget+1, propid})
            end
        end

        -- remove paydirt/water ever cycle
        if paydirt > 0 and water > 0 then
            MySQL.update('UPDATE rex_goldrush SET paydirt = ? WHERE propid = ?', {paydirt-1, propid})
            MySQL.update('UPDATE rex_goldrush SET water = ? WHERE propid = ?', {water-1, propid})
        end

    end

    ::continue::

    if Config.CycleNotify then
        print(Lang:t('server.lang_2'))
    end

end)
