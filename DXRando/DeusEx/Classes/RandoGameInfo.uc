class RandoGameInfo extends DeusExGameInfo config(DXRando);

var config class<PlayerPawn> allowed_class;
var config class<PlayerPawn> default_class;

event playerpawn Login
(
    string Portal,
    string Options,
    out string Error,
    class<playerpawn> SpawnClass
)
{
    if (!ApproveClass(SpawnClass))
    {
        SpawnClass=default_class;
    }

    log("RandoGameInfo Login "$SpawnClass);
    return Super.Login(Portal, Options, Error, SpawnClass);
}

function bool ApproveClass( class<playerpawn> SpawnClass)
{
    return ClassIsChildOf(SpawnClass, allowed_class);
}

defaultproperties
{
    allowed_class=class'Human'
    default_class=class'JCDentonMale'
}
