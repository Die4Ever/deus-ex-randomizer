class DXRAnimal merges Animal;
// TODO: we can change this to injects but it breaks savegame compatibility

var bool bHasBeenPet;

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
{
    return Super(ScriptedPawn).ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
}

function PlayDying(name damageType, vector hitLoc)
{
    Super(FixScriptedPawn).PlayDying(damageType, hitLoc);
}

//Animal petting
function Timer()
{
    local DXRCameraModes camera;

    foreach AllActors(class'DXRCameraModes',camera)
        break;

    if (camera!=None) {
        camera.DisableTempCamera();

        if (!bHasBeenPet){
            bHasBeenPet=True;
            class'DXREvents'.static.MarkBingo(camera.dxr,"PetAnimal_"$Class.Name);
        }
        camera.player().bPetting=False;
        camera.player().AnimEnd();
    }
}

function PetAnimal(#var(PlayerPawn) petter)
{
    local DXRCameraModes camera;
    local float animTime,tweenTime;
    local bool highPet;

    if (petter==None) return;
    if (GetAllianceType('player')==ALLIANCE_Hostile) return;

    foreach AllActors(class'DXRCameraModes',camera)
        break;

    camera.EnableTempThirdPerson();

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

    petter.bPetting=True;
    if (highPet){
        petter.PlayAnim('PushButton',0.75,0.1);
        animTime=1.75;
    }else{
        petter.PlayAnim('Pickup',0.5,0.1);
        animTime=1.25;
    }
    SetTimer(animTime,False);

}

function Frob(Actor Frobber, Inventory frobWith)
{
    if (#var(PlayerPawn)(Frobber)!=None){
        PetAnimal(#var(PlayerPawn)(Frobber));
    }
}
