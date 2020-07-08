class DXRando extends Info;

var transient DeusExPlayer Player;
var transient FlagBase flags;
var transient DeusExLevelInfo dxInfo;
var transient string localURL;
var transient DeusExNote lastCheckedNote;

var int newseed;

var string oldpasswords[128];
var string newpasswords[128];
var int passStart;
var int passEnd;

//rando flags
var int seed;
var int flagsversion;//if you load an old game with a newer version of the randomizer, we'll need to set defaults for new flags
var int brightness, minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
var int keysrando;//0=off, 1=dumb, 2=smart, 3=copies
var int doorspickable, doorsdestructible, deviceshackable, passwordsrandomized, gibsdropkeys;//could be bools, but int is more flexible, especially so I don't have to change the flag type

var transient private int CrcTable[256]; // for string hashing to do more stable seeding

function SetdxInfo(DeusExLevelInfo i)
{
    dxInfo = i;
    localURL = Caps(dxInfo.mapName);
    log("DXRando SetdxInfo got localURL: " $ localURL);
}

function PostPostBeginPlay()
{
    local name flagName;

    if( localURL == "DX" || localURL == "" ) {
        log("DXRando PostPostBeginPlay returning because localURL == " $ localURL);
        return;
    }

    log("DXRando PostPostBeginPlay has localURL == " $ localURL);
    Player = DeusExPlayer(GetPlayerPawn());
    if( Player == None ) {
        log("DXRando PostPostBeginPlay() didn't find player?");
        SetTimer(0.1, False);
        return;
    }
    log("DXRando found Player "$ActorToString(Player));
    flags = Player.FlagBase;
    CrcInit();
    LoadFlags();

    flagName = Player.rootWindow.StringToName("M"$localURL$"_Randomized");
    if (!flags.GetBool(flagName))
    {
        Rando();
        flags.SetBool(flagName, True);
    }
    RandoEnter();

    SetTimer(1.0, True);
}

function PreTravel()
{
    log("DXRando PreTravel()");
	// turn off the timer
	SetTimer(0, False);

    flags=None;
    Player=None;
}

function Timer()
{
    if( Player == None ) {
        PostPostBeginPlay();
        return;
    }
    if( flags.GetInt('Rando_version') == 0 ) {
        log("DXRando flags got deleted, saving again");//the intro deletes all flags
        SaveFlags();
    }
    CheckNotes();
}

function LoadFlags()
{
    log("DXRando LoadFlags()");
    seed = flags.GetInt('Rando_seed');

    flagsversion = flags.GetInt('Rando_version');
    brightness = flags.GetInt('Rando_brightness');
    minskill = flags.GetInt('Rando_minskill');
    maxskill = flags.GetInt('Rando_maxskill');
    ammo = flags.GetInt('Rando_ammo');
    multitools = flags.GetInt('Rando_multitools');
    lockpicks = flags.GetInt('Rando_lockpicks');
    biocells = flags.GetInt('Rando_biocells');
    medkits = flags.GetInt('Rando_medkits');
    speedlevel = flags.GetInt('Rando_speedlevel');
    keysrando = flags.GetInt('Rando_keys');
    doorspickable = flags.GetInt('Rando_doorspickable');
    doorsdestructible = flags.GetInt('Rando_doorsdestructible');
    deviceshackable = flags.GetInt('Rando_deviceshackable');
    passwordsrandomized = flags.GetInt('Rando_passwordsrandomized');
    gibsdropkeys = flags.GetInt('Rando_gibsdropkeys');

    if(flagsversion < 1) {
        log("DXRando upgrading flags from v"$flagsversion);
        brightness = 5;
        minskill = 25;
        maxskill = 400;
        ammo = 80;
        multitools = 70;
        lockpicks = 70;
        biocells = 80;
        speedlevel = 1;
        keysrando = 2;
        doorspickable = 100;
        doorsdestructible = 100;
        deviceshackable = 100;
        passwordsrandomized = 100;
        gibsdropkeys = 1;
    }
    if(flagsversion < 2) {
        medkits = 80;
        SaveFlags();
    }
}

