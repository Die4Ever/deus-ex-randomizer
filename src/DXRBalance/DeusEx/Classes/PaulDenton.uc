class DXRPaulDenton injects PaulDenton;

// if his shields are down, allow him to be stunned/gassed
function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    if(ShieldDamage(damageType) < 1) {
        if(EmpHealth > 0) {
            MaybeDrawShield();
            Super.GotoDisabledState(damageType, hitPos);
        }
        else
            Super(HumanMilitary).GotoDisabledState(damageType, hitPos);
    } else {
        Super.GotoDisabledState(damageType, hitPos);
    }
}


#ifndef vmd
function ResetSkinStyle()
{
    local DXRFashionManager fashion;
    local #var(PlayerPawn) p;

    //This normally resets the textures to defaults (But does not change the mesh, obv)
    Super.ResetSkinStyle();

    //Make sure he's dressed
    foreach AllActors(class'#var(PlayerPawn)',p) break;
    fashion = class'DXRFashionManager'.static.GiveItem(p);
    if (fashion!=None){
        fashion.GetDressed();
    }
}
#endif
