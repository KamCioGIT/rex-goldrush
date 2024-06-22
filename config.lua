Config = {}
Config.PlayerProps = {}

---------------------------------------------
-- settings
---------------------------------------------
Config.EnableVegModifier    = true                   -- if set true clears vegetation
Config.GoldRocker           = `p_goldcradlestand01x` -- prop used for gold rocker
Config.MaxGoldRockers       = 1                      -- maximum gold rockers per character
Config.CronJob              = '*/5 * * * *'          -- cronjob time (every hour = 0 * * * *) / (every 30 mins = */30 * * * *)
Config.GoldChance           = 20                     -- percentage of chance of findig gold nugget
Config.DegradeChance        = 5                      -- percentage of chance of equipment degrading
Config.CycleNotify          = false                   -- if set to true will tell you when the update cycle runs
Config.AddPaydirtAmount     = 10                     -- amount of paydirt to add to gold rocker per 1 paydirt
Config.AddPaydirtTime       = 10000                  -- amount of time to add paydirt
Config.AddWaterAmount       = 10                     -- amount of water to add to gold rocker per 1 water
Config.AddWaterTime         = 10000                  -- amount of time to add water
Config.CollectGoldTime      = 10000                  -- amount of time to collect gold
Config.CollectPaydirtTime   = 10000                  -- amount of time to collect water
Config.CollectPaydirtAmount = 1                      -- amount of water collected
Config.CollectWaterTime     = 10000                  -- amount of time to collect water
Config.CollectWaterAmount   = 1                      -- amount of water collected
Config.RepairCost           = 1                      -- amount of $ per repair units
Config.RepairTime           = 10000                  -- amount of time it takes to repair the gold rocker
Config.Keybind              = 'J'                    -- keybind for gold agent
Config.EnableTarget         = true                   -- toggle between target / prompt

---------------------------------------------
-- gold agent / smelting settings
---------------------------------------------
Config.SmallNuggetSmelt  = 300   -- amount of small nuggets required for 1 bar of gold
Config.MediumNuggetSmelt = 200   -- amount of medium nuggets required for 1 bar of gold
Config.LargeNuggetSmelt  = 100   -- amount of large nuggets required for 1 bar of gold
Config.GoldBarPrice      = 100   -- amount of $ gold bar sells for
Config.SmeltTime         = 30000 -- amount of time to smelt a gold bar

---------------------------------------------
-- equpment blip settings
---------------------------------------------
Config.Blip = {
    blipName = 'Gold Equipment',
    blipSprite = 'blip_gold',
    blipScale = 0.2,
    blipColour = 'BLIP_MODIFIER_MP_COLOR_6'
}

---------------------------------
-- gold agent blip settings
---------------------------------
Config.GoldAgentBlip = {
    blipName = 'Gold Agent', -- Config.Blip.blipName
    blipSprite = 'blip_gold', -- Config.Blip.blipSprite
    blipScale = 0.2 -- Config.Blip.blipScale
}

---------------------------------------------
-- deploy prop settings
---------------------------------------------
Config.ForwardDistance = 2.0
Config.PromptGroupName = 'Place Equipment'
Config.PromptCancelName = 'Cancel'
Config.PromptPlaceName = 'Set'
Config.PromptRotateLeft = 'Rotate Left'
Config.PromptRotateRight = 'Rotate Right'

---------------------------------
-- npc settings
---------------------------------
Config.DistanceSpawn = 20.0
Config.FadeIn = true

---------------------------------
-- gold agent locations
---------------------------------
Config.GoldAgentLocations = {

    {
        name = 'Goldsmith',
        prompt = 'one-goldagent',
        coords = vector3(2799.70, 1350.10, 73.13),
        npcmodel = `re_goldpanner_males_01`,
        npccoords = vector4(2799.70, 1350.10, 73.13, 268.01),
        showblip = true
    },

}

---------------------------------
-- goldrush shop items
---------------------------------
Config.GoldRushShop = {
    [1] = { name = 'goldrocker', price = 800, amount = 10, info = {}, type = 'item', slot = 1, },
    [2] = { name = 'gr_bucket',  price = 5,   amount = 10, info = {}, type = 'item', slot = 2, },
    [3] = { name = 'gr_shovel',  price = 5,   amount = 10, info = {}, type = 'item', slot = 3, },
}
