class NanoKey merges NanoKey;
// doesn't work with injects due to use of Self
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
