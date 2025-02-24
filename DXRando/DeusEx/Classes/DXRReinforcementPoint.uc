//An object for the UNATCO troops in M08 to run towards, instead of just
//directly ordering them to attack the player (which breaks stealth)
class DXRReinforcementPoint extends Info;

var bool bSetAsHomeBase;

event BaseChange()
{
    if (Base==None && Owner!=None){
        SetLocation(Owner.Location);
        SetBase(Owner);
    }
}

//In reality, this isn't *really* needed, because in mission 8,
//there will only be one of each guy.  If we allowed these to be
//placed on clones, there could be multiple, but we don't.
event Timer()
{
    local DXRReinforcementPoint rp;
    local bool found;

    if (Owner==None){
        //The owner died?

        //See if there are other reinforcement points left
        foreach AllActors(class'DXRReinforcementPoint',rp,Tag){
            if (rp!=Self){
                found=True;
                break;
            }
        }

        if (found){
            //if there are other reinforcement points, this one can be destroyed
            Destroy();
        }
        SetTimer(0,false);
    }
}

//Once pawns reach us, just wander (so that RunningTo doesn't just leave them standing there)
function Touch( actor Other )
{
    local #var(prefix)ScriptedPawn sp;

    sp = #var(prefix)ScriptedPawn(other);

    if (sp==None) return;
    if (sp.OrderTag!=Tag) return;

    //Set the reinforcement point as the new home point, so they don't wander away
    if (bSetAsHomeBase){
        sp.bUseHome = false;
        sp.InitializeHomeBase();
    }

    sp.ClearNextState();
    sp.SetOrders('Wandering',,True);

    //This is an interesting idea I had to prevent clumping, but I think Touch
    //doesn't really work if the collision radius is extended through someone?
    //SetCollisionSize(CollisionRadius+sp.CollisionRadius,CollisionHeight);
}

function SetAsHomeBase(bool b)
{
    bSetAsHomeBase=b;
}

function Init(Actor o)
{
    SetOwner(o);
    SetBase(o);

    //Don't need to track to see if we're the last reinforcement point left
    //SetTimer(1,true);
}

defaultproperties
{
    bCollideActors=true
    bSetAsHomeBase=true
    CollisionRadius=100
}
