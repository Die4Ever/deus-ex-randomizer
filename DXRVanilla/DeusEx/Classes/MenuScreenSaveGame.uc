class DXRMenuScreenSaveGame injects MenuScreenSaveGame;

// Fix negative free space issue, if you don't have Kentie's Launcher installed
function ConfirmSaveGame()
{
    // First check to see how much disk space we have.
    // If < the minimum, then notify the user to clear some
    // disk space.
    if (((freeDiskSpace / 1024) < minFreeDiskSpace) && (freeDiskSpace>=0))
    {
        msgBoxMode = MB_LowSpace;
        root.MessageBox(DiskSpaceTitle, DiskSpaceMessage, 1, False, Self);
    }
    else
    {
        if (freeDiskSpace < 0)
        {
            msgBoxMode = MB_LowSpace;
            root.MessageBox(DiskSpaceTitle, "Disk Space is getting read as negative.  You may want to install a launcher to fix that!", 1, False, Self);
        }

        if (editRowId == newSaveRowId)
        {
            SaveGame(editRowId);
        }
        else
        {
            saveRowId = editRowId;
            msgBoxMode = MB_Overwrite;
            root.MessageBox( OverwriteTitle, OverwritePrompt, 0, False, Self);
        }
    }
}

function SaveGame(int rowId)
{
    if( !class'DXRAutosave'.static.AllowManualSaves(player) ) return;
    class'DXRAutosave'.static.UseSaveItem(player);
    Super.SaveGame(rowId);
}
