class BingoHintMsgBox extends MenuUIMessageBoxWindow;

#exec TEXTURE IMPORT FILE="Textures\BingoHintBoxBackground_1.pcx"	NAME="BingoHintBoxBackground_1"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\BingoHintBoxBackground_2.pcx"	NAME="BingoHintBoxBackground_2"	GROUP="DXRandoUI" MIPS=Off


function SetMode( int newMode )
{
	// Now create button appropriately
	btnOK = winButtonBar.AddButton(btnLabelOK, HALIGN_Right);
	numButtons = 1;
	SetFocusWindow(btnOK);

	// Tell the shadow which bitmap to use
	if (winShadow != None)
		MenuUIMessageBoxShadowWindow(winShadow).SetButtonCount(numButtons);
}


function CreateTextWindow()
{
	winText = CreateMenuHeader(10, 13, "", winClient);
	winText.SetTextAlignments(HALIGN_Center, VALIGN_Center);
	winText.SetFont(Font'FontMenuHeaders_DS');
	winText.SetWindowAlignments(HALIGN_Full, VALIGN_Full, textBorderX, textBorderY);
}

defaultproperties
{
     textBorderX=8
     textBorderY=10
     ClientWidth=525
     ClientHeight=130
     textureRows=1
     textureCols=2
     clientTextures(0)=Texture'BingoHintBoxBackground_1'
     clientTextures(1)=Texture'BingoHintBoxBackground_2'
}
