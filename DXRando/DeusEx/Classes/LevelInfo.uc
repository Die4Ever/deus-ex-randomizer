class DXRLevelInfo merges DeusExLevelInfo;
/* this refuses to work with the extends keyword, ucc make gives me the error
C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\DeusEx\Classes\DeusExLevelInfo.uc(4) : Error, DeusEx.DeusExLevelInfo's superclass must be Engine.Info, not DeusEx.DeusExLevelInfoBase
I'm guessing because of native bindings or something
as an alternative to injects, we use merges
*/

function SpawnScript()
{
    local DXRando dxr;
    local bool bFound;

    bFound = False;
    foreach AllActors(class'DXRando', dxr)
        bFound = True;
    
    if (!bFound) {
        dxr = Spawn(class'DXRando');
        dxr.SetdxInfo(Self);
    }

    _SpawnScript();
}
