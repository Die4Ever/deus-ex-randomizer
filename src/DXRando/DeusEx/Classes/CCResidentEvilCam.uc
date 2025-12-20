class CCResidentEvilCam extends SecurityCamera;

var DeusExPlayer p;
var bool Reposition;
var float cameraMoveTimer;
var float JoltMagnitude;
var vector DesiredLoc;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    Reposition = False;
}

function bool FindNewCameraPosition()
{
    local DXRMachines dxrm;
    local Vector loc,loc2, aimLoc;
    local Rotator rot, rot2;
    local Actor hit, aimTarget;
    local Vector HitLocation, HitNormal;
    local int mult;
    local bool success;

    foreach AllActors(class'DXRMachines',dxrm){break;}

    if (dxrm==None){
        return false;
    }

    aimTarget = GetAimTarget(p,aimLoc);

    success = dxrm.GetLazyCameraLocation(loc,cameraRange*0.75);

    if (success){
        if (!aimTarget.FastTrace(loc)){
            success=False;
        }
    }

    if (!success){
        //Try to fall back to a position at a point somewhere behind the target (unless it's a conversation)
        rot2 = aimTarget.Rotation;
        rot2.Yaw = rot2.Yaw - 8000 + Rand(16000); //Add some slight skew, so the camera isn't always dead behind the player

        //In a conversation, the fallback location should be in front,
        //otherwise, put the fallback behind the target
        if (p.InConversation()) {
            mult = 1;
        } else {
            mult = -1;
        }

        loc2 = aimLoc + Vector(rot2) * (mult * 16 * 10) + vect(0,0,120);  //Make the camera also somewhat above
        hit = Trace(HitLocation, HitNormal, loc2, aimLoc, True);
        if (hit!=None){
            loc2 = HitLocation;
        }
        loc = loc2;
    }
    rot = Rotator(aimLoc - loc);
    SetLocation(loc);
    SetRotation(rot);
    DesiredLoc = loc;
    DesiredRotation = rot;
    JoltMagnitude /= 2;
    Reposition=False;
    cameraMoveTimer=0;

    return success;
}

function BindPlayer(DeusExPlayer play)
{
    if (play==None) return; //What are you doing?

    if (p==play && p.ViewTarget == Self) return;  //Camera is already set up, don't need to do anything

    p = play;
    p.ViewTarget = Self;
    FindNewCameraPosition();
}

