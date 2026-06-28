//For a rocket that fixes the reload problems with the GEP if you have
//more than one shot in the clip.
class GMDXRocketWP extends #var(prefix)RocketWP;
#compileif gmdxnotae

simulated function Destroyed()
{
    local DeusExPlayer dxp;
    local DeusExWeapon dxw;

    dxp = DeusExPlayer(Owner);

    //Kind of inspired by Sarge's GMDX:AE implementation, but not quite the same,
    //because the GMDXv9 scope behaviour is definitely different, and I'm not *super*
    //interested in trying to debug that.  Unscopes after every shot, even if you have
    //multiple shots in your clip.  At least it doesn't screw up your FOV...
    if ((dxp!=None)&&(bGEPInFlight))
    {
        bGEPInFlight=False; //So that the original code in the super class doesn't run
        dxp.bGEPprojectileInflight=false;
        dxp.aGEPProjectile=none;

        dxw=DeusExWeapon(dxp.InHand);

        if (dxw.IsA('WeaponGEPGun'))
        {
            //Clear any lock-on, to prevent random beeping
            dxw.LockTimer=0;
            dxw.SetLockMode(dxw.ELockMode.LOCK_None);

            if (dxw.bZoomed){
                dxw.ScopeOff();
            }

            if (dxw.AmmoLeftInClip() == 0)
            {
                if (dxp.bAutoReload){
                    dxw.ReloadAmmo();
                }
            }
        }
    }

    Super.Destroyed();
}
