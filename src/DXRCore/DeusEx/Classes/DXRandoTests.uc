class DXRandoTests extends #switch(hx: HXRandoGameInfo, vanilla: DeusExGameInfo, else: DXRandoGameInfo);

var transient int stage;

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

    class'MenuChoice_ShowBingoUpdates'.default.value = 0; // silence some bingo fail messages
    dxr = class'DXRando'.default.dxr;

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
    local Inventory inv;

    dxr = class'DXRando'.default.dxr;
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
    if(stage == 0) {
        dxr.ExtendedTests();
        stage++;
    }

    if(#bool(injections)) { // we only have a test save for vanilla currently, to make a test save use our ExitGameTrigger.uc
        if(stage == 1) {
            stage++;
            log("TIME: clearing items before loading savegame");
            foreach AllActors(class'Inventory', inv) inv.Destroy();
            log("TIME: loading savegame");
            Level.ServerTravel("?loadgame=1", False); // https://github.com/Die4Ever/unrealscript-injector/wiki/How-to-compile-Deus-Ex-Randomizer#automated-test-for-savegame-compatibility-optional
        } else if(stage<10) {
            log("TIME: waiting to load save...");
            stage++;
        } else {
            log("ERROR: failed to load save?");
            SetTimer(0, false);
            ConsoleCommand("Exit");
        }
    } else {
        SetTimer(0, false);
        ConsoleCommand("Exit");
    }
}
