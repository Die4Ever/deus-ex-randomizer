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

    add_datacubes[i].map = "06_HONGKONG_WANCHAI_MARKET";
    add_datacubes[i].text = "This new ATM in the market is in such a convenient location for all my banking needs!|nAccount: 8326942 |nPIN: 7797 ";
    i++;

    add_datacubes[i].map = "06_HONGKONG_WANCHAI_STREET";
    add_datacubes[i].text = "It's so handy being able to quickly grab some cash from the Quick Stop before getting to the club!|nAccount: 2332316 |nPIN: 1608 ";
    i++;

    Super.CheckConfig();
}

function PreFirstEntryMapFixes()
{
    local Actor a;
    local #var(prefix)ScriptedPawn p;
    local Button1 b;
    local ElevatorMover e;
    local #var(DeusExPrefix)Mover m;
    local #var(prefix)AllianceTrigger at;
    local DeusExMover d;
    local DataLinkTrigger dt;
    local ComputerSecurity cs;
    local #var(prefix)Keypad pad;
    local ProjectileGenerator pg;
    local #var(prefix)WeaponNanoSword dts;
    local #var(prefix)RatGenerator rg;
    local #var(prefix)Credits creds;
    local #var(prefix)Greasel g;
    local #var(prefix)FlagTrigger ft;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)TriadRedArrow bouncer;

#ifdef injections
    local #var(prefix)DataCube dc;
#else
    local DXRInformationDevices dc;
#endif

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
                pg.SetRotation(rotm(-7000, 80000, 0, 16384));
                break;
            case 'ProjectileGenerator2':// middle left
                pg.SetRotation(rotm(-6024, 70000, 0, 16384));
                break;
            case 'ProjectileGenerator3':// middle right
                pg.SetRotation(rotm(-8056, 64000, 0, 16384));
                break;
            case 'ProjectileGenerator7':// right side
                pg.SetRotation(rotm(-8056, 60000, 0, 16384));
                break;
            }
        }

        //Make the elevator doors trigger Jock firing a missile
        foreach AllActors(class'#var(DeusExPrefix)Mover',m,'elevator_door'){
            m.Event='make_a_break';
            break;
        }

        class'PlaceholderEnemy'.static.Create(self,vectm(769,-520,144));
        class'PlaceholderEnemy'.static.Create(self,vectm(1620,-87,144));
        class'PlaceholderEnemy'.static.Create(self,vectm(-844,-359,816));
        class'PlaceholderEnemy'.static.Create(self,vectm(2036,122,816));

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
    case "06_HONGKONG_WANCHAI_COMPOUND":
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
                case "MarketMonk01":
                    //He was meant to be out of world until the ceremony, apparently
                    //If he isn't, he can get in the way of Gordon teleporting into positon
                    #var(prefix)ScriptedPawn(a).LeaveWorld();
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
                d.SetKeyframe(1,vectm(0,0,-136),d.Rotation);  //Make sure the keyframe exists for it to drop into the floor
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
        foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'MJ12Alert') {
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

        foreach AllActors(class'#var(prefix)Greasel',g){
            g.bImportant = True;
            g.BindName="JerryTheVentGreasel";
            g.FamiliarName = "Jerry the Vent Greasel";
            g.UnfamiliarName = "Jerry the Vent Greasel";
        }

        SpawnDatacubeImage(vectm(-1194.700195,-789.460266,-750.628357), rotm(0,0,0),Class'DeusEx.Image15_GrayDisection');

        Spawn(class'PlaceholderItem',,, vectm(-1.95,1223.1,810.3)); //Table over entrance
        Spawn(class'PlaceholderItem',,, vectm(1022.24,-1344.15,450.3)); //Bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(1519.6,-1251,442.3)); //Conference room side table
        Spawn(class'PlaceholderItem',,, vectm(1685.6,-1852.78,442.31)); //Kitchen counter
        Spawn(class'PlaceholderItem',,, vectm(47.23,-243,-308)); //Vanilla ROM computer table
        Spawn(class'PlaceholderItem',,, vectm(-1168.5,2584.1,-549)); //Barracks urinal divider
        Spawn(class'PlaceholderItem',,, vectm(-305.4,2492.4,-581.7)); //Barracks sinks
        Spawn(class'PlaceholderItem',,, vectm(-101.4,1887.5,-467)); //Barracks bed
        Spawn(class'PlaceholderItem',,, vectm(-1677.9,-301.7,-740)); //Counter near karkian dissection
        Spawn(class'PlaceholderItem',,, vectm(-1337,-593.7,-741)); //Karkian dissection sink
        Spawn(class'PlaceholderItem',,, vectm(-406.8,1064.1,-789)); //Elevator shaft bottom
        Spawn(class'PlaceholderItem',,, vectm(-394.9,1060.5,-533.7)); //Elevator shaft 2nd floor
        Spawn(class'PlaceholderItem',,, vectm(-629.2,1089.2,-85)); //Elevator shaft 3rd floor
        Spawn(class'PlaceholderItem',,, vectm(-553.1,1045.8,523)); //Elevator shaft top
        Spawn(class'PlaceholderItem',,, vectm(3.2,-1567.4,219)); //Back of hand
        Spawn(class'PlaceholderItem',,, vectm(771.4,-1335,394.3)); //Bathroom stall
        Spawn(class'PlaceholderItem',,, vectm(-608.414246,2400.136963,-549.689514)); //Barracks locker
        Spawn(class'PlaceholderItem',,, vectm(-1668.29,-358.24,-780.69)); //Lower cabinets near dissection
        Spawn(class'PlaceholderItem',,, vectm(-1666.12,-303.75,-780.69)); //Lower cabinets near dissection

        Spawn(class'PlaceholderContainer',,, vectm(-992,1582,-479)); //Barracks empty side upper
        Spawn(class'PlaceholderContainer',,, vectm(-839,1629,-479)); //Barracks empty side upper
        Spawn(class'PlaceholderContainer',,, vectm(-987,1713,-479)); //Barracks empty side upper
        Spawn(class'PlaceholderContainer',,, vectm(-840,1890,-479)); //Barracks empty side upper
        Spawn(class'PlaceholderContainer',,, vectm(-980,2089,-607)); //Barracks empty side lower
        Spawn(class'PlaceholderContainer',,, vectm(-894,1465,-607)); //Barracks empty side lower
        Spawn(class'PlaceholderContainer',,, vectm(-442,-494,-607)); //Near vanilla ROM encoding computer


        break;
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
#ifdef injections
        foreach AllActors(class'#var(prefix)AllianceTrigger',at,'StoreSafe') {
            at.bPlayerOnly = true;
        }
#endif
        foreach AllActors(class'#var(prefix)Credits',creds){
            if (creds.numCredits==25){
                creds.numCredits=100;
            }
        }

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

        //A switch inside the freezer to open it back up... just in case
        AddSwitch( vect(-1560.144409,-3166.475098,-315.504028), rot(0,16408,0), 'FreezerDoor');


        //Restore bouncer conversation....

        //Remove the flag trigger that says you paid as soon as you walk in the door...
        //The doorgirl conversation sets the flag appropriately
        foreach AllActors(class'#var(prefix)FlagTrigger',ft){
            if (ft.bSetFlag==True && ft.FlagName=='PaidForLuckyMoney'){
                ft.Destroy();
                break;
            }
        }

        ft=Spawn(class'#var(prefix)FlagTrigger',,,vectm(-1024,-1019,-343));
        ft.bSetFlag=False;
        ft.bTrigger=True;
        ft.FlagName='PaidForLuckyMoney';
        ft.flagValue=False;
        ft.Event='BouncerGonnaGetcha';

        ft=Spawn(class'#var(prefix)FlagTrigger');
        ft.SetCollision(False,False,False);
        ft.Tag='BouncerGonnaGetcha';
        ft.bSetFlag=True;
        ft.bTrigger=False;
        ft.FlagName='BouncerComing';
        ft.flagValue=True;

        ot=Spawn(class'#var(prefix)OrdersTrigger');
        ot.Tag='BouncerGonnaGetcha';
        ot.Event='ClubBouncer'; //Need to make sure one of these guys is actually labeled as such...
        ot.SetCollision(False,False,False);
        ot.Orders='RunningTo';

        ot=Spawn(class'#var(prefix)OrdersTrigger');
        ot.Tag='BouncerStartAttacking';
        ot.Event='ClubBouncer'; //Need to make sure one of these guys is actually labeled as such...
        ot.SetCollision(False,False,False);
        ot.Orders='Attacking';

        at = Spawn(class'#var(prefix)AllianceTrigger');
        at.Tag='BouncerStartAttacking';
        at.Event='ClubBouncer';
        at.SetCollision(False,False,False);
        at.Alliance='RedArrow';
        at.Alliances[0].AllianceLevel=-1;
        at.Alliances[0].AllianceName='Player';
        at.Alliances[0].bPermanent=False;

        foreach AllActors(class'#var(prefix)TriadRedArrow',bouncer){
            if (bouncer.BindName=="ClubBouncer" && bouncer.Location.Z > -150){
                bouncer.Tag = 'ClubBouncer';
                break;
            }
        }

        break;

    case "06_HONGKONG_WANCHAI_GARAGE":
        foreach AllActors(class'DeusExMover',d,'secret_door'){
            d.bFrobbable=False;
        }
        break;
    case "06_HONGKONG_VERSALIFE":

        ft= Spawn(class'#var(prefix)FlagTrigger',,, vectm(128.850372,635.855957,-123)); //In front of lower elevator
        ft.Event='VL_OnAlert';
        ft.FlagName='Have_ROM';
        ft.bSetFlag=False;
        ft.bTrigger=True;

        foreach AllActors(class'#var(prefix)ScriptedPawn',p){
            if(p.BindName=="Supervisor01"){
                p.FamiliarName="Mr. Hundley"; //It's spelled this way everywhere else
                GiveItem(p,class'#var(prefix)Credits');  //He asks for 2000 credits to get into the labs
                GiveItem(p,class'#var(prefix)Credits');  //He's probably getting a bunch of cash from other people too.
            }
        }

        Spawn(class'PlaceholderItem',,, vectm(12.36,1556.5,-51)); //1st floor front cube
        Spawn(class'PlaceholderItem',,, vectm(643.5,2139.7,-51.7)); //1st floor back cube
        Spawn(class'PlaceholderItem',,, vectm(210.94,2062.23,204.3)); //2nd floor front cube
        Spawn(class'PlaceholderItem',,, vectm(464,1549.45,204.3)); //2nd floor back cube
        Spawn(class'PlaceholderItem',,, vectm(217.1,2027.76,460.3)); //3rd floor front cube
        Spawn(class'PlaceholderItem',,, vectm(607.54,1629.1,460.3)); //3rd floor back cube
        Spawn(class'PlaceholderItem',,, vectm(-914.38,255.5,458.3)); //3rd floor breakroom table
        Spawn(class'PlaceholderItem',,, vectm(-836.9,850.3,-9.7)); //Reception desk back
        break;
    case "06_HONGKONG_STORAGE":
        Spawn(class'PlaceholderItem',,, vectm(-39.86,-542.35,570.3)); //Computer desk
        Spawn(class'PlaceholderItem',,, vectm(339.25,-2111.46,506.3)); //Near lasers
        Spawn(class'PlaceholderItem',,, vectm(1169,-1490,459)); //Water pool
        Spawn(class'PlaceholderItem',,, vectm(1079.73,-1068.17,842.4)); //Pipes above water

        Spawn(class'PlaceholderContainer',,, vectm(160.7,-1589.4,545)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vectm(-159.23,-1300.16,544.1)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vectm(158.5,-1011.84,544.11)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vectm(691.3,-358.4,-1007.9)); //Near UC
        Spawn(class'PlaceholderContainer',,, vectm(174,-2862,1057)); //Near upper security computer

        Spawn(class'MJ12Clone1',,, vectm(819.992188, -0.852280, -67.399956));
        break;

    case "06_HONGKONG_WANCHAI_CANAL":

        //Give the drug dealer and pusher 100 credits each
        foreach AllActors(class'#var(prefix)ScriptedPawn',p){
            if (p.BindName=="Canal_Thug1" || p.BindName=="Canal_Thug2"){
                GiveItem(p,class'#var(prefix)Credits');
            }
        }

        //Just a few that can spawn on top of the ship to maybe coax people down there?
        Spawn(class'PlaceholderContainer',,, vectm(2305.5,-512.4,-415)); //On top of cargo ship
        Spawn(class'PlaceholderContainer',,, vectm(2362.5,-333.4,-383.9)); //On top of cargo ship
        Spawn(class'PlaceholderContainer',,, vectm(2403,-777,-359)); //On top of cargo ship
        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(3237,3217,-506));//Lower garage storage area
        rg.MaxCount=3;
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
    case "06_HONGKONG_WANCHAI_STREET":
        a = Spawn(class'NanoKey',,, vectm(1159.455444, -1196.089111, 1723.212402));
        NanoKey(a).KeyID = 'JocksKey';
        NanoKey(a).Description = "Jock's apartment";
        if(dxr.flags.settings.keysrando > 0)
            GlowUp(a);
        break;
