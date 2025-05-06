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
    local bool femJC;

    Super.CreateControls();
    CreateTitleWindow(9,   5, "That's a Bingo!");

    data = class'PlayerDataItem'.static.GiveItem(#var(PlayerPawn)(player));
    femJC=player.flagbase.GetBool('LDDPJCIsFemale');

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            bActiveMission = data.GetBingoSpot(x, y, event, desc, progress, max);
            CreateBingoSpot(x, y, desc, progress, max, event, bActiveMission,data.GetBingoMissionMask(x,y),femJC);
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
function BingoTile CreateBingoSpot(int x, int y, string text, int progress, int max, string event, int bActiveMission, int missions, bool femJC)
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
    t.SetHelpText(event,player.GetLevelInfo().MissionNumber,femJC);
    t.SetMissions(missions);
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
    //} else if (msgBox.winText.GetText()==InfoWindowText){
    //    if (buttonNumber==0){
    //        action="wiki";
    //    }
    }

    // Destroy the msgbox!
	root.PopWindow();

    if (action=="reset"){
        ResetBingoBoard();
    } else if (action=="wiki"){
        class'DXRInfo'.static.OpenURL(player, bingoWikiUrl);
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

    bt=BingoTile(bingoTile);

    if(bt==None){
        //Don't know how we got here, but might as well check
        return;
    }

    class'BingoHintMsgBox'.static.Create(root, bt.GetText(), bt.GetHelpText(), 1, False, self);
    if(#defined(bingocheat)) {
        class'DXREvents'.static.MarkBingo(bt.event);
        bt.progress++;
    }
}

function string GetNextStartingMap(DXRando dxr)
{
    local int nextStartNum;
    local string nextStartName;
    local DXRStartMap m;

    if(dxr.flags.settings.starting_map == 0) return "";

    m = DXRStartMap(class'DXRStartMap'.static.Find());
    if(m == None) return "";
    dxr.seed++;
    nextStartNum = m.ChooseRandomStartMap(m, dxr.flags.settings.starting_map);
    dxr.seed--;
    nextStartName = m.GetStartingMapName(nextStartNum);
    return nextStartName;
}

function bool ButtonActivated( Window buttonPressed )
{
    local int nextStartNum, bingoWin, bingosCompleted,  bingoDuration, currentLoop;
    local string infoText, nextStartName, difficulty;
    local DXRando dxr;

    if(buttonPressed == btnReset) {
        root.MessageBox(ResetWindowHeader,ResetWindowText,0,False,Self);
        return true;
    }
    else if(buttonPressed == btnBingoInfo) {
        dxr = class'DXRando'.default.dxr;

        bingoWin = dxr.flags.settings.bingo_win;
        bingosCompleted = class'PlayerDataItem'.static.GiveItem(dxr.player).NumberOfBingos();
        bingoDuration = dxr.flags.bingo_duration;
        currentLoop = dxr.flags.newgameplus_loops;
        difficulty = class'DXRInfo'.static.FloatToString(dxr.player.CombatDifficulty, 3);

        nextStartName = GetNextStartingMap(dxr);

        infoText = InfoWindowText $ "|n";
        if (dxr.flags.IsBingoCampaignMode() && bingoWin > 0) {
            infoText = infoText $ "|nBingo Lines Required to Progress: " $ bingoWin;
        } else if (bingoWin > 0) {
            infoText = infoText $ "|nBingo Lines to Win: " $ bingoWin;
        }
        infoText = infoText $ "|nBingo Lines Completed: " $ bingosCompleted;
        infoText = infoText $ "|nBingo Duration: ";
        if (bingoDuration == 0) {
            infoText = infoText $ "End of the Game";
        } else {
            infoText = infoText $ bingoDuration $ " Mission";
            if (bingoDuration != 1) {
                infoText = infoText $ "s";
            }
        }
        infoText = infoText $ "|n|nNew Game Plus Loops Completed: " $ currentLoop;
        if(nextStartName != "") infoText = infoText $ "|nNext Loop Starting Map: " $ nextStartName;
        infoText = infoText $ "|n|nCombat Difficulty: " $ difficulty;

        class'BingoHintMsgBox'.static.Create(root, InfoWindowHeader, infoText, 1, False, self);

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
    InfoWindowHeader="Bingo Info"
    InfoWindowText="Complete specific tasks to mark off bingo squares!|n|nSquares marked gray can be completed this mission.  Black squares cannot be completed in this mission.  Green squares have been completed.  Red squares can no longer be completed.|n|nClick on the squares to get more info about the specific task for each one!"
    bingoWikiUrl="https://github.com/Die4Ever/deus-ex-randomizer/wiki/Bingo-Goals"
}
