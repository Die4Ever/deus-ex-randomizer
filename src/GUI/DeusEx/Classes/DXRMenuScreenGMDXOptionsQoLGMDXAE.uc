#compileif gmdxae
class DXRMenuScreenGMDXOptionsQoLGMDXAE extends MenuScreenGMDXOptionsQoL;

function BuildModifierList()
{
    //This *works*, but it only consumes the unrandomized skill points when
    //auto-upgraded, so you can downgrade and have more starting skill points
    //than normal.  Probably fixable, but let's just disable it for now.
    RemoveItem("bPistolStartTrained");

    Super.BuildModifierList();

    //Theoretically the Super should probably be calling this
    CreateChoices();
}

//Hopefully this will be patched upstream soon (Or handled in some other way to call this?)
event InitWindow()
{
    Super.InitWindow();

    //This should probably be getting called normally???
    BuildModifierList();

}

defaultproperties
{
    items(71)=(defaultValue=0) //bPistolStartTrained, defaulted off in Rando
}
