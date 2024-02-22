class DXRHoverHint extends Info;

var() string HintText;
var Actor target;
var bool attached;

var Actor baseActor;
var bool bInWorld;

static function DXRHoverHint Create(Actor a, String hint, vector loc, float rad, float height,optional Name targetName)
{
    local DXRHoverHint hoverHint;

    hoverHint = DXRHoverHint(a.Spawn(GetSelfClass(),,,loc));
    hoverHint.SetCollisionSize(rad,height);
    hoverHint.HintText = hint;

    if (targetName!=''){
        hoverHint.AttachTarget(targetName);
    }

    return hoverHint;
}

static function class<Actor> GetSelfClass()
{
    return class'DXRHoverHint';
}

function AttachTarget(name targetName)
{
    local Actor targetActor;

    foreach AllActors(class'Actor',targetActor){
        if (targetActor.Name==targetName){
            target = targetActor;
            attached = True;
            break;
        }
    }

    if (attached==False){
        log("Unable to find target '"$targetName$"' to attach to DXRHoverHint");
    }
}

function SetBaseActor(Actor base)
{
    baseActor = base;
    SetBase(baseActor);

    //The tick logic is primarily for handling EnterWorld/LeaveWorld,
    //so only activate for things that can do that.
    if (ScriptedPawn(baseActor)!=None || Vehicles(baseActor)!=None){
        Enable('Tick');
    }
}

function bool ShouldDisplay()
{
    if (baseActor!=None){
        if (ScriptedPawn(baseActor)!=None){
            if ((ScriptedPawn(baseActor).bInWorld==False)){
                return False;
            }
        }
        if (Vehicles(baseActor)!=None){
            if ((Vehicles(baseActor).bInWorld==False)){
                return False;
            }
        }
    }

    return True;
}

function bool ShouldSelfDestruct()
{
    //Check if the attached target has been destroyed
    if (attached){
        if (#var(DeusExPrefix)Mover(target)!=None){
            return #var(DeusExPrefix)Mover(target).bDestroyed;
        } else {
            return (target==None);
        }
    }

    return False;
}

function String GetHintText()
{
    return HintText;
}

event Tick(float DeltaTime)
{
    local bool nowInWorld;
    if (baseActor==None){
        return;
    }

    if (ScriptedPawn(baseActor)!=None){
        nowInWorld=ScriptedPawn(baseActor).bInWorld;
    } else if (Vehicles(baseActor)!=None){
        nowInWorld=Vehicles(baseActor).bInWorld;
    } else {
        return;
    }

    if (nowInWorld!=bInWorld){
        SetLocation(baseActor.Location);
        bInWorld = nowInWorld;
        SetBase(baseActor);
    }
}

//You would think this would work...  It calls SetLocation and SetBase, but it stays where it is.
//Presumably the base changes to None before the baseActor actually moves?
/*
event BaseChange()
{
    log ("Base before: "$base);
    Super.BaseChange();
    log ("Base after: "$base);
    if (baseActor!=None && base==None){
        log("Moving to base actor location");
        SetLocation(baseActor.Location);
        SetBase(baseActor);
    }
}
*/

defaultproperties
{
     bCollideActors=True
     bCollideWorld=False
     HintText="HOVER HINT DEFAULT TEXT - REPORT AS A BUG"
     attached=False
     target=None
     bInWorld=False
}
