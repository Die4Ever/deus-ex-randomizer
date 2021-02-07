class MenuMain injects MenuMain;

var float countdown;

function SetTitle(String newTitle)
{
    bTickEnabled = true;
    title = "DEUS EX RANDOMIZER " $ class'DXRFlags'.static.VersionString();
    winTitle.SetTitle( title );
    countdown = 0.5;
}

function Tick(float DeltaTime)
{
    local DXRando dxr;
    local int i;
    local string l, r, letter;

    countdown -= DeltaTime;
    if( countdown > 0 ) return;

    foreach player.AllActors(class'DXRando', dxr) {
        break;
    }
    if( dxr == None ) {
        countdown = 0.1;
        return;
    }

    countdown = Float(dxr.rng(500)) / 2000.0 + 0.1;

    i = dxr.rng(16);
    if(i >= 4) i++;//skip the space after DEUS
    if(i >= 7) i++;//skip the space after EX

    l = Left(title, i);
    r = Mid(title, i+1);
    letter = Chr( dxr.rng(26) + 65 );

    title = l $ letter $ r;

	winTitle.SetTitle( title );
}
