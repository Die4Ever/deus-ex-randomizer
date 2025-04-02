//=============================================================================
// OATMenuAugsSelector. Lightweight and to the point, I'd hope.
//=============================================================================
class OATMenuAugsSelector expands MenuUIWindow;

//OAT, 8/26/23: I get really damn tired of having to define 2x as many default properties.
struct OATButtonPos {
	var int X;
	var int Y;
};

//OAT, 8/26/23: Aug tree time!
//
//Here's the rundown:
//-We have 2 pages, 5 augs each, for 10 augs total.
//-Toggle between 0 and 1 for CurPage, for 1 and 2.
//-Store all 10 augs at once, sorted by hotkeynum - 3 (F3-F12 becomes 0-9)
//-Merely update which 5 augs are on our 5 buttons as we go.
var int CurPage, SelectedAug;
var Texture PageIcons[2];
var OATButtonPos HighlighterOffset, PageLabelPos[2], AugButtonPos[7];

var localized string StrNextPage, StrLastPage, StrCloseWindow, StrAugLevel;
var string CurAugName;
var OATButtonPos AugNameLabelPos, AugNameLabelSize;
var MenuUILabelWindow AugNameLabel;

var localized string StrReload;
var OATButtonPos EnergyBarPos, EnergyBarMaxSize, EnergyCasePos, EnergyCaseSize, BiocellPos,
			BioEnergyLabelPos, BioEnergyLabelSize, BioCellCountLabelPos, BioCellCountLabelSize, ReloadTipLabelPos, ReloadTipLabelSize;
var Window EnergyBar, EnergyCase;
var OATAugSelectorCellIcon CellIcon;
var MenuUILabelWindow BioEnergyLabel, BioCellCountLabel, ReloadTipLabel;
var Color ColBioBar, ColNoCells, ColHasCells;

var bool bShowPercent;

var Augmentation Augs[10];
var BioelectricCell BioCell;
var MenuUIHeaderWindow PageLabels[2];
var OATAugSelectorButton AugButtons[5];
var OATAugSelectorPageButton AugPage, ExitButton;
var OATAugSelectorHighlight Highlighter;

//OAT, 8/27/23: We can now read all our inputs dynamically. Yay. Good suggestion from HawkBird.
var EInputKey MenuValues1[9], MenuValues2[9], MenuValues3[9], HackKey,
		LeftKey[3], RightKey[3], UpKey[3], DownKey[3], FireKey[6], JumpKey[3], AugMenuKey[4],
		RechargeKey[3];

var string AliasNames[9];

var Mutator LastMutator; //OAT, 1/12/24: Not always useful, depending which method you used.

event StyleChanged()
{
	local bool bTranslucent;
	local ColorTheme theme;
	
	Super.StyleChanged();
	
	theme = player.ThemeManager.GetCurrentHUDColorTheme();
	
	AugNameLabel.ColLabel = theme.GetColorFromName('HUDColor_ButtonTextNormal');
	AugNameLabel.SetTextColor(AugNameLabel.ColLabel);
	
	BioEnergyLabel.ColLabel = theme.GetColorFromName('HUDColor_ButtonTextNormal');
	BioEnergyLabel.SetTextColor(BioEnergyLabel.ColLabel);
	
	ReloadTipLabel.ColLabel = theme.GetColorFromName('HUDColor_ButtonTextNormal');
	ReloadTipLabel.SetTextColor(ReloadTipLabel.ColLabel);
	
	//bTranslucent = player.GetMenuTranslucency();
	bTranslucent = False; //This is a case. It shouldn't be transparent, due to the corners of the bar.
	
	if (bTranslucent)
	{
		EnergyCase.SetBackgroundStyle(DSTY_Translucent);
	}
	else
	{
		EnergyCase.SetBackgroundStyle(DSTY_Masked);
	}
	EnergyCase.SetTileColor(Theme.GetColorFromName('HUDColor_Background'));
}

