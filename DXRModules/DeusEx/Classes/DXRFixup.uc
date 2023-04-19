class DXRFixup expands DXRActorsBase transient;

struct DecorationsOverwrite {
    var string type;
    var bool bInvincible;
    var int HitPoints;
    var int minDamageThreshold;
    var bool bFlammable;
    var float Flammability; // how long does the object burn?
    var bool bExplosive;
    var int explosionDamage;
    var float explosionRadius;
    var bool bPushable;
};

var DecorationsOverwrite DecorationsOverwrites[16];
var class<DeusExDecoration> DecorationsOverwritesClasses[16];

struct AddDatacube {
    var string map;
    var string text;
    var vector location;// 0,0,0 for random
    // spawned in PreFirstEntry, so if you set a location then it will be moved according to the logic of DXRPasswords
};
var AddDatacube add_datacubes[32];

var int storedWeldCount;// ship weld points
var int storedReactorCount;// Area 51 goal

static function class<DXRBase> GetModuleToLoad(DXRando dxr, class<DXRBase> request)
{
    switch(dxr.dxInfo.missionNumber) {
    case 0:
        return class'DXRFixupM00';
    case 1:
        return class'DXRFixupM01';
    case 2:
        return class'DXRFixupM02';
    case 3:
        return class'DXRFixupM03';
    case 4:
        return class'DXRFixupM04';
    case 5:
        return class'DXRFixupM05';
    case 6:
        return class'DXRFixupM06';
    case 8:
        return class'DXRFixupM08';
    case 9:
        return class'DXRFixupM09';
    case 10:
    case 11:
        return class'DXRFixupParis';
    case 12:
    case 14:
        return class'DXRFixupVandenberg';
    case 15:
        return class'DXRFixupM15';
    }
    return request;
}

function CheckConfig()
{
    local int i;
    local class<DeusExDecoration> c;

    i=0;
    DecorationsOverwrites[i].type = "CrateUnbreakableLarge";
    DecorationsOverwrites[i].bInvincible = false;
    DecorationsOverwrites[i].HitPoints = 2000;
    DecorationsOverwrites[i].minDamageThreshold = 0;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;

    i++;
    DecorationsOverwrites[i].type = "BarrelFire";
    DecorationsOverwrites[i].bInvincible = false;
    DecorationsOverwrites[i].HitPoints = 50;
    DecorationsOverwrites[i].minDamageThreshold = 0;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;

    i++;
    DecorationsOverwrites[i].type = "Van";
    DecorationsOverwrites[i].bInvincible = false;
    DecorationsOverwrites[i].HitPoints = 500;
    DecorationsOverwrites[i].minDamageThreshold = 0;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;

    Super.CheckConfig();

    for(i=0; i<ArrayCount(DecorationsOverwrites); i++) {
        if( DecorationsOverwrites[i].type == "" ) continue;
        DecorationsOverwritesClasses[i] = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    }
    for(i=0; i<ArrayCount(add_datacubes); i++) {
        add_datacubes[i].map = Caps(add_datacubes[i].map);
    }
}

function PreFirstEntry()
{
    Super.PreFirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" PreFirstEntry()");

    SetSeed( "DXRFixup PreFirstEntry" );

    OverwriteDecorations();
    FixFlagTriggers();
    SpawnDatacubes();

    SetSeed( "DXRFixup PreFirstEntry missions" );
    if(#defined(mapfixes))
        PreFirstEntryMapFixes();
}

function PostFirstEntry()
{
    Super.PostFirstEntry();

    if(#defined(mapfixes)) {
        PostFirstEntryMapFixesBase();// so every module doesn't need to call Super all over the place
        PostFirstEntryMapFixes();
    }
}

function AnyEntry()
{
    local #var(prefix)Vehicles v;
    local #var(prefix)Button1 b;
    local #var(prefix)Teleporter t;
    Super.AnyEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" AnyEntry()");

    SetSeed( "DXRFixup AnyEntry" );

    FixSamCarter();
    SetSeed( "DXRFixup AnyEntry missions" );
    if(#defined(mapfixes))
        AnyEntryMapFixes();

    FixAmmoShurikenName();

    AllAnyEntry();

    foreach AllActors(class'#var(prefix)Button1', b) {
        if(b.CollisionRadius <3 && b.CollisionHeight <3)
            b.SetCollisionSize(3, 3);
    }
    foreach AllActors(class'#var(prefix)Vehicles', v) {
        if(#var(prefix)BlackHelicopter(v) == None && #var(prefix)AttackHelicopter(v) == None)
            continue;
        if(v.CollisionRadius > 360)
            v.SetCollisionSize(360, v.CollisionHeight);
    }
    foreach AllActors(class'#var(prefix)Teleporter', t) {
        t.bHidden = !(t.bCollideActors && t.bEnabled);
    }
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);
    if(#defined(vanillamaps))
        FixLogTimeout(p);

    FixAmmoShurikenName();
    FixInventory(p);
}

function PreTravel()
{
    Super.PreTravel();
    if(#defined(mapfixes)) {
        if(dxr == None) {
            warning("PreTravelMapFixes with dxr None");
            return;
        }
        PreTravelMapFixes();
    }
}

function Timer()
{
    Super.Timer();
    if( dxr == None ) return;

    if(#defined(mapfixes)) {
        TimerMapFixes();
    }
}

function PreTravelMapFixes()
{
}

function PreFirstEntryMapFixes()
{
}

function PostFirstEntryMapFixes()
{
}

final function PostFirstEntryMapFixesBase()
{
    local RetinalScanner r;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOHQ":
    case "03_NYC_UNATCOHQ":
    case "04_NYC_UNATCOHQ":
        foreach AllActors(class'RetinalScanner', r) {
            if( r.Event != 'retinal_msg_trigger' ) continue;
            r.bHackable = false;
            r.hackStrength = 0;
            r.msgUsed = "";
        }
        break;
    }
}

