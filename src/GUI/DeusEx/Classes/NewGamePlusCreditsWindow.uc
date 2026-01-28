#ifdef revision
class NewGamePlusCreditsWindow injects RevCreditsWindow;
#else
class NewGamePlusCreditsWindow injects CreditsWindow;
#endif

var float lastClickTime;

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
        if(f.moresettings.newgameplus_curve_scalar < 0) {
            return;
        }
        f.NewGamePlus();
        bLoadIntro=false;
        break;
    }
}

//Draw up to 3 columns across the screen
//  1 | 2 | 3
//     or
//    1 | 2
function PrintColumns(String colHeader[3], String colTxt[3])
{
    local AlignWindow winAlign;
    local HeaderedColumnWindow winColumn;
    local int i,numCols;

    winAlign = AlignWindow(winScroll.NewChild(Class'AlignWindow'));
    winAlign.SetWindowAlignments(HALIGN_Center, VALIGN_Top);
    winAlign.SetChildVAlignment(VALIGN_Top);

    numCols=0;
    if (colTxt[0]!="") numCols++;
    if (colTxt[1]!="") numCols++;
    if (colTxt[2]!="") numCols++;

    for (i=0;i<ArrayCount(colTxt);i++){
        if (colTxt[i]!=""){
            winColumn = HeaderedColumnWindow(winAlign.NewChild(Class'HeaderedColumnWindow'));
            winColumn.SetColumnWidth(maxTextWidth/numCols);
            winColumn.SetTitle(colHeader[i]);
            winColumn.SetText(colTxt[i]);
        }
    }
    winAlign.SetWidth(maxTextWidth);
}

//Draw 1 tall column and two stacked rows
//     | 2
//   1 |---
//     | 3
function PrintTeeColumns(String colHeader[3], String colTxt[3])
{
    local AlignWindow winAlign;
    local TileWindow  winTile;
    local HeaderedColumnWindow winColumn;

    winAlign = AlignWindow(winScroll.NewChild(Class'AlignWindow'));
    winAlign.SetWindowAlignments(HALIGN_Center, VALIGN_Center);
    winAlign.SetChildVAlignment(VALIGN_Center);

    winColumn = HeaderedColumnWindow(winAlign.NewChild(Class'HeaderedColumnWindow'));
    winColumn.SetColumnWidth(maxTextWidth/2);
    winColumn.SetTitle(colHeader[0]);
    winColumn.SetText(colTxt[0]);

    winTile = TileWindow(winAlign.NewChild(Class'TileWindow'));
    winTile.SetWindowAlignments(HALIGN_Center, VALIGN_Center);
    winTile.SetWidth(maxTextWidth/2);

    winColumn = HeaderedColumnWindow(winTile.NewChild(Class'HeaderedColumnWindow'));
    winColumn.SetColumnWidth(maxTextWidth/2);
    winColumn.SetTitle(colHeader[1]);
    winColumn.SetText(colTxt[1]);

    winColumn = HeaderedColumnWindow(winTile.NewChild(Class'HeaderedColumnWindow'));
    winColumn.SetColumnWidth(maxTextWidth/2);
    winColumn.SetTitle(colHeader[2]);
    winColumn.SetText(colTxt[2]);

    winAlign.SetWidth(maxTextWidth);
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
    PrintText("Press Escape or Double Click to exit");
    PrintLn();

    PrintHeader("Contributors");
    PrintText("Die4Ever");
    PrintText("TheAstropath");
    PrintText("Silverstrings");
    PrintText("MQDuck");

    PrintLn();
    PrintHeader("Home Page");
    PrintText("Mods4Ever.com");

    PrintLn();
    PrintHeader("Discord Community");
    PrintText("Mods4Ever.com/discord");

    PrintLn();
    PrintHeader("Special Thanks");
    PrintText("WCCC for the OpenAugTree");
    PrintText("Joe Wintergreen for the Lipsync fix");
    PrintText("Kentie for DeusExe Launcher and D3D10");
    PrintText("Deus_nsf for the tweaked D3D10 Renderer");
    PrintText("Han for Launchbox");
    PrintText("Chris Dohnal for D3D9 and OpenGL2 Renderers");
    PrintText("doitsujin for DXVK");
    PrintText("The Lay D Denton team");

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

event bool MouseButtonReleased(float pointX, float pointY, EInputKey button,
                               int numClicks)
{
    if(player == None || lastClickTime + 0.5 > player.Level.TimeSeconds) {
        FinishedScrolling();
    }
	else {
        lastClickTime = player.Level.TimeSeconds;
    }
	return True;
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
	}

	return False;
}

defaultproperties
{
     lastClickTime=-10
     currentScrollSpeed=100.0000
     scrollSpeed=100.0000
     minScrollSpeed=-600
     maxScrollSpeed=600
     speedAdjustment=15
     maxTileWidth=700
     maxTextWidth=700
     fontHeader=Font'DXRFontConversationLargeBold'
     fontText=Font'DXRFontConversationLarge'
}
