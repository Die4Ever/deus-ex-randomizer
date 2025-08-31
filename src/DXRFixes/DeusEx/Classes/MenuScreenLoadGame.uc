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
    local string desc;
    if (saveInfo != None)
    {
        //if(Right(saveInfo.Description, 15) == " CRASH AUTOSAVE") return; // hiding them freaks me out

        //Strip semicolons out of the description, in case someone made a bad save (semicolons are now blocked though)
        //Upgrade them from semi to full colons!
        desc = class'DXRInfo'.static.ReplaceText(saveInfo.Description,";",":");

        lstGames.AddRow( desc                              $ ";" $
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

function EnableButtons()
{
    local int rowId, gameIndex;
    local string name;
    Super.EnableButtons();

    if(lstGames.GetNumSelectedRows() != 1) return;

    rowId = lstGames.GetSelectedRow();
    gameIndex = int(lstGames.GetField(rowId, 4));
    name = lstGames.GetField(rowID, 0);
    if(Right(name, 15) == " CRASH AUTOSAVE") {
        EnableActionButton(AB_Other, false, "LOAD");
    }
}

function LoadGame(int rowId)
{
    local int gameIndex;
    local string name;
    gameIndex = int(lstGames.GetField(rowId, 4));
    name = lstGames.GetField(rowID, 0);
    if(Right(name, 15) == " CRASH AUTOSAVE") {
        return; // crash saves are only for auto loading, not manual loading
    } else if(Right(name, 14) == " EXIT AUTOSAVE") {
        player.ConsoleCommand("set DXRAutosave delete_save " $ gameIndex);
    }
    Super.LoadGame(rowId);
}

defaultproperties
{
    DeleteAutosavesTitle="Delete Autosaves?"
    DeleteAutosavesPrompt="Are you sure you wish to delete autosaves? This will not delete the newest save, or any temporary autosaves in the rotating slots."
    actionButtons(3)=(Action=AB_Other,Text="Delete Autosaves",Key="DELETEAUTOSAVES")
}
//#endregion
