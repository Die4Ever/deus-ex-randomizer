class HUDInfoLinKDisplay injects HUDInfoLinKDisplay;

function CreateControls()
{
    Super.CreateControls();

    // we can make this instant by setting it to 0
    // but the text doesn't always fit the window and instant scrolling is bad
    // default is 0.03, must match DataLinkPlay perCharDelay
    winText.SetTextTiming(class'DataLinkPlay'.default.perCharDelay);
}
