//=============================================================================
// DXRImage05_NYC_MJ12Lab
//=============================================================================

class DXRImage05_NYC_MJ12Lab injects Image05_NYC_MJ12Lab;

function PostPostBeginPlay()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando',dxr) break;

    if (dxr==None || dxr.flags.settings.goals == 0){
        imageTextures[0]=Texture'DeusExUI.UserInterface.Image05_NYC_MJ12Lab_1';
        imageTextures[1]=Texture'DeusExUI.UserInterface.Image05_NYC_MJ12Lab_2';
        imageTextures[2]=Texture'DeusExUI.UserInterface.Image05_NYC_MJ12Lab_3';
    }
}

defaultproperties
{
     imageTextures(0)=Texture'#var(package).DXRandoImages.Image05_NYC_MJ12Lab_1'
     imageTextures(1)=Texture'#var(package).DXRandoImages.Image05_NYC_MJ12Lab_2'
     imageTextures(2)=Texture'#var(package).DXRandoImages.Image05_NYC_MJ12Lab_3'
     imageTextures(3)=Texture'DeusExUI.UserInterface.Image05_NYC_MJ12Lab_4'

}

