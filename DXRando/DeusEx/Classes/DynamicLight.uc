class DynamicLight extends Light;

function BaseChange()
{
    Super.BaseChange();
    if(Base==None) Destroy();
}

defaultproperties
{
    bStatic=false
    bNoDelete=false
    bMovable=true
}
