#dontcompileif vanilla
//Inventory screen fixes for non-vanilla
class DXRPersonaScreenInventory extends PersonaScreenInventory;

#ifdef gmdxae
function SelectInventory(PersonaItemButton buttonPressed, optional bool bNoDeselect)
#else
function SelectInventory(PersonaItemButton buttonPressed)
#endif
{
    local Inventory inv;
    inv = Inventory(selectedItem.GetClientObject());

#ifdef gmdxae
    Super.SelectInventory(buttonpressed,bNoDeselect);
#else
    Super.SelectInventory(buttonpressed);
#endif
    UpdateRandoInvInfo();
}

function WeaponChangeAmmo()
{
    local Inventory inv;
    inv = Inventory(selectedItem.GetClientObject());

    Super.WeaponChangeAmmo();

    UpdateRandoInvInfo();
}

function Class<DeusExAmmo> LoadAmmo()
{
    local Class<DeusExAmmo> ammo;
    local Inventory inv;
    inv = Inventory(selectedItem.GetClientObject());

    ammo = Super.LoadAmmo();

#ifdef gmdxnotae
    //Old GMDX doesn't update the weapon info when you change ammo
    if ( ammo != None && inv != None ){
        inv.UpdateInfo(winInfo);
    }
#endif

    UpdateRandoInvInfo();

    return ammo;
}

#ifdef vmd2
function DropSelectedItem()
{
    Super.DropSelectedItem();

    UpdateRandoInvInfo();
}

function UseSelectedItem()
{
    Super.UseSelectedItem();

    UpdateRandoInvInfo();
}
#endif

#ifdef gmdxae
function WeaponUpdateInfo(DeusExWeapon weaponFrom)                              //RSD: Called by weaponFrom to force an update
{
    Super.WeaponUpdateInfo(weaponFrom);

    UpdateRandoInvInfo();
}
#endif


//#region Update Stats

function UpdateRandoInvInfo()
{
    local Inventory inv;
    local DeusExWeapon dxw;
    local DXRWeapons dxrw;
    inv = Inventory(selectedItem.GetClientObject());
    dxrw = DXRWeapons(class'DXRWeapons'.static.Find());

    dxw = DeusExWeapon(inv);
    if (dxw!=None){
        if (dxrw!=None){
            //Immediately reapply weapon randomization, particularly for ShotTime which gets set to default
            dxrw.RandoWeapon(dxw);
        }
        UpdateRandoWeaponInfo(dxw);
    }
}

