class PersonaScreenBingo extends PersonaScreenBaseWindow;

const bingoWidth = 394;
const bingoHeight = 361;

function CreateControls()
{
    local int x, y, progress, max;
    local string event, desc;
    local PlayerDataItem data;
    Super.CreateControls();
    CreateTitleWindow(9,   5, "That's a Bingo!");

    data = class'PlayerDataItem'.static.GiveItem(#var PlayerPawn (player));

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            data.GetBingoSpot(x, y, event, desc, progress, max);
            CreateBingoSpot(x, y, desc $ "|n" $ progress $ "/" $ max);
        }
    }
}

// we can fit about 6 lines of text, about 14 characters wide
// probably want a new class instead of ButtonWindow, so we can turn the background into a progress bar, maybe a subclass of PersonaItemButton so the theming works correctly
function TextWindow CreateBingoSpot(int x, int y, string text)
{
    local ButtonWindow t;
    local int w, h;
    t = ButtonWindow(winClient.NewChild(class'ButtonWindow'));
    t.SetText(text);
    t.SetWordWrap(true);
    t.SetTextAlignments(HALIGN_Center, VALIGN_Center);
    t.SetFont(Font'FontMenuSmall_DS');
    w = bingoWidth/5;
    h = bingoHeight/5;
    t.SetSize(w, h);
    t.SetPos(x * w + 16, y * h + 21);
    return t;
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
}
