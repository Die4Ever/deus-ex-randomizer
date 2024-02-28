#ifdef injections
class DXRMusicPlayer extends DXRBase transient config(DXRMusicPlayer);
#else
class DXRMusicPlayer extends DXRBase transient config(#var(package)MusicPlayer);
#endif

// keep the config for this class small, since it's saved often
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
var config float musicChangeTimer;

var byte savedSection;
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
var bool allowCombat;
var bool NoSections;

var class<MenuChoice_ContinuousMusic> c;// for convenience, damn I'm lazy

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
        PrevSong == p.Song && PrevMusicMode == musicMode && PrevSongSection == p.SongSection && PrevSavedSection == savedSection
        && PrevSavedCombatSection == savedCombatSection && PrevSavedConvSection == savedConvSection
    ) {
        return;
    }

    PrevSong = p.Song;
    PrevMusicMode = musicMode;
    PrevSongSection = p.SongSection;
    PrevSavedSection = savedSection;
    PrevSavedCombatSection = savedCombatSection;
    PrevSavedConvSection = savedConvSection;
    SaveConfig();
}

function ClientSetMusic( playerpawn NewPlayer, music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    local bool changed_song, set_seed;
    local bool rando_music_setting;
    local int continuous_setting;

    p = #var(PlayerPawn)(NewPlayer);
    c = class'MenuChoice_ContinuousMusic';
    continuous_setting = c.default.continuous_music;
    rando_music_setting = class'MenuChoice_RandomMusic'.default.enabled;
    l("ClientSetMusic("$NewSong@NewSection@NewCdTrack@NewTransition$") "$continuous_setting@rando_music_setting@PrevSong@PrevMusicMode@dxr.dxInfo.missionNumber);

    // copy to LevelSong in order to support changing songs, since Level.Song is const
    if(LevelSong != None)
        changed_song = true;
    set_seed = NewSong == Level.Song;
    LevelSong = NewSong;
    LevelSongSection = NewSection;
    DyingSection = 1;
    CombatSection = 3;
    ConvSection = 4;
    OutroSection = 5;
    savedCombatSection = CombatSection;
    savedConvSection = ConvSection;
    if( dxr.dxInfo.missionNumber == 8 && dxr.localURL != "08_NYC_BAR" && string(NewSong) != "Credits_Music.Credits_Music" ) {
        //LevelSong = Music'NYCStreets2_Music';
        LevelSong = Music(DynamicLoadObject("NYCStreets2_Music.NYCStreets2_Music", class'Music'));
        NewSong = LevelSong;
        CombatSection = 26;// idk why but section 3 takes time to start playing the song
    }

    // ignore complicated logic if everything is disabled
    if( p == None || dxr == None || (continuous_setting == c.default.disabled && rando_music_setting == false) ) {
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

    if(changed_song && dxr != None) {
        PlayRandomSong(set_seed);// should we use the level's normal seed or a random seed?
    }
}

function AnyEntry()
{
    local DXRMusic music;
    music = DXRMusic(dxr.FindModule(class'DXRMusic'));
    if(music != None) {
        allowCombat = music.allowCombat;
    }
    PlayRandomSong(true);
}

function string GetCurrentSongName()
{
    local string p, s;
    p = string(LevelSong);
    s = string(LevelSong.Name);
    if(p ~= (s$"."$s))
        return s;
    return p;
}

function GetLevelSong(bool setseed)
{
    local string oldSong, newSong;
    local DXRMusic music;

    if(setseed) {
        SetGlobalSeed(string(Level.Song.Name));// matching songs will stay matching
        if( dxr.dxInfo.missionNumber == 8 && dxr.localURL != "08_NYC_BAR" )
            SetGlobalSeed("NYCStreets2_Music");
    } else {
        SetGlobalSeed(FRand());
        oldSong = GetCurrentSongName();
    }

    music = DXRMusic(dxr.FindModule(class'DXRMusic'));
    if(music == None) {
        return;
    }
    music._GetLevelSong(oldSong, newSong, LevelSongSection, DyingSection, CombatSection, ConvSection, OutroSection);

    l("GetLevelSong() "$newSong@LevelSongSection@DyingSection@CombatSection@ConvSection@OutroSection);

    if(InStr(newSong, ".") != -1)
        LevelSong = Music(DynamicLoadObject(newSong, class'Music'));
    else
        LevelSong = Music(DynamicLoadObject(newSong$"."$newSong, class'Music'));

    if(LevelSong == None) {
#ifdef injections
        err("Failed to load song "$newSong$"! You need to put the UMX file in the right spot, or remove this entry from the DXRMusic.ini config!");
#else
        err("Failed to load song "$newSong$"! You need to put the UMX file in the right spot, or remove this entry from the #var(package)Music.ini config!");
#endif
    }

    if(LevelSongSection == DyingSection && LevelSongSection == CombatSection && LevelSongSection == ConvSection && LevelSongSection == OutroSection)
        NoSections = true;
    else
        NoSections = false;

    savedSection = LevelSongSection;
    savedCombatSection = CombatSection;
    savedConvSection = ConvSection;
}

function PlayRandomSong(bool setseed)
{
    local music NewSong;
    local byte NewSection, NewCdTrack;
    local EMusicTransition NewTransition;
    local bool rando_music_setting;
    local int continuous_setting;

    if(p == None) return;

    continuous_setting = class'MenuChoice_ContinuousMusic'.default.continuous_music;
    rando_music_setting = class'MenuChoice_RandomMusic'.default.enabled;
    l("AnyEntry 1: "$p@dxr@dxr.dxInfo.missionNumber@continuous_setting@rando_music_setting);
    if( p == None || dxr == None  || (continuous_setting == c.default.disabled && rando_music_setting==false) )
        return;

    if(rando_music_setting && !dxr.flags.IsReducedRando()) {
        GetLevelSong(setseed);
    }
    NewSong = LevelSong;
    NewSection = LevelSongSection;
    NewCdTrack = 255;
    NewTransition = MTRAN_Fade;

    l("AnyEntry 2: "$NewSong@NewSection@NewCdTrack@NewTransition@PrevSong@PrevSongSection@PrevSavedSection@PrevMusicMode);

    // ensure musicMode defaults to ambient, to fix combat music re-entry
    musicMode = MUS_Ambient;

    // now time for fancy stuff, don't attempt a smmoth transition for the title screen, we need to init the config
    if(PrevSong == NewSong && continuous_setting != c.default.disabled && dxr.dxInfo.missionNumber > -2 && musicChangeTimer > 1.0) {
        l("trying to do smooth stuff");
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
        savedSection = PrevSavedSection;
        p.SongSection = PrevSongSection;
        savedCombatSection = PrevSavedCombatSection;
        savedConvSection = PrevSavedConvSection;
        NewSection = PrevSongSection;
        if(continuous_setting==c.default.simple) {
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
    } else if(PrevMusicMode == 1 && dxr.dxInfo.missionNumber > -2) {// 1 is combat
        NewTransition = MTRAN_SlowFade;
        l("MTRAN_SlowFade");
    } else {
        // does the default MTRAN_Fade even work?
        NewTransition = MTRAN_FastFade;
        l("MTRAN_FastFade");
    }

    // we need an extra second for the song to init before we can change to combat music
    musicCheckTimer = -1;
    musicChangeTimer = 0;

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

    if(NoSections)
        return;

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
        savedSection = p.SongSection;
    if (musicMode == MUS_Combat)
        savedCombatSection = p.SongSection;
    if (musicMode == MUS_Conversation)
        savedConvSection = p.SongSection;
}

function EnterOutro()
{
    l("EnterOutro");
    SaveSection();
    musicMode = MUS_Outro;
    _ClientSetMusic(LevelSong, OutroSection, 255, MTRAN_FastFade);
}

function byte FixSavedSection(byte section, byte start)
{
    if(section == 255 || section == LevelSongSection || section == DyingSection || section == CombatSection || section == ConvSection || section == OutroSection)
        return start;
    return section;
}

function EnterConversation()
{
    l("EnterConversation");
    SaveSection();
    musicMode = MUS_Conversation;
    savedConvSection = FixSavedSection(savedConvSection, ConvSection);
    _ClientSetMusic(LevelSong, savedConvSection, 255, MTRAN_Fade);
}

function EnterDying()
{
    l("EnterDying");
    SaveSection();
    musicMode = MUS_Dying;
    _ClientSetMusic(LevelSong, DyingSection, 255, MTRAN_Fade);
}

function EnterCombat()
{
    l("EnterCombat");
    SaveSection();
    musicMode = MUS_Combat;
    savedCombatSection = FixSavedSection(savedCombatSection, CombatSection);
    _ClientSetMusic(LevelSong, savedCombatSection, 255, MTRAN_FastFade);
}

function EnterAmbient()
{
    local EMusicMode oldMusicMode;
    l("EnterAmbient");
    SaveSection();

    oldMusicMode = musicMode;
    musicMode = MUS_Ambient;
    savedSection = FixSavedSection(savedSection, LevelSongSection);

    // fade slower for combat transitions
    if (oldMusicMode == MUS_Combat)
        _ClientSetMusic(LevelSong, savedSection, 255, MTRAN_SlowFade);
    else
        _ClientSetMusic(LevelSong, savedSection, 255, MTRAN_Fade);

    musicChangeTimer = 0.0;
}

function bool InCombat()
{
    local ScriptedPawn npc;
    local Pawn CurPawn;

    if(!allowCombat) return false;

    return class'DXRActorsBase'.static.PawnIsInCombat(p);
}

function _ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    l("_ClientSetMusic("$NewSong@NewSection@NewCdTrack@NewTransition$")"@savedSection@musicMode);
#ifdef vanilla
    p._ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
#else
    p.ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
#endif
    RememberMusic();
}

defaultproperties
{
    allowCombat=true
}
