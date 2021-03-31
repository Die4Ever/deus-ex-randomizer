class NanoKey merges NanoKey;
// need to figure out states compatibility https://github.com/Die4Ever/deus-ex-randomizer/issues/135
function PostBeginPlay()
{
	Super.PostPostBeginPlay();
    SetTimer(0.3, False);
}

function Timer()
{
    Super.Timer();
    ItemName = ItemName $ " (" $ Description $ ")";
    class'DXRActorsBase'.static.SetActorScale(Self, 1.3);
}
