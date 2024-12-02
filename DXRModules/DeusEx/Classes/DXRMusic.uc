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

struct OggSongChoice {
    var string group; //Eg. Revision vs PS2
    var string song;
    var string ambientintro,ambient,dying,combatintro,combat,convintro,conv,outro;
    var bool cutscene_only;
    var bool enabled;
};

var config bool allowCombat;
var config SongChoice choices[300];// keep size in sync with _GetLevelSong tchoices[]

var config OggSongChoice oggChoices[300]; //For Revision

var string skipped_songs[20];// copied back to defaults, so they get remembered across loading screens but not when you close the program, otherwise use the disable button instead of the change song button
var int last_skipped_song;

function CheckConfig()
{
    local int i, g;
    local string gamesongs[100];

    if( ConfigOlderThan(3,2,5,1) ) {
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
        choices[i++] = MakeSongChoice("HKClub_Music", 0, 0, 0, 4, 0); // only has ambient and convo
        choices[i++] = MakeSongChoice("HKClub2_Music", 0, 0, 0, 0, 0); // only ambient
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
        choices[i++] = MakeSongChoice("ParisClub_Music", 0, 0, 0, 0, 0); // has ambient and a single section combat song
        choices[i++] = MakeSongChoice("ParisClub2_Music", 0, 0, 0, 0, 0); // has ambient and a single section combat song
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

        //Revision
        AddRevisionSongs();
    }
    Super.CheckConfig();
}

