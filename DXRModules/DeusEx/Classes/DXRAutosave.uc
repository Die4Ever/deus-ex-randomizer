class DXRAutosave extends DXRBase transient;

var transient bool bNeedSave;
var config float save_delay;

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,8) ) {
        save_delay = default.save_delay;
    }
    Super.CheckConfig();
}

function PostFirstEntry()
{
    Super.PostFirstEntry();
    if( dxr.dxInfo != None && dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 && dxr.flags.autosave > 0 ) {
        bNeedSave=true;
    }
}

function ReEntry(bool IsTravel)
{
    Super.ReEntry(IsTravel);
    if( dxr.dxInfo != None && dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 && dxr.flags.autosave==2 && IsTravel ) {
        bNeedSave=true;
    }
}

function AnyEntry()
{
    Super.AnyEntry();
    if( bNeedSave )
        SetTimer(save_delay, True);
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

    if( dxr == None ) {
        info("dxr == None, doAutosave() not saving yet");
        SetTimer(1.0, True);
        return;
    }
    
    if( dxr.Player.dataLinkPlay != None ) {
        dxr.Player.dataLinkPlay.AbortDataLink();
        interruptedDL = dxr.Player.dataLinkPlay;
        dxr.Player.dataLinkPlay = None;
    }

    //copied from DeusExPlayer QuickSave()
    if (
        (dxr.dxInfo == None) || (dxr.dxInfo.MissionNumber < 0) || 
        ((dxr.Player.IsInState('Dying')) || (dxr.Player.IsInState('Paralyzed')) || (dxr.Player.IsInState('Interpolating'))) || 
        (dxr.Player.dataLinkPlay != None) || (dxr.Level.Netmode != NM_Standalone) || (dxr.Player.InConversation())
    ){
        info("doAutosave() not saving yet");
        SetTimer(1.0, True);
        return;
    }

    saveSlot = -1;
    saveName = "DXR " $ dxr.seed $ ": " $ dxr.dxInfo.MissionLocation;
    lastMission = dxr.flags.f.GetInt('Rando_lastmission');
    if( lastMission != 0 && dxr.dxInfo.MissionNumber != 0 && lastMission != dxr.dxInfo.MissionNumber ) {
        saveSlot = 0;
        saveName = "DXR " $ dxr.seed $ ", Mission " $ dxr.dxInfo.MissionNumber $ ": " $ dxr.dxInfo.MissionLocation;
    }
    dxr.flags.f.SetInt('Rando_lastmission', dxr.dxInfo.MissionNumber,, 999);

    bNeedSave = false;
    dxr.Player.SaveGame(saveSlot, saveName);
    if( interruptedDL != None ) {
        dxr.Player.dataLinkPlay = interruptedDL;
        if( interruptedDL.tag != 'dummydatalink' )
            dxr.Player.ResumeDataLinks();
    }

    SetTimer(0, False);
    info("doAutosave() completed, save_delay: "$save_delay);
}

defaultproperties
{
    save_delay=1.5
}
