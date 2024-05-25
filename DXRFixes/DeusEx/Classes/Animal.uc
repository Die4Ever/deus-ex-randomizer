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
    }
}

function PetAnimal(#var(PlayerPawn) petter)
{
    local DXRCameraModes camera;
    local float animTime;

    if (petter==None) return;
    if (GetAllianceType('player')==ALLIANCE_Hostile) return;

    foreach AllActors(class'DXRCameraModes',camera)
        break;

    camera.EnableTempThirdPerson();

    //This should probably have some logic around crouching
    if (petter.Location.Z - Location.Z < 16){
        petter.PlayAnim('PushButton',0.75,0.5);
        animTime=2.25;
    }else{
        petter.PlayAnim('Pickup',0.5,0.1);
        animTime=1.5;
    }
    SetTimer(animTime,False);

}

function Frob(Actor Frobber, Inventory frobWith)
{
    if (#var(PlayerPawn)(Frobber)!=None){
        PetAnimal(#var(PlayerPawn)(Frobber));
    }
}