//OAT, 8/26/23: One last hack from beyond the grave: Update our colors to menu type. Thanks.
function CreateClientWindow()
{
	local int clientIndex, titleOffsetX, titleOffsetY;
	local ColorTheme theme;
	
	winClient = MenuUIClientWindow(NewChild(class'MenuUIClientWindow'));
	
	winTitle.GetOffsetWidths(titleOffsetX, titleOffsetY);
	
	winClient.SetSize(clientWidth, clientHeight);
	winClient.SetTextureLayout(textureCols, textureRows);
	
	// Set background textures
	for(clientIndex=0; clientIndex<arrayCount(clientTextures); clientIndex++)
	{
		winClient.SetClientTexture(clientIndex, clientTextures[clientIndex]);
	}
	
	// Translucency
	if (Player.GetHUDBackgroundTranslucency())
	{
		WinClient.BackgroundDrawStyle = DSTY_Translucent;
	}
	else
	{
		WinClient.BackgroundDrawStyle = DSTY_Masked;
	}
	
	Theme = Player.ThemeManager.GetCurrentHUDColorTheme();
	WinClient.ColBackground = Theme.GetColorFromName('HUDColor_Background');
}

function ActivateAugmentation(Augmentation TargetAug)
{
	local int i;
	
	if ((TargetAug != None) && (Player != None) && (Player.AugmentationSystem != None))
	{
		Player.AugmentationSystem.ActivateAugByKey(TargetAug.HotkeyNum - 3);
		for (i=0; i<ArrayCount(AugButtons); i++)
		{
			AugButtons[i].UpdateAugColor();
		}
	}
}

function LoadAugPage(int PageNum)
{
	local int i, HackAdd;
	
	//OAT: Default to cycling page again.
	SelectedAug = 5;
	
	CurPage = PageNum;
	
	//OAT, 8/26/23: WARNING! EVIL, EVIL HACK! Line up our 1 as close to the slash as our 2.
	//Not sure why alignments didn't work, so aight, fuck it. Negotiations failed.
	if (CurPage == 0) HackAdd = 4;
	PageLabels[0].SetText( string(CurPage+1) );
	PageLabels[0].SetPos(PageLabelPos[0].X+HackAdd, PageLabelPos[0].Y);
	
	for (i=0; i<ArrayCount(AugButtons); i++)
	{
		AugButtons[i].SetAugmentation( Augs[i+(CurPage*5)] );
	}
	AugPage.SetFakeIcon(PageIcons[CurPage]);
	PlaySound(Sound'Menu_OK', 1.0);
	
	UpdateHighlighterPos();
}

function UpdateHighlighterPos()
{
	Highlighter.SetPos(AugButtonPos[SelectedAug].X + HighlighterOffset.X, AugButtonPos[SelectedAug].Y + HighlighterOffset.Y);
	
	CurAugName = "";
	switch(SelectedAug)
	{
		case 0:
			if (CurPage == 0)
			{
				if (Augs[0] != None)
				{
					CurAugName = Augs[0].AugmentationName$CR()$SprintF(StrAugLevel, Augs[0].CurrentLevel+1);
				}
			}
			else
			{
				if (Augs[5] != None)
				{
					CurAugName = Augs[5].AugmentationName$CR()$SprintF(StrAugLevel, Augs[5].CurrentLevel+1);
				}
			}
		break;
		case 1:
			if (CurPage == 0)
			{
				if (Augs[1] != None)
				{
					CurAugName = Augs[1].AugmentationName$CR()$SprintF(StrAugLevel, Augs[1].CurrentLevel+1);
				}
			}
			else
			{
				if (Augs[6] != None)
				{
					CurAugName = Augs[6].AugmentationName$CR()$SprintF(StrAugLevel, Augs[6].CurrentLevel+1);
				}
			}
		break;
		case 2:
			if (CurPage == 0)
			{
				if (Augs[2] != None)
				{
					CurAugName = Augs[2].AugmentationName$CR()$SprintF(StrAugLevel, Augs[2].CurrentLevel+1);
				}
			}
			else
			{
				if (Augs[7] != None)
				{
					CurAugName = Augs[7].AugmentationName$CR()$SprintF(StrAugLevel, Augs[7].CurrentLevel+1);
				}
			}
		break;
		case 3:
			if (CurPage == 0)
			{
				if (Augs[3] != None)
				{
					CurAugName = Augs[3].AugmentationName$CR()$SprintF(StrAugLevel, Augs[3].CurrentLevel+1);
				}
			}
			else
			{
				if (Augs[8] != None)
				{
					CurAugName = Augs[8].AugmentationName$CR()$SprintF(StrAugLevel, Augs[8].CurrentLevel+1);
				}
			}
		break;
		case 4:
			if (CurPage == 0)
			{
				if (Augs[4] != None)
				{
					CurAugName = Augs[4].AugmentationName$CR()$SprintF(StrAugLevel, Augs[4].CurrentLevel+1);
				}
			}
			else
			{
				if (Augs[9] != None)
				{
					CurAugName = Augs[9].AugmentationName$CR()$SprintF(StrAugLevel, Augs[9].CurrentLevel+1);
				}
			}
		break;
		case 5:
			if (CurPage == 0)
			{
				CurAugName = StrNextPage;
			}
			else
			{
				CurAugName = StrLastPage;
			}
		break;
		case 6:
			CurAugName = StrCloseWindow;
		break;
	}
	
	AugNameLabel.SetText(CurAugName);
}

