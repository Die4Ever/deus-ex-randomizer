class DXRCeilingFan injects #var(prefix)CeilingFan;

var bool bAlreadyUsed;
var int adjustRate;

function Timer()
{
    RotationRate.Yaw+=adjustRate;

    if (RotationRate.Yaw<0){
        RotationRate.Yaw=0;
    } else if (RotationRate.Yaw>Default.RotationRate.Yaw){
        RotationRate.Yaw=Default.RotationRate.Yaw;
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

    if (RotationRate.Yaw==Default.RotationRate.Yaw || adjustRate>0){
        turningOn=False; //Fan is on in the process of turning on, so turn it off
    } else if (RotationRate.Yaw==0 || adjustRate<0){
        turningOn=True; //Fan is off or in the process of turning off, so turn it on
    } else {
        turningOn=True; //We'll just start speeding it up, I guess - shouldn't happen
    }

    //Find the closest ceiling fan motor - I can't imagine there would ever be multiple *that* close together
    foreach RadiusActors(class'#var(prefix)CeilingFanMotor', motor,20){break;}

    if (turningOn){
        PlaySound(sound'Switch4ClickOn');
        adjustRate=250;
        if (motor!=None){motor.AmbientSound=motor.Default.AmbientSound;}
    } else {
        PlaySound(sound'Switch4ClickOff');
        adjustRate=-250;
        if (motor!=None){motor.AmbientSound=None;}
    }

    SetTimer(0.1,True);
}

function Frob(actor Frobber, Inventory frobWith)
{
    local DXRando dxr;

    Super.Frob(Frobber, frobWith);

    ToggleFan();

    dxr = class'DXRando'.default.dxr;
    if (dxr == None)
        return;

    if (!bAlreadyUsed){
        bAlreadyUsed=true;
        class'DXREvents'.static.MarkBingo(dxr,"NotABigFan");
    }
}

defaultproperties
{
     bHighlight=True
     adjustRate=0
}
