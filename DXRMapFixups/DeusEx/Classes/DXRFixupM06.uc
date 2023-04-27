class DXRFixupM06 extends DXRFixup;

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "06_HONGKONG_VERSALIFE";
    add_datacubes[i].text = "Versalife employee ID: 06288.  Use this to access the VersaLife elevator north of the market.";
    i++;

    add_datacubes[i].map = "06_HONGKONG_STORAGE";
    add_datacubes[i].text = "Access code to the Versalife nanotech research wing: 55655.";
    i++;

    Super.CheckConfig();
}

function PreFirstEntryMapFixes()
{
    local Actor a;
    local ScriptedPawn p;
    local Button1 b;
    local ElevatorMover e;
    local #var(DeusExPrefix)Mover m;
    local FlagTrigger ft;
    local AllianceTrigger at;
    local DeusExMover d;
    local DataLinkTrigger dt;
    local ComputerSecurity cs;
    local #var(prefix)Keypad pad;
    local ProjectileGenerator pg;
    local #var(prefix)WeaponNanoSword dts;

    switch(dxr.localURL)
    {
    case "06_HONGKONG_HELIBASE":
#ifdef vanillamaps
        foreach AllActors(class'ProjectileGenerator', pg, 'purge') {
            pg.CheckTime = 0.25;
            pg.spewTime = 0.4;
            pg.ProjectileClass = class'PurgeGas';
            switch(pg.Name) {
            case 'ProjectileGenerator5':// left side
                pg.SetRotation(rot(-7000, 80000, 0));
                break;
            case 'ProjectileGenerator2':// middle left
                pg.SetRotation(rot(-6024, 70000, 0));
                break;
            case 'ProjectileGenerator3':// middle right
                pg.SetRotation(rot(-8056, 64000, 0));
                break;
            case 'ProjectileGenerator7':// right side
                pg.SetRotation(rot(-8056, 60000, 0));
                break;
            }
        }
#endif
        break;

    case "06_HONGKONG_TONGBASE":
        foreach AllActors(class'Actor', a)
        {
            switch(string(a.Tag))
            {
                case "AlexGone":
                case "TracerGone":
                case "JaimeGone":
                    a.Destroy();
                    break;
                case "Breakintocompound":
                case "LumpathPissed":
                    Trigger(a).bTriggerOnceOnly = False;
                    break;
                default:
                    break;
            }
        }
        break;
    case "06_HONGKONG_WANCHAI_MARKET":
        foreach AllActors(class'Actor', a)
        {
            switch(string(a.Tag))
            {
                case "DummyKeypad01":
                    a.Destroy();
                    break;
                case "BasementKeypad":
                case "GateKeypad":
                    a.bHidden=False;
                    break;
                case "Breakintocompound":
                case "LumpathPissed":
                    Trigger(a).bTriggerOnceOnly = False;
                    break;
                case "Keypad3":
                    if( a.Event == 'elevator_door' && HackableDevices(a) != None ) {
                        HackableDevices(a).hackStrength = 0;
                    }
                    break;
                case "PoliceVault":
                    a.SetCollision(False,False,False);
                    break;
                default:
                    break;
            }
        }
        break;

    case "06_HONGKONG_WANCHAI_STREET":
        foreach AllActors(class'#var(prefix)WeaponNanoSword', dts) {
            dts.bIsSecretGoal = true;// just in case you don't have DXRMissions enabled
        }
#ifdef vanillamaps
        foreach AllActors(class'Button1',b)
        {
            if (b.Event=='JockShaftTop')
            {
                b.Event='JocksElevatorTop';
            }
        }

        foreach AllActors(class'ElevatorMover',e)
        {
            if(e.Tag=='JocksElevator')
            {
                e.Event = '';
            }
        }
        foreach AllActors(class'DeusExMover',d)
        {
            if(d.Tag=='DispalyCase') //They seriously left in that typo?
            {
                d.SetKeyframe(1,vect(0,0,-136),d.Rotation);  //Make sure the keyframe exists for it to drop into the floor
                d.bIsDoor = true; //Mark it as a door so the troops can actually open it...
            }
            else if(d.Tag=='JockShaftTop')
            {
                d.bFrobbable=True;
            }
            else if(d.Tag=='JockShaftBottom')
            {
                d.bFrobbable=True;
            }
        }
#endif
        break;

    case "06_HONGKONG_MJ12LAB":
        foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'security_doors') {
            m.bBreakable = false;
            m.bPickable = false;
        }
        foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'Lower_lab_doors') {
            m.bBreakable = false;
            m.bPickable = false;
        }
        foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'elevator_door') {
            m.bIsDoor = true;// DXRDoors will pick this up later since we're in PreFirstEntry
        }
        foreach AllActors(class'FlagTrigger', ft, 'MJ12Alert') {
            ft.Tag = 'TongHasRom';
        }
        foreach AllActors(class'DataLinkTrigger', dt) {
            if(dt.name == 'DataLinkTrigger0')
                dt.Tag = 'TongHasRom';
        }
        // don't wait for M07Briefing_Played to get rid of the dummy keypad
        foreach AllActors(class'#var(prefix)Keypad', pad)
        {
            if (pad.Tag == 'DummyKeypad_02')
                pad.Destroy();
            else if (pad.Tag == 'RealKeypad_02')
                pad.bHidden = False;
        }

        Spawn(class'PlaceholderItem',,, vect(-1.95,1223.1,810.3)); //Table over entrance
        Spawn(class'PlaceholderItem',,, vect(1022.24,-1344.15,450.3)); //Bathroom counter
        Spawn(class'PlaceholderItem',,, vect(1519.6,-1251,442.3)); //Conference room side table
        Spawn(class'PlaceholderItem',,, vect(1685.6,-1852.78,442.31)); //Kitchen counter
        Spawn(class'PlaceholderItem',,, vect(47.23,-243,-308)); //Vanilla ROM computer table
        Spawn(class'PlaceholderItem',,, vect(-1168.5,2584.1,-549)); //Barracks urinal divider
        Spawn(class'PlaceholderItem',,, vect(-305.4,2492.4,-581.7)); //Barracks sinks
        Spawn(class'PlaceholderItem',,, vect(-101.4,1887.5,-467)); //Barracks bed
        Spawn(class'PlaceholderItem',,, vect(-1677.9,-301.7,-740)); //Counter near karkian dissection
        Spawn(class'PlaceholderItem',,, vect(-1337,-593.7,-741)); //Karkian dissection sink
        Spawn(class'PlaceholderItem',,, vect(-406.8,1064.1,-789)); //Elevator shaft bottom
        Spawn(class'PlaceholderItem',,, vect(-394.9,1060.5,-533.7)); //Elevator shaft 2nd floor
        Spawn(class'PlaceholderItem',,, vect(-629.2,1089.2,-85)); //Elevator shaft 3rd floor
        Spawn(class'PlaceholderItem',,, vect(-553.1,1045.8,523)); //Elevator shaft top
        Spawn(class'PlaceholderItem',,, vect(3.2,-1567.4,219)); //Back of hand
        Spawn(class'PlaceholderItem',,, vect(771.4,-1335,394.3)); //Bathroom stall
        Spawn(class'PlaceholderItem',,, vect(-608.414246,2400.136963,-549.689514)); //Barracks locker
        Spawn(class'PlaceholderItem',,, vect(-1668.29,-358.24,-780.69)); //Lower cabinets near dissection
        Spawn(class'PlaceholderItem',,, vect(-1666.12,-303.75,-780.69)); //Lower cabinets near dissection

        Spawn(class'PlaceholderContainer',,, vect(-992,1582,-479)); //Barracks empty side upper
        Spawn(class'PlaceholderContainer',,, vect(-839,1629,-479)); //Barracks empty side upper
        Spawn(class'PlaceholderContainer',,, vect(-987,1713,-479)); //Barracks empty side upper
        Spawn(class'PlaceholderContainer',,, vect(-840,1890,-479)); //Barracks empty side upper
        Spawn(class'PlaceholderContainer',,, vect(-980,2089,-607)); //Barracks empty side lower
        Spawn(class'PlaceholderContainer',,, vect(-894,1465,-607)); //Barracks empty side lower
        Spawn(class'PlaceholderContainer',,, vect(-442,-494,-607)); //Near vanilla ROM encoding computer


        break;
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
#ifdef injections
        foreach AllActors(class'AllianceTrigger',at,'StoreSafe') {
            at.bPlayerOnly = true;
        }
