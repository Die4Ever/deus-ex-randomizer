class DrawWeaponTrigger extends Trigger;

var bool bKeepWeaponDrawn;

function Touch(Actor Other)
{
    Super.Touch(Other);

    if (IsRelevant(Other))
    {
        DrawWeapon();
        if(bTriggerOnceOnly) Destroy();
    }
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    DrawWeapon();
    if(bTriggerOnceOnly) Destroy();
}

function DrawWeapon()
{
    local #var(prefix)ScriptedPawn sp;
    local name cloneevent;

    if (Event != '') {

        foreach AllActors(class '#var(prefix)ScriptedPawn', sp, Event) {
            sp.SetupWeapon(true,true);
            if (bKeepWeaponDrawn) sp.bKeepWeaponDrawn=true;
        }

        //Also apply to any clones
        cloneevent = class'DXRInfo'.static.StringToName(Event $ "_clone");
        foreach AllActors(class '#var(prefix)ScriptedPawn', sp, cloneevent) {
            sp.SetupWeapon(true,true);
            if (bKeepWeaponDrawn) sp.bKeepWeaponDrawn=true;
        }
    }
}

static function DrawWeaponTrigger Create(Actor a, name Tag, Name event, vector loc, bool keepWeaponDrawn, optional float rad, optional float height)
{
    local DrawWeaponTrigger dwt;

    dwt = a.Spawn(class'DrawWeaponTrigger',,Tag,loc);
    dwt.event = event;
    dwt.bKeepWeaponDrawn=keepWeaponDrawn;

    if (rad!=0 && height!=0){
        dwt.SetCollisionSize(rad,height); //You want collision
    } else {
        dwt.SetCollision(False,False,False); //Disable collision, trigger only
    }

    return dwt;
}
