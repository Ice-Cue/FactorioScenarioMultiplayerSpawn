-- oarc_store_map_features.lua
-- May 2020
-- Adding microtransactions.

require("lib/shared_chests")
require("lib/map_features")

OARC_STORE_MAP_CATEGORIES = 
{
    special_chests = "Special buildings for sharing or monitoring items and energy. This will convert the closest wooden chest (to you) within 16 tiles into a special building of your choice. Make sure to leave enough space! The combinators and accumulators can take up several tiles around them.",
    special_chunks = "Map features that can be built on the special empty chunks found on the map. You must be standing inside an empty special chunk to be able to build these. Each player can only build one of each type. [color=red]THESE FEATURES ARE PERMANENT AND CAN NOT BE REMOVED![/color]",
    special_buttons = "Special actions. Like teleporting home. (For now this is the only one...)",
}

-- N = number already purchased
-- Cost = initial + (additional * ( N^multiplier ))
OARC_STORE_MAP_FEATURES = 
{
    special_chests = {
        ["logistic-chest-storage"] = {
            initial_cost = 200,
            additional_cost = 20,
            multiplier_cost = 2,
            -- limit = 100,
            text="Input chest for sharing items."},
        ["logistic-chest-requester"] = {
            initial_cost = 200,
            additional_cost = 50,
            multiplier_cost = 2,
            -- limit = 100,
            text="Output chest for requesting shared items."},
        ["constant-combinator"] = {
            initial_cost = 50, 
            text="Combinator setup to monitor shared items."},
        ["accumulator"] = {
            initial_cost = 200,
            additional_cost = 50,
            multiplier_cost = 2,
            -- limit = 100,
            text="INPUT for shared energy system."},
        ["electric-energy-interface"] = {
            initial_cost = 200,
            additional_cost = 100,
            multiplier_cost = 2,
            -- limit = 100,
            text="OUTPUT for shared energy system."},
        ["deconstruction-planner"] = {
            initial_cost = 0,
            text="Removes the closest special building within range. NO REFUNDS!"},
    },

    special_chunks = {
        ["electric-furnace"] = {
            initial_cost = 1000,
            additional_cost = 1000,
            multiplier_cost = 2,
            -- limit = 3,
            text="Build a special furnace chunk here. Contains 4 furnaces that run at very high speeds. [color=red]Requires energy from the shared storage. Modules have no effect![/color]"},
        ["oil-refinery"] = {
            initial_cost = 1000,
            additional_cost = 1000,
            multiplier_cost = 2,
            -- limit = 3,
            text="Build a special oil refinery chunk here. Contains 2 refineries and some chemical plants that run at very high speeds. [color=red]Requires energy from the shared storage. Modules have no effect![/color]"},
        ["assembling-machine-3"] = {
            initial_cost = 1000,
            additional_cost = 1000,
            multiplier_cost = 2,
            -- limit = 3,
            text="Build a special assembly machine chunk here. Contains 6 assembling machines that run at very high speeds. [color=red]Requires energy from the shared storage. Modules have no effect![/color]"},
        ["centrifuge"] = {
            initial_cost = 1000,
            additional_cost = 1000,
            multiplier_cost = 2,
            -- limit = 1,
            text="Build a special centrifuge chunk here. Contains 1 centrifuge that runs at very high speeds. [color=red]Requires energy from the shared storage. Modules have no effect![/color]"},
        ["rocket-silo"] = {
            initial_cost = 1000,
            additional_cost = 0,
            multiplier_cost = 2,
            -- limit = 2,
            text="Convert this special chunk into a rocket launch pad. This allows you to build a rocket silo here!"},
        -- ["rocket-silo"] = {cost = 1000, text="Build a special rocket silo chunk here."}, TODO...
    },

    special_buttons = {
        ["assembling-machine-1"] = {
            initial_cost = 10,
            text="Teleport home."},
    }
}

function CreateMapFeatureStoreTab(tab_container, player)

    local player_inv = player.get_main_inventory()
    if (player_inv == nil) then return end

    local wallet = player_inv.get_item_count("coin")
    AddLabel(tab_container,
        "map_feature_store_wallet_lbl",
        "Coins Available: " .. wallet .. "  [item=coin]",
        {top_margin=5, bottom_margin=5})
    AddLabel(tab_container, "coin_info", "Players start with some coins. Earn more coins by killing enemies.", my_note_style)

    local line = tab_container.add{type="line", direction="horizontal"}
    line.style.top_margin = 5
    line.style.bottom_margin = 5

    for category,section in pairs(OARC_STORE_MAP_FEATURES) do
        AddLabel(tab_container,
                nil,
                OARC_STORE_MAP_CATEGORIES[category],
                {bottom_margin=5, maximal_width = 400, single_line = false})
        local flow = tab_container.add{name = category, type="flow", direction="horizontal"}
        for item_name,item in pairs(section) do
            local count = OarcMapFeaturePlayerCountGet(player, category, item_name)
            local cost = OarcMapFeatureCostScaling(player, category, item_name)
            local color = "[color=green]"
            if ((cost > wallet) or (cost < 0)) then
                color = "[color=red]"
            end
            local btn = flow.add{name=item_name,
                        type="sprite-button",
                        -- number=item.count,
                        sprite="item/"..item_name,
                        -- tooltip=item.text.." Cost: "..color..cost.."[/color] [item=coin]",
                        style=mod_gui.button_style}
            if (cost < 0) then
                btn.enabled = false
                btn.tooltip = item.text .. "\n "..color..
                                 "Limit: ("..count.."/"..item.limit..") [/color]"
            elseif (item.limit) then
                btn.tooltip = item.text .. "\nCost: "..color..cost.."[/color] [item=coin] "..
                                "Limit: ("..count.."/"..item.limit..")"
            else
                btn.tooltip = item.text.." Cost: "..color..cost.."[/color] [item=coin]"
            end
        end
        local line2 = tab_container.add{type="line", direction="horizontal"}
        line2.style.top_margin = 5
        line2.style.bottom_margin = 5
    end
