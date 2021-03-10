//=============================================================================
// WeaponHideAGun.
//=============================================================================
class BalancePS40 injects WeaponHideAGun;

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
    local PlasmaBolt proj;
    local float oldDamage, oldmpDamage;
    oldDamage = ProjClass.default.Damage;
    oldmpDamage = class<PlasmaBolt>(ProjClass).default.mpDamage;
    ProjClass.default.Damage = HitDamage;
    class<PlasmaBolt>(ProjClass).default.mpDamage = HitDamage;

    proj = PlasmaBolt(Super.ProjectileFire(ProjClass, ProjSpeed, bWarn));
    if( proj != None ) {
        proj.LightBrightness = 250;
        proj.LightRadius = 20;
        //proj.blastRadius = 257;
    }
    
    ProjClass.default.Damage = oldDamage;
    class<PlasmaBolt>(ProjClass).default.mpDamage = oldmpDamage;
	return proj;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    ItemName="PS40";
    Description="The PS40 is a disposable, plasma-based weapon developed by an unknown security organization as a next generation stealth pistol."
        $ "  Unfortunately, the necessity of maintaining a small physical profile restricts the weapon to a single shot."
        $ "  Despite its limited functionality, the PS40 can be lethal at close range.";
    beltDescription="PS40";
}

defaultproperties
{
    HitDamage=400
    ItemName="PS40"
    Description="The PS40 is a disposable, plasma-based weapon developed by an unknown security organization as a next generation stealth pistol.  Unfortunately, the necessity of maintaining a small physical profile restricts the weapon to a single shot.  Despite its limited functionality, the PS40 can be lethal at close range."
    beltDescription="PS40"
}
