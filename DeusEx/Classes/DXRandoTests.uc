class DXRandoTests extends DeusExGameInfo;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
    log(Self$" Login("$Portal$", "$Options$", "$Error$", "$SpawnClass$")");
    return Super.Login(Portal, Options, Error, SpawnClass);
}

function PostBeginPlay()
{
    local DXRando dxr;
    local PlayerPawn p;
    local string error, localURL;

    p = Login("", "?Name=Player?Class=DeusEx.JCDentonMale", error, class'JCDentonMale');
    p.Possess();
    log(Self$" PostBeginPlay Login got error: "$error$", player: "$p);

    foreach AllActors(class'DXRando', dxr) { break; }

    if( dxr.localURL != "12_VANDENBERG_TUNNELS" ) {
        log("DXRandoTests loading map 12_VANDENBERG_TUNNELS");
        Level.ServerTravel( "12_VANDENBERG_TUNNELS", False );
        return;
    }

    SetTimer(0.2, true);
}

function Timer()
{
    local DXRando dxr;
    
    foreach AllActors(class'DXRando', dxr) { break; }
    if( dxr.player == None ) dxr.Timer();

    dxr.ExtendedTests();
    SetTimer(0, false);
    ConsoleCommand("Exit");
}
