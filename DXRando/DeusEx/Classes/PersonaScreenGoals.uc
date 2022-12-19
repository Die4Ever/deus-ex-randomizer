class DXRPersonaScreenGoals injects PersonaScreenGoals;

var PersonaActionButtonWindow btnBingo, btnGoalHints, btnEntranceLocs, btnEntranceSpoilers, btnGoalSpoilers;
//var PersonaCheckBoxWindow  chkShowSpoilers;
var string goalRandoWikiUrl;
var string InfoWindowHeader, InfoWindowText;
var string EntSpoilerWindowHeader, EntSpoilerWindowText;
var string GoalSpoilerWindowHeader, GoalSpoilerWindowText;
var String DisplaySpoilers;
var bool bDisplaySpoilers;

function CreateControls()
{
    local DXRando dxr;

    Super.CreateControls();

    btnBingo = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnBingo.SetButtonText("|&Bingo");
    btnBingo.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 13, 179);
    btnBingo.SetSensitivity(true);

    foreach player.AllActors(class'DXRando',dxr){
        if (dxr.flags.settings.goals > 0) {
            btnGoalHints = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
            btnGoalHints.SetButtonText("|&Goal Randomization Wiki");
            btnGoalHints.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 65, 179);
            btnGoalHints.SetSensitivity(true);

            //CreateShowSpoilersCheckbox();
            if (dxr.flags.settings.spoilers==1){
                CreateShowSpoilersButton(); //A button makes a confirmation window easier
            }

        }

        if (dxr.flags.gamemode==1){ //Entrance Rando
            btnEntranceLocs = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
            btnEntranceLocs.SetButtonText("Entrances");
            btnEntranceLocs.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 220, 411);
            btnEntranceLocs.SetSensitivity(true);

            if (dxr.flags.settings.spoilers==1){
                btnEntranceSpoilers = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
                btnEntranceSpoilers.SetButtonText("Entrance Spoilers");
                btnEntranceSpoilers.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 300, 411);
                btnEntranceSpoilers.SetSensitivity(true);
            }
        }
        break;
    }
}

/*
function CreateShowSpoilersCheckbox()
{
	chkShowSpoilers = PersonaCheckBoxWindow(winClient.NewChild(Class'PersonaCheckBoxWindow'));

	bDisplaySpoilers = False;

	chkShowSpoilers.SetText(DisplaySpoilers);
	chkShowSpoilers.SetToggle(bDisplaySpoilers);
	chkShowSpoilers.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 300, 180);
}
*/

function CreateShowSpoilersButton()
{
	bDisplaySpoilers = False;

    btnGoalSpoilers = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnGoalSpoilers.SetButtonText(DisplaySpoilers);
    btnGoalSpoilers.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 290, 179);
    btnGoalSpoilers.SetSensitivity(true);

}

function PopulateGoals()
{
    Super.PopulateGoals();

    if (bDisplaySpoilers){
        PopulateSpoilers();
    }
}

function PopulateSpoilers()
{
    local DXRMissions missions;
    local PersonaHeaderTextWindow spoilerHeader;
    local PersonaGoalItemWindow spoilerWindow;
    local int i;
    local string spoilName,spoilLoc;

    foreach player.AllActors(class'DXRMissions',missions){
        // Create Goals Header
	    spoilerHeader = PersonaHeaderTextWindow(winGoals.NewChild(Class'PersonaHeaderTextWindow'));
	    spoilerHeader.SetTextAlignments(HALIGN_Left, VALIGN_Center);
	    spoilerHeader.SetText("Spoilers");
        if (missions.num_goals==0){
            spoilerWindow = PersonaGoalItemWindow(winGoals.NewChild(Class'PersonaGoalItemWindow'));
			spoilerWindow.SetGoalProperties(True, False, "No possible goals in this map");
            break;
        }
        for(i=0;i<missions.num_goals;i++){
            spoilName = missions.GetSpoiler(i).goalName;
            spoilLoc = missions.GetSpoiler(i).goalLocation;
            spoilLoc = Caps(Left(spoilLoc,1))$Mid(spoilLoc,1);

            spoilerWindow = PersonaGoalItemWindow(winGoals.NewChild(Class'PersonaGoalItemWindow'));
			spoilerWindow.SetGoalProperties(True, False, spoilName $": "$spoilLoc);
        }

        break;
    }
}

