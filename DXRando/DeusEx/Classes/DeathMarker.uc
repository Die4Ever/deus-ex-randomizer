#ifdef hx
class DeathMarker extends HXDecoration;
#else
class DeathMarker extends DeusExDecoration;
#endif

// Sprite.
#exec Texture Import File=Textures\Corpse.pcx Name=S_Corpse Flags=2
// normally has Mips=Off for the editor, but probably not good for the game

var string playername, killerclass, killer, damagetype, map;
var int created;// we receive the age from the server and store the difference between that age and our local _SystemTime

function BeginPlay()
{
    // temporary code just for testing
    created = class'DataStorage'.static._SystemTime(Level);
}

function Frob(Actor Frobber, Inventory frobWith)
{
    local DeusExPlayer Player;
    local string age;
    local int secondsago;
    Player = DeusExPlayer(Frobber);
    if(Player == None) return;

    secondsago = class'DataStorage'.static._SystemTime(Level)-created;
    if(secondsago < 60*1.5)
        age = secondsago $ " seconds ago";
    else if(secondsago < 3600*1.5)
        age = class'DXRInfo'.static.FloatToString(secondsago/60.0, 1) $ " minutes ago";
    else if(secondsago < 86400*1.5)
        age = class'DXRInfo'.static.FloatToString(secondsago/3600.0, 1) $ " hours ago";
    else if(secondsago < 86400*9.9)
        age = class'DXRInfo'.static.FloatToString(secondsago/86400.0, 1) $ " days ago";
    else
        age = int(secondsago/86400.0) $ " days ago";

    age = "about " $ age;
    Player.ClientMessage(playername $ " was " $ damagetype $ " by " $ killer @ age $".");

    // disable highlighting for a few seconds just in case there's an item hiding behind us
    bHighlight = false;
    SetCollision(false, false, false);
    SetTimer(5, false);
}

function Timer()
{
    bHighlight=true;
    SetCollision(true, false, false);
}

simulated function Tick(float deltaTime)
{
    // do nothing
}

static function DeathMarker New(Actor a, vector loc, string playername, string killerclass, string killer, string damagetype, int age) {
    local int created, time;
    local DeathMarker dm;

    time = class'DataStorage'.static._SystemTime(a.Level);
    created = time - age;

    foreach a.RadiusActors(class'DeathMarker', dm, 0.1, loc) {
        if(dm.playername==playername && dm.killerclass==killerclass && dm.killer==killer && dm.damagetype==damagetype) {
            // give 5 minutes of leeway?
            if(dm.created - created < 300 && dm.created - created > -300)
                return dm;
        }
    }
    dm = a.Spawn(class'DeathMarker', a,, a.Location);
    dm.playername=playername;
    dm.killerclass=killerclass;
    dm.killer=killer;
    dm.damagetype=damagetype;
    dm.created = created;
    return dm;
}

defaultproperties
{
    bStatic=false
    bDecorative=True
    Texture=Texture'Engine.S_Corpse'
    bCollideActors=true
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bProjTarget=false
    Physics=PHYS_None
    DrawType=DT_Sprite
    bHighlight=true
    bInvincible=true
    bPushable=false
    itemName="Here lies Anon"
    playername="Anon"
    killerclass="PaulDenton"
    killer="Paul Denton"
    damagetype="exploded"
}
