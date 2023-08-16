class BingoHintMsgBox extends MenuUIMessageBoxWindow;

#exec TEXTURE IMPORT FILE="Textures\BingoHintBoxBackground_1.pcx"	NAME="BingoHintBoxBackground_1"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\BingoHintBoxBackground_2.pcx"	NAME="BingoHintBoxBackground_2"	GROUP="DXRandoUI" MIPS=Off

event InitWindow()
{
	Super.InitWindow();

	btnOK = winButtonBar.AddButton(btnLabelOK, HALIGN_Right);
	numButtons = 1;
	SetFocusWindow(btnOK);
}

function CreateTextWindow()
{
	winText = CreateMenuHeader(21, 13, "", winClient);
	winText.SetTextAlignments(HALIGN_Left, VALIGN_Center);
	winText.SetFont(Font'FontMenuHeaders_DS');
	winText.SetWindowAlignments(HALIGN_Full, VALIGN_Full, textBorderX, textBorderY);
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
