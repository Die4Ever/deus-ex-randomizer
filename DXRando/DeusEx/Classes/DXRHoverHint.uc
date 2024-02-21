class DXRHoverHint extends Info;

var() string HintText;
var Actor target;
var bool attached;

static function DXRHoverHint Create(Actor a, String hint, vector loc, float rad, float height,optional Name targetName)
{
    local DXRHoverHint hoverHint;
    local Actor targetActor;

    hoverHint = a.Spawn(class'DXRHoverHint',,,loc);
    hoverHint.SetCollisionSize(rad,height);
    hoverHint.HintText = hint;

    if (targetName!=''){
        foreach a.AllActors(class'Actor',targetActor){
            if (targetActor.Name==targetName){
                hoverHint.target = targetActor;
                hoverHint.attached = True;
                log("Attached DXRHoverHint to "$targetActor);
                break;
            }
        }

        if (hoverHint.attached==False){
            log("Unable to find target '"$targetName$"' to attach to DXRHoverHint");
        }
    }

    return hoverHint;
}

function bool ShouldDisplay()
{
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

defaultproperties
{
     bCollideActors=True
     bCollideWorld=False
     HintText="HOVER HINT DEFAULT TEXT - REPORT AS A BUG"
     attached=False
     target=None
}
