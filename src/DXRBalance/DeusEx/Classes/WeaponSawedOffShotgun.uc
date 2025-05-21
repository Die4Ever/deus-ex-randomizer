class DXRWeaponSawedOffShotgun injects WeaponSawedOffShotgun;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        HitDamage = 6;
        BaseAccuracy = 0.7;
        AccurateRange = 688;
        maxRange = 960;
        AIMaxRange = 448;
    } else {
        HitDamage = 5;
        BaseAccuracy = 0.6;
        AccurateRange = 1200;
        maxRange = 2400;
        AIMaxRange = 800;
    }
    default.HitDamage = HitDamage;
    default.BaseAccuracy = BaseAccuracy;
    default.AccurateRange = AccurateRange;
    default.maxRange = maxRange;
    default.AIMaxRange = AIMaxRange;
}

simulated function PlayFiringSound()
{ // DXRando: same as vanilla, but quieter
    if (bHasSilencer)
        PlaySimSound( Sound'StealthPistolFire', SLOT_None, TransientSoundVolume*0.8, 2048 );
    else
    {
        // The sniper rifle sound is heard to it's range in multiplayer
        if ( ( Level.NetMode != NM_Standalone ) &&  Self.IsA('WeaponRifle') )
            PlaySimSound( FireSound, SLOT_None, TransientSoundVolume*0.8, class'WeaponRifle'.Default.mpMaxRange );
        else
            PlaySimSound( FireSound, SLOT_None, TransientSoundVolume*0.8, 2048 );
    }
}

// vanilla is 5 damage, 0.6 accuracy, 1200 AccurateRange, 2400 maxRange
defaultproperties
{
    HitDamage=6
    BaseAccuracy=0.7
    maxRange=960
    AccurateRange=688
    MinSpreadAcc=0.25
    AIMaxRange=448
    AfterShotTime=1.0636363636363636363636363636364
}