function AnyEntryMapFixes()
{
}

function AllAnyEntry()
{
    // for when mapfixes isn't defined, but currently it's defined for all mods even Revision
}

function TimerMapFixes()
{
}

function FixSamCarter()
{
    local SamCarter s;
    foreach AllActors(class'SamCarter', s) {
        RemoveFears(s);
    }
}

simulated function FixAmmoShurikenName()
{
    local AmmoShuriken a;

    class'AmmoShuriken'.default.ItemName = "Throwing Knives";
    class'AmmoShuriken'.default.ItemArticle = "some";
    class'AmmoShuriken'.default.beltDescription="THW KNIFE";
    foreach AllActors(class'AmmoShuriken', a) {
        a.ItemName = a.default.ItemName;
        a.ItemArticle = a.default.ItemArticle;
        a.beltDescription = a.default.beltDescription;
    }
}

simulated function FixLogTimeout(#var(PlayerPawn) p)
{
    if( p.GetLogTimeout() - 1 <3 ) {
        p.SetLogTimeout(10);
    }
}

simulated function FixInventory(#var(PlayerPawn) p)
{
    local Inventory item, nextItem;
    local DXRLoadouts loadouts;

    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));

    for(item=p.Inventory; item!=None; item=nextItem) {
        nextItem = item.Inventory;// save this in case we're deleting an item

        if(loadouts != None && loadouts.ban(p, item)) {
            item.Destroy();
            continue;
        }
        item.BecomeItem();
        item.SetLocation(p.Location);
        item.SetBase(p);
    }
}

function OverwriteDecorations()
{
    local DeusExDecoration d;
    local #var(prefix)Barrel1 b;
    local int i;
    foreach AllActors(class'DeusExDecoration', d) {
        if( d.IsA('CrateBreakableMedCombat') || d.IsA('CrateBreakableMedGeneral') || d.IsA('CrateBreakableMedMedical') ) {
            d.Mass = 35;
            d.HitPoints = 1;
        }
        for(i=0; i < ArrayCount(DecorationsOverwrites); i++) {
            if(DecorationsOverwritesClasses[i] == None) continue;
            if( d.IsA(DecorationsOverwritesClasses[i].name) == false ) continue;
            d.bInvincible = DecorationsOverwrites[i].bInvincible;
            d.HitPoints = DecorationsOverwrites[i].HitPoints;
            d.minDamageThreshold = DecorationsOverwrites[i].minDamageThreshold;
            d.bFlammable = DecorationsOverwrites[i].bFlammable;
            d.Flammability = DecorationsOverwrites[i].Flammability;
            d.bExplosive = DecorationsOverwrites[i].bExplosive;
            d.explosionDamage = DecorationsOverwrites[i].explosionDamage;
            d.explosionRadius = DecorationsOverwrites[i].explosionRadius;
            d.bPushable = DecorationsOverwrites[i].bPushable;
        }
    }

    // in DeusExDecoration is the Exploding state, it divides the damage into 5 separate ticks with gradualHurtSteps = 5;
    foreach AllActors(class'#var(prefix)Barrel1', b) {
        if( b.explosionDamage > 50 && b.explosionDamage < 400 ) {
            b.explosionDamage = 400;
        }
    }
}

function FixFlagTriggers()
{//the History Un-Eraser Button
    local FlagTrigger f;

    foreach AllActors(class'FlagTrigger', f) {
        if( f.bSetFlag && f.flagExpiration == -1 ) {
            f.flagExpiration = 999;
            log(f @ f.FlagName @ f.flagValue $" changed expiration from -1 to 999");
        }
    }
}

