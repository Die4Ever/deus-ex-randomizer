class DXRFixupM06 extends DXRFixup;

var bool raidStarted;

function CheckConfig()
{
    local Rotator rot;
    local int i;

    //#region Add Datacubes
    add_datacubes[i].map = "06_HONGKONG_VERSALIFE";
    add_datacubes[i].text = "Versalife employee ID: 06288.  Use this to access the VersaLife elevator north of the market.";
    add_datacubes[i].Location = vect(350,1950,200); //Middle cube on middle floor
    add_datacubes[i].plaintextTag = "VersalifeMainElevatorCode";
    i++;

    add_datacubes[i].map = "06_HONGKONG_STORAGE";
    add_datacubes[i].text = "Access code to the Versalife nanotech research wing: 55655.";
    add_datacubes[i].Location = vect(-480,-550,570); //Room with cabinet
    add_datacubes[i].plaintextTag = "VersalifeNanotechCode";
    i++;

    add_datacubes[i].map = "06_HONGKONG_WANCHAI_MARKET";
    add_datacubes[i].text = "This new ATM in the market is in such a convenient location for all my banking needs!|nAccount: 8326942 |nPIN: 7797 ";
    add_datacubes[i].Location = vect(360,-1120,40); //Pottery shop counter
    add_datacubes[i].plaintextTag = "MarketATMPassword";
    i++;

    add_datacubes[i].map = "06_HONGKONG_WANCHAI_STREET";
    add_datacubes[i].text = "It's so handy being able to quickly grab some cash from the Quick Stop before getting to the club!|nAccount: 2332316 |nPIN: 1608 ";
    add_datacubes[i].Location = vect(-330,-700,1700); //Under Construction floor
    add_datacubes[i].plaintextTag = "QuickStopATMPassword";
    i++;

    add_datacubes[i].map = "06_HONGKONG_WANCHAI_STREET";
    add_datacubes[i].text = "Miss Chow,|nOur agents have ascertained the access codes to the police evidence vault in the market.  When you are ready, our agents can enter the vault and remove the evidence located within using the code 87342.|n|nCommander Triolet";
    add_datacubes[i].Location = vect(-300.4, -1544.0, 1970.4);
    rot.Yaw = -2250.0;
    add_datacubes[i].rotation = rot;
    add_datacubes[i].plaintextTag = "PoliceVaultPassword";
    i++;

    add_datacubes[i].map = "06_HONGKONG_WANCHAI_UNDERWORLD";
    add_datacubes[i].text = "Max,|nIf you need to get into the freezer again, I've connected the door to the security terminal in the meeting room.|n|nLogin: LUCKYMONEY |nPassword: REDARROW |n|nRemember, that's the same account as your own computer.";
    add_datacubes[i].Location = vect(367,-2511,-334);
    add_datacubes[i].plaintextTag = "LuckyMoneyPassword";
    i++;
    //#endregion

    Super.CheckConfig();
}

function MakeLumpathPissedTrigger(Vector loc, float rad, float height)
{
    local #var(prefix)FlagTrigger ft;

    ft = Spawn(class'#var(prefix)FlagTrigger',,, loc);
    ft.SetCollision(true, false, false);
    ft.SetCollisionSize(rad, height);
    ft.bSetFlag = false;
    ft.bTrigger = true;
    ft.FlagName = 'QuickLetPlayerIn';
    ft.FlagValue = false;
    ft.Tag = 'Breakintocompound';
    ft.Event = 'LumpathPissed';
    ft.bTriggerOnceOnly = false;
}

