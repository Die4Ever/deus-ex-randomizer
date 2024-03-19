class FixSaveGameNegativeSpace injects MenuScreenSaveGame;

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
