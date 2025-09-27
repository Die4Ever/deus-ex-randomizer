class DXRFemur injects #var(prefix)BoneFemur;

function Destroyed()
{
    class'DXREvents'.static.MarkBingo("FightSkeletons_DestroyDeco");

    Super.Destroyed();
}
