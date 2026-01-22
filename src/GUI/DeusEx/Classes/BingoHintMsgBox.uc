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
    winText.SetFont(Font'DXRFontMenuHeaders_DS');
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

function SetMode( int newMode )
{
    // Store away
    mbMode = newMode;

    // Now create buttons appropriately

    switch( mbMode )
    {
        case 0:         // MB_YesNo:
            btnNo  = winButtonBar.AddButton(btnLabelNo, HALIGN_Right);
            btnYes = winButtonBar.AddButton(btnLabelYes, HALIGN_Right);
            numButtons = 2;
            SetFocusWindow(btnYes);
            break;

        case 1:         // MB_OK:
            btnOK = winButtonBar.AddButton(btnLabelOK, HALIGN_Right);
            numButtons = 1;
            SetFocusWindow(btnOK);
            break;

        case 2:         // 3 buttons?
            btnOK  = winButtonBar.AddButton("Button 2", HALIGN_Right);
            btnYes = winButtonBar.AddButton("Button 1", HALIGN_Right);
            btnNo  = winButtonBar.AddButton("Button 0", HALIGN_Right);
            numButtons = 3;
            SetFocusWindow(btnNo);
    }

    // Tell the shadow which bitmap to use; DXRando: we don't actually use this number currently
    if (winShadow != None)
        MenuUIMessageBoxShadowWindow(winShadow).SetButtonCount(numButtons);
}

function SetButtonTexts(string b0, string b1, string b2)
{
    btnNo.SetButtonText(b0);
    btnYes.SetButtonText(b1);
    btnOK.SetButtonText(b2);
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
    switch( mbMode )
    {
        case 0:
        case 1:
            return Super.RawKeyPressed(key, iState, bRepeat);
    }

    return false;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	switch(mbMode)
    {
        case 0:
        case 1:
            return Super.VirtualKeyPressed(key, bRepeat);
    }

    /*switch( key )
    {
        case IK_Escape:
            PostResult(-1);
            return true;
    }*/

    return false;
}

function bool ButtonActivated( Window buttonPressed )
{
    switch(mbMode)
    {
        case 0:
        case 1:
            return Super.ButtonActivated(buttonPressed);
    }

    Super(MenuUIWindow).ButtonActivated(buttonPressed);

    switch( buttonPressed )
    {
        case btnNo:
            PostResult(0);
            return true;

        case btnYes:
            PostResult(1);
            return true;

        case btnOK:
            PostResult(2);
            return true;
    }

    return false;
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
