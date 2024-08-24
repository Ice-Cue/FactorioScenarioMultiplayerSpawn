-- This file is used to validate the config.lua file and handle any mod conflicts.

---Provides a way to look up the config settings key from the mod settings key.
---@alias OarcSettingsLookup { mod_key: string, ocfg_keys: table<integer, string>, type: string }

---@type table<string, OarcSettingsLookup>
OCFG_KEYS =
{
    ["server_info.server_msg"] = {mod_key = "oarc-mod-server-msg" , ocfg_keys = {"server_info", "server_msg"}, type = "string"},
    ["server_info.welcome_msg_title"] = {mod_key = "oarc-mod-welcome-msg-title" , ocfg_keys = {"server_info", "welcome_msg_title"}, type = "string"},
    ["server_info.welcome_msg"] = {mod_key = "oarc-mod-welcome-msg" , ocfg_keys = {"server_info", "welcome_msg"}, type = "string"},

    ["gameplay.enable_main_team"] = {mod_key = "oarc-mod-enable-main-team" , ocfg_keys = {"gameplay", "enable_main_team"}, type = "boolean"},
    ["gameplay.enable_separate_teams"] = {mod_key = "oarc-mod-enable-separate-teams" , ocfg_keys = {"gameplay", "enable_separate_teams"}, type = "boolean"},
    ["gameplay.enable_spawning_on_other_surfaces"] = {mod_key = "oarc-mod-enable-spawning-on-other-surfaces" , ocfg_keys = {"gameplay", "enable_spawning_on_other_surfaces"}, type = "boolean"},
    ["gameplay.allow_moats_around_spawns"] = {mod_key = "oarc-mod-allow-moats-around-spawns" , ocfg_keys = {"gameplay", "allow_moats_around_spawns"}, type = "boolean"},
    ["gameplay.enable_moat_bridging"] = {mod_key = "oarc-mod-enable-moat-bridging" , ocfg_keys = {"gameplay", "enable_moat_bridging"}, type = "boolean"},
    ["gameplay.minimum_distance_to_existing_chunks"] = {mod_key = "oarc-mod-minimum-distance-to-existing-chunks" , ocfg_keys = {"gameplay", "minimum_distance_to_existing_chunks"}, type = "integer"},
    ["gameplay.near_spawn_min_distance"] = {mod_key = "oarc-mod-near-spawn-min-distance" , ocfg_keys = {"gameplay", "near_spawn_min_distance"}, type = "integer"},
    ["gameplay.near_spawn_max_distance"] = {mod_key = "oarc-mod-near-spawn-max-distance" , ocfg_keys = {"gameplay", "near_spawn_max_distance"}, type = "integer"},
    ["gameplay.far_spawn_min_distance"] = {mod_key = "oarc-mod-far-spawn-min-distance" , ocfg_keys = {"gameplay", "far_spawn_min_distance"}, type = "integer"},
    ["gameplay.far_spawn_max_distance"] = {mod_key = "oarc-mod-far-spawn-max-distance" , ocfg_keys = {"gameplay", "far_spawn_max_distance"}, type = "integer"},

    ["gameplay.enable_buddy_spawn"] = {mod_key = "oarc-mod-enable-buddy-spawn" , ocfg_keys = {"gameplay", "enable_buddy_spawn"}, type = "boolean"},
    ["gameplay.enable_offline_protection"] = {mod_key = "oarc-mod-enable-offline-protection" , ocfg_keys = {"gameplay", "enable_offline_protection"}, type = "boolean"},
    ["gameplay.enable_shared_team_vision"] = {mod_key = "oarc-mod-enable-shared-team-vision" , ocfg_keys = {"gameplay", "enable_shared_team_vision"}, type = "boolean"},
    ["gameplay.enable_shared_team_chat"] = {mod_key = "oarc-mod-enable-shared-team-chat" , ocfg_keys = {"gameplay", "enable_shared_team_chat"}, type = "boolean"},
    ["gameplay.enable_shared_spawns"] = {mod_key = "oarc-mod-enable-shared-spawns" , ocfg_keys = {"gameplay", "enable_shared_spawns"}, type = "boolean"},
    ["gameplay.number_of_players_per_shared_spawn"] = {mod_key = "oarc-mod-number-of-players-per-shared-spawn" , ocfg_keys = {"gameplay", "number_of_players_per_shared_spawn"}, type = "integer"},
    ["gameplay.enable_friendly_fire"] = {mod_key = "oarc-mod-enable-friendly-fire" , ocfg_keys = {"gameplay", "enable_friendly_fire"}, type = "boolean"},

    ["gameplay.main_force_name"] = {mod_key = "oarc-mod-main-force-name" , ocfg_keys = {"gameplay", "main_force_name"}, type = "string"},
    ["gameplay.default_surface"] = {mod_key = "oarc-mod-default-surface" , ocfg_keys = {"gameplay", "default_surface"}, type = "string"},

    ["gameplay.scale_resources_around_spawns"] = {mod_key = "oarc-mod-scale-resources-around-spawns" , ocfg_keys = {"gameplay", "scale_resources_around_spawns"}, type = "boolean"},
    ["gameplay.modified_enemy_spawning"] = {mod_key = "oarc-mod-modified-enemy-spawning" , ocfg_keys = {"gameplay", "modified_enemy_spawning"}, type = "boolean"},

    ["gameplay.minimum_online_time"] = {mod_key = "oarc-mod-minimum-online-time" , ocfg_keys = {"gameplay", "minimum_online_time"}, type = "integer"},
    ["gameplay.respawn_cooldown_min"] = {mod_key = "oarc-mod-respawn-cooldown-min" , ocfg_keys = {"gameplay", "respawn_cooldown_min"}, type = "integer"},

    ["regrowth.enable_regrowth"] = {mod_key = "oarc-mod-enable-regrowth" , ocfg_keys = {"regrowth", "enable_regrowth"}, type = "boolean"},
    ["regrowth.enable_world_eater"] = {mod_key = "oarc-mod-enable-world-eater" , ocfg_keys = {"regrowth", "enable_world_eater"}, type = "boolean"},
    ["regrowth.enable_abandoned_base_cleanup"] = {mod_key = "oarc-mod-enable-abandoned-base-cleanup" , ocfg_keys = {"regrowth", "enable_abandoned_base_cleanup"}, type = "boolean"},
}

