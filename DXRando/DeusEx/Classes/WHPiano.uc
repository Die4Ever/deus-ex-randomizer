class DXRPiano injects #var(prefix)WHPiano;

var int SongPlayed[38];
var DXRando dxr;

var #var(PlayerPawn) player;
var string message;
var int soundHandle, currentSong;
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

function Landed(vector HitNormal)
{
    Super.Landed(HitNormal);

    if (Velocity.Z <= -200)
    {
        soundHandle = PlaySound(sound'MaxPaynePianoJustBroke', SLOT_Misc,5.0,, 500);
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
                SongPlayed[currentSong]=1;
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
        soundHandle = PlaySound(sound'MaxPaynePianoJustBroke', SLOT_Misc,5.0,, 500);
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
        rnd = currentSong;
        while(rnd == currentSong) {
            rnd = Rand(45); //make sure this matches the number of sounds below
        }
        currentSong = rnd;
        switch(currentSong){
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
                duration = 8;
                break;
            case 22:
                SelectedSound = sound'AquaticAmbience';
                duration = 8;
                break;
            case 23:
                SelectedSound = sound'ChronoTriggerTheme';
                duration = 8;
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
                duration = 11;
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
            default:
                log("DXRPiano went too far this time!  Got "$currentSong);
                return;
        }
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

    soundHandle = PlaySound(SelectedSound, SLOT_Misc,5.0,, 500);
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
        case sound'MaxPayneBrokenPianoPlay':
            return "You played a broken piano";
        case sound'MaxPaynePianoJustBroke':
            return "You just broke a perfectly good piano";
        default:
            return "You played an unknown song - "$SelectedSound$" (REPORT ME!)";
    }
}

defaultproperties
{
    currentSong=-1
    bFlammable=True
    HitPoints=100
    PlayDoneTime=0.0
    broken=False
}
