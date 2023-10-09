class DXRSkull injects #var(prefix)BoneSkull;

function Destroyed()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando', dxr) {
        class'DXREvents'.static.MarkBingo(dxr,"FightSkeletons");
    }

    Super.Destroyed();
}
