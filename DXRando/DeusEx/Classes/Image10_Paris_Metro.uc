//=============================================================================
// DXRImage10_Paris_Metro
//=============================================================================

class DXRImage10_Paris_Metro injects Image10_Paris_Metro;

function PostPostBeginPlay()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando',dxr) break;

    if (dxr==None || dxr.flags.settings.goals == 0){
        imageTextures[1]=Texture'DeusExUI.UserInterface.Image10_Paris_Metro_2';
        imageTextures[2]=Texture'DeusExUI.UserInterface.Image10_Paris_Metro_3';
        imageTextures[3]=Texture'DeusExUI.UserInterface.Image10_Paris_Metro_4';
    }
}

defaultproperties
{
     imageTextures(0)=Texture'DeusExUI.UserInterface.Image10_Paris_Metro_1'
     imageTextures(1)=Texture'#var(package).DXRandoImages.Image10_Paris_Metro_2'
     imageTextures(2)=Texture'#var(package).DXRandoImages.Image10_Paris_Metro_3'
     imageTextures(3)=Texture'#var(package).DXRandoImages.Image10_Paris_Metro_4'
}

