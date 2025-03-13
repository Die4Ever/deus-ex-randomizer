class DXRShowerFaucet injects #var(prefix)ShowerFaucet;

function PostBeginPlay()
{
    local #var(prefix)ShowerHead head;

    // See if there is a matching shower head
    if (Tag != ''){
        foreach AllActors(class'#var(prefix)ShowerHead', head, Tag){ break; }
    }

    //if not, find the closest one and attach it
    //50 seems reasonable, but maybe if some are still broken it can go higher
    if (head==None){
        foreach RadiusActors(class'#var(prefix)ShowerHead',head,50){ break; }

        //Give the shower head a unique tag (the name *should* be unique)
        //and give the faucet the same tag so they can be attached
        if (head!=None){
            head.Tag=head.Name;
            Tag = head.Tag;
        }
    }

    //Proceed with the original logic to bind the two together
    Super.PostBeginPlay();
}

function Frob(actor Frobber, Inventory frobWith)
{
	local #var(PlayerPawn) player;
    local bool         wasOnFire;

	player = #var(PlayerPawn)(Frobber);
    wasOnFire = (player != None && player.bOnFire);

	Super.Frob(Frobber, frobWith);

	if (wasOnFire && !player.bOnFire)
	{
		player.ClientMessage("Splish Splash!",, true);

        class'DXREvents'.static.ExtinguishFire("shower",player);
	}
}

defaultproperties
{
}