//OAT, 8/26/23: If you're wondering why not just pop window, it's because sometimes code
//is still executing by the time we do, which crashes the game. This offsets these by at least a frame,
//even with god awful PC FPS.
//----------------------------
//OAT: Forgot to mention, if it seems I'm paranoid, I've found whether something crashes on normal pop
//sometimes depends on how much load the machine is already under. This removes execution speed dependency.
function ForcePopWindow()
{
	Root.PopWindow();
}

function InitWindow()
{
	Super.InitWindow();	
	
	//OAT, 8/26/23: Hide our title bar. We are very cool and minimalist UI. We're hip.
	if (WinTitle != None)
	{
	 	WinTitle.Show(False);
	 	WinTitle = None;
	}
	
	//OAT, 2/25/25: Small patch for real time UI support.
	AddTimer(0.1, True,, 'UpdateInfo');
}

function CreateControls()
{
	local bool bHadFirstFive;
	local int i;
	local Augmentation TAug;
	local ColorTheme Theme;
	
	Super.CreateControls();
	
	BuildKeyBindings(); //8/27/23: We can now read inputs as they are mapped in real time. Yay.
	
	//OAT, 2/25/25: For later reference and use.
	BioCell = BioelectricCell(Player.FindInventoryType(Class'BioelectricCell'));
	
	if ((Player != None) && (Player.AugmentationSystem != None))
	{
		for(TAug = Player.AugmentationSystem.FirstAug; TAug != None; TAug = TAug.Next)
		{
			if ((TAug.bHasIt) && (!TAug.bAlwaysActive) && (TAug.HotkeyNum > 2) && (TAug.HotkeyNum < 13))
			{
				if (TAug.HotkeyNum < 8) bHadFirstFive = true;
				
				Augs[TAug.HotKeyNum-3] = TAug;
			}
		}
		
		Theme = Player.ThemeManager.GetCurrentHUDColorTheme();
		for (i=0; i<ArrayCount(PageLabels); i++)
		{
 			PageLabels[i] = CreateMenuHeader(PageLabelPos[i].X, PageLabelPos[i].Y, string(i+1), Self);
			PageLabels[i].SetSize(48, 48);
 			PageLabels[i].SetFont(Font'FontMenuHeaders_DS');
 			PageLabels[i].SetTextAlignments(HALIGN_Left, VALIGN_Top);
 			PageLabels[i].SetWindowAlignments(HALIGN_Right, VALIGN_Full, 0, 0, 0, 0);
			PageLabels[i].SetPos(PageLabelPos[i].X, PageLabelPos[i].Y);
			
			// Title colors
			PageLabels[i].ColLabel = Theme.GetColorFromName('HUDColor_ListText');
			PageLabels[i].SetTextColor(PageLabels[i].ColLabel);
		}
		
		for (i=0; i<ArrayCount(AugButtons); i++)
		{
			AugButtons[i] = OATAugSelectorButton(NewChild(class'OATAugSelectorButton'));
			AugButtons[i].SetPos(AugButtonPos[i].X, AugButtonPos[i].Y);
			AugButtons[i].SetSensitivity(False);
			
			//OAT: Don't bother setting augs here. We'll load the page later.
		}
		
		AugPage = OATAugSelectorPageButton(NewChild(class'OATAugSelectorPageButton'));
		AugPage.SetPos(AugButtonPos[5].X, AugButtonPos[5].Y);
		AugPage.SetSensitivity(False);
		
		//OAT: Adding this a bit late, but it's fine. We can just reuse it with no issues.
		ExitButton = OATAugSelectorPageButton(NewChild(class'OATAugSelectorPageButton'));
		ExitButton.SetPos(AugButtonPos[6].X, AugButtonPos[6].Y);
		ExitButton.SetFakeIcon(Texture'OATCloseAugPageIcon');
		ExitButton.SetSensitivity(False);
		
		//OAT: Select down button for fast cycling.
		Highlighter = OATAugSelectorHighlight(NewChild(class'OATAugSelectorHighlight'));
		Highlighter.SetSensitivity(False);
		
		//OAT, 3/12/25: Turns out anchoring to self instead of WinClient fixes centering. My god. What treason.
		AugNameLabel = CreateMenuLabel(AugNameLabelPos.X, AugNameLabelPos.Y, "", Self);
		AugNameLabel.SetSize(AugNameLabelSize.X, AugNameLabelSize.Y);
		AugNameLabel.SetPos(AugNameLabelPos.X, AugNameLabelPos.Y);
		AugNameLabel.SetTextAlignments(HALIGN_Center, AugNameLabel.VAlign);
		
		//OAT: If we don't have any augs except flashlight or some bullshit, start on page 2, of course.
		LoadAugPage(1 - int(bHadFirstFive));
		
		CellIcon = OATAugSelectorCellIcon(NewChild(class'OATAugSelectorCellIcon'));
		CellIcon.SetPos(BiocellPos.X, BiocellPos.Y);
		
		EnergyBar = NewChild(class'Window');
		EnergyBar.SetBackground(Texture'Nano_SFX_A');
		EnergyBar.SetTileColor(ColBioBar);
		
		EnergyCase = NewChild(class'Window');
		EnergyCase.SetSize(EnergyCaseSize.X, EnergyCaseSize.Y);
		EnergyCase.SetPos(EnergyCasePos.X, EnergyCasePos.Y);
		EnergyCase.SetBackground(Texture'OATAugControllerMenuEnergyCase');
		
		BioEnergyLabel = CreateMenuLabel(BioEnergyLabelPos.X, BioEnergyLabelPos.Y, "", Self);
		BioEnergyLabel.SetSize(BioEnergyLabelSize.X, BioEnergyLabelSize.Y);
		BioEnergyLabel.SetPos(BioEnergyLabelPos.X, BioEnergyLabelPos.Y);
		BioEnergyLabel.SetTextAlignments(HALIGN_Center, BioEnergyLabel.VAlign);
		
		BioCellCountLabel = CreateMenuLabel(BioCellCountLabelPos.X, BioCellCountLabelPos.Y, "", Self);
		BioCellCountLabel.SetSize(BioCellCountLabelSize.X, BioCellCountLabelSize.Y);
		BioCellCountLabel.SetPos(BioCellCountLabelPos.X, BioCellCountLabelPos.Y);
		BioCellCountLabel.SetTextAlignments(HALIGN_Right, BioEnergyLabel.VAlign);
		
		ReloadTipLabel = CreateMenuLabel(ReloadTipLabelPos.X, ReloadTipLabelPos.Y, StrReload, Self);
		ReloadTipLabel.SetSize(ReloadTipLabelSize.X, ReloadTipLabelSize.Y);
		ReloadTipLabel.SetPos(ReloadTipLabelPos.X, ReloadTipLabelPos.Y);
		
		UpdateEnergyBar();
	}
	else
	{
		Log("AUG TREE WARNING: Failed to find deus ex player or aug system.");
	}
}

