class DXRShakeTrigger injects #var(prefix)ShakeTrigger;

var DeusExPlayer player;

event Tick(float DeltaTime)
{
    if(player != None)
        player.ViewShake(DeltaTime);
}

function Timer()
{
    local name stateName;

    if (player!=None){
        stateName = player.GetStateName();

        //These states don't handle shaking the view in DeusExPlayer normally
        if (stateName=='Interpolating' || stateName=='Paralyzed'){
            Enable('Tick');
        } else {
            Disable('Tick');
        }
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    local DeusExPlayer p;

    if (Instigator==None){
	    foreach AllActors(class'DeusExPlayer',p){
            player = p;
            SetTimer(1, True); //Start caring about making sure the screen shakes
            Enable('Tick'); //Just to be sure
	        Super.Trigger(Other, p);
        }
    }else {
	    Super.Trigger(Other, Instigator);
    }
}
