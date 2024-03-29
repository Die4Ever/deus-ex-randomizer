#ifdef injections
class DXRMusic extends DXRActorsBase transient config(DXRMusic);
#else
class DXRMusic extends DXRActorsBase transient config(#var(package)Music);
#endif

struct SongChoice {
    var string song;
    var int ambient, dying, combat, conv, outro;
    var bool cutscene_only;
    var bool enabled;
};

var config bool allowCombat;
var config SongChoice choices[300];// keep size in sync with _GetLevelSong tchoices[]

var string skipped_songs[10];// copied back to defaults, so they get remembered across loading screens but not when you close the program, otherwise use the disable button instead of the change song button
var int last_skipped_song;

function CheckConfig()
{
    local int i, g;
    local string gamesongs[100];

    if( ConfigOlderThan(2,6,2,2) ) {
        allowCombat = default.allowCombat;

        for(i=0; i<ArrayCount(choices); i++) {
            choices[i].song = "";
            choices[i].enabled = false;
        }

        i=0;
        // TODO: we could mix up ambient vs alternative ambient for songs that have it
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
        choices[i++] = MakeSongChoice("Lebedev_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("LibertyIsland_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("MJ12_Music", 0, 1, 3, 4, 5);
        //choices[i++] = MakeSongChoice("MJ12_Music", 2, 1, 3, 4, 5);// ambient 2? maybe this could be a conversation song instead? maybe this isn't the right way to do this because it puts MJ12_Music into the pool twice
        choices[i++] = MakeSongChoice("NavalBase_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("NYCBar2_Music", 0, 0, 0, 0, 0);// no sections because it sounds janky when switching
        choices[i++] = MakeSongChoice("NYCStreets_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("NYCStreets2_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("OceanLab_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("OceanLab2_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("ParisCathedral_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("ParisChateau_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("ParisClub_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("ParisClub2_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("Tunnels_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("UNATCO_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("UNATCOReturn_Music", 0, 1, 3, 4, 5);
        //choices[i++] = MakeSongChoice("UNATCOReturn_Music", 2, 1, 3, 4, 5);// ambient 2
        choices[i++] = MakeSongChoice("Vandenberg_Music", 0, 1, 3, 4, 5);
        choices[i++] = MakeSongChoice("VersaLife_Music", 0, 1, 3, 4, 5);

        // cutscene-only songs, change all the arguments to 0 since they don't have other sections
        choices[i++] = MakeSongChoice("Credits_Music", 0, 0, 0, 0, 0, true);
        choices[i++] = MakeSongChoice("DeusExDanceMix_Music", 0, 1, 3, 4, 5, true);
        choices[i++] = MakeSongChoice("Endgame1_Music", 0, 0, 0, 0, 0, true);
        choices[i++] = MakeSongChoice("Endgame2_Music", 0, 0, 0, 0, 0, true);
        choices[i++] = MakeSongChoice("Endgame3_Music", 0, 0, 0, 0, 0, true);
        choices[i++] = MakeSongChoice("Intro_Music", 0, 0, 0, 0, 0, true);
        choices[i++] = MakeSongChoice("Quotes_Music", 0, 0, 0, 0, 0, true);
        choices[i++] = MakeSongChoice("Title_Music", 0, 0, 0, 0, 0, true);
        choices[i++] = MakeSongChoice("Training_Music", 0, 0, 0, 0, 0, true);

        // Unreal Tournament songs
        GetUTSongs(gamesongs);
        AddGameSongs(gamesongs, i);

        // Unreal
        GetUnrealSongs(gamesongs);
        AddGameSongs(gamesongs, i);
    }
    Super.CheckConfig();
}

function GetDXSongs(out string songs[100])
{
    local int i;
    songs[i++] = "Area51_Music";
    songs[i++] = "Area51Bunker_Music";
    songs[i++] = "BatteryPark_Music";
    songs[i++] = "HKClub_Music";
    songs[i++] = "HKClub2_Music";
    songs[i++] = "HongKong_Music";
    songs[i++] = "HongKongCanal_Music";
    songs[i++] = "HongKongHelipad_Music";
    songs[i++] = "Lebedev_Music";
    songs[i++] = "LibertyIsland_Music";
    songs[i++] = "MJ12_Music";
    //choices[i++] = MakeSongChoice("MJ12_Music", 2, 1, 3, 4, 5);// ambient 2? maybe this could be a conversation song instead? maybe this isn't the right way to do this because it puts MJ12_Music into the pool twice
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
    songs[i++] = "Tunnels_Music";
    songs[i++] = "UNATCO_Music";
    songs[i++] = "UNATCOReturn_Music";
    //choices[i++] = MakeSongChoice("UNATCOReturn_Music", 2, 1, 3, 4, 5);// ambient 2
    songs[i++] = "Vandenberg_Music";
    songs[i++] = "VersaLife_Music";

    // cutscene-only songs, change all the arguments to 0 since they don't have other sections
    songs[i++] = "Credits_Music";
    songs[i++] = "DeusExDanceMix_Music";
    songs[i++] = "Endgame1_Music";
    songs[i++] = "Endgame2_Music";
    songs[i++] = "Endgame3_Music";
    songs[i++] = "Intro_Music";
    songs[i++] = "Quotes_Music";
    songs[i++] = "Title_Music";
    songs[i++] = "Training_Music";
}

function GetUTSongs(out string songs[100])
{
    local int i;
    songs[i++] = "Botmca9";
    songs[i++] = "Botpck10";
    songs[i++] = "Cannon";
    songs[i++] = "Colossus";
    songs[i++] = "Course";
    songs[i++] = "Credits.Trophy";
    songs[i++] = "Ending"; // duplicate file name with Unreal, Ending.umx
    songs[i++] = "Enigma";
    songs[i++] = "firebr";
    songs[i++] = "Foregone";
    songs[i++] = "Godown";
    songs[i++] = "Lock";
    songs[i++] = "Mech8";
    songs[i++] = "Mission";
    songs[i++] = "Nether";
    songs[i++] = "Organic";
    songs[i++] = "Phantom";
    songs[i++] = "Razor-ub";
    songs[i++] = "Run";
    songs[i++] = "SaveMe";
    songs[i++] = "Savemeg";
    songs[i++] = "Seeker";
    songs[i++] = "Seeker2";
    songs[i++] = "Skyward";
    songs[i++] = "Strider";
    songs[i++] = "Suprfist";
    songs[i++] = "UnWorld2";
    songs[i++] = "utmenu23";
    songs[i++] = "Uttitle";
    songs[i++] = "Wheels";
}

function GetUnrealSongs(out string songs[100])
{
    local int i;
    songs[i++] = "Boundary";
    songs[i++] = "Chizra1";
    songs[i++] = "Crater";
    songs[i++] = "DigSh";
    songs[i++] = "Dusk";
    songs[i++] = "EndEx";
    songs[i++] = "UEnding.Ending"; // duplicate file name with UT, rename the Ending.umx file to UEnding.umx
    songs[i++] = "EverSmoke";
    songs[i++] = "Fifth";
    songs[i++] = "Flyby";
    songs[i++] = "Found99";
    songs[i++] = "Fourth";
    songs[i++] = "Gala";
    songs[i++] = "Guardian";
    songs[i++] = "Hub2";
    songs[i++] = "Inter";
    songs[i++] = "Isotoxin";
    songs[i++] = "Journey";
    songs[i++] = "Kran2";
    songs[i++] = "Kran32";
    songs[i++] = "K_vision";
    songs[i++] = "Moroset";
    songs[i++] = "Mountain";
    songs[i++] = "Nali";
    songs[i++] = "Neve";
    songs[i++] = "Newmca13";
    songs[i++] = "Newmca16";
    songs[i++] = "Newmca7";
    songs[i++] = "Newmca9";
    songs[i++] = "Opal";
    songs[i++] = "QueenSong";
    songs[i++] = "Return";
    songs[i++] = "Sacred";
    songs[i++] = "Seti";
    songs[i++] = "SkyTwn";
    songs[i++] = "SpaceMarines";
    songs[i++] = "Spire";
    songs[i++] = "Starseek";
    songs[i++] = "Surface";
    songs[i++] = "Title";
    songs[i++] = "Twilight";
    songs[i++] = "Unreal4";
    songs[i++] = "UTemple";
    songs[i++] = "utend";
    songs[i++] = "Vortex";
    songs[i++] = "WarGate";
    songs[i++] = "Warlord";
    songs[i++] = "Watcher";
}

function int AddGameSongs(string songs[100], out int i)
{
    local int g;
    for(g=0; g<ArrayCount(songs); g++) {
        if(songs[g] == "") break;
        choices[i] = MakeSongChoice(songs[g]);
        choices[i].enabled = false;
        i++;
    }
    return i;
}

function bool bSongExists(string song)
{
    local Music SongObj;

    if(InStr(song, ".") != -1)
        SongObj = Music(DynamicLoadObject(song, class'Music', true)); // MayFail=true so it doesn't spam the logs
    else
        SongObj = Music(DynamicLoadObject(song$"."$song, class'Music', true));

    return SongObj != None;
}

function SetEnabledGameSongs(string songs[100], bool enable)
{
    local int c, s;
    l("SetEnabledGameSongs " $ songs[0] @ enable);
    for(c=0; c<ArrayCount(choices); c++) {
        if(choices[c].song == "") continue;
        for(s=0; s<ArrayCount(songs); s++) {
            if(songs[s] == "") break;
            if(songs[s] ~= choices[c].song) {
                choices[c].enabled = enable;
                if(enable && !bSongExists(songs[s])) {
                    l("SetEnabledGameSongs " $ songs[s] $ " file does not exist");
                    choices[c].enabled = false;
                }
                break;
            }
        }
    }
    SaveConfig();
}

function bool AreGameSongsEnabled(string songs[100], optional out int num_enabled, optional out int total)
{
    local int c, s;
    // just return an overall status
    num_enabled = 0;
    total = 0;
    for(s=0; s<ArrayCount(songs); s++) {
        if(songs[s] == "") break;
        total++;
    }
    for(c=0; c<ArrayCount(choices); c++) {
        if(choices[c].song == "") continue;
        for(s=0; s<ArrayCount(songs); s++) {
            if(songs[s] == "") break;
            if(songs[s] ~= choices[c].song && choices[c].enabled) {
                num_enabled++;
            }
        }
    }
    l("AreGameSongsEnabled "$songs[0] @ num_enabled @ total);
    return num_enabled > total/3;
}

function SetEnabledSong(string song, bool enable)
{
    local int c;
    local string fullsong;
    if(InStr(song, ".") != -1)
        fullsong = song$"."$song;
    else
        fullsong = song;

    info("SetEnabledSong "$song@enable);
    for(c=0; c<ArrayCount(choices); c++) {
        if(choices[c].song ~= song || choices[c].song ~= fullsong) {
            choices[c].enabled = enable;
            if(enable && !bSongExists(fullsong)) {
                l("SetEnabledSong " $ song $ " file does not exist");
                choices[c].enabled = false;
            }
        }
    }
    SaveConfig();
}


function SongChoice MakeSongChoice(string song, optional int ambient, optional int dying, optional int combat, optional int conv, optional int outro, optional bool cutscene_only)
{
    local SongChoice s;
    s.song = song;
    s.ambient = ambient;
    s.dying = dying;
    s.combat = combat;
    s.conv = conv;
    s.outro = outro;
    s.cutscene_only = cutscene_only;
    s.enabled = true;
    //s.enabled = (Music(DynamicLoadObject(s.song$"."$s.song, class'Music')) != None);
    return s;
}

function _GetLevelSong(string oldSong, out string newSong, out byte LevelSongSection, out byte DyingSection, out byte CombatSection, out byte ConvSection, out byte OutroSection)
{
    local SongChoice tchoices[300], s;
    local int i, j, num;
    local bool cutscene, goodSong;

    // we expect the caller to handle setting the initial seed
    switch(dxr.localURL) {
    case "DX":
    case "DXOnly":
    case "INTRO":
    case "ENDGAME1":
    case "ENDGAME2":
    case "ENDGAME3":
    case "ENDGAME4":
    case "ENDGAME4REV":
        cutscene=true;
    }

    // build local choices list
    for(j=0; j<ArrayCount(choices); j++) {
        s = choices[j];
        if(s.enabled == false) continue;
        if(s.song == "") continue;
        if(s.cutscene_only && !cutscene) continue;
        tchoices[num++] = s;
    }

    // remember skipped songs
    if(oldSong != "") {
        last_skipped_song = last_skipped_song % ArrayCount(skipped_songs);
        skipped_songs[last_skipped_song] = oldSong;
        default.skipped_songs[last_skipped_song] = skipped_songs[last_skipped_song];
        default.last_skipped_song = ++last_skipped_song;
    }

    // choose the song
    for(j=0; j<100; j++) {
        i = rng(num);
        s = tchoices[i];
        goodSong = true;
        for(i=0; i<ArrayCount(skipped_songs); i++) {
            if(s.song ~= skipped_songs[i]) {
                goodSong = false;
                break;
            }
        }
        if(goodSong) break;
    }

    newSong = s.song;
    LevelSongSection = s.ambient;
    DyingSection = s.dying;
    CombatSection = s.combat;
    ConvSection = s.conv;
    OutroSection = s.outro;
    /*if(cutscene) {
        switch(rng(5)) {
        case 1: LevelSongSection = DyingSection; break;
        case 2: LevelSongSection = CombatSection; break;
        case 3: LevelSongSection = ConvSection; break;
        case 4: LevelSongSection = OutroSection; break;
        }
    }
    LevelSongSection = CombatSection;
    LevelSongSection = PrevSavedSection;*/
    l("GetLevelSong() "$s.song@LevelSongSection@DyingSection@CombatSection@ConvSection@OutroSection);
}

defaultproperties
{
    allowCombat=true
}
