class DXREarth injects #var(prefix)Earth;

#ifdef revision
//This class basically only exists to disable Revision Facelift,
//so that the MJ12 Lab globe doesn't look goofy after Memes
function bool Facelift(bool bOn)
{
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (dxr == None) {
        return Super.Facelift(bOn);
    }

    if (class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)){
        return False; //Disable when memes are enabled
    }

    //Otherwise facelift as appropriate
    return Super.Facelift(bOn);
}
#endif
