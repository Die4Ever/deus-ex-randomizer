#compileif injections
class DXRAugHeartLung injects AugHeartLung;

function UpdateBalance()
{
    if(bAutomatic) {
        Description = "This synthetic heart circulates not only blood but a steady concentration of mechanochemical power cells, smart phagocytes, and liposomes containing prefab diamondoid machine parts,"
                        $ " resulting in upgraded performance for all installed augmentations, but also increasing their energy use."
                        $ "|n|n<UNATCO OPS FILE NOTE JR133-VIOLET> ";
        MaxLevel=3;
        LevelValues[0]=2;
    } else {
        Description = "This synthetic heart circulates not only blood but a steady concentration of mechanochemical power cells, smart phagocytes, and liposomes containing prefab diamondoid machine parts,"
                        $ " resulting in upgraded performance for all installed augmentations."
                        $ "|n|n<UNATCO OPS FILE NOTE JR133-VIOLET> ";
        MaxLevel=0;
        LevelValues[0]=1;
    }
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        Description = Description $ "However, not all augmentations can be enhanced past their maximum upgrade level. -- Jaime Reyes <END NOTE>";
    } else {
        Description = Description $ "However, this will not enhance any augmentation past its maximum upgrade level. -- Jaime Reyes <END NOTE>|n|nNO UPGRADES";
    }
    default.Description = Description;
    default.MaxLevel = MaxLevel;
    default.LevelValues[0] = LevelValues[0];
}

function Deactivate()
{
    Super(Augmentation).Deactivate();

    Player.AugmentationSystem.BoostAugs(False, Self);
    //Player.AugmentationSystem.DeactivateAll();
}

defaultproperties
{
    bAutomatic=true
    AutoEnergyMult=0
    MaxLevel=3
    LevelValues(0)=2
    LevelValues(1)=1.75
    LevelValues(2)=1.5
    LevelValues(3)=1.25
}
