class DXRPersonaScreenImages injects PersonaScreenImages;

function SetImage(DataVaultImage newImage)
{
	local string bingoName;
    local DXRando dxr;

    if (newImage!=None && newImage.bPlayerViewedImage==False){
        bingoName = newImage.imageDescription;
        bingoName = class'DXRInfo'.static.ReplaceText(bingoName," ","");
        bingoName = class'DXRInfo'.static.ReplaceText(bingoName,"-","");
        bingoName = class'DXRInfo'.static.ReplaceText(bingoName,":","");
        bingoName = class'DXRInfo'.static.ReplaceText(bingoName,",","");
        bingoName = "ImageOpened_"$bingoName;

        foreach newImage.AllActors(class'DXRando', dxr) {
            class'DXREvents'.static.MarkBingo(dxr,bingoName);
        }

        newImage.bPlayerViewedImage = True;
    }

    Super.SetImage(newImage);
}