//#region Pre First Entry
function PreFirstEntryMapFixes()
{
    local Actor a;
    local #var(prefix)ScriptedPawn p;
    local ElevatorMover e;
    local #var(DeusExPrefix)Mover m;
    local #var(prefix)AllianceTrigger at;
    local DeusExMover d;
    local DataLinkTrigger dt;
    local ComputerSecurity cs;
    local #var(prefix)ComputerPersonal cp;
    local #var(prefix)Keypad pad;
    local ProjectileGenerator pg;
    local #var(prefix)WeaponNanoSword dts;
    local #var(prefix)RatGenerator rg;
    local #var(prefix)Credits creds;
    local #var(prefix)Greasel g;
    local #var(prefix)FlagTrigger ft;
    local #var(prefix)OrdersTrigger ot;
    local OnceOnlyTrigger oot;
    local #var(prefix)TriadRedArrow bouncer;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local #var(prefix)Button1 button;
    local #var(injectsprefix)Button1 injbutton;
    local #var(prefix)BeamTrigger bt;
    local #var(prefix)LaserTrigger lt;
    local #var(prefix)SpiderBot2 sb;
    local #var(prefix)BreakableGlass bg;
    local DXRButtonHoverHint buttonHint;
    local DXRHoverHint hoverHint;
    local #var(prefix)MJ12Commando commando;
    local WaterCooler wc;
    local Rotator rot;
    local Male1 male;
    local GordonQuick gordon;
    local DXRReinforcementPoint reinforce;
    local Dispatcher disp;
    local #var(prefix)Trigger t;
    local #var(prefix)ControlPanel panel;
    local int i;

    local bool VanillaMaps;

#ifdef injections
    local #var(prefix)DataCube dc;
#else
    local DXRInformationDevices dc;
#endif

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    //#region Helibase
    case "06_HONGKONG_HELIBASE":
        if (VanillaMaps){
            foreach AllActors(class'ProjectileGenerator', pg, 'purge') {
                pg.CheckTime = 0.25;
                pg.spewTime = 0.4;
                pg.ProjectileClass = class'PurgeGas';
                switch(pg.Name) {
                case 'ProjectileGenerator5':// left side
                    pg.SetRotation(rotm(-7000, 80000, 0, GetRotationOffset(pg.class)));
                    break;
                case 'ProjectileGenerator2':// middle left
                    pg.SetRotation(rotm(-6024, 70000, 0, GetRotationOffset(pg.class)));
                    break;
                case 'ProjectileGenerator3':// middle right
                    pg.SetRotation(rotm(-8056, 64000, 0, GetRotationOffset(pg.class)));
                    break;
                case 'ProjectileGenerator7':// right side
                    pg.SetRotation(rotm(-8056, 60000, 0, GetRotationOffset(pg.class)));
                    break;
                }
            }

            //Make the elevator doors trigger Jock firing a missile
            foreach AllActors(class'#var(DeusExPrefix)Mover',m,'elevator_door'){
                m.Event='make_a_break';
                break;
            }

            foreach AllActors(class'#var(injectsprefix)Button1', injbutton) {
                if (injbutton.tag == 'Weapons_Lock_broken' || injbutton.tag == 'Weapons_lock' || injbutton.event == 'missile_door') {
                    injbutton.SetRotation(rotm(14400,16500,0,GetRotationOffset(injbutton.class))); //A similar rotation to original that only rotates in two axes instead of all three
                } else if (injbutton.Event=='elevator_door' && injbutton.ButtonType==BT_Blank){
                    //Both the button inside and outside
                    injbutton.RandoButtonType=RBT_OpenDoors;
                    injbutton.BeginPlay();
                }
            }
        }

        foreach AllActors(class'#var(DeusExPrefix)Mover',m,'robobay'){
            m.bIsDoor=False;
        }
        foreach AllActors(class'#var(DeusExPrefix)Mover',m,'robobay_01'){
            m.bIsDoor=False;
        }
        // nonsensical mover blocking jock's tail
        foreach AllActors(class'#var(DeusExPrefix)Mover',m,'jockweapons'){
            m.NumFragments=0; //So it isn't visible when it's destroyed
            m.ExplodeSound1=None; //So you don't hear it get broken
            m.ExplodeSound2=None;
            m.BlowItUp(None);
        }

        if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
            foreach AllActors(class'#var(prefix)ControlPanel', panel, 'ControlPanel') {
                if(panel.UnTriggerEvent[0] == 'LibElectric') {
                    panel.hackStrength = 0.12;
                    break;
                }
            }
        }

        foreach AllActors(class'#var(prefix)MapExit',exit,'change_floors'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){ //Button won't be replaced yet in non-vanilla, so just use regular Button1
            if (button.Event=='change_floors'){
                break;
            }
        }
        buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
        buttonHint.SetBaseActor(button);

        Spawn(class'PlaceholderItem',,, vectm(1975,-500,845)); //Crate on rooftop
        Spawn(class'PlaceholderItem',,, vectm(1915,395,845)); //Lighter Crate on rooftop
        Spawn(class'PlaceholderItem',,, vectm(-875,125,815)); //Satellites on rooftop
        Spawn(class'PlaceholderItem',,, vectm(1290,-600,155)); //Bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(805,-615,185)); //Urinal divider
        Spawn(class'PlaceholderItem',,, vectm(1215,-370,140)); //Bench near shower lockers
        Spawn(class'PlaceholderItem',,, vectm(1640,185,140)); //Barracks first floor bed
        Spawn(class'PlaceholderItem',,, vectm(-215,-865,185)); //Near Gas Purge Keypad
        Spawn(class'PlaceholderItem',,, vectm(460,610,775)); //Behind Basketball Net

        class'PlaceholderEnemy'.static.Create(self,vectm(769,-520,144));
        class'PlaceholderEnemy'.static.Create(self,vectm(1620,-87,144));
        class'PlaceholderEnemy'.static.Create(self,vectm(-844,-359,816));
        class'PlaceholderEnemy'.static.Create(self,vectm(2036,122,816));
        class'PlaceholderEnemy'.static.Create(self,vectm(755,-364,144),,'Shitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(877,-360,144),,'Shitting');

        break;
    //#endregion

    //#region Tong Base
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
    //#endregion

    //#region Wan Chai Market
    case "06_HONGKONG_WANCHAI_MARKET":
        if (VanillaMaps) {
            // button to get out of Tong's base
            // Revision already has a button in place (In WANCHAI_COMPOUND)
            AddSwitch( vect(1433.658936, 273.360352, -167.364777), rot(0, 16384, 0), 'Basement_door' );
            foreach AllActors(class'#var(injectsprefix)Button1', injbutton) {
                if ((injbutton.Event=='elevator_door' || injbutton.Event=='elevator_door01') && injbutton.ButtonType==BT_Blank){ //Helibase and Versalife elevators
                    injbutton.RandoButtonType=RBT_OpenDoors;
                    injbutton.BeginPlay();
                }
            }
        }
        if (dxr.flagbase.GetBool('DragonHeadsInLuckyMoney')) {
            foreach AllActors(class'GordonQuick', gordon) {
                gordon.LeaveWorld();
                break;
            }
        }
        // fallthrough
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
        //Add teleporter hint text to Jock
        if (VanillaMaps){
            foreach AllActors(class'#var(prefix)MapExit',exit,'outro_trigger'){break;}
        } else {
            foreach AllActors(class'#var(prefix)MapExit',exit,'CameraExit'){break;}
        }
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock,'chopper'){break;}
        if (jock!=None){
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit,, true);
            hoverHint.SetBaseActor(jock);
        }

        //Elevator to Versalife
        foreach AllActors(class'#var(prefix)MapExit',exit,'change_floors01'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){ //Button won't be replaced yet in non-vanilla, so just use regular Button1
            if (button.Event=='change_floors01'){
                break;
            }
        }
        if (button!=None){
            buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
            buttonHint.SetBaseActor(button);
        }

        //Elevator to Helibase
        foreach AllActors(class'#var(prefix)MapExit',exit,'change_floors'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){ //Button won't be replaced yet in non-vanilla, so just use regular Button1
            if (button.Event=='change_floors'){
                break;
            }
        }
        if (button!=None){
            buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
            buttonHint.SetBaseActor(button);
        }

        foreach AllActors(class'#var(prefix)ScriptedPawn',p){
            if (p.BindName=="MarketKid"){
                p.Tag = 'MarketKid';
            }
        }

        foreach AllActors(class'#var(prefix)OrdersTrigger',ot){
            if (ot.Tag=='KidWanders' || ot.Tag=='KidGoesToNewsStand' || ot.Tag=='KidGoesToLumPath'){
                ot.Event='MarketKid';
            }
        }

        if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
            if (VanillaMaps){
                foreach AllActors(class'#var(prefix)OrdersTrigger', ot, 'LumpathPissed') {
                    ot.Destroy();
                    break;
                }

                //Make sure they turn and face you so that they engage immediately if you are uncloaked (like if ordered to Attack)
                class'FacePlayerTrigger'.static.Create(self,'LumpathPissed','TriadLumPath',vect(0,0,0));
                class'FacePlayerTrigger'.static.Create(self,'LumpathPissed','TriadLumPath1',vect(0,0,0));
                class'FacePlayerTrigger'.static.Create(self,'LumpathPissed','TriadLumPath2',vect(0,0,0));
                class'FacePlayerTrigger'.static.Create(self,'LumpathPissed','TriadLumPath3',vect(0,0,0));
                class'FacePlayerTrigger'.static.Create(self,'LumpathPissed','TriadLumPath4',vect(0,0,0));
                class'FacePlayerTrigger'.static.Create(self,'LumpathPissed','TriadLumPath5',vect(0,0,0));
                class'FacePlayerTrigger'.static.Create(self,'LumpathPissed','GordonQuick',vect(0,0,0));

                //Make sure you have plenty of places for them to become hostile
                MakeLumpathPissedTrigger(vectm(750.0, 1130.0, -240.0),600.0, 100.0); //Basement area
                MakeLumpathPissedTrigger(vectm(1650.0, 1130.0, -240.0),600.0, 100.0); //Basement area
                MakeLumpathPissedTrigger(vectm(750.0, 230.0, -240.0),600.0, 100.0); //Basement area
                MakeLumpathPissedTrigger(vectm(1650.0, 230.0, -240.0),600.0, 100.0); //Basement area
                MakeLumpathPissedTrigger(vectm(1365,315,-215),96,150); //Tong's Lab painting
                MakeLumpathPissedTrigger(vectm(-16,825,-120),96,250); //Staircase to basement area
                MakeLumpathPissedTrigger(vectm(1660,1140,90),96,100); //Door from kitchen to hallway
                MakeLumpathPissedTrigger(vectm(1840,680,200),150,100); //Top of stairs down to kitchen
            }
        }
        break;
    //#endregion

    //#region Tonnochi Road
    case "06_HONGKONG_WANCHAI_STREET":
        SetupMaggieGuardBarkFix();
        foreach AllActors(class'#var(prefix)WeaponNanoSword', dts) {
            dts.bIsSecretGoal = true;// just in case you don't have DXRMissions enabled
        }
        if (VanillaMaps){
            foreach AllActors(class'#var(prefix)Button1',button)
            {
                if (button.Event=='JockShaftTop')
                {
                    button.Event='JocksElevatorTop';
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
            foreach AllActors(class'#var(injectsprefix)Button1', injbutton) {
                if ((injbutton.Event=='Eledoor01' || injbutton.Event=='eledoor02') && injbutton.ButtonType==BT_Blank){ //Penthouse and renovation elevators
                    injbutton.RandoButtonType=RBT_OpenDoors;
                    injbutton.BeginPlay();
                }
            }

            foreach AllActors(class'#var(prefix)ScriptedPawn', p, 'MaggieTroop') {
                if(p.Name == 'MJ12Troop4') {
                    p.bIsSecretGoal = true;// don't clone him, he's too close
                }
            }

            class'FakeMirrorInfo'.static.Create(self,vectm(1335,-1663,1736),vectm(1345,-1535,1775)); //Jock's Bathroom
            class'FakeMirrorInfo'.static.Create(self,vectm(1345,-1545,1736),vectm(1280,-1535,1790)); //Jock's Bathroom (right side)
            class'FakeMirrorInfo'.static.Create(self,vectm(-1195,-1065,2285),vectm(-1075,-1045,2245)); //Maggie's Guest Bathroom
            class'FakeMirrorInfo'.static.Create(self,vectm(-1060,-1415,2285),vectm(-1180,-1405,2240)); //Maggie's Master Bathroom

        } else {
            //These mirrors actually work in Revision, so no FakeMirrorInfo required
        }

        //behind Maggie's DispalyCase (sic), there is a Trigger to open it
        //That trigger gets hit when an OrdersTrigger in the same spot gets replaced by DXRReplaceActors
        foreach AllActors(class'#var(prefix)Trigger',t,'Trigger'){
            if (t.Event=='DispalyCase'){
                t.TriggerType=TT_PawnProximity;
            }
        }
        break;
    //#endregion

    //#region Level 1 Labs
    case "06_HONGKONG_MJ12LAB":
        // alarm in MiB's overlook office
        Spawnm(class'#var(injectsprefix)AlarmUnit',, 'SecurityRevoked', vect(253.179993,1055.714844,825.220764), rot(0,32768,0));

        //Trigger the alarm on first entry if the flag is already set (ie. a late HK start)
        if (player().flagBase.GetBool('Have_ROM')){
            foreach AllActors(class'Actor', a,'SecurityRevoked')
            {
                a.Trigger(None,player()); //To match as originally triggered by ComputerScreenSpecialOptions
            }
        }

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
            m.FragmentClass = class'MetalFragment'; // only one of these two doors has any helpful sounds set
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

        foreach AllActors(class'#var(prefix)Greasel', g){
            g.bImportant = True;
            g.BindName = "BoringLabGreasel";
            //The other ones are tagged as Dogs
            if (g.Tag=='Greasel'){
                g.BindName="JerryTheVentGreasel";
                if(dxr.flags.IsBingoMode() || class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
                    g.FamiliarName = "Jerry the Vent Greasel";
                    g.UnfamiliarName = "Jerry the Vent Greasel";
                }
            }
        }

        SpawnDatacubeImage(vectm(-1194.700195,-789.460266,-750.628357), rotm(0,0,0,0),Class'DeusEx.Image15_GrayDisection');

        //Elevator to Versalife
        foreach AllActors(class'#var(prefix)MapExit',exit,'change_floors01'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){
            if (button.Event=='change_floors01'){
                break;
            }
        }
        buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
        buttonHint.SetBaseActor(button);

        //Elevator to Level 2
        foreach AllActors(class'#var(prefix)MapExit',exit,'change_floors'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){
            if (button.Event=='change_floors'){
                break;
            }
        }
        buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
        buttonHint.SetBaseActor(button);

        foreach AllActors(class'#var(injectsprefix)Button1', injbutton) {
            if ((injbutton.Event=='elevator_door' || injbutton.Event=='elevator_door01' || injbutton.Event=='eledoor02') && injbutton.ButtonType==BT_Blank){ //Office, Level 2, and balcony elevators
                injbutton.RandoButtonType=RBT_OpenDoors;
                injbutton.BeginPlay();
            }
        }

        foreach AllActors(class'#var(prefix)AllianceTrigger',at){
            //These alliance triggers didn't have the right tag set,
            //so secretaries and Mr Harrison didn't get mad at you
            if (at.Event=='Secretary' || at.Event=='Businessman1'){
                at.Tag='SecurityRevoked';
            }
        }

        if (dxr.flagbase.GetBool('Meet_MJ12Lab_Supervisor_Played')) { // 70+ starts set this to true
            foreach AllActors(class'#var(prefix)ScriptedPawn', p, 'Businessman1') {
                if (p.BindName == "MJ12Lab_Supervisor") {
                    p.SetOrders('Wandering');
                    break;
                }
            }
        }

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

        class'PlaceholderEnemy'.static.Create(self,vectm(903,-1363,432),,'Shitting',, 'security', 1);
        class'PlaceholderEnemy'.static.Create(self,vectm(709,-1378,432),,'Shitting',, 'security', 1);
        class'PlaceholderEnemy'.static.Create(self,vectm(-1101,2364,-592),,'Shitting',, 'security', 1);
        class'PlaceholderEnemy'.static.Create(self,vectm(-1368,2350,-592),,'Shitting',, 'security', 1);
        class'PlaceholderEnemy'.static.Create(self,vectm(85,1351,816),,'Sitting',, 'security', 1); //Upper lookout room
        class'PlaceholderEnemy'.static.Create(self,vectm(53,1173,816),,'Sitting',, 'security', 1); //Upper Lookout room
        class'PlaceholderEnemy'.static.Create(self,vectm(-1470,-540,-80),,,, 'security', 1); //Catwalk to level 2 lab elevator
        class'PlaceholderEnemy'.static.Create(self,vectm(-1121,-185,-752),,,, 'security', 1); //Between zappy things in lab
        class'PlaceholderEnemy'.static.Create(self,vectm(-829,2811,-592),,,, 'security', 1); //In the shower
        class'PlaceholderEnemy'.static.Create(self,vectm(626,-632,-80),,,, 'security', 1); //Upper level of ROM encoding room
        class'PlaceholderEnemy'.static.Create(self,vectm(-33,155,176),,,, 'security', 1); //Main hall
        class'PlaceholderEnemy'.static.Create(self,vectm(-8,-715,176),,,, 'security', 1); //Main hall
        class'PlaceholderEnemy'.static.Create(self,vectm(1345,-1092,431),,,, 'security', 1); //Conference room
        class'PlaceholderEnemy'.static.Create(self,vectm(-629,1718,-592),,,, 'security', 1); //Barracks


        break;
    //#endregion

    //#region Lucky Money
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
                if(dxr.flags.settings.doorsdestructible >= 90) { // this door can be rough in speedruns
                    d.bBreakable = true;
                    d.minDamageThreshold = 40;
                    d.doorStrength = 0.5;
                }
            }
        }
        foreach AllActors(class'ComputerSecurity',cs){
            if (cs.UserList[0].UserName=="LUCKYMONEY"){
                cs.Views[2].doorTag='FreezerDoor';
            }
        }

        //Move Russ (from LDDP) to the side.  Can't reference the actual class,
        //in case someone doesn't have LDDP installed.
        foreach AllActors(class'#var(prefix)ScriptedPawn',p,'LDDPRuss'){
            p.SetLocation(vectm(-1110,-70,-336));
            p.LookAtVector(vectm(-1190,-2,-316),true,false,false);
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

        //The cops hate shots (which is reasonable normally), but that also means they'll
        //aggro on you if you're killing a commando and they're nearby.  They should hate them
        //to start, but stop hating them when the raid starts.  They also hate distress, so if
        //someone runs past who you distressed, they can get aggroed on you.  We can take that
        //away always, I think.
        foreach AllActors(class'#var(prefix)ScriptedPawn',p,'Beat_Cop'){
            //p.bHateShot=False;
            p.bHateDistress=False;
            p.ResetReactions();
        }

        //Cops run into the club as you exit, after the raid has started
        ft=Spawn(class'#var(prefix)FlagTrigger',,,vectm(-1024,-594,-343));
        ft.bSetFlag=False;
        ft.bTrigger=True;
        ft.FlagName='Raid_Underway';
        ft.SetCollisionSize(160,40);
        ft.flagValue=True;
        ft.Event='SendTheCopsIn';

        ot=Spawn(class'#var(prefix)OrdersTrigger',,'SendTheCopsIn');
        ot.SetCollision(False,False,False);
        ot.Event='Beat_Cop';
        ot.Orders='RunningTo';
        ot.OrdersTag='Cruising01'; //A patrol point inside the club doors

        SetTimer(1.0, True); //Start the timer so we can remove bHateShot once the raid starts

        if(VanillaMaps) {
            foreach AllActors(class'#var(prefix)OrdersTrigger', ot, 'RaidIsOver') {
                ot.Tag = 'ResumeDate';
            }

            ft=Spawn(class'#var(prefix)FlagTrigger',, 'RaidIsOver');
            ft.bSetFlag=False;
            ft.bTrigger=True;
            ft.FlagName='M06JCHasDate';
            ft.flagValue=True;
            ft.Event='CheckResumeDateOver';
            ft.SetCollision(false,false,false);

            ft=Spawn(class'#var(prefix)FlagTrigger',, 'CheckResumeDateOver');
            ft.bSetFlag=False;
            ft.bTrigger=True;
            ft.FlagName='M06DateDone';
            ft.flagValue=false;
            ft.Event='ResumeDate';
            ft.SetCollision(false,false,false);

            class'FakeMirrorInfo'.static.Create(self,vectm(-1840,-592,-255),vectm(-1860,-815,-320)); //Men's Bathroom

            bg = None;
            foreach RadiusActors(class'#var(prefix)BreakableGlass', bg, 10, vectm(-1216,-2048,-320)){break;}
            class'FakeMirrorInfo'.static.Create(self,vectm(-1152,-2056,-256),vectm(-1280,-2052.5,-382), bg); //Left Conference Window

            bg = None;
            foreach RadiusActors(class'#var(prefix)BreakableGlass', bg, 10, vectm(-1024,-2048,-320)){break;}
            class'FakeMirrorInfo'.static.Create(self,vectm(-1088,-2056,-256),vectm(-960,-2052.5,-382), bg); //Middle Conference Window

            bg = None;
            foreach RadiusActors(class'#var(prefix)BreakableGlass', bg, 10, vectm(-832,-2048,-320)){break;}
            class'FakeMirrorInfo'.static.Create(self,vectm(-896,-2056,-256),vectm(-768,-2052.5,-382), bg); //Right Conference Window

        } else {
            //These mirrors actually work in Revision, so no FakeMirrorInfo required
        }

        break;
    //#endregion

    //#region Canal Road
    case "06_HONGKONG_WANCHAI_GARAGE":
        foreach AllActors(class'DeusExMover',d,'secret_door'){
            d.bFrobbable=False;
        }
        foreach AllActors(class'#var(prefix)AllianceTrigger', at) {
            if (at.event == 'crashscene_cops') {
                at.event = 'RumbleCops';
            }
        }
        break;
    //#endregion

    //#region Versalife
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

        foreach AllActors(class'#var(prefix)ComputerPersonal',cp){
            for(i=0;i<ArrayCount(cp.UserList);i++){
                if (cp.UserList[i].UserName=="ALL_SHIFTS"){
                    cp.UserList[i].Password="DATA_ENTRY"; //Make sure all the ALL_SHIFTS accounts have the same password
                }
            }
        }

        //Elevator to Market
        foreach AllActors(class'#var(prefix)MapExit',exit,'change_floors01'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){
            if (button.Event=='change_floors01'){
                break;
            }
        }
        buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
        buttonHint.SetBaseActor(button);

        //Elevator to MJ12 Lab
        foreach AllActors(class'#var(prefix)MapExit',exit,'change_floors'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){
            if (button.Event=='change_floors'){
                break;
            }
        }
        buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
        buttonHint.SetBaseActor(button);

        foreach AllActors(class'#var(injectsprefix)Button1', injbutton) {
            if ((injbutton.Event=='LobbyDoor' || injbutton.Event=='elevator_door') && injbutton.ButtonType==BT_Blank){ //Market and Level 1 elevators
                injbutton.RandoButtonType=RBT_OpenDoors;
                injbutton.BeginPlay();
            }
        }

        if (VanillaMaps) {
            foreach RadiusActors(class'WaterCooler', wc, 1.0, vectm(-1000.329651, 155.701721, 201.670242)) {
                // this water cooler faces the wall normally
                rot = wc.Rotation;
                rot.yaw += 32768;
                wc.SetRotation(rot);
                break;
            }
        }

        //Verified in both vanilla and Revision
        class'FakeMirrorInfo'.static.Create(self,vectm(-1152,425,-15),vectm(-1024,430,80)); //Security Window
        class'FakeMirrorInfo'.static.Create(self,vectm(-1008,425,-15),vectm(-880,430,80)); //Security Window
        class'FakeMirrorInfo'.static.Create(self,vectm(-864,425,-15),vectm(-736,430,80)); //Security Window
        class'FakeMirrorInfo'.static.Create(self,vectm(-720,400,-15),vectm(-710,256,80)); //Security Window

        Spawn(class'PlaceholderItem',,, vectm(12.36,1556.5,-51)); //1st floor front cube
        Spawn(class'PlaceholderItem',,, vectm(643.5,2139.7,-51.7)); //1st floor back cube
        Spawn(class'PlaceholderItem',,, vectm(210.94,2062.23,204.3)); //2nd floor front cube
        Spawn(class'PlaceholderItem',,, vectm(464,1549.45,204.3)); //2nd floor back cube
        Spawn(class'PlaceholderItem',,, vectm(217.1,2027.76,460.3)); //3rd floor front cube
        Spawn(class'PlaceholderItem',,, vectm(607.54,1629.1,460.3)); //3rd floor back cube
        Spawn(class'PlaceholderItem',,, vectm(-914.38,255.5,458.3)); //3rd floor breakroom table
        Spawn(class'PlaceholderItem',,, vectm(-836.9,850.3,-9.7)); //Reception desk back

        break;
    //#endregion

    //#region Level 2 Labs
    case "06_HONGKONG_STORAGE":
        //Make sure Maggie always has her MaggieChowShowdown conversation with you if she's here.
        //Mark her as having Fled as you enter the lower section of the UC (This prevents her conversations from the apartment from playing)
        //Remove the requirement for M07Briefing_Played for the conversation (Done in AnyEntry)
        ft= Spawn(class'#var(prefix)FlagTrigger',,, vectm(-2.5,-3,-848));
        ft.SetCollisionSize(1000,5);
        ft.FlagName='MaggieFled';
        ft.bTrigger=False;
        ft.bSetFlag=True;
        ft.flagValue=True;
        ft.flagExpiration=8;

        //Elevator to MJ12 Lab
        foreach AllActors(class'#var(prefix)MapExit',exit,'change_floors'){break;}
        foreach AllActors(class'#var(prefix)Button1',button){
            if (button.Event=='change_floors'){
                break;
            }
        }
        buttonHint = DXRButtonHoverHint(class'DXRButtonHoverHint'.static.Create(self, "", button.Location, button.CollisionRadius+5, button.CollisionHeight+5, exit));
        buttonHint.SetBaseActor(button);

        foreach AllActors(class'#var(injectsprefix)Button1', injbutton) {
            if (injbutton.Event=='elevator_door' && injbutton.ButtonType==BT_Blank){ //Level 1 elevator
                injbutton.RandoButtonType=RBT_OpenDoors;
                injbutton.BeginPlay();
            }
        }

        //Swap BeamTriggers to LaserTrigger, since these lasers set off an alarm
        foreach AllActors(class'#var(prefix)BeamTrigger',bt){
            lt = #var(prefix)LaserTrigger(SpawnReplacement(bt,class'#var(prefix)LaserTrigger'));
            lt.TriggerType=bt.TriggerType;
            lt.bTriggerOnceOnly = bt.bTriggerOnceOnly;
            lt.bDynamicLight = bt.bDynamicLight;
            lt.bIsOn = bt.bIsOn;
            bt.Destroy();
        }

        foreach AllActors(class'#var(prefix)MJ12Commando', commando) {
            if (commando.BarkBindName == "MJ12 Commando" || commando.BarkBindName == "") {
                commando.BarkBindName = "MJ12Commando";
            }
        }

        //The ramp can just be frobbed normally (unintentional, presumably, since it isn't highlightable either)
        foreach AllActors(class'#var(DeusExPrefix)Mover',m,'FloodDoor08'){
            //Really make sure the randomizer knows you shouldn't be able to interact with it
            m.bFrobbable=False;
            m.bHighlight=False;
            m.bIsDoor=False;
            m.bLocked=False;
            m.bBreakable=False;
        }


        //Make sure the spider bot doors can't be closed again
        foreach AllActors(class'#var(DeusExPrefix)Mover',m,'Self_Destruct'){
            m.Tag='Self_Destruct_Once';
        }
        oot = Spawn(class'OnceOnlyTrigger');
        oot.Event='Self_Destruct_Once';
        oot.Tag='Self_Destruct';

        if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){

            //The lockdown door should only close once the UC has been destroyed,
            //so that there's always an exit available.
            foreach AllActors(class'#var(DeusExPrefix)Mover',m,'VirusUploaded'){
                m.Tag='LockdownDoorClosing';
                break;
            }
            oot = Spawn(class'OnceOnlyTrigger');
            oot.Event='LockdownDoorClosing';
            oot.Tag='Self_Destruct';

            //The sleeping bots are already hostile, but are sitting in Idle state.
            //The existing orders trigger can just change them to Wandering instead of Attacking
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'WakeTheSleepingBots'){
                ot.Orders='Wandering';
                break;
            }

            /*
            //The spiderbots normally have Attacking orders.  Make them move to the keypad instead.
            //The pathing on these guys is totally hosed and needs more investigation
            reinforce=Spawn(class'DXRReinforcementPoint',,'SpiderBotDest',vectm(0,700,-1000));

            foreach AllActors(class'#var(prefix)SpiderBot2', sb){
                sb.SetOrders('Standing','',True);
                sb.Tag='SelfDestructSpiders';
                sb.SetHomeBase(reinforce.Location,,200);
            }

            disp = Spawn(class'Dispatcher',, 'Self_Destruct' );
            disp.OutEvents[0]='Self_Destruct_After';
            disp.OutDelays[0]=3;

            ot = Spawn(class'#var(prefix)OrdersTrigger',,'Self_Destruct_After');
            ot.SetCollision(False,False,False);
            ot.Orders='GoingTo';
            ot.ordersTag='SpiderBotDest';
            ot.Event='SelfDestructSpiders';
            */

        }

        //Verified in both vanilla and Revision
        foreach AllActors(class'#var(prefix)BreakableGlass', bg, 'BreakableGlass'){break;}
        class'FakeMirrorInfo'.static.Create(self,vectm(121,-672,1086),vectm(63,-628,1146), bg); //Breakable Corner Mirror

        Spawn(class'PlaceholderItem',,, vectm(-39.86,-542.35,570.3)); //Computer desk
        Spawn(class'PlaceholderItem',,, vectm(339.25,-2111.46,506.3)); //Near lasers
        Spawn(class'PlaceholderItem',,, vectm(1169,-1490,459)); //Water pool
        Spawn(class'PlaceholderItem',,, vectm(1079.73,-1068.17,842.4)); //Pipes above water
        Spawn(class'PlaceholderItem',,, vectm(90,-666,1030)); //Under corner mirror
        Spawn(class'PlaceholderItem',,, vectm(175,-2515,855)); //Pit near security computer
        Spawn(class'PlaceholderItem',,, vectm(75,-1730,905)); //Lower hallway alcove
        Spawn(class'PlaceholderItem',,, vectm(-90,-2320,1030)); //Upper Hallway near computer
        Spawn(class'PlaceholderItem',,, vectm(-800,-650,1030)); //Upper Hallway near elevator
        Spawn(class'PlaceholderItem',,, vectm(510,-1450,860)); //Lower Hallway near where you drop in
        Spawn(class'PlaceholderItem',,, vectm(790,-1360,810)); //Another pipe in the water pool area

        Spawn(class'PlaceholderContainer',,, vectm(160.7,-1589.4,545)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vectm(-159.23,-1300.16,544.1)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vectm(158.5,-1011.84,544.11)); //Robot alcove
        Spawn(class'PlaceholderContainer',,, vectm(691.3,-358.4,-1007.9)); //Near UC
        Spawn(class'PlaceholderContainer',,, vectm(174,-2862,1057)); //Near upper security computer

        if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
            p=MJ12Clone1(Spawnm(class'MJ12Clone1',,, vect(635,0,-65),rot(0,32768,0))); //Should he just be a PlaceholderEnemy now?
            p.SetAlliance('MJ12');
            ChangeInitialAlliance(p,'Player',-1,true);
            p.InitializePawn();
        }
        class'PlaceholderEnemy'.static.Create(self,vectm(0,0,-75)); //Middle of room with 4 containers
        class'PlaceholderEnemy'.static.Create(self,vectm(0,0,565)); //Walkway over UC room
        class'PlaceholderEnemy'.static.Create(self,vectm(75,-1515,1075)); //Upper hallway (to keep it likely for there to be enemies up there)
        break;
    //#endregion

    //#region Canal
    case "06_HONGKONG_WANCHAI_CANAL":

        //Give the drug dealer and pusher 100 credits each, and make them defend each other if attacked
        foreach AllActors(class'#var(prefix)ScriptedPawn',p){
            if (p.BindName=="Canal_Thug1" || p.BindName=="Canal_Thug2"){
                GiveItem(p,class'#var(prefix)Credits');
                p.bHateDistress = true;
                p.bHateIndirectInjury = true;
                p.bHateInjury = true;
                p.ResetReactions();
            }
        }

        //Just a few that can spawn on top of the ship to maybe coax people down there?
        Spawn(class'PlaceholderContainer',,, vectm(2305.5,-512.4,-415)); //On top of cargo ship
        Spawn(class'PlaceholderContainer',,, vectm(2362.5,-333.4,-383.9)); //On top of cargo ship
        Spawn(class'PlaceholderContainer',,, vectm(2403,-777,-359)); //On top of cargo ship
        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(3237,3217,-506));//Lower garage storage area
        rg.MaxCount=3;
        break;
    //#endregion
    default:
        break;
    }
}
//#endregion

