class DXRToiletSeat extends Seat;

var #var(prefix)Toilet toilet;
var bool occupied;

static function DXRToiletSeat Create(#var(injectsprefix)Toilet t)
{
    local DXRToiletSeat seat;

    seat = t.Spawn(class'DXRToiletSeat',,,t.Location,t.Rotation);
    seat.toilet=t;

    return seat;
}


function BeginPlay()
{
    Super.BeginPlay();
    SetTimer(1,true);
}

simulated event Timer()
{
    local bool occupiedNow;

    occupiedNow = (sittingActor[0]!=None);
    if (occupiedNow!=occupied && !occupiedNow && toilet!=None){
        toilet.Frob(None,None);
    }
    occupied = occupiedNow;
}

defaultproperties
{
    sitPoint(0)=(X=0.000000,Y=-14.000000,Z=4.00000)
    ItemName="Toilet Seat"
    bHidden=True
    bInvincible=True
    bPushable=False
    Physics=PHYS_None
    CollisionRadius=0
    CollisionHeight=0
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    occupied=false
}
