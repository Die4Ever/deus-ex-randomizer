class DXRAutosave extends DXRBase;

var transient bool bNeedSave;

function FirstEntry()
{
    if( dxr.flags.autosave > 0 ) {
        bNeedSave=true;
    }
}

function ReEntry()
{
    if( dxr.flags.autosave==2 && dxr.flags.f.GetBool('PlayerTraveling') ) {
        bNeedSave=true;
    }
}

function AnyEntry()
{
    if( bNeedSave )
        SetTimer(1.0, True);
}

function Timer()
{
    if( bNeedSave )
        doAutosave();
}

function doAutosave()
{
    local string saveName;
    local DataLinkPlay interruptedDL;
    local int saveSlot;
    local int lastMission;
    
    if( dxr.Player.dataLinkPlay != None ) {
        dxr.Player.dataLinkPlay.AbortDataLink();
        interruptedDL = dxr.Player.dataLinkPlay;
        dxr.Player.dataLinkPlay = None;
    }

    //copied from DeusExPlayer QuickSave()
    if (
        ((dxr.dxInfo == None) && (dxr.dxInfo.MissionNumber < 0)) || 
        ((dxr.Player.IsInState('Dying')) || (dxr.Player.IsInState('Paralyzed')) || (dxr.Player.IsInState('Interpolating'))) || 
        (dxr.Player.dataLinkPlay != None) || (dxr.Level.Netmode != NM_Standalone) || (dxr.Player.InConversation())
    ){
        l("doAutosave() not saving");
        return;
    }

    saveSlot = -1;
    lastMission = dxr.flags.f.GetInt('Rando_lastmission');
    if( lastMission != 0 && dxr.dxInfo.MissionNumber != 0 && lastMission != dxr.dxInfo.MissionNumber ) {
        saveSlot = 0;
    }
    dxr.flags.f.SetInt('Rando_lastmission', dxr.dxInfo.MissionNumber);

    saveName = "DXR " $ dxr.seed $ ": " $ dxr.dxInfo.MissionLocation;
    dxr.Player.SaveGame(saveSlot, saveName);
    bNeedSave = false;
    if( interruptedDL != None ) {
        dxr.Player.dataLinkPlay = interruptedDL;
        dxr.Player.ResumeDataLinks();
    }

    SetTimer(0, False);
}
