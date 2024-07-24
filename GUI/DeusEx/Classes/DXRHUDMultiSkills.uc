class DXRHUDMultiSkills injects HUDMultiSkills;

const skillLevelX	= 0.22;

var bool dashPressed;

function CheckDashPress()
{
    local bool dashDown;
    local Skill aSkill;

    dashDown=IsKeyDown(IK_Minus) || IsKeyDown(IK_GreyMinus);

    if (dashDown!=dashPressed){
        dashPressed=dashDown;
        if(dashDown){
            if (Player!=None && Player.bBuySkills){
                if ( Player.SkillSystem != None )
                {
                    aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillSwimming');
                    if (aSkill!=None){
                        if (AttemptBuySkill(Player,aSkill)){
                            //Player.bBuySkills=False; //Keep the menu open after buying
                        }
                    }
                }
            }
        }
    }
}

//Copied from vanilla, but removed a check to ensure you were a multiplayer client of some sort
event DrawWindow(GC gc)
{
    local Skill askill;
    local float curx, cury, w, h;
    local String str, costStr;
    local int index;
    local float barLen, costx, levelx;

    if ( Player == None )
        return;

    if ( Player.bBuySkills )
    {
        CheckDashPress(); //We don't get button presses for dash, so check it manually

        if ( Player.SkillSystem != None )
        {
            gc.SetFont(Font'FontMenuSmall_DS');
            index = 1;
            askill = Player.SkillSystem.FirstSkill;
            cury = height * skillListY;
            curx = width * skillListX;
            costx = width * skillCostX;
            levelx = width * skillLevelX;
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
            str = LevelString;
            gc.GetTextExtent( 0, w, h, str );
            gc.DrawText( levelx, cury, w, h, str );
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

                gc.GetTextExtent( 0, w, h, str );
                if ( askill.CurrentLevel == 3)
                {
                    gc.SetTileColor( colBlue );
                    gc.SetTextColor( colBlue );
                    costStr = NAString;
                }
                else if ( Player.SkillPointsAvail >= askill.GetCost() )
                {
                    gc.SetTextColor( colLtGreen );
                    gc.SetTileColor( colLtGreen );

                    costStr = "" $ askill.GetCost();
                }
                else
                {
                    gc.SetTileColor( colLtRed );
                    gc.SetTextColor( colLtRed );

                    if (askill.GetCost()>=99999){
                        costStr = "BANNED";
                    } else {
                        costStr = "" $ askill.GetCost();
                    }
                }
                gc.DrawText( curx, cury, w, h, str );
                DrawLevel( gc, levelx, cury, askill.CurrentLevel );
                gc.GetTextExtent(	0, w, h, costStr );
                gc.DrawText( costx, cury, w, h, costStr );
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
    //else
    //    SkillMessage( gc ); //Don't draw the "Skills available" message

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

function bool OverrideBelt( DeusExPlayer thisPlayer, int objectNum )
{
    local Skill askill;

    if ( !thisPlayer.bBuySkills )
        return False;

    askill = GetSkillFromIndex( thisPlayer, objectNum );
    if ( AttemptBuySkill( thisPlayer, askill ) ){
        //thisPlayer.bBuySkills = False;   //Keep the menu open after buying
    }

    if ( ( objectNum >= 0 ) && ( objectNum <= 11) )
        return True;
    else
        return False;
}
