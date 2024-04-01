class DXRAimLaserEmitter extends LaserEmitter;

//Mostly copied from LaserEmitter, but modified so it doesn't even try to reflect the laser
function CalcTrace(float deltaTime)
{
    local vector StartTrace, EndTrace, HitLocation, HitNormal, Reflection;
    local actor target;
    local int i, texFlags;
    local name texName, texGroup;

    StartTrace = Location;
    EndTrace = Location + 20000 * vector(Rotation);
    HitActor = None;

    foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace, StartTrace)
    {
        if ((target.DrawType == DT_None) || target.bHidden)
        {
            // do nothing - keep on tracing
        }
        else if ((target == Level) || target.IsA('Mover'))
        {
            break;
        }
        else
        {
            HitActor = target;
            break;
        }
    }

    SetLaserColour();

    if (LaserIterator(RenderInterface) != None)
        LaserIterator(RenderInterface).AddBeam(i, Location, Rotation, VSize(Location - HitLocation));

    if (spot[0] == None)
    {
        spot[0] = Spawn(class'LaserSpot', Self, , HitLocation, Rotator(HitNormal));
        spot[0].bHidden=True; //Keep it secret, keep it safe
    }
    else
    {
        spot[0].SetLocation(HitLocation);
        spot[0].SetRotation(Rotator(HitNormal) * -1);
    }
}

function SetLaserColour()
{
    local DeusExPlayer player;
    local Color retColour;

    if (proxy==None) return;

    player = DeusExPlayer(Owner);
    if (player==None) return;

    DeusExRootWindow(Player.rootWindow).hud.augDisplay.GetTargetReticleColor(HitActor,retColour);
    //player.ClientMessage("R"$retColour.R$" G"$retColour.G$" B"$retColour.B);
    if (HitActor!=None){
        if (retColour.R==0 && retColour.G==0 && retColour.B==0){
            proxy.Skin = Texture'Extension.SolidYellow';
        } else if (retColour.R==255 && retColour.G==0 && retColour.B==0){
            proxy.Skin = Texture'Extension.SolidRed';
        } else if (retColour.R==0 && retColour.G==255 && retColour.B==0){
            proxy.Skin = Texture'Extension.SolidGreen';
        }
    } else {
        proxy.Skin = Texture'Extension.Solid'; //Solid White
    }
}

function Tick(float deltaTime)
{
    //Make sure we never get frozen
    if (proxy!=None){
        proxy.DistanceFromPlayer=0;
    }
    Super.Tick(deltaTime);
}

defaultproperties
{
     SoundRadius=16
     AmbientSound=None
     CollisionRadius=40.000000
     CollisionHeight=40.000000
     RenderIteratorClass=Class'DeusEx.LaserIterator'
}
