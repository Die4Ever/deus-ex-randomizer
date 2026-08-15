#compileif gmdxae
class DXRMenuScreenPlaythroughModifiersGMDXAE extends MenuScreenPlaythroughModifiers;

//Remove some options from Rando, due to feature overlap, or just straight incompatibility
function BuildModifierList()
{
    //Remove randomization modifiers, that's kind of what we do
    RemoveItem("bRandomizeCrates");
    RemoveItem("bRandomizeMods");
    RemoveItem("bRandomizeAugs");
    RemoveItem("bRandomizeEnemies");

    //We just always let you access the console in rando, because it's good for debug
    //Use some self-restraint!
    RemoveItem("bDisableConsoleAccess");

    //We're always going to remove Paul's free weapon based on Randomizer modes
    //so we'll just hide this choice
    RemoveItem("bNoStartingWeaponChoices");

    //Randomized passwords/codes already kind of serve the purpose of anti-cheese
    //We'll hide this for now, maybe it can be brought back if there's demand?
    //(Theoretically this would prevent finding a datacube with a code, remembering
    //the code, then loading back)
    //We can actually probably support this pretty easily
    RemoveItem("iNoKeypadCheese");

    //Rando already has alternate starts for every mission,
    //so let's not do this for now.
    RemoveItem("bPrisonStart");

    Super.BuildModifierList();
}