/*
event bool ToggleChanged(Window button, bool bNewToggle)
{
    Super.ToggleChanged(button,bNewToggle);

    if (button == chkShowSpoilers)
	{
        //root.MessageBox(GoalSpoilerWindowHeader,GoalSpoilerWindowText,0,False,Self);
		bDisplaySpoilers = bNewToggle;
		PopulateGoals();
	}

	return True;
}
*/

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    local MenuUIMessageBoxWindow msgBox;
    local string action;

    msgBox = MenuUIMessageBoxWindow(msgBoxWindow);
    if (msgBox.winText.GetText()==InfoWindowText){
        if (buttonNumber==0){
            action="wiki";
        }
    } else if (msgBox.winText.GetText()==EntSpoilerWindowText){
        if (buttonNumber==0){
            action="entspoilers";
        }
    } else if (msgBox.winText.GetText()==GoalSpoilerWindowText){
        action="goalspoilers";
        bDisplaySpoilers=(buttonNumber==0);
    }

    if (action=="wiki"){
        player.ConsoleCommand("start "$goalRandoWikiUrl);
        // Destroy the msgbox!
	    root.PopWindow();
        return true;
    } else if (action=="entspoilers"){
        // Destroy the msgbox!
	    root.PopWindow();
        generateEntranceNote(True);
        return true;
    } else if (action=="goalspoilers"){
        // Destroy the msgbox!
	    root.PopWindow();
        PopulateGoals();
        return true;

    }

    return Super.BoxOptionSelected(msgBoxWindow,buttonNumber);
}

function Teleporter findOtherTeleporter(Teleporter nearThis){
    local Teleporter thing,nearestThing;

    foreach player.AllActors(class'Teleporter',thing) {
        if (thing==nearThis){
            continue;
        } else if (nearestThing==None){
            nearestThing = thing;
        } else {
            if ((VSize(nearThis.Location-thing.Location)) < (VSize(nearThis.Location-nearestThing.Location))){
                nearestThing = thing;
            }
        }
    }
    return nearestThing;
}


function generateEntranceNote(bool bSpoil)
{
#ifdef vanilla
	local DeusExNote newNote;
	local PersonaNotesEditWindow newNoteWindow;
    local String entranceList,source,dest;
    local DeusExLevelInfo dxLevel;
    local DXREntranceRando entRando;
    local int i;
    local bool found;

    if (bSpoil){
        entranceList="Entrance Rando Spoilers: ";
    } else {
        entranceList="Randomized Entrances: ";
    }

    foreach player.AllActors(class'DeusExLevelInfo',dxLevel){
        entranceList = entranceList $ dxLevel.MissionLocation $ " (Mission "$dxLevel.missionNumber$")";
        break;
    }

    entranceList = entranceList $ "|n--------------------------------------------------------";

    foreach player.AllActors(class'DXREntranceRando',entRando){
        entRando.LoadConns();
        player.ClientMessage("Found "$entRando.numConns$" connections in EntranceRando");
        for (i=0;i<entRando.numConns;i++){
            found=False;
            if (entRando.GetConnection(i).a.mapname==entRando.dxr.localURL){
                source = entRando.GetConnection(i).a.inTag;
                dest = entRando.GetConnection(i).b.mapname$" - "$entRando.GetConnection(i).b.inTag;
                found=True;
            }else if (entRando.GetConnection(i).b.mapname==entRando.dxr.localURL){
                source = entRando.GetConnection(i).b.inTag;
                dest = entRando.GetConnection(i).a.mapname$" - "$entRando.GetConnection(i).a.inTag;
                found=True;
            }

            if(found){
                entranceList=entranceList$"|n"$source$" -> ";
                if (bSpoil){
                    entranceList=entranceList$dest;
                }
            }
        }
        break;
    }

	// Create a new note and then a window to display it in
	newNote = player.AddNote(entranceList, True);

	newNoteWindow = CreateNoteEditWindow(newNote);
	newNoteWindow.Lower();
	SetFocusWindow(newNoteWindow);
#endif
}

function bool ButtonActivated( Window buttonPressed )
{
    if(buttonPressed == btnBingo) {
        SaveSettings();
        root.InvokeUIScreen(class'PersonaScreenBingo');
        return true;
    } else if(buttonPressed == btnGoalHints) {
        SaveSettings();
        root.MessageBox(InfoWindowHeader,InfoWindowText,0,False,Self);
        return true;
    } else if (buttonPressed == btnEntranceLocs) {
        generateEntranceNote(False);
        return true;
    } else if (buttonPressed == btnEntranceSpoilers) {
        root.MessageBox(EntSpoilerWindowHeader,EntSpoilerWindowText,0,False,Self);
        return true;
    } else if (buttonPressed == btnGoalSpoilers) {
        root.MessageBox(GoalSpoilerWindowHeader,GoalSpoilerWindowText,0,False,Self);
        return true;
    }
    return Super.ButtonActivated(buttonPressed);
}

defaultproperties
{
     InfoWindowHeader="Open Wiki?"
     InfoWindowText="Would you like to open the DXRando Goal Randomization wiki page in your web browser?"
     EntSpoilerWindowHeader="Spoilers?"
     EntSpoilerWindowText="Are you sure you want to see spoilers for the entrance randomization?"
     GoalSpoilerWindowHeader="Spoilers?"
     GoalSpoilerWindowText="Do you want to see spoilers for the goal randomization?"
     goalRandoWikiUrl="https://github.com/Die4Ever/deus-ex-randomizer/wiki/Goal-Randomization"
     DisplaySpoilers="Show Spoilers"
}
