#compileif gmdx
class GMDXGepGun extends WeaponGEPGun;
// fix for https://github.com/Die4Ever/deus-ex-randomizer/issues/227

simulated function Tick(float deltaTime)
{
    local bool oldbCanTrack;
    oldbCanTrack = bCanTrack;
    if(DeusExPlayer(Owner) == None)
        bCanTrack = false;
    Super.Tick(deltaTime);
    bCanTrack = oldbCanTrack;
}

function RenderPortal(canvas Canvas)
{
    local bool portalRejected, oldCanvasFlipFlop;
    local rotator rdif;
    local vector rloc;
    local Actor traceActor;

    if (player.bGepProjectileInFlight && player.aGEPProjectile!=None){
        rdif=player.aGEPProjectile.Rotation;
        rloc=player.aGEPProjectile.Location+(Rocket(player.aGEPProjectile).PortalOffset>>rdif);
        traceActor=player.aGEPProjectile;
    } else {
        rloc=player.Location+CalcDrawOffset();
        rdif=player.ViewRotation;
        traceActor=player;
    }

    if (traceActor.FastTrace(rloc)==False){
        portalRejected = true;
        oldCanvasFlipFlop = bFlipFlopCanvas;
        bFlipFlopCanvas = true;
    }

    //When bFlipFlopCanvas==false, draws the portal
    Super.RenderPortal(Canvas);

    if (portalRejected){
        bFlipFlopCanvas = oldCanvasFlipFlop;
    }
}

//Might as well keep this here so most of the GEP logic is in one place
static function RocketDestroyed(Rocket r){
    local DeusExPlayer dxp;
    local DeusExWeapon dxw;

    dxp = DeusExPlayer(r.Owner);

    //Kind of inspired by Sarge's GMDX:AE implementation, but not quite the same,
    //because the GMDXv9 scope behaviour is definitely different, and I'm not *super*
    //interested in trying to debug that.  Unscopes after every shot, even if you have
    //multiple shots in your clip.  At least it doesn't screw up your FOV...
    if ((dxp!=None)&&(r.bGEPInFlight))
    {
        r.bGEPInFlight=False; //So that the original code in the super class doesn't run
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
}
