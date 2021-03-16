class FrobDisplayWindow injects FrobDisplayWindow;

function DrawWindow(GC gc)
{
    local actor frobTarget;

    if (player != None)
    {
        frobTarget = player.FrobTarget;
        if (frobTarget != None)
            if (!player.IsHighlighted(frobTarget))
                frobTarget = None;
    }

    if ( DeusExMover(frobTarget) != None)
    {
        DeusExMoverDrawMore(DeusExMover(frobTarget), gc);
    }
    Super.DrawWindow(gc);
}

function DeusExMoverDrawMore(DeusExMover m, GC gc)
{
    //display damageThreshold
}