//#region Post First Entry
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
    case "06_HONGKONG_VERSALIFE":
        foreach AllActors(class'Male1',male){
            if (male.BindName=="Disgruntled_Guy"){
                male.bImportant=True;
            }
        }
        break;
    }
}
//#endregion

function SetupMaggieGuardBarkFix()
{
    local #var(prefix)MJ12Troop t;
    local BarkBindTrigger bbt;

    foreach AllActors(class'#var(prefix)MJ12Troop',t,'MaggieTroop')
    {
        //Remove their default bark bind names
        t.BarkBindName=""; //Default is "MJ12Troop"
        t.ConBindEvents();
    }

    //Add BarkBindTriggers
    //Main entrance
    class'BarkBindTrigger'.static.Create(self,'MaggieTroop',"MJ12Troop", vectm(-943,-448,2024),50,40);
    //Buddha entrance
    class'BarkBindTrigger'.static.Create(self,'MaggieTroop',"MJ12Troop", vectm(-1295, -1174, 2024),50,40);
    //Rooftop entrance
    class'BarkBindTrigger'.static.Create(self,'MaggieTroop',"MJ12Troop", vectm(-1297,-1268,2405),50,40);
    //Floor below entrance
    bbt=class'BarkBindTrigger'.static.Create(self,'MaggieTroop',"MJ12Troop", vectm(-1203, -934, 1736),50,40);

    bbt.Tag = 'Onalert'; //Make the triggers also go off when the alarm triggers
}

