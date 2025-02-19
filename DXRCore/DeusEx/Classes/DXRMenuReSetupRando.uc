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

//If changing ranges in this menu, make sure to update any clamped ranges in DXRFlags ScoreFlags function to match
function BindControls(optional string action)
{
    if(action=="BACK") return;

    //NewGroup("Test"); // TODO: clean way to replicate options from basic new game screen: loadout, autosave, crowd control, and mirrored maps

    Super.BindControls(action);

    if( action == "DONE" ) GetFlags().SaveFlags();
    if( action != "" ) CancelScreen();
}

defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel,Text="|&Back",Key="BACK")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Done",Key="DONE")
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_None,Text="",Key="")
}
