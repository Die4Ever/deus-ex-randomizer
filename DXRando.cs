using System;
using System.Collections.Generic;
using CrowdControl.Common;
using CrowdControl.Games.Packs;
using ConnectorType = CrowdControl.Common.ConnectorType;

public class DXRando : SimpleTCPPack
{
    public override string Host => "0.0.0.0";

    public override ushort Port => 43384;

    public DXRando(IPlayer player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler) : base(player, responseHandler, statusUpdateHandler) { }

    public override Game Game => new Game(90, "Deus Ex Randomizer", "DeusEx", "PC", ConnectorType.SimpleTCPConnector);

    public override List<Effect> Effects => new List<Effect>
    {

        //General Effects
        new Effect("Trigger the Killswitch", "kill"),
        new Effect("Poison the Player", "poison"),
        new Effect("Glass Legs", "glass_legs"),
        new Effect("Give Health", "give_health",new[]{"amount"}),
        new Effect("Set On Fire", "set_fire"),
        new Effect("Give one Medkit", "give_medkit"),
        new Effect("Full Heal", "full_heal"),
        new Effect("Drunk Mode (1 minute)", "drunk_mode"),
        new Effect("Drop Selected Item", "drop_selected_item"), 
        new Effect("Enable Matrix Mode (1 Minute)", "matrix"),        
        new Effect("Give Player EMP Field (15 seconds)", "emp_field"),
        new Effect("Give Bioelectric Energy", "give_energy",new[]{"amount"}),
        new Effect("Give one Biocell", "give_biocell"),
        new Effect("Give 100 skill points", "give_skillpoints",new[]{"spslider"}), //Updated text for second Crowd Control batch
        new Effect("Remove 100 skill points", "remove_skillpoints",new[]{"spslider"}), //Updated text for second Crowd Control batch
        new Effect("Disable Jump (1 minute)", "disable_jump"),
        new Effect("Gotta go fast (1 minute)", "gotta_go_fast"),
        new Effect("Slow like snail (1 minute)", "gotta_go_slow"),
        new Effect("Ice Physics! (1 minute)","ice_physics"),
        new Effect("Go Third-Person (1 minute)","third_person"),
        new Effect("Take Double Damage (1 minute)","dmg_double"),
        new Effect("Take Half Damage (1 minute)","dmg_half"),
        new Effect("Give 100 credits", "add_credits",new[]{"creditsslider"}), //Updated for text second Crowd Control batch
        new Effect("Remove 100 credits", "remove_credits",new[]{"creditsslider"}), //Updated text for second Crowd Control batch      
        new Effect("Upgrade a Flamethrower to a LAMThrower (1 minute)", "lamthrower"),
        
        new Effect ("Ask a Question","ask_a_question"), //New for second Crowd Control batch
        new Effect ("Nudge","nudge"), //New for second Crowd Control batch
        new Effect ("Swap Player with another human","swap_player_position"), //New for second Crowd Control batch
        new Effect ("Float Away","floaty_physics"), //New for second Crowd Control batch
        new Effect ("Floor is Lava","floor_is_lava"), //New for second Crowd Control batch
        new Effect ("Invert Mouse Controls","invert_mouse"), //New for second Crowd Control batch
        new Effect ("Invert Movement Controls","invert_movement"), //New for second Crowd Control batch
                
        //Add/Remove Augs
        new Effect("Add/Upgrade Augmentations","addaugs",ItemKind.Folder),
        new Effect("Remove/Downgrade Augmentations","remaugs",ItemKind.Folder),
        
        new Effect("Add/Upgrade Aqualung", "add_aqualung", "addaugs"),
        new Effect("Add/Upgrade Ballistic Protection", "add_ballistic", "addaugs"),
        new Effect("Add/Upgrade Cloak", "add_cloak", "addaugs"),
        new Effect("Add/Upgrade Combat Strength", "add_combat", "addaugs"),
        new Effect("Add/Upgrade Aggressive Defense System", "add_defense", "addaugs"),
        new Effect("Add/Upgrade Spy Drone", "add_drone", "addaugs"),
        new Effect("Add/Upgrade EMP Shield", "add_emp", "addaugs"),
        new Effect("Add/Upgrade Environmental Resistance", "add_enviro", "addaugs"),
        new Effect("Add/Upgrade Regeneration", "add_healing", "addaugs"),
        new Effect("Add/Upgrade Synthetic Heart", "add_heartlung", "addaugs"),
        new Effect("Add/Upgrade Microfibral Muscle", "add_muscle", "addaugs"),
        new Effect("Add/Upgrade Power Recirculator", "add_power", "addaugs"),
        new Effect("Add/Upgrade Radar Transparancy", "add_radartrans", "addaugs"),
        new Effect("Add/Upgrade Energy Shield", "add_shield", "addaugs"),
        new Effect("Add/Upgrade Speed Enhancement", "add_speed", "addaugs"),
        new Effect("Add/Upgrade Run Silent", "add_stealth", "addaugs"),
        new Effect("Add/Upgrade Targeting", "add_target", "addaugs"),
        new Effect("Add/Upgrade Vision Enhancement", "add_vision", "addaugs"),

        new Effect("Remove/Downgrade Aqualung", "rem_aqualung", "remaugs"),
        new Effect("Remove/Downgrade Ballistic Protection", "rem_ballistic", "remaugs"),
        new Effect("Remove/Downgrade Cloak", "rem_cloak", "remaugs"),
        new Effect("Remove/Downgrade Combat Strength", "rem_combat", "remaugs"),
        new Effect("Remove/Downgrade Aggressive Defense System", "rem_defense", "remaugs"),
        new Effect("Remove/Downgrade Spy Drone", "rem_drone", "remaugs"),
        new Effect("Remove/Downgrade EMP Shield", "rem_emp", "remaugs"),
        new Effect("Remove/Downgrade Environmental Resistance", "rem_enviro", "remaugs"),
        new Effect("Remove/Downgrade Regeneration", "rem_healing", "remaugs"),
        new Effect("Remove/Downgrade Synthetic Heart", "rem_heartlung", "remaugs"),
        new Effect("Remove/Downgrade Microfibral Muscle", "rem_muscle", "remaugs"),
        new Effect("Remove/Downgrade Power Recirculator", "rem_power", "remaugs"),
        new Effect("Remove/Downgrade Radar Transparancy", "rem_radartrans", "remaugs"),
        new Effect("Remove/Downgrade Energy Shield", "rem_shield", "remaugs"),
        new Effect("Remove/Downgrade Speed Enhancement", "rem_speed", "remaugs"),
        new Effect("Remove/Downgrade Run Silent", "rem_stealth", "remaugs"),
        new Effect("Remove/Downgrade Targeting", "rem_target", "remaugs"),
        new Effect("Remove/Downgrade Vision Enhancement", "rem_vision", "remaugs"),

        
        //Drop Grenades
        new Effect("Drop a live grenade","dropgrenade",ItemKind.Folder),
        
        new Effect("Drop a live LAM", "drop_lam", "dropgrenade"),
        new Effect("Drop a live EMP Grenade", "drop_emp", "dropgrenade"),
        new Effect("Drop a live Gas Grenade", "drop_gas", "dropgrenade"),
        new Effect("Drop a live Scrambler Grenade", "drop_scrambler", "dropgrenade"),


        //Weapons
        new Effect("Give Weapons","giveweapon",ItemKind.Folder),
        
        new Effect("Give Flamethrower", "give_flamethrower", "giveweapon"),
        new Effect("Give GEP Gun", "give_gep", "giveweapon"),
        new Effect("Give Dragon Tooth Sword", "give_dts", "giveweapon"),
        new Effect("Give Plasma Rifle", "give_plasma", "giveweapon"),
        new Effect("Give LAW", "give_law", "giveweapon"),
        new Effect("Give Sniper Rifle", "give_sniper", "giveweapon"),
        new Effect("Give Assault Rifle", "give_assaultgun", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Assault Shotgun", "give_assaultshotgun", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Baton", "give_baton", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Combat Knife", "give_knife", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Crowbar", "give_crowbar", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Mini Crossbow", "give_crossbow", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Pepper Spray", "give_pepperspray", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Pistol", "give_pistol", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Stealth Pistol", "give_stealthpistol", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Riot Prod", "give_prod", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Sawed-off Shotgun", "give_sawedoff", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Throwing Knives", "give_shuriken", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Sword", "give_sword", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give LAM", "give_lam", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give EMP Grenade", "give_emp", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Gas Grenade", "give_gas", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give Scrambler Grenade", "give_scrambler", "giveweapon"),  //New for second Crowd Control batch
        new Effect("Give PS40","give_ps40","giveweapon"),
        
        //Ammo
        new Effect("Give Ammo","giveammo",ItemKind.Folder),

        new Effect("Give 10mm Ammo (Pistols)", "ammo10mm",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give 20mm Ammo (Assault Rifle)", "ammo20mm",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give 7.62mm Ammo (Assault Rifle)", "ammo762mm",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give 30.06mm Ammo (Sniper Rifle)", "ammo3006",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Prod Charger", "ammobattery",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Darts", "ammodart",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Flare Darts", "ammodartflare",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Tranq Darts", "ammodartpoison",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Napalm", "ammonapalm",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Pepper Spray Ammo", "ammopepper",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Plasma", "ammoplasma",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Rockets", "ammorocket",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give WP Rockets", "ammorocketwp",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Sabot Shells", "ammosabot",new[]{"amount"},"giveammo"), //New for second Crowd Control batch
        new Effect("Give Shotgun Shells", "ammoshell",new[]{"amount"},"giveammo"), //New for second Crowd Control batch

    };
    
    //Slider ranges need to be defined
    public override List<ItemType> ItemTypes => new List<ItemType>(new[]
    {
        new ItemType("Credits", "creditsslider", ItemType.Subtype.Slider, "{\"min\":1,\"max\":1000}"),
        new ItemType("Skill Points", "spslider", ItemType.Subtype.Slider, "{\"min\":1,\"max\":1000}"),
        new ItemType("Amount","amount",ItemType.Subtype.Slider, "{\"min\":1,\"max\":100}"),
    });
}
