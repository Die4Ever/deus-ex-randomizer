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

// DXRando: save as vanilla, just call our middle-man SaveGameCmd function
function PerformSave()
{
    local DeusExRootWindow localRoot;
    local DeusExPlayer localPlayer;
    local int gameIndex;
    local String saveName;

    // Get the save index if this is an existing savegame
    gameIndex = int(lstGames.GetFieldValue(saveRowID, 4));

    // If gameIndex is -2, this is our New Save Game and we
    // need to set gameIndex to 0, which is not a valid
    // gameIndex, in which case the DeusExGameEngine::SaveGame()
    // code will be kind and get us a new GameIndex (Really!
    // If you don't believe me, go look at the code!)

    if (gameIndex == -2)
        gameIndex = 0;

    saveName = editName.GetText();
    if(Right(saveName, 9) == " AUTOSAVE") { // we're not an autosave anymore
        saveName = Left(saveName, Len(saveName)-9);
    }

    localPlayer   = player;
    localRoot     = root;

    localRoot.ClearWindowStack();
    #var(PlayerPawn)(localPlayer).SaveGameCmd(gameIndex, saveName);
    localRoot.Show();
}
