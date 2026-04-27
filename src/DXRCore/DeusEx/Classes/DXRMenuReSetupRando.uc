class DXRMenuReSetupRando extends DXRMenuSetupRando;

event InitWindow()
{
    Super.InitWindow();
    GetDxr();
    Init(GetDxr());
}

function DXRando GetDxr()
{
    if( dxr != None ) return dxr;
    dxr = class'DXRando'.default.dxr;
    flags = dxr.flags;
    return dxr;
}

// just in case, make sure DXR is never cleaned up
event DestroyWindow()
{
    dxr = None;
    Super.DestroyWindow();
}

function CancelScreen()
{
    dxr = None;
    Super.CancelScreen();
}

//If changing ranges in this menu, make sure to update any clamped ranges in DXRFlags ScoreFlags function to match
function BindControls(optional string action)
{
    local DXRFlags f;

    if(action=="BACK") return;

    f = GetFlags();
    CreateLabelRow("You may need to save/load or reach a new map for changes to take effect."$BR$"Be careful when changing these settings in the middle of a mission.");

    combatDifficulty = player.combatDifficulty;
    Super.BindControls(action);

    if(!CheckSafeMap()) {
        wnds[starting_locations].SetSensitivity(false);
        wnds[goals_rando].SetSensitivity(false);
    }

    if( action == "DONE" ) {
        if( ! #defined(hx||vmd) ) player.combatDifficulty = combatDifficulty;
        GetFlags().SaveFlags();
    }
    if( action != "" ) CancelScreen();
}

function EnumListAddButton(DXREnumList list, string title, string val, string help, string prev)
{
    if(title == "Loadout") {
        class'DXRMenuSelectDifficulty'.static.LoadoutsGrouping(list, val, prev);
    }
    list.AddButton(val, help);
}

function bool CheckSafeMap()
{
    switch(GetDxr().dxInfo.missionNumber) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        //case 6: DTS and Gordon are cross-map goals
        //case 8: the 3 people are cross-map goals
        case 9:
        //case 10: // Nicolette and Jaime are cross-map goals
        case 11:
        //case 12: // Jock&Tong have complicated code handling re-entry
        case 14:
        case 15:
            return true;
    }

    return false;
}

defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel,Text="|&Back",Key="BACK")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Done",Key="DONE")
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_None,Text="",Key="")
    showMode=False
}
