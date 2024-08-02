class DXRPiano injects #var(prefix)WHPiano;

var DXRando dxr;

var int SongPlayed[68]; // <------- Make sure to update this array size when adding new songs!
const NUM_PIANO_SONGS = ArrayCount(SongPlayed);

var #var(PlayerPawn) player;
var string message;
var int soundHandle, currentSong;
var int numSongsPlayed;
var float PlayDoneTime;
var bool broken;
#ifdef hx
var bool bUsing;
#endif

const BROKEN_PIANO_SONG = -2;
const JUST_BROKEN_PIANO = -3;

function bool ValidSong(int i)
{
    if (i==1 || i==2 || i==6 || i==25 || i==BROKEN_PIANO_SONG || i==JUST_BROKEN_PIANO){
        return False;
    }

    return True;
}

function UpdateSongCount()
{
    local int i;

    numSongsPlayed=0;
    for (i=0;i<ArrayCount(SongPlayed);i++){
        if (ValidSong(i) && SongPlayed[i]!=0){
            numSongsPlayed++;
        }
    }
}

function Landed(vector HitNormal)
{
    Super.Landed(HitNormal);

    if (Velocity.Z <= -200)
    {
        soundHandle = PlaySound(sound'MaxPaynePianoJustBroke', SLOT_Misc,5.0,, 900);
    }
}

simulated function Tick(float deltaTime)
{
    if (bUsing){
        if (PlayDoneTime<=Level.TimeSeconds) {
            if (dxr==None){
                foreach AllActors(class'DXRando', dxr) {break;}
            }

            if (!PianoIsBroken() && SongPlayed[currentSong]==0){
                SongPlayed[currentSong]++;
                class'DXREvents'.static.MarkBingo(dxr,"PianoSong"$currentSong$"Played");
                if (ValidSong(currentSong)){
                    class'DXREvents'.static.MarkBingo(dxr,"PianoSongPlayed");
                }
            } else if (currentSong==BROKEN_PIANO_SONG) {
                class'DXREvents'.static.MarkBingo(dxr,"BrokenPianoPlayed");
            }

            if(player != None) {
                player.ClientMessage(message);
                player = None;
            }

            bUsing = False;
            message = "";
            soundHandle = 0;
            UpdateSongCount();
        }
    }

    if (!broken && PianoIsBroken()){
        broken = True;
        bUsing = True;
        if (soundHandle!=0 && Role==ROLE_Authority){
            StopSound(soundHandle);
            soundHandle = 0;
        }
        currentSong=JUST_BROKEN_PIANO;
        PlayDoneTime = 1.0 + Level.TimeSeconds;
        soundHandle = PlaySound(sound'MaxPaynePianoJustBroke', SLOT_Misc,5.0,, 900);
        message = GetSongMessage(sound'MaxPaynePianoJustBroke');
    }
}

function bool PianoIsBroken()
{
     return HitPoints < (default.HitPoints*0.5);
}

function Frob(actor Frobber, Inventory frobWith)
{
    local int rnd;
    local float duration;
    local Sound SelectedSound;

    Super(WashingtonDecoration).Frob(Frobber, frobWith);
#ifdef hx
    if ( PlayDoneTime>Level.TimeSeconds || IsInState('Conversation') || IsInState('FirstPersonConversation') )
        return;
#else
    if (bUsing && soundHandle!=0) {
        if (!PianoIsBroken()){
            StopSound(soundHandle);
        } else {
            return;
        }
    }
#endif

    player = #var(PlayerPawn)(Frobber);
    message = "";
    soundHandle = 0;
    if ( !PianoIsBroken() ) {
        currentSong = PickSongIndex();
        GetSongByIndex(currentSong,SelectedSound,duration);
    } else {
        //Piano is broken!
        SelectedSound = sound'MaxPayneBrokenPianoPlay';
        duration = 2.5;
        currentSong=BROKEN_PIANO_SONG;
    }

    if(SelectedSound == None) {
        log("DXRPiano got an invalid sound!  Got "$currentSong);
        return;
    }

    if(message == "") {
        message = GetSongMessage(SelectedSound);
    }

    soundHandle = PlaySound(SelectedSound, SLOT_Misc,5.0,, 900);
    bUsing = True;

    duration = FMax(duration-0.5, 1);// some leniency
    PlayDoneTime = Level.TimeSeconds + duration;
}

