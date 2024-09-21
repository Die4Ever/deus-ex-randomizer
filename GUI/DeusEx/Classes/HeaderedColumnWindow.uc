class HeaderedColumnWindow extends Window;

var TextWindow   winTitle;
var TextWindow   winText;
var Font         fontHeader;
var Font         fontText;
var Color        colHeader;
var Color        colText;
var float        columnWidth;


event InitWindow()
{
    Super.InitWindow();

    winTitle = TextWindow(NewChild(Class'TextWindow'));
    winTitle.SetFont(fontHeader);
    winTitle.SetTextColor(colHeader);
    winTitle.SetTextAlignments(HALIGN_Center, VALIGN_Top);
    winTitle.SetTextMargins(0, 0);
    winTitle.SetPos(0,0);

    winText = TextWindow(NewChild(Class'TextWindow'));
    winText.SetFont(fontText);
    winText.SetTextColor(colText);
    winText.SetTextAlignments(HALIGN_Center, VALIGN_Top);
    winText.SetTextMargins(0, 0);
    winText.SetPos(0,24);
}

function SetColumnWidth(float newWidth)
{
    SetWidth(newWidth);
    winTitle.SetWidth(newWidth);
    winText.SetWidth(newWidth);
    columnWidth=newWidth;
    ResizeWindow();
}

function SetTitle(String newTitle)
{
    winTitle.SetText(newTitle);
    ResizeWindow();
}

function SetText(String newText)
{
    winText.SetText(newText);
    ResizeWindow();
}

function ResizeWindow()
{
    local float width,titleHeight,textHeight;

    winTitle.QueryPreferredSize(width,titleHeight);
    winText.QueryPreferredSize(width,textHeight);
    SetSize(columnWidth,titleHeight+textHeight);
}

defaultproperties
{
     fontHeader=Font'DeusExUI.FontConversationLargeBold'
     fontText=Font'DeusExUI.FontConversationLarge'
     colHeader=(R=255,G=255,B=255)
     colText=(R=200,G=200,B=200)
}