function SaveFlags()
{
    log("DXRando SaveFlags()");
    InitVersion();
    flags.SetInt('Rando_seed', seed,, 999);

    flags.SetInt('Rando_version', flagsversion,, 999);
    flags.SetInt('Rando_brightness', brightness,, 999);
    flags.SetInt('Rando_minskill', minskill,, 999);
    flags.SetInt('Rando_maxskill', maxskill,, 999);
    flags.SetInt('Rando_ammo', ammo,, 999);
    flags.SetInt('Rando_multitools', multitools,, 999);
    flags.SetInt('Rando_lockpicks', lockpicks,, 999);
    flags.SetInt('Rando_biocells', biocells,, 999);
    flags.SetInt('Rando_medkits', medkits,, 999);
    flags.SetInt('Rando_speedlevel', speedlevel,, 999);
    flags.SetInt('Rando_keys', keysrando,, 999);
    flags.SetInt('Rando_doorspickable', doorspickable,, 999);
    flags.SetInt('Rando_doorsdestructible', doorsdestructible,, 999);
    flags.SetInt('Rando_deviceshackable', deviceshackable,, 999);
    flags.SetInt('Rando_passwordsrandomized', passwordsrandomized,, 999);
    flags.SetInt('Rando_gibsdropkeys', gibsdropkeys,, 999);
}

function InitVersion()
{
    flagsversion = 2;
}

function Rando()
{
    local ScriptedPawn p;
    local DeusExCarcass c;
    local Weapon inv;
    local Augmentation anAug;

    SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL) );

    log("DXRando randomizing "$localURL$" using seed " $ seed);

    if( Level.AmbientBrightness<150 ) Level.AmbientBrightness += brightness;
    //if( Level.Brightness<150 ) Level.Brightness += brightness;//Level.Brightness is way more extreme than AmbientBrightness, maybe still useful though?

    if( localURL == "INTRO" || localURL == "ENDGAME1" || localURL == "ENDGAME2" || localURL == "ENDGAME3" || localURL == "ENDGAME4" || localURL == "00_TRAINING" )
    { // extra randomization in the intro for the lolz, ENDGAME4 doesn't have a DeusExLevelInfo object though, so it doesn't get randomized :(
        RandomizeIntro();
        return;
    }

    if( localURL == "01_NYC_UNATCOISLAND" && speedlevel>0 )
    {
        anAug = Player.AugmentationSystem.GivePlayerAugmentation(class'AugSpeed');
        anAug.CurrentLevel = min(speedlevel-1, anAug.MaxLevel);
    }

    MoveNanoKeys(keysrando);
    SwapAll('Inventory');
    SwapAll('Containers');

    RandomizeAugCannisters();
    ReduceAmmo( float(ammo)/100.0 );
    ReduceSpawns('Multitool', multitools);
    ReduceSpawns('Lockpick', lockpicks);
    ReduceSpawns('BioelectricCell', biocells);
    ReduceSpawns('MedKit', medkits);

    RandoPasswords(passwordsrandomized);

    log("DXRando done randomizing "$localURL);
}

function SwapAll(name classname)
{
    local Actor a, b;
    local int num, i, slot;

    SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL $ "SwapAll " $ classname) );
    num=0;
    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;
        num++;
    }

    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;

        i=0;
        slot=Rng(num-1);
        foreach AllActors(class'Actor', b )
        {
            if( SkipActor(b, classname) ) continue;

            if(i==slot) {
                Swap(a, b);
                break;
            }
            i++;
        }
    }
}

function vector AbsEach(vector v)
{// not a real thing in math? but it's convenient
    v.X = abs(v.X);
    v.Y = abs(v.Y);
    v.Z = abs(v.Z);
    return v;
}

function bool AnyGreater(vector a, vector b)
{
    return a.X > b.X || a.Y > b.Y || a.Z > b.Z;
}

function MoveNanoKeys(int mode)
{
    local Inventory a;
    local NanoKey k;
    local DeusExMover d;
    local int num, i, slot;
    local vector doorloc, distkey, distdoor;

    num=0;

    // 0=off, 1=dumb, 2=smart, 3=copies
    if( mode == 0 ) return;

    SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL $ "MoveNanoKeys") );

    foreach AllActors(class'NanoKey', k )
    {
        if ( SkipActorBase(k) ) continue;

        doorloc = vect(99999, 99999, 99999);
        foreach AllActors(class'DeusExMover', d)
        {
            if( d.KeyIDNeeded == k.KeyID ) {
                doorloc = d.Location;
                break;
            }
        }
        i=0;
        num=0;
        foreach AllActors(class'Inventory', a)
        {
            if( SkipActor(a, 'Inventory') ) continue;
            distkey = AbsEach(a.Location - k.Location);
            distdoor = AbsEach(a.Location - doorloc);
            if ( AnyGreater( distkey, distdoor ) ) continue;
            num++;
        }
        slot=Rng(num-1);
        i=0;
        foreach AllActors(class'Inventory', a)
        {
            if( SkipActor(a, 'Inventory') ) continue;
            distkey = AbsEach(a.Location - k.Location);
            distdoor = AbsEach(a.Location - doorloc);
            if ( AnyGreater( distkey, distdoor ) ) continue;

            if(i==slot) {
                log("DXRando swapping key "$k.KeyID$" (distdoor "$distdoor$", distkey "$distkey$") with "$a.Class);
                Swap(k, a);
                break;
            }
            i++;
        }
    }
}