function string GetSongMessage(Sound SelectedSound)
{
    switch(SelectedSound){
        case sound'Piano1':
            return "You played the theme from Deus Ex";
        case sound'Piano2':
            return "You gently tickled the ivories";
        case sound'MaxPaynePianoSlow':
            return "You didn't quite play the theme from Max Payne";
        case sound'MaxPaynePianoFast':
            return "You played the theme from Max Payne";
        case sound'Megalovania':
            return "You played Megalovania from Undertale";
        case sound'SongOfStorms':
            return "You played the Song of Storms from Legend of Zelda: Ocarina of Time";
        case sound'T7GPianoBad':
            return "You didn't quite play The Game from The 7th Guest";
        case sound'T7GPianoGood':
            return "You played The Game from The 7th Guest";
        case sound'MonkeyIsland':
            return "You played the Opening Theme from The Secret of Monkey Island";
        case sound'BloodyTears':
            return "You played Bloody Tears from Castlevania";
        case sound'GreenHillZone':
            return "You played Green Hill Zone from Sonic the Hedgehog";
        case sound'KirbyGreenGreens':
            return "You played Green Greens from Kirby's Dreamland";
        case sound'MetroidItem':
            return "You played the Item Acquisition Fanfare from Metroid";
        case sound'NeverGonnaGive':
            return "You played Never Gonna Give You Up by Rick Astley";
        case sound'MiiChannel':
            return "You played the Mii Channel Theme";
        case sound'SpinachRag':
            return "You played Spinach Rag from Final Fantasy VI";
        case sound'FurElise':
            return "You played Fur Elise by Beethoven";
        case sound'EightMelodiesM1':
            return "You played Eight Melodies from Earthbound Beginnings";
        case sound'EightMelodiesM2':
            return "You played Eight Melodies from Earthbound";
        case sound'FurretWalk':
            return "You played Accumula Town from Pokemon: Black and White";
        case sound'ProfOaksLab':
            return "You played Professor Oak's Lab Theme from Pokemon: Red and Blue";
        case sound'FF4Battle1':
            return "You played Battle Theme 1 from Final Fantasy IV";
        case sound'AquaticAmbience':
            return "You played Aquatic Ambience from Donkey Kong Country";
        case sound'ChronoTriggerTheme':
            return "You played the Main Theme from Chrono Trigger";
        case sound'DoomE1M1':
            return "You played E1M1 from Doom";
        case sound'DoomE1M1Wrong':
            return "You didn't quite play E1M1 from Doom";
        case sound'FFVictoryFanfare':
            return "You played the Victory Fanfare from Final Fantasy";
        case sound'GangplankGalleonIntro':
            return "You played Gangplank Galleon from Donkey Kong Country";
        case sound'Grabbag':
            return "You played Grabbag from Duke Nukem 3D";
        case sound'MegaManStageStart':
            return "You played the Stage Start theme from Mega Man";
        case sound'MGS2MainTheme':
            return "You played the Main Theme from Metal Gear Solid 2";
        case sound'Halo':
            return "You played the Main Theme from Halo";
        case sound'SH2PromiseReprise':
            return "You played Promise (Reprise) from Silent Hill 2";
        case sound'SH2EndingTheme':
            return "You played the Dog Ending Credits Song from Silent Hill 2";
        case sound'StillAlive':
            return "You played Still Alive from Portal";
        case sound'DireDireDocks':
            return "You played Dire Dire Docks from Super Mario 64";
        case sound'GuilesTheme':
            return "You played Guile's Theme from Street Fighter 2";
        case sound'TetrisThemeA':
            return "You played Theme A from Tetris";
        case sound'NokiaRing':
            return "You played the Nokia ringtone";
        case sound'AllStar':
            return "You played All Star by Smash Mouth";
        case sound'BlasterMasterArea1':
            return "You played the Area 1 theme from Blaster Master";
        case sound'DrMarioFever':
            return "You played Fever from Dr. Mario";
        case sound'SML2SpaceZone2':
            return "You played Space Zone 2 from Super Mario Land 2: Six Golden Coins";
        case sound'SimCity2kDowntownDance':
            return "You played Downtown Dance from SimCity 2000";
        case sound'MoonlightSonata':
            return "You played Moonlight Sonata by Beethoven";
        case sound'REMansionBasement':
            return "You played the Basement theme from Resident Evil: Director's Cut Dualshock Edition... for some reason";
        case sound'PachelbelsCanon':
            return "You played Canon in D by Johann Pachelbel";
        case sound'SMRPGForestMaze':
            return "You played Forest Maze from Super Mario RPG";
        case sound'HKSynapse':
            return "You played The Synapse from Deus Ex";
        case sound'ToZanarkand':
            return "You played To Zanarkand from Final Fantasy X";
        case sound'BubbleBobble':
            return "You played Quest Begins from Bubble Bobble";
        case sound'CruelAngelsThesis':
            return "You played A Cruel Angel's Thesis from Neon Genesis Evangelion";
        case sound'ZeldaOverworld':
            return "You played the Overworld theme from The Legend of Zelda";
        case sound'Terran1':
            return "You played Terran Theme 1 from StarCraft";
        case sound'BabaYetu':
            return "You played Baba Yetu from Civilization 4";
        case sound'DuckTalesMoon':
            return "You played the Moon Theme from DuckTales";
        case sound'HKHornet':
            return "You played Hornet's Theme from Hollow Knight";
        case sound'THPSSuperman':
            return "You played Superman by Goldfinger (from Tony Hawk's Pro Skater)";
        case sound'BakaMitai':
            return "You played Baka Mitai from the Yakuza series";
        case sound'DragonRoostIsland':
            return "You played Dragon Roost Island from Legend of Zelda: Wind Waker";
        case sound'LonelyRollingStar':
            return "You played Lonely Rolling Star from Katamari Damacy";
        case sound'MM3WeaponGet':
            return "You played Weapon Get from Mega Man 3";
        case sound'SOTNTragicPrince':
            return "You played The Tragic Prince from Castlevania: Symphony of the Night";
        case sound'PictionaryDrawingGame':
            return "You played Drawing Game from Pictionary (NES)";
        case sound'CelesteFirstSteps':
            return "You played First Steps from Celeste";
        case sound'MM2WilyStage1':
            return "You played Wily Stage 1 from Mega Man 2";
        case sound'Mario2Overworld':
            return "You played the Overworld theme from Super Mario Bros 2 (Did you know it was originally called Doki Doki Panic?)";
        case sound'SMGCometObservatory':
            return "You played Comet Observatory from Super Mario Galaxy";
        case sound'MaxPayneBrokenPianoPlay':
            return "You played a broken piano";
        case sound'MaxPaynePianoJustBroke':
            return "You just broke a perfectly good piano";
        default:
            return "You played an unknown song - "$SelectedSound$" (REPORT ME!)";
    }
}

