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
    local DXRLoadouts loadout;
    local DXRTelemetry t;
    local DXRCrowdControl cc;
    local int temp, i;
    local string ts,tht;
#ifdef injections
    local bool mirrored_maps_files_found;
#endif

    if(action=="BACK") return;

    f = GetFlags();
    NewGroup("Basic");

    class'DXRMenuSelectDifficulty'.static.CreateLoadoutEnum(self, f);
    class'DXRMenuSelectDifficulty'.static.CreateAutosaveEnum(self, f);
    class'DXRMenuSelectDifficulty'.static.CreateCrowdControlEnum(self, f);
    class'DXRMenuSelectDifficulty'.static.CreateOnlineFeaturesEnum(self, f);
    class'DXRMenuSelectDifficulty'.static.CreateMirroredMapsSlider(self, f);

    Super.BindControls(action);

    if( action == "DONE" ) GetFlags().SaveFlags();
    if( action != "" ) CancelScreen();
}


function EnumListAddButton(DXREnumList list, string title, string val, string help, string prev)
{
    if(title == "Loadout") {
        class'DXRMenuSelectDifficulty'.static.LoadoutsGrouping(list, val, prev);
    }
    list.AddButton(val, help);
}


defaultproperties
{
    actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel,Text="|&Back",Key="BACK")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Done",Key="DONE")
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_None,Text="",Key="")
}
