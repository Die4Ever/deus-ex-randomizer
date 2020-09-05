class DXRKillBobPage expands DXRBase;

var config class<ScriptedPawn> BobPageClass;
var config float minDistance;// minimum distance away from any Teleporter with a tag, or PlayerStart
var ScriptedPawn BobPage;

function CheckConfig()
{
    if( config_version == 0 ) {
        BobPageClass = class'BobPage';
        minDistance = 1000;
    }
    Super.CheckConfig();
}

function FirstEntry()
{
    local PathNode p;
    local string maps[128];
    local int i, numMaps;
    Super.FirstEntry();

    class'DXRTestAllMaps'.static.GetAllMaps(maps);

    foreach AllActors(class'PathNode', p) {
        if(p.name == 'PathNode497') {
            BobPage = Spawn(BobPageClass,,, p.Location );
            break;
        }
    }
}