function int GetSongByIndex(int songIndex, out Sound SelectedSound, out float duration)
{
    switch(songIndex){
        case 0:
            //DX Theme, Correct
            SelectedSound = sound'Piano1';
            duration = 1.5;
            break;
        case 1:
            //Random Key Mashing, DX Vanilla
            SelectedSound = sound'Piano2';
            duration = 1.5;
            break;
        case 2:
            //Max Payne Piano, Slow, Learning
            SelectedSound = sound'MaxPaynePianoSlow';
            duration = 8;
            break;
        case 3:
            //Max Payne Piano, Fast
            SelectedSound = sound'MaxPaynePianoFast';
            duration = 4;
            break;
        case 4:
            //Megalovania
            SelectedSound = sound'Megalovania';
            duration = 3;
            break;
        case 5:
            //Song of Storms
            SelectedSound = sound'SongOfStorms';
            duration = 4;
            break;
        case 6:
            // The six arrive, the fire lights their eyes
            SelectedSound = sound'T7GPianoBad';
            duration = 6;
            break;
        case 7:
            // invited here to learn to play.... THE GAME
            SelectedSound = sound'T7GPianoGood';
            duration = 7;
            break;
        case 8:
            // You fight like a dairy farmer!
            SelectedSound = sound'MonkeyIsland';
            duration = 5;
            break;
        case 9:
            SelectedSound = sound'BloodyTears';
            duration = 4;
            break;
        case 10:
            SelectedSound = sound'GreenHillZone';
            duration = 6;
            break;
        case 11:
            SelectedSound = sound'KirbyGreenGreens';
            duration = 6;
            break;
        case 12:
            SelectedSound = sound'MetroidItem';
            duration = 5;
            break;
        case 13:
            SelectedSound = sound'NeverGonnaGive';
            duration = 5;
            break;
        case 14:
            SelectedSound = sound'MiiChannel';
            duration = 7;
            break;
        case 15:
            SelectedSound = sound'SpinachRag';
            duration = 5;
            break;
        case 16:
            SelectedSound = sound'FurElise';
            duration = 5;
            break;
        case 17:
            SelectedSound = sound'EightMelodiesM1';
            duration = 7;
            break;
        case 18:
            SelectedSound = sound'EightMelodiesM2';
            duration = 5;
            break;
        case 19:
            SelectedSound = sound'FurretWalk';
            duration = 7;
            break;
        case 20:
            SelectedSound = sound'ProfOaksLab';
            duration = 5;
            break;
        case 21:
            SelectedSound = sound'FF4Battle1';
            duration = 7.5;
            break;
        case 22:
            SelectedSound = sound'AquaticAmbience';
            duration = 8;
            break;
        case 23:
            SelectedSound = sound'ChronoTriggerTheme';
            duration = 7;
            break;
        case 24:
            SelectedSound = sound'DoomE1M1';
            duration = 5;
            break;
        case 25:
            SelectedSound = sound'DoomE1M1Wrong';
            duration = 5;
            break;
        case 26:
            SelectedSound = sound'FFVictoryFanfare';
            duration = 5;
            break;
        case 27:
            SelectedSound = sound'GangplankGalleonIntro';
            duration = 9;
            break;
        case 28:
            SelectedSound = sound'Grabbag';
            duration = 7;
            break;
        case 29:
            SelectedSound = sound'MegaManStageStart';
            duration = 8;
            break;
        case 30:
            SelectedSound = sound'MGS2MainTheme';
            duration = 8;
            break;
        case 31:
            SelectedSound = sound'Halo';
            duration = 9.5;
            break;
        case 32:
            SelectedSound = sound'SH2PromiseReprise';
            duration = 8;
            break;
        case 33:
            SelectedSound = sound'SH2EndingTheme';
            duration = 7;
            break;
        case 34:
            SelectedSound = sound'StillAlive';
            duration = 7;
            break;
        case 35:
            SelectedSound = sound'DireDireDocks';
            duration = 8;
            break;
        case 36:
            SelectedSound = sound'GuilesTheme';
            duration = 7;
            break;
        case 37:
            SelectedSound = sound'TetrisThemeA';
            duration = 8;
            break;
        case 38:
            SelectedSound = sound'NokiaRing';
            duration = 4;
            break;
        case 39:
            SelectedSound = sound'AllStar';
            duration = 8;
            break;
        case 40:
            SelectedSound = sound'BlasterMasterArea1';
            duration = 5;
            break;
        case 41:
            SelectedSound = sound'DrMarioFever';
            duration = 5;
            break;
        case 42:
            SelectedSound = sound'SML2SpaceZone2';
            duration = 7;
            break;
        case 43:
            SelectedSound = sound'SimCity2kDowntownDance';
            duration = 7;
            break;
        case 44:
            SelectedSound = sound'MoonlightSonata';
            duration = 10;
            break;
        case 45:
            SelectedSound = sound'REMansionBasement';
            duration = 9;
            break;
        case 46:
            SelectedSound = sound'PachelbelsCanon';
            duration = 9;
            break;
        case 47:
            SelectedSound = sound'SMRPGForestMaze';
            duration = 5;
            break;
        case 48:
            SelectedSound = sound'HKSynapse';
            duration = 5;
            break;
        case 49:
            SelectedSound = sound'ToZanarkand';
            duration = 8;
            break;
        case 50:
            SelectedSound = sound'BubbleBobble';
            duration = 8;
            break;
        case 51:
            SelectedSound = sound'CruelAngelsThesis';
            duration = 8;
            break;
        case 52:
            SelectedSound = sound'ZeldaOverworld';
            duration = 6;
            break;
        case 53:
            SelectedSound = sound'Terran1';
            duration = 7;
            break;
        case 54:
            SelectedSound = sound'BabaYetu';
            duration = 11;
            break;
        case 55:
            SelectedSound = sound'DuckTalesMoon';
            duration = 9;
            break;
        case 56:
            SelectedSound = sound'HKHornet';
            duration = 5;
            break;
        case 57:
            SelectedSound = sound'THPSSuperman';
            duration = 10;
            break;
        case 58:
            SelectedSound = sound'BakaMitai';
            duration = 10;
            break;
        case 59:
            SelectedSound = sound'DragonRoostIsland';
            duration = 7;
            break;
        case 60:
            SelectedSound = sound'LonelyRollingStar';
            duration = 11;
            break;
        case 61:
            SelectedSound = sound'MM3WeaponGet';
            duration = 4;
            break;
        case 62:
            SelectedSound = sound'SOTNTragicPrince';
            duration = 7;
            break;
        case 63:
            SelectedSound = sound'PictionaryDrawingGame';
            duration = 10;
            break;
        case 64:
            SelectedSound = sound'CelesteFirstSteps';
            duration = 7;
            break;
        case 65:
            SelectedSound = sound'MM2WilyStage1';
            duration = 8;
            break;
        case 66:
            SelectedSound = sound'Mario2Overworld';
            duration = 10;
            break;
        case 67:
            SelectedSound = sound'SMGCometObservatory';
            duration = 8;
            break;
        default:
            SelectedSound = None;
            duration = 0;
            log("DXRPiano went too far this time!  Got "$currentSong);
    }
}

