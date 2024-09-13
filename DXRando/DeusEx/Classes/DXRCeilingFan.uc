class DXRCeilingFan injects #var(prefix)CeilingFan;

var bool bAlreadyUsed;
var int adjustRate;
var int baseAdjustRate;
var int maxFanSpeed;

function BeginPlay()
{
    Super.BeginPlay();
    InitFanSpeed();
}

function InitFanSpeed()
{
    local int divisor;

    maxFanSpeed = RotationRate.Yaw;

    divisor = 50 + Rand(30); //Some fans are better lubricated than others
    baseAdjustRate = maxFanSpeed / divisor;

}

function Timer()
{
    RotationRate.Yaw+=adjustRate;

    if (RotationRate.Yaw<0 && adjustRate<0){
        RotationRate.Yaw=0; //Only clamp the rotation rate to 0 if it's being slowed down
    } else if (RotationRate.Yaw>maxFanSpeed && adjustRate>0){
        RotationRate.Yaw=maxFanSpeed; //Only clamp the rotation rate to the maximum if it's being sped up
    } else {
        return;
    }

    adjustRate=0;
    SetTimer(0,False);
}

function ToggleFan()
{
    local bool turningOn;
    local #var(prefix)CeilingFanMotor motor;

    if (RotationRate.Yaw > 0 && adjustRate>0){
        turningOn=False; //Fan is on in the process of turning on, so turn it off
    } else if (RotationRate.Yaw<maxFanSpeed && adjustRate<0){
        turningOn=True; //Fan is off or in the process of turning off, so turn it on
    } else {
        if (adjustRate==0){ //Fan isn't in a transition state, but isn't within the bounds of the default speeds
            if (RotationRate.Yaw <= 0) { //Fan is off, or rotating the opposite direction.  Start it spinning towards the right way
                turningOn=True;
            } else if (RotationRate.Yaw >= maxFanSpeed){ //Fan is on, possibly spinning faster than normal
                turningOn=False;
            }
        } else {
            //Fan is adjusting speed, but outside the bounds of defaults.
            //Don't allow it to be fiddled with until it's in-bounds
            return;
        }
    }

    //Find the closest ceiling fan motor - I can't imagine there would ever be multiple *that* close together
    foreach RadiusActors(class'#var(prefix)CeilingFanMotor', motor,20){break;}

    if (turningOn){
        PlaySound(sound'Switch4ClickOn');
        adjustRate=baseAdjustRate; //Default speed of 16384 means this takes 65 timer ticks to adjust
        if (motor!=None){motor.AmbientSound=motor.Default.AmbientSound;}
    } else {
        PlaySound(sound'Switch4ClickOff');
        adjustRate=-baseAdjustRate;
        if (motor!=None){motor.AmbientSound=None;}
    }

    SetTimer(0.1,True);
}

function Frob(actor Frobber, Inventory frobWith)
{
    Super.Frob(Frobber, frobWith);

    ToggleFan();

    if (!bAlreadyUsed){
        bAlreadyUsed=true;
        class'DXREvents'.static.MarkBingo("NotABigFan");
    }
}

defaultproperties
{
     bHighlight=True
     adjustRate=0
     baseAdjustRate=250
     maxFanSpeed=16384
}
