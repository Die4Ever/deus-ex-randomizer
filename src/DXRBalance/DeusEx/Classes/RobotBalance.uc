class DXRRobotBalance shims Robot;

var bool bHasBeenPet;
var bool bPetInProgress;

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
    local int oldEMPHitPoints;

    oldEMPHitPoints = EMPHitPoints;

    // robots now have 25% damage resistance for plasma instead of 75%
    if(damageType == 'Burned' && class'MenuChoice_BalanceEtc'.static.IsEnabled()) Damage *= 3;

    Super.TakeDamageBase(Damage, instigatedBy, hitLocation, momentum, damageType, bPlayAnim);

    if (EMPHitPoints <= 0 && EMPHitPoints < oldEMPHitPoints){
        //Robot freshly disabled
        class'DXREventsBase'.static.AddPawnDeath(self,instigatedBy,damageType,hitLocation);
    }
}

//Copied from the various Human classes.  Makes it more possible to filter out
//accidentally walking on one vs actively jumping on one
function bool WillTakeStompDamage(actor stomper)
{
	// This blows chunks!
	if (stomper.IsA('PlayerPawn') && (GetPawnAllianceType(Pawn(stomper)) != ALLIANCE_Hostile))
		return false;
	else
		return true;
}

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        BaseAccuracy=0.1;
    } else {
        BaseAccuracy=0;
    }
    default.BaseAccuracy=BaseAccuracy;
    Super.BeginPlay();
}

function EndPetting(optional bool bInterrupted)
{
    local DXRCameraModes camera;

    if (!bPetInProgress) return;

    foreach AllActors(class'DXRCameraModes',camera)
        break;

    if (camera!=None) {
        camera.DisableTempCamera();

        if (!bHasBeenPet && !bInterrupted){
            bHasBeenPet=True;
            class'DXREvents'.static.MarkBingo("PetRobot_"$Class.Name);

            if (BindName!=Default.BindName){
                class'DXREvents'.static.MarkBingo("PetRobot_BindName_"$BindName);
            }
        }
        camera.player().bBlockAnimations=False;
        camera.player().AnimEnd(); //Kicks the appropriate normal animations off again
    }
    bPetInProgress=False;
}

function Timer()
{
    EndPetting();
}

function Destroyed()
{
    EndPetting(True); //If they die before you finish petting them, don't mark the bingo
    Super.Destroyed();
}

function PetRobot(#var(PlayerPawn) petter)
{
    local DXRCameraModes camera;
    local float animTime,tweenTime;
    local bool highPet;

    if (petter==None) return;
    if (petter.InHand!=None) return; //Must have free hands to pet!
    if (petter.CarriedDecoration!=None) return; //Seriously, free hands
    if (petter.Region.Zone.bWaterZone) return; //No underwater petting (but you can pet things that are IN the water)
    if (bPetInProgress) return; //No pet interruptions
    //if (GetAllianceType('player')==ALLIANCE_Hostile) return;

    foreach AllActors(class'DXRCameraModes',camera)
        break;

    camera.EnableTempThirdPerson(true);

    highPet=False;
    if ((petter.bIsCrouching || petter.bForceDuck)){
        if (Location.Z - petter.Location.Z > 25){
            highPet=True;
        }
    } else {
        if (petter.Location.Z - Location.Z < 25){
            highPet=True;
        }
    }

    petter.bBlockAnimations=True;

    if (highPet){
        petter.PlayAnim('PushButton',0.75,0.1);
        animTime=1.75;
    }else{
        petter.PlayAnim('Pickup',0.5,0.1);
        animTime=1.25;
    }

    SetTimer(animTime,False);
    bPetInProgress=True;
}

function Frob(Actor Frobber, Inventory frobWith)
{
    local #var(PlayerPawn) p;
    local bool canPet;
    local DXRando dxr;

    Super.Frob(Frobber,frobWith);

    p = #var(PlayerPawn)(Frobber);

    if (p!=None){
        canPet = true;

        //Robots probably don't have conversations, but check anyway
        //(basically, make sure the Super.Frob above didn't put us in a conversation)
        if (p.conPlay!=None && p.conPlay.con!=None && p.conPlay.con.bFirstPerson==False){
            //Don't allow petting during third person conversations (aka real conversations)
            canPet = false;
        }

        //These guys open up a window when frobbed, don't pet them
        if (#var(prefix)RepairBot(self)!=None || #var(prefix)MedicalBot(self)!=None){
            canPet = false;
        }
    }

    if (canPet){
        PetRobot(p);
    }
}


defaultproperties
{
    BaseAccuracy=0.1
}
