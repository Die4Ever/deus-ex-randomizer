class DXRMenuScreenLoadGame injects MenuScreenLoadGame;

var string DeleteAutosavesTitle;
var string DeleteAutosavesPrompt;
var bool bDeleteAutosaves;

//#region fix sorting
// https://github.com/Die4Ever/deus-ex-randomizer/issues/133
function CreateGamesList()
{
    Super.CreateGamesList();
    lstGames.SetColumnType(2, COLTYPE_String);
}

function AddSaveRow(DeusExSaveInfo saveInfo, int saveIndex)
{
    if (saveInfo != None)
    {
        lstGames.AddRow( saveInfo.Description              $ ";" $
                         BuildTimeStringFromInfo(saveInfo) $ ";" $
                         BuildTimeStringSeconds(saveInfo)  $ ";" $
                         BuildTimeStringFromInfo(saveInfo) $ ";" $
                         String(saveInfo.DirectoryIndex));
    }
}

function String BuildTimeStringSeconds(DeusExSaveInfo s)
{
    local String retValue;

    retValue = s.Year $"-"$ TwoDigits(s.Month) $"-"$ TwoDigits(s.Day);
    retValue = retValue @ TwoDigits(s.Hour) $ ":" $ TwoDigits(s.Minute) $ ":" $ TwoDigits(s.Second);

    return retValue;
}
//#endregion

//#region Delete Autosaves
function ProcessAction(String actionKey)
{
    local int t;
    if (actionKey == "DELETEAUTOSAVES")
    {
        //t = MB_DeleteAutosaves;
        //msgBoxMode = EMessageBoxModes(MB_DeleteAutosaves);
        msgBoxMode = MB_None;
        bDeleteAutosaves = true;
        root.MessageBox(DeleteAutosavesTitle, DeleteAutosavesPrompt, 0, False, Self);
    }
    else Super.ProcessAction(actionKey);
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    local bool ret;
    ret = Super.BoxOptionSelected(msgBoxWindow, buttonNumber);

    if(bDeleteAutosaves) {
        bDeleteAutosaves = false;
        if (buttonNumber==0) {
            DeleteAutosaves();
        }
        return true;
    }
    return ret;
}

function DeleteAutosaves()
{
    local int i, rowID, slot;
    local string name;

    // make sure we're sorted by newest
    bDateSortOrder = true;
    lstGames.SetSortColumn(2, bDateSortOrder);
    lstGames.Sort();

    // start with index 1 so we don't delete the newest save
    for(i=1; i<lstGames.GetNumRows(); i++) {
        rowID = lstGames.IndexToRowId(i);
        slot = int(lstGames.GetField(rowID, 4));
        if(slot < 0) continue;
        name = lstGames.GetField(rowID, 0);
        if(Right(name, 9) == " AUTOSAVE") {
            player.ConsoleCommand("DeleteGame " $ slot);
        }
    }
    PopulateGames();
}

defaultproperties
{
    DeleteAutosavesTitle="Delete Autosaves?"
    DeleteAutosavesPrompt="Are you sure you wish to delete autosaves? This will not delete the newest save, or any temporary autosaves in the rotating slots."
    actionButtons(3)=(Action=AB_Other,Text="Delete Autosaves",Key="DELETEAUTOSAVES")
}
//#endregion
