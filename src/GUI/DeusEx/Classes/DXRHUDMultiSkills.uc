class DXRHUDMultiSkills injects HUDMultiSkills;

const skillLevelX	= 0.22;

const curValX = 0.14;
const nextValX = 0.18;

const augLevelX = 0.25;
const augCurValX = 0.16;
const augNextValX = 0.21;

var bool dashPressed;
var bool bShowing;
var Color	colMax;

var String curAugKeyName;


function RefreshKey()
{
    local String KeyName, Alias;
    local int i;

    curKeyName = "";
    for ( i=0; i<255; i++ )
    {
        KeyName = player.ConsoleCommand ( "KEYNAME "$i );
        if ( KeyName != "" )
        {
            Alias = player.ConsoleCommand( "KEYBINDING "$KeyName );
            if ( Alias ~= "BuySkills" )
            {
                curKeyName = KeyName;
            }
            else if ( Alias ~= "UpgradeAugs" )
            {
                curAugKeyName = KeyName;
            }
        }
    }
    if ( curKeyName ~= "" )
        curKeyName = KeyNotBoundString;
    if ( curAugKeyName ~= "" )
        curAugKeyName = KeyNotBoundString;

}

function CheckDashPress()
{
    local bool dashDown;
    local Skill aSkill;
    local Augmentation anAug;
    local bool showAugs,showSkills;

    if(Player==None) return;

#ifdef injections
    showAugs = Human(Player).bUpgradeAugs;
    showSkills = Player.bBuySkills;
#else
    showSkills = Player.bBuySkills;
    showAugs = False;
#endif


    dashDown=IsKeyDown(IK_Minus) || IsKeyDown(IK_GreyMinus);

    if (dashDown==dashPressed) return;
    dashPressed=dashDown;
    if(!dashDown) return;

    if (showSkills){
        aSkill = GetSkillFromIndex(Player, 11);
        if (aSkill!=None){
            if (AttemptBuySkill(Player,aSkill)){
                //Player.bBuySkills=False; //Keep the menu open after buying
                class'#var(injectsprefix)PersonaScreenSkills'.static.UpdateSwimSpeed(aSkill,#var(prefix)Human(Player));
            }
        }
    } else if(showAugs) {
        anAug = GetAugFromIndex(Player, 11);
        if(anAug!=None) {
            AttemptUpgradeAug(Player, anAug);
        }
    }
}

function DrawSkillsScreen(GC gc)
{
    local Skill askill;
    local float curx, cury, w, h;
    local String str, costStr, word;
    local int index, i;
    local float barLen, costx, levelx, curvaluex, nextvaluex, val, defaultval;
    local DXRSkills dxrs;
    local String levelValuesDisplay[4];

    if ( Player.SkillSystem != None )
    {
#ifdef vanilla
        dxrs = DXRSkills(Human(Player).dxr.FindModule(class'DXRSkills'));
#endif
        gc.SetFont(Font'DXRFontMenuSmall_DS');
        gc.SetTextColor( colWhite );
        index = 1;
        askill = Player.SkillSystem.FirstSkill;
        cury = height * skillListY;
        curx = width * skillListX;
        costx = width * skillCostX;
        levelx = width * skillLevelX;
        curvaluex = width * curValX;
        nextvaluex = width * nextValX;
        gc.GetTextExtent( 0, w, h, CostString );
        barLen = (costx+(w*1.33))-curx;
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
        cury += (h*0.25);
        str = SkillPointsString $ Player.SkillPointsAvail;
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( curx, cury, w, h, str );
        cury += h;
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
        cury += (h*0.25);
        str = SkillString;
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( curx, cury, w, h, str );
        str = "Current";
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( curvaluex-7, cury, w, h, str ); //Slight offset to look a bit nicer
        str = "Next";
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( nextvaluex, cury, w, h, str );
        str = LevelString;
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( levelx-4, cury, w, h, str ); //Slight offset to look a bit nicer
        str = CostString;
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( costx, cury, w, h, str );
        cury += h;
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
        cury += (h*0.25);

        while ( askill != None )
        {
            if ( index == 11 )
                str = "-. " $ askill.SkillName;
            else if ( index == 10 )
                str = "0. " $ askill.SkillName;
            else
                str = index $ ". " $ askill.SkillName;

            if ( askill.CurrentLevel == 3)
            {
                gc.SetTileColor( colMax );
                gc.SetTextColor( colMax );
                costStr = NAString;
            }
            else if ( Player.SkillPointsAvail >= askill.GetCost() )
            {
                gc.SetTextColor( colGreen );
                gc.SetTileColor( colGreen );

                costStr = "" $ askill.GetCost();
            }
            else
            {
                gc.SetTileColor( colRed );
                gc.SetTextColor( colRed );

                if (askill.GetCost()>=99999){
                    costStr = "BANNED";
                } else {
                    costStr = "" $ askill.GetCost();
                }
            }
            gc.GetTextExtent( 0, w, h, str );
            gc.DrawText( curx, cury, w, h, str );

            str = ""$askill.CurrentLevel+1;
            gc.GetTextExtent( 0, w, h, str );
            gc.DrawText( levelx, cury, w, h, str ); //Draw text, not boxes
            //DrawLevel( gc, levelx, cury, askill.CurrentLevel );

            gc.GetTextExtent(	0, w, h, costStr );
            gc.DrawText( costx, cury, w, h, costStr );

            if (dxrs!=None){
                for (i=0;i<4;i++){
                    val = askill.levelValues[i];
                    levelValuesDisplay[i] = dxrs.DescriptionLevelShort(aSkill, i, val);
                }
                gc.GetTextExtent(	0, w, h, levelValuesDisplay[askill.CurrentLevel] );
                gc.DrawText( curvaluex, cury, w, h, levelValuesDisplay[askill.CurrentLevel]);
                if (askill.CurrentLevel<3){
                    gc.GetTextExtent(	0, w, h, levelValuesDisplay[askill.CurrentLevel+1] );
                    gc.DrawText( nextvaluex, cury, w, h, levelValuesDisplay[askill.CurrentLevel+1]);
                }
            }

            cury += h;
            index += 1;
            askill = askill.next;
        }
        gc.SetTileColor( colWhite );
        if ( curKeyName ~= KeyNotBoundString )
            RefreshKey();
        str = PressString $ curKeyName $ ToExitString;
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
        cury += (h*0.25);
        gc.SetTextColor( colWhite );
        gc.DrawText( curx + ((barLen*0.5)-(w*0.5)), cury, w, h, str );
        cury += h;
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
    }

}

function DrawAugsScreen(GC gc)
{
    local Augmentation anaug;
    local float curx, cury, w, h;
    local String str, costStr;
    local int index, i, numUpgrades;
    local float barLen, levelx, curvaluex, nextvaluex, val, defaultval;
    local DXRAugmentations dxra;
    local String levelValuesDisplay[5];

    if ( Player.AugmentationSystem != None )
    {
#ifdef vanilla
        dxra = DXRAugmentations(Human(Player).dxr.FindModule(class'DXRAugmentations'));
#endif
        numUpgrades = GetNumAugUpgrades(Player);

        gc.SetFont(Font'DXRFontMenuSmall_DS');
        gc.SetTextColor( colWhite );
        index = 1;
        anaug = Player.AugmentationSystem.FirstAug;
        cury = height * skillListY;
        curx = width * skillListX;
        levelx = width * augLevelX;
        curvaluex = width * augCurValX;
        nextvaluex = width * augNextValX;
        gc.GetTextExtent( 0, w, h, LevelString );
        barLen = (levelx+(w*1.33))-curx;
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
        cury += (h*0.25);
        str = "Aug Upgrades: " $ numUpgrades;
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( curx, cury, w, h, str );
        cury += h;
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
        cury += (h*0.25);
        str = "Augmentation";
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( curx, cury, w, h, str );
        str = "Current";
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( curvaluex-7, cury, w, h, str ); //Slight offset to look a bit nicer
        str = "Next";
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( nextvaluex, cury, w, h, str );
        str = LevelString;
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawText( levelx-4, cury, w, h, str ); //Slight offset to look a bit nicer

        cury += h;
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
        cury += (h*0.25);

        while ( anAug != None )
        {
            if (isValidQuickAug(anAug)){
                if ( index == 11 )
                    str = "-. " $ anAug.AugmentationName;
                else if ( index == 10 )
                    str = "0. " $ anAug.AugmentationName;
                else
                    str = index $ ". " $ anAug.AugmentationName;

                if ( anAug.CurrentLevel == anAug.MaxLevel)
                {
                    gc.SetTileColor( colMax );
                    gc.SetTextColor( colMax );
                }
                else if ( numUpgrades!=0 )
                {
                    gc.SetTextColor( colGreen );
                    gc.SetTileColor( colGreen );
                }
                else
                {
                    gc.SetTileColor( colRed );
                    gc.SetTextColor( colRed );
                }

                gc.GetTextExtent( 0, w, h, str );
                gc.DrawText( curx, cury, w, h, str );

                str = ""$anAug.CurrentLevel+1;
                gc.GetTextExtent( 0, w, h, str );
                gc.DrawText( levelx, cury, w, h, str ); //Draw text, not boxes
                //DrawLevel( gc, levelx, cury, askill.CurrentLevel );

                if (dxra!=None){
                    for (i=0;i<4;i++){
                        val = anAug.LevelValues[i];
                        levelValuesDisplay[i] = dxra.DescriptionLevelShort(anAug, i, val);
                    }
                #ifdef injections
                    if(anAug.Level5Value != -1) {
                        val = anAug.Level5Value;
                        levelValuesDisplay[4] = dxra.DescriptionLevelShort(anAug, 4, val);
                    }
                #endif
                    gc.GetTextExtent( 0, w, h, levelValuesDisplay[anAug.CurrentLevel] );
                    gc.DrawText( curvaluex, cury, w, h, levelValuesDisplay[anAug.CurrentLevel]);
                    if (anAug.CurrentLevel<anAug.MaxLevel){
                        gc.GetTextExtent( 0, w, h, levelValuesDisplay[anAug.CurrentLevel+1] );
                        gc.DrawText( nextvaluex, cury, w, h, levelValuesDisplay[anAug.CurrentLevel+1]);
                    }
                }

                cury += h;
                index += 1;
            }
            anAug = AnAug.next;
        }
        gc.SetTileColor( colWhite );
        if ( curAugKeyName ~= KeyNotBoundString )
            RefreshKey();
        str = PressString $ curAugKeyName $ ToExitString;
        gc.GetTextExtent( 0, w, h, str );
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
        cury += (h*0.25);
        gc.SetTextColor( colWhite );
        gc.DrawText( curx + ((barLen*0.5)-(w*0.5)), cury, w, h, str );
        cury += h;
        gc.DrawBox( curx, cury, barLen, 1, 0, 0, 1, Texture'Solid');
    }

}


event DrawWindow(GC gc)
{
    if ( Player == None ){
        bShowing=False;
        return;
    }

    if ( Player.bBuySkills )
    {
        CheckDashPress(); //We don't get button presses for dash, so check it manually
        DrawSkillsScreen(gc);
        bShowing=True;
    }
#ifdef injections
    else if ( Human(Player).bUpgradeAugs )
    {
        DrawAugsScreen(gc);
        bShowing=True;
    }
#endif
    else
    {
        bShowing=False;
    }
    Super.DrawWindow(gc);
}

function Skill GetSkillFromIndex( DeusExPlayer thisPlayer, int index )
{
    local Skill askill;
    local int curIndex;

    // Zero indexed, but min element is 1, 0 is 10
    if ( index == 0 )
        index = 9;
    else
        index -= 1;

    curIndex = 0;
    askill = None;
    if ( thisPlayer != None )
    {
        askill = thisPlayer.SkillSystem.FirstSkill;
        while ( askill != None )
        { //Don't skip swimming like in vanilla

            if ( curIndex == index )
                return( askill );

            curIndex += 1;

            askill = askill.next;
        }
    }
    return( askill );
}

function int GetNumAugUpgrades( DeusExPlayer thisPlayer )
{
    local Inventory anItem;
    local int augCanCount;

    augCanCount=0;

    //Allow usage of an aug upgrade can on the ground
    if (#var(prefix)AugmentationUpgradeCannister(thisPlayer.FrobTarget)!=None && !thisPlayer.FrobTarget.bDeleteMe){
        augCanCount++;
    }

    anItem = thisPlayer.Inventory;
    while (anItem != None)
    {
        if (anItem.IsA('#var(prefix)AugmentationUpgradeCannister')){
            augCanCount++;
        }

        anItem = anItem.Inventory;
    }

    return augCanCount;
}

function bool isValidQuickAug(Augmentation anAug)
{
    local bool isValid;

    isValid=anAug.bHasIt;
    if (anAug.AugmentationLocation==LOC_Default){
        if (anAug.MaxLevel==0){
            isValid=False;
        }

    }

    return isValid;

}

function Augmentation GetAugFromIndex( DeusExPlayer thisPlayer, int index )
{
    local Augmentation anAug;
    local int i;

    // Zero indexed, but min element is 1, 0 is 10
    if ( index == 0 )
        index = 9;
    else
        index -= 1;

    if (thisPlayer==None){
        return None;
    }

    i = 0;
    anAug=thisPlayer.AugmentationSystem.FirstAug;
    while ( anAug != None )
    {
        if (isValidQuickAug(anAug)){
            if (i==index){
                return anAug;
            }
            i += 1;
        }
        anAug = AnAug.next;
    }
    return None;
}

function bool AttemptUpgradeAug( DeusExPlayer thisPlayer, Augmentation anAug )
{
    local #var(prefix)AugmentationUpgradeCannister augCan;

    if (anAug!=None)
    {
        if (anAug.CurrentLevel==anAug.MaxLevel){
            thisPlayer.BuySkillSound( 1 );
            return False;
        } else {
            //Prioritize a highlighted aug upgrade over one in your inventory
            if (#var(prefix)AugmentationUpgradeCannister(thisPlayer.FrobTarget)!=None && !thisPlayer.FrobTarget.bDeleteMe){
                augCan = #var(prefix)AugmentationUpgradeCannister(thisPlayer.FrobTarget);
                thisPlayer.AddInventory(augCan); //Needs to be in inventory so the Aug can see it is available for upgrading
            } else {
                augCan = #var(prefix)AugmentationUpgradeCannister(player.FindInventoryType(Class'#var(prefix)AugmentationUpgradeCannister'));
            }
            if (augCan!=None){
                anAug.IncLevel();
                augCan.UseOnce();
                thisPlayer.BuySkillSound( 0 );
            } else {
                thisPlayer.BuySkillSound( 1 );
                return False;
            }
        }
    }
}

function bool OverrideBelt( DeusExPlayer thisPlayer, int objectNum )
{
    local Skill askill;
    local Augmentation anAug;
    local bool showAugs,showSkills;

#ifdef injections
    showAugs = Human(thisPlayer).bUpgradeAugs;
    showSkills = thisPlayer.bBuySkills;
#else
    showSkills = thisPlayer.bBuySkills;
    showAugs = False;
#endif

    if ( !showSkills && !showAugs )
        return False;

    if (showSkills){
        askill = GetSkillFromIndex( thisPlayer, objectNum );
        if ( AttemptBuySkill( thisPlayer, askill ) ){
            //thisPlayer.bBuySkills = False;   //Keep the menu open after buying
        }
    } else if (showAugs){
        //Map number to aug
        anAug = GetAugFromIndex( thisPlayer, objectNum );
        AttemptUpgradeAug( thisPlayer, anAug );
    }

    if ( ( objectNum >= 0 ) && ( objectNum <= 11) )
        return True;
    else
        return False;
}

defaultproperties
{
     colMax=(R=216,G=175,B=31,A=255)
     colGreen=(R=40,G=204,B=80,A=255)
     colRed=(R=220,G=90,B=80,A=255)
}
