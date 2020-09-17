class DXRKillBobPage expands DXRBase;

var config string BobPageClass;
var config float minDistance;// minimum distance away from any Teleporter, or PlayerStart
var config string endgamemap;
var ScriptedPawn BobPage;

function CheckConfig()
{
    if( config_version < 4 ) {
        BobPageClass = "BobPage";
        minDistance = 5000;
        endgamemap = "99_Endgame4.dx";
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    local MapExit exit;
    local NavigationPoint p;
    //local NYPoliceBoat b;
    local int i ,slot, num;
    local string map;

    Super.FirstEntry();

    if( dxr.flags.gamemode != 3 ) return;

    dxr.SetSeed( dxr.seed + dxr.Crc(Class.Name) );

    map = class'DXRTestAllMaps'.static.PickRandomMap(dxr);
    //map = "01_NYC_UNATCOISLAND";
    l("Bob Page map " $ map);
    if( Caps(map) != Caps(dxr.localURL) )
        return;

    foreach AllActors(class'NavigationPoint', p) {
        if( IsGoodBossLocation(p.Location) == false ) continue;
        num++;
    }

    slot = rng(num);
    num = 0;
    foreach AllActors(class'NavigationPoint', p) {
        if( IsGoodBossLocation(p.Location) == false ) continue;
        if( num == slot ) {
            BobPage = Spawn( class<ScriptedPawn>(GetClassFromString(BobPageClass, class'ScriptedPawn')),,, p.Location );
            BobPage.bImportant = true;
            BobPage.BindName = "EndGameBoss";
            break;
        }
        num++;
    }

    SetTimer(1.0, true);
}

function AnyEntry()
{
    Super.AnyEntry();

    if( dxr.flags.gamemode != 3 ) return;
    
    switch(dxr.dxInfo.missionNumber) {
        case 1:
            LibertyIsland_OpenWorld();
            break;
        case 2:
            NYC1_OpenWorld();
            break;
        case 3:
            NYC2_OpenWorld();
            break;
    }
}

function Timer()
{
    Super.Timer();
    if( BobPage == None || BobPage.health <= 0 ) {
        dxr.player.ConsoleCommand("open " $ endgamemap);
    }
    /*if( dxr.flags.f.GetBool('EndGameBoss_Dead') ) {
        l("EndGameBoss_Dead BobPage == " $ BobPage);
        dxr.player.ConsoleCommand("open " $ endgamemap);
    }*/
}

function bool IsGoodBossLocation(vector loc)
{
    local float dist;
    local Teleporter t;
    local PlayerStart p;

    foreach AllActors(class'Teleporter', t) {
        dist = VSize( t.Location - loc );
        if( dist < minDistance ) return false;
    }

    foreach AllActors(class'PlayerStart', p) {
        dist = VSize( p.Location - loc );
        if( dist < minDistance ) return false;
    }

    return true;
}

function LibertyIsland_OpenWorld()
{
    switch (dxr.localURL)
    {
        case "01_NYC_UNATCOISLAND":
            dxr.flags.f.SetBool('M02Briefing_Played', True,, 999);
            break;
    }
}

function NYC1_OpenWorld()
{
    local BlackHelicopter h;
    switch (dxr.localURL)
    {
        case "02_NYC_WAREHOUSE":
            foreach AllActors(class'BlackHelicopter', h) {
                //h.bHidden = false;
                h.EnterWorld();
            }
            break;
    }
}

function NYC2_OpenWorld()
{
    local BlackHelicopter h;
    switch(dxr.localURL)
    {
        case "03_NYC_UNATCOISLAND":
            dxr.flags.f.SetBool('ManderleyDebriefing02_Played', True,, 999);
            break;
        case "03_NYC_AIRFIELD":
            foreach AllActors(class'BlackHelicopter', h)
                h.EnterWorld();
            break;
    }
}
