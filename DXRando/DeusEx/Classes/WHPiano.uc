class DXRPiano injects #var(prefix)WHPiano;

var DXRando dxr;

var int SongPlayed[87]; // <------- Make sure to update this array size when adding new songs!
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
    local int i, oldNumSongsPlayed;
    local bool bAllSongsPlayed;

    bAllSongsPlayed = true;
    oldNumSongsPlayed = numSongsPlayed;
    numSongsPlayed=0;

    for (i=0;i<ArrayCount(SongPlayed);i++){
        if (ValidSong(i)) {
            if(SongPlayed[i]!=0){
                numSongsPlayed++;
            } else if(GetSongWeight(i) > 0) {
                bAllSongsPlayed = false;
            }
        }
    }

    if(numSongsPlayed > oldNumSongsPlayed && bAllSongsPlayed) {
        AllSongsPlayed();
    }
}

function AllSongsPlayed()
{
    local string j;
    local DXRando dxr;
    local class<Json> js;
    js = class'Json';

    log(self $ " AllSongsPlayed()");
    dxr = class'DXRando'.default.dxr;

    j = js.static.Start("Flag");
    js.static.Add(j, "flag", "AllSongsPlayed");
    js.static.Add(j, "num", numSongsPlayed);
    class'DXREvents'.static.GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, self, j);
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
        message = "You just broke a perfectly good piano";
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
        GetSongByIndex(currentSong,SelectedSound,duration,message);
    } else {
        //Piano is broken!
        SelectedSound = sound'MaxPayneBrokenPianoPlay';
        duration = 2.5;
        currentSong=BROKEN_PIANO_SONG;
        message = "You played a broken piano";
    }

    if(SelectedSound == None) {
        log("DXRPiano got an invalid sound!  Got "$currentSong);
        return;
    }

    soundHandle = PlaySound(SelectedSound, SLOT_Misc,5.0,, 900);
    bUsing = True;

    duration = FMax(duration-0.5, 1);// some leniency
    PlayDoneTime = Level.TimeSeconds + duration;
}

