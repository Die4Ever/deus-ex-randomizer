class DXRCat injects #var(prefix)Cat;

function EndPetting(optional bool bInterrupted)
{
    Super.EndPetting(bInterrupted);

    //A cat purrs if you pet it!
    if (!bInterrupted){
        PlaySound(sound'CatPurr', SLOT_None,,, 256);
    }
}
