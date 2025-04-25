// A type of fire that will actually set other things on fire when it touches them

class DXRBurningFire extends SmokelessFire;

function Touch(actor Other)
{
    local #var(DeusExPrefix)Decoration deco;

    deco = #var(DeusExPrefix)Decoration(Other);
    if (deco!=None && deco.bFlammable && deco.FragType==Class'DeusEx.PaperFragment'){
        deco.GotoState('Burning');
    }
}

defaultproperties
{
     bCollideActors=True;
     CollisionRadius=5.000000
     CollisionHeight=5.000000
}
