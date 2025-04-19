class LavaFire extends Fire transient;

const SpawnRadius = 1500;
const SpawnRadiusShort = 400;
const DespawnRadius = 2000;

simulated function SpawnSmokeEffects()
{
    //Don't generate smoke
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    Update();
}

function Update()
{
    SetTimer(0.1 + FRand()*0.1, true);
    DrawScale = 0.75 + FRand()*0.5;
    LifeSpan = 100 + FRand();
}

function Timer()
{
    local #var(PlayerPawn) p;
    local vector loc, PlayerHead;

    p = #var(PlayerPawn)(GetPlayerPawn());
    if(p == None) return;

    PlayerHead = p.Location;
    PlayerHead.Z += p.BaseEyeHeight;

    if (LifeSpan > 99 && VSize(Location-PlayerHead) < DespawnRadius && FastTrace(PlayerHead)){
        return;
    }

    loc = GetLocation(p);
    if(loc != vect(0,0,0)) {
        SetLocation(loc);
    }
}

static function vector GetLocation(#var(PlayerPawn) p)
{

    local float spawnRange;
    local vector loc, PlayerHead, HitLocation, HitNormal,EndTrace;
    local Actor HitActor;

    PlayerHead = p.Location;
    PlayerHead.Z += p.BaseEyeHeight;

    //Trace forward to account for a bit of velocity
    EndTrace = PlayerHead + (p.Velocity*vect(0.5,0.5,0)); //500ms of velocity?
    HitActor = p.Trace(HitLocation, HitNormal, EndTrace, PlayerHead, false);
    if (HitActor==None){
        PlayerHead = EndTrace;
    } else {
        PlayerHead = HitLocation;
    }

    spawnRange = SpawnRadius;
    if (Rand(2)==0){
        spawnRange=SpawnRadiusShort; //Extra odds for close fire spawns
    }

    //Get a random position around the player at head height
    loc = VRand() * spawnRange;
    loc += PlayerHead;
    loc.Z = PlayerHead.Z;

    //Trace down to the ground and see if it actually hits the level
    EndTrace = loc;
    EndTrace.Z -= 1000;

    HitActor = p.Trace(HitLocation, HitNormal, EndTrace, loc, false);

    if (HitActor == p.Level) {
        //Vary height off the ground a little bit, makes the fire look less uniform
        HitLocation.Z += 5.0 + (FRand() * 10.0);

        //Make sure the final location is in line of sight before spawning
        if (p.FastTrace(HitLocation, PlayerHead)){
            return HitLocation;
        }
    }

    return vect(0,0,0);
}

defaultproperties
{
    bAlwaysRelevant=True
    LifeSpan=100
}