function UpdateInfo()
{
	local int i;
	
	//OAT, 2/25/25: Update for real time UI in case augs go out.
	for (i=0; i<ArrayCount(AugButtons); i++)
	{
		AugButtons[i].UpdateAugColor();
	}
	
	UpdateEnergyBar();
}

function UpdateEnergyBar()
{
	local int IPer;
	local float GetEn, MaxEn, FFull, FPer;
	
	GetEn = Player.Energy;
	MaxEn = Player.EnergyMax;
	
	FFull = GetEn / MaxEn;
	FPer = (FFull * 100.0) + 0.99;
	IPer = int(FPer);
	
	if (bShowPercent)
	{
		BioEnergyLabel.SetText(IPer$"%");
	}
	else
	{
		BioEnergyLabel.SetText(int(GetEn)$"/"$int(MaxEn));
	}
	
	EnergyBar.SetSize(EnergyBarMaxSize.X, (EnergyBarMaxSize.Y * FFull) + 1);
	EnergyBar.SetPos(EnergyBarPos.X, EnergyBarPos.Y + (EnergyBarMaxSize.Y * (1.0 - FFull)));
	
	BioCellCountLabel.SetText("x0");
	CellIcon.SetTileColor(ColNoCells);
	if ((BioCell != None) && (!BioCell.bDeleteMe) && (BioCell.NumCopies > 0))
	{
		BioCellCountLabel.SetText("x"$BioCell.NumCopies);
		CellIcon.SetTileColor(ColHasCells);
	}
}

