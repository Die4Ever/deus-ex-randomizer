//=============================================================================
// HealingItem.
//=============================================================================
class HealingItem extends DeusExPickup;

var int health;
var float energy;
var float drugEffect;

function DoHeal(DeusExPlayer player)
{
    local int i;
    local float f;
    local string message;

    if (player == None) return;

    player.drugEffectTimer += drugEffect;

    if( health > 0 ) {
        i = player.HealPlayer(health, False);
        message = "Healed "$ i $" point";
        if(i > 1)
            message = message $ "s";
    }

    f = FMin( energy, player.EnergyMax - player.Energy);
    if( f > 0 ) {
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
        local DeusExPlayer player;
        
        Super.BeginState();

        player = DeusExPlayer(Owner);
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
    energy=0
    drugEffect=5.0
}
