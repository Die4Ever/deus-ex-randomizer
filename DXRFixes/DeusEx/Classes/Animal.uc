class DXRAnimal merges Animal;
// TODO: we can change this to injects but it breaks savegame compatibility

var bool bHasBeenPet;
var bool bPetInProgress;

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
{
    return Super(ScriptedPawn).ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
}

function PlayDying(name damageType, vector hitLoc)
{
    Super(FixScriptedPawn).PlayDying(damageType, hitLoc);
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
            class'DXREvents'.static.MarkBingo(camera.dxr,"PetAnimal_"$Class.Name);
        }
        camera.player().bBlockAnimations=False;
        camera.player().AnimEnd(); //Kicks the appropriate normal animations off again
    }
    bPetInProgress=False;
}

//Animal petting
function Timer()
{
    EndPetting();
}

function Destroyed()
{
    EndPetting(True); //If they die before you finish petting them, don't mark the bingo
    Super.Destroyed();
}

function PetAnimal(#var(PlayerPawn) petter)
{
    local DXRCameraModes camera;
    local float animTime,tweenTime;
    local bool highPet;

    if (petter==None) return;
    if (petter.InHand!=None) return; //Must have free hands to pet!
    if (petter.Region.Zone.bWaterZone) return; //No underwater petting (but you can pet things that are IN the water)
    if (Fly(self)!=None) return; //No, you can't pet the flies
    if (bPetInProgress) return; //No pet interruptions
    //if (GetAllianceType('player')==ALLIANCE_Hostile) return;

    foreach AllActors(class'DXRCameraModes',camera)
        break;

    camera.EnableTempThirdPerson(camera.IsFirstPersonGame());

    highPet=False;
    if ((petter.bIsCrouching || petter.bForceDuck)){
        if (Location.Z - petter.Location.Z > 16){
            highPet=True;
        }
    } else {
        if (petter.Location.Z - Location.Z < 16){
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
    if (#var(PlayerPawn)(Frobber)!=None){
        PetAnimal(#var(PlayerPawn)(Frobber));
    }
}
