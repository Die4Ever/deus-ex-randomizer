//=============================================================================
// DeusExLevelInfo
//=============================================================================
class DeusExLevelInfo extends Info
    native;
/* this refuses to work with the extends keyword, ucc make gives me the error
C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\DeusEx\Classes\DeusExLevelInfo.uc(4) : Error, DeusEx.DeusExLevelInfo's superclass must be Engine.Info, not DeusEx.DeusExLevelInfoBase
I'm guessing because of native bindings or something
*/

var() String				MapName;
var() String				MapAuthor;
var() localized String		MissionLocation;
var() int					missionNumber;  // barfy, lowercase "m" due to SHITTY UNREALSCRIPT NAME BUG!
var() Bool					bMultiPlayerMap;
var() class<MissionScript>	Script;
var() int					TrueNorth;
var() localized String		startupMessage[4];		// printed when the level starts
var() String				ConversationPackage;  // DEUS_EX STM -- added so SDK users will be able to use their own convos


function SpawnScript()
{
    local MissionScript scr;
    local DXRando dxr;
    local bool bFound;

    // check to see if this script has already been spawned
    if (Script != None)
    {
        bFound = False;
        foreach AllActors(class'MissionScript', scr)
            bFound = True;

        if (!bFound)
        {
            if (Spawn(Script) == None)
                log("DeusExLevelInfo - WARNING! - Could not spawn mission script '"$Script$"'");
            else
                log("DeusExLevelInfo - Spawned new mission script '"$Script$"'");
        }
        else
            log("DeusExLevelInfo - WARNING! - Already found mission script '"$Script$"'");
    }

    bFound = False;
    foreach AllActors(class'DXRando', dxr)
        bFound = True;
    
    if (!bFound) {
        dxr = Spawn(class'DXRando');
        dxr.SetdxInfo(Self);
    }
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    SpawnScript();
}

defaultproperties
{
     ConversationPackage="DeusExConversations"
     Texture=Texture'Engine.S_ZoneInfo'
     bAlwaysRelevant=True
}