function ValidateAndLoadConfig()

    -- Save the config into the global table.
    ---@class OarcConfig
    global.ocfg = OCFG

    CacheModSettings()

    GetScenarioOverrideSettings()

    -- Validate enable_main_team and enable_separate_teams.
    -- Force enable_main_team if both are disabled.
    if (not global.ocfg.gameplay.enable_main_team and not global.ocfg.gameplay.enable_separate_teams) then
        log("Both main force and separate teams are disabled! Enabling main force. Please check your mod settings or config!")
        global.ocfg.gameplay.enable_main_team = true
    end

    -- Validate minimum is less than maximums
    if (global.ocfg.gameplay.near_spawn_min_distance >= global.ocfg.gameplay.near_spawn_max_distance) then
        log("Near spawn min distance is greater than or equal to near spawn max distance! Please check your mod settings or config!")
        global.ocfg.gameplay.near_spawn_max_distance = global.ocfg.gameplay.near_spawn_min_distance
    end
    if (global.ocfg.gameplay.far_spawn_min_distance >= global.ocfg.gameplay.far_spawn_max_distance) then
        log("Far spawn min distance is greater than or equal to far spawn max distance! Please check your mod settings or config!")
        global.ocfg.gameplay.far_spawn_max_distance = global.ocfg.gameplay.far_spawn_min_distance
    end

    -- TODO: Vanilla spawn point are not implemented yet.
    -- Validate enable_shared_spawns and enable_buddy_spawn.
    -- if (global.ocfg.enable_vanilla_spawns) then
    --     global.ocfg.enable_buddy_spawn = false
    -- end

