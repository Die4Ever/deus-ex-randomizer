class DXRWeaponMods extends DXRActorsBase transient;

struct RandomModStruct { var class<#var(prefix)WeaponMod> type; var float chance; };
var RandomModStruct randommods[8];

var config float min_rate_adjust, max_rate_adjust;

function class<#var(prefix)WeaponMod> PickRandomMod()
{
    local class<#var(prefix)WeaponMod> newmod;
    local float r;
    local int i;

    newmod=None;

    r = initchance();
    for (i=0;i<ArrayCount(randommods);i++){
        if(chance(randommods[i].chance,r)) newmod = randommods[i].type;
    }

    if (newmod==None){
        //Shouldn't happen, but...
        err("Failed to pick a random weapon mod");
        newmod=randommods[0].type;
    }

    return newmod;
}

function AddRandomMod(class<#var(prefix)WeaponMod> mod, float c)
{
    local int i;
    for(i=0;i < ArrayCount(randommods);i++){
        if (randommods[i].type==None){
            randommods[i].type=mod;
            randommods[i].chance=rngrangeseeded(c,min_rate_adjust,max_rate_adjust,mod.name) ** 2;
            return;
        }
    }
}

function CheckConfig()
{
    local float total;
    local int i;

    Super.CheckConfig();

    //This is the vanilla count of each mod through the game
    AddRandomMod(class'#var(prefix)WeaponModAccuracy',14);
    AddRandomMod(class'#var(prefix)WeaponModClip',10);
    AddRandomMod(class'#var(prefix)WeaponModRange',7);
    AddRandomMod(class'#var(prefix)WeaponModRecoil',10);
    AddRandomMod(class'#var(prefix)WeaponModReload',8);
    AddRandomMod(class'#var(prefix)WeaponModScope',3);
    AddRandomMod(class'#var(prefix)WeaponModSilencer',5);
    AddRandomMod(class'#var(prefix)WeaponModLaser',6);

    //Scale to 100%
    total=0;
    for(i=0;i<ArrayCount(randommods);i++)
    {
        total += randommods[i].chance;
    }
    for(i=0;i<ArrayCount(randommods);i++)
    {
        randommods[i].chance *= 100.0/total;
    }
}

function bool IsValidModClass(class<Actor> mod){
    if (mod==None){ return False;}

    if (!ClassIsChildOf(mod,class'#var(prefix)WeaponMod')){
        return False;
    }

    //Mod in VMD.  Very uncommon, kind of an easter egg.  Ignore them for now
    if (mod.name=='WeaponModEvolution'){
        return False;
    }

    return True;
}

function FirstEntry()
{
    local #var(prefix)WeaponMod mod;
    local #var(prefix)WeaponMod mods[16];
    local Containers container;
    local class<#var(prefix)WeaponMod> newMod;
    local int i;

    Super.FirstEntry();
    if(dxr.flags.IsZeroRando()) return;

    SetSeed("RandoWeaponMods");

    i=0;
    foreach AllActors(class'#var(prefix)WeaponMod',mod)
    {
        if (!IsValidModClass(mod.class)){
            continue;
        }
        if (mod.Owner==None && !mod.bIsSecretGoal){
            mods[i++]=mod;
        }
    }

    for (i=0;mods[i]!=None;i++){
        newMod = PickRandomMod();
        if (newMod == mods[i].Class){
            l("WeaponMod "$mods[i].name$" not changing type");
        } else {
            mod = #var(prefix)WeaponMod(SpawnReplacement(mods[i],newMod,True));
            if (mod!=None){
                l("Spawned a "$mod.name$" to replace "$mods[i].name);
                mods[i].Destroy();
            } else {
                l("Failed to replace weapon mod "$mods[i].Name);
            }
        }
    }

    //Technically any decoration can contain objects, but I think DX only puts them in containers
    foreach AllActors(class'Containers',container)
    {
        if (#var(PlayerPawn)(container.base)!=None){
            continue; //Skip boxes the player might have carried across levels
        }
        //I don't know if anything has anything in contents2 or contents3, but can't hurt...
        if(IsValidModClass(container.contents)){
            container.contents = PickRandomMod();
        }
        if(IsValidModClass(container.content2)){
            container.content2 = PickRandomMod();
        }
        if(IsValidModClass(container.content3)){
            container.content3 = PickRandomMod();
        }
    }
}

simulated function AddDXRCredits(CreditsWindow cw)
{
    local int i;
    if(dxr.flags.IsZeroRando()) return;
    cw.PrintHeader( "Weapon Mods" );

    //Should this try to strip the "Weapon Modification (xyz)" name to just "xyz"?
    for (i=0;i<ArrayCount(randommods);i++){
        cw.PrintText( randommods[i].Type.default.ItemName $ " : " $ FloatToString(randommods[i].chance, 1) $ "%" );
    }

    cw.PrintLn();
    cw.PrintLn();
}


defaultproperties
{
    min_rate_adjust=0.3
    max_rate_adjust=1.75
}
