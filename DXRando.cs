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

    public override Game Game => new Game(54, "Deus Ex Randomizer", "dxrando", "PC", ConnectorType.SimpleTCPConnector);

    public override List<Effect> Effects => new List<Effect>
    {
        new Effect("Trigger the Killswitch", "kill"),
        new Effect("Poison the Player", "poison"),
        new Effect("Glass Legs", "glass_legs"),
        new Effect("Give Health (50)", "give_health"),
        new Effect("Set On Fire", "set_fire"),
        new Effect("Drop a LAM", "drop_lam"),
        new Effect("Give one Medkit", "give_medkit"),
        new Effect("Full Heal", "full_heal"),
        new Effect("Drunk Mode (1 minute)", "drunk_mode"),
        new Effect("Drop Selected Item", "drop_selected_item"), 
        new Effect("Enable Matrix Mode (1 Minute)", "matrix"),        
        new Effect("Give Player EMP Field (15 seconds)", "emp_field"),
        new Effect("Give Bioelectric Energy (10)", "give_energy"),
        new Effect("Give one Biocell", "give_biocell"),
        new Effect("Give 100 skill points", "give_skillpoints"),
        new Effect("Remove 100 skill points", "remove_skillpoints"),
        new Effect("Disable Jump (1 minute)", "disable_jump"),
        new Effect("Gotta go fast (1 minute)", "gotta_go_fast"),
        new Effect("Slow like snail (1 minute)", "gotta_go_slow"),
        new Effect("Ice Physics! (1 minute)","ice_physics"),
        new Effect("Upgrade a Flamethrower to a LAMThrower (1 minute)", "lamthrower"),

        new Effect("Give Flamethrower","give_flamethrower"),
        new Effect("Give GEP Gun","give_gep"),
        new Effect("Give Dragon Tooth Sword","give_dts"),
        new Effect("Give LAM","give_lam"),
        new Effect("Give EMP Grenade","give_emp"),
        new Effect("Give Scrambler Grenade","give_scrambler"),
        new Effect("Give Gas Grenade","give_gas"),
        new Effect("Give Plasma Rifle","give_plasma"),
        new Effect("Give LAW","give_law"),
        new Effect("Give PS40","give_ps40"),
        new Effect("Give Aug Upgrade Canister","give_aug_up"),
		
        new Effect("Add/Upgrade Aqualung Aug","up_aqualung"),
        new Effect("Add/Upgrade Ballistic Protection Aug","up_ballistic"),
        new Effect("Add/Upgrade Cloak Aug","up_cloak"),
        new Effect("Add/Upgrade Combat Strength Aug","up_combat"),
        new Effect("Add/Upgrade Aggressive Defense Aug","up_defense"),
        new Effect("Add/Upgrade Spy Drone Aug","up_drone"),
        new Effect("Add/Upgrade EMP Shield Aug","up_emp"),
        new Effect("Add/Upgrade Environmental Resistance Aug","up_enviro"),
        new Effect("Add/Upgrade Regeneration Aug","up_healing"),		
        new Effect("Add Synthetic Heart Aug","up_heartlung"),
        new Effect("Add/Upgrade Microfibral Muscle Aug","up_muscle"),
        new Effect("Add/Upgrade Power Recirculator Aug","up_power"),
        new Effect("Add/Upgrade Radar Transparency Aug","up_radartrans"),
        new Effect("Add/Upgrade Energy Shield Aug","up_shield"),
        new Effect("Add/Upgrade Speed Enhancement Aug","up_speed"),
        new Effect("Add/Upgrade Run Silent Aug","up_stealth"),
        new Effect("Add/Upgrade Targeting Aug","up_target"),
        new Effect("Add/Upgrade Vision Enhancement Aug","up_vision"),

        new Effect("Remove/Downgrade Aqualung Aug","down_aqualung"),
        new Effect("Remove/Downgrade Ballistic Protection Aug","down_ballistic"),
        new Effect("Remove/Downgrade Cloak Aug","down_cloak"),
        new Effect("Remove/Downgrade Combat Strength Aug","down_combat"),
        new Effect("Remove/Downgrade Aggressive Defense Aug","down_defense"),
        new Effect("Remove/Downgrade Spy Drone Aug","down_drone"),
        new Effect("Remove/Downgrade EMP Shield Aug","down_emp"),
        new Effect("Remove/Downgrade Environmental Resistance Aug","down_enviro"),
        new Effect("Remove/Downgrade Regeneration Aug","down_healing"),		
        new Effect("Remove Synthetic Heart Aug","down_heartlung"),
        new Effect("Remove/Downgrade Microfibral Muscle Aug","down_muscle"),
        new Effect("Remove/Downgrade Power Recirculator Aug","down_power"),
        new Effect("Remove/Downgrade Radar Transparency Aug","down_radartrans"),
        new Effect("Remove/Downgrade Energy Shield Aug","down_shield"),
        new Effect("Remove/Downgrade Speed Enhancement Aug","down_speed"),
        new Effect("Remove/Downgrade Run Silent Aug","down_stealth"),
        new Effect("Remove/Downgrade Targeting Aug","down_target"),
        new Effect("Remove/Downgrade Vision Enhancement Aug","down_vision"),

    };
}
