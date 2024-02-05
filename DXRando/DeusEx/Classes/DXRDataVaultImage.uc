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
