class RevRandoMenuMain extends RevMenuMain;

var float countdown;

/* TODO: DXRAutosave in Revision?
function UpdateButtonStatus()
{
    Super.UpdateButtonStatus();
    if( ! class'DXRAutosave'.static.AllowManualSaves(player) ) winButtons[1].SetSensitivity(False);
}
*/

function SetTitle(String newTitle)
{
    bTickEnabled = true;
    title = "REVISION RANDOMIZER " $ class'DXRFlags'.static.VersionString();
    winTitle.SetTitle( title );
    countdown = 0.5;
}

function Tick(float DeltaTime)
{
    local int i;
    local string l, r, letter;

    countdown -= DeltaTime;
    if( countdown > 0 ) return;

    countdown = Float(Rand(500)) / 2000.0 + 0.1;

    i = Rand(19);
    if(i >= 9) i++;//skip the space after REVISION

    l = Left(title, i);
    r = Mid(title, i+1);
    letter = Chr( Rand(26) + 65 );

    title = l $ letter $ r;

    winTitle.SetTitle( title );
}
