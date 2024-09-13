class DamageProxy extends ScriptedPawn;

static function Create(Actor Base, float height)
{
    local DamageProxy dp;
    local vector loc;

    loc = Base.Location;
    loc.Z += Base.CollisionHeight + height/2;
    dp = Base.Spawn(class'DamageProxy',,, loc);
    dp.SetBase(Base);
    dp.SetCollisionSize(Base.CollisionRadius, height);
    if(ScriptedPawn(Base) != None) {
        dp.CopyAlliances(ScriptedPawn(Base));
    }
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
    if(Base != None) {
        Base.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
    } else {
        Destroy();
    }
}

function CopyAlliances(ScriptedPawn from)
{
    Alliance = from.Alliance;
    ChangeAlly('Player', -1, true);// TODO: make this smarter
}


// do a bunch of nothing
function Tick(float deltaTime)
{}
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
function Bump(actor Other)
{}
function HitWall(vector HitLocation, Actor hitActor)
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
    bCollideActors=true
    bBlockActors=false
    bBlockPlayers=true
    bProjTarget=true
    bHidden=true
    bImportant=true // don't randomize
}
