class DXRHUDObjectBelt injects HUDObjectBelt;

function UpdateObjectText(int pos)
{
    local int i;

    //Update all belt texts (So that ammo counts are shown correctly)
    for (i=0;i<10;i++) {
        objects[i].UpdateItemText();
    }
}