end

-- Read in the mod settings and copy them to the OARC_CFG table, overwriting the defaults in config.lua.
function CacheModSettings()

    log("Copying mod settings to OCFG table...")

    -- TODO: Vanilla spawn point are not implemented yet.
    -- settings.global["oarc-mod-enable-vanilla-spawn-points"].value   
    -- settings.global["oarc-mod-number-of-vanilla-spawn-points"].value
    -- settings.global["oarc-mod-vanilla-spawn-point-spacing"].value

    -- Copy the global settings from the mod settings.
    -- Find the matching OARC setting and update it.
    for _,entry in pairs(OCFG_KEYS) do
        SetGlobalOarcConfigUsingKeyTable(entry.ocfg_keys, settings.global[entry.mod_key].value)
    end

    -- global.ocfg.server_info.welcome_msg_title = settings.global["oarc-mod-welcome-msg-title"].value --[[@as string]]
    -- global.ocfg.server_info.welcome_msg = settings.global["oarc-mod-welcome-msg"].value --[[@as string]]
    -- global.ocfg.server_info.server_msg = settings.global["oarc-mod-server-msg"].value --[[@as string]]

    -- global.ocfg.gameplay.enable_main_team = settings.global["oarc-mod-enable-main-team"].value --[[@as boolean]]
    -- global.ocfg.gameplay.enable_separate_teams = settings.global["oarc-mod-enable-separate-teams"].value --[[@as boolean]]
    -- global.ocfg.gameplay.enable_spawning_on_other_surfaces = settings.global["oarc-mod-enable-spawning-on-other-surfaces"].value --[[@as boolean]]

    -- global.ocfg.gameplay.allow_moats_around_spawns = settings.global["oarc-mod-allow-moats-around-spawns"].value --[[@as boolean]]
    -- global.ocfg.gameplay.enable_moat_bridging = settings.global["oarc-mod-enable-moat-bridging"].value --[[@as boolean]]
    -- global.ocfg.gameplay.minimum_distance_to_existing_chunks = settings.global["oarc-mod-minimum-distance-to-existing-chunks"].value --[[@as integer]]
    -- global.ocfg.gameplay.near_spawn_min_distance = settings.global["oarc-mod-near-spawn-min-distance"].value --[[@as integer]]
    -- global.ocfg.gameplay.near_spawn_max_distance = settings.global["oarc-mod-near-spawn-max-distance"].value --[[@as integer]]
    -- global.ocfg.gameplay.far_spawn_min_distance = settings.global["oarc-mod-far-spawn-min-distance"].value --[[@as integer]]
    -- global.ocfg.gameplay.far_spawn_max_distance = settings.global["oarc-mod-far-spawn-max-distance"].value --[[@as integer]]

    -- global.ocfg.gameplay.enable_buddy_spawn = settings.global["oarc-mod-enable-buddy-spawn"].value --[[@as boolean]]
    -- global.ocfg.gameplay.enable_offline_protection = settings.global["oarc-mod-enable-offline-protection"].value --[[@as boolean]]
    -- global.ocfg.gameplay.enable_shared_team_vision = settings.global["oarc-mod-enable-shared-team-vision"].value --[[@as boolean]]
    -- global.ocfg.gameplay.enable_shared_team_chat = settings.global["oarc-mod-enable-shared-team-chat"].value --[[@as boolean]]
    -- global.ocfg.gameplay.enable_shared_spawns = settings.global["oarc-mod-enable-shared-spawns"].value --[[@as boolean]]
    -- global.ocfg.gameplay.number_of_players_per_shared_spawn = settings.global["oarc-mod-number-of-players-per-shared-spawn"].value --[[@as integer]]
    -- global.ocfg.gameplay.enable_friendly_fire = settings.global["oarc-mod-enable-friendly-fire"].value --[[@as boolean]]

    -- global.ocfg.gameplay.main_force_name = settings.global["oarc-mod-main-force-name"].value --[[@as string]]
    -- global.ocfg.gameplay.default_surface = settings.global["oarc-mod-default-surface"].value --[[@as string]]
    -- global.ocfg.gameplay.scale_resources_around_spawns = settings.global["oarc-mod-scale-resources-around-spawns"].value --[[@as boolean]]
    -- global.ocfg.gameplay.modified_enemy_spawning = settings.global["oarc-mod-modified-enemy-spawning"].value --[[@as boolean]]
    -- global.ocfg.gameplay.minimum_online_time = settings.global["oarc-mod-um-online-time"].value --[[@as integer]]
    -- global.ocfg.gameplay.respawn_cooldown_min = settings.global["oarc-mod-respawn-cooldown-min"].value --[[@as integer]]

    -- global.ocfg.regrowth.enable_regrowth = settings.global["oarc-mod-enable-regrowth"].value --[[@as boolean]]
    -- global.ocfg.regrowth.enable_world_eater = settings.global["oarc-mod-enable-world-eater"].value--[[@as boolean]]
    -- global.ocfg.regrowth.enable_abandoned_base_cleanup = settings.global["oarc-mod-enable-abandoned-base-cleanup"].value --[[@as boolean]]
