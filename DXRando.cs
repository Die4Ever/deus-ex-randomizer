using System;
using System.Collections.Generic;
using CrowdControl.Common;
using CrowdControl.Games.Packs;
using ConnectorType = CrowdControl.Common.ConnectorType;

public class DeusEx : SimpleTCPPack
{
    public override string Host { get; } = "0.0.0.0";

    public override ushort Port { get; } = 43384;

    public DeusEx(IPlayer player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler) : base(player, responseHandler, statusUpdateHandler) { }

    public override Game Game { get; } = new Game(90, "Deus Ex Randomizer", "DeusEx", "PC", ConnectorType.SimpleTCPConnector);

    public override List<Effect> Effects => new List<Effect>
    {
        //General Effects
        new Effect("Trigger the Killswitch", "kill"),
        new Effect("Poison the Player", "poison"),
        new Effect("Glass Legs", "glass_legs"),
        new Effect("Give Health (x10)", "give_health",new[]{"amount100"}),
        new Effect("Set On Fire", "set_fire"),
        new Effect("Full Heal", "full_heal"),
        new Effect("Drunk Mode (1 minute)", "drunk_mode"),
        new Effect("Drop Selected Item", "drop_selected_item"),
        new Effect("Enable Matrix Mode (1 Minute)", "matrix"),
        new Effect("Give Player EMP Field (15 seconds)", "emp_field"),
        new Effect("Give Bioelectric Energy (x10)", "give_energy",new[]{"amount100"}),
        new Effect("Give Skill Points (x100)", "give_skillpoints",new[]{"skillpoints1000"}), //Updated text for second Crowd Control batch
        new Effect("Remove Skill  Points (x100)", "remove_skillpoints",new[]{"skillpoints1000"}), //Updated text for second Crowd Control batch
        new Effect("Disable Jump (1 minute)", "disable_jump"),
        new Effect("Gotta Go Fast (1 minute)", "gotta_go_fast"),
        new Effect("Slow Like Snail (1 minute)", "gotta_go_slow"),
        new Effect("Ice Physics! (1 minute)","ice_physics"),
        new Effect("Go Third-Person (1 minute)","third_person"),
        new Effect("Take Double Damage (1 minute)","dmg_double"),
        new Effect("Take Half Damage (1 minute)","dmg_half"),
        new Effect("Give Credits (x100)", "add_credits",new[]{"credits1000"}), //Updated for text second Crowd Control batch
        new Effect("Remove Credits (x100)", "remove_credits",new[]{"credits1000"}), //Updated text for second Crowd Control batch
        new Effect("Upgrade a Flamethrower to a LAMThrower (1 minute)", "lamthrower"),

        new Effect ("Ask a Question","ask_a_question"), //New for second Crowd Control batch
        new Effect ("Nudge","nudge"), //New for second Crowd Control batch
        new Effect ("Swap Player with another human","swap_player_position"), //New for second Crowd Control batch
        new Effect ("Float Away","floaty_physics"), //New for second Crowd Control batch
        new Effect ("Floor is Lava","floor_is_lava"), //New for second Crowd Control batch
        new Effect ("Invert Mouse Controls","invert_mouse"), //New for second Crowd Control batch
        new Effect ("Invert Movement Controls","invert_movement"), //New for second Crowd Control batch
        new Effect ("Earthquake","earthquake"), //New for fourth Crowd Control batch
        new Effect ("Full Bioelectric Energy","give_full_energy"), //New for fourth Crowd Control batch
        new Effect ("Trigger all alarms","trigger_alarms"), //New for fourth Crowd Control batch
        new Effect ("Flip camera upside down","flipped"), //New for fourth Crowd Control batch
        new Effect ("Flip camera sideways","limp_neck"), //New for fourth Crowd Control batch
        new Effect ("Do a barrel roll!","barrel_roll"), //New for fourth Crowd Control batch
        new Effect ("Set off a Flashbang", "flashbang"), //New for fourth Crowd Control batch
        new Effect ("Eat Beans", "eat_beans"), //New for fourth Crowd Control batch
        new Effect ("Fire the current weapon", "fire_weapon"), //New for fourth Crowd Control batch
        new Effect ("Switch to next item", "next_item"), //New for fourth Crowd Control batch
        new Effect ("Switch to next HUD color scheme", "next_hud_color"), //New for fourth Crowd Control batch
        new Effect ("Quick Save", "quick_save"), //New for fourth Crowd Control batch
        new Effect ("Quick Load", "quick_load"), //New for fourth Crowd Control batch

        //Spawn Enemies/Allies
        new Effect("Spawn Enemies/Allies","spawnpawns",ItemKind.Folder), //New for fourth Crowd Control batch
        new Effect ("Spawn Medical Bot", "spawnfriendly_medicalbot","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn Repair Bot", "spawnfriendly_repairbot","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Spider Bot", "spawnenemy_spiderbot2","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn hostile MJ12 Commando", "spawnenemy_mj12commando","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Security Bot", "spawnenemy_securitybot4","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn friendly Security Bot", "spawnfriendly_securitybot4","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Military Bot", "spawnenemy_militarybot","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn friendly Military Bot", "spawnfriendly_militarybot","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Doberman", "spawnenemy_doberman","spawnpawns"), //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Greasel", "spawnenemy_greasel","spawnpawns"), //New for fourth Crowd Control batch

        //Items
        new Effect("Give Items","giveitems",ItemKind.Folder), //New folder for third batch
        new Effect("Give a Medkit", "give_medkit", "giveitems"), //Moved into new folder for third batch
        new Effect("Give a Biocell", "give_bioelectriccell", "giveitems"), //Moved into new folder for third batch
        new Effect("Give a Fire Extinguisher", "give_fireextinguisher", "giveitems"), //New for third Crowd Control batch
        new Effect("Give a Ballistic Armor", "give_ballisticarmor", "giveitems"), //New for third Crowd Control batch
        new Effect("Give a Lockpick", "give_lockpick", "giveitems"), //New for third Crowd Control batch
        new Effect("Give a Multitool", "give_multitool", "giveitems"), //New for third Crowd Control batch
        new Effect("Give a Rebreather", "give_rebreather", "giveitems"), //New for third Crowd Control batch
        new Effect("Give a Thermoptic Camo", "give_adaptivearmor", "giveitems"), //New for third Crowd Control batch
        new Effect("Give a HazMat Suit", "give_hazmatsuit", "giveitems"), //New for third Crowd Control batch
        new Effect("Give a bottle of Wine", "give_winebottle", "giveitems"), //New for Fourth Crowd Control batch
        new Effect("Give a set of Tech Goggles", "give_techgoggles", "giveitems"), //New for Fourth Crowd Control batch

        //Add/Remove Augs
        new Effect("Add/Upgrade Augmentations","addaugs",ItemKind.Folder),
        new Effect("Remove/Downgrade Augmentations","remaugs",ItemKind.Folder),

        new Effect("Add/Upgrade Aqualung", "add_augaqualung", "addaugs"),
        new Effect("Add/Upgrade Ballistic Protection", "add_augballistic", "addaugs"),
        new Effect("Add/Upgrade Cloak", "add_augcloak", "addaugs"),
        new Effect("Add/Upgrade Combat Strength", "add_augcombat", "addaugs"),
        new Effect("Add/Upgrade Aggressive Defense System", "add_augdefense", "addaugs"),
        new Effect("Add/Upgrade Spy Drone", "add_augdrone", "addaugs"),
        new Effect("Add/Upgrade EMP Shield", "add_augemp", "addaugs"),
        new Effect("Add/Upgrade Environmental Resistance", "add_augenviro", "addaugs"),
        new Effect("Add/Upgrade Regeneration", "add_aughealing", "addaugs"),
        new Effect("Add/Upgrade Synthetic Heart", "add_augheartlung", "addaugs"),
        new Effect("Add/Upgrade Microfibral Muscle", "add_augmuscle", "addaugs"),
        new Effect("Add/Upgrade Power Recirculator", "add_augpower", "addaugs"),
        new Effect("Add/Upgrade Radar Transparancy", "add_augradartrans", "addaugs"),
        new Effect("Add/Upgrade Energy Shield", "add_augshield", "addaugs"),
        new Effect("Add/Upgrade Speed Enhancement", "add_augspeed", "addaugs"),
        new Effect("Add/Upgrade Run Silent", "add_augstealth", "addaugs"),
        new Effect("Add/Upgrade Targeting", "add_augtarget", "addaugs"),
        new Effect("Add/Upgrade Vision Enhancement", "add_augvision", "addaugs"),

        new Effect("Remove/Downgrade Aqualung", "rem_augaqualung", "remaugs"),
        new Effect("Remove/Downgrade Ballistic Protection", "rem_augballistic", "remaugs"),
        new Effect("Remove/Downgrade Cloak", "rem_augcloak", "remaugs"),
        new Effect("Remove/Downgrade Combat Strength", "rem_augcombat", "remaugs"),
        new Effect("Remove/Downgrade Aggressive Defense System", "rem_augdefense", "remaugs"),
        new Effect("Remove/Downgrade Spy Drone", "rem_augdrone", "remaugs"),
        new Effect("Remove/Downgrade EMP Shield", "rem_augemp", "remaugs"),
        new Effect("Remove/Downgrade Environmental Resistance", "rem_augenviro", "remaugs"),
        new Effect("Remove/Downgrade Regeneration", "rem_aughealing", "remaugs"),
        new Effect("Remove/Downgrade Synthetic Heart", "rem_augheartlung", "remaugs"),
        new Effect("Remove/Downgrade Microfibral Muscle", "rem_augmuscle", "remaugs"),
        new Effect("Remove/Downgrade Power Recirculator", "rem_augpower", "remaugs"),
        new Effect("Remove/Downgrade Radar Transparancy", "rem_augradartrans", "remaugs"),
        new Effect("Remove/Downgrade Energy Shield", "rem_augshield", "remaugs"),
        new Effect("Remove/Downgrade Speed Enhancement", "rem_augspeed", "remaugs"),
        new Effect("Remove/Downgrade Run Silent", "rem_augstealth", "remaugs"),
        new Effect("Remove/Downgrade Targeting", "rem_augtarget", "remaugs"),
        new Effect("Remove/Downgrade Vision Enhancement", "rem_augvision", "remaugs"),


        //Drop Grenades
        new Effect("Drop a live grenade","dropgrenade",ItemKind.Folder),

        new Effect("Drop a Live LAM", "drop_lam", "dropgrenade"),
        new Effect("Drop a Live EMP Grenade", "drop_empgrenade", "dropgrenade"),
        new Effect("Drop a Live Gas Grenade", "drop_gasgrenade", "dropgrenade"),
        new Effect("Drop a Live Scrambler Grenade", "drop_nanovirusgrenade", "dropgrenade"),


        //Weapons
        new Effect("Give Weapons","giveweapon",ItemKind.Folder),

        new Effect("Give Flamethrower", "give_weaponflamethrower", "giveweapon"),
        new Effect("Give GEP Gun", "give_weapongepgun", "giveweapon"),
        new Effect("Give Dragon Tooth Sword", "give_weaponnanosword", "giveweapon"),
        new Effect("Give Plasma Rifle", "give_weaponplasmarifle", "giveweapon"),
        new Effect("Give LAW", "give_weaponlaw", "giveweapon"),
        new Effect("Give Sniper Rifle", "give_weaponrifle", "giveweapon"),
        new Effect("Give Assault Rifle", "give_weaponassaultgun", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Assault Shotgun", "give_weaponassaultshotgun", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Baton", "give_weaponbaton", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Combat Knife", "give_weaponcombatknife", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Crowbar", "give_weaponcrowbar", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Mini Crossbow", "give_weaponminicrossbow", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Pepper Spray", "give_weaponpeppergun", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Pistol", "give_weaponpistol", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Stealth Pistol", "give_weaponstealthpistol", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Riot Prod", "give_weaponprod", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Sawed-off Shotgun", "give_weaponsawedoffshotgun", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Throwing Knives", "give_weaponshuriken", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Sword", "give_weaponsword", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give LAM", "give_weaponlam", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give EMP Grenade", "give_weaponempgrenade", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Gas Grenade", "give_weapongasgrenade", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Scrambler Grenade", "give_weaponnanovirusgrenade", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give PS40","give_weaponhideagun","giveweapon"),

        //Ammo
        new Effect("Give Ammo","giveammo",ItemKind.Folder),

        new Effect("Give 10mm Ammo (Pistols)", "give_ammo10mm",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give 20mm Ammo (Assault Rifle)", "give_ammo20mm",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give 7.62mm Ammo (Assault Rifle)", "give_ammo762mm",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give 30.06mm Ammo (Sniper Rifle)", "give_ammo3006",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Prod Charger", "give_ammobattery",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Darts", "give_ammodart",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Flare Darts", "give_ammodartflare",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Tranq Darts", "give_ammodartpoison",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Napalm", "give_ammonapalm",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Pepper Spray Ammo", "give_ammopepper",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Plasma", "give_ammoplasma",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Rockets", "give_ammorocket",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give WP Rockets", "give_ammorocketwp",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Sabot Shells", "give_ammosabot",new[]{"amount100"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Shotgun Shells", "give_ammoshell",new[]{"amount100"},"giveammo") //New for second Crowd Control batch
    };

    //Slider ranges need to be defined
    public override List<ItemType> ItemTypes => new List<ItemType>(new[]
    {
        new ItemType("Credits", "credits1000", ItemType.Subtype.Slider, "{\"min\":1,\"max\":1000}"),
        new ItemType("Skill Points", "skillpoints1000", ItemType.Subtype.Slider, "{\"min\":1,\"max\":1000}"),
        new ItemType("Amount","amount100",ItemType.Subtype.Slider, "{\"min\":1,\"max\":100}")
    });
}
