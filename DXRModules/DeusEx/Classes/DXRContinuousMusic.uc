class DXRContinuousMusic extends DXRBase;

#ifdef vanilla
#exec OBJ LOAD FILE=NYCStreets2_Music
#endif

var #var(PlayerPawn) p;
var config Music PrevSong;
var config byte PrevMusicMode;
var config byte PrevSongSection;
var config byte PrevSavedSection;
var config byte CombatSection;// used for NYCStreets2_Music

simulated event Destroyed()
{
    RememberMusic();
    Super.Destroyed();
}

simulated event PreTravel()
{
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
    if(p==None) return;

    // save us writing to the config file
    if(PrevSong == p.Song && PrevMusicMode == p.musicMode && PrevSongSection == p.SongSection && PrevSavedSection == p.savedSection)
        return;

    // dying and outro don't set the savedSection, so we have to do it manually
    if(PrevMusicMode == 0 && (p.musicMode == MUS_Dying || p.musicMode == MUS_Outro) ) {
        p.savedSection = PrevSongSection;
    }

    PrevSong = p.Song;
    PrevMusicMode = p.musicMode;
    PrevSongSection = p.SongSection;
    PrevSavedSection = p.savedSection;
    SaveConfig();
}

function ClientSetMusic( playerpawn NewPlayer, music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
    local int setting;
    local class<MenuChoice_ContinuousMusic> c;

    p = #var(PlayerPawn)(NewPlayer);
    setting = int(NewPlayer.ConsoleCommand("get #var(package).MenuChoice_ContinuousMusic continuous_music"));
    c = class'MenuChoice_ContinuousMusic';
    l("ClientSetMusic("$NewSong@NewSection@NewCdTrack@NewTransition$") "$setting@PrevSong@PrevMusicMode);

#ifdef vanilla
    // copy to LevelSong in order to support changing songs, since Level.Song is const
    p.LevelSong = Level.Song;
    p.LevelSongSection = Level.SongSection;
    p.CombatSection = 3;
    if( dxr.dxInfo.missionNumber == 8 && dxr.localURL != "08_NYC_BAR" ) {
        p.LevelSong = Music'NYCStreets2_Music';
        NewSong = p.LevelSong;
        p.CombatSection = 26;// idk why but section 3 takes time to start playing the song
    }
#endif

    // ignore complicated logic for title screen and cutscenes or if disabled, gives us a chance to reset the values stored in configs
    if( p == None || dxr == None || dxr.dxInfo.missionNumber <= 0 || dxr.dxInfo.missionNumber > 50 || setting == c.default.disabled ) {
#ifdef vanilla
        p._ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
#else
        NewPlayer.ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
#endif
        // really make sure we clean the config
        PrevSong = NewSong;
        PrevMusicMode = 0;
        PrevSongSection = 0;
        PrevSavedSection = 0;
        RememberMusic();
        SaveConfig();
        return;
    }

    // ensure musicMode defaults to ambient, to fix combat music re-entry
    p.musicMode = MUS_Ambient;

    // now time for fancy stuff
    if(PrevSong == NewSong) {
        if(PrevSavedSection == 255)
            PrevSavedSection = NewSection;

        switch(PrevMusicMode) {
            case 0: p.musicMode = MUS_Ambient; break;
            case 1: p.musicMode = MUS_Combat; break;
            // 2=conversation, 3=outro, 4=dying
            default:
                p.musicMode = MUS_Ambient;
                PrevSongSection = PrevSavedSection;
                break;
        }
        p.savedSection = PrevSavedSection;
        p.SongSection = PrevSongSection;
        NewSection = PrevSongSection;
        if(setting==c.default.simple) {
            // simpler version of continuous music
            NewSection = PrevSongSection;
            NewTransition = MTRAN_FastFade;// default is MTRAN_Fade, quicker fade here when it's the same song
        } else if(p.musicMode == PrevMusicMode) { //if(setting==c.default.advanced) {
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
    p.musicCheckTimer = 10;
    p.musicChangeTimer = 10;

#ifdef vanilla
    // fix NYCStreets2_Music because reasons
    if(NewSection == 3) {
        NewSection = p.CombatSection;
    }

    p._ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
#else
    p.ClientSetMusic(NewSong, NewSection, NewCdTrack, NewTransition);
#endif

    SetTimer(1.0, True);
}
