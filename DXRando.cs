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
    };
}
