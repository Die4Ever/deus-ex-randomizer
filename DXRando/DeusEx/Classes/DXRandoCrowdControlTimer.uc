//=============================================================================
// DXRandoCrowdControlTimer.
//=============================================================================
class DXRandoCrowdControlTimer extends ChargedPickup;

var DXRandoCrowdControlLink link;
var name timerName;
var int defTime;
var string timerLabel;

function initTimer( DXRandoCrowdControlLink ccLink, name tName, int defaultTime, string label )
{
    link = ccLink;
    timerName = tName;
    defTime = defaultTime;
    timerLabel = label;
    
    SetPhysics(PHYS_None);
    SetCollision(False,False,False);
    bHidden = True;
}

function string GetTimerLabel()
{
    return timerLabel;
}

function name GetTimerName()
{
    return timerName;
}

function Float GetCurrentCharge()
{
    local int curTime;
    
    curTime = link.getTimer(timerName);
    
    return (Float(curTime) / Float(defTime)) * 100.0;
}

function ChargedPickupBegin(DeusExPlayer Player)
{
    Player.AddChargedDisplay(Self);

    bIsActive = True;
}
function ChargedPickupEnd(DeusExPlayer Player)
{
    Player.RemoveChargedDisplay(Self);
    bIsActive = False;
    
    link.removeTimerDisplay(self);
}

function UsedUp()
{
    local DeusExPlayer Player;

    Player = link.dxr.Player;
    
    if (Player != None)
    {
        ChargedPickupEnd(Player);
        
    }
    
    Destroy();
}

state Activated
{
    function Timer()
    {
        Charge = GetCurrentCharge();
        //link.PlayerMessage("Charge is now "$Charge);
        if (Charge <= 0)
            UsedUp();
 
    }
    
    function BeginState()
    {
        local DeusExPlayer Player;

        Super(DeusExPickup).BeginState();

        Player = link.dxr.Player;
        if (Player != None)
        {
            ChargedPickupBegin(Player);
            SetTimer(0.1, True);
        }
    }

    function EndState()
    {
        local DeusExPlayer Player;

        Super.EndState();

        Player = link.dxr.Player;
        if (Player != None)
        {
            ChargedPickupEnd(Player);
            SetTimer(0.1, False);
        }
    }

}


defaultproperties
{
     bCollideActors = False
     bHidden=True
     M_Activated=""
     skillNeeded=None
     LoopSound=None
     ChargedIcon=Texture'UWindow.Icons.MouseWait'
     ExpireMessage=" "
     ItemName="Crowd Control Timer"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.HazMatSuit'
     PickupViewMesh=LodMesh'DeusExItems.HazMatSuit'
     ThirdPersonMesh=LodMesh'DeusExItems.HazMatSuit'
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconHazMatSuit'
     largeIcon=Texture'DeusExUI.Icons.LargeIconHazMatSuit'
     largeIconWidth=46
     largeIconHeight=45
     Description="Crowd Control Timer.  You shouldn't see this!"
     beltDescription="CCTIMER"
     Texture=Texture'DeusExItems.Skins.ReflectionMapTex1'
     Mesh=LodMesh'DeusExItems.HazMatSuit'
     CollisionRadius=17.000000
     CollisionHeight=11.520000
     Mass=20.000000
     Buoyancy=12.000000
}
