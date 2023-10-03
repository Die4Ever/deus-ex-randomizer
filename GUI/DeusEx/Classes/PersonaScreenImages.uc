class DXRPersonaScreenImages injects PersonaScreenImages;

function ClearViewedImageFlags()
{
    local DataVaultImage image;
    local int listIndex;
    local int rowId;

    for(listIndex=0; listIndex<lstImages.GetNumRows(); listIndex++)
    {
        rowId = lstImages.IndexToRowId(listIndex);

        if (lstImages.GetFieldValue(rowId, 2) > 0)
        {
            image = DataVaultImage(lstImages.GetRowClientObject(rowId));
            MarkViewed(image);
        }
    }
}


function MarkViewed(DataVaultImage newImage)
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
}