end

function OarcMapFeatureInitGlobalCounters()
    global.oarc_store = {}
    global.oarc_store.pmf_counts = {}
end

function OarcMapFeaturePlayerCreatedEvent(player)
    global.oarc_store.pmf_counts[player.name] = {}
end

function OarcMapFeaturePlayerCountGet(player, category_name, feature_name)
    if (not global.oarc_store.pmf_counts[player.name][feature_name]) then
        global.oarc_store.pmf_counts[player.name][feature_name] = 0
        return 0
    end
    
    return global.oarc_store.pmf_counts[player.name][feature_name]
end

function OarcMapFeaturePlayerCountChange(player, category_name, feature_name, change)

    if (not global.oarc_store.pmf_counts[player.name][feature_name]) then
        if (change < 0) then
            log("ERROR - OarcMapFeaturePlayerCountChange - Removing when count is not set??")
        end
        global.oarc_store.pmf_counts[player.name][feature_name] = change
        return
    end

    -- Update count
    global.oarc_store.pmf_counts[player.name][feature_name] = global.oarc_store.pmf_counts[player.name][feature_name] + change

    -- Make sure we don't go below 0.
    if (global.oarc_store.pmf_counts[player.name][feature_name] < 0) then
        global.oarc_store.pmf_counts[player.name][feature_name] = 0
    end
end



-- Return cost (0 or more) or return -1 if disabled.
function OarcMapFeatureCostScaling(player, category_name, feature_name)

    local map_feature = OARC_STORE_MAP_FEATURES[category_name][feature_name]

    -- Check limit first.
    local count = OarcMapFeaturePlayerCountGet(player, category_name, feature_name)
    if (map_feature.limit and (count >= map_feature.limit)) then
        return -1
    end

    if (map_feature.initial_cost and map_feature.additional_cost and map_feature.multiplier_cost) then
        return (map_feature.initial_cost + (map_feature.additional_cost*(count^map_feature.multiplier_cost)))
    else
        return map_feature.initial_cost
    end
end

function OarcMapFeatureStoreButton(event)
    local button = event.element
    local player = game.players[event.player_index]

    local player_inv = player.get_inventory(defines.inventory.character_main)
    if (player_inv == nil) then return end
    local wallet = player_inv.get_item_count("coin")

    local map_feature = OARC_STORE_MAP_FEATURES[button.parent.name][button.name]

    -- Calculate cost based on how many player has purchased?
    local cost = OarcMapFeatureCostScaling(player, button.parent.name, button.name)

    -- Check if we have enough money
    if (wallet < cost) then
        player.print("You're broke! Go kill some enemies or beg for change...")
        return
    end

    -- Each button has a special function
    local result = false
    if (button.name == "logistic-chest-storage") then
        result = ConvertWoodenChestToSharedChestInput(player)
    elseif (button.name == "logistic-chest-requester") then
        result = ConvertWoodenChestToSharedChestOutput(player)
    elseif (button.name == "constant-combinator") then
        result = ConvertWoodenChestToSharedChestCombinators(player)
    elseif (button.name == "accumulator") then
        result = ConvertWoodenChestToShareEnergyInput(player)
    elseif (button.name == "electric-energy-interface") then
        result = ConvertWoodenChestToShareEnergyOutput(player)
    elseif (button.name == "deconstruction-planner") then
        result = DestroyClosestSharedChestEntity(player)
    elseif (button.name == "electric-furnace") then
        result = RequestSpawnSpecialChunk(player, SpawnFurnaceChunk, button.name)
    elseif (button.name == "oil-refinery") then
        result = RequestSpawnSpecialChunk(player, SpawnOilRefineryChunk, button.name)
    elseif (button.name == "assembling-machine-3") then
        result = RequestSpawnSpecialChunk(player, SpawnAssemblyChunk, button.name)
    elseif (button.name == "centrifuge") then
        result = RequestSpawnSpecialChunk(player, SpawnAssemblyChunk, button.name)
    elseif (button.name == "rocket-silo") then
        result = RequestSpawnSpecialChunk(player, SpawnSiloChunk, button.name)        
    elseif (button.name == "assembling-machine-1") then
        SendPlayerToSpawn(player)
        result = true
    end

    -- On success, we deduct money
    if (result) then
        player_inv.remove({name = "coin", count = cost})
    end

    -- Refresh GUI:
    FakeTabChangeEventOarcStore(player)
end
