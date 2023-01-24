class BalanceHacking injects ComputerScreenHack;

var PersonaHeaderTextWindow   hackBackground;
var TextWindow   energyMeter;

var Color colWhite;
var int energyMeterTimer;

function Tick(float deltaTime)
{
    local DeusExPlayer p;
    if (bHacking)
    {
        p = DeusExPlayer(winTerm.compOwner.Owner);
        if( p == None ) p = Player;// ATMs don't set the Owner
        if( p != None ) {
            p.Energy -= deltaTime * 5.0;
            if( p.Energy <= 0 ) {
                p.Energy = 0;
                detectionTime = -1;
                bHackDetected = true;
                p.ClientMessage("You need more energy to hack!",, true);
            }
        }
    }

    UpdateEnergyMeter();

    Super.Tick(deltaTime);
}


function CreateHackMessageWindow()
{

	hackBackground = PersonaHeaderTextWindow(NewChild(Class'PersonaHeaderTextWindow'));
	hackBackground.SetPos(22, 19);
	hackBackground.SetSize(168, 47);
	hackBackground.SetTextAlignments(HALIGN_Center, VALIGN_Center);
	hackBackground.SetBackgroundStyle(DSTY_Modulated);
	hackBackground.SetBackground(Texture'HackInfoBackground');

	winHackMessage = PersonaHeaderTextWindow(NewChild(Class'PersonaHeaderTextWindow'));
	winHackMessage.SetPos(22, 10);
	winHackMessage.SetSize(168, 47);
	winHackMessage.SetTextAlignments(HALIGN_Center, VALIGN_Center);

	energyMeter = TextWindow(NewChild(Class'TextWindow'));
    energyMeter.SetFont(Font'DeusExUI.FontMenuHeaders');
    energyMeter.SetTextMargins(0, 0);
	energyMeter.SetPos(22, 28);
	energyMeter.SetSize(168, 47);
	energyMeter.SetTextAlignments(HALIGN_Center, VALIGN_Center);

    UpdateEnergyMeter();
    if(energyMeterTimer == -1)
        energyMeterTimer = AddTimer(0.1, true, 0, 'UpdateEnergyMeterTimer');
}

function UpdateEnergyMeterTimer(int timerID, int invocations, int clientData)
{
    UpdateEnergyMeter();
}

event DestroyWindow()
{
    Super.DestroyWindow();

    if (energyMeterTimer != -1)
    {
        RemoveTimer(energyMeterTimer);
        energyMeterTimer = -1;
    }
}

function UpdateEnergyMeter()
{
    local DeusExPlayer p;
    local int energy,energydec,req,reqdec;
    local float reqEnergy;
    local string msg;

    p = player;

    //Keep it to one decimal point
    energy = int(p.Energy);
    energydec = int((p.Energy * 10) - (energy*10));

    reqEnergy = hackTime * 5.0;
    req = int(reqEnergy);
    reqdec = int((reqEnergy*10) - (req*10));


    msg = "Energy: "$energy$"."$energydec;

    if (!bHacking) {
        msg = msg$"|n";
        msg = msg$"Required: "$req$"."$reqdec;
    }

    energyMeter.SetText(msg);

    if (reqEnergy >= p.Energy) {
        energyMeter.SetTextColor(colRed);
    } else {
        energyMeter.SetTextColor(colWhite);
    }

    if (!bHacked) {
        energyMeter.Show();
    } else {
        energyMeter.Hide();
    }
}

function SetDetectionTime(Float newDetectionTime, Float newHackTime)
{
    Super.SetDetectionTime(newDetectionTime,newHackTime);

    UpdateEnergyMeter();
}

function SetHackMessage(String newHackMessage)
{
    Super.SetHackMessage(newHackMessage);

    UpdateEnergyMeter();
}

defaultproperties
{
    colWhite=(R=255,G=255,B=255)
    energyMeterTimer=-1
}
