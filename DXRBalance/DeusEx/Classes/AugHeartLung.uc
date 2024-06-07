class DXRAugHeartLung injects AugHeartLung;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    // description gets overwritten by language file, also DXRAugmentations reads from the default.Description
    default.Description = "This synthetic heart circulates not only blood but a steady concentration of mechanochemical power cells, smart phagocytes, and liposomes containing prefab diamondoid machine parts,"
                            $ " resulting in upgraded performance for all installed augmentations, but also increasing their energy use."
                            $ "|n|n<UNATCO OPS FILE NOTE JR133-VIOLET> However, this will not enhance any augmentation past its maximum upgrade level. -- Jaime Reyes <END NOTE>";
    Description = default.Description;
}

defaultproperties
{
    bAutomatic=true
    AutoLength=0
    AutoEnergyMult=1

    EnergyRate=0
    MaxLevel=3
    LevelValues(0)=2
    LevelValues(1)=1.75
    LevelValues(2)=1.5
    LevelValues(3)=1.25
}
