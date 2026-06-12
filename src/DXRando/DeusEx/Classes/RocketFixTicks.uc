class RocketFixTicks extends #var(prefix)Rocket;

#ifdef gmdxnotae
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
#endif

state Exploding
{
    ignores ProcessTouch, HitWall, Explode;
Begin:
    // stagger the HurtRadius outward using Timer()
    // do five separate blast rings increasing in size
    gradualHurtCounter = 1;
    gradualHurtSteps = 4;// DXRando: 4 ticks instead of 5, that way a 150 damage gep gun still deals 75 damage per tick which is enough to break any door
    Velocity = vect(0,0,0);
    bHidden = True;
    LightType = LT_None;
    SetCollision(False, False, False);
    DamageRing();
    SetTimer(0.25/float(gradualHurtSteps), True);
}

// vanilla MomentumTransfer is 10000
defaultproperties
{
    MomentumTransfer=25000
}
