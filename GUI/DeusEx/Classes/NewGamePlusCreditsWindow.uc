class NewGamePlusCreditsWindow injects CreditsWindow;

event DestroyWindow()
{
    DoNewGamePlus();
    Super.DestroyWindow();
}

function DoNewGamePlus()
{
    local DXRFlags f;

    if (!bLoadIntro) return;

    foreach player.AllActors(class'DXRFlags', f) {
        f.NewGamePlus();
        bLoadIntro=false;
        break;
    }
}

function AddDXRCreditsGeneral()
{
    local Texture randoTextTextures[6];
    randoTextTextures[0]=Texture'RandomizerTextCredits1';
    randoTextTextures[1]=Texture'RandomizerTextCredits2';

    PrintPicture(randoTextTextures,2,1,512,64);
    PrintLn();
#ifdef gmdx
    PrintHeader("Deus Ex GMDX Randomizer");
#elseif vmd
    PrintHeader("Deus Ex Vanilla? Madder. Randomizer");
#elseif revision
    PrintHeader("Deus Ex: Revision Randomizer");
#elseif hx
    PrintHeader("Deus Ex HX Randomizer");
#else
    PrintHeader("Deus Ex Randomizer");
#endif
    PrintText("Version"@class'DXRVersion'.static.VersionString());
    PrintText("Hold the up arrow key to slow down or go backwards");
    PrintText("Hold the down arrow key to speed up");
    PrintText("Press Spacebar to pause/unpause");
    PrintLn();
    PrintHeader("Contributors");
    PrintText("Die4Ever");
    PrintText("TheAstropath");
    PrintText("Silverstrings");

    PrintLn();
    PrintHeader("Home Page");
    PrintText("Mods4Ever.com");

    PrintLn();
    PrintHeader("Discord Community");
    PrintText("Mods4Ever.com/discord");

    PrintLn();
    PrintLn();
}

function AddDXRandoCredits()
{
    local DXRBase mod;
    local DataStorage ds;

    AddDXRCreditsGeneral();

    foreach player.AllActors(class'DXRBase', mod) {
        mod.AddDXRCredits(Self);
    }

    PrintHeader("Original Developers");
    PrintLn();

    ds = class'DataStorage'.static.GetObjFromPlayer(player);
    if( ds != None ) ds.EndPlaythrough();
}

function ProcessText()
{
    PrintPicture(CreditsBannerTextures, 2, 1, 505, 75);
    PrintLn();
    AddDXRandoCredits();
    Super.ProcessText();
}

function Tick(float deltaTime)
{
	local float diff;

	if (bScrolling)
	{
		diff = currentScrollSpeed * deltaTime;

		if (diff != 0)
		{
			winScroll.SetPos(winScroll.x, winScroll.y - diff);

			// Check to see if we've finished scrolling
			if ((winScroll.y + winScroll.height) < 0)
			{
				bScrolling = False;
				FinishedScrolling();
            } else if (currentScrollSpeed<0 && winScroll.y > 300){
                winScroll.SetPos(winScroll.x, 300);
                currentScrollSpeed = 0;
            }
		}
	}
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	if ( IsKeyDown( IK_Alt ) || IsKeyDown( IK_Shift ) )
		return False;

	switch( key )
	{
		// Decrease print rate
		case IK_Down:
		case IK_Minus:
			if (currentScrollSpeed < maxScrollSpeed)
				currentScrollSpeed += speedAdjustment;
 			break;


		// Increase print rate
		case IK_Equals:
		case IK_Up:
			if (currentScrollSpeed > minScrollSpeed)
				currentScrollSpeed -= speedAdjustment;
			break;

		// Pause
		case IK_S:
			if (IsKeyDown(IK_Ctrl))
				bTickEnabled = False;
			break;

		case IK_Q:
			if (IsKeyDown(IK_Ctrl))
				bTickEnabled = True;
			break;

		case IK_Space:
			if (bTickEnabled)
				bTickEnabled = False;
			else
				bTickEnabled = True;
			break;

        case IK_Escape:
            player.PlaySound(Sound'DeusExSounds.Generic.Buzz1');// HACK TODO
            return True;
            break;
	}

	return False;
}

defaultproperties
{
     currentScrollSpeed=100.0000
     scrollSpeed=100.0000
     minScrollSpeed=-500
     maxScrollSpeed=500
     speedAdjustment=10
     maxTileWidth=700
     maxTextWidth=700
}
