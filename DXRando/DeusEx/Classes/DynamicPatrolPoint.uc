class DynamicPatrolPoint extends PatrolPoint;

var ScriptedPawn myGuy;
var vector lastPos;
var float lastMoveTime;

// watch the pawn to see if they get stuck and convert them to wandering
// doing this here instead of inside the pawn so that it works for all mods

function SetMyGuy(ScriptedPawn p)
{
    myGuy = p;
    if(myGuy != None) {
        lastPos = myGuy.Location;
        lastMoveTime = Level.TimeSeconds;
        SetTimer(1.0, true);
    }
}

function Timer()
{
    if(myGuy == None) {
        SetTimer(0, false);
        myGuy = None;
        return;
    }

    if(myGuy.InStasis()) {
        lastMoveTime = Level.TimeSeconds;
    } else if(VSize(lastPos - myGuy.Location) <3) {
        if( (Level.TimeSeconds - lastMoveTime) > 10 ) {
            myGuy.SetOrders('Wandering',, true);
            log(self@myGuy@myGuy.Location$" dynamic patrol was stuck, set to Wandering");
            SetTimer(0, false);
            myGuy = None;
            return;
        }
    }
    else {
        lastMoveTime = Level.TimeSeconds;
        lastPos = myGuy.Location;
    }
}

defaultproperties
{
    bStatic=False
    //bHidden=False
    //DrawScale=3
}
