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

defaultproperties
{
     bCollideActors=True
     bCollideWorld=False
     HintText="HOVER HINT DEFAULT TEXT - REPORT AS A BUG"
     attached=False
     target=None
}
