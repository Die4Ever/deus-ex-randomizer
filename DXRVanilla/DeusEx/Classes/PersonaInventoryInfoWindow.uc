class PersonaInventoryInfoWindow injects PersonaInventoryInfoWindow;

function AddAmmoInfoWindow(DeusExAmmo ammo, bool bShowDescriptions)
{
    local AlignWindow winAmmo;
    local PersonaNormalTextWindow winText;
    local Window winIcon;

    if (ammo != None)
    {
        winAmmo = AlignWindow(winTile.NewChild(Class'AlignWindow'));
        winAmmo.SetChildVAlignment(VALIGN_Top);
        winAmmo.SetChildSpacing(4);

        // Add icon
        winIcon = winAmmo.NewChild(Class'Window');
        winIcon.SetBackground(ammo.Icon);
        winIcon.SetBackgroundStyle(DSTY_Masked);
        winIcon.SetSize(42, 37);

        // Add description
        winText = PersonaNormalTextWindow(winAmmo.NewChild(Class'PersonaNormalTextWindow'));
        winText.SetWordWrap(True);
        winText.SetTextMargins(0, 0);
        winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);

        if (bShowDescriptions)
        {
            winText.SetText(ammo.itemName @ "(" $ AmmoRoundsLabel @ ammo.AmmoAmount $ " / " $ ammo.MaxAmmo $ ")|n|n");
            winText.AppendText(ammo.description);
        }
        else
        {
            winText.SetText(ammo.itemName $ "|n|n" $ AmmoRoundsLabel @ ammo.AmmoAmount $ " / " $ ammo.MaxAmmo);
        }
    }

    AddLine();
}
