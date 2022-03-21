#ifdef hx
class DeathMarker extends HXDecoration;
#else
class DeathMarker extends DeusExDecoration;
#endif

var string playername, killerclass, killer, damagetype, map;
// we receive the age from the server and store the difference between that age and our local _SystemTime
var int created, numtimes;

static function string DamageTypeText(string dmg) {
    if(dmg == "None" || dmg == "")
        return "killed";

    switch(dmg) {
        case "shot":
            return "murdered";
        case "TearGas":
            return "tear gassed to death";
        case "PoisonGas":
            return "poison gassed to death";
        case "Radiation":
            return "radiated to death";// ?
        case "HalonGas":
            return "gassed to death";// ?
        case "PoisonEffect":
        case "Poison":
            return "poisoned to death";
        case "Sabot":
        case "autoshot":
            return "filled with holes";
        case "Burned":
        case "Flamed":
            return "burned to death";
        case "Drowned":
            return "drowned to death";
        case "EMP":
        case "Shocked":
            return "shocked to death";
        case "Exploded":
            return "exploded to bits";
        case "stomped":
            return "asked to be stepped on";
        case "stunned":
            return "stunned";
        case "knockedout":
            return "knocked out";
    }
    log("WARNING: missing DamageTypeText for "$dmg);
    return "killed";
}

function string KilledByText() {
    if(killer == "" || killer == "None")
        return damagetype;
    return damagetype $ " by " $ killer;
}

function Frob(Actor Frobber, Inventory frobWith)
{
    local DeusExPlayer Player;
    local string age, msg;
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
    msg = playername $ " was " $ KilledByText() @ age;
    //if(numtimes > 1)
        //msg = msg $ " and "$(numtimes-1)$" times before that";
    msg = msg $ ".";
    Player.ClientMessage(msg);

    // disable highlighting for a few seconds just in case there's an item hiding behind us
    bHighlight = false;
    SetCollision(false, false, false);
    ScaleGlow = default.ScaleGlow / 3;
    SetTimer(5, false);
}

function Timer()
{
    bHighlight=true;
    SetCollision(true, false, false);
    ScaleGlow = default.ScaleGlow;
}

simulated function Tick(float deltaTime)
{
    // do nothing
}

static function DeathMarker New(Actor a, vector loc, string playername, string killerclass, string killer, string damagetype, int age, int numtimes) {
    local int created, time;
    local DeathMarker dm;

    time = class'DataStorage'.static._SystemTime(a.Level);
    created = time - age;
    damagetype = DamageTypeText(damagetype);

    foreach a.RadiusActors(class'DeathMarker', dm, 0.1, loc) {
        if(dm.playername==playername && dm.killerclass==killerclass && dm.killer==killer && dm.damagetype==damagetype) {
            // give 5 minutes of leeway?
            if(dm.created - created < 300 && dm.created - created > -300) {
                log(dm$" New reusing");
                dm.numtimes += numtimes;
                return dm;
            }
        }
    }
    dm = a.Spawn(class'DeathMarker',,, loc);
    log(dm$" New spawned");
    dm.playername=playername;
    dm.killerclass=killerclass;
    dm.killer=killer;
    dm.damagetype=damagetype;
    dm.created = created;
    dm.numtimes = numtimes;
    dm.itemName = "Here lies " $ playername $ "," $ Chr(10) $ dm.KilledByText() $ ".";
    return dm;
}

defaultproperties
{
    bStatic=false
    Texture=Texture'Engine.S_Corpse'
    CollisionRadius=16
    CollisionHeight=16
    bCollideActors=true
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bProjTarget=false
    Physics=PHYS_None
    DrawType=DT_Sprite
    Style=STY_Translucent
    ScaleGlow=0.3
    bNoSmooth=false
    bHighlight=true
    bInvincible=true
    bPushable=false
    itemName="Here lies Anon"
    playername="Anon"
    killerclass="PaulDenton"
    killer="Paul Denton"
    damagetype="exploded"
    numtimes=1
}
