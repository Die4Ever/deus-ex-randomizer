//This trigger makes the targeted pawn turn to face towards the player when activated (by touch or trigger)
class FacePlayerTrigger extends Trigger;

function Touch(Actor Other)
{
    Super.Touch(Other);

    if (IsRelevant(Other))
    {
        FacePlayer();
        if(bTriggerOnceOnly) Destroy();
    }
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    FacePlayer();
    if(bTriggerOnceOnly) Destroy();
}


function FacePlayer()
{
    local #var(prefix)ScriptedPawn sp;
    local #var(PlayerPawn) player;

    if (Event != '') {
        foreach AllActors(class'#var(PlayerPawn)',player){break;}
        if (player==None) return;

        foreach AllActors(class '#var(prefix)ScriptedPawn', sp, Event) {
            sp.LookAtActor(player,true,true,true);
        }
    }

}

static function FacePlayerTrigger Create(Actor a, Name event, vector loc, optional float rad, optional float height)
{
    local FacePlayerTrigger fpt;

    fpt = a.Spawn(class'FacePlayerTrigger',,,loc);
    fpt.event = event;

    if (rad!=0 && height!=0){
        fpt.SetCollisionSize(rad,height); //You want collision
    } else {
        fpt.SetCollision(False,False,False); //Disable collision, trigger only
    }

    return fpt;

}

defaultproperties
{
    bTriggerOnceOnly=true
}
