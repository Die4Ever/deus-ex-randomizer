class DamageProxy extends ScriptedPawn;

var float height;

static function Create(Actor Base, float height)
{
    local DamageProxy dp;
    dp = Base.Spawn(class'DamageProxy',,, Base.Location);// Tick will adjust our position
    dp.height = height;
    dp.SetBase(Base);
    dp.SetCollisionSize(Base.CollisionRadius + 1, Base.CollisionHeight + 0.2);
    dp.SetCollision(true,true,true);
    if(ScriptedPawn(Base) != None) {
        ScriptedPawn(Base).bInvincible=true;
        dp.CopyAlliances(ScriptedPawn(Base));
    }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    local ScriptedPawn sp;
    sp = ScriptedPawn(Base);
    if(sp != None) {
        sp.bInvincible=false;
        sp.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
        sp.bInvincible=true;
    }
    else if(Base != None) {
        Base.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
    } else {
        Destroy();
    }
}

event Bump( Actor Other )
{
    Base.Bump(Other);
}

function CopyAlliances(ScriptedPawn from)
{
    Alliance = from.Alliance;
    ChangeAlly('Player', -1, true);// TODO: make this smarter
}

function Tick(float deltaTime)
{
    local vector loc;

    // do NOT call Super
    if(Base==None || Base.bDeleteMe) {
        Destroy();
        return;
    }

    loc = Base.Location;
    loc.Z += height - 0.1;
    if(loc!=Location) {
        SetCollision(false,false,false);
        SetLocation(loc);
        SetCollision(true,true,true);
    }
}

// do a bunch of nothing
function PreBeginPlay()
{}
function BeginPlay()
{}
function PostBeginPlay()
{}
function PostPostBeginPlay()
{}
function ZoneChange(ZoneInfo newZone)
{}
singular function BaseChange()
{}
function HitWall(vector HitLocation, Actor hitActor)
{}
function TweenAnimPivot(name Sequence, float TweenTime,
                        optional vector NewPrePivot)
{}
function Timer()
{}

auto state StartUp
{
    function BeginState()
    {
    }
}

defaultproperties
{
    CollisionRadius=0
    CollisionHeight=0
    bCollideWorld=false
    bCollideActors=false
    bBlockActors=false
    bBlockPlayers=false
    bProjTarget=true
    bHidden=true
    Mesh=None
    bImportant=true // don't randomize
    bStasis=false
}
