class DXRButtonBar extends PersonaButtonBarWindow;

event StyleChanged()
{
    local color c;
    Super.StyleChanged();

    c.A = 255;
    SetTileColor(c);
    SetBackgroundStyle(DSTY_Normal);
}

event DrawWindow(GC gc)
{
    local color c;
    c.A = 255;
    gc.SetTileColor(c);
    gc.SetStyle(DSTY_Normal);
    gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');
}

// ----------------------------------------------------------------------
// ConfigurationChanged()
//
// Determine placement of all our pretty buttons
// ----------------------------------------------------------------------

// DXRando: we copy pasted from PersonaButtonBarWindow
// but we replaced GetTopChild() with GetBottomChild() and GetLowerSibling() with GetHigherSibling()
// so that the buttons are no longer placed in reverse order

function ConfigurationChanged()
{
	local float qWidth, qHeight;
	local int leftX;
	local int numButtons;
	local int remainingSpace;
	local int buttonPadding;
	local Window winPlace;

	leftX      = 0;
	numButtons = 0;

	// Loop through all buttons and try to place them
	winPlace = GetBottomChild();
	while(winPlace != None)
	{
		if (winPlace.IsA('ButtonWindow'))
		{
			winPlace.QueryPreferredSize(qWidth, qHeight);

			if (!bFillAllSpace)
				winPlace.ConfigureChild(leftX, 0, qWidth, qHeight);

			numButtons++;

			leftX += qWidth;
		}

		winPlace = winPlace.GetHigherSibling();

		if ((winPlace != None) && (winPlace.IsA('ButtonWindow')))
			leftX += buttonSpacing;
	}

	// Now, if we need to make all the buttons an equal width
	if (bFillAllSpace)
	{
		remainingSpace = width - leftX;

		// Loop through the buttons again, adding "remaining space / #buttons"
		// width to each button

		leftX = 0;

		winPlace = GetBottomChild();
		while(winPlace != None)
		{
			if (winPlace.IsA('ButtonWindow'))
			{
				winPlace.QueryPreferredSize(qWidth, qHeight);

				buttonPadding = (remainingSpace / numButtons);
				qWidth += buttonPadding;

				winPlace.ConfigureChild(leftX, 0, qWidth, qHeight);

				leftX += qWidth;
			}

			winPlace = winPlace.GetHigherSibling();

			if ((winPlace != None) && (winPlace.IsA('ButtonWindow')))
				leftX += buttonSpacing;
		}
	}

	// Now calculate the position of the filler window
	winFiller.ConfigureChild(leftX, 0, width - leftX, height);
}
