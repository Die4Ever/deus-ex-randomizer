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

event ParentRequestedPreferredSize(bool bWidthSpecified, out float preferredWidth,
                                   bool bHeightSpecified, out float preferredHeight)
{
    local float w,h,height;

    preferredWidth=columnWidth;

    height=0;
    winTitle.QueryPreferredSize(w,h);
    height+=h;
    winText.QueryPreferredSize(w,h);
    height+=h;
}

function SetTextAlignment(EHAlign newHAlign, EVAlign newVAlign)
{
    winTitle.SetTextAlignments(newHAlign,newVAlign);
    winText.SetTextAlignments(newHAlign,newVAlign);
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
     fontHeader=Font'DXRFontConversationLargeBold'
     fontText=Font'DXRFontConversationLarge'
     colHeader=(R=255,G=255,B=255)
     colText=(R=200,G=200,B=200)
}
