class DXRMerchantTelemetryTrigger extends DXRTelemetryTrigger;

function string GetTelemMessage()
{
    local DXRando dxr;
    local int numCredits;

    dxr = class'DXRando'.default.dxr;
    numCredits=-1;

    if (dxr!=None){
        if (dxr.Player!=None){
            numCredits=dxr.Player.Credits;
        }
    }

    return class'DXRInfo'.static.ReplaceText(telemMsg,"__CURPLAYERCREDITS__",string(numCredits));

}
