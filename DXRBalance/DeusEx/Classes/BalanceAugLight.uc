class BalanceAugLight injects AugLight;

function SetBeamLocation()
{
    Super.SetBeamLocation();
    if(CurrentLevel==0)// quick way to check that we're in a Halloween mode, or vanilla balance
        return;
    if( b1 == None || b2 == None )
        return;

    b1.LightRadius *= 2;
    b1.LightBrightness = 220; // default is 192
    b2.LightRadius = 8; // default is 4
    // white like a new high tech LED flashlight? little bit of blue like JC's eyes?
    b1.LightHue = 172;
    b2.LightHue = 172;
    b1.LightSaturation = 140; // default is 140
    b2.LightSaturation = 140; // default is 140
}

simulated function float GetEnergyRate()
{
    if(CurrentLevel>0) EnergyRate = 0;
    else EnergyRate = 20;
    return EnergyRate;
}

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    default.Description="Bioluminescent cells within the retina provide coherent illumination of the agent's field of view.";
    Description = default.Description;
    GetEnergyRate();// HACK: UpdateInfo function is still using the EnergyRate variable not the GetEnergyRate() function
}

function TravelPostAccept()
{
    Super.TravelPostAccept();
    GetEnergyRate();// HACK: UpdateInfo function is still using the EnergyRate variable not the GetEnergyRate() function
}

function bool IncLevel()
{
    Super.IncLevel();
    GetEnergyRate();// HACK: UpdateInfo function is still using the EnergyRate variable not the GetEnergyRate() function
}

function BeginPlay()
{
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        MaxLevel=1;
        EnergyRate = 0;
    } else {
        MaxLevel=0;
        EnergyRate = 20;
    }
    default.MaxLevel=MaxLevel;
    default.EnergyRate=EnergyRate;
    Super.BeginPlay();
}

defaultproperties
{
    EnergyRate=0
    LevelValues(0)=1024
    LevelValues(1)=1000
    MaxLevel=1
}
