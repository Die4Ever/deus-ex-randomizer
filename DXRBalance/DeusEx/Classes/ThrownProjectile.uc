class DXRThrownProjectile shims ThrownProjectile;

// scale trigger time with skill for grenades attached to walls
simulated function Tick(float deltaTime)
{
    local float oldSkillTime;
    local #var(PlayerPawn) player;

    oldSkillTime = skillTime;
    Super.Tick(deltaTime);
    player = #var(PlayerPawn)(Owner);
    if(oldSkillTime == 0 && skillTime == 1 && player != None) {
        // higher skill will make the player's grenades trigger more quickly, but too quickly and it explodes when the enemy is still far from the grenade
        // also need to consider multiple enemies running at you, the first one will trigger the grenade, so too fast and you don't get as many
        skillTime = player.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
        skillTime = 0.5 * skillTime + 1.1;
        skillTime = FClamp(skillTime, 0.75, 1.25);
    }
    else if(oldSkillTime == 0 && skillTime > 0 && player == None) {
        // faster than vanilla, unfortunately vanilla doesn't save the triggering actor but they already factored in the skill value
        skillTime *=  0.6;
        skillTime += 0.2;
    }
}

// scale arming time with skill and fuse length for thrown grenades (fuseLength is used for thrown grenades, but also the SetTimer call for arming attached grenades)
simulated function PreBeginPlay()
{
    local #var(PlayerPawn) player;

    Super.PreBeginPlay();
    player = #var(PlayerPawn)(Owner);
    if(player != None) {
        // high skill gives the player shorter fuses
        fuseLength += 3.0 * player.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
        fuseLength = FClamp(fuseLength, 0.2, 6);
    } else {
        // higher skill gives the enemies longer fuses
        player = #var(PlayerPawn)(GetPlayerPawn());
        if(player != None) {
            fuseLength -= player.SkillSystem.GetSkillLevelValue(class'SkillDemolition') * 2.0 + 0.5;
        }
    }
}

// this allows us to override GetSpawnCloudType in subclasses, in vanilla it's hardcoded to TearGas
//
// SpawnTearGas needs to happen on the server so the clouds are insync and damage is dealt out of them
//
function SpawnTearGas()
{
    local int i;
    local class<Cloud> GasType;
    local Name tDamageType;

    if ( Role < ROLE_Authority )
        return;

    for (i=0; i<blastRadius/36; i++)
    {
        if (FRand() < 0.9)
        {
            GetSpawnCloudType( GasType, tDamageType );
            SpawnCloud(GasType, tDamageType);
        }
    }
}

function GetSpawnCloudType(out class<Cloud> GasType, out Name tDamageType)
{
    GasType = class'TearGas';
    tDamageType = 'TearGas';
}

function SpawnCloud(class<Cloud> type, Name DamageType)
{
    local Vector loc;
    local Cloud gas;

    loc = Location;
    loc.X += FRand() * blastRadius - blastRadius * 0.5;
    loc.Y += FRand() * blastRadius - blastRadius * 0.5;
    loc.Z += 32;
    gas = spawn(type, None,, loc);
    if (gas == None) return;

    gas.DamageType = DamageType;
    gas.Velocity = vect(0,0,0);
    gas.Acceleration = vect(0,0,0);
    gas.DrawScale = FRand() * 0.5 + 2.0;
    gas.LifeSpan = FRand() * 10 + 30;
    if ( Level.NetMode != NM_Standalone )
        gas.bFloating = False;
    else
        gas.bFloating = True;
    gas.Instigator = Instigator;
}

// DXRando: also apply damage to AutoTurretGun
state Exploding
{
   function DamageRing()
   {
       local AutoTurretGun gun;
       local float damageRadius,damageAmount,damageScale,momentum;
       local vector damageDir,hitLocation;

       damageRadius =(blastRadius / gradualHurtSteps) * gradualHurtCounter;
       damageAmount = (2 * Damage) / gradualHurtSteps;

       Super.DamageRing();
       foreach VisibleActors(class'AutoTurretGun', gun, damageRadius) {
           damageDir = gun.Location - Location;
           damageDir = damageDir / (FMax(1,VSize(damageDir)));
           damageScale = 1 - FMax(0,(FMax(1,VSize(damageDir)) - gun.CollisionRadius)/DamageRadius);
           hitLocation = gun.Location - 0.5 * (gun.CollisionHeight + gun.CollisionRadius) * damageDir;
           momentum = MomentumTransfer / gradualHurtSteps;

           gun.TakeDamage(damageScale * damageAmount, Pawn(Owner), hitLocation, (damageScale * momentum * damageDir), damageType);
       }
   }
}

// DXRando: Grenades will no longer immediately explode when they touch a carcass
auto simulated state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
        if (DeusExCarcass(Other)!=None){
            return;
        } else {
            Super.ProcessTouch(Other,HitLocation);
        }
	}
}