function int GetSongByIndex(int songIndex, out Sound SelectedSound, out float duration, out string message)
{
    switch(songIndex){
        case 0:
            //DX Theme, Correct
            SelectedSound = sound'Piano1';
            duration = 1.5;
            message="You played the theme from Deus Ex";
            break;
        case 1:
            //Random Key Mashing, DX Vanilla
            SelectedSound = sound'Piano2';
            duration = 1.5;
            message="You gently tickled the ivories";
            break;
        case 2:
            //Max Payne Piano, Slow, Learning
            SelectedSound = sound'MaxPaynePianoSlow';
            duration = 8;
            message="You didn't quite play the theme from Max Payne";
            break;
        case 3:
            //Max Payne Piano, Fast
            SelectedSound = sound'MaxPaynePianoFast';
            duration = 4;
            message="You played the theme from Max Payne";
            break;
        case 4:
            //Megalovania
            SelectedSound = sound'Megalovania';
            duration = 3;
            message="You played Megalovania from Undertale";
            break;
        case 5:
            //Song of Storms
            SelectedSound = sound'SongOfStorms';
            duration = 4;
            message="You played the Song of Storms from Legend of Zelda: Ocarina of Time";
            break;
        case 6:
            // The six arrive, the fire lights their eyes
            SelectedSound = sound'T7GPianoBad';
            duration = 6;
            message="You didn't quite play The Game from The 7th Guest";
            break;
        case 7:
            // invited here to learn to play.... THE GAME
            SelectedSound = sound'T7GPianoGood';
            duration = 7;
            message="You played The Game from The 7th Guest";
            break;
        case 8:
            // You fight like a dairy farmer!
            SelectedSound = sound'MonkeyIsland';
            duration = 5;
            message="You played the Opening Theme from The Secret of Monkey Island";
            break;
        case 9:
            SelectedSound = sound'BloodyTears';
            duration = 4;
            message="You played Bloody Tears from Castlevania";
            break;
        case 10:
            SelectedSound = sound'GreenHillZone';
            duration = 6;
            message="You played Green Hill Zone from Sonic the Hedgehog";
            break;
        case 11:
            SelectedSound = sound'KirbyGreenGreens';
            duration = 6;
            message="You played Green Greens from Kirby's Dreamland";
            break;
        case 12:
            SelectedSound = sound'MetroidItem';
            duration = 5;
            message="You played the Item Acquisition Fanfare from Metroid";
            break;
        case 13:
            SelectedSound = sound'NeverGonnaGive';
            duration = 5;
            message="You played Never Gonna Give You Up by Rick Astley";
            break;
        case 14:
            SelectedSound = sound'MiiChannel';
            duration = 7;
            message="You played the Mii Channel Theme";
            break;
        case 15:
            SelectedSound = sound'SpinachRag';
            duration = 5;
            message="You played Spinach Rag from Final Fantasy VI";
            break;
        case 16:
            SelectedSound = sound'FurElise';
            duration = 5;
            message="You played Fur Elise by Beethoven";
            break;
        case 17:
            SelectedSound = sound'EightMelodiesM1';
            duration = 7;
            message="You played Eight Melodies from Earthbound Beginnings";
            break;
        case 18:
            SelectedSound = sound'EightMelodiesM2';
            duration = 5;
            message="You played Eight Melodies from Earthbound";
            break;
        case 19:
            SelectedSound = sound'FurretWalk';
            duration = 6;
            message="You played Accumula Town from Pokemon: Black and White";
            break;
        case 20:
            SelectedSound = sound'ProfOaksLab';
            duration = 5;
            message="You played Professor Oak's Lab Theme from Pokemon: Red and Blue";
            break;
        case 21:
            SelectedSound = sound'FF4Battle1';
            duration = 7.5;
            message="You played Battle Theme 1 from Final Fantasy IV";
            break;
        case 22:
            SelectedSound = sound'AquaticAmbience';
            duration = 7;
            message="You played Aquatic Ambience from Donkey Kong Country";
            break;
        case 23:
            SelectedSound = sound'ChronoTriggerTheme';
            duration = 7;
            message="You played the Main Theme from Chrono Trigger";
            break;
        case 24:
            SelectedSound = sound'DoomE1M1';
            duration = 5;
            message="You played E1M1 from Doom";
            break;
        case 25:
            SelectedSound = sound'DoomE1M1Wrong';
            duration = 5;
            message="You didn't quite play E1M1 from Doom";
            break;
        case 26:
            SelectedSound = sound'FFVictoryFanfare';
            duration = 4.5;
            message="You played the Victory Fanfare from Final Fantasy";
            break;
        case 27:
            SelectedSound = sound'GangplankGalleonIntro';
            duration = 9;
            message="You played Gangplank Galleon from Donkey Kong Country";
            break;
        case 28:
            SelectedSound = sound'Grabbag';
            duration = 7;
            message="You played Grabbag from Duke Nukem 3D";
            break;
        case 29:
            SelectedSound = sound'MegaManStageStart';
            duration = 7;
            message="You played the Stage Start theme from Mega Man";
            break;
        case 30:
            SelectedSound = sound'MGS2MainTheme';
            duration = 8;
            message="You played the Main Theme from Metal Gear Solid 2";
            break;
        case 31:
            SelectedSound = sound'Halo';
            duration = 9.5;
            message="You played the Main Theme from Halo";
            break;
        case 32:
            SelectedSound = sound'SH2PromiseReprise';
            duration = 7;
            message="You played Promise (Reprise) from Silent Hill 2";
            break;
        case 33:
            SelectedSound = sound'SH2EndingTheme';
            duration = 7;
            message="You played the Dog Ending Credits Song from Silent Hill 2";
            break;
        case 34:
            SelectedSound = sound'StillAlive';
            duration = 7;
            message="You played Still Alive from Portal";
            break;
        case 35:
            SelectedSound = sound'DireDireDocks';
            duration = 8;
            message="You played Dire Dire Docks from Super Mario 64";
            break;
        case 36:
            SelectedSound = sound'GuilesTheme';
            duration = 7;
            message="You played Guile's Theme from Street Fighter 2";
            break;
        case 37:
            SelectedSound = sound'TetrisThemeA';
            duration = 8;
            message="You played Theme A from Tetris";
            break;
        case 38:
            SelectedSound = sound'NokiaRing';
            duration = 4;
            message="You played the Nokia ringtone";
            break;
        case 39:
            SelectedSound = sound'AllStar';
            duration = 8;
            message="You played All Star by Smash Mouth";
            break;
        case 40:
            SelectedSound = sound'BlasterMasterArea1';
            duration = 5;
            message="You played the Area 1 theme from Blaster Master";
            break;
        case 41:
            SelectedSound = sound'DrMarioFever';
            duration = 5;
            message="You played Fever from Dr. Mario";
            break;
        case 42:
            SelectedSound = sound'SML2SpaceZone2';
            duration = 7;
            message="You played Space Zone 2 from Super Mario Land 2: Six Golden Coins";
            break;
        case 43:
            SelectedSound = sound'SimCity2kDowntownDance';
            duration = 7;
            message="You played Downtown Dance from SimCity 2000";
            break;
        case 44:
            SelectedSound = sound'MoonlightSonata';
            duration = 10;
            message="You played Moonlight Sonata by Beethoven";
            break;
        case 45:
            SelectedSound = sound'REMansionBasement';
            duration = 9;
            message="You played the Basement theme from Resident Evil: Director's Cut Dualshock Edition... for some reason";
            break;
        case 46:
            SelectedSound = sound'PachelbelsCanon';
            duration = 9;
            message="You played Canon in D by Johann Pachelbel";
            break;
        case 47:
            SelectedSound = sound'SMRPGForestMaze';
            duration = 5;
            message="You played Forest Maze from Super Mario RPG";
            break;
        case 48:
            SelectedSound = sound'HKSynapse';
            duration = 5;
            message="You played The Synapse from Deus Ex";
            break;
        case 49:
            SelectedSound = sound'ToZanarkand';
            duration = 8;
            message="You played To Zanarkand from Final Fantasy X";
            break;
        case 50:
            SelectedSound = sound'BubbleBobble';
            duration = 8;
            message="You played Quest Begins from Bubble Bobble";
            break;
        case 51:
            SelectedSound = sound'CruelAngelsThesis';
            duration = 8;
            message="You played A Cruel Angel's Thesis from Neon Genesis Evangelion";
            break;
        case 52:
            SelectedSound = sound'ZeldaOverworld';
            duration = 6;
            message="You played the Overworld theme from The Legend of Zelda";
            break;
        case 53:
            SelectedSound = sound'Terran1';
            duration = 7;
            message="You played Terran Theme 1 from StarCraft";
            break;
        case 54:
            SelectedSound = sound'BabaYetu';
            duration = 11;
            message="You played Baba Yetu from Civilization 4";
            break;
        case 55:
            SelectedSound = sound'DuckTalesMoon';
            duration = 9;
            message="You played the Moon Theme from DuckTales";
            break;
        case 56:
            SelectedSound = sound'HKHornet';
            duration = 5;
            message="You played Hornet's Theme from Hollow Knight";
            break;
        case 57:
            SelectedSound = sound'THPSSuperman';
            duration = 10;
            message="You played Superman by Goldfinger (from Tony Hawk's Pro Skater)";
            break;
        case 58:
            SelectedSound = sound'BakaMitai';
            duration = 10;
            message="You played Baka Mitai from the Yakuza series";
            break;
        case 59:
            SelectedSound = sound'DragonRoostIsland';
            duration = 7;
            message="You played Dragon Roost Island from Legend of Zelda: Wind Waker";
            break;
        case 60:
            SelectedSound = sound'LonelyRollingStar';
            duration = 11;
            message="You played Lonely Rolling Star from Katamari Damacy";
            break;
        case 61:
            SelectedSound = sound'MM3WeaponGet';
            duration = 4;
            message="You played Weapon Get from Mega Man 3";
            break;
        case 62:
            SelectedSound = sound'SOTNTragicPrince';
            duration = 7;
            message="You played The Tragic Prince from Castlevania: Symphony of the Night";
            break;
        case 63:
            SelectedSound = sound'PictionaryDrawingGame';
            duration = 10;
            message="You played Drawing Game from Pictionary (NES)";
            break;
        case 64:
            SelectedSound = sound'CelesteFirstSteps';
            duration = 7;
            message="You played First Steps from Celeste";
            break;
        case 65:
            SelectedSound = sound'MM2WilyStage1';
            duration = 8;
            message="You played Wily Stage 1 from Mega Man 2";
            break;
        case 66:
            SelectedSound = sound'Mario2Overworld';
            duration = 10;
            message="You played the Overworld theme from Super Mario Bros 2 (Did you know it was originally called Doki Doki Panic?)";
            break;
        case 67:
            SelectedSound = sound'SMGCometObservatory';
            duration = 8;
            message="You played Comet Observatory from Super Mario Galaxy";
            break;
        case 68:
            SelectedSound = sound'MKWiiCoconutMall';
            duration = 4;
            message="You played Coconut Mall from Mario Kart Wii";
            break;
        case 69:
            SelectedSound = sound'OdeToJoy';
            duration = 8;
            message="You played Ode to Joy by Beethoven";
            break;
        case 70:
            SelectedSound = sound'TotakasSong';
            duration = 11;
            message="You played Totaka's Song by Kazumi Totaka";
            break;
        case 71:
            SelectedSound = sound'ChronoTriggerFrogsTheme';
            duration = 5;
            message="You played Frog's Theme from Chrono Trigger";
            break;
        case 72:
            SelectedSound = sound'HarvestMoonTown';
            duration = 7;
            message="You played the Town Theme from Harvest Moon";
            break;
        case 73:
            SelectedSound = sound'ZAMNNoAssembly';
            duration = 6;
            message="You played No Assembly Required from Zombies Ate My Neighbors";
            break;
        case 74:
            SelectedSound = sound'SA2PumpkinHill';
            duration = 6;
            message="You played A Ghost's Pumpkin Soup from Sonic Adventure 2";
            break;
        case 75:
            SelectedSound = sound'SkeletonsInMyCloset';
            duration = 8;
            message="You played Skeletons in my Closet from The 7th Guest";
            break;
        case 76:
            SelectedSound = sound'T7GPuzzles';
            duration = 7;
            message="You played Puzzles from The 7th Guest";
            break;
        case 77:
            SelectedSound = sound'ToccataFugue';
            duration = 11;
            message="You played Toccata and Fugue in D Minor by Bach";
            break;
        case 78:
            SelectedSound = sound'ExorcistTubularBells';
            duration = 8;
            message="You played Tubular Bells by Mike Oldfield (from The Exorcist)";
            break;
        case 79:
            SelectedSound = sound'FF6PhantomTrain';
            duration = 8;
            message="You played Phantom Train from Final Fantasy 6";
            break;
        case 80:
            SelectedSound = sound'GnGStage1';
            duration = 5;
            message="You played the Stage 1 theme from Ghosts 'n Goblins";
            break;
        case 81:
            SelectedSound = sound'HalloweenTheme';
            duration = 9;
            message="You played the Theme from Halloween";
            break;
        case 82:
            SelectedSound = sound'SpookyScarySkeletons';
            duration = 12;
            message="You played Spooky, Scary Skeletons by Andrew Gold";
            break;
        case 83:
            SelectedSound = sound'ThisIsHalloween';
            duration = 6;
            message="You played This Is Halloween from The Nightmare Before Christmas";
            break;
        case 84:
            SelectedSound = sound'AllIWantForChristmas';
            duration = 34;  //Deal with it
            message="You played All I Want For Christmas Is You by Mariah Carey";
            break;
        case 85:
            SelectedSound = sound'PeanutsLinusLucy';
            duration = 14;
            message="You played Linus and Lucy from A Charlie Brown Christmas";
            break;
        case 86:
            SelectedSound = sound'Thriller';
            duration = 9;
            message="You played Thriller by Michael Jackson";
            break;
        default:
            SelectedSound = None;
            duration = 0;
            message="You played an unknown song - "$songIndex$" (REPORT ME!)";
            log("DXRPiano went too far this time!  Got "$songIndex);
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
    local DXRando dxr;
    dxr = class'DXRando'.default.dxr; //Pull a reference out of the defaults

    switch (songIdx){
        case 0: //Deus Ex theme (Bingo goal)
        case 7: //7th Guest, The Game (bingo goal)
            return 5;

        //old Halloween-themed songs that are active outside of October and Halloween mode, but at a normal rate
        case 9:  // BloodyTears
        case 32: // SH2PromiseReprise
        case 33: // SH2EndingTheme, I guess...
        case 45: // REMansionBasement
        case 62: // SOTNTragicPrince
            if(dxr.IsOctober()) return 3;
            break; // else use the default return at the bottom

        //Halloween-themed songs (These are inactive outside of October or Halloween mode)
        case 73: //ZAMNNoAssembly
        case 74: //SA2PumpkinHill
        case 75: //SkeletonsInMyCloset
        case 76: //T7GPuzzles
        case 77: //ToccataFugue
        case 78: //ExorcistTubularBells
        case 79: //FF6PhantomTrain
        case 80: //GnGStage1
        case 81: //HalloweenTheme
        case 82: //SpookyScarySkeletons
        case 83: //ThisIsHalloween
        case 86: //Thriller
            if(dxr.IsOctober()) return 3;
            return 0; // else these songs are not active

        case 84: //AllIWantForChristmas
            if (dxr.IsChristmasSeason()) return 75; //The ice thaws
            return 0; //She stays frozen in the block of ice
        case 85: //PeanutsLinusLucy
            if (dxr.IsChristmasSeason()) return 3;
            return 0;

    }
    return 1;
}

//More intelligent picking, weights less played songs more
function int PickSongIndex()
{
    local int rnd, i, j, songPlayedAvg, numValidSongs, numActiveSongs;
    local int validSongs[175]; //Needs to be bigger than NUM_PIANO_SONGS, since some can have extra weight

    songPlayedAvg=0;
    numActiveSongs=0;
    for (i=0;i<NUM_PIANO_SONGS;i++){
        if (GetSongWeight(i) > 0){
            songPlayedAvg+=SongPlayed[i];
            numActiveSongs++;
        }
    }
    songPlayedAvg = songPlayedAvg/numActiveSongs;

    numValidSongs=0;
    for (i=0;i<NUM_PIANO_SONGS;i++){
        if (SongPlayed[i]<=songPlayedAvg && i!=currentSong){
            for (j=GetSongWeight(i); j>0; j--){
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