function bool CarriedItem(Actor a)
{// I need to check Engine.Inventory.bCarriedItem
    return a.Owner != None && a.Owner.IsA('Pawn');
}

function bool SkipActorBase(Actor a)
{
    if( (a.Owner != None) || a.bStatic || a.bHidden || a.bMovable==False )
        return true;
    if( a.Base != None )
        return a.Base.IsA('ScriptedPawn');
    return false;
}

function bool SkipActor(Actor a, name classname)
{
    return SkipActorBase(a) || ( ! a.IsA(classname) ) || a.IsA('BarrelAmbrosia') || a.IsA('BarrelVirus') || a.IsA('NanoKey');
}

function Swap(Actor a, Actor b)
{
    local vector newloc;
    local rotator newrot;
    local bool asuccess, bsuccess;
    local EPhysics aphysics, bphysics;
    local Actor abase, bbase;
    local bool AbCollideActors, AbBlockActors, AbBlockPlayers, BbCollideActors, BbBlockActors, BbBlockPlayers;

    if( a == b ) return;

    log("DXRando swapping "$ActorToString(a)$" and "$ActorToString(b));

    // https://docs.unrealengine.com/udk/Two/ActorVariables.html#Advanced
    // native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
    AbCollideActors = a.bCollideActors;
    AbBlockActors = a.bBlockActors;
    AbBlockPlayers = a.bBlockPlayers;
    BbCollideActors = b.bCollideActors;
    BbBlockActors = b.bBlockActors;
    BbBlockPlayers = b.bBlockPlayers;
    a.SetCollision(false, false, false);
    b.SetCollision(false, false, false);

    newloc = b.Location + (a.CollisionHeight - b.CollisionHeight) * vect(0,0,1);
    newrot = b.Rotation;

    bsuccess = b.SetLocation(a.Location + (b.CollisionHeight - a.CollisionHeight) * vect(0,0,1) );
    b.SetRotation(a.Rotation);

    if( bsuccess == false )
        log("DXRando failed to move " $ ActorToString(b) $ " into location of " $ ActorToString(a) );

    asuccess = a.SetLocation(newloc);
    a.SetRotation(newrot);

    if( asuccess == false )
        log("DXRando failed to move " $ ActorToString(a) $ " into location of " $ ActorToString(b) );

    aphysics = a.Physics;
    bphysics = b.Physics;
    abase = a.Base;
    bbase = b.Base;

    if(asuccess)
    {
        a.SetPhysics(bphysics);
        if(abase != bbase) a.SetBase(bbase);
    }
    if(bsuccess)
    {
        b.SetPhysics(aphysics);
        if(abase != bbase) b.SetBase(abase);
    }

    a.SetCollision(AbCollideActors, AbBlockActors, AbBlockPlayers);
    b.SetCollision(BbCollideActors, BbBlockActors, BbBlockPlayers);
}

function RandomizeAugCannisters()
{
    local AugmentationCannister a;

    if( Player == None ) return;

    SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL $ "RandomizeAugCannisters") );

    foreach AllActors(class'AugmentationCannister', a)
    {
        a.AddAugs[0] = PickRandomAug();
        a.AddAugs[1] = a.AddAugs[0];
        while( a.AddAugs[1] == a.AddAugs[0] )
        {
            a.AddAugs[1] = PickRandomAug();
        }
    }
}