function BuildKeyBindings()
{
	local int i, j, UsePos, Pos, Pos2;
	local string KeyName, Alias;
	
	// First, clear all the existing keybinding display 
	// strings in the MenuValues[1|2|3] arrays
	for(i=0; i<arrayCount(MenuValues1); i++)
	{
		MenuValues1[i] = IK_None;
		MenuValues2[i] = IK_None;
		MenuValues3[i] = IK_None;
	}
	
	// Now loop through all the keynames and generate
	// human-readable versions of keys that are mapped.
	for ( i=0; i<255; i++ )
	{
		KeyName = player.ConsoleCommand ( "KEYNAME "$i );
		if ( KeyName != "" )
		{
			Alias = player.ConsoleCommand( "KEYBINDING "$KeyName );
			if ( Alias != "" )
			{
				//OAT, 1/12/24: Fix for mutate commands not closing the window.
				if (InStr(CAPS(Alias), "MUTATE") == -1)
				{
					Pos = InStr(Alias, " " );
				}
				else
				{
					Pos = -1;
				}
				Pos2 = InStr(Alias, "|"); //OAT, read muticommands' primary purpose.
				
				UsePos = Pos;
				if (Pos == -1 || (Pos2 > -1 && Pos2 < Pos))
				{
					UsePos = Pos2;
				}
				if (UsePos != -1)
				{
					Alias = Left(Alias, UsePos);
				}
				
				for ( j=0; j<arrayCount(AliasNames); j++ )
				{
					if ( AliasNames[j] ~= Alias )
					{
						//OAT, 8/27/23: Both int and GetEnum tell me type mismatch.
						//Suck on my SetPropertyText, nerd.
						SetPropertyText( "HackKey", string(GetEnum(enum'EInputKey', i)) );
						
						if (MenuValues1[j] == IK_None)
						{
							MenuValues1[j] = HackKey;
						}
						else if (MenuValues2[j] == IK_None)
						{
							MenuValues2[j] = HackKey;
						}
						else if (MenuValues3[j] == IK_None)
						{
							MenuValues3[j] = HackKey;
						}
					}
				}
			}
		}
	}
	
	//OAT: Plug in all our values now.
	LeftKey[0] = MenuValues1[4];
	LeftKey[1] = MenuValues2[4];
	LeftKey[2] = MenuValues3[4];
	RightKey[0] = MenuValues1[5];
	RightKey[1] = MenuValues2[5];
	RightKey[2] = MenuValues3[5];
	UpKey[0] = MenuValues1[2];
	UpKey[1] = MenuValues2[2];
	UpKey[2] = MenuValues3[2];
	DownKey[0] = MenuValues1[3];
	DownKey[1] = MenuValues2[3];
	DownKey[2] = MenuValues3[3];
	FireKey[0] = MenuValues1[0];
	FireKey[1] = MenuValues2[0];
	FireKey[2] = MenuValues3[0];
	FireKey[3] = MenuValues1[1];
	FireKey[4] = MenuValues2[1];
	FireKey[5] = MenuValues3[1];
	JumpKey[0] = MenuValues1[6];
	JumpKey[1] = MenuValues2[6];
	JumpKey[2] = MenuValues3[6];
	AugMenuKey[0] = MenuValues1[7];
	AugMenuKey[1] = MenuValues2[7];
	AugMenuKey[2] = MenuValues3[7];
	RechargeKey[0] = MenuValues1[8];
	RechargeKey[1] = MenuValues2[8];
	RechargeKey[2] = MenuValues3[8];
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local int i;
	
	bHandled = True;
	
	Super.ButtonActivated(buttonPressed);
	
	switch(ButtonPressed)
	{
		default:
			bHandled = False;
		break;
	}
	
	for (i=0; i<ArrayCount(AugButtons); i++)
	{
		if (ButtonPressed == AugButtons[i])
		{
			SelectedAug = i;
			UpdateHighlighterPos();
			ActivateAugmentation( Augs[i+(CurPage*5)] );
			break;
		}
	}
	
	return bHandled;
}

