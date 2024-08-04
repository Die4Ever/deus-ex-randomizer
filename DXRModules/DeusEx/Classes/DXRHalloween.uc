class DXRHalloween extends DXRActorsBase transient;

function FirstEntry()
{
    Super.FirstEntry();

    if(dxr.flags.IsHalloweenMode()) {
        // Mr. X is only for the Halloween game mode, but other things will instead be controlled by IsOctober(), such as cosmetic changes
        class'MrX'.static.Create(self);
    }
}

function ReEntry(bool IsTravel)
{
    if(IsTravel && dxr.flags.IsHalloweenMode()) {
        // recreate him if you leave the map and come back, but not if you load a save
        class'MrX'.static.Create(self);
    }
}
