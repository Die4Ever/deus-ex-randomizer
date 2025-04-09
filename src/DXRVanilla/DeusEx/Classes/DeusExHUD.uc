class DXRandoHUD merges DeusExHUD;

var HUDEnergyDisplay  energy;
const infolink_and_logs_min_width=950; // 1920x1080 with 2x GUI scaling is 960 width

event InitWindow()
{
    _InitWindow();

    energy = HUDEnergyDisplay(NewChild(Class'HUDEnergyDisplay'));
}

event DescendantRemoved(Window descendant)
{
    _DescendantRemoved(descendant);

    if (descendant == energy){
        energy = None;
    }
}

function ConfigurationChanged()
{
    local float qWidth, qHeight;
    local float compassWidth, compassHeight;
    local float beltWidth, beltHeight;
    local float ammoWidth, ammoHeight;
    local float hitWidth, hitHeight;
    local float infoX, infoY, infoTop, infoBottom;
    local float infoWidth, infoHeight, maxInfoWidth, maxInfoHeight;
    local float itemsWidth, itemsHeight;
    local float damageWidth, damageHeight;
    local float conHeight;
    local float barkWidth, barkHeight;
    local float recWidth, recHeight, recPosY;

    //DXRando:
    local float energyWidth, energyHeight;
    local float infolinkWidth;

    if (ammo != None)
    {
        if (ammo.IsVisible())
        {
            ammo.QueryPreferredSize(ammoWidth, ammoHeight);
            ammo.ConfigureChild(0, height-ammoHeight, ammoWidth, ammoHeight);
        }
        else
        {
            ammoWidth  = 0;
            ammoHeight = 0;
        }
    }

    if (hit != None)
    {
        if (hit.IsVisible())
        {
            hit.QueryPreferredSize(hitWidth, hitHeight);
            hit.ConfigureChild(0, 0, hitWidth, hitHeight);
        }
    }

    // Stick the Compass directly under the Hit display
    if (compass != None)
    {
        compass.QueryPreferredSize(compassWidth, compassHeight);
        compass.ConfigureChild(0, hitHeight + 4, compassWidth, compassHeight);

        if (hitWidth == 0)
            hitWidth = compassWidth;
    }

    if (cross != None)
    {
        cross.QueryPreferredSize(qWidth, qHeight);
        cross.ConfigureChild((width-qWidth)*0.5+0.5, (height-qHeight)*0.5+0.5, qWidth, qHeight);
    }
    if (belt != None)
    {
        belt.QueryPreferredSize(beltWidth, beltHeight);
        belt.ConfigureChild(width - beltWidth, height - beltHeight, beltWidth, beltHeight);

        infoBottom = height - beltHeight;
    }
    else
    {
        infoBottom = height;
    }

    // Damage display
    //
    // Left side, under the compass

    if (damageDisplay != None)
    {
        // Doesn't check to see if it might bump into the Hit Display
        damageDisplay.QueryPreferredSize(damageWidth, damageHeight);
        damageDisplay.ConfigureChild(0, hitHeight + compassHeight + 4, damageWidth, damageHeight);
    }

    // Active Items, includes Augmentations and various charged Items
    //
    // Upper right corner

    if (activeItems != None)
    {
        itemsWidth = activeItems.QueryPreferredWidth(height - beltHeight);
        activeItems.ConfigureChild(width - itemsWidth, 0, itemsWidth, height - beltHeight);
    }

    // Display the infolink to the right of the hit display
    // and underneath the Log window if it's visible. (DXRando: actually no)
    if (infolink != None)
    {
        infolink.QueryPreferredSize(infolinkWidth, qHeight);

        if (msgLog != None && msgLog.IsVisible() && width < infolink_and_logs_min_width) // old yucky vanilla layout
            infolink.ConfigureChild(hitWidth + 20, msgLog.Height + 20, infolinkWidth, qHeight);
        else// DXRando: side-by-side infolink with logs
            infolink.ConfigureChild(hitWidth + 10, 0, infolinkWidth, qHeight);

        if (infolink.IsVisible())
            infoTop = max(infoTop, 10 + qHeight);
    }

    // Display the Log in the upper-left corner, to the right of
    // the hit display.

    if (msgLog != None && infolink != None && width >= infolink_and_logs_min_width)
    { // DXRando: side by side infolink and logs
        qHeight = msgLog.QueryPreferredHeight(width - hitWidth - itemsWidth - 0 - infolinkWidth);
        msgLog.ConfigureChild(hitWidth + 10 + infolinkWidth, 10, width - hitWidth - itemsWidth - 0 - infolinkWidth, qHeight);
    }
    else if (msgLog != None)
    {
        qHeight = msgLog.QueryPreferredHeight(width - hitWidth - itemsWidth - 40);
        msgLog.ConfigureChild(hitWidth + 20, 10, width - hitWidth - itemsWidth - 40, qHeight);
    }

    // First-person conversation window

    if (conWindow != None)
    {
        qWidth  = Min(width - 100, 800);
        conHeight = conWindow.QueryPreferredHeight(qWidth);

        // Stick it above the belt
        conWindow.ConfigureChild(
            (width / 2) - (qwidth / 2), (infoBottom - conHeight) - 20,
            qWidth, conHeight);
    }

    // Bark Display.  Position where first-person convo window would
    // go, or above it if the first-person convo is visible
    if (barkDisplay != None)
    {
        qWidth = Min(width - 100, 800);
        barkHeight = barkDisplay.QueryPreferredHeight(qWidth);

        barkDisplay.ConfigureChild(
            (width / 2) - (qwidth / 2), (infoBottom - barkHeight - conHeight) - 20,
            qWidth, barkHeight);
    }

    // Received Items display
    //
    // Stick below the crosshair, but above any bark/convo windows that might
    // be visible.

    if (receivedItems != None)
    {
        receivedItems.QueryPreferredSize(recWidth, recHeight);

        recPosY = (height / 2) + 20;

        if ((barkDisplay != None) && (barkDisplay.IsVisible()))
            recPosY -= barkHeight;
        if ((conWindow != None) && (conWindow.IsVisible()))
            recPosY -= conHeight;

        receivedItems.ConfigureChild(
            (width / 2) - (recWidth / 2), recPosY,
            recWidth, recHeight);
    }

    // Display the timer above the object belt if it's visible

    if (timer != None)
    {
        timer.QueryPreferredSize(qWidth, qHeight);

        if ((belt != None) && (belt.IsVisible()))
            timer.ConfigureChild(width-qWidth, height-qHeight-beltHeight-10, qWidth, qHeight);
        else
            timer.ConfigureChild(width-qWidth, height-qHeight, qWidth, qHeight);
    }

    // Mission Start Text
    if (startDisplay != None)
    {
        // Stick this baby right in the middle of the screen.
        startDisplay.QueryPreferredSize(qWidth, qHeight);
        startDisplay.ConfigureChild(
            (width / 2) - (qWidth / 2), (height / 2) - (qHeight / 2) - 75,
            qWidth, qHeight);
    }

    // Display the Info Window sandwiched between all the other windows.  :)

    if ((info != None) && (info.IsVisible(False)))
    {
        // Must redo these formulas
        maxInfoWidth  = Min(width - 170, 800);
        maxInfoHeight = (infoBottom - infoTop) - 20;

        info.QueryPreferredSize(infoWidth, infoHeight);

        if (infoWidth > maxInfoWidth)
        {
            infoHeight = info.QueryPreferredHeight(maxInfoWidth);
            infoWidth  = maxInfoWidth;
        }

        infoX = (width / 2) - (infoWidth / 2);
        infoY = infoTop + (((infoBottom - infoTop) / 2) - (infoHeight / 2)) + 10;

        info.ConfigureChild(infoX, infoY, infoWidth, infoHeight);
    }

    // DXRando: Put the energy display right under the compass
    if (energy != None)
    {
        energy.QueryPreferredSize(energyWidth, energyHeight);
        energy.ConfigureChild(0, hitHeight + compassHeight + 8, energyWidth, energyHeight);
    }
}


