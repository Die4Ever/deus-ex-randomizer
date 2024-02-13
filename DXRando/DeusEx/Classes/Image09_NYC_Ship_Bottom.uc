//=============================================================================
// DXRImage09_NYC_Ship_Bottom
//=============================================================================

class DXRImage09_NYC_Ship_Bottom injects Image09_NYC_Ship_Bottom;

function PostBeginPlay()
{
    CheckImageUpdate(); //Check the state immediately
}

simulated event Timer()
{
    CheckImageUpdate();
}

function CheckImageUpdate()
{
    local DXRando dxr;

    SetTimer(1,True); //In case we need to check for DXR again later

    foreach AllActors(class'DXRando',dxr) break;

    //Check if we're ready or not
    if (dxr==None) return;
    if (dxr.flags==None) return;
    if (dxr.flags.flags_loaded==False) return;

    if (dxr.flags.settings.goals == 0){
        SetVanillaTextures();
    }

    SetTimer(0,False);

}

function SetVanillaTextures()
{
    imageTextures[0]=Texture'DeusExUI.UserInterface.Image09_NYC_Ship_Bttm_1';
    imageTextures[1]=Texture'DeusExUI.UserInterface.Image09_NYC_Ship_Bttm_2';
    imageTextures[2]=Texture'DeusExUI.UserInterface.Image09_NYC_Ship_Bttm_3';
    imageTextures[3]=Texture'DeusExUI.UserInterface.Image09_NYC_Ship_Bttm_4';
}

defaultproperties
{
     imageTextures(0)=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_1'
     imageTextures(1)=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_2'
     imageTextures(2)=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_3'
     imageTextures(3)=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_4'
}
