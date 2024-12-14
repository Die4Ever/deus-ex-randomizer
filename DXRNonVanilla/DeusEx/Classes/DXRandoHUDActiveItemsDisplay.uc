class DXRHUDActiveItemsDisplay extends HUDActiveItemsDisplay;

function CreateContainerWindows()
{
    winAugsContainer  = HUDActiveAugsBorder(NewChild(Class'HUDActiveAugsBorder'));
    winItemsContainer = HUDActiveItemsBorder(NewChild(Class'DXRHUDActiveItemsBorder'));
}
