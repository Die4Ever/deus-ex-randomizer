class DXRSwapItems extends DXRActorsBase;

function FirstEntry()
{
    Super.FirstEntry();

    SwapAll('Inventory');
    SwapAll('Containers');
}
