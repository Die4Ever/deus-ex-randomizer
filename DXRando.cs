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
        new Effect("Trigger the Killswitch", "kill"){Price = 125,Description = "Instantly kill the player by simply flipping a switch."},
        new Effect("Poison the Player", "poison"){Price = 15,Description = "Give the player a nice dose of poison"},
        new Effect("Glass Legs", "glass_legs"){Price = 30,Description = "Take away all but one health from each of the players legs"},
        new Effect("Give Health (x10)", "give_health",new[]{"amount100"}){Price = 1,Description = "Give the player some health!"},
        new Effect("Set On Fire", "set_fire"){Price = 25,Description = "Burn baby burn!"},
        new Effect("Full Heal", "full_heal"){Price = 30,Description = "Fully heal the player"},
        new Effect("Drunk Mode", "drunk_mode"){Price = 10,Description = "Let the player overindulge with some nice alcohol",Duration=60},
        new Effect("Drop Selected Item", "drop_selected_item"){Price = 2,Description = "Toss the currently held weapon out in front of the player"},
        new Effect("Enable Matrix Mode", "matrix"){Price = 5,Description = "Make the player see the code behind the game...",Duration=60},
        new Effect("Give Player EMP Field", "emp_field"){Price = 25,Description = "Make all electronics around the player go haywire for 15 seconds!",Duration=15},
        new Effect("Give Bioelectric Energy (x10)", "give_energy",new[]{"amount100"}){Price = 1,Description = "Top up the players battery by a bit"},
        new Effect("Give Skill Points (x100)", "give_skillpoints",new[]{"skillpoints1000"}){Price = 5,Description = "Give the player some skill points"}, //Updated text for second Crowd Control batch
        new Effect("Remove Skill  Points (x100)", "remove_skillpoints",new[]{"skillpoints1000"}){Price = 10,Description = "Take some skill points away from the player"}, //Updated text for second Crowd Control batch
        new Effect("Disable Jump", "disable_jump"){Price = 5,Description = "Lock up the players knees and prevent them from jumping",Duration=60},
        new Effect("Gotta Go Fast", "gotta_go_fast"){Price = 5,Description = "Make the player go extremely fast!",Duration=60},
        new Effect("Slow Like Snail", "gotta_go_slow"){Price = 5,Description = "Make the player go very slow...",Duration=60},
        new Effect("Ice Physics!","ice_physics"){Price = 10,Description = "Make the ground freeze up and become as slippery as a skating rink!",Duration=60},
        new Effect("Go Third-Person","third_person"){Price = 5,Description = "Change the game into a third person shooter for a minute!",Duration=60},
        new Effect("Take Double Damage","dmg_double"){Price = 10,Description = "Make the player weaker so they take double damage!",Duration=60},
        new Effect("Take Half Damage","dmg_half"){Price = 5,Description = "Make the player tougher so they take half damage!",Duration=60},
        new Effect("Give Credits (x100)", "add_credits",new[]{"credits1000"}){Price = 2,Description = "Make it rain on the player and give them some spare cash!"}, //Updated for text second Crowd Control batch
        new Effect("Remove Credits (x100)", "remove_credits",new[]{"credits1000"}){Price = 5,Description = "Take some money away from the player"}, //Updated text for second Crowd Control batch
        new Effect("Upgrade a Flamethrower to a LAMThrower", "lamthrower"){Price = 30,Description = "If the player is currently carrying a flamethrower, it only shoots live LAMs instead of napalm for a minute",Duration=60},

        new Effect ("Ask a Question","ask_a_question"){Price = 5,Description = "Make a dialog box appear on screen with a question while the game continues in behind!"}, //New for second Crowd Control batch
        new Effect ("Nudge","nudge"){Price = 1,Description = "Just ever so slightly... nudge... the player in a random direction"}, //New for second Crowd Control batch
        new Effect ("Swap Player with another human","swap_player_position"){Price = 40,Description = "Finds another human somewhere in the current level and swaps their position with the player!"}, //New for second Crowd Control batch
        new Effect ("Float Away","floaty_physics"){Price = 100,Description = "Suddenly gravity feels very light and everything starts floating up into the sky...",Duration=60}, //New for second Crowd Control batch
        new Effect ("Floor is Lava","floor_is_lava"){Price = 75,Description = "Floor is lava!  If the player doesn't keep jumping or get up on top of something, they're gonna burn!",Duration=60}, //New for second Crowd Control batch
        new Effect ("Invert Mouse Controls","invert_mouse"){Price = 20,Description = "Up is down and down is up!",Duration=60}, //New for second Crowd Control batch
        new Effect ("Invert Movement Controls","invert_movement"){Price = 20,Description = "Right is left, left is right, forwards is backwards, and backwards is forwards!",Duration=60}, //New for second Crowd Control batch
        new Effect ("Earthquake","earthquake"){Price = 5,Description = "Set off a massive earthquake in the game!",Duration=60}, //New for fourth Crowd Control batch
        new Effect ("Full Bioelectric Energy","give_full_energy"){Price = 5,Description = "Completely fill the players bioelectric energy"}, //New for fourth Crowd Control batch
        new Effect ("Trigger all alarms","trigger_alarms"){Price = 5,Description = "Set off every alarm panel and security camera in the current level to make sure all the enemies are on high alert!"}, //New for fourth Crowd Control batch
        new Effect ("Flip camera upside down","flipped"){Price = 20,Description = "Australia mode",Duration=60}, //New for fourth Crowd Control batch
        new Effect ("Flip camera sideways","limp_neck"){Price = 20,Description = "Just turn the screen to the side!",Duration=60}, //New for fourth Crowd Control batch
        new Effect ("Do a barrel roll!","barrel_roll"){Price = 25,Description = "The camera does an ever so slow barrel roll over the course of a minute...",Duration=60}, //New for fourth Crowd Control batch
        new Effect ("Set off a Flashbang", "flashbang"){Price = 5,Description = "Set off a flashbang in the players face"}, //New for fourth Crowd Control batch
        new Effect ("Eat Beans", "eat_beans"){Price = 5,Description = "Force feed the player a bunch of beans and witness the consequences!",Duration=60}, //New for fourth Crowd Control batch
        new Effect ("Fire the current weapon", "fire_weapon"){Price = 5,Description = "Fire whatever weapon the player is holding!"}, //New for fourth Crowd Control batch
        new Effect ("Switch to next item", "next_item"){Price = 2,Description = "Switch to the next item in the players item belt"}, //New for fourth Crowd Control batch
        new Effect ("Switch to next HUD color scheme", "next_hud_color"){Price = 1,Description = "Maybe the current color scheme doesn't look so good?"}, //New for fourth Crowd Control batch
        new Effect ("Quick Save", "quick_save"){Price = 10,Description = "Stir up some real trouble..."}, //New for fourth Crowd Control batch
        new Effect ("Quick Load", "quick_load"){Price = 20,Description = "Hope that last quick save wasn't too far back, or in too much danger!"}, //New for fourth Crowd Control batch

        //Spawn Enemies/Allies
        new Effect("Spawn Enemies/Allies","spawnpawns",ItemKind.Folder), //New for fourth Crowd Control batch
        new Effect ("Spawn Medical Bot", "spawnfriendly_medicalbot","spawnpawns"){Price = 75,Description = "Spawn a medical bot for healing and augmentation installation"}, //New for fourth Crowd Control batch
        new Effect ("Spawn Repair Bot", "spawnfriendly_repairbot","spawnpawns"){Price = 30,Description = "Spawn a repair bot to restore bioelectric energy"}, //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Spider Bot", "spawnenemy_spiderbot2","spawnpawns"){Price = 15,Description = "Spawn a spiderbot that will hunt you down"}, //New for fourth Crowd Control batch
        new Effect ("Spawn hostile MJ12 Commando", "spawnenemy_mj12commando","spawnpawns"){Price = 10,Description = "Spawn an MJ12 Commando who will try to take you out"}, //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Security Bot", "spawnenemy_securitybot4","spawnpawns"){Price = 25,Description = "Spawn a security bot to fill you with holes"}, //New for fourth Crowd Control batch
        new Effect ("Spawn friendly Security Bot", "spawnfriendly_securitybot4","spawnpawns"){Price = 15,Description = "Spawn a security bot to help you out"}, //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Military Bot", "spawnenemy_militarybot","spawnpawns"){Price = 40,Description = "Spawn a huge military bot to blow you to pieces"}, //New for fourth Crowd Control batch
        new Effect ("Spawn friendly Military Bot", "spawnfriendly_militarybot","spawnpawns"){Price = 30,Description = "Spawn a military bot to give you a hand"}, //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Doberman", "spawnenemy_doberman","spawnpawns"){Price = 5,Description = "Spawn a doberman to tear you to shreds"}, //New for fourth Crowd Control batch
        new Effect ("Spawn hostile Greasel", "spawnenemy_greasel","spawnpawns"){Price = 10,Description = "Spawn a hostile greasel to poison you to death"}, //New for fourth Crowd Control batch

        //Items
        new Effect("Give Items","giveitems",ItemKind.Folder), //New folder for third batch
        new Effect("Give a Medkit", "give_medkit", "giveitems"){Price = 15,Description = "Give the player a medkit"}, //Moved into new folder for third batch
        new Effect("Give a Biocell", "give_bioelectriccell", "giveitems"){Price = 15,Description = "Give the player a bioelectric cell"}, //Moved into new folder for third batch
        new Effect("Give a Fire Extinguisher", "give_fireextinguisher", "giveitems"){Price = 5,Description = "Give the player a fire extinguisher"}, //New for third Crowd Control batch
        new Effect("Give a Ballistic Armor", "give_ballisticarmor", "giveitems"){Price = 5,Description = "Give the player ballistic armor"}, //New for third Crowd Control batch
        new Effect("Give a Lockpick", "give_lockpick", "giveitems"){Price = 10,Description = "Give the player a lockpick"}, //New for third Crowd Control batch
        new Effect("Give a Multitool", "give_multitool", "giveitems"){Price = 10,Description = "Give the player a multitool"}, //New for third Crowd Control batch
        new Effect("Give a Rebreather", "give_rebreather", "giveitems"){Price = 5,Description = "Give the player a rebreather"}, //New for third Crowd Control batch
        new Effect("Give a Thermoptic Camo", "give_adaptivearmor", "giveitems"){Price = 10,Description = "Give the player thermoptic camo"}, //New for third Crowd Control batch
        new Effect("Give a HazMat Suit", "give_hazmatsuit", "giveitems"){Price = 5,Description = "Give the player a hazmat suit"}, //New for third Crowd Control batch
        new Effect("Give a bottle of Wine", "give_winebottle", "giveitems"){Price = 1,Description = "Give the player a bottle of wine"}, //New for Fourth Crowd Control batch
        new Effect("Give a set of Tech Goggles", "give_techgoggles", "giveitems"){Price = 5,Description = "Give the player a set of tech goggles"}, //New for Fourth Crowd Control batch

        //Add/Remove Augs
        new Effect("Add/Upgrade Augmentations","addaugs",ItemKind.Folder),
        new Effect("Remove/Downgrade Augmentations","remaugs",ItemKind.Folder),

        new Effect("Add/Upgrade Aqualung", "add_augaqualung", "addaugs"){Price = 10,Description = "Add or upgrade the aqualung aug"},
        new Effect("Add/Upgrade Ballistic Protection", "add_augballistic", "addaugs"){Price = 40,Description = "Add or upgrade the ballistic protection aug"},
        new Effect("Add/Upgrade Cloak", "add_augcloak", "addaugs"){Price = 60,Description = "Add or upgrade the cloak aug"},
        new Effect("Add/Upgrade Combat Strength", "add_augcombat", "addaugs"){Price = 40,Description = "Add or upgrade the combat strength aug"},
        new Effect("Add/Upgrade Aggressive Defense System", "add_augdefense", "addaugs"){Price = 40,Description = "Add or upgrade the aggressive defense aug"},
        new Effect("Add/Upgrade Spy Drone", "add_augdrone", "addaugs"){Price = 30,Description = "Add or upgrade the spy drone aug"},
        new Effect("Add/Upgrade EMP Shield", "add_augemp", "addaugs"){Price = 20,Description = "Add or upgrade the EMP shield aug"},
        new Effect("Add/Upgrade Environmental Resistance", "add_augenviro", "addaugs"){Price = 10,Description = "Add or upgrade the environmental resistance aug"},
        new Effect("Add/Upgrade Regeneration", "add_aughealing", "addaugs"){Price = 60,Description = "Add or upgrade the regeneration aug"},
        new Effect("Add/Upgrade Synthetic Heart", "add_augheartlung", "addaugs"){Price = 60,Description = "Add or upgrade the synthetic heart aug"},
        new Effect("Add/Upgrade Microfibral Muscle", "add_augmuscle", "addaugs"){Price = 40,Description = "Add or upgrade the microfibral muscle aug"},
        new Effect("Add/Upgrade Power Recirculator", "add_augpower", "addaugs"){Price = 60,Description = "Add or upgrade the power recirculator aug"},
        new Effect("Add/Upgrade Radar Transparancy", "add_augradartrans", "addaugs"){Price = 60,Description = "Add or upgrade the radar transparency aug"},
        new Effect("Add/Upgrade Energy Shield", "add_augshield", "addaugs"){Price = 20,Description = "Add or upgrade the energy shield aug"},
        new Effect("Add/Upgrade Speed Enhancement", "add_augspeed", "addaugs"){Price = 60,Description = "Add or upgrade the speed enhancement aug"},
        new Effect("Add/Upgrade Run Silent", "add_augstealth", "addaugs"){Price = 10,Description = "Add or upgrade the run silent aug"},
        new Effect("Add/Upgrade Targeting", "add_augtarget", "addaugs"){Price = 10,Description = "Add or upgrade the targeting aug"},
        new Effect("Add/Upgrade Vision Enhancement", "add_augvision", "addaugs"){Price = 40,Description = "Add or upgrade the vision enhancement aug"},

        new Effect("Remove/Downgrade Aqualung", "rem_augaqualung", "remaugs"){Price = 20,Description = "Remove or downgrade the aqualung aug"},
        new Effect("Remove/Downgrade Ballistic Protection", "rem_augballistic", "remaugs"){Price = 60,Description = "Remove or downgrade the ballistic protection aug"},
        new Effect("Remove/Downgrade Cloak", "rem_augcloak", "remaugs"){Price = 60,Description = "Remove or downgrade the cloak aug"},
        new Effect("Remove/Downgrade Combat Strength", "rem_augcombat", "remaugs"){Price = 40,Description = "Remove or downgrade the combat strength aug"},
        new Effect("Remove/Downgrade Aggressive Defense System", "rem_augdefense", "remaugs"){Price = 60,Description = "Remove or downgrade the aggressive defense aug"},
        new Effect("Remove/Downgrade Spy Drone", "rem_augdrone", "remaugs"){Price = 40,Description = "Remove or downgrade the spy drone aug"},
        new Effect("Remove/Downgrade EMP Shield", "rem_augemp", "remaugs"){Price = 30,Description = "Remove or downgrade the EMP shield aug"},
        new Effect("Remove/Downgrade Environmental Resistance", "rem_augenviro", "remaugs"){Price = 20,Description = "Remove or downgrade the environmental resistance aug"},
        new Effect("Remove/Downgrade Regeneration", "rem_aughealing", "remaugs"){Price = 60,Description = "Remove or downgrade the regeneration aug"},
        new Effect("Remove/Downgrade Synthetic Heart", "rem_augheartlung", "remaugs"){Price = 70,Description = "Remove or downgrade the synthetic heart aug"},
        new Effect("Remove/Downgrade Microfibral Muscle", "rem_augmuscle", "remaugs"){Price = 60,Description = "Remove or downgrade the microfibral muscle aug"},
        new Effect("Remove/Downgrade Power Recirculator", "rem_augpower", "remaugs"){Price = 60,Description = "Remove or downgrade the power recirculator aug"},
        new Effect("Remove/Downgrade Radar Transparancy", "rem_augradartrans", "remaugs"){Price = 60,Description = "Remove or downgrade the radar transparency aug"},
        new Effect("Remove/Downgrade Energy Shield", "rem_augshield", "remaugs"){Price = 30,Description = "Remove or downgrade the energy shield aug"},
        new Effect("Remove/Downgrade Speed Enhancement", "rem_augspeed", "remaugs"){Price = 80,Description = "Remove or downgrade the speed enhancement aug"},
        new Effect("Remove/Downgrade Run Silent", "rem_augstealth", "remaugs"){Price = 20,Description = "Remove or downgrade the run silent aug"},
        new Effect("Remove/Downgrade Targeting", "rem_augtarget", "remaugs"){Price = 20,Description = "Remove or downgrade the targeting aug"},
        new Effect("Remove/Downgrade Vision Enhancement", "rem_augvision", "remaugs"){Price = 60,Description = "Remove or downgrade the vision enhancement aug"},


        //Drop Grenades
        new Effect("Drop a live grenade","dropgrenade",ItemKind.Folder),

        new Effect("Drop a Live LAM", "drop_lam", "dropgrenade"){Price = 30,Description = "Drop a LAM on the ground, ready to explode!"},
        new Effect("Drop a Live EMP Grenade", "drop_empgrenade", "dropgrenade"){Price = 10,Description = "Drop an EMP grenade on the ground, ready to take away your energy!"},
        new Effect("Drop a Live Gas Grenade", "drop_gasgrenade", "dropgrenade"){Price = 5,Description = "Drop a gas grenade on the ground, ready to irritate your mucus membranes!"},
        new Effect("Drop a Live Scrambler Grenade", "drop_nanovirusgrenade", "dropgrenade"){Price = 1,Description = "Drop a scrambler grenade on the ground, ready to take control of bots!"},


        //Weapons
        new Effect("Give Weapons","giveweapon",ItemKind.Folder),

        new Effect("Give Flamethrower", "give_weaponflamethrower", "giveweapon"){Price = 25,Description = "Give the player a flamethrower"},
        new Effect("Give GEP Gun", "give_weapongepgun", "giveweapon"){Price = 25,Description = "Give the player a GEP gun"},
        new Effect("Give Dragon Tooth Sword", "give_weaponnanosword", "giveweapon"){Price = 75,Description = "Give the player a Dragon Tooth Sword"},
        new Effect("Give Plasma Rifle", "give_weaponplasmarifle", "giveweapon"){Price = 25,Description = "Give the player a plasma rifle"},
        new Effect("Give LAW", "give_weaponlaw", "giveweapon"){Price = 25,Description = "Give the player a LAW"},
        new Effect("Give Sniper Rifle", "give_weaponrifle", "giveweapon"){Price = 10,Description = "Give the player a sniper rifle"},
        new Effect("Give Assault Rifle", "give_weaponassaultgun", "giveweapon"){Price = 5,Description = "Give the player an assault rifle"},  //New for second Crowd Control batch
        new Effect("Give Assault Shotgun", "give_weaponassaultshotgun", "giveweapon"){Price = 5,Description = "Give the player an assault shotgun"},  //New for second Crowd Control batch
        new Effect("Give Baton", "give_weaponbaton", "giveweapon"){Price = 1,Description = "Give the player a baton"},  //New for second Crowd Control batch
        new Effect("Give Combat Knife", "give_weaponcombatknife", "giveweapon"){Price = 1,Description = "Give the player a combat knife"},  //New for second Crowd Control batch
        new Effect("Give Crowbar", "give_weaponcrowbar", "giveweapon"){Price = 1,Description = "Give the player a crowbar"},  //New for second Crowd Control batch
        new Effect("Give Mini Crossbow", "give_weaponminicrossbow", "giveweapon"){Price = 1,Description = "Give the player a mini crossbow"},  //New for second Crowd Control batch
        new Effect("Give Pepper Spray", "give_weaponpeppergun", "giveweapon"){Price = 1,Description = "Give the player pepper spray"},  //New for second Crowd Control batch
        new Effect("Give Pistol", "give_weaponpistol", "giveweapon"){Price = 1,Description = "Give the player a pistol"},  //New for second Crowd Control batch
        new Effect("Give Stealth Pistol", "give_weaponstealthpistol", "giveweapon"){Price = 1,Description = "Give the player a stealth pistol"},  //New for second Crowd Control batch
        new Effect("Give Riot Prod", "give_weaponprod", "giveweapon"){Price = 1,Description = "Give the player a riot prod"},  //New for second Crowd Control batch
        new Effect("Give Sawed-off Shotgun", "give_weaponsawedoffshotgun", "giveweapon"){Price = 5,Description = "Give the player a sawed-off shotgun"},  //New for second Crowd Control batch
        new Effect("Give Throwing Knives", "give_weaponshuriken", "giveweapon"){Price = 5,Description = "Give the player throwing knives"},  //New for second Crowd Control batch
        new Effect("Give Sword", "give_weaponsword", "giveweapon"){Price = 1,Description = "Give the player a sword"},  //New for second Crowd Control batch
        new Effect("Give LAM", "give_weaponlam", "giveweapon"){Price = 10,Description = "Give the player a LAM"},  //New for second Crowd Control batch
        new Effect("Give EMP Grenade", "give_weaponempgrenade", "giveweapon"){Price = 5,Description = "Give the player an EMP grenade"},  //New for second Crowd Control batch
        new Effect("Give Gas Grenade", "give_weapongasgrenade", "giveweapon"){Price = 2,Description = "Give the player a gas grenade"},  //New for second Crowd Control batch
        new Effect("Give Scrambler Grenade", "give_weaponnanovirusgrenade", "giveweapon"){Price = 5,Description = "Give the player a scrambler grenade"},  //New for second Crowd Control batch
        new Effect("Give PS40","give_weaponhideagun","giveweapon"){Price = 10,Description = "Give the player a PS40"},

        //Ammo
        new Effect("Give Ammo","giveammo",ItemKind.Folder),

        new Effect("Give 10mm Ammo (Pistols)", "give_ammo10mm",new[]{"amount100"},"giveammo"){Price = 5,Description = "Give the player some 10mm ammo"}, //New for second Crowd Control batch
        new Effect("Give 20mm Ammo (Assault Rifle)", "give_ammo20mm",new[]{"amount100"},"giveammo"){Price = 15,Description = "Give the player some 20mm high explosive ammo"}, //New for second Crowd Control batch
        new Effect("Give 7.62mm Ammo (Assault Rifle)", "give_ammo762mm",new[]{"amount100"},"giveammo"){Price = 5,Description = "Give the player some 7.62mm ammo"}, //New for second Crowd Control batch
        new Effect("Give 30.06mm Ammo (Sniper Rifle)", "give_ammo3006",new[]{"amount100"},"giveammo"){Price = 5,Description = "Give the player some 30.06mm ammo"}, //New for second Crowd Control batch
        new Effect("Give Prod Charger", "give_ammobattery",new[]{"amount100"},"giveammo"){Price = 5,Description = "Give the player a prod charger"}, //New for second Crowd Control batch
        new Effect("Give Darts", "give_ammodart",new[]{"amount100"},"giveammo"){Price = 5,Description = "Give the player some darts"}, //New for second Crowd Control batch
        new Effect("Give Flare Darts", "give_ammodartflare",new[]{"amount100"},"giveammo"){Price = 5,Description = "Give the player some flare darts"}, //New for second Crowd Control batch
        new Effect("Give Tranq Darts", "give_ammodartpoison",new[]{"amount100"},"giveammo"){Price = 5,Description = "Give the player some tranquilizer darts"}, //New for second Crowd Control batch
        new Effect("Give Napalm", "give_ammonapalm",new[]{"amount100"},"giveammo"){Price = 10,Description = "Give the player some napalm"}, //New for second Crowd Control batch
        new Effect("Give Pepper Spray Ammo", "give_ammopepper",new[]{"amount100"},"giveammo"){Price = 1,Description = "Give the player some pepper spray ammo"}, //New for second Crowd Control batch
        new Effect("Give Plasma", "give_ammoplasma",new[]{"amount100"},"giveammo"){Price = 10,Description = "Give the player some plasma ammo"}, //New for second Crowd Control batch
        new Effect("Give Rockets", "give_ammorocket",new[]{"amount100"},"giveammo"){Price = 10,Description = "Give the player some rockets"}, //New for second Crowd Control batch
        new Effect("Give WP Rockets", "give_ammorocketwp",new[]{"amount100"},"giveammo"){Price = 15,Description = "Give the player some WP rockets"}, //New for second Crowd Control batch
        new Effect("Give Sabot Shells", "give_ammosabot",new[]{"amount100"},"giveammo"){Price = 20,Description = "Give the player some Sabot shells"}, //New for second Crowd Control batch
        new Effect("Give Shotgun Shells", "give_ammoshell",new[]{"amount100"},"giveammo"){Price = 5,Description = "Give the player some shotgun shells"} //New for second Crowd Control batch
    };

    //Slider ranges need to be defined
    public override List<ItemType> ItemTypes => new List<ItemType>(new[]
    {
        new ItemType("Credits", "credits1000", ItemType.Subtype.Slider, "{\"min\":1,\"max\":1000}"),
        new ItemType("Skill Points", "skillpoints1000", ItemType.Subtype.Slider, "{\"min\":1,\"max\":1000}"),
        new ItemType("Amount","amount100",ItemType.Subtype.Slider, "{\"min\":1,\"max\":100}")
    });
}
