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
        new Effect("Trigger the Killswitch", "kill"),
        new Effect("Poison the Player", "poison"),
        new Effect("Glass Legs", "glass_legs"),
        new Effect("Give Health", "give_health",new[]{"amount"}),
        new Effect("Set On Fire", "set_fire"),
        new Effect("Drop a live grenade", "drop_grenade",new[]{"grenades"}),
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

        new Effect("Give Grenade","give_grenade",new[]{"grenades"}),
        new Effect("Give Weapon","give_weapon",new[]{"weapons"}),
        new Effect("Give PS40","give_ps40"),

        new Effect ("Add/Upgrade Aug","up_aug",new[] { "augs" }),
        new Effect ("Remove/Downgrade Aug","down_aug",new[] { "augs" }),
        
        new Effect ("Ask a Question","ask_a_question"), //New for second Crowd Control batch
        new Effect ("Nudge","nudge"), //New for second Crowd Control batch
        new Effect ("Swap Player with another human","swap_player_position"), //New for second Crowd Control batch
        new Effect ("Float Away","floaty_physics"), //New for second Crowd Control batch
        new Effect ("Floor is Lava","floor_is_lava"), //New for second Crowd Control batch
        new Effect ("Invert Mouse Controls","invert_mouse"), //New for second Crowd Control batch
        new Effect ("Invert Movement Controls","invert_movement"), //New for second Crowd Control batch
        new Effect ("Give Ammo","give_ammo",new[] { "ammo","amount" }),  //New for second Crowd Control batch
        
        //Start of list elements
        
        //Augs
        new Effect("Aqualung", "aqualung", ItemKind.Usable, "augs"),
        new Effect("Ballistic Protection", "ballistic", ItemKind.Usable, "augs"),
        new Effect("Cloak", "cloak", ItemKind.Usable, "augs"),
        new Effect("Combat Strength", "combat", ItemKind.Usable, "augs"),
        new Effect("Aggressive Defense System", "defense", ItemKind.Usable, "augs"),
        new Effect("Spy Drone", "drone", ItemKind.Usable, "augs"),
        new Effect("EMP Shield", "emp", ItemKind.Usable, "augs"),
        new Effect("Environmental Resistance", "enviro", ItemKind.Usable, "augs"),
        new Effect("Regeneration", "healing", ItemKind.Usable, "augs"),
        new Effect("Synthetic Heart", "heartlung", ItemKind.Usable, "augs"),
        new Effect("Microfibral Muscle", "muscle", ItemKind.Usable, "augs"),
        new Effect("Power Recirculator", "power", ItemKind.Usable, "augs"),
        new Effect("Radar Transparancy", "radartrans", ItemKind.Usable, "augs"),
        new Effect("Energy Shield", "shield", ItemKind.Usable, "augs"),
        new Effect("Speed Enhancement", "speed", ItemKind.Usable, "augs"),
        new Effect("Run Silent", "stealth", ItemKind.Usable, "augs"),
        new Effect("Targeting", "target", ItemKind.Usable, "augs"),
        new Effect("Vision Enhancement", "vision", ItemKind.Usable, "augs"),

        //Grenades
        new Effect("LAM", "g_lam", ItemKind.Usable, "grenades"),
        new Effect("EMP", "g_emp", ItemKind.Usable, "grenades"),
        new Effect("Gas", "g_gas", ItemKind.Usable, "grenades"),
        new Effect("Scrambler", "g_scrambler", ItemKind.Usable, "grenades"),
        
        //Weapons (More valuable ones)
        new Effect("Flamethrower", "flamethrower", ItemKind.Usable, "weapons"),
        new Effect("GEP Gun", "gep", ItemKind.Usable, "weapons"),
        new Effect("Dragon Tooth Sword", "dts", ItemKind.Usable, "weapons"),
        new Effect("Plasma Rifle", "plasma", ItemKind.Usable, "weapons"),
        new Effect("LAW", "law", ItemKind.Usable, "weapons"),
        new Effect("Sniper Rifle", "sniper", ItemKind.Usable, "weapons"),
        new Effect("Assault Rifle", "assaultgun", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Assault Shotgun", "assaultshotgun", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Baton", "baton", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Combat Knife", "knife", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Crowbar", "crowbar", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Mini Crossbow", "crossbow", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Pepper Spray", "pepperspray", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Pistol", "pistol", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Stealth Pistol", "stealthpistol", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Riot Prod", "prod", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Sawed-off Shotgun", "sawedoff", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Throwing Knives", "shuriken", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        new Effect("Sword", "sword", ItemKind.Usable, "weapons"),  //New for second Crowd Control batch
        
        //Ammo
        new Effect("10mm Ammo (Pistols)", "ammo10mm", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("20mm Ammo (Assault Rifle)", "ammo20mm", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("7.62mm Ammo (Assault Rifle)", "ammo762mm", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("30.06mm Ammo (Sniper Rifle)", "ammo3006", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Prod Charger", "ammobattery", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Darts", "ammodart", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Flare Darts", "ammodartflare", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Tranq Darts", "ammodartpoison", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Napalm", "ammonapalm", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Pepper Spray", "ammopepper", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Plasma", "ammoplasma", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Rockets", "ammorocket", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("WP Rockets", "ammorocketwp", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Sabot Shells", "ammosabot", ItemKind.Usable, "ammo"), //New for second Crowd Control batch
        new Effect("Shotgun Shells", "ammoshell", ItemKind.Usable, "ammo"), //New for second Crowd Control batch


    };
    
    public override List<ItemType> ItemTypes => new List<ItemType>(new[]
    {
        new ItemType("Credits", "creditsslider", ItemType.Subtype.Slider, "{\"min\":1,\"max\":9999}"),
        new ItemType("Skill Points", "spslider", ItemType.Subtype.Slider, "{\"min\":1,\"max\":9999}"),
        new ItemType("Amount","amount",ItemType.Subtype.Slider, "{\"min\":1,\"max\":100}"),
        new ItemType("Augmentation", "augs", ItemType.Subtype.ItemList),
        new ItemType("Grenades", "grenades", ItemType.Subtype.ItemList),
        new ItemType("Weapons", "weapons", ItemType.Subtype.ItemList),
        new ItemType("Ammo", "ammo", ItemType.Subtype.ItemList), //New for second Crowd Control batch

    });
}