function Name PickRandomAug()
{
    local int slot;
    local int skipAugSpeed;
    local int numAugs;
    numAugs=21;
    if( speedlevel > 0 )
        skipAugSpeed=1;
    slot = Rng(numAugs-3-skipAugSpeed) + skipAugSpeed;// exclude the 3 or 4 augs you start with, 0 is AugSpeed
    if ( slot >= 11 ) slot++;// skip AugIFF
    if ( slot >= 12 ) slot++;// skip AugLight
    if (slot >= 18 ) slot++;// skip AugDatalink
    log("DXRando Picked Aug "$ slot $"/"$numAugs$" " $ Player.AugmentationSystem.augClasses[slot].Name);
    return Player.AugmentationSystem.augClasses[slot].Name;
}

function ReduceAmmo(float mult)
{
    local Weapon w;
    local Ammo a;

    log("DXRando ReduceAmmo "$mult);
    SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL $ "ReduceAmmo") );

    if( mult ~= 1 ) return;

    foreach AllActors(class'Weapon', w)
    {
        if( w.PickupAmmoCount > 0 )
            w.PickupAmmoCount = Clamp(float(w.PickupAmmoCount) * mult, 0, 99999);
    }

    foreach AllActors(class'Ammo', a)
    {
        if( a.AmmoAmount > 0 && ( ! CarriedItem(a) ) )
            a.AmmoAmount = Clamp(float(a.AmmoAmount) * mult, 0, 99999);
    }

    ReduceSpawnsInContainers('Ammo', int(mult*100.0) );
}

function ReduceSpawns(name classname, int percent)
{
    local Actor a;

    if( percent >= 100 ) return;

    SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL $ "ReduceSpawns " $ classname) );

    foreach AllActors(class'Actor', a)
    {
        //if( SkipActor(a, classname) ) continue;
        if( a == Player ) continue;
        if( a.Owner == Player ) continue;
        if( ! a.IsA(classname) ) continue;

        if( Rng(100) >= percent )
        {
	        DestroyActor( a );
        }
    }

    ReduceSpawnsInContainers(classname, percent);
}

function ReduceSpawnsInContainers(name classname, int percent)
{
    local Containers d;

    if( percent >= 100 ) return;

    SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL $ "ReduceSpawnsInContainers " $ classname) );

    foreach AllActors(class'Containers', d)
    {
        //log("DXRando found Decoration " $ d.Name $ " with Contents: " $ d.Contents $ ", looking for " $ classname);
        if( Rng(100) >= percent ) {
            if( ClassIsA( d.Contents, classname) ) d.Contents = d.Content2;
            if( ClassIsA( d.Contents, classname) ) d.Content2 = d.Content3;
            if( ClassIsA( d.Contents, classname) ) d.Content3 = None;
        }
    }
}

function bool ClassIsA(class<actor> class, name classname)
{
    // there must be a better way to do this...
    local actor a;
    local bool ret;
    if(class == None) return ret;

    //return class<classname>(class) != None;

    a = Spawn(class);
    ret = a.IsA(classname);
    a.Destroy();
    return ret;
}

function RandoPasswords(int mode)
{
    local Computers c;
    local Keypad k;
    local ATM a;
    local int i;

    if( mode == 0 ) return;

    foreach AllActors(class'Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            if (c.userList[i].password == "")
                continue;

            ChangeComputerPassword(c, i);
        }
    }

    foreach AllActors(class'Keypad', k)
    {
        ChangeKeypadPasscode(k);
    }

    foreach AllActors(class'ATM', a)
    {
        for (i=0; i<ArrayCount(a.userList); i++)
        {
            if(a.userList[i].PIN == "")
                continue;

            ChangeATMPIN(a, i);
        }
    }
}

function ChangeComputerPassword(Computers c, int i)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    oldpassword = c.userList[i].password;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            c.userList[i].password = newpasswords[j];
            return;
        }
    }
    newpassword = GeneratePassword(oldpassword);
    c.userList[i].password = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ChangeKeypadPasscode(Keypad k)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    oldpassword = k.validCode;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            k.validCode = newpasswords[j];
            return;
        }
    }

    newpassword = GeneratePasscode(oldpassword);
    k.validCode = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ChangeATMPIN(ATM a, int i)
{
    local string oldpassword;
    local string newpassword;
    local int j;

    oldpassword = a.userList[i].PIN;

    for (j=0; j<ArrayCount(oldpasswords); j++)
    {
        if( oldpassword == oldpasswords[j] ) {
            a.userList[i].PIN = newpasswords[j];
            return;
        }
    }
    newpassword = GeneratePasscode(oldpassword);
    a.userList[i].PIN = newpassword;
    ReplacePassword(oldpassword, newpassword);
}

