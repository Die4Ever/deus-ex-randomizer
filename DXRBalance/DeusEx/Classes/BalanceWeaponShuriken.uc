class BalanceWeaponShuriken injects WeaponShuriken;

simulated function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
    local DeusExProjectile p;
    local float skill, mult;
    local int i;

    skill = GetWeaponSkill();
    mult = (-2.0 * skill) + 1.0;
    p = DeusExProjectile(Super.ProjectileFire(ProjClass, ProjSpeed, bWarn));
    p.speed *= mult;
    p.Velocity *= mult;
    p.AccurateRange = float(p.AccurateRange) * mult;
    return p;
}

simulated function TweenDown()
{
    CheckSkill();
    Super.TweenDown();
}

function TweenSelect()
{
    CheckSkill();
    Super.TweenSelect();
}

function PlaySelect()
{
    CheckSkill();
    Super.PlaySelect();
}

simulated function PlaySelectiveFiring()
{
    CheckSkill();
    Super.PlaySelectiveFiring();
}

function CheckSkill()
{
    local DeusExPlayer player;
    player = DeusExPlayer(Owner);

    if( player != None ) {
        ShotTime = default.ShotTime * (1+GetWeaponSkill());
    }
}

defaultproperties
{
    PickupAmmoCount=20
    ShotTime=0.3
    ReloadCount=1
    HitDamage=20
}
