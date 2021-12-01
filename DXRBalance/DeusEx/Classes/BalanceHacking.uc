class BalanceHacking injects ComputerScreenHack;

var PersonaHeaderTextWindow   hackBackground;
var PersonaHeaderTextWindow   energyMeter;

var Color colWhite;

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

	energyMeter = PersonaHeaderTextWindow(NewChild(Class'PersonaHeaderTextWindow'));
	energyMeter.SetPos(22, 28);
	energyMeter.SetSize(168, 47);
	energyMeter.SetTextAlignments(HALIGN_Center, VALIGN_Center);

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
}
