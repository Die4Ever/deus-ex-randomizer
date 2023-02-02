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
    if( p == None || dxr == None || dxr.dxInfo.missionNumber <= -2 || setting == c.default.disabled ) {
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

function GetLevelSong()
{
    local string songs[50];
    local int i;

    // TODO: probably a few of these songs don't have the right sections, also we could mix up ambient vs alternative ambient for songs that have it
    // we could also use combat/conversation/outro/dying songs from different songs
    songs[i++] = "Area51_Music";
    songs[i++] = "Area51Bunker_Music";
    songs[i++] = "BatteryPark_Music";
    songs[i++] = "Credits_Music";
    songs[i++] = "DeusExDanceMix_Music";
    songs[i++] = "Endgame1_Music";
    songs[i++] = "Endgame2_Music";
    songs[i++] = "Endgame3_Music";
    songs[i++] = "HKClub_Music";
    songs[i++] = "HKClub2_Music";
    songs[i++] = "HongKong_Music";
    songs[i++] = "HongKongCanal_Music";
    songs[i++] = "HongKongHelipad_Music";
    songs[i++] = "Intro_Music";
    songs[i++] = "Lebedev_Music";
    songs[i++] = "LibertyIsland_Music";
    songs[i++] = "MJ12_Music";
    songs[i++] = "NavalBase_Music";
    songs[i++] = "NYCBar2_Music";
    songs[i++] = "NYCStreets_Music";
    songs[i++] = "NYCStreets2_Music";
    songs[i++] = "OceanLab_Music";
    songs[i++] = "OceanLab2_Music";
    songs[i++] = "ParisCathedral_Music";
    songs[i++] = "ParisChateau_Music";
    songs[i++] = "ParisClub_Music";
    songs[i++] = "ParisClub2_Music";
    songs[i++] = "Quotes_Music";
    songs[i++] = "Title_Music";
    songs[i++] = "Training_Music";
    songs[i++] = "Tunnels_Music";
    songs[i++] = "UNATCO_Music";
    songs[i++] = "UNATCOReturn_Music";
    songs[i++] = "Vandenberg_Music";
    songs[i++] = "VersaLife_Music";

    SetGlobalSeed(string(Level.Song.Name));// matching songs will stay matching
    if( dxr.dxInfo.missionNumber == 8 && dxr.localURL != "08_NYC_BAR" )
        SetGlobalSeed("NYCStreets2_Music");

    i = rng(i);
    p.ClientMessage(songs[i]);

    DyingSection = 1;
    CombatSection = 3;
    ConvSection = 4;
    OutroSection = 5;
    LevelSong = Music(DynamicLoadObject(songs[i]$"."$songs[i], class'Music'));
    if(songs[i]=="NYCStreets2_Music") CombatSection = 26;
    savedCombatSection = CombatSection;
    savedConvSection = ConvSection;
    LevelSongSection = 0;
}

function AnyEntry()
{
    local music NewSong;
    local byte NewSection, NewCdTrack;
    local EMusicTransition NewTransition;

    l("AnyEntry 1: "$p@dxr@dxr.dxInfo.missionNumber@setting);
    if( p == None || dxr == None || dxr.dxInfo.missionNumber <= -2 || setting == c.default.disabled )
        return;

    GetLevelSong();
    NewSong = LevelSong;
    NewSection = LevelSongSection;
    NewCdTrack = 255;
    NewTransition = MTRAN_Fade;

    l("AnyEntry 2: "$NewSong@NewSection@NewCdTrack@NewTransition@PrevSong@PrevSongSection@PrevSavedSection@PrevMusicMode);

    // ensure musicMode defaults to ambient, to fix combat music re-entry
    musicMode = MUS_Ambient;

    // now time for fancy stuff
    if(PrevSong == NewSong) {
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

    // fix NYCStreets2_Music because reasons
    if(NewSection == 3) {
        NewSection = CombatSection;
        err("had to fix combat music");
    }

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
