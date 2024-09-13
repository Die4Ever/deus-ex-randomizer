class DXRToilet injects #var(prefix)Toilet;

var bool bAlreadyUsed;
var DXRToiletSeat seat;

function BeginPlay()
{
    Super.BeginPlay();
    seat = class'DXRToiletSeat'.static.Create(self);
}

function Frob(actor Frobber, Inventory frobWith)
{
	local #var(PlayerPawn) player;
    local DXRando      dxr;

	Super.Frob(Frobber, frobWith);

	player = #var(PlayerPawn)(Frobber);
	if (player != None && player.bOnFire)
	{
		player.ClientMessage("Splish Splash!",, true);
		player.ExtinguishFire();

        foreach AllActors(class'DXRando', dxr) {
            if (SkinColor==SC_Clean){
                class'DXREvents'.static.ExtinguishFire(dxr,"clean toilet",player);
            } else {
                class'DXREvents'.static.ExtinguishFire(dxr,"filthy toilet",player);
            }
            break;
        }
	}
    if (player!=None){
        if (!bAlreadyUsed){
            bAlreadyUsed = true;
            class'DXREvents'.static.MarkBingo("FlushToilet");
        }
    }
}

defaultproperties
{
    bCanBeBase=True
    CollisionHeight=10.000000
}
