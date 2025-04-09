class FixLoadGameSort injects MenuScreenLoadGame;
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