#ifndef revision
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
    local #var(DeusExPrefix)Carcass carc;
    local Conversation c;
    local ConEvent ce;
    local ConEventSpeech ces;
    local ConEventSetFlag cesf;
    local ConEventTrigger cet;
    local #var(prefix)Pigeon pigeon;

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
                case "MonkReadyForCeremony":
                case "QuickInTemple":
                case "ChenInTemple":
                    //Pigeons can also interfere with a teleport, so make sure the move points
                    //are clear of pigeons as well.  These will be replaced by the PigeonGenerator
                    foreach RadiusActors(class'#var(prefix)Pigeon',pigeon,60,a.Location){
                        pigeon.Destroy();
                    }
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
            foreach AllActors(class'#var(DeusExPrefix)Carcass', carc, 'John_Smith_Body')
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
    case "06_HONGKONG_MJ12LAB":
        c = GetConversation('MJ12Lab_BioWeapons_Overheard');
        ce = c.eventList;

        while (ce!=None && ce.eventType!=ET_End){
            if (ce.eventType==ET_Speech){
                ces = ConEventSpeech(ce);
                if (ces.speakingToName=="MJ12Lab_Assistant_Level2"){
                    ces.speakingToName="MJ12Lab_Assistant_BioWeapons";
                }
            }
            ce = ce.nextEvent;
        }
        break;
    case "06_HONGKONG_WANCHAI_UNDERWORLD":

        //Let FemJC pay for a date if she wants
        DeleteConversationFlag( GetConversation('MamasanConvos'), 'LDDPMaleCont4FJC', true);

        c = GetConversation('BouncerPissed');
        c.bInvokeRadius=True;
        c.radiusDistance=180;

        ce = c.eventList;
        while (ce!=None){
            if (ce.eventType==ET_Speech){
                ces = ConEventSpeech(ce);
                if (InStr(ces.conSpeech.speech,"Don't try that again")!=-1){
                    //Spawn a ConEventSetFlag to set "PaidForLuckyMoney", insert it between this and it's next event
                    cesf = new(c) class'ConEventSetFlag';
                    cesf.eventType=ET_SetFlag;
                    cesf.label="PaidForLuckyMoneyTrue";
                    cesf.flagRef = new(c) class'ConFlagRef';
                    cesf.flagRef.flagName='PaidForLuckyMoney';
                    cesf.flagRef.value=True;
                    cesf.flagRef.expiration=7;
                    cesf.nextEvent = ces.nextEvent;
                    ces.nextEvent = cesf;

                }
                if (InStr(ces.conSpeech.speech,"Your choice.")!=-1){
                    //Spawn a ConEventTrigger to hit an alliance trigger or something so he starts attacking, insert between this and next event
                    cet = new(c) class'ConEventTrigger';
                    cet.eventType=ET_Trigger;
                    cet.triggerTag = 'BouncerStartAttacking';
                    cet.nextEvent = ces.nextEvent;
                    ces.nextEvent = cet;
                }
            }
            ce = ce.nextEvent;
        }

        break;
    default:
        break;
    }
}

function HandleJohnSmithDeath()
{
    if (dxr.flagbase.GetBool('Disgruntled_Guy_Dead')){ //He's already dead
        return;
    }

    if (!dxr.flagbase.GetBool('Supervisor01_Dead') &&
        dxr.flagbase.GetBool('Have_ROM') &&
        !dxr.flagbase.GetBool('Disgruntled_Guy_Return_Played'))
    {
        dxr.flagbase.SetBool('Disgruntled_Guy_Dead',true);
        //We could send a death message here?
    }
}
