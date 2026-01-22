class DXRHUDConWindowFirst injects HUDConWindowFirst;

//Duplicated, but changed the font used
function DisplayText(string text, Actor speakingActor)
{
    local TextWindow newText;
    local float txtWidth;
    local GC gc;

    newText = TextWindow(lowerConWindow.NewChild(Class'TextWindow'));
    newText.SetTextAlignments( HALIGN_Left, VALIGN_Center);
    newText.SetTextMargins(10, 5);
    newText.SetFont(Font'DXRFontMenuSmall_DS'); //DXRando: Changed to get rid of the shitty font
    newText.SetText(text);

    // Use a different color for the player's text
    if ( DeusExPlayer(speakingActor) != None )
        newText.SetTextColor(colConTextPlayer);
    else
        newText.SetTextColor(colText);

    lastTextWindow = newText;

    AskParentForReconfigure();
}

defaultproperties
{
     fontName=Font'DXRFontMenuHeaders_DS' //Swap out the garbage vanilla font with this better one
}