function FixMaggieMoveSpeed()
{
    local #var(prefix)MaggieChow maggie;
    foreach AllActors(class'#var(prefix)MaggieChow',maggie){
        maggie.GroundSpeed = 180;
        maggie.walkAnimMult = 1;
    }
}

//#region Any Entry
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
    local OrdersTrigger ot;
    local #var(prefix)Pigeon pigeon;
    local #var(prefix)MaggieChow maggie;
    local #var(prefix)Maid maysung;

    // if flag Have_ROM, set flags Have_Evidence and KnowsAboutNanoSword?
    // or if flag Have_ROM, Gordon Quick should let you into the compound? requires Have_Evidence and MaxChenConvinced

    c = GetConversation('MarketLum1Barks');
    FixConversationFlagJump(c, 'Versalife_Done', true, 'M08Briefing_Played', true);
    c = GetConversation('MarketLum2Barks');
    FixConversationFlagJump(c, 'Versalife_Done', true, 'M08Briefing_Played', true);

    switch(dxr.localURL)
    {
    //#region Tong Base
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
    //#endregion

    //#region Wan Chai Market
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
                case "TriadLumPath_clone":
                case "TriadLumPath1_clone":
                case "TriadLumPath2_clone":
                case "TriadLumPath3_clone":
                case "TriadLumPath4_clone":
                case "TriadLumPath5_clone":
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
    //#endregion

    //#region Versalife
    case "06_HONGKONG_VERSALIFE":
        // allow you to get the code from him even if you've been to the labs, to fix backtracking
        DeleteConversationFlag( GetConversation('Disgruntled_Guy_Convos'), 'VL_Found_Labs', false);
        GetConversation('Disgruntled_Guy_Return').AddFlagRef('Disgruntled_Guy_Done', true);
        break;
    //#endregion

    //#region Tonnochi Road
    case "06_HONGKONG_WANCHAI_STREET":
        foreach AllActors(class'#var(DeusExPrefix)Mover', m, 'JockShaftTop') {
            m.bLocked = false;
            m.bHighlight = true;
        }

        HandleJohnSmithDeath();
        FixMaggieMoveSpeed();

        if (dxr.flagbase.GetBool('MaxChenConvinced')) {
            foreach AllActors(class'#var(prefix)MaggieChow', maggie) {
                maggie.LeaveWorld();
                break;
            }

            dxr.flagbase.SetBool('MeetMaySung_Played', true);
            foreach AllActors(class'OrdersTrigger', ot, 'MaySungFollows') {
                ot.Trigger(None, None);
                break;
            }
        }

        break;
    //#endregion

    //#region Canals
    case "06_HONGKONG_WANCHAI_CANAL":
        HandleJohnSmithDeath();
        if (dxr.flagbase.GetBool('Disgruntled_Guy_Dead')){
            foreach AllActors(class'#var(DeusExPrefix)Carcass', carc, 'John_Smith_Body') {
                if (dxr.flags.settings.goals <= 0) {
                    if (carc.bHidden) {
                        carc.bHidden = false;
                        carc.ItemName = "John Smith (Dead)";
                    } else {
                        break;
                    }
                } else if (NervousWorkerCarcass(carc) == None) {
                    carc = carc.Spawn(class'NervousWorkerCarcass', carc, carc.Tag);
                    carc.Owner.Destroy();
                } else {
                    break;
                }

                #ifdef injections
                //HACK: to be removed once the problems with Carcass2 are fixed/removed
                carc.mesh = LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassC';  //His body starts in the water, so this is fine
                carc.SetMesh2(LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassB');
                carc.SetMesh3(LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassC');
                #endif

                break;
            }
        }
        break;
    //#endregion

    //#region Level 1 Labs
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
    //#endregion

    //#region Lucky Money
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
    //#endregion

    //#region level 2 Labs
    case "06_HONGKONG_STORAGE":
        //Make sure Maggie always has her MaggieChowShowdown conversation with you if she's here.
        //Mark her as having Fled as you enter the lower section of the UC (This prevents her conversations from the apartment from playing) - Done in PreFirstEntry
        //Remove the requirement for M07Briefing_Played for the conversation (This allows the conversation to trigger if you went out of order - maybe normally, maybe entrance rando)
        DeleteConversationFlag(GetConversation('MaggieChowShowdown'), 'M07Briefing_Played', true);
        FixMaggieMoveSpeed();
        break;
    //#endregion
    default:
        break;
    }
}
//#endregion

//#region Timer
function TimerMapFixes()
{
    local #var(prefix)ScriptedPawn sp;

    switch(dxr.localURL)
    {
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        if (!raidStarted && dxr.flagbase.GetBool('Raid_Underway') )
        {
            foreach AllActors(class'#var(prefix)ScriptedPawn', sp, 'Beat_Cop'){
                sp.bHateShot=False;
                sp.ResetReactions();
            }
            raidStarted=True;
        }
        break;
    }
}
//#endregion


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