event bool VirtualKeyPressed(EInputKey Key, bool bRepeat)
{
	local int IdealMove, LastSelectedAug;
	
	LastSelectedAug = SelectedAug;
	IdealMove = -1;
	switch(Key)
	{
		case UpKey[0]:
		case UpKey[1]:
		case UpKey[2]:
			IdealMove = 2;
		break;
		case DownKey[0]:
		case DownKey[1]:
		case DownKey[2]:
			IdealMove = 5;
		break;
		case LeftKey[0]:
		case LeftKey[1]:
		case LeftKey[2]:
			IdealMove = 0;
		break;
		case RightKey[0]:
		case RightKey[1]:
		case RightKey[2]:
			IdealMove = 4;
		break;
		case FireKey[0]:
		case FireKey[1]:
		case FireKey[2]:
		case FireKey[3]:
		case FireKey[4]:
		case FireKey[5]:
		case JumpKey[0]:
		case JumpKey[1]:
		case JumpKey[2]:
			if (SelectedAug == 6)
			{
				if (LastMutator != None)
				{
					LastMutator.SetPropertyText("LastBrowsedAugPage", string(CurPage));
					LastMutator.SetPropertyText("LastBrowsedAug", string(SelectedAug));
				}
				else
				{
					Player.SetPropertyText("LastBrowsedAugPage", string(CurPage));
					Player.SetPropertyText("LastBrowsedAug", string(SelectedAug));
				}
				PlaySound(Sound'Menu_OK', 1.0);
				AddTimer(0.1, False,, 'ForcePopWindow');
			}
			else if (SelectedAug == 5) //Down button cycles page.
			{
				LoadAugPage( (CurPage+1) % 2 );
			}
			else //Otherwise, activate the aug in question.
			{
				ActivateAugmentation( Augs[SelectedAug+(CurPage*5)] );
			}
		break;
		//case IK_Escape:
		case AugMenuKey[0]:
		case AugMenuKey[1]:
		case AugMenuKey[2]:
		case AugMenuKey[3]:
			if (LastMutator != None)
			{
				LastMutator.SetPropertyText("LastBrowsedAugPage", string(CurPage));
				LastMutator.SetPropertyText("LastBrowsedAug", string(SelectedAug));
			}
			else
			{
				Player.SetPropertyText("LastBrowsedAugPage", string(CurPage));
				Player.SetPropertyText("LastBrowsedAug", string(SelectedAug));
			}
			
			PlaySound(Sound'Menu_OK', 1.0);
			AddTimer(0.1, False,, 'ForcePopWindow');
			return true;
		break;
		case RechargeKey[0]:
		case RechargeKey[1]:
		case RechargeKey[2]:
			UseCell();
			return true;
		break;
	}
	
	if (IdealMove > -1)
	{
		switch(IdealMove)
		{
			case 0: //OAT: Left. If we have up selected, go to upper left instead.
				if (SelectedAug == 2)
				{
					SelectedAug = 1;
				}
				else
				{
					SelectedAug = IdealMove;
				}
			break;
			case 2: //OAT: Up. If we have left or right selected, go to a diagonal instead.
				if (SelectedAug == 0)
				{
					SelectedAug = 1;
				}
				else if (SelectedAug == 4)
				{
					SelectedAug = 3;
				}
				else
				{
					SelectedAug = IdealMove;
				}
			break;
			case 4: //OAT: Right. If we have up selected, go to upper right instead.
				if (SelectedAug == 2)
				{
					SelectedAug = 3;
				}
				else
				{
					SelectedAug = IdealMove;
				}
			break;
			case 5: //OAT: Down. If already down, go down further. Otherwise go to the first down slot.
				if (SelectedAug == 5)
				{
					SelectedAug = 6;
				}
				else
				{
					SelectedAug = IdealMove;
				}
			break;
		}
		UpdateHighlighterPos();
	}
	
	if (LastSelectedAug != SelectedAug)
	{
		PlaySound(Sound'Menu_Press', 1.0);
	}
	
 	return True;
}

