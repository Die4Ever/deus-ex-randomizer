class DXRHoverHint extends Info;

var() string HintText;
var() int VisibleDistance;
var Actor target;
var bool attached, addBingoText;

var Actor baseActor;
var bool bInWorld;

static function DXRHoverHint Create(Actor a, String hint, vector loc, float rad, float height, optional Actor target, optional Name targetName, optional bool addBingoText)
{
    local DXRHoverHint hoverHint;
    local Actor act;

    act = a.Spawn(default.class,,,loc);
    hoverHint = DXRHoverHint(act);
    hoverHint.SetCollisionSize(rad,height);
    hoverHint.HintText = hint;
    hoverHint.addBingoText = addBingoText;

    if (target != None){
        hoverHint.target = target;
        hoverHint.attached = true;
    }
    else if (targetName!=''){
        hoverHint.AttachTarget(targetName);
    }

    return hoverHint;
}

function ReplaceActor(Actor old, Actor newA)
{
    if (Base==old){
        SetBaseActor(newA);
    }

    if (target==old){
        target=newA;
    }
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
        log("ERROR: Unable to find target '"$targetName$"' to attach to DXRHoverHint");
    }
}

function SetBaseActor(Actor base)
{
    baseActor = base;
    SetLocation(baseActor.Location);
    SetBase(baseActor);

    //The tick logic is primarily for handling EnterWorld/LeaveWorld,
    //so only activate for things that can do that.
    if (#var(prefix)ScriptedPawn(baseActor)!=None || #var(prefix)Vehicles(baseActor)!=None){
        //Initialize bInWorld before ticking, in case the base actor changes state before their first tick
        if (#var(prefix)ScriptedPawn(baseActor)!=None){
            bInWorld = ScriptedPawn(baseActor).bInWorld;
        }
        if (#var(prefix)Vehicles(baseActor)!=None){
            bInWorld = #var(prefix)Vehicles(baseActor).bInWorld;
        }
        Enable('Tick');
    }
}

function bool ShouldDisplay(float dist)
{
    if (dist > VisibleDistance){
        return False;
    }

    if (baseActor!=None){
        if (#var(prefix)ScriptedPawn(baseActor)!=None){
            if ((#var(prefix)ScriptedPawn(baseActor).bInWorld==False)){
                return False;
            }
        }
        if (#var(prefix)Vehicles(baseActor)!=None){
            if ((#var(prefix)Vehicles(baseActor).bInWorld==False)){
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
    if (addBingoText) {
        return class'DXRBingoCampaign'.static.GetBingoHoverHintText(class'DXRando'.default.dxr, HintText);
    }
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
     VisibleDistance=2000
}
