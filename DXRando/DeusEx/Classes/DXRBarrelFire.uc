class DXRBarrelFire injects #var(prefix)BarrelFire;

var float lastIgniteTime;

function DamageOther(Actor Other)
{
  //This function does nothing now
}

function DamageOtherReal(Actor Other,bool supporting)
{
	if ((Other != None) && !Other.IsA('ScriptedPawn'))
	{
        //Only make it possible to ignite periodically, but this takes precedence over regular damage
        if (supporting && Level.TimeSeconds - lastIgniteTime >= 5.0)
        {
            Other.TakeDamage(5, None, Location, vect(0,0,0), 'Flamed');
            lastIgniteTime = Level.TimeSeconds;
            lastDamageTime = Level.TimeSeconds;
        }

		// only take damage every second
		if (Level.TimeSeconds - lastDamageTime >= 1.0)
		{
			Other.TakeDamage(5, None, Location, vect(0,0,0), 'Burned');
			lastDamageTime = Level.TimeSeconds;
		}
	}
}

singular function SupportActor(Actor Other)
{
	DamageOtherReal(Other,True);
	Super(Containers).SupportActor(Other);
}

singular function Bump(Actor Other)
{
	DamageOtherReal(Other,False);
	Super(Containers).Bump(Other);
}

function Tick(float delta)
{
    if( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self) ) {
        DamageOtherReal(Base, False);
    }

    log("barrelfire SoundRadius:  " $ SoundRadius);
    log("barrelfire SoundVolume:  " $ SoundVolume);
    log("barrelfire AmbientSound: " $ AmbientSound);

    Super.Tick(delta);
}

function Destroyed()
{
    class'TrashContainerCommon'.static.GenerateTrashPaper(self, 0.5, true);
    Super.Destroyed();
}

// same Mass and Buoyancy as Barrel1
// vanilla uses FireSmall2, which is almost inaudible
defaultproperties
{
    Mass=80
    Buoyancy=90
    bInvincible=False
    SoundRadius=32
    SoundVolume=200
    AmbientSound=Sound'Ambient.Ambient.FireSmall1'
}
