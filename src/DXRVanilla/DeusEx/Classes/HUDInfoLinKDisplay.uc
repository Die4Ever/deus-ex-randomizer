class HUDInfoLinKDisplay injects HUDInfoLinKDisplay;

function CreateControls()
{
    Super.CreateControls();

    // we can make this instant by setting it to 0
    // but the text doesn't always fit the window and instant scrolling is bad
    // default is 0.03, must match DataLinkPlay perCharDelay
    winText.SetTextTiming(class'DataLinkPlay'.default.perCharDelay / class'DXRMemes'.static.GetVoicePitch(Human(player).dxr));
}

defaultproperties
{
     FontName=Font'DXRFontMenuHeaders_DS'
     fontText=Font'DXRFontFixedWidthSmall_DS' //Swap out the garbage vanilla font with this better one
}
