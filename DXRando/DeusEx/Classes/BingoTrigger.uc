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

	if (IsRelevant(Other))
	{
		DoBingoThing();
	}
}


function DoBingoThing()
{
    local DXRando dxr;

    if (bingoEvent==""){
        return;
    }

    foreach AllActors(class'DXRando',dxr){
        class'DXREvents'.static.MarkBingo(dxr,bingoEvent);
        break;
    }

    if (bTriggerOnceOnly) {
        bingoEvent = "";
        Destroy();
    }
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

}

defaultproperties
{
     bingoEvent=""
     bTriggerOnceOnly=True
}
