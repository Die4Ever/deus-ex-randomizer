class BalanceWeaponShuriken injects WeaponShuriken;

var bool auto_pickup;

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

function Touch( actor Other )
{
    local DeusExPlayer p;
    Super.Touch(Other);

    if(!auto_pickup) return;
    p = DeusExPlayer(Other);
    if(p == None) return;

    if( ! class'DXRActorsBase'.static.HasItem(p, self.class) ) return;
    p.FrobTarget = Self;
    p.ParseRightClick();
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
    ShotTime=0.5
    ReloadCount=1
    HitDamage=18
}
