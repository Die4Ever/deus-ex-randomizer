//=============================================================================
// DXRImage09_NYC_Ship_Bottom
//=============================================================================

class DXRImage09_NYC_Ship_Bottom injects Image09_NYC_Ship_Bottom;

function PostPostBeginPlay()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando',dxr) break;

    if (dxr==None || dxr.flags.settings.goals == 0){
        imageTextures[0]=Texture'DeusExUI.UserInterface.Image09_NYC_Ship_Bttm_1';
        imageTextures[1]=Texture'DeusExUI.UserInterface.Image09_NYC_Ship_Bttm_2';
        imageTextures[2]=Texture'DeusExUI.UserInterface.Image09_NYC_Ship_Bttm_3';
        imageTextures[3]=Texture'DeusExUI.UserInterface.Image09_NYC_Ship_Bttm_4';
    }
}

defaultproperties
{
     imageTextures(0)=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_1'
     imageTextures(1)=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_2'
     imageTextures(2)=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_3'
     imageTextures(3)=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_4'
}
