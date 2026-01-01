class DXRWeaponSpiderBot injects WeaponSpiderBot;

var bool damageTypeHack;

//Spiderbots will attack the player with their zap, but not ScriptedPawns that aren't robots
//even though the electricity will deal Shocked damage (See ScriptedPawn::SwitchToBestWeapon,
//EMP damage type is considered completely invalid against enemies that aren't the player or
//a robot)
//
//If the hack is enabled, it means we're going through ProcessTraceHit (or SpawnEffects), which
//actually applies the base weapon damage, which *should* still be EMP (the electricity emitter
//will deal Shocked itself).
//
//If the hack is disabled, the damage type is probably being checked by SwitchToBestWeapon, and
//should be considered Shocked instead (unless the enemy is a robot, in which case, still say
//EMP so that it prioritizes it)
function name WeaponDamageType()
{
    local Pawn p;

    if (damageTypeHack){
        //Actually dealing damage, or spawning effects
        return 'EMP';
    }

    //Checking what weapon to use

    p = Pawn(Owner);
    if (p!=None && #var(prefix)Robot(p.Enemy)!=None){
        //If the owner is fighting a robot, consider this EMP still,
        //since the ScriptedPawn logic will prioritize EMP weapons
        //against robots
        return 'EMP';
    }

    //Otherwise, just consider the shocking from the electricity emitter
    return 'Shocked';


}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    damageTypeHack=true;
    Super.ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);
    damageTypeHack=false;
}

//Not really necessary, but for completeness sake
function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other, float Damage)
{
    damageTypeHack=true;
    Super.SpawnEffects(HitLocation, HitNormal, Other, Damage);
    damageTypeHack=false;
}