function SpawnDatacubes()
{
#ifdef injections
    local #var(prefix)DataCube dc;
#else
    local DXRInformationDevices dc;
#endif

    local vector loc;
    local int i;

    for(i=0; i<ArrayCount(add_datacubes); i++) {
        if( dxr.localURL != add_datacubes[i].map ) continue;

        loc = add_datacubes[i].location;
        if( loc.X == 0 && loc.Y == 0 && loc.Z == 0 )
            loc = GetRandomPosition();

#ifdef injections
        dc = Spawn(class'#var(prefix)DataCube',,, loc, rot(0,0,0));
#else
        dc = Spawn(class'DXRInformationDevices',,, loc, rot(0,0,0));
#endif

        if( dc != None ){
             dc.plaintext = add_datacubes[i].text;
             l("add_datacubes spawned "$dc @ dc.plaintext @ loc);
        }
        else warning("failed to spawn datacube at "$loc$", text: "$add_datacubes[i].text);
    }
}

function UpdateGoalWithRandoInfo(name goalName)
{
    local string goalText;
    local DeusExGoal goal;
    local int randoPos;
    goal = player().FindGoal(goalName);
    if (goal!=None){
        goalText = goal.text;
        randoPos = InStr(goalText,"Rando: ");

        if (randoPos==-1){
            switch(goalName){
                case 'InvestigateMaggieChow':
                    goalText = goalText$"|nRando: The sword may not be in Maggie's apartment, instead there will be a Datacube with a hint.";
                    break;
                case 'FindHarleyFilben':
                    if(dxr.flags.settings.goals > 0)
                        goalText = goalText$"|nRando: Harley could be anywhere in Hell's Kitchen";
                    break;
                case 'FindNicolette':
                    if(dxr.flags.settings.goals > 0)
                        goalText = goalText$"|nRando: Nicolette could be anywhere in the city";
                    break;
            }
            goal.SetText(goalText);
            player().ClientMessage("Goal Updated - Check DataVault For Details",, true);
        }
    }
}

function AddDelay(Actor trigger, float time)
{
    local Dispatcher d;
    local name tagname;
    tagname = StringToName( "dxr_delay_" $ trigger.Event );
    d = Spawn(class'Dispatcher', trigger, tagname);
    d.OutEvents[0] = trigger.Event;
    d.OutDelays[0] = time;
    trigger.Event = d.Tag;
}

static function DeleteConversationFlag(Conversation c, name Name, bool Value)
{
    local ConFlagRef f, prev;
    if( c == None ) return;
    for(f = c.flagRefList; f!=None; f=f.nextFlagRef) {
        if( f.flagName == Name && f.value == Value ) {
            if( prev == None )
                c.flagRefList = f.nextFlagRef;
            else
                prev.nextFlagRef = f.nextFlagRef;
            return;
        }
        prev = f;
    }
}

static function FixConversationFlag(Conversation c, name fromName, bool fromValue, name toName, bool toValue)
{
    local ConFlagRef f;
    if( c == None ) return;
    for(f = c.flagRefList; f!=None; f=f.nextFlagRef) {
        if( f.flagName == fromName && f.value == fromValue ) {
            f.flagName = toName;
            f.value = toValue;
            return;
        }
    }
}

static function ConEventCheckFlag FixConversationFlagJump(Conversation c, name fromName, bool fromValue, name toName, bool toValue)
{
    local ConEvent e;
    local ConEventCheckFlag ef, matched;
    local ConFlagRef f;
    if( c == None ) return None;
    for(e = c.eventList; e!=None; e=e.nextEvent) {
        ef = ConEventCheckFlag(e);
        if( ef != None ) {
            for(f = ef.flagRef; f!=None; f=f.nextFlagRef) {
                if( f.flagName == fromName && f.value == fromValue ) {
                    f.flagName = toName;
                    f.value = toValue;
                    matched = ef;
                }
            }
        }
    }

    return matched;
}

static function FixConversationGiveItem(Conversation c, string fromName, Class<Inventory> fromClass, Class<Inventory> to)
{
    local ConEvent e;
    local ConEventTransferObject t;
    if( c == None ) return;
    for(e=c.eventList; e!=None; e=e.nextEvent) {
        t = ConEventTransferObject(e);
        if( t == None ) continue;
        if( t.objectName == fromName && t.giveObject == fromClass ) {
            t.objectName = string(to.name);
            t.giveObject = to;
        }
    }
}

static function FixConversationAddNote(Conversation c, string textSnippet)
{
    local ConEvent e;
    local ConEventSpeech s;
    local ConEventAddNote n;
    if( c == None ) return;
    for(e=c.eventList; e!=None; e=e.nextEvent) {
        s = ConEventSpeech(e);
        if( s == None ) continue;
        if( InStr(s.conSpeech.speech,textSnippet)!=-1) {
            n = New class'ConEventAddNote';
            n.nextEvent = e.nextEvent;
            e.nextEvent = n;
            n.noteText = s.conSpeech.speech;

            n.conversation = c;
            n.eventType = ET_AddNote;
        }
    }
}

defaultproperties
{
}