function ReplacePassword(string oldpassword, string newpassword)
{ // do I even need passStart?
    local DeusExNote note;

    oldpasswords[passEnd] = oldpassword;
    newpasswords[passEnd] = newpassword;
    //log("DXRando replaced password " $ oldpassword $ " with " $ newpassword $ ", passEnd was " $ passEnd $", passStart was " $ passStart);
    passEnd = (passEnd+1) % ArrayCount(oldpasswords);
    if(passEnd == passStart) passStart = (passStart+1) % ArrayCount(oldpasswords);
    //Player.ClientMessage("replaced password " $ oldpassword $ " with " $ newpassword);
    log("DXRando replaced password " $ oldpassword $ " with " $ newpassword $ ", passEnd is " $ passEnd $", passStart is " $ passStart);

    note = Player.FirstNote;

	while( note != None )
	{
        if( InStr( Caps(note.text), Caps(oldpassword) ) != -1 )
        {
            UpdateNote(note, oldpassword, newpassword);
        }
		note = note.next;
	}
}

function CheckNotes()
{
    local DeusExNote note;
    local int i;

	note = Player.FirstNote;

    //log("DXRando CheckNotes(), passEnd is " $ passEnd $", passStart is " $ passStart);

	while( note != lastCheckedNote && note != None )
	{
        for (i=0; i<ArrayCount(oldpasswords); i++)
        {
            UpdateNote(note, oldpasswords[i], newpasswords[i]);
        }
		note = note.next;
	}
    lastCheckedNote = Player.FirstNote;
}

function UpdateNote(DeusExNote note, string oldpassword, string newpassword)
{
    if( oldpassword == "" ) return;
    if( note.text == "") return;
    if( InStr( Caps(note.text), Caps(oldpassword) ) == -1 ) return;

    Player.ClientMessage("Note updated");
    log("DXRando found note with password " $ oldpassword $ ", replacing with newpassword " $ newpassword);

    note.text = ReplaceText( note.text, oldpassword, newpassword );
}

function string GeneratePassword(string oldpassword)
{
    local string out;
    local int i;
    local int c;
    SetSeed( seed + Crc(oldpassword) );
    for(i=0; i<5; i++) {
        // 0-9 is 48-57, 97-122 is a-z
        c = Rng(36) + 48;
        if ( c > 57 ) c += 39;
        out = out $ Chr(c);
    }
    return out;
}

function string GeneratePasscode(string oldpasscode)
{
    SetSeed( seed + Crc(oldpasscode) );
    // a number from 1000 to 9999, easily avoids leading 0s
    return (Rng(8999) + 1000) $ "";
}

function RandomizeIntro()
{
    local Tree t;
    local DeusExMover m;
    local BreakableGlass g;

    foreach AllActors(class'Tree', t)
    { // exclude 80% of trees from the SwapAll by temporarily hiding them
        if( Rng(100) < 80 ) t.bHidden = true;
    }
    foreach AllActors(class'DeusExMover', m)
    {
        m.bHidden = true;
    }
    foreach AllActors(class'BreakableGlass', g)
    {
        g.bHidden = true;
    }
    SwapAll('Actor');
    foreach AllActors(class'Tree', t)
    {
        t.bHidden = false;
    }
    foreach AllActors(class'DeusExMover', m)
    {
        m.bHidden = false;
    }
    foreach AllActors(class'BreakableGlass', g)
    {
        g.bHidden = false;
    }
}

function RandoEnter()
{
    local DeusExMover d;
    local Terrorist t;
    local NanoKey key;
    local HackableDevices h;

    local Computers c;
    local int i;

    log("DXRando RandoEnter()");

    foreach AllActors(class'Computers', c)
    {
        for (i=0; i<ArrayCount(c.userList); i++)
        {
            if (c.userList[i].password == "")
                continue;

            log("DXRando RandoEnter found computer password: " $ c.userList[i].password);
        }
    }

    RandoSkills();

    foreach AllActors(class'DeusExMover', d)
    {
        if( (d.KeyIDNeeded$"") == "None" || d.bPickable || d.bBreakable ) continue;

        if( d.bPickable == false && doorspickable > 0 ) {
            d.bPickable = true;
            d.lockStrength = 1;
            d.initiallockStrength = 1;
        }
        if( d.bBreakable == false && doorsdestructible > 0 ) {
            d.bBreakable = true;
            d.minDamageThreshold = 50;
            d.doorStrength = 1;
        }
    }

    foreach AllActors(class'NanoKey', key)
    {
        log("DXRando found key class: " $ ActorToString(key) $ ", tag: " $ key.Tag $ ", KeyID: " $ key.KeyID $ " in " $ localURL);
    }

    foreach AllActors(class'HackableDevices', h)
    {
        if( h.bHackable == false && deviceshackable > 0 ) {
            log("DXRando found unhackable device class: " $ ActorToString(h) $ ", tag: " $ h.Tag $ " in " $ localURL);
            h.bHackable = true;
            h.hackStrength = 1;
            h.initialhackStrength = 1;
        }
    }
}

