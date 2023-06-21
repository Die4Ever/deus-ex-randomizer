class DXRPiano injects #var(prefix)WHPiano;

function Frob(actor Frobber, Inventory frobWith)
{
    local int rnd;
    local float duration;

    Super(WashingtonDecoration).Frob(Frobber, frobWith);

    if (bUsing)
        return;
    bUsing = True;

    rnd = Rand(4); //make sure this matches the number of sounds below
    switch(rnd){
        case 0:
            //DX Theme, Correct
            PlaySound(sound'Piano1', SLOT_Misc,,, 256);
            duration=2.0;
            break;
        case 1:
            //Random Key Mashing, DX Vanilla
            PlaySound(sound'Piano2', SLOT_Misc,,, 256);
            duration=2.0;
            break;
        case 2:
            //Max Payne Piano, Slow, Learning
            PlaySound(sound'MaxPaynePianoSlow', SLOT_Misc,,, 256);
            duration=7.5;
            break;
        case 3:
            //Max Payne Piano, Fast
            PlaySound(sound'MaxPaynePianoFast', SLOT_Misc,,, 256);
            duration=4.5;
            break;
        default:
            log("DXRPiano went to far this time!  Got "$rnd);
            duration=-1.0;
            break;
    }

    if (duration<=0){
        bUsing=False; //Picked an invalid sound
    } else {
        SetTimer(duration, False);
    }
}
