class DXRKillBobPage expands DXRBase;

var config string BobPageClass;
var config float minDistance;// minimum distance away from any Teleporter, or PlayerStart
var config string endgamemap;
var ScriptedPawn BobPage;

function CheckConfig()
{
    if( config_version == 0 ) {
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
    local int i ,slot, num;
    local string map;
    Super.FirstEntry();

    dxr.SetSeed( dxr.seed + dxr.Crc(Class.Name) );

    map = class'DXRTestAllMaps'.static.PickRandomMap(dxr);
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

function Timer()
{
    Super.Timer();
    if( dxr.flags.f.GetBool('EndGameBoss_Dead') ) {
        dxr.player.ConsoleCommand("open " $ endgamemap);
    }
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
