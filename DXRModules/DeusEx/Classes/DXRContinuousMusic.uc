class DXRContinuousMusic extends DXRBase transient;

var Music LevelSong;
var byte LevelSongSection;

enum EMusicMode
{
	MUS_Ambient,
	MUS_Combat,
	MUS_Conversation,
	MUS_Outro,
	MUS_Dying
};

var EMusicMode musicMode;
var float musicCheckTimer;
var float musicChangeTimer;

var byte savedCombatSection;
var byte savedConvSection;

var #var(PlayerPawn) p;
var config Music PrevSong;
var config byte PrevMusicMode;
var config byte PrevSongSection;
var config byte PrevSavedSection;
var config byte PrevSavedCombatSection;
var config byte PrevSavedConvSection;

var byte OutroSection;
var byte DyingSection;
var byte ConvSection;
var byte CombatSection;// used for NYCStreets2_Music

var int setting;
var class<MenuChoice_ContinuousMusic> c;

struct SongChoice {
    var string song;
    var int ambient, dying, combat, conv, outro;
};

simulated function PreBeginPlay()
{
    Disable('Tick');
    Super.PreBeginPlay();
}

simulated event Destroyed()
{
    Disable('Tick');
    RememberMusic();
    Super.Destroyed();
}

simulated event PreTravel()
{
    Disable('Tick');
    RememberMusic();
    Super.PreTravel();
}

function Timer()
{
    Super.Timer();
    RememberMusic();
}

function RememberMusic()
{
    if(p==None || p.Song == None) return;

    // save us writing to the config file
    if(
        PrevSong == p.Song && PrevMusicMode == musicMode && PrevSongSection == p.SongSection && PrevSavedSection == p.savedSection
        && PrevSavedCombatSection == savedCombatSection && PrevSavedConvSection == savedConvSection
    )
        return;

    // dying and outro don't set the savedSection, so we have to do it manually
    if(PrevMusicMode == 0 && (musicMode == MUS_Dying || musicMode == MUS_Outro) ) {
        p.savedSection = PrevSongSection;
    }

    PrevSong = p.Song;
    PrevMusicMode = musicMode;
    PrevSongSection = p.SongSection;
    PrevSavedSection = p.savedSection;
    PrevSavedCombatSection = savedCombatSection;
    PrevSavedConvSection = savedConvSection;
    SaveConfig();
}

function ClientSetMusic( playerpawn NewPlayer, music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    p = #var(PlayerPawn)(NewPlayer);
    setting = int(NewPlayer.ConsoleCommand("get #var(package).MenuChoice_ContinuousMusic continuous_music"));
    c = class'MenuChoice_ContinuousMusic';
    l("ClientSetMusic("$NewSong@NewSection@NewCdTrack@NewTransition$") "$setting@PrevSong@PrevMusicMode@dxr.dxInfo.missionNumber);

    // copy to LevelSong in order to support changing songs, since Level.Song is const
    LevelSong = Level.Song;
    LevelSongSection = Level.SongSection;
    DyingSection = 1;
    CombatSection = 3;
    ConvSection = 4;
    OutroSection = 5;
    savedCombatSection = CombatSection;
    savedConvSection = ConvSection;
    if( dxr.dxInfo.missionNumber == 8 && dxr.localURL != "08_NYC_BAR" ) {
        //LevelSong = Music'NYCStreets2_Music';
        LevelSong = Music(DynamicLoadObject("NYCStreets2_Music.NYCStreets2_Music", class'Music'));
        NewSong = LevelSong;
        CombatSection = 26;// idk why but section 3 takes time to start playing the song
    }

    // ignore complicated logic for title screen or if disabled, gives us a chance to reset the values stored in configs
    if( p == None || dxr == None || setting == c.default.disabled ) {
        _ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
        // really make sure we clean the config
        PrevSong = NewSong;
        PrevMusicMode = 0;
        PrevSongSection = 0;
        PrevSavedSection = 0;
        RememberMusic();
        SaveConfig();
        return;
    }

    p.musicMode = MUS_Outro;
}

function SongChoice MakeSongChoice(string song, int ambient, int dying, int combat, int conv, int outro)
{
    local SongChoice s;
    s.song = song;
    s.ambient = ambient;
    s.dying = dying;
    s.combat = combat;
    s.conv = conv;
    s.outro = outro;
    return s;
}

