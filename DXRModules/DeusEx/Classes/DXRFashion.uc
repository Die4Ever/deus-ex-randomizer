#dontcompileif vmd
class DXRFashion extends DXRBase transient;


simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local int lastUpdate, i;
    local bool isFemale;
    local class<Pawn> jcd;
    local DXRFashionManager f;
    Super.PlayerAnyEntry(p);

    isFemale = dxr.flagbase.GetBool('LDDPJCIsFemale');

    if(isFemale) {
        info("DXRFashion isFemale, Level.Game.Class.Name == " $ Level.Game.Class.Name);
    }

    f=class'DXRFashionManager'.static.GiveItem(p);

    info("got DXRFashion_LastUpdate: "$lastUpdate);
    if ((class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags))
        && (f.lastUpdate < dxr.dxInfo.MissionNumber || f.lastUpdate > dxr.dxInfo.MissionNumber + 2)) {
        f.RandomizeClothes(player());
    }

    f.GetDressed();
}
