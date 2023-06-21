class DXRPiano injects #var(prefix)WHPiano;

function Frob(actor Frobber, Inventory frobWith)
{
    local int rnd;
    local float duration;
    local Sound SelectedSound;

    Super(WashingtonDecoration).Frob(Frobber, frobWith);

#ifdef hx
    if ( NextUseTime>Level.TimeSeconds || IsInState('Conversation') || IsInState('FirstPersonConversation') )
        return;
#else
    if (bUsing)
        return;
#endif

    rnd = Rand(8); //make sure this matches the number of sounds below
    switch(rnd){
        case 0:
            //DX Theme, Correct
            SelectedSound = sound'Piano1';
            break;
        case 1:
            //Random Key Mashing, DX Vanilla
            SelectedSound = sound'Piano2';
            break;
        case 2:
            //Max Payne Piano, Slow, Learning
            SelectedSound = sound'MaxPaynePianoSlow';
            break;
        case 3:
            //Max Payne Piano, Fast
            SelectedSound = sound'MaxPaynePianoFast';
            break;
        case 4:
            //Megalovania
            SelectedSound = sound'Megalovania';
            break;
        case 5:
            //Song of Storms
            SelectedSound = sound'SongOfStorms';
            break;
        case 6:
            // The six arrive, the fire lights their eyes
            SelectedSound = sound'T7GPianoBad';
            break;
        case 7:
            // invited here to learn to play.... THE GAME
            SelectedSound = sound'T7GPianoGood';
            break;
        default:
            log("DXRPiano went too far this time!  Got "$rnd);
            return;
    }

    if(SelectedSound == None) {
        log("DXRPiano got an invalid sound!  Got "$rnd);
        return;
    }

    PlaySound(SelectedSound, SLOT_Misc,,, 256);
    duration = GetSoundDuration(SelectedSound) + 0.5;
#ifdef hx
    NextUseTime = Level.TimeSeconds + duration;
#else
    bUsing = True;
    SetTimer(duration, False);
#endif
}
