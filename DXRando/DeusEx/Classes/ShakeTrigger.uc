class DXRShakeTrigger injects #var(prefix)ShakeTrigger;

function Trigger(Actor Other, Pawn Instigator)
{
    local DeusExPlayer p;

    if (Instigator==None){
	    foreach AllActors(class'DeusExPlayer',p){
            p.ShakeView(shakeTime, shakeRollMagnitude, shakeVertMagnitude);
        }
    }

	Super.Trigger(Other, Instigator);
}