end

function GetScenarioOverrideSettings()

    if remote.interfaces["oarc_scenario"] then

        log("Getting scenario ode settings...")
        local scenario_settings = remote.call("oarc_scenario", "get_scenario_settings")

        -- Overwrite the non mod settings with the scenario settings.
        global.ocfg = scenario_settings

    else
        log("No scenario settings found.")
    end

end

---Handles the event when a mod setting is changed in the mod settings menu.
---@param event EventData.on_runtime_mod_setting_changed
---@return nil
function RuntimeModSettingChanged(event)

    log("on_runtime_mod_setting_changed" .. event.setting)

    -- Find the matching OARC setting and update it.
    local found_setting = false
    for _,entry in pairs(OCFG_KEYS) do
        if (event.setting == entry.mod_key) then
            SetGlobalOarcConfigUsingKeyTable(entry.ocfg_keys, settings.global[entry.mod_key].value)
            found_setting = true
            goto LOOP_BREAK
        end
    end
    ::LOOP_BREAK::

    if (not found_setting) then
        error("Unknown oarc-mod setting changed: " .. event.setting)
    end
end

---A probably quit stupid function to let me lookup and set the global.ocfg entries using a key table.
---@param key_table table<integer, string>
---@param value any
function SetGlobalOarcConfigUsingKeyTable(key_table, value)
    local number_of_keys = #key_table

    if (number_of_keys == 1) then
        global.ocfg[key_table[1]] = value
    elseif (number_of_keys == 2) then
        global.ocfg[key_table[1]][key_table[2]] = value
    elseif (number_of_keys == 3) then
        global.ocfg[key_table[1]][key_table[2]][key_table[3]] = value
    else
        error("Invalid key_table length: " .. number_of_keys .. "\n" .. serpent.block(key_table))
    end
end

---An equally stupid function to let me lookup the global.ocfg entries using a key table.
---@param key_table table<integer, string>
---@return any
function GetGlobalOarcConfigUsingKeyTable(key_table)
    local number_of_keys = #key_table

    if (number_of_keys == 1) then
        return global.ocfg[key_table[1]]
    elseif (number_of_keys == 2) then
        return global.ocfg[key_table[1]][key_table[2]]
    elseif (number_of_keys == 3) then
        return global.ocfg[key_table[1]][key_table[2]][key_table[3]]
    else
        error("Invalid key_table length: " .. number_of_keys .. "\n" .. serpent.block(key_table))
    end
end