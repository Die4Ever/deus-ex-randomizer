class DXRStalker extends #var(prefix)HumanMilitary abstract;

var float healthRegenTimer, empRegenTimer;
var #var(PlayerPawn) player;
var int FleeHealth;// like MinHealth, but we need more control
var Actor closestDestPoint, farthestDestPoint;
var float maxDist; // for iterative farthestDestPoint

static function DXRStalker Create(DXRActorsBase a)
{
    local DXRStalker s;
    local vector loc;
    local int i;

    for(i=0; i<100; i++) {
        loc = a.GetRandomPosition(a.player().Location, 16*100, 999999);
        s = a.Spawn(default.class,,, loc);
        if(s != None) break;
    }
    if(s == None) return None;

    s.player = a.player();
    s.HomeLoc = loc;
    s.bUseHome = true;

    return s;
}

function Actor GetFarthestNavPoint(Actor from, optional int iters)
{
    local Actor farthest, t;
    local NavigationPoint p;
    local float dist;

    dist = VSize(closestDestPoint.Location-from.Location);
    if(dist > maxDist) {
        maxDist = dist;
        farthest = from;
    }

    if(iters > 3) return farthest;

    foreach ReachablePathnodes(class'NavigationPoint', p, from, dist) {
        t = GetFarthestNavPoint(p, iters+1);
        if(t != None) {
            farthest = t;
        }
    }

    return farthest;
}

function InitializePawn()
{
    local NavigationPoint p, closest;
    local float dist, minDist;
    local int i;

    Super.InitializePawn();

    minDist = 999999;
    foreach RadiusActors(class'NavigationPoint', p, 1600) {
        if(p.bPlayerOnly) continue;
        if(GetNextWaypoint(p)==None) continue;
        dist = VSize(Location - p.Location);
        if(dist < minDist) {
            minDist = dist;
            closest = p;
        }
    }

    closestDestPoint = closest;

    SetOrders('Wandering');
}

function Tick(float delta)
{
    local int i;

    Super.Tick(delta);

    LastRenderTime = Level.TimeSeconds;
    bStasis = false;

    healthRegenTimer += delta;
    if(healthRegenTimer > 2) {
        healthRegenTimer = 0;
        i = 20;

        if(health < FleeHealth) {
            MinHealth = default.health/2;
            bDetectable=false;
            bIgnore=true;
            Visibility=0;
        } else if(health > MinHealth) {
            MinHealth = default.MinHealth;
            bDetectable=true;
            bIgnore=false;
            Visibility=default.Visibility;
            i = 10;
        }

        HealthHead += i;
        HealthTorso += i;
        HealthArmLeft += i;
        HealthArmRight += i;
        HealthLegLeft += i;
        HealthLegRight += i;
        GenerateTotalHealth();
    }

    empRegenTimer += delta;
    if(empRegenTimer > 30) {
        empRegenTimer = 0;
        #ifdef injections
        EmpHealth = FClamp(EmpHealth + 10, 0, default.EmpHealth);
        #endif
    }
}

state Wandering
{
    #ifdef vmd175
    function bool PickDestination()
    #else
    function PickDestination()
    #endif
    {
        local Actor   target;
        local int     iterations;
        local float   magnitude, dist1, dist2;
        local rotator rot1;

        if(closestDestPoint != None) {
            target = GetFarthestNavPoint(self);
        }
        if(target != None) {
            farthestDestPoint = target;
        }

        if(farthestDestPoint == None || closestDestPoint == None) {
            #ifdef vmd175
            return Super.PickDestination();
            #else
            Super.PickDestination();
            return;
            #endif
        }

        target = farthestDestPoint;
        dist1 = VSize(Location - farthestDestPoint.Location);
        dist2 = VSize(Location - closestDestPoint.Location);

        if(dist1 < dist2*0.1) {
            // swap target
            target = closestDestPoint;
            closestDestPoint = farthestDestPoint;
            farthestDestPoint = target;
            dist1 = dist2;
        }

        if (dist1 > 16)
        {
            target = FindPathToward(farthestDestPoint);
            if(target == None) {
                target = farthestDestPoint;
            }
        }

        if(target == None) {
            #ifdef vmd175
            return Super.PickDestination();
            #else
            Super.PickDestination();
            return;
            #endif
        }

        iterations = 5;
        magnitude  = 4000*(FRand()*0.4+0.8);  // 4000, +/-20%
        rot1       = Rotator(Location - target.Location);
        rot1.Yaw  += 32768; // looking towards target

        destLoc = target.Location;

        if (!AIPickRandomDestination(100, magnitude, rot1.Yaw, 0.8, -rot1.Pitch, 0.8, iterations,
                                        FRand()*0.4+0.35, destLoc))
        {
            target = FindPathToward(farthestDestPoint);
            if(target != None) destLoc = target.Location;
            else {
                #ifdef vmd175
                return Super.PickDestination();
                #else
                Super.PickDestination();
                return;
                #endif
            }
        }

        #ifdef vmd175
        return true;
        #endif
    }
}

function GenerateTotalHealth()
{
    // you can hurt him but you can't kill him
    HealthHead     = FClamp(HealthHead, FleeHealth/2, default.HealthHead);
    HealthTorso    = FClamp(HealthTorso, FleeHealth/2, default.HealthTorso);
    HealthArmLeft  = FClamp(HealthArmLeft, FleeHealth/2, default.HealthArmLeft);
    HealthArmRight = FClamp(HealthArmRight, FleeHealth/2, default.HealthArmRight);
    HealthLegLeft  = FClamp(HealthLegLeft, FleeHealth/2, default.HealthLegLeft);
    HealthLegRight = FClamp(HealthLegRight, FleeHealth/2, default.HealthLegRight);
    bInvincible    = false;// damageproxy hack, GenerateTotalHealth() sets health to maximum when invincible
    Super.GenerateTotalHealth();
    bInvincible    = true;// damageproxy hack
    Health = FClamp(Health, FleeHealth/2, default.Health);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    if(damageType == 'EMP') empRegenTimer=0;
    else if(health < MinHealth) return;
    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function bool ShouldDropWeapon()
{
    return false;
}

defaultproperties
{
    Health=1000
    HealthHead=1000
    HealthTorso=1000
    HealthLegLeft=1000
    HealthLegRight=1000
    HealthArmLeft=1000
    HealthArmRight=1000
    bShowPain=False
    bInvincible=false
    RandomWandering=0.3
    Wanderlust=0.01
    HomeExtent=20000
    bUseHome=false
    bStasis=false
    bEmitDistress=false
    bLookingForLoudNoise=true
    bReactLoudNoise=true
    bImportant=True
}
