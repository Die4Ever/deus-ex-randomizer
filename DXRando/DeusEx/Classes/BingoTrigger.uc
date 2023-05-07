//=============================================================================
// BingoTrigger.
//=============================================================================
class BingoTrigger expands Trigger;

var() String bingoEvent;

function Trigger(Actor Other, Pawn Instigator)
{
	Super.Trigger(Other, Instigator);
    DoBingoThing();

}

function Touch(Actor Other)
{
	Super.Touch(Other);

	if (TriggerType!=TT_Shoot && IsRelevant(Other))
	{
		DoBingoThing();
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
    if (TriggerType==TT_Shoot && instigatedBy.bIsPlayer)
	{
        DoBingoThing();
    }
}


function DoBingoThing()
{
    local DXRando dxr;
    local BingoTrigger bt;

    if (bingoEvent==""){
        return;
    }

    foreach AllActors(class'DXRando',dxr){
        class'DXREvents'.static.MarkBingo(dxr,bingoEvent);
        break;
    }

    if (bTriggerOnceOnly) {
        foreach AllActors(class'BingoTrigger',bt,Tag){
            bt.SelfDestruct();
        }
    }
}

function SelfDestruct()
{
    bingoEvent = "";
    Destroy();
}

function MakeShootingTarget()
{
    TriggerType = TT_Shoot;
    bProjTarget=True;
    DamageThreshold=0;
}

function MakeClassProximityTrigger(class<Actor> className)
{
    TriggerType=TT_ClassProximity;
    ClassProximityType=className;
}

static function BingoTrigger Create(Actor a, Name bingoEvent, vector loc, optional float rad, optional float height)
{
    local BingoTrigger bt;

    bt = a.Spawn(class'BingoTrigger',,bingoEvent,loc); //Tag defaults to the bingoEvent name
    bt.bingoEvent = string(bingoEvent);

    if (rad!=0 && height!=0){
        bt.SetCollisionSize(rad,height); //You want collision
    } else {
        bt.SetCollision(False,False,False); //Disable collision, trigger only
    }

    return bt;

}

defaultproperties
{
     bingoEvent=""
     bTriggerOnceOnly=True
}
