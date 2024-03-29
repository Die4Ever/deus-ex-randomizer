class NanoKey merges NanoKey;
// need to figure out states compatibility https://github.com/Die4Ever/deus-ex-randomizer/issues/135
function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    ItemName = default.ItemName $ " (" $ Description $ ")";
    if(DrawScale < 1.2) {
        class'DXRActorsBase'.static.SetActorScale(Self, 1.3);
    }
}
