class AugStealth injects AugStealth;

state Active
{
Begin:
    ActivateBegin();
}

function ActivateBegin()
{
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        if(bIsActive) {
            Player.RunSilentValue = 0;
        }
    } else {
        Player.RunSilentValue = GetAugLevelValue();
        if ( Player.RunSilentValue == -1.0 )
            Player.RunSilentValue = 1.0;
    }
}

function UpdateBalance()
{
    local int i;
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        LevelValues[0] = 0.5;
        LevelValues[1] = 0.66;
        LevelValues[2] = 0.83;
        LevelValues[3] = 1;
        Level5Value = 1.2;
        EnergyRate = 50;
    } else {
        LevelValues[0] = 0.75;
        LevelValues[1] = 0.5;
        LevelValues[2] = 0.25;
        LevelValues[3] = 0;
        Level5Value = -1;
        EnergyRate = 40;
    }
    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
    default.Level5Value = Level5Value;
    default.EnergyRate = EnergyRate;

    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        Description = "The necessary muscle movements for complete silence when walking or running are determined continuously with reactive kinematics equations produced by embedded nanocomputers.";
        Description = Description $ "|n|nTECH ONE: Movement speed while moving silently is slightly increased."
            $ "|n|nTECH TWO: Movement speed while moving silently is moderately increased."
            $ "|n|nTECH THREE: Movement speed while moving silently is significantly increased."
            $ "|n|nTECH FOUR: An agent can now run at full speed silently.";
    } else {
        Description = "The necessary muscle movements for complete silence when walking or running are determined continuously with reactive kinematics equations produced by embedded nanocomputers.";
        Description = Description $ "|n|nTECH ONE: Sound made while moving is reduced slightly."
            $ "|n|nTECH TWO: Sound made while moving is reduced moderately."
            $ "|n|nTECH THREE: Sound made while moving is reduced significantly."
            $ "|n|nTECH FOUR: An agent is completely silent.";
    }
    default.Description = Description;
}

defaultproperties
{
    EnergyRate=40.000000
    LevelValues(0)=0.75
    LevelValues(1)=0.5
    LevelValues(2)=0.25
    LevelValues(3)=0
}
