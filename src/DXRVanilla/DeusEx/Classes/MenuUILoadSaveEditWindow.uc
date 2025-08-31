class DXRMenuUILoadSaveEditWindow injects MenuUILoadSaveEditWindow;

//*ACTUALLY* prevent semicolons
function bool FilterChar(out string chStr)
{
    return ((chStr != ";") && (!bReadOnly));

    //Original logic was just wrong
    //return ((chStr != ";") || (!bReadOnly));
}
