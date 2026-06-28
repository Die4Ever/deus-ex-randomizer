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

    if (player.bGepProjectileInFlight){
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
