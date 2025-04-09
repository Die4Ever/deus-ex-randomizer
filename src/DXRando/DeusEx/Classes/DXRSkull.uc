class DXRSkull injects #var(prefix)BoneSkull;

function Destroyed()
{
    class'DXREvents'.static.MarkBingo("FightSkeletons");

    Super.Destroyed();
}
