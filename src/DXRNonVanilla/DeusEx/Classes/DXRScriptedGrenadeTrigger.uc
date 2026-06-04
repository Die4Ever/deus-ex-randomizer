#compileif gmdx
//This trigger replacement is an attempt to fix ADS setting off the hidden, scripted grenades
class DXRScriptedGrenadeTrigger extends ScriptedGrenadeTrigger;

function BeginPlay()
{
    local GasGrenade gg;

    Super.BeginPlay();

    foreach RadiusActors(class'GasGrenade', gg, CheckGasRadius)
    {
        if (!gg.bScriptedGrenade) continue;

        gg.SetOwner(GetPlayerPawn()); //Mark them as belonging to the player so that ADS doesn't set them off
    }
}

function Touch(Actor Other)
{
    local GasGrenade grens[5];
    local GasGrenade gg;
    local int i;

    //Track any nearby scripted grenades
    //I'm pretty sure there's usually only one grenade nearby, but let's be generous
    foreach RadiusActors(class'GasGrenade', gg, CheckGasRadius)
    {
        if (!gg.bScriptedGrenade) continue;
        if (i>=ArrayCount(grens)) break;
        grens[i++]=gg;
    }

    Super.Touch(Other);

    for (i=0;i<ArrayCount(grens);i++){
        if (grens[i]==None) continue;

        //Grenades clear their bScriptedGrenade after being thrown, so ignore ones that still have it set
        if (grens[i].bScriptedGrenade) continue;

        //Clear the owner so ADS works again
        grens[i].SetOwner(None);
    }
}