function Tick(float deltaTime)
{
    local float ang;
    local Rotator rot;
    local DeusExPlayer curplayer;

    Super(#var(prefix)HackableDevices).Tick(deltaTime);

    if (p==None){
        return;
    }

    HandleJolt(deltaTime);

    if (p.ViewTarget!=Self){
        Destroy(); //Self destruct
    }

    cameraMoveTimer+=deltaTime;

    curTarget = None;

    //Prevent it from going into stasis
    LastRenderTime = p.LastRendered();
    DistanceFromPlayer=0;

    playerCheckTimer += deltaTime;

    if (playerCheckTimer > 0.1)
    {
        playerCheckTimer = 0;
        CheckTargetVisibility(p);
    }

    if (Reposition && cameraMoveTimer>1.0){ //Don't allow moves more than once a second
        //If not, find new location
        FindNewCameraPosition();
    }

    // DEUS_EX AMSD For multiplayer
    ReplicatedRotation = DesiredRotation;


}

function Actor GetAimTarget(DeusExPlayer player, out Vector aimLoc)
{
    local Actor aimTarget;

    aimTarget = player;
    if (DeusExRootWindow(player.rootWindow).scopeView.bViewVisible){
#ifdef vanilla||revision
        if (#var(PlayerPawn)(player).aimLaser.HitActor!=None) {
            aimTarget = #var(PlayerPawn)(player).aimLaser.HitActor;
            player.DesiredFOV = Player.Default.DefaultFOV;
        } else if (#var(PlayerPawn)(player).aimLaser.spot[0]!=None){
            aimTarget = #var(PlayerPawn)(player).aimLaser.spot[0];
            player.DesiredFOV = Player.Default.DefaultFOV;
        }
#endif
    }

    if (player.InConversation()) {
        //In a conversation, look at the person who is talking, instead of always at JC
        aimTarget = player.conPlay.currentSpeaker;
    }

    aimLoc = aimTarget.Location;

    if (Pawn(aimTarget)!=None){
        //In conversations, target the head region particularly
        //Borrowed a bit from ConCamera to not go quite as high
        //as the actual eye height
        aimLoc.Z += (Pawn(aimTarget).BaseEyeHeight / 1.5);
    } else if (#var(prefix)BlackHelicopter(aimTarget)!=None) {
        //Aim at the cockpit
        aimLoc += vect(0,-150,0) << aimTarget.Rotation;
    }
#ifdef revision
    else if (JockHelicopter(aimTarget)!=None) {
        //Aim at the cockpit
        aimLoc += vect(0,-150,0) << aimTarget.Rotation;
    }
#endif

    return aimTarget;

}

function CheckTargetVisibility(DeusExPlayer player)
{
    local float yaw, pitch, dist;
    local Actor hit,aimTarget;
    local Vector HitLocation, HitNormal, aimLoc;
    local Rotator rot;
    local bool hitTarget;

    if (player == None)
        return;

    Reposition=True;

    aimTarget = GetAimTarget(player,aimLoc);

    dist = Abs(VSize(aimLoc - Location));

    hitTarget = True;
    foreach TraceActors(class'Actor',hit,HitLocation,HitNormal,aimLoc,Location)
    {
        //Immediately reposition if you're on the far side of a wall or door
        if (LevelInfo(hit)!=None || Mover(hit)!=None){
            hitTarget = False;
            break;
        }

        //Need to account for targets that have no collision, like communicator holograms
        //So in theory, if hit eventually got to None, that's actually a good thing, because
        //it means we have a clear line of site to the location we're aiming for.  Most cases
        //we'll hit the target before then, but sometimes...

        //Aim the camera at the target
        if (hit == aimTarget)
        {
            break;
        }
    }

    if (hitTarget){
        // figure out if we can see the player
        rot = Rotator(aimLoc - Location);
        rot.Roll = 0;
        yaw = (Abs(Rotation.Yaw - rot.Yaw)) % 65536;
        pitch = (Abs(Rotation.Pitch - rot.Pitch)) % 65536;

        // center the angles around zero
        if (yaw > 32767)
            yaw -= 65536;
        if (pitch > 32767)
            pitch -= 65536;

        if (!((Abs(yaw) < cameraFOV) && (Abs(pitch) < cameraFOV)) || player.InConversation())
        {
            // rotate to face the player
            DesiredRotation = rot;
        }
        Reposition = False;
    }

    // if the player is out of range
    if (dist > cameraRange)
    {
        Reposition = True;
    }
}

function TriggerEvent(bool bTrigger)
{
}

function Trigger(Actor Other, Pawn Instigator)
{
}

function UnTrigger(Actor Other, Pawn Instigator)
{
}

event JoltView()
{
    local float newJoltMagnitude;
    if(p == None) return;
    newJoltMagnitude = p.JoltMagnitude;
    newJoltMagnitude *= 10;
    if (Abs(JoltMagnitude) < Abs(newJoltMagnitude))
        JoltMagnitude = newJoltMagnitude;
}

function HandleJolt(float delta)
{
    if(JoltMagnitude == 0) return;

    delta *= JoltMagnitude;
    SetLocation(Location + (delta*vect(0,0,12)));
    if(Location.Z < DesiredLoc.Z) {
        JoltMagnitude = 0;
        SetLocation(DesiredLoc);
    }
    else if(Location.Z >= DesiredLoc.Z + JoltMagnitude) {
        if(JoltMagnitude > 0) JoltMagnitude *= -1;
    }
}

defaultproperties
{
    bHidden=true
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bProjTarget=false
    bActive=True
    bNoAlarm=True
    bSwing=False
    bTrackPlayer=True
    bGameRelevant=True
    bAlwaysRelevant=True
    bAlwaysTick=True
    HitPoints=50
    minDamageThreshold=5
    bStasis=False
    cameraRange=750
    RotationRate=(Pitch=40000,Yaw=40000)
    AmbientSound=None
    LightType=LT_None
    LightBrightness=0
    LightHue=0
    LightSaturation=0
    LightRadius=0
}