function AddRevisionSongs()
{
    local int i;

    if (!#defined(revision)) return;

    oggChoices[i++] = MakeOggSongChoice("Revision","Intro","","Intro.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("Revision","Intro (Sax)","","Main_Title_Alternate.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("PS2","Intro","","Intro.ogg","","","","","","",true);

    oggChoices[i++] = MakeOggSongChoice("Revision","M01/M03 UNATCO HQ","01_UNATCOHQ_Ambientintro.ogg","01_UNATCOHQ_Ambient.ogg","01_UNATCOHQ_Death.ogg","","01_UNATCOHQ_Combat.ogg","","01_UNATCOHQ_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M01 Liberty Island","01_UNATCOIsland_Ambientintro.ogg","01_UNATCOIsland_Ambient.ogg","01_NYC_Death.ogg","","01_NYC_Combat.ogg","","","01_NYC_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","UNATCO HQ","","PS2_UNATCO_Ambient.ogg","PS2_UNATCO_Death.ogg","","PS2_UNATCO_Combat.ogg","","PS2_UNATCO_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Liberty Island","","PS2_Liberty_Ambient.ogg","PS2_Liberty_Death.ogg","","PS2_Liberty_Combat.ogg","","PS2_Liberty_Convo.ogg","PS2_Liberty_Outro.ogg",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","M02 Bar","02_Bar_Ambientintro.ogg","02_Bar_Ambient.ogg","02_NYC_Death.ogg","","02_Street_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Battery Park","02_BatteryPark_Ambientintro.ogg","02_BatteryPark_Ambient.ogg","02_NYC_Death.ogg","","02_NYC_Combat.ogg","","02_NYC_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M02 Free Clinic","02_Street_Ambientintro.ogg","02_Street_Ambient.ogg","02_NYC_Death.ogg","","02_NYC_Combat.ogg","","02_Street_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M02 Streets","02_Street_Ambientintro.ogg","02_Street_Ambient.ogg","02_NYC_Death.ogg","","02_Street_Combat.ogg","","02_Street_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M02 Smuggler","02_Smuggler_Ambientintro.ogg","02_Smuggler_Ambient.ogg","02_NYC_Death.ogg","","02_NYC_Combat.ogg","","02_Street_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","NYC Sewers","09_Graveyard_Ambientintro.ogg","09_Graveyard_Ambient.ogg","02_NYC_Death.ogg","","02_Street_Combat.ogg","","02_Street_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","M02 Bar","","PS2_02_Bar_Ambient.ogg","","","","","","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Battery Park","","PS2_BatteryPark_Ambient.ogg","PS2_BatteryPark_Death.ogg","","PS2_BatteryPark_Combat.ogg","","PS2_BatteryPark_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","NYC Streets","","PS2_NYC_Ambient.ogg","PS2_NYC_Death.ogg","","PS2_NYC_Combat.ogg","","PS2_NYC_Convo.ogg","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","Hangar/747","03_AirfieldHeliBase_Ambientintro.ogg","03_AirfieldHeliBase_Ambient.ogg","02_NYC_Death.ogg","","03_AirfieldHeliBase_Combat.ogg","","03_747_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Airfield","03_AirfieldHeliBase_Ambientintro.ogg","03_AirfieldHeliBase_Ambient.ogg","02_NYC_Death.ogg","","03_AirfieldHeliBase_Combat.ogg","","03_Airfield_Convo.ogg","03_Airfield_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Airfield Helibase","03_AirfieldHeliBase_Ambientintro.ogg","03_AirfieldHeliBase_Ambient.ogg","02_NYC_Death.ogg","","03_AirfieldHeliBase_Combat.ogg","","02_NYC_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Mole People","03_BrooklynBridgeStation_Ambientintro.ogg","03_BrooklynBridgeStation_Ambient.ogg","02_NYC_Death.ogg","","02_Street_Combat.ogg","","02_Street_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M03 Liberty Island","01_UNATCOIsland_Ambientintro.ogg","01_UNATCOIsland_Ambient.ogg","01_NYC_Death.ogg","","01_NYC_Combat.ogg","","","03_UNATCOIsland_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Lebedev","","PS2_Lebedev_Ambient.ogg","PS2_Lebedev_Death.ogg","","PS2_Lebedev_Combat.ogg","","PS2_Lebedev_Convo.ogg","PS2_Lebedev_Outro.ogg",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","M04 Bar","02_Bar_Ambientintro.ogg","02_Bar_Ambient.ogg","02_NYC_Death.ogg","","02_NYC_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M04 Battery Park","02_BatteryPark_Ambientintro.ogg","02_BatteryPark_Ambient.ogg","04_NYC_Death.ogg","","04_Anna_Combat.ogg","","02_NYC_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M04 Streets","02_Street_Ambientintro.ogg","02_Street_Ambient.ogg","04_NYC_Death.ogg","","02_Street_Combat.ogg","","02_Street_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M04 Smuggler","02_Smuggler_Ambientintro.ogg","02_Smuggler_Ambient.ogg","04_NYC_Death.ogg","","02_Street_Combat.ogg","","02_Street_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M04 UNATCO HQ","04_UNATCOHQ_Ambientintro.ogg","04_UNATCOHQ_Ambient.ogg","","","01_UNATCOHQ_Combat.ogg","04_UNATCOHQ_Convointro.ogg","04_UNATCOHQ_Convo.ogg","01_UNATCOHQ_Death.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M04 Liberty Island","01_UNATCOIsland_Ambientintro.ogg","01_UNATCOIsland_Ambient.ogg","01_NYC_Death.ogg","","01_NYC_Combat.ogg","","","04_UNATCOIsland_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","M04 Bar","","PS2_04_Bar_Ambient.ogg","","","","","","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","M05 UNATCO HQ","05_UNATCOHQ_AmbientIntro.ogg","05_UNATCOHQ_Ambient.ogg","05_UNATCOHQ_Death.ogg","","05_UNATCOHQ_Combat.ogg","","05_UNATCOHQ_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M05 Liberty Island","01_UNATCOIsland_Ambientintro.ogg","01_UNATCOIsland_Ambient.ogg","01_NYC_Death.ogg","","01_NYC_Combat.ogg","","","05_NYC_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M05 UNATCO MJ12 Lab","05_UNATCOMJ12lab_Ambientintro.ogg","05_UNATCOMJ12lab_Ambient.ogg","05_UNATCOMJ12lab_Death.ogg","","05_UNATCOMJ12Lab_Combat.ogg","","05_UNATCOMJ12Lab_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","M05 UNATCO HQ","","PS2_05_UNATCO_Ambient.ogg","PS2_05_UNATCO_Death.ogg","","PS2_05_UNATCO_Combat.ogg","","PS2_05_UNATCO_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","M05 Liberty Island","","PS2_Liberty_Ambient.ogg","PS2_Liberty_Death.ogg","","PS2_Liberty_Combat.ogg","","PS2_Liberty_Convo.ogg","PS2_05_UNATCO_Outro.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","MJ12 Lab","","PS2_MJ12_Ambient.ogg","PS2_MJ12_Death.ogg","","PS2_MJ12_Combat.ogg","","PS2_MJ12_Convo.ogg","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","HK Intro","06_Helibase_AmbientIntro.ogg","06_Helibase_Ambient.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("Revision","HK Helibase","06_Helibase_Ambientintro.ogg","06_Helibase_Ambient.ogg","06_HongKong_Death.ogg","","06_HeliBase_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Versalife Labs","06_MJ12lab_Ambientintro.ogg","06_MJ12lab_Ambient.ogg","06_MJ12lab_Death.ogg","","05_UNATCOMJ12lab_Combat.ogg","","06_MJ12lab_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Versalife Labs Level 2","06_HeliBase_Ambientintro.ogg","06_HeliBase_Ambient.ogg","06_MJ12lab_Death.ogg","","06_HeliBase_Combat.ogg","","06_MJ12Lab_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Wan Chai Market","06_Market_AmbientIntro.ogg","06_Market_Ambient.ogg","06_HongKong_Death.ogg","","06_HongKong_Combat.ogg","","06_HongKong_Convo.ogg","06_HongKong_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Versalife","06_Versalife_Ambientintro.ogg","06_Versalife_Ambient.ogg","06_HongKong_Death.ogg","","06_Versalife_Combat.ogg","","06_Versalife_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","HK Canals","06_Canal_AmbientIntro.ogg","06_Canal_Ambient.ogg","06_HongKong_Death.ogg","","06_HongKong_Combat.ogg","","06_Canal_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Lucky Money Exterior","06_Underworld_AmbientIntro.ogg","06_Underworld_Ambient.ogg","06_HongKong_Death.ogg","","06_Underworld_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Lucky Money Interior","","06_Underworld_Ambient_Interior.ogg","06_HongKong_Death.ogg","","06_Underworld_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","HK Intro","","PS2_HK_Helibase_Ambient.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("PS2","HK Helibase","","PS2_HK_Helibase_Ambient.ogg","PS2_HK_Helibase_Death.ogg","","PS2_HK_Helibase_Combat.ogg","","PS2_HK_Helibase_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Wan Chai Market","","PS2_HK_Ambient.ogg","PS2_HK_Death.ogg","","PS2_HK_Combat.ogg","","PS2_HK_Convo.ogg","PS2_HK_Outro.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Versalife","","PS2_Versalife_Ambient.ogg","PS2_Versalife_Death.ogg","","PS2_Versalife_Combat.ogg","","PS2_Versalife_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","HK Canals","","PS2_HK_Canal_Ambient.ogg","PS2_HK_Canal_Death.ogg","","PS2_HK_Canal_Combat.ogg","","PS2_HK_Canal_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Lucky Money","","PS2_HK_Club.ogg","","","","","","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","M08 Bar","08_Bar_Ambientintro.ogg","08_Bar_Ambient.ogg","08_NYC_Death.ogg","08_NYC_Combat_Intro.ogg","08_NYC_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M08 Streets","08_Street_Ambientintro.ogg","08_Street_Ambient.ogg","08_NYC_Death.ogg","08_NYC_Combat_Intro.ogg","08_NYC_Combat.ogg","","08_NYC_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","M08 Smuggler","02_Smuggler_Ambientintro.ogg","02_Smuggler_Ambient.ogg","08_NYC_Death.ogg","08_NYC_Combat_Intro.ogg","08_NYC_Combat.ogg","","08_NYC_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","M08 Streets","","PS2_08_NYC_Ambient.ogg","PS2_08_NYC_Death.ogg","","PS2_08_NYC_Combat.ogg","","PS2_08_NYC_Conversation.ogg","PS2_08_NYC_Outro.ogg",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","Brooklyn Naval Yard","09_Dockyard_Ambientintro.ogg","09_Dockyard_Ambient.ogg","09_NYC_Death.ogg","","09_Dockyard_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Graveyard","09_Graveyard_Ambientintro.ogg","09_Graveyard_Ambient.ogg","09_NYC_Death.ogg","08_NYC_Combat_Intro.ogg","08_NYC_Combat.ogg","","09_Graveyard_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Superfreighter Below Decks","06_Helibase_Ambientintro.ogg","06_Helibase_Ambient.ogg","09_NYC_Death.ogg","","09_Dockyard_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Brooklyn Naval Yard","","PS2_Naval_Ambient.ogg","PS2_Naval_Death.ogg","","PS2_Naval_Combat.ogg","","PS2_Naval_Convo.ogg","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","Paris","10_Metro_AmbientIntro.ogg","10_Metro_Ambient.ogg","10_Paris_Death.ogg","","10_Paris_Combat.ogg","","10_Paris_Convo.ogg","10_Metro_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Paris (Sax)","10_Metro_Ambientintro_Alternate.ogg","10_Metro_Ambient_Alternate.ogg","10_Paris_Death.ogg","","10_Paris_Combat_Alternate.ogg","","10_Paris_Convo.ogg","10_Metro_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Catacombs Tunnels","10_Tunnels_AmbientIntro.ogg","10_Tunnels_Ambient.ogg","10_Paris_Death.ogg","","10_Paris_Combat.ogg","","10_Paris_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Paris Chateau","10_Chateau_Ambientintro.ogg","10_Chateau_Ambient.ogg","10_Paris_Death.ogg","","10_Chateau_Combat.ogg","","10_Chateau_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Paris Club","10_Club_AmbientIntro.ogg","10_Club_Ambient.ogg","10_Paris_Death.ogg","","10_Paris_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Paris Catacombs","","PS2_Paris_Ambient.ogg","PS2_Paris_Death.ogg","","PS2_Paris_Combat.ogg","","PS2_Paris_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Paris Metro","","PS2_Paris_Ambient.ogg","PS2_Paris_Death.ogg","","PS2_Paris_Combat.ogg","","PS2_Paris_Convo.ogg","PS2_Paris_Outro.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Paris Chateau","","PS2_Chateau_Ambient.ogg","PS2_Chateau_Death.ogg","","PS2_Chateau_Combat.ogg","","PS2_Chateau_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Paris Club","","PS2_Paris_Club.ogg","PS2_Paris_Death.ogg","","PS2_Paris_Combat.ogg","","","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","Cathedral","11_Cathedral_AmbientIntro.ogg","11_Cathedral_Ambient.ogg","10_Paris_Death.ogg","","10_Paris_Combat.ogg","","11_Cathedral_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Everett","10_Chateau_Ambientintro.ogg","10_Chateau_Ambient.ogg","10_Paris_Death.ogg","","10_Chateau_Combat.ogg","","10_Chateau_Convo.ogg","11_Paris_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Paris Underground","11_Underground_Ambientintro.ogg","11_Underground_Ambient.ogg","10_Paris_Death.ogg","","10_Paris_Combat.ogg","","10_Paris_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Cathedral","","PS2_Cathedral_Ambient.ogg","PS2_Paris_Death.ogg","","PS2_Paris_Combat.ogg","","PS2_Paris_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Everett","","PS2_Chateau_Ambient.ogg","PS2_Chateau_Death.ogg","","PS2_Chateau_Combat.ogg","","PS2_Chateau_Convo.ogg","PS2_Paris_Outro.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Paris Underground","","PS2_Paris_Ambient.ogg","PS2_Paris_Death.ogg","","PS2_Paris_Combat.ogg","","PS2_Paris_Convo.ogg","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","Vandenberg Command","12_Cmd_AmbientIntro.ogg","12_Cmd_Ambient.ogg","12_Vandenberg_Death.ogg","","12_Vandenberg_Combat.ogg","","12_Vandenberg_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Vandenberg Computer","12_Computer_AmbientIntro.ogg","12_Computer_Ambient.ogg","12_Vandenberg_Death.ogg","","12_Vandenberg_Combat.ogg","","12_Vandenberg_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Gas Station","12_Gas_Ambientintro.ogg","12_Gas_Ambient.ogg","12_Vandenberg_Death.ogg","","12_Vandenberg_Combat.ogg","","","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Vandenberg Tunnels","12_Tunnels_AmbientIntro.ogg","12_Tunnels_Ambient.ogg","12_Vandenberg_Death.ogg","","12_Vandenberg_Combat.ogg","","12_Vandenberg_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Vandenberg","","PS2_Vandenberg_Ambient.ogg","PS2_Vandenberg_Death.ogg","","PS2_Vandenberg_Combat.ogg","","PS2_Vandenberg_Convo.ogg","PS2_Vandenberg_Outro.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Vandenberg Tunnels","","PS2_Tunnels_Ambient.ogg","PS2_Tunnels_Death.ogg","","PS2_Tunnels_Combat.ogg","","PS2_Tunnels_Convo.ogg","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","Oceanlab","14_Lab_Ambientintro.ogg","14_Lab_Ambient.ogg","14_OceanLab_Death.ogg","","14_OceanLab_Combat.ogg","14_OceanLab_Convointro.ogg","14_OceanLab_Convo.ogg","14_OceanLab_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Silo","12_Cmd_Ambientintro.ogg","12_Cmd_Ambient.ogg","12_Vandenberg_Death.ogg","","12_Vandenberg_Combat.ogg","","","14_Silo_End.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Oceanlab UC","14_UC_Ambientintro.ogg","14_UC_Ambient.ogg","14_OceanLab_Death.ogg","","14_OceanLab_Combat.ogg","14_OceanLab_Convointro.ogg","14_OceanLab_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Sub Base","05_UNATCOMJ12lab_Ambientintro.ogg","05_UNATCOMJ12lab_Ambient.ogg","05_UNATCOMJ12lab_Death.ogg","","05_UNATCOMJ12Lab_Combat.ogg","","05_UNATCOMJ12Lab_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Oceanlab","","PS2_OceanLab_Ambient.ogg","PS2_OceanLab_Death.ogg","","PS2_OceanLab_Combat.ogg","","PS2_OceanLab_Convo.ogg","PS2_OceanLab_Outro.ogg",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Oceanlab UC/Silo","","PS2_UCSilo_Ambient.ogg","PS2_UCSilo_Death.ogg","","PS2_UCSilo_Combat.ogg","","PS2_UCSilo_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Sub Base","","PS2_MJ12_Ambient.ogg","PS2_MJ12_Death.ogg","","PS2_MJ12_Combat.ogg","","PS2_MJ12_Convo.ogg","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","Area 51 Exterior","15_Bunker_Ambientintro.ogg","15_Bunker_Ambient.ogg","15_Area51_Death.ogg","15_Area51_Combatintro.ogg","15_Area51_Combat.ogg","15_Area51_Convointro.ogg","15_Area51_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("Revision","Area 51 Interior","15_Entrance_Ambientintro.ogg","15_Entrance_Ambient.ogg","15_Area51_Death.ogg","","15_Entrance_Combat.ogg","15_Entrance_Convointro.ogg","15_Entrance_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Area 51 Exterior","","PS2_Bunker_Ambient.ogg","PS2_Bunker_Death.ogg","","PS2_Bunker_Combat.ogg","","PS2_Bunker_Convo.ogg","",false);
    oggChoices[i++] = MakeOggSongChoice("PS2","Area 51 Interior","","PS2_Area51_Ambient.ogg","PS2_Area51_Death.ogg","","PS2_Area51_Combat.ogg","","PS2_Area51_Convo.ogg","",false);

    oggChoices[i++] = MakeOggSongChoice("Revision","Endgame 1","Endgame1.ogg","Blank.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("Revision","Endgame 2","Endgame2.ogg","Blank.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("Revision","Endgame 3","Endgame3.ogg","Blank.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("Revision","Endgame 4","","Endgame4.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("PS2","Endgame 1","","Endgame1.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("PS2","Endgame 2","","Endgame2.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("PS2","Endgame 3","","Endgame3.ogg","","","","","","",true);
    oggChoices[i++] = MakeOggSongChoice("PS2","Endgame 4","","Endgame4.ogg","","","","","","",true);
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

function GetRevSongs(out string songs[100])
{
    local int i,numSongs;
    for (i=0;i<ArrayCount(oggChoices);i++){
        if (oggChoices[i].song=="") continue;
        if (oggChoices[i].group!="Revision") continue;
        songs[numSongs++] = GetOggSongName (oggChoices[i]);
    }
}

function GetRevPS2Songs(out string songs[100])
{
    local int i,numSongs;
    for (i=0;i<ArrayCount(oggChoices);i++){
        if (oggChoices[i].song=="") continue;
        if (oggChoices[i].group!="PS2") continue;
        songs[numSongs++] = GetOggSongName (oggChoices[i]);
    }
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

function SetEnabledOggGameSongs(string songs[100], bool enable)
{
    local int c, s;
    l("SetEnabledOggGameSongs " $ songs[0] @ enable);
    for(c=0; c<ArrayCount(oggChoices); c++) {
        if(oggChoices[c].song == "") continue;
        for(s=0; s<ArrayCount(songs); s++) {
            if(songs[s] == "") break;
            if(songs[s] ~= GetOggSongName(oggChoices[c])) {
                oggChoices[c].enabled = enable;
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

function bool AreOggGameSongsEnabled(string songs[100], optional out int num_enabled, optional out int total)
{
    local int c, s;
    // just return an overall status
    num_enabled = 0;
    total = 0;
    for(s=0; s<ArrayCount(songs); s++) {
        if(songs[s] == "") break;
        total++;
    }
    for(c=0; c<ArrayCount(oggChoices); c++) {
        if(oggChoices[c].song == "") continue;
        for(s=0; s<ArrayCount(songs); s++) {
            if(songs[s] == "") break;
            if(songs[s] ~= GetOggSongName(oggChoices[c]) && oggChoices[c].enabled) {
                num_enabled++;
            }
        }
    }
    l("AreOggGameSongsEnabled "$songs[0] @ num_enabled @ total);
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

    for(c=0; c<ArrayCount(oggChoices); c++) {
        if(GetOggSongName(oggChoices[c]) ~= song || GetOggSongName(oggChoices[c]) ~= fullsong) {
            oggChoices[c].enabled = enable;
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

function OggSongChoice MakeOggSongChoice(string group, string song, optional string ambientintro, optional string ambient, optional string dying, optional string combatintro, optional string combat, optional string convintro, optional string conv, optional string outro, optional bool cutscene_only)
{
    local OggSongChoice s;
    s.group = group;
    s.song = song;
    s.ambientintro = ambientintro;
    s.ambient = ambient;
    s.dying = dying;
    s.combatintro = combatintro;
    s.combat = combat;
    s.conv = conv;
    s.outro = outro;
    s.cutscene_only = cutscene_only;
    s.enabled = true;
    return s;
}

function MarkSkippedSong(string oldSong)
{
    // remember skipped songs
    if(oldSong != "") {
        last_skipped_song = last_skipped_song % ArrayCount(skipped_songs);
        skipped_songs[last_skipped_song] = oldSong;
        default.skipped_songs[last_skipped_song] = skipped_songs[last_skipped_song];
        default.last_skipped_song = ++last_skipped_song;
    }
}

function _GetLevelSong(out string newSong, out byte LevelSongSection, out byte DyingSection, out byte CombatSection, out byte ConvSection, out byte OutroSection)
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
    case "06_HONGKONG_ENTERINGSCENE": //Revision cutscene as you fly into Hong Kong
        cutscene=true;
    }

    // build local choices list
    for(j=0; j<ArrayCount(choices); j++) {
        s = choices[j];
        if(s.enabled == false) continue;
        if(s.song == "") continue;
        if(s.cutscene_only && !cutscene) continue;

        goodSong = true;
        for(i=0; i<ArrayCount(skipped_songs); i++) {
            if(s.song ~= skipped_songs[i]) {
                goodSong = false;
                break;
            }
        }

        if(goodSong) tchoices[num++] = s;
    }

    // choose the song
    // if we don't put the num into the seed then skipping songs causes you to get the same rng result, which means you skip songs in order
    BranchSeed(num);
    i = rng(num);
    s = tchoices[i];

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

function String GetOggSongName(OggSongChoice s)
{
    return s.song$" ("$s.group$")";
}

function _GetOggLevelSong(out string newSong, out string ambientintro, out string ambient, out string dying, out string combatintro, out string combat, out string convintro, out string conv, out string outro)
{
    local OggSongChoice tchoices[300], s;
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
    case "06_HONGKONG_ENTERINGSCENE": //Revision cutscene as you fly into Hong Kong
        cutscene=true;
    }

    // build local choices list
    for(j=0; j<ArrayCount(oggChoices); j++) {
        s = oggChoices[j];
        if(s.enabled == false) continue;
        if(s.song == "") continue;
        if(s.cutscene_only && !cutscene) continue;

        goodSong = true;
        for(i=0; i<ArrayCount(skipped_songs); i++) {
            if(GetOggSongName(s) ~= skipped_songs[i]) {
                goodSong = false;
                break;
            }
        }

        if(goodSong) tchoices[num++] = s;
    }

    // choose the song
    // if we don't put the num into the seed then skipping songs causes you to get the same rng result, which means you skip songs in order
    BranchSeed(num);
    i = rng(num);
    s = tchoices[i];

    newSong = GetOggSongName(s);
    ambientintro = s.ambientintro;
    ambient = s.ambient;
    dying = s.dying;
    combatintro = s.combatintro;
    combat = s.combat;
    convintro = s.convintro;
    conv = s.conv;
    outro = s.outro;

    l("GetOggLevelSong() "$s.song@ambientintro@ambient@dying@combat@conv@outro);
}

defaultproperties
{
    allowCombat=true
}
