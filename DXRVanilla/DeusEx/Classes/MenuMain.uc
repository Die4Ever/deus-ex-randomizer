class MenuMain injects MenuMain;

var float countdown;

function UpdateButtonStatus()
{
    Super.UpdateButtonStatus();
    if( ! class'DXRAutosave'.static.AllowManualSaves(player) ) winButtons[1].SetSensitivity(False);
}

function SetTitle(String newTitle)
{
    bTickEnabled = true;
    title = "DEUS EX RANDOMIZER " $ class'DXRVersion'.static.VersionString();
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

    i = Rand(16);
    if(i >= 4) i++;//skip the space after DEUS
    if(i >= 7) i++;//skip the space after EX

    l = Left(title, i);
    r = Mid(title, i+1);
    letter = Chr( Rand(26) + 65 );

    title = l $ letter $ r;

    winTitle.SetTitle( title );
}