#endif
        foreach AllActors(class'DeusExMover',d){
            if (d.Region.Zone.ZoneGroundFriction < 8) {
                //Less than default friction should be the freezer
                d.Tag='FreezerDoor';
            }
        }
        foreach AllActors(class'ComputerSecurity',cs){
            if (cs.UserList[0].UserName=="LUCKYMONEY"){
                cs.Views[2].doorTag='FreezerDoor';
            }
        }
        break;

    case "06_HONGKONG_WANCHAI_GARAGE":
        foreach AllActors(class'DeusExMover',d,'secret_door'){
            d.bFrobbable=False;
        }
        break;
    case "06_HONGKONG_VERSALIFE":
        Spawn(class'PlaceholderItem',,, vect(12.36,1556.5,-51)); //1st floor front cube
        Spawn(class'PlaceholderItem',,, vect(643.5,2139.7,-51.7)); //1st floor back cube
        Spawn(class'PlaceholderItem',,, vect(210.94,2062.23,204.3)); //2nd floor front cube
        Spawn(class'PlaceholderItem',,, vect(464,1549.45,204.3)); //2nd floor back cube
        Spawn(class'PlaceholderItem',,, vect(217.1,2027.76,460.3)); //3rd floor front cube
        Spawn(class'PlaceholderItem',,, vect(607.54,1629.1,460.3)); //3rd floor back cube
        Spawn(class'PlaceholderItem',,, vect(-914.38,255.5,458.3)); //3rd floor breakroom table
        Spawn(class'PlaceholderItem',,, vect(-836.9,850.3,-9.7)); //Reception desk back
        break;
    case "06_HONGKONG_STORAGE":
        Spawn(class'PlaceholderItem',,, vect(-39.86,-542.35,570.3)); //Computer desk
        Spawn(class'PlaceholderItem',,, vect(339.25,-2111.46,506.3)); //Near lasers
        Spawn(class'PlaceholderItem',,, vect(1169,-1490,459)); //Water pool
        Spawn(class'PlaceholderItem',,, vect(1079.73,-1068.17,842.4)); //Pipes above water

        Spawn(class'PlaceholderContainer',,, vect(160.7,-1589.4,545)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vect(-159.23,-1300.16,544.1)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vect(158.5,-1011.84,544.11)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vect(691.3,-358.4,-1007.9)); //Near UC
        Spawn(class'PlaceholderContainer',,, vect(174,-2862,1057)); //Near upper security computer
        break;

    case "06_HONGKONG_WANCHAI_CANAL":
        //Just a few that can spawn on top of the ship to maybe coax people down there?
        Spawn(class'PlaceholderContainer',,, vect(2305.5,-512.4,-415)); //On top of cargo ship
        Spawn(class'PlaceholderContainer',,, vect(2362.5,-333.4,-383.9)); //On top of cargo ship
        Spawn(class'PlaceholderContainer',,, vect(2403,-777,-359)); //On top of cargo ship
        break;
    default:
        break;
    }
}