// ----------------------------------------------------------------------
// CreateInfoLinkWindow()
//
// Creates the InfoLink window used to display messages.  If a
// InfoLink window already exists, then return None.  If the Log window
// is visible, it hides it.
// ----------------------------------------------------------------------

function HUDInfoLinkDisplay CreateInfoLinkWindow()
{
    if ( infolink != None )
        return None;

    infolink = HUDInfoLinkDisplay(NewChild(Class'HUDInfoLinkDisplay'));

    // Hide Log window DXRando: or don't
    if (msgLog != None && width < infolink_and_logs_min_width)
        msgLog.Hide();

    infolink.AskParentForReconfigure();

    return infolink;
}

// ----------------------------------------------------------------------
// DestroyInfoLinkWindow()
// ----------------------------------------------------------------------

function DestroyInfoLinkWindow()
{
    if ( infoLink != None )
    {
        infoLink.Destroy();

        // If the msgLog window was visible, show it again
        if (msgLog != None && msgLog.MessagesWaiting()) {
            msgLog.Show();
        }
        if (msgLog != None && msgLog.IsVisible()) {// DXRando: reconfigure the window so the logs can be the proper width again
            msgLog.AskParentForReconfigure();
        }
    }
}

function PartialShow(bool bShow)
{
    if(!bShow) { // UpdateSettings should take care of most of these showing again
        if(belt!=None) belt.Show(bShow);
        if(receivedItems!=None) receivedItems.Show(bShow);
        if(startDisplay!=None) startDisplay.Show(bShow);
    }
    if(msgLog!=None) msgLog.Show(bShow);
    if(infolink!=None) infolink.Show(bShow);
}
