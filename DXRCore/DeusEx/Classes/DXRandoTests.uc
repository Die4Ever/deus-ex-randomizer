#ifdef hx
class DXRandoTests extends HXRandoGameInfo;
#elseif vanilla
class DXRandoTests extends DeusExGameInfo;
#else
class DXRandoTests extends DXRandoGameInfo;
#endif

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
    log(Self$" Login("$Portal$", "$Options$", "$Error$", "$SpawnClass$")", Name);
    return Super.Login(Portal, Options, Error, SpawnClass);
}

function PostBeginPlay()
{
    local DXRando dxr;
    local PlayerPawn p;
    local string error, localURL;

#ifdef playersonly
    log("ERROR: can't run tests in playersonly mode!");
    ConsoleCommand("Exit");
#endif

    SetTimer(0, false);

    foreach AllActors(class'DXRando', dxr) { break; }

    if( dxr.localURL != "12_VANDENBERG_TUNNELS" ) {
        dxr.Destroy();
        log("TIME: DXRandoTests loading map 12_VANDENBERG_TUNNELS", Name);
        Level.ServerTravel( "12_VANDENBERG_TUNNELS", False );
        return;
    }

    log("TIME: DXRandoTests entered map 12_VANDENBERG_TUNNELS", Name);
    p = Login("", "?Name=Player?Class=DeusEx.JCDentonMale", error, class'JCDentonMale');
    p.Possess();
    log(Self$" PostBeginPlay Login got error: "$error$", player: "$p, Name);

    SetTimer(0.1, true);
}

function Timer()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando', dxr) { break; }
    if( dxr.bTickEnabled ) {
        log("waiting... dxr: " $ dxr $ ", dxr.bTickEnabled: " $ dxr.bTickEnabled );
        return;
    }
    if( dxr.flagbase == None ) {
        log("ERROR: still didn't find flagbase? dxr.bTickEnabled: "$dxr.bTickEnabled, Name);
        SetTimer(0, false);
        ConsoleCommand("Exit");
        return;
    }
    if( dxr.runPostFirstEntry ) {
        log("ERROR: dxr.runPostFirstEntry: " $ dxr.runPostFirstEntry);
    }

    dxr.ExtendedTests();
    SetTimer(0, false);
    ConsoleCommand("Exit");
}
