class DXRPersonaScreenImages injects PersonaScreenImages;

var DXRPersonaActionButtonWindow btnGoalLocations;
var DXRPersonaActionButtonWindow btnShowSpoilers;
var PersonaButtonBarWindow    winGoalHintButtons;

var String GoalSpoilersText;
var String GoalLocationsText;
var string GoalSpoilerWindowHeader, GoalSpoilerWindowText;

var DXRDataVaultMapImageNote spoilerNotes[32];


event InitWindow()
{
	local int i;

    Super.InitWindow();

    for (i=0;i<ArrayCount(spoilerNotes);i++){
        spoilerNotes[i] = new(player) class'DXRDataVaultMapImageNote';
    }
}

event DestroyWindow()
{
	local int i;

    for (i=0;i<ArrayCount(spoilerNotes);i++){
        CriticalDelete(spoilerNotes[i]);
    }

    Super.DestroyWindow();
}

function CreateButtons()
{
    local PersonaButtonBarWindow winActionButtons;

    Super.CreateButtons();

    winGoalHintButtons = PersonaButtonBarWindow(winClient.NewChild(Class'PersonaButtonBarWindow'));
    winGoalHintButtons.SetPos(180, 422);
    winGoalHintButtons.SetWidth(195);
    winGoalHintButtons.FillAllSpace(False);

    btnShowSpoilers = DXRPersonaActionButtonWindow(winGoalHintButtons.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnShowSpoilers.SetButtonText(GoalSpoilersText);

    btnGoalLocations = DXRPersonaActionButtonWindow(winGoalHintButtons.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnGoalLocations.SetButtonText(GoalLocationsText);

    btnShowSpoilers.Show(False);
    btnGoalLocations.Show(False);
}

//Checkbox needs to be moved to the right
function CreateShowNotesCheckbox()
{
    chkShowNotes = PersonaCheckBoxWindow(winClient.NewChild(Class'PersonaCheckBoxWindow'));

    chkShowNotes.SetWindowAlignments(HALIGN_Right, VALIGN_Top, 133, 424);
    chkShowNotes.SetText(ShowNotesLabel);
    chkShowNotes.SetToggle(True);
}

function RemoveSpoilerNotes()
{
	local Window window;
	local Window nextWindow;

	window = winImage.GetTopChild();
	while( window != None )
	{
		nextWindow = window.GetLowerSibling();

		if (DXRPersonaImageGoalHintWindow(window) != None)
			window.Destroy();

		window = nextWindow;
	}
}

function AddGoalLocationNotes()
{
    local DataVaultImage image;
    local DXRMissions dxrMissions;
    local DXRPersonaImageGoalHintWindow editNote;
    local int numNotes,i;

	image = winImage.GetImage();

    if (player!=None){
        foreach player.AllActors(class'DXRMissions',dxrMissions) break;
    }
    RemoveSpoilerNotes();
    if (dxrMissions!=None && dxrMissions.dxr.flags.settings.goals > 0){
        numNotes=dxrMissions.PopulateMapMarkerNotes(image.class,spoilerNotes);
    }

    for (i=0;i<numNotes;i++){
        editNote = DXRPersonaImageGoalHintWindow(winImage.NewChild(Class'DXRPersonaImageGoalHintWindow'));
        editNote.SetNote(spoilerNotes[i]);
        editNote.EnableEditing(False);
		editNote.Show();
    }
}

function AddSpoilerNotes()
{
    local DataVaultImage image;
    local DXRMissions dxrMissions;
    local DXRPersonaImageGoalHintWindow editNote;
    local int numNotes,i;

	image = winImage.GetImage();

    if (player!=None){
        foreach player.AllActors(class'DXRMissions',dxrMissions) break;
    }
    RemoveSpoilerNotes();
    if (dxrMissions!=None && dxrMissions.dxr.flags.settings.goals > 0){
        numNotes=dxrMissions.PopulateMapMarkerSpoilers(image.class,spoilerNotes);
    }

    for (i=0;i<numNotes;i++){
        editNote = DXRPersonaImageGoalHintWindow(winImage.NewChild(Class'DXRPersonaImageGoalHintWindow'));
        editNote.SetNote(spoilerNotes[i]);
        editNote.EnableEditing(False);
        editNote.Show();
    }
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    local MenuUIMessageBoxWindow msgBox;
    local bool bHandled;

    bHandled=False;

    msgBox = MenuUIMessageBoxWindow(msgBoxWindow);
    switch(msgBox.winText.GetText()) {
    case GoalSpoilerWindowText:
        bHandled=True;
        if (buttonNumber==0){
            class'DXRStats'.static.AddSpoilerOffense(player, 3);
            AddSpoilerNotes();
        }
        break;
    }

    if (bHandled){
        root.PopWindow();
        return true;
    }

    return Super.BoxOptionSelected(msgBoxWindow,buttonNumber);
}

function bool ButtonActivated( Window buttonPressed )
{
    local bool bHandled;

    bHandled = True;

    switch(buttonPressed)
    {
        case btnShowSpoilers:
            root.MessageBox(GoalSpoilerWindowHeader,GoalSpoilerWindowText,0,False,Self);
            break;

        case btnGoalLocations:
            AddGoalLocationNotes();
            break;

        default:
            bHandled = False;
            break;
    }

    if ( !bHandled )
        bHandled = Super.ButtonActivated(buttonPressed);

    return bHandled;
}

function EnableButtons()
{
    local DataVaultImage image;
    local DXRMissions dxrMissions;

    image = winImage.GetImage();

    if (player!=None){
        foreach player.AllActors(class'DXRMissions',dxrMissions) break;
    }

    btnShowSpoilers.Show(False);
    btnGoalLocations.Show(False);

    //Check if image has hint information available from DXRMissions
    if (dxrMissions!=None && dxrMissions.dxr.flags.settings.goals > 0){
        if (dxrMissions.MapHasGoalMarkers(image.class)){
            if (dxrMissions.dxr.flags.settings.spoilers==1){
                btnShowSpoilers.Show(True);
            }
            btnGoalLocations.Show(True);
        }
    }

    Super.EnableButtons();
}

function ClearViewedImageFlags()
{
    local DataVaultImage image;
    local int listIndex;
    local int rowId;

    for(listIndex=0; listIndex<lstImages.GetNumRows(); listIndex++)
    {
        rowId = lstImages.IndexToRowId(listIndex);

        if (lstImages.GetFieldValue(rowId, 2) > 0)
        {
            image = DataVaultImage(lstImages.GetRowClientObject(rowId));
            MarkViewed(image);
        }
    }
}

function MarkViewed(DataVaultImage newImage)
{
    local string bingoName;
    local DXRando dxr;

    if (newImage!=None && newImage.bPlayerViewedImage==False){
        bingoName = newImage.imageDescription;
        bingoName = class'DXRInfo'.static.ReplaceText(bingoName," ","");
        bingoName = class'DXRInfo'.static.ReplaceText(bingoName,"-","");
        bingoName = class'DXRInfo'.static.ReplaceText(bingoName,":","");
        bingoName = class'DXRInfo'.static.ReplaceText(bingoName,",","");
        bingoName = "ImageOpened_"$bingoName;

        foreach newImage.AllActors(class'DXRando', dxr) {
            class'DXREvents'.static.MarkBingo(dxr,bingoName);
        }

        newImage.bPlayerViewedImage = True;
    }
}

function SetImage(DataVaultImage newImage)
{
    class'#var(injectsprefix)DataVaultImage'.static.UpdateDataVaultImageTextures(newImage);
    Super.SetImage(newImage);
}


defaultproperties
{
     GoalSpoilersText="Goal S|&poilers"
     GoalLocationsText="Goal Loca|&tions"
     GoalSpoilerWindowHeader="Spoilers?"
     GoalSpoilerWindowText="Do you want to see spoilers for the goal randomization? This will impact your score! Click Goal Locations instead if you don't want to hurt your score."
}
