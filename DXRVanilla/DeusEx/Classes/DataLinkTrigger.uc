class DXRDataLinkTrigger injects DataLinkTrigger;

var bool bImportant;// currently only marked by DXRMissions, maybe later also by DXRFixups
var transient Conversation conv;

function bool EvaluateFlag()
{
    local bool ret;

    ret = Super.EvaluateFlag();

    if(ret && player != None && bImportant && CheckConversationFlags()) {
        if(player.dataLinkPlay != None) {
            player.dataLinkPlay.FastForward();
        }
        bImportant = false;
    }
    return ret;
}

function bool CheckConversationFlags()
{
    if(conv == None) {
        foreach AllObjects(class'Conversation', conv) {
            if(conv.conName == datalinkTag) break;
        }
    }
    if(conv == None) return true;

    return player.CheckFlagRefs(conv.flagRefList);
}
