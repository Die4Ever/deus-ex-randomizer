class GMDX9RubberBullet extends RubberBullet;
#compileif gmdxnotae

var float dmgMult;

/*
 * The GMDX V9 Rubber bullet uses hardcoded damage values, and has an actual damage of 0.
 * This replacement projectile will have real damage values that can be randomized and
 * used when applying damage.  Sawed-off shotguns do an additional 35% damage according
 * to the sawed-off description, but 13 -> 19 is more like 46%?  Damage mod value gets
 * passed into the projectile already.
 *
 * AE has already taken this stuff into account and should work without this.
 */

function PreBeginPlay()
{
    local #var(PlayerPawn) p;

    Super.PreBeginPlay();

    p = #var(PlayerPawn)(Owner);
    if (p!=None && p.InHand!=None){
        if (WeaponSawedOffShotgun(p.InHand)!=None){
            dmgMult = 1.35;
        }
    }
}

function bool IsValidTarget(Actor other)
{
    return (Other.IsA('Pawn') || Other.IsA('DeusExDecoration') || Other.IsA('DeusExPickup'));
}

event Bump( Actor Other )
{
    local float curSpeed;
    local float finalDmg;

    curSpeed = VSize(Velocity);
    if (curSpeed > 1000)
    {
        if (IsValidTarget(Other))
        {
            finalDmg = (Damage * dmgMult);
            Other.TakeDamage(int(finalDmg),Pawn(Owner),Location,0.5*Velocity,'KnockedOut');
        }
    }
}

 defaultproperties
{
    Damage=13.0
    dmgMult=1.0
}