function UpdateRandoWeaponInfo(DeusExWeapon w)
{
    //The info screen is a collection of PersonaInfoItemWindow's
    //which are basically just a "Label" and a "Text"

    local Window win;
    local PersonaInfoItemWindow info;
    local string label, text, defaultVal;
    local bool highlight;

    if (#defined(vmd)) return; //VMD already handles this

    if (w==None) return; //No weapon, no update
    if (winInfo==None) return; //No info window???
    if (winInfo.winTile==None) return; //No pile of objects inside???

    win = winInfo.winTile.GetTopChild();
    while (win!=None){
        info = PersonaInfoItemWindow(win);
        if (info!=None){
            label = info.winLabel.GetText();
            text  = info.winText.GetText();
            highlight = info.bHighlight;

            //If the text is blank, it's not the real value
            //(GMDX uses the same labels for weapon mod counts)
            if (text!=""){
                switch(label){
                    case w.msgInfoDamage:
                        highlight = GenerateNewWeaponDamageStr(w, text);
                        break;
                    case w.msgInfoROF:
                        highlight = GenerateNewWeaponROFStr(w, text);
                        break;
                }
                info.SetItemInfo(label,text,highlight);
            }
        }
        win = win.GetLowerSibling();
    }
}
//#endregion


//#region Damage Info
//This is an amalgam of the logic from across mods...
function bool GenerateNewWeaponDamageStr(DeusExWeapon w, out String damStr)
{
    local int dmg, defDmg, numSlugs;
    local float mod, modDmg;
    local string defDamStr;

    damStr = "";
    numSlugs = GetNumSlugs(w);

    defDmg = w.Default.HitDamage;
    if (w.ProjectileClass!=None){
        defDmg = class'DXRWeapons'.static.GetDefaultProjDamage(w.ProjectileClass);
    }

    dmg = w.HitDamage;
    if (w.ProjectileClass!=None){
        dmg = w.ProjectileClass.Default.Damage;
    }
#ifdef gmdx
    modDmg = w.ModDamage;
#endif

    damStr = String(dmg);

    mod = 1.0 - (2.0 * w.GetWeaponSkill()) + modDmg;
    if (mod!=1.0 || modDmg!=0.0){
        damStr = damStr @ w.BuildPercentString(mod - 1.0);

        if (numSlugs>1){
            damStr = damStr $ " (x" $ String(numSlugs) $ ")";
        }
        damStr = damStr @ "=" @ w.FormatFloatString(dmg * numSlugs * mod, 1.0);
    } else {
        if (numSlugs>1){
            damStr = damStr $ " (x" $ String(numSlugs) $ ")";
            damStr = damStr $" = "$ String(dmg * numSlugs);
        }
    }

    if (dmg!=defDmg){
        defDamStr = "(Default: " $ String(defDmg);
        if (numSlugs>1){
            defDamStr = defDamStr @ "x" @ String(numSlugs) @ "=" @ String(defDmg * numSlugs);
        }
        defDamStr = defDamStr $ ")";

        damStr = damStr $"|n"$ defDamStr;
    }

    return (mod != 1.0);
}

//This is stolen straight from Revision, everything else just returns 1
function int GetNumSlugs(DeusExWeapon w)
{
    local int numSlugs;
    numSlugs = 1;
#ifdef revision
    if (w.bInstantHit && Ammo20mm(w.AmmoType) == None && w.numInstantProjectiles != 0)
        numSlugs = w.numInstantProjectiles;
    else if ((!w.bInstantHit || Ammo20mm(w.AmmoType) != None) && w.numProjectiles != 0)
        numSlugs = w.numProjectiles;
    else if (w.AreaOfEffect == AOE_Cone)
    {
        if (w.bInstantHit)
        {
            if (String(w.Class.Name) == "WeaponNanoSword")
                numSlugs = 2;
            else
                numSlugs = 5;
        }
        else
        {
            if (w.IsA('WeaponPlasmaRifle'))
                numSlugs = 2;
            else
                numSlugs = 3;
        }
    }

    //if (w.AmmoType.IsA('AmmoSabot')){
    //    numSlugs = 1;
    //}
#endif

    return numSlugs;
}

//#endregion

//#region Rate of Fire Info

//This is an amalgam of the logic from across mods...
function bool GenerateNewWeaponROFStr(DeusExWeapon w, out String rofStr)
{
    local bool highlight;
    local float TotalShotTime;
    local float defRof;
    local String defRofStr, rdsPerSec;

    TotalShotTime = w.ShotTime;
    rdsPerSec = w.msgInfoRoundsPerSec;

#ifdef injections
    TotalShotTime += w.AfterShotTime;
#elseif revision
    if ((w.AmmoType != class'AmmoNone') && (!w.bHandToHand) && (w.ReloadCount != 0))
        rdsPerSec = Caps(DeusExAmmo(w.AmmoType).AmmoRoundNameShort)$w.msgInfoPerSec;

#endif

    // RANDO: Always show rate of fire
    if ((w.Default.ReloadCount == 0) || w.bHandToHand)
    {
        //rofStr = msgInfoNA;
        rofStr = w.FormatFloatString(1.0/TotalShotTime, 0.1) $ "/SEC";
    }
    else
    {
        if (w.bAutomatic)
            rofStr = w.msgInfoAuto;
        else
            rofStr = w.msgInfoSingle;

        rofStr = rofStr $ "," @ w.FormatFloatString(1.0/TotalShotTime, 0.1) @ rdsPerSec;

#ifdef gmdx
        if(w.HasROFMod())
        {
            rofStr = rofStr @ w.BuildPercentString(w.ModShotTime);
            rofStr = rofStr @ "=" @ w.FormatFloatString(1.0/TotalShotTime, 0.1) @ rdsPerSec;
            highlight = true;
        }
#endif
    }

    defRof = class'DXRWeapons'.static.GetDefaultShottime(w);
#ifdef injections
    defRof += w.Default.AfterShotTime;
#endif
    if (!(TotalShotTime~=defRof)){
        defRofStr = "(Default: " $ w.FormatFloatString(1.0/defRof, 0.1) @ rdsPerSec $ ")";

        rofStr = rofStr $"|n"$ defRofStr;
    }

    return highlight;
}
//#endregion
