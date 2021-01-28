class DXRWeapon merges DeusExWeapon abstract;

function PostBeginPlay()
{
    local DXRWeapons m;
    _PostBeginPlay();

    foreach AllActors(class'DXRWeapons', m) {
        if(m.dxr == None) {
            log("m.dxr == None for "$m$"?");
            continue;
        }
        m.RandoWeapon(self);
        return;
    }
}

//mostly copied from DeusExWeapon, but use actual values instead of default values
simulated function bool UpdateInfo(Object winObject)
{
    local PersonaInventoryInfoWindow winInfo;
    local string str;
    local int i, dmg;
    local float mod;
    local bool bHasAmmo;
    local bool bAmmoAvailable;
    local class<DeusExAmmo> ammoClass;
    local Pawn P;
    local Ammo weaponAmmo;
    local int  ammoAmount;

    P = Pawn(Owner);
    if (P == None)
        return False;

    winInfo = PersonaInventoryInfoWindow(winObject);
    if (winInfo == None)
        return False;

    winInfo.SetTitle(itemName);
    winInfo.SetText(msgInfoWeaponStats);
    winInfo.AddLine();

    // Create the ammo buttons.  Start with the AmmoNames[] array,
    // which is used for weapons that can use more than one 
    // type of ammo.

    if (AmmoNames[0] != None)
    {
        for (i=0; i<ArrayCount(AmmoNames); i++)
        {
            if (AmmoNames[i] != None) 
            {
                // Check to make sure the player has this ammo type
                // *and* that the ammo isn't empty
                weaponAmmo = Ammo(P.FindInventoryType(AmmoNames[i]));

                if (weaponAmmo != None)
                {
                    ammoAmount = weaponAmmo.AmmoAmount;
                    bHasAmmo = (weaponAmmo.AmmoAmount > 0);
                }
                else
                {
                    ammoAmount = 0;
                    bHasAmmo = False;
                }

                winInfo.AddAmmo(AmmoNames[i], bHasAmmo, ammoAmount);
                bAmmoAvailable = True;

                if (AmmoNames[i] == AmmoName)
                {
                    winInfo.SetLoaded(AmmoName);
                    ammoClass = class<DeusExAmmo>(AmmoName);
                }
            }
        }
    }
    else
    {
        // Now peer at the AmmoName variable, but only if the AmmoNames[] 
        // array is empty
        if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
        {	
            weaponAmmo = Ammo(P.FindInventoryType(AmmoName));

            if (weaponAmmo != None)
            {
                ammoAmount = weaponAmmo.AmmoAmount;
                bHasAmmo = (weaponAmmo.AmmoAmount > 0);
            }
            else
            {
                ammoAmount = 0;
                bHasAmmo = False;
            }

            winInfo.AddAmmo(AmmoName, bHasAmmo, ammoAmount);
            winInfo.SetLoaded(AmmoName);
            ammoClass = class<DeusExAmmo>(AmmoName);
            bAmmoAvailable = True;
        }
    }

    // Only draw another line if we actually displayed ammo.
    if (bAmmoAvailable)
        winInfo.AddLine();	

    // Ammo loaded
    if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
        winInfo.AddAmmoLoadedItem(msgInfoAmmoLoaded, AmmoType.itemName);

    // ammo info
    if ((AmmoName == class'AmmoNone') || bHandToHand || (ReloadCount == 0))
        str = msgInfoNA;
    else
        str = AmmoName.Default.ItemName;
    for (i=0; i<ArrayCount(AmmoNames); i++)
        if ((AmmoNames[i] != None) && (AmmoNames[i] != AmmoName))
            str = str $ "|n" $ AmmoNames[i].Default.ItemName;

    winInfo.AddAmmoTypesItem(msgInfoAmmo, str);

    // base damage
    if (AreaOfEffect == AOE_Cone)
    {
        if (bInstantHit)
        {
            if (Level.NetMode != NM_Standalone)
                dmg = mpHitDamage * 5;
            else
                dmg = HitDamage * 5;
        }
        else
        {
            if (Level.NetMode != NM_Standalone)
                dmg = mpHitDamage * 3;
            else
                dmg = HitDamage * 3;
        }
    }
    else
    {
        if (Level.NetMode != NM_Standalone)
            dmg = mpHitDamage;
        else
            dmg = HitDamage;
    }

    str = String(dmg);
    mod = 1.0 - GetWeaponSkill();
    if (mod != 1.0)
    {
        str = str @ BuildPercentString(mod - 1.0);
        str = str @ "=" @ FormatFloatString(dmg * mod, 1.0);
    }

    winInfo.AddInfoItem(msgInfoDamage, str, (mod != 1.0));

    // clip size
    if ((Default.ReloadCount == 0) || bHandToHand)
        str = msgInfoNA;
    else
    {
        if ( Level.NetMode != NM_Standalone )
            str = Default.mpReloadCount @ msgInfoRounds;
        else
            str = Default.ReloadCount @ msgInfoRounds;
    }

    if (HasClipMod())
    {
        str = str @ BuildPercentString(ModReloadCount);
        str = str @ "=" @ ReloadCount @ msgInfoRounds;
    }

    winInfo.AddInfoItem(msgInfoClip, str, HasClipMod());

    // rate of fire
    if ((Default.ReloadCount == 0) || bHandToHand)
    {
        str = msgInfoNA;
    }
    else
    {
        if (bAutomatic)
            str = msgInfoAuto;
        else
            str = msgInfoSingle;

        str = str $ "," @ FormatFloatString(1.0/ShotTime, 0.1) @ msgInfoRoundsPerSec;
    }
    winInfo.AddInfoItem(msgInfoROF, str);

    // reload time
    if ((Default.ReloadCount == 0) || bHandToHand)
        str = msgInfoNA;
    else
    {
        if (Level.NetMode != NM_Standalone )
            str = FormatFloatString(Default.mpReloadTime, 0.1) @ msgTimeUnit;
        else
            str = FormatFloatString(Default.ReloadTime, 0.1) @ msgTimeUnit;
    }

    if (HasReloadMod())
    {
        str = str @ BuildPercentString(ModReloadTime);
        str = str @ "=" @ FormatFloatString(ReloadTime, 0.1) @ msgTimeUnit;
    }

    winInfo.AddInfoItem(msgInfoReload, str, HasReloadMod());

    // recoil
    str = FormatFloatString(Default.recoilStrength, 0.01);
    if (HasRecoilMod())
    {
        str = str @ BuildPercentString(ModRecoilStrength);
        str = str @ "=" @ FormatFloatString(recoilStrength, 0.01);
    }

    winInfo.AddInfoItem(msgInfoRecoil, str, HasRecoilMod());

    // base accuracy (2.0 = 0%, 0.0 = 100%)
    if ( Level.NetMode != NM_Standalone )
    {
        str = Int((2.0 - Default.mpBaseAccuracy)*50.0) $ "%";
        mod = (Default.mpBaseAccuracy - (BaseAccuracy + GetWeaponSkill())) * 0.5;
        if (mod != 0.0)
        {
            str = str @ BuildPercentString(mod);
            str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.mpBaseAccuracy)*50.0)) $ "%";
        }
    }
    else
    {
        str = Int((2.0 - Default.BaseAccuracy)*50.0) $ "%";
        mod = (Default.BaseAccuracy - (BaseAccuracy + GetWeaponSkill())) * 0.5;
        if (mod != 0.0)
        {
            str = str @ BuildPercentString(mod);
            str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.BaseAccuracy)*50.0)) $ "%";
        }
    }
    winInfo.AddInfoItem(msgInfoAccuracy, str, (mod != 0.0));

    // accurate range
    if (bHandToHand)
        str = msgInfoNA;
    else
    {
        if ( Level.NetMode != NM_Standalone )
            str = FormatFloatString(Default.mpAccurateRange/16.0, 1.0) @ msgRangeUnit;
        else
            str = FormatFloatString(Default.AccurateRange/16.0, 1.0) @ msgRangeUnit;
    }

    if (HasRangeMod())
    {
        str = str @ BuildPercentString(ModAccurateRange);
        str = str @ "=" @ FormatFloatString(AccurateRange/16.0, 1.0) @ msgRangeUnit;
    }
    winInfo.AddInfoItem(msgInfoAccRange, str, HasRangeMod());

    // max range
    if (bHandToHand)
        str = msgInfoNA;
    else
    {
        if ( Level.NetMode != NM_Standalone )
            str = FormatFloatString(Default.mpMaxRange/16.0, 1.0) @ msgRangeUnit;
        else
            str = FormatFloatString(Default.MaxRange/16.0, 1.0) @ msgRangeUnit;
    }
    winInfo.AddInfoItem(msgInfoMaxRange, str);

    // mass
    winInfo.AddInfoItem(msgInfoMass, FormatFloatString(Default.Mass, 1.0) @ msgMassUnit);

    // laser mod
    if (bCanHaveLaser)
    {
        if (bHasLaser)
            str = msgInfoYes;
        else
            str = msgInfoNo;
    }
    else
    {
        str = msgInfoNA;
    }
    winInfo.AddInfoItem(msgInfoLaser, str, bCanHaveLaser && bHasLaser && (Default.bHasLaser != bHasLaser));

    // scope mod
    if (bCanHaveScope)
    {
        if (bHasScope)
            str = msgInfoYes;
        else
            str = msgInfoNo;
    }
    else
    {
        str = msgInfoNA;
    }
    winInfo.AddInfoItem(msgInfoScope, str, bCanHaveScope && bHasScope && (Default.bHasScope != bHasScope));

    // silencer mod
    if (bCanHaveSilencer)
    {
        if (bHasSilencer)
            str = msgInfoYes;
        else
            str = msgInfoNo;
    }
    else
    {
        str = msgInfoNA;
    }
    winInfo.AddInfoItem(msgInfoSilencer, str, bCanHaveSilencer && bHasSilencer && (Default.bHasSilencer != bHasSilencer));

    // Governing Skill
    winInfo.AddInfoItem(msgInfoSkill, GoverningSkill.default.SkillName);

    winInfo.AddLine();
    winInfo.SetText(Description);

    // If this weapon has ammo info, display it here
    if (ammoClass != None)
    {
        winInfo.AddLine();
        winInfo.AddAmmoDescription(ammoClass.Default.ItemName $ "|n" $ ammoClass.Default.description);
    }

    return True;
}
