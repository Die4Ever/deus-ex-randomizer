class DXRPaulDentonCarcass injects PaulDentonCarcass;

function PostPostBeginPlay()
{
    local DXRFashionManager fashion;
    local #var(PlayerPawn) p;

    Super.PostPostBeginPlay();

    //Make sure he's dressed
    foreach AllActors(class'#var(PlayerPawn)',p) break;
    fashion = class'DXRFashionManager'.static.GiveItem(p);
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
