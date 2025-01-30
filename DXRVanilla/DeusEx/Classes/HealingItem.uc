//=============================================================================
// HealingItem.
//=============================================================================
class HealingItem extends DeusExPickup;
// base class, ONLY used for alcohol, I would rename this class but it would break compatibility

var int health;
var int vanillaHealth;
var float energy; // ignored when BalanceItems is disabled
var float drugEffect;

function DoHeal(Human player)
{
    local int i;
    local float f;
    local string message;
    local bool balance;

    if (player == None) return;

    player.drugEffectTimer += drugEffect;
    balance = class'MenuChoice_BalanceItems'.static.IsEnabled();

    if(!balance) health = vanillaHealth;

    if( health > 0 ) {
        i = player._HealPlayer(health, false, balance);// balance bool used for heal legs
        message = "Healed "$ i $" point";
        if(i > 1)
            message = message $ "s";
    }

    f = FMin( energy, player.EnergyMax - player.Energy);
    if( f > 0 && balance ) {
        if( Len(message) > 0 )
            message = message $ ", recharged ";
        else
            message = "Recharged ";

        player.Energy += f;
        message = message $ int(f) $ " point";
        if( int(f) > 1 )
            message = message $"s";
    }

    if( Len(message) > 0 )
        player.ClientMessage(message);
}

state Activated
{
    function Activate()
    {
        // can't turn it off
    }

    function BeginState()
    {
        local Human player;

        Super.BeginState();

        player = Human(Owner);
        DoHeal(player);

        UseOnce();
    }
Begin:
}

defaultproperties
{
    bBreakable=True
    maxCopies=10
    bCanHaveMultipleCopies=True
    bActivatable=True
    ItemName="Healing Item"
    ItemArticle="a"
    PlayerViewOffset=(X=30.000000,Z=-12.000000)
    LandSound=Sound'DeusExSounds.Generic.GlassHit1'
    largeIconWidth=36
    largeIconHeight=48
    Description="A generic healing item."
    beltDescription="HEAL"
    CollisionRadius=4.060000
    CollisionHeight=16.180000
    Mass=10.000000
    Buoyancy=8.000000
    health=2
    vanillaHealth=2
    energy=0
    drugEffect=5.0
}
