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
    local DXRFlags f;
    local DXRLoadouts loadout;
    local DXRTelemetry t;
    local DXRCrowdControl cc;
    local int temp, i;
    local string ts;
#ifdef injections
    local DXRAutosave autosave;
    local bool mirrored_maps_files_found;
#endif

    if(action=="BACK") return;

    f = GetFlags();
    NewGroup("Basic");

    // KEEP IN SYNC WITH DXRMenuSelectDifficulty.uc
    NewMenuItem("Loadout", "Which items and augs you start with and which are banned.");
    foreach f.AllActors(class'DXRLoadouts', loadout) { break; }
    if( loadout == None )
        EnumOption("All Items Allowed", 0, f.loadout);
    else {
        for(i=0; i < 20; i++) {
            temp = loadout.GetIdForSlot(i);
            ts = loadout.GetName(temp);
            if( ts == "" ) continue;
            EnumOption(ts, temp, f.loadout);
        }
    }

#ifdef injections
    // KEEP IN SYNC WITH DXRMenuSelectDifficulty.uc
    foreach f.AllActors(class'DXRAutosave', autosave) { break; }// need an object to access consts
    NewMenuItem("Save Behavior", "Saves the game in case you die!");
    EnumOption("Autosave Every Entry", autosave.EveryEntry, f.autosave);
    EnumOption("Autosave First Entry", autosave.FirstEntry, f.autosave);
    EnumOption("Autosaves-Only (Hardcore)", autosave.Hardcore, f.autosave);
    EnumOption("Extra Safe (1+GB per playthrough)", autosave.ExtraSafe, f.autosave);
    EnumOption("Limited Saves", autosave.LimitedSaves, f.autosave);
    EnumOption("Limited Fixed Saves", autosave.FixedSaves, f.autosave);
    EnumOption("Unlimited Fixed Saves", autosave.UnlimitedFixedSaves, f.autosave);
    EnumOption("Extreme Limited Fixed Saves", autosave.FixedSavesExtreme, f.autosave);
    EnumOption("Autosaves Disabled", autosave.Disabled, f.autosave);
#endif

    // KEEP IN SYNC WITH DXRMenuSelectDifficulty.uc
    NewMenuItem("Crowd Control", "Let your Twitch/YouTube/Discord viewers troll you or help you!" $BR$ "See their website crowdcontrol.live");
    //EnumOption("Enabled (Anonymous)", 2, f.crowdcontrol);
    EnumOption("Enabled (Streaming)", 1, f.crowdcontrol);
    EnumOption("Offline Simulated", 3, f.crowdcontrol);
    EnumOption("Streaming and Simulated", 4, f.crowdcontrol);
    EnumOption("Disabled", 0, f.crowdcontrol);

    foreach f.AllActors(class'DXRTelemetry', t) { break; }
    if( t == None ) t = f.Spawn(class'DXRTelemetry');
    t.CheckConfig();
    if(t.enabled && t.death_markers)
        temp = 2;
    else if(t.enabled)
        temp = 1;
    else
        temp = 0;
    NewMenuItem("Online Features", "Death Markers, send error reports,"$BR$" and get notified about updates!");
    if( EnumOption("All Enabled", 2, temp) ) {
        t.set_enabled(true, true);
    }
    if( EnumOption("Enabled, Death Markers Hidden", 1, temp) ) {
        t.set_enabled(true, false);
    }
    if( EnumOption("Disabled", 0, temp) ) {
        t.set_enabled(false, true);
    }


#ifdef injections
    // KEEP IN SYNC WITH DXRMenuSelectDifficulty.uc
    mirrored_maps_files_found = class'DXRMapVariants'.static.MirrorMapsAvailable();

    if(mirrored_maps_files_found) {
        NewMenuItem("Mirrored Maps %", "Enable mirrored maps if you have the files downloaded for them.");
        if(f.mirroredmaps == -1 && f.IsZeroRando()) {
            f.mirroredmaps = 0; // default to 0% because of Zero Rando
        } else if(f.mirroredmaps == -1) {
            f.mirroredmaps = 50; // default to 50% when the files are installed
        }
        Slider(f.mirroredmaps, 0, 100);
    } else {
        // use -1 to indicate not installed, because this gets saved to the config
        f.mirroredmaps = -1;
        NewMenuItem("", "Use the installer to download the mirrored map files, or go to the unreal-map-flipper Releases page on Github");
        EnumOption("Mirror Map Files Not Found", -1, f.mirroredmaps);
    }
#endif

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
