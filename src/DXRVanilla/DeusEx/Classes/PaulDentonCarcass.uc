class DXRPaulDentonCarcass injects PaulDentonCarcass;

function SetSkin(DeusExPlayer player)
{
    local int i;
    local DXRFashionManager fashion;

    Super.SetSkin(player);

    if( player == None ) {
        return;
    }

    //FASHION!
    fashion = class'DXRFashionManager'.static.GiveItem(#var(PlayerPawn)(player));
    if (fashion!=None){
        fashion.GetDressed();
    }
}

// Make paul's lifeless body even more mortal so it can be picked up for the "PaulToTong" goal.
// It could be made bInvincible again after calling Super.Frob, but keeping the corpse intact after finding it is
// probably a fair, and minor, challenge.
function Frob(Actor frobber, Inventory frobWith)
{
    bInvincible = false;
    Super.Frob(frobber, frobWith);
}