function GetLevelSong()
{
    local SongChoice choices[50];
    local SongChoice s;
    local int i;
    local bool all;

    switch(dxr.localURL) {
    case "INTRO":
    case "ENDGAME1":
    case "ENDGAME2":
    case "ENDGAME3":
    case "ENDGAME4":
        all=true;
    }

    // TODO: probably a few of these songs don't have the right sections, also we could mix up ambient vs alternative ambient for songs that have it
    // we could also use combat/conversation/outro/dying songs from different songs
    // 0=ambient, 1=dying, 2=ambient2, 3=combat, 4=conversation, 5=outro
    choices[i++] = MakeSongChoice("Area51_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("Area51Bunker_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("BatteryPark_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("HKClub_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("HKClub2_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("HongKong_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("HongKongCanal_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("HongKongHelipad_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("Intro_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("Lebedev_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("LibertyIsland_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("MJ12_Music", 0, 1, 3, 4, 5);
    //choices[i++] = MakeSongChoice("MJ12_Music", 2, 1, 3, 4, 5);// ambient 2? maybe this could be a conversation song instead? maybe this isn't the right way to do this because it puts MJ12_Music into the pool twice
    choices[i++] = MakeSongChoice("NavalBase_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("NYCBar2_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("NYCStreets_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("NYCStreets2_Music", 0, 1, 26, 4, 5);
    choices[i++] = MakeSongChoice("OceanLab_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("OceanLab2_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("ParisCathedral_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("ParisChateau_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("ParisClub_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("ParisClub2_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("Training_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("Tunnels_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("UNATCO_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("UNATCOReturn_Music", 0, 1, 3, 4, 5);
    //choices[i++] = MakeSongChoice("UNATCOReturn_Music", 2, 1, 3, 4, 5);// ambient 2
    choices[i++] = MakeSongChoice("Vandenberg_Music", 0, 1, 3, 4, 5);
    choices[i++] = MakeSongChoice("VersaLife_Music", 0, 1, 3, 4, 5);

    if(all) {
        choices[i++] = MakeSongChoice("Credits_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("DeusExDanceMix_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("Endgame1_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("Endgame2_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("Endgame3_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("Quotes_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("Title_Music", 0, 1, 3, 4, 5);
    }

    SetGlobalSeed(string(Level.Song.Name));// matching songs will stay matching
    if( dxr.dxInfo.missionNumber == 8 && dxr.localURL != "08_NYC_BAR" )
        SetGlobalSeed("NYCStreets2_Music");

    i = rng(i);
    s = choices[i];

    LevelSongSection = s.ambient;
    DyingSection = s.dying;
    CombatSection = s.combat;
    ConvSection = s.conv;
    OutroSection = s.outro;
    if(all) {
        switch(rng(5)) {
        case 1: LevelSongSection = DyingSection; break;
        case 2: LevelSongSection = CombatSection; break;
        case 3: LevelSongSection = ConvSection; break;
        case 4: LevelSongSection = OutroSection; break;
        }
    }
    l("GetLevelSong() "$s.song@LevelSongSection@DyingSection@CombatSection@ConvSection@OutroSection);
    LevelSong = Music(DynamicLoadObject(s.song$"."$s.song, class'Music'));
    savedCombatSection = CombatSection;
    savedConvSection = ConvSection;
}

function AnyEntry()
{
    local music NewSong;
    local byte NewSection, NewCdTrack;
    local EMusicTransition NewTransition;

    l("AnyEntry 1: "$p@dxr@dxr.dxInfo.missionNumber@setting);
    if( p == None || dxr == None  || setting == c.default.disabled )
        return;

    GetLevelSong();
    NewSong = LevelSong;
    NewSection = LevelSongSection;
    NewCdTrack = 255;
    NewTransition = MTRAN_Fade;

    l("AnyEntry 2: "$NewSong@NewSection@NewCdTrack@NewTransition@PrevSong@PrevSongSection@PrevSavedSection@PrevMusicMode);

    // ensure musicMode defaults to ambient, to fix combat music re-entry
    musicMode = MUS_Ambient;

    // now time for fancy stuff, don't attempt a smmoth transition for the title screen, we need to init the config
    if(PrevSong == NewSong && setting != c.default.disabled && dxr.dxInfo.missionNumber > -2) {
        if(PrevSavedSection == 255)
            PrevSavedSection = NewSection;

        switch(PrevMusicMode) {
            case 0: musicMode = MUS_Ambient; break;
            case 1: musicMode = MUS_Combat; break;
            // 2=conversation, 3=outro, 4=dying
            default:
                musicMode = MUS_Ambient;
                PrevSongSection = PrevSavedSection;
                break;
        }
        p.savedSection = PrevSavedSection;
        p.SongSection = PrevSongSection;
        savedCombatSection = PrevSavedCombatSection;
        savedConvSection = PrevSavedConvSection;
        NewSection = PrevSongSection;
        if(setting==c.default.simple) {
            // simpler version of continuous music
            NewSection = PrevSongSection;
            NewTransition = MTRAN_FastFade;// default is MTRAN_Fade, quicker fade here when it's the same song
        } else if(musicMode == PrevMusicMode) { //if(setting==c.default.advanced) {
            // this is where we've determined we can just leave the current song playing
            // MTRAN_None is basically the same as return here, except the Song variable gets set instead of being None, seems like less of a hack to me
            NewTransition = MTRAN_None;
        } else {
            NewTransition = MTRAN_FastFade;
        }
    } else if(PrevMusicMode == 1) {// 1 is combat
        NewTransition = MTRAN_SlowFade;
    } else {
        // does the default MTRAN_Fade even work?
        NewTransition = MTRAN_FastFade;
    }

    // let us change songs immediately so we go straight to combat music if we're in combat
    musicCheckTimer = 10;
    musicChangeTimer = 10;

    _ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);

    SetTimer(1.0, True);
    Enable('Tick');
}

// ----------------------------------------------------------------------
// UpdateDynamicMusic() copied from DeusExPlayer, but Level.Song was changed to LevelSong, and Level.SongSection changed to LevelSongSection
//
// Pattern definitions:
//   0 - Ambient 1
//   1 - Dying
//   2 - Ambient 2 (optional)
//   3 - Combat
//   4 - Conversation
//   5 - Outro
// ----------------------------------------------------------------------

simulated event Tick(float deltaTime)
{
    if (LevelSong == None)
        return;

    if(p == None && string(Level.Game.class.name) == "DXRandoTests")
        return;

    // DEUS_EX AMSD In singleplayer, do the old thing.
    // In multiplayer, we can come out of dying.
    if (!p.PlayerIsClient())
    {
        if ((musicMode == MUS_Dying) || (musicMode == MUS_Outro))
            return;
    }
    else
    {
        if (musicMode == MUS_Outro)
            return;
    }

    musicCheckTimer += deltaTime;
    musicChangeTimer += deltaTime;

    if (p.IsInState('Interpolating'))
    {
        // don't mess with the music on any of the intro maps
        if ((dxr.dxInfo != None) && (dxr.dxInfo.MissionNumber < 0))
        {
            musicMode = MUS_Outro;
            return;
        }

        if (musicMode != MUS_Outro)
            EnterOutro();
    }
    else if (p.IsInState('Conversation'))
    {
        if (musicMode != MUS_Conversation)
            EnterConversation();
    }
    else if (p.IsInState('Dying'))
    {
        if (musicMode != MUS_Dying)
            EnterDying();
    }
    else
    {
        // only check for combat music every second
        if (musicCheckTimer >= 1.0)
        {
            musicCheckTimer = 0.0;

            if (InCombat())
            {
                musicChangeTimer = 0.0;

                if (musicMode != MUS_Combat)
                    EnterCombat();
            }
            else if (musicMode != MUS_Ambient)
            {
                // wait until we've been out of combat for 5 seconds before switching music
                if (musicChangeTimer >= 5.0)
                    EnterAmbient();
            }
        }
    }

    RememberMusic();
}

function SaveSection()
{
    // save our place in the ambient track
    if (musicMode == MUS_Ambient)
        p.savedSection = p.SongSection;
    if (musicMode == MUS_Combat)
        savedCombatSection = p.SongSection;
    if (musicMode == MUS_Conversation)
        savedConvSection = p.SongSection;
}

function EnterOutro()
{
    SaveSection();
    _ClientSetMusic(LevelSong, OutroSection, 255, MTRAN_FastFade);
    musicMode = MUS_Outro;
}

function EnterConversation()
{
    SaveSection();
    _ClientSetMusic(LevelSong, savedConvSection, 255, MTRAN_Fade);
    musicMode = MUS_Conversation;
}

function EnterDying()
{
    SaveSection();
    _ClientSetMusic(LevelSong, DyingSection, 255, MTRAN_Fade);
    musicMode = MUS_Dying;
}

function EnterCombat()
{
    SaveSection();
    _ClientSetMusic(LevelSong, savedCombatSection, 255, MTRAN_FastFade);
    musicMode = MUS_Combat;
}

function EnterAmbient()
{
    SaveSection();

    // fade slower for combat transitions
    if (musicMode == MUS_Combat)
        _ClientSetMusic(LevelSong, p.savedSection, 255, MTRAN_SlowFade);
    else
        _ClientSetMusic(LevelSong, p.savedSection, 255, MTRAN_Fade);

    musicMode = MUS_Ambient;
    musicChangeTimer = 0.0;
}

function bool InCombat()
{
    local ScriptedPawn npc;
    local Pawn CurPawn;

    // check a 100 foot radius around me for combat
    // XXXDEUS_EX AMSD Slow Pawn Iterator
    //foreach RadiusActors(class'ScriptedPawn', npc, 1600)
    for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
    {
        npc = ScriptedPawn(CurPawn);
        if ((npc != None) && (VSize(npc.Location - p.Location) < (1600 + npc.CollisionRadius)))
        {
            if ((npc.GetStateName() == 'Attacking') && (npc.Enemy == p))
            {
                return true;
            }
        }
    }

    return false;
}

function _ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    l("_ClientSetMusic "$NewSong@NewSection@NewCdTrack@NewTransition@p.savedSection);
#ifdef vanilla
    p._ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
#else
    p.ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
#endif
    RememberMusic();
}
