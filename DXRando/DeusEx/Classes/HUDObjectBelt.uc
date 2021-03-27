class DXRHUDObjectBelt injects HUDObjectBelt;

function UpdateObjectText(int pos)
{
    local int i;

    //Update all belt texts (So that ammo counts are shown correctly)
    for (i=0; i<ArrayCount(objects); i++) {
        if(objects[i] != None) objects[i].UpdateItemText();
    }
}