function RandoSkills()
{
    local Skill aSkill;
    local int i;
    local int percent;

    log("DXRando randomizing skills with seed " $ seed);
    SetSeed(seed);

    if( minskill > maxskill ) maxskill = minskill;

    aSkill = Player.SkillSystem.FirstSkill;
	while(aSkill != None)
	{
        percent = Rng(maxskill - minskill) + minskill;
        log("DXRando RandoSkills percent: "$percent$", min: "$minskill$", max: "$maxskill);
        for(i=0; i<arrayCount(aSkill.Cost); i++)
        {
    		aSkill.Cost[i] = aSkill.default.Cost[i] * percent / 100;
        }
		aSkill = aSkill.next;
	}
}

function bool DestroyActor( Actor d )
{
	// If this item is in an inventory chain, unlink it.
    local Decoration downer;

    if( d.IsA('Inventory') && d.Owner != None && d.Owner.IsA('Pawn') )
    {
        Pawn(d.Owner).DeleteInventory( Inventory(d) );
    }
    return d.Destroy();
}

function string ActorToString( Actor a )
{
    local string out;
    out = a.Class.Name$":"$a.Name$"("$a.Location$")";
    if( a.Base != None && a.Base.Class!=class'LevelInfo' )
        out = out $ "(Base:"$a.Base.Class$":"$a.Base.Name$")";
    return out;
}

static final function string ReplaceText(coerce string Text, coerce string Replace, coerce string With)
{
    local int i;
    local string Output, capsReplace;

    capsReplace = Caps(Replace);
    
    i = InStr( Caps(Text), capsReplace );
    while (i != -1) {
        Output = Output $ Left(Text, i) $ With;
        Text = Mid(Text, i + Len(Replace)); 
        i = InStr( Caps(Text), capsReplace);
    }
    Output = Output $ Text;
    return Output;
}

function int SetSeed(int s)
{
    newseed = s;
}

function int Rng(int max)
{
    local int gen1, gen2;
    gen2 = 2147483643;
    gen1 = gen2/2;
    newseed = gen1 * newseed * 5 + gen2 + (newseed/5) * 3;
    newseed = abs(newseed);
    return (newseed >>> 8) % max;
}


// ============================================================================
// CrcInit https://web.archive.org/web/20181105143221/http://unrealtexture.com/Unreal/Downloads/3DEditing/UnrealEd/Tutorials/unrealwiki-offline/crc32.html
//
// Initializes CrcTable and prepares it for use with Crc.
// ============================================================================

final function CrcInit() {

    const CrcPolynomial = 0xedb88320;

    local int CrcValue;
    local int IndexBit;
    local int IndexEntry;

  for (IndexEntry = 0; IndexEntry < 256; IndexEntry++) {
        CrcValue = IndexEntry;

        for (IndexBit = 8; IndexBit > 0; IndexBit--)
        {
            if ((CrcValue & 1) != 0)
                CrcValue = (CrcValue >>> 1) ^ CrcPolynomial;
            else
                CrcValue = CrcValue >>> 1;
        }
        
        CrcTable[IndexEntry] = CrcValue;
    }
}


// ============================================================================
// Crc
//
// Calculates and returns a checksum of the given string. Call CrcInit before.
// ============================================================================

final function int Crc(coerce string Text) {

    local int CrcValue;
    local int IndexChar;

    CrcValue = 0xffffffff;

    for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
        CrcValue = (CrcValue >>> 8) ^ CrcTable[Asc(Mid(Text, IndexChar, 1)) ^ (CrcValue & 0xff)];

    return CrcValue;
}

defaultproperties
{
    bAlwaysRelevant=True
}
