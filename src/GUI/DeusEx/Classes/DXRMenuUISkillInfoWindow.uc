class DXRMenuUISkillInfoWindow injects MenuUISkillInfoWindow;

function CreateControls()
{
    Super.CreateControls();
    winSkillName.SetFont(Font'DXRFontMenuHeaders'); //Swap out the garbage vanilla font with this better one
    winSkillDescription.SetFont(Font'DXRFontMenuSmall'); //Swap out the garbage vanilla font with this better one
}