//Old logic that purely picked a random song (except for the last played one)
function int PickSongIndexOld()
{
    local int rnd;
    rnd = currentSong;
    while(rnd == currentSong) {
        rnd = Rand(NUM_PIANO_SONGS);
    }
    return rnd;
}

//How many times should a particular song be added into the possible song list
function int GetSongWeight(int songIdx)
{
    switch (songIdx){
        case 0: //Deus Ex theme (Bingo goal)
        case 7: //7th Guest, The Game (bingo goal)
            return 5;
    }
    return 1;
}

//More intelligent picking, weights less played songs more
function int PickSongIndex()
{
    local int rnd, i, j, songPlayedAvg, numValidSongs;
    local int validSongs[100]; //Needs to be bigger than NUM_PIANO_SONGS, since some can have extra weight

    songPlayedAvg=0;
    for (i=0;i<NUM_PIANO_SONGS;i++){
        songPlayedAvg+=SongPlayed[i];
    }
    songPlayedAvg = songPlayedAvg/NUM_PIANO_SONGS;

    numValidSongs=0;
    for (i=0;i<NUM_PIANO_SONGS;i++){
        if (SongPlayed[i]<=songPlayedAvg && i!=currentSong){
            for (j=GetSongWeight(i);j>0;j--){
                validSongs[numValidSongs++]=i;
            }
        }
    }

    if (numValidSongs==0){
        //Ran out of valid songs - probably happening because you're on the last song and you tried to skip it
        //Just return the current song and play it again!  Seems to work reasonably well.
        return currentSong;
    }

    rnd = Rand(numValidSongs);

    //if(player != None) {
    //    player.ClientMessage("Piano picked choice "$rnd$" (song "$validSongs[rnd]$") out of "$numValidSongs$" choices");
    //}

    return validSongs[rnd];
}

defaultproperties
{
    currentSong=-1
    bFlammable=True
    HitPoints=100
    PlayDoneTime=0.0
    broken=False
}