function UseCell()
{
	if ((BioCell != None) && (!BioCell.bDeleteMe) && (BioCell.NumCopies > 0))
	{
		BioCell.Activate();
	}
	
	UpdateEnergyBar();
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
 	return false; // don't handle
}

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button, int numClicks)
{
	VirtualKeyPressed(Button, false); //OAT: Massive hack. Check mouse buttons how we check all buttons.
	
	return false;
}

event bool RawMouseButtonPressed(float pointX, float pointY, EInputKey button, EInputState iState)
{
	return false; // don't handle
}

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
 	return false;
}

function bool CanStack()
{
 	return false;
}

defaultproperties
{
     AugNameLabelPos=(X=0,Y=246)
     AugNameLabelSize=(X=186,Y=24)
     StrNextPage="Next Page"
     StrLastPage="Prev. Page"
     StrCloseWindow="Close menu"
     StrAugLevel="(Lvl %d)"
     
     PageIcons(0)=Texture'OATNextAugPageIcon'
     PageIcons(1)=Texture'OATPrevAugPageIcon'
     HighlighterOffset=(X=-3,Y=-3)
     PageLabelPos(0)=(X=136,Y=136)
     PageLabelPos(1)=(X=146,Y=145)
     AugButtonPos(0)=(X=3,Y=75)
     AugButtonPos(1)=(X=19,Y=19)
     AugButtonPos(2)=(X=75,Y=3)
     AugButtonPos(3)=(X=131,Y=19)
     AugButtonPos(4)=(X=147,Y=75)
     AugButtonPos(5)=(X=75,Y=147)
     AugButtonPos(6)=(X=75,Y=195)
     
     StrReload="Reload"
     EnergyBarPos=(X=217,Y=54)
     EnergyBarMaxSize=(X=12,Y=78)
     EnergyCasePos=(X=212,Y=49)
     EnergyCaseSize=(X=22,Y=88)
     BiocellPos=(X=206,Y=145)
     BioEnergyLabelPos=(X=188,Y=30)
     BioEnergyLabelSize=(X=72,Y=24)
     BioCellCountLabelPos=(X=191,Y=170)
     BioCellCountLabelSize=(X=48,Y=24)
     ReloadTipLabelPos=(X=202,Y=189)
     ReloadTipLabelSize=(X=48,Y=24)
     ColBioBar=(R=255,G=255,B=255)
     ColNoCells=(R=96,G=96,B=96)
     ColHasCells=(R=255,G=255,B=255)
     
     ClientWidth=256
     ClientHeight=258
     
     clientTextures(0)=Texture'OATAugControllerMenu'
     clientTextures(1)=None
     clientTextures(2)=None
     clientTextures(3)=None
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=1
     TextureCols=1
     
     AugMenuKey(3)=IK_Escape //Hack.
     AliasNames(0)="ParseLeftClick"
     AliasNames(1)="Fire"
     AliasNames(2)="MoveForward"
     AliasNames(3)="MoveBackward"
     AliasNames(4)="StrafeLeft"
     AliasNames(5)="StrafeRight"
     AliasNames(6)="Jump"
     AliasNames(7)="OpenControllerAugWindow" //OAT: UPDATE ME TO WHAT CONSOLE COMMAND YOU USE TO OPEN THE MENU!
     AliasNames(8)="ReloadWeapon"
}
