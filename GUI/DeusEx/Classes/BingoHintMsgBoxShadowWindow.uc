class BingoHintMsgBoxShadowWindow extends MenuUIMessageBoxShadowWindow;

#exec TEXTURE IMPORT FILE="Textures\BingoHintBoxShadow_1.pcx"	NAME="BingoHintBoxShadow_1"	GROUP="DXRandoUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\BingoHintBoxShadow_2.pcx"	NAME="BingoHintBoxShadow_2"	GROUP="DXRandoUI" MIPS=Off


event DrawWindow(GC gc)
{
	gc.SetStyle(DSTY_Modulated);
	gc.DrawTexture(0,   0, 256, shadowHeight, 0, 0, texShadows[0]);
	gc.DrawTexture(256, 0, 44, shadowHeight, 0, 0, texShadows[1]);
	gc.DrawTexture(300, 0, 256, shadowHeight, 0, 0, texShadows[1]);
}

defaultproperties
{
     texShadows(0)=Texture'BingoHintBoxShadow_1'
     texShadows(1)=Texture'BingoHintBoxShadow_2'
     shadowWidth=596
     shadowHeight=205
     shadowOffsetX=13
     shadowOffsetY=13
}
