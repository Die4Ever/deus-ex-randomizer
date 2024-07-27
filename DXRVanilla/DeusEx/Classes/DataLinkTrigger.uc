class DXRDataLinkTrigger injects DataLinkTrigger;

var bool bImportant;// currently only marked by DXRMissions, maybe later also by DXRFixups

function bool EvaluateFlag()
{
    local bool ret;

    ret = Super.EvaluateFlag();

    if(ret && player != None && player.dataLinkPlay != None && bImportant) {
        player.dataLinkPlay.FastForward();
    }
    return ret;
}
