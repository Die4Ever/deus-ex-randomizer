//=============================================================================
// DXRDataVaultImage
//=============================================================================

class DXRDataVaultImage injects DataVaultImage;

function AddNote(DataVaultImageNote newNote)
{
    Super.AddNote(newNote);

    if (!class'DXRVersion'.static.VersionIsStable() && owner!=None){
        DeusExPlayer(owner).ClientMessage("New note '"$newNote.noteText$"' added at X"$newNote.posX$"  Y"$newNote.posY);
    }
}


static function UpdateDataVaultImageTextures(DataVaultImage newImage)
{
    local DXRando dxr;

    foreach newImage.AllActors(class'DXRando',dxr) {break;}

    //Check if we're ready or not
    if (dxr==None) return;
    if (dxr.flags==None) return;
    if (dxr.flags.flags_loaded==False) return;
    if (dxr.flags.settings.goals == 0) return;

    switch(newImage.class.name){
        case 'Image09_NYC_Ship_Bottom':
            newImage.imageTextures[0]=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_1';
            newImage.imageTextures[1]=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_2';
            newImage.imageTextures[2]=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_3';
            newImage.imageTextures[3]=Texture'#var(package).DXRandoImages.Image09_NYC_Ship_Bttm_4';
            break;
    }
}
