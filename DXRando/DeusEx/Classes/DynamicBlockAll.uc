class DynamicBlockAll extends BlockAll;

simulated function BaseChange()
{
    Super.BaseChange();
    if (Base == None)
        Destroy();
}

defaultproperties
{
    bStatic=false
    bCollideWorld=false
}