function PostFirstEntryMapFixes()
{
    local Actor a;
    local Male1 male;

    switch(dxr.localURL) {
#ifndef revision
    case "06_HONGKONG_WANCHAI_STREET":
        a = Spawn(class'NanoKey',,, vect(1159.455444, -1196.089111, 1723.212402));
        NanoKey(a).KeyID = 'JocksKey';
        NanoKey(a).Description = "Jock's apartment";
        break;

    case "06_HONGKONG_VERSALIFE":
        foreach AllActors(class'Male1',male){
            if (male.BindName=="Disgruntled_Guy"){
                male.bImportant=True;
            }
        }
        break;
#endif
    }
}

function AnyEntryMapFixes()
{
    local Actor a;
    local ScriptedPawn p;
    local #var(DeusExPrefix)Mover m;
    local bool boolFlag;
    local bool recruitedFlag;
    local DeusExCarcass carc;
    local Conversation c;

    // if flag Have_ROM, set flags Have_Evidence and KnowsAboutNanoSword?
    // or if flag Have_ROM, Gordon Quick should let you into the compound? requires Have_Evidence and MaxChenConvinced

    c = GetConversation('MarketLum1Barks');
    FixConversationFlagJump(c, 'Versalife_Done', true, 'M08Briefing_Played', true);
    c = GetConversation('MarketLum2Barks');
    FixConversationFlagJump(c, 'Versalife_Done', true, 'M08Briefing_Played', true);

    switch(dxr.localURL)
    {
    case "06_HONGKONG_TONGBASE":
        c = GetConversation('M08Briefing');
        c.AddFlagRef('TriadCeremony_Played', true);
        c.AddFlagRef('VL_UC_Destroyed', true);
        c.AddFlagRef('VL_Got_Schematic', true);
        // some infolinks could require MeetTracerTong_Played or MeetTracerTong2_Played? DL_Tong_05 and DL_Tong_06?

        boolFlag = dxr.flagbase.GetBool('QuickLetPlayerIn');
        foreach AllActors(class'Actor', a)
        {
            switch(string(a.Tag))
            {
                case "TriadLumPath":
                    ScriptedPawn(a).ChangeAlly('Player',1,False);
                    break;

                case "TracerTong":
                    if ( boolFlag == True )
                    {
                        ScriptedPawn(a).EnterWorld();
                    } else {
                        ScriptedPawn(a).LeaveWorld();
                    }
                    break;
                case "AlexJacobson":
                    recruitedFlag = dxr.flagbase.GetBool('JacobsonRecruited');
                    if ( boolFlag == True && recruitedFlag == True)
                    {
                        ScriptedPawn(a).EnterWorld();
                    } else {
                        ScriptedPawn(a).LeaveWorld();
                    }
                    break;
                case "JaimeReyes":
                    recruitedFlag = dxr.flagbase.GetBool('JaimeRecruited') && dxr.flagbase.GetBool('Versalife_Done');
                    if ( boolFlag == True && recruitedFlag == True)
                    {
                        ScriptedPawn(a).EnterWorld();
                    } else {
                        ScriptedPawn(a).LeaveWorld();
                    }
                    break;
                case "Operation1":
                    DataLinkTrigger(a).checkFlag = 'QuickLetPlayerIn';
                    break;
                case "TurnOnTheKillSwitch":
                    if (boolFlag == True)
                    {
                        Trigger(a).TriggerType = TT_PlayerProximity;
                    } else {
                        Trigger(a).TriggerType = TT_ClassProximity;
                        Trigger(a).ClassProximityType = class'Teleporter';//Impossible, thus disabling it
                    }
                    break;
                default:
                    break;
            }
        }
        break;
    case "06_HONGKONG_WANCHAI_MARKET":
        foreach AllActors(class'Actor', a)
        {
            switch(string(a.Tag))
            {
                case "TriadLumPath":
                case "TriadLumPath1":
                case "TriadLumPath2":
                case "TriadLumPath3":
                case "TriadLumPath4":
                case "TriadLumPath5":
                case "GordonQuick":

                    ScriptedPawn(a).ChangeAlly('Player',1,False);
                    break;
            }
        }
        HandleJohnSmithDeath();
        SetTimer(1.0, True); //To handle updating the DTS goal description
        break;

    case "06_HONGKONG_VERSALIFE":
        // allow you to get the code from him even if you've been to the labs, to fix backtracking
        DeleteConversationFlag( GetConversation('Disgruntled_Guy_Convos'), 'VL_Found_Labs', false);
        GetConversation('Disgruntled_Guy_Return').AddFlagRef('Disgruntled_Guy_Done', true);
        break;

    case "06_HONGKONG_WANCHAI_STREET":
        foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'JockShaftTop') {
            m.bLocked = false;
            m.bHighlight = true;
        }
        HandleJohnSmithDeath();
        break;

    case "06_HONGKONG_WANCHAI_CANAL":
        HandleJohnSmithDeath();
        if (dxr.flagbase.GetBool('Disgruntled_Guy_Dead')){
            foreach AllActors(class'DeusExCarcass', carc, 'John_Smith_Body')
                if (carc.bHidden){
				    carc.bHidden = False;
#ifdef injections
                    //HACK: to be removed once the problems with Carcass2 are fixed/removed
                    carc.mesh = LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassC';  //His body starts in the water, so this is fine
                    carc.SetMesh2(LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassB');
                    carc.SetMesh3(LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassC');
#endif
                }
        }
        break;

    default:
        break;
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "06_HONGKONG_WANCHAI_MARKET":
        UpdateGoalWithRandoInfo('InvestigateMaggieChow');
        break;
    }
}

function HandleJohnSmithDeath()
{
    if (dxr.flagbase.GetBool('Disgruntled_Guy_Dead')){ //He's already dead
        return;
    }

    if (!dxr.flagbase.GetBool('Supervisor01_Dead') &&
        dxr.flagbase.GetBool('HaveROM') &&
        !dxr.flagbase.GetBool('Disgruntled_Guy_Return_Played'))
    {
        dxr.flagbase.SetBool('Disgruntled_Guy_Dead',true);
        //We could send a death message here?
    }
}
