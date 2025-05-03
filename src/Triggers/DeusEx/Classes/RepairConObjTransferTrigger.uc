class RepairConObjTransferTrigger extends Trigger;

var name conName;
var string packages[5];

function Trigger(Actor Other, Pawn Instigator)
{
    local ConEventTransferObject e;

    foreach AllObjects(class'ConEventTransferObject',e)
    {
        if (e.conversation.conName != conName) continue;
        if (e.objectName!="" && e.giveObject==None){
            RepairConEventTransferObjectClassReference(e);
        }
    }
}

function RepairConEventTransferObjectClassReference(ConEventTransferObject e)
{
    local class<Inventory> actualClass;
    local string className;
    local bool fullyQualified;
    local int i;

    className = e.objectName;
    if(instr(e.objectName, ".") != -1) {
        fullyQualified = true;
    }

    actualClass = class<inventory>(DynamicLoadObject(className, class'Class')); //Try loading the named class directly

    if (!fullyQualified){
        //if the class was fully qualified (with a package name), we have to assume that was the intended class
        //whether we find it or not.  If it wasn't, let's try some other packages
        for (i=0;i<ArrayCount(packages);i++)
        {
            if (packages[i]=="") continue;
            className = packages[i]$"."$e.objectName;
            actualClass = class<inventory>(DynamicLoadObject(className, class'Class'));
            if (actualClass!=None){
                break;
            }
        }
    }

    if (actualClass==None){
        //Couldn't find a viable class, no repair possible on this event
        return;
    }

    e.giveObject = actualClass;
}


function AddPackage(string packageName)
{
    local int i;
    for (i=0;i<ArrayCount(packages);i++)
    {
        if (packages[i]!="") continue;
        if (packages[i]==packageName) return; //Don't add the same thing twice
        packages[i]=packageName;
        return;
    }
}


defaultproperties
{
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bProjTarget=false
    bTriggerOnceOnly=false
    packages(0)="DeusEx"
}
