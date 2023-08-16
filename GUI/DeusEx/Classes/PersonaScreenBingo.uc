class PersonaScreenBingo extends PersonaScreenBaseWindow;

const bingoWidth = 395;
const bingoHeight = 360;
const bingoStartX = 16;
const bingoStartY = 22;

var PersonaActionButtonWindow btnReset, btnBingoInfo;

var string ResetWindowHeader, ResetWindowText;
var string InfoWindowHeader, InfoWindowText;
var string bingoWikiUrl;

function CreateControls()
{
    local int x, y, progress, max;
    local string event, desc;
    local PlayerDataItem data;
    local int bActiveMission;

    Super.CreateControls();
    CreateTitleWindow(9,   5, "That's a Bingo!");

    data = class'PlayerDataItem'.static.GiveItem(#var(PlayerPawn)(player));

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            bActiveMission = data.GetBingoSpot(x, y, event, desc, progress, max);
            CreateBingoSpot(x, y, desc, progress, max, bActiveMission);
        }
    }

    btnReset = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnReset.SetButtonText("New Board");
    btnReset.SetWindowAlignments(HALIGN_Left, VALIGN_Top,10,385);

    btnBingoInfo = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnBingoInfo.SetButtonText("Bingo Info");
    btnBingoInfo.SetWindowAlignments(HALIGN_Right, VALIGN_Top,10,385);
}

// we can fit about 6 lines of text, about 14 characters wide
// probably want a new class instead of ButtonWindow, so we can turn the background into a progress bar, maybe a subclass of PersonaItemButton so the theming works correctly
function BingoTile CreateBingoSpot(int x, int y, string text, int progress, int max, int bActiveMission)
{
    local BingoTile t;
    local int w, h;
    t = BingoTile(winClient.NewChild(class'BingoTile'));
    t.SetText(text);
    t.SetWordWrap(true);
    t.SetTextAlignments(HALIGN_Center, VALIGN_Center);
    t.SetFont(Font'FontMenuSmall_DS');
    w = bingoWidth/5;
    h = bingoHeight/5;
    t.SetSize(w-1, h-1);
    t.SetPos(x * w + bingoStartX, y * h + bingoStartY);
    t.SetProgress(progress, max, bActiveMission);
    t.SetHelpText("This is my help message!"); //This will need to be populated per bingo goal
    return t;
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    local MenuUIMessageBoxWindow msgBox;
    local string action;

    msgBox = MenuUIMessageBoxWindow(msgBoxWindow);
    if (msgBox.winText.GetText()==ResetWindowText){
        if (buttonNumber==0){
            action = "reset";
        }
    } else if (msgBox.winText.GetText()==InfoWindowText){
        if (buttonNumber==0){
            action="wiki";
        }
    }

    // Destroy the msgbox!
	root.PopWindow();

    if (action=="reset"){
        ResetBingoBoard();
    } else if (action=="wiki"){
        player.ConsoleCommand("start "$bingoWikiUrl);
    }

	return True;
}

function bool ResetBingoBoard()
{
    local DXREvents e;

    foreach player.AllActors(class'DXREvents', e) { break; }
    if(e == None) return false;
    e.CreateBingoBoard();
    SaveSettings();
    root.InvokeUIScreen(class'PersonaScreenBingo');
    return true;
}

function ShowBingoGoalHelp( Window bingoTile )
{
    local BingoTile bt;
    local BingoHintMsgBox msgbox;

    bt=BingoTile(bingoTile);

    if(bt==None){
        //Don't know how we got here, but might as well check
        return;
    }
    msgbox = BingoHintMsgBox(root.PushWindow(class'BingoHintMsgBox',False));
    msgbox.SetTitle(bt.GetText());
    msgbox.SetMessageText(bt.GetHelpText());
    msgbox.SetNotifyWindow(Self);
}

function bool ButtonActivated( Window buttonPressed )
{
    local int val;

    if(buttonPressed == btnReset) {
        root.MessageBox(ResetWindowHeader,ResetWindowText,0,False,Self);

        return true;
    }
    else if(buttonPressed == btnBingoInfo) {
        root.MessageBox(InfoWindowHeader,InfoWindowText,0,False,Self);

        return true;
    }
    else if(BingoTile(buttonPressed)!=None){
        ShowBingoGoalHelp(buttonPressed);
        return true;
    }

    return Super.ButtonActivated(buttonPressed);
}

defaultproperties
{
     ClientWidth=426
     ClientHeight=407
     clientOffsetX=105
     clientOffsetY=17
     clientTextures(0)=Texture'DeusExUI.UserInterface.LogsBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.LogsBackground_2'
     clientTextures(2)=Texture'DeusExUI.UserInterface.LogsBackground_3'
     clientTextures(3)=Texture'DeusExUI.UserInterface.LogsBackground_4'
     clientBorderTextures(0)=Texture'DeusExUI.UserInterface.ConversationsBorder_1'
     clientBorderTextures(1)=Texture'DeusExUI.UserInterface.ConversationsBorder_2'
     clientBorderTextures(2)=Texture'DeusExUI.UserInterface.ConversationsBorder_3'
     clientBorderTextures(3)=Texture'DeusExUI.UserInterface.ConversationsBorder_4'
     clientBorderTextures(4)=Texture'DeusExUI.UserInterface.ConversationsBorder_5'
     clientBorderTextures(5)=Texture'DeusExUI.UserInterface.ConversationsBorder_6'
     clientTextureRows=2
     clientTextureCols=2
     clientBorderTextureRows=2
     clientBorderTextureCols=3
     ResetWindowHeader="Are you sure?"
     ResetWindowText="Are you sure you want to reset your board?  All bingo progress will be lost!"
     InfoWindowHeader="Open Wiki?"
     InfoWindowText="Would you like to open the DXRando Bingo Goal wiki page in your web browser?"
     bingoWikiUrl="https://github.com/Die4Ever/deus-ex-randomizer/wiki/Bingo-Goals"
}
