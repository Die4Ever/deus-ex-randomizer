//Formerly BalanceHacking
class DXRComputerScreenHack injects #var(prefix)ComputerScreenHack;

var PersonaHeaderTextWindow   hackBackground;
var TextWindow   energyMeter;

var Color colWhite;
var int energyMeterTimer;

var PersonaActionButtonWindow btnBiocell;
var String BiocellButtonLabel;
var int biocellCount;


function Tick(float deltaTime)
{
    local Human p;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (bHacking)
    {
        p = Human(winTerm.compOwner.Owner);
        if( p == None ) p = Human(Player);// ATMs don't set the Owner
        if( p != None && class'MenuChoice_BalanceSkills'.static.IsEnabled() ) {
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
    local Human p;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;
    p = Human(winTerm.compOwner.Owner);

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

    if(p == None || class'MenuChoice_BalanceSkills'.static.IsDisabled()) {
        energyMeter.Hide();
    }

    UpdateEnergyMeter();
    if(energyMeterTimer == -1)
        energyMeterTimer = AddTimer(0.1, true, 0, 'UpdateEnergyMeterTimer');
}

function CreateHackButton()
{
    local #var(PlayerPawn) p;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    //Make the hacking button
    Super.CreateHackButton();

    p = #var(PlayerPawn)(player);
    if (p==None || class'MenuChoice_BalanceSkills'.static.IsDisabled()) return;
    //Make the Biocell button as well
    btnBiocell = PersonaActionButtonWindow(NewChild(Class'DXRPersonaActionButtonWindow'));
    btnBioCell.minimumButtonWidth=111;
    btnBioCell.SetPos(83,86);
    btnBioCell.CenterText(true);
    UpdateBiocellButtonCount();
}

function UpdateBiocellButtonCount()
{
    local #var(prefix)BioElectricCell bc;
    local #var(PlayerPawn) p;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    p = #var(PlayerPawn)(player);

    if (p==None || btnBiocell==None || class'MenuChoice_BalanceSkills'.static.IsDisabled()) return;

    biocellCount = 0;
    if (p!=None){
        bc = #var(prefix)BioElectricCell(p.FindInventoryType(class'#var(prefix)BioElectricCell'));
        if (bc!=None){
            biocellCount = bc.NumCopies;
        }
    }

    btnBiocell.SetButtonText(BiocellButtonLabel$" ("$biocellCount$")");

    UpdateBiocellButtonClickability();

}

function UpdateBiocellButtonClickability()
{
    local bool enable;
    local #var(PlayerPawn) p;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    p = #var(PlayerPawn)(player);
    enable=False;

    if (p==None || btnBiocell==None || class'MenuChoice_BalanceSkills'.static.IsDisabled()) return;

    if (p!=None && biocellCount!=0){
        if (p.Energy<p.EnergyMax){
            enable=True;
        }
    }

    if (!bHacked){
        btnBiocell.EnableWindow(enable);
    } else {
        btnBiocell.Hide(); //Hide biocell button once the computer is hacked
    }
}

function UpdateHackButtonClickability()
{
    local bool enable;
    local #var(PlayerPawn) p;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    p = #var(PlayerPawn)(player);
    enable=False;

    if (p==None || btnHack==None || class'MenuChoice_BalanceSkills'.static.IsDisabled()) return;

    if (p!=None){
        if (p.Energy>0 && !bHacking && !bHacked){
            enable=True;
        }
    }

    btnHack.SetSensitivity(enable);
}

function HandleBiocellButton()
{
    local #var(prefix)BioElectricCell bc;
    local #var(PlayerPawn) p;

    p = #var(PlayerPawn)(player);

    if (p!=None){
        bc = #var(prefix)BioElectricCell(p.FindInventoryType(class'#var(prefix)BioElectricCell'));
        if (bc!=None){
            bc.Activate();
            UpdateBiocellButtonCount();
        }
    }
}

function bool ButtonActivated( Window buttonPressed )
{
    local #var(PlayerPawn) p;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    p = #var(PlayerPawn)(player);

    if (p==None || btnBiocell==None || class'MenuChoice_BalanceSkills'.static.IsDisabled()) return Super.ButtonActivated(buttonPressed);

    switch( buttonPressed )
    {
        case btnBiocell:
            HandleBiocellButton();
            return true;
    }

    return Super.ButtonActivated(buttonPressed);
}

function UpdateEnergyMeterTimer(int timerID, int invocations, int clientData)
{
    UpdateEnergyMeter();
    UpdateBiocellButtonClickability(); //Button can change clickability based on remaining energy
    UpdateHackButtonClickability();
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
    local Human p;
    local int energy,energydec,req,reqdec,maxenergy,maxenergydec;
    local float reqEnergy;
    local string msg;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    p = Human(player);

    if (p==None || class'MenuChoice_BalanceSkills'.static.IsDisabled()) return;

    //Keep it to one decimal point
    energy = int(p.Energy);
    energydec = int((p.Energy * 10) - (energy*10));

    maxenergy = int(p.EnergyMax);
    maxenergydec = int((p.EnergyMax * 10) - (maxenergy*10));

    reqEnergy = hackTime * 5.0;
    req = int(reqEnergy);
    reqdec = int((reqEnergy*10) - (req*10));


    msg = "Energy: "$energy$"."$energydec$" / "$maxenergy$"."$maxenergydec;

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

#ifdef gmdxae
function SetHackMessage(String newHackMessage, optional bool bShowNukes)
{
    Super.SetHackMessage(newHackMessage, bShowNukes);
    UpdateEnergyMeter();
}
#else
function SetHackMessage(String newHackMessage)
{
    Super.SetHackMessage(newHackMessage);

    UpdateEnergyMeter();
}
#endif

defaultproperties
{
    colWhite=(R=255,G=255,B=255)
    energyMeterTimer=-1
    BiocellButtonLabel="Use |&Biocell"
}
