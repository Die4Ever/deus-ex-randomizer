#compileif gmdxae
class DXRPerkSystem extends PerkSystem;

//Overridden from the default PerkSystem function
function InitPerkObtained(Perk perkInstance)
{
    if (ShouldHidePerk(perkInstance.class)){
        perkInstance.bHidden=true;
    }
    if (ShouldImmediatelyInitPerk(perkInstance.class)){
        Super.InitPerkObtained(perkInstance);
    }
}



function bool ShouldHidePerk(class<Perk> perk)
{
    switch(perk){
        case class'PerkDataRecovery':
            return true;
    }
    return false;
}

//Some perks might need to wait to be initialized until after certain Rando modules load
function bool ShouldImmediatelyInitPerk(class<Perk> perk)
{
    switch(perk){
        case class'PerkBreakdown':
        case class'PerkDoorsman':
            //These should be initialized after DXRDoors runs (Which will run InitDoorPerks below)
            return false;
    }
    return true;
}

function InitPerkWithClass(class<Perk> perk)
{
    local Perk p;

    p = GetPerkWithClass(perk);
    if (p!=None && p.bPerkObtained) Super.InitPerkObtained(p);
}

//Convenience function for DXRDoors to run
function InitDoorPerks()
{
    InitPerkWithClass(class'PerkBreakdown');
    InitPerkWithClass(class'PerkDoorsman');
}
