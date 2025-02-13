class BingoHintMsgBox extends MenuUIMessageBoxWindow;

#exec TEXTURE IMPORT FILE="Textures\BingoHintBoxBackground_1.pcx"	NAME="BingoHintBoxBackground_1"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\BingoHintBoxBackground_2.pcx"	NAME="BingoHintBoxBackground_2"	GROUP="DXRandoUI" MIPS=Off

var PersonaScrollAreaWindow winScroll;

function CreateTextWindow()
{
    winScroll = PersonaScrollAreaWindow(winClient.NewChild(Class'PersonaScrollAreaWindow'));
    winText = MenuUIHeaderWindow(winScroll.ClipWindow.NewChild(Class'MenuUIHeaderWindow'));

    winScroll.SetPos(12, 13);
    winScroll.SetSize(490,95);

    winText.SetTextAlignments(HALIGN_Left, VALIGN_Center);
    winText.SetFont(Font'FontMenuHeaders_DS');
    winText.SetWindowAlignments(HALIGN_Full, VALIGN_Full, textBorderX, textBorderY);
}

static function BingoHintMsgBox Create
    (
    DeusExRootWindow root,
    String msgTitle,
    String msgText,
    int msgBoxMode,
    bool hideCurrentScreen,
    Window winParent
    )
{
    local BingoHintMsgBox msgbox;
    msgbox = BingoHintMsgBox(root.PushWindow(class'BingoHintMsgBox', hideCurrentScreen));
    msgbox.SetTitle(msgTitle);
    msgbox.SetMessageText(msgText);
    msgBox.SetMode(msgBoxMode);
    msgbox.SetNotifyWindow(winParent);
    return msgbox;
}

defaultproperties
{
     textBorderX=20
     textBorderY=14
     ClientWidth=514
     ClientHeight=126
     textureRows=1
     textureCols=2
     clientTextures(0)=Texture'BingoHintBoxBackground_1'
     clientTextures(1)=Texture'BingoHintBoxBackground_2'
     winShadowClass=Class'BingoHintMsgBoxShadowWindow'
}
