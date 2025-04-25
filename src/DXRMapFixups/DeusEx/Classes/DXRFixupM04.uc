class DXRFixupM04 extends DXRFixup;

var int old_pawns;// used for NYC_04_CheckPaulRaid()

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "04_NYC_UNATCOHQ";
    add_datacubes[i].text = "Note to self:|nUsername: JCD|nPassword: bionicman ";
    add_datacubes[i].Location = vect(-210,1290,290); //JC's Desk
    add_datacubes[i].plaintextTag = "JCCompPassword";
    i++;

    Super.CheckConfig();
}

//#region PreTravel
function PreTravelMapFixes()
{
    switch(dxr.localURL) {
    case "04_NYC_HOTEL":
        if(#defined(vanilla))
            NYC_04_LeaveHotel();
        break;
    }
}
//#endregion

//#region Pre First Entry
function PreFirstEntryMapFixes()
{
    local Actor a;
    local #var(prefix)FlagTrigger ft;
    local #var(prefix)DatalinkTrigger dt;
    local #var(prefix)OrdersTrigger ot;
    local SkillAwardTrigger st;
    local #var(prefix)BoxSmall b;
    local #var(prefix)HackableDevices hd;
    local #var(prefix)UNATCOTroop lloyd, troop;
    local #var(prefix)AutoTurret turret;
    local #var(prefix)ControlPanel panel;
    local #var(prefix)LaserTrigger laser;
    local #var(prefix)Containers c;
    local #var(prefix)Karkian k;
    local AllianceTrigger at;
    local BlockPlayer bp;
    local #var(DeusExPrefix)Mover door;
    local #var(prefix)NanoKey key;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)GuntherHermann gunther;
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)GilbertRenton gilbert;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local #var(prefix)JoJoFine jojo;
    local OnceOnlyTrigger oot;
    local DXRHoverHint hoverHint;
    local DXRMapVariants mapvariants;
    local bool VanillaMaps;
    local #var(prefix)HumanCivilian hc;
    local Teleporter tel;
    local DynamicTeleporter dtel;
    local #var(prefix)ComputerPublic compublic;
    local #var(prefix)LaserTrigger lt;
    local #var(prefix)Datacube dc;
    local Smuggler smug;
    local DXRReinforcementPoint reinforce;
    local #var(prefix)CrateExplosiveSmall boom;
    local #var(prefix)Trigger trig;
    local #var(PlayerPawn) p;

    p = player();
    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(p);

    switch (dxr.localURL)
    {
    //#region Hotel
    case "04_NYC_HOTEL":
        if (#defined(vanilla)){
            foreach AllActors(class'#var(prefix)OrdersTrigger', ot, 'PaulSafe') {
                if( ot.Orders == 'Leaving' )
                    ot.Orders = 'Seeking';
            }
            foreach AllActors(class'#var(prefix)FlagTrigger', ft) {
                if( ft.Event == 'PaulOutaHere' )
                    ft.Destroy();
            }
            foreach AllActors(class'SkillAwardTrigger', st) {
                if( st.Tag == 'StayedWithPaul' ) {
                    st.skillPointsAdded = 100;
                    st.awardMessage = "Stayed with Paul";
                    st.Destroy();// HACK: this trigger is buggy for some reason, just forget about it for now
                }
                else if( st.Tag == 'PaulOutaHere' ) {
                    st.skillPointsAdded = 500;
                    st.awardMessage = "Saved Paul";
                }
            }
        }

        foreach AllActors(class'#var(prefix)CrateExplosiveSmall',boom,'BlowDoor'){
            //TNT crate explodes when the MIBs are ordered to move in, instead of
            //when the MIB actually starts moving (in case he's gassed or something)
            boom.Tag='RaidBegin';

            //Put a trigger on the crate as well with big radius, just in case someone else tries to run in first
            //This can happen if you, for example, gas the big group on the upper floor, but not the single MIB
            //near the elevator (he gets aggroed by the grenade, but locked in place until the conversation is over,
            //since he's involved in it).
            ft = Spawn(class'#var(prefix)FlagTrigger',,,boom.Location);
            ft.TriggerType=TT_ClassProximity;
            ft.SetCollisionSize(300,40); //Basically as big as it can be without hitting the MIB near the elevator
            //ft.ClassProximityType=class'#var(prefix)MIB';
            ft.ClassProximityType=class'#var(prefix)HumanMilitary';
            ft.event = boom.Tag;
            ft.bSetFlag=False;
            ft.bTrigger=True;
            ft.FlagName='M04RaidTeleportDone'; //Don't trigger as extra enemies spawn in on first entry (particularly Serious Sam mode)
            ft.flagValue=True;
        }

        class'GilbertWeaponMegaChoice'.static.Create(p);
        foreach AllActors(class'#var(prefix)GilbertRenton',gilbert){
            //Make sure he has ammo for Stealth Pistol(10mm), Pistol (10mm),
            //Sawed-off (Buckshot shells), Mini Crossbow (Tranq Darts)
            GiveItem(gilbert, class'AmmoShell',20);
            GiveItem(gilbert, class'Ammo10mm',20);
            GiveItem(gilbert, class'AmmoDartPoison',20);
            break;
        }

        foreach AllActors(class'#var(prefix)JoJoFine',jojo){
            jojo.BarkBindName="JoJoFine";
        }

        if (VanillaMaps){
            Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table

            if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
                key = Spawn(class'#var(prefix)NanoKey',,, vectm(-967,-1240,-74)); //In a mail nook
                key.KeyID = 'CrackRoom';
                key.Description = "'Ton Hotel, North Room Key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(key);

                key = Spawn(class'#var(prefix)NanoKey',,, vectm(-845,-2920,180)); //Top shelf of Paul's closet
                key.KeyID = 'Apartment';
                key.Description = "Apartment key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(key);

                SpawnDatacubeTextTag(vectm(-840,-2920,85), rotm(0,0,0,0), '02_Datacube07',False); //Paul's stash code, in bottom of closet
            }

            foreach RadiusActors(class'#var(DeusExPrefix)Mover', door, 1.0, vectm(-304.0, -3000.0, 64.0)) {
                // interpolate Paul's bathroom door to its starting position so it doesn't close instantaneously when frobbed
                door.InterpolateTo(1, 0.0);
                break;
            }

            Spawn(class'PlaceholderItem',,, vectm(-732,-2628,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-732,-2712,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-129,-3038,127)); //Bathroom counter
            Spawn(class'PlaceholderItem',,, vectm(15,-2972,123)); //Kitchen counter
            Spawn(class'PlaceholderItem',,, vectm(-853,-3148,75)); //Crack next to Paul's bed
        } else {
            Spawn(class'#var(prefix)Binoculars',,, vectm(-90,-3958,95)); //Paul's bedside table

            if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
                key = Spawn(class'#var(prefix)NanoKey',,, vectm(-900,-1385,-74)); //In a mail nook
                key.KeyID = 'Hotelroom1'; //CrackRoom doesn't exist in Revision M04 - doesn't hurt to add a key to a different room instead
                key.Description = "'Ton Hotel, South Room Key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(key);

                key = Spawn(class'#var(prefix)NanoKey',,, vectm(-900,-1415,-55)); //In a different mail nook
                key.KeyID = 'Hotelroom2'; //CrackRoom doesn't exist in Revision M04 - doesn't hurt to add a key to a different room instead
                key.Description = "'Ton Hotel, Northwest Room Key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(key);

                key = Spawn(class'#var(prefix)NanoKey',,, vectm(-300,-3630,180)); //Top shelf of Paul's closet
                key.KeyID = 'Apartment';
                key.Description = "Apartment key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(key);

                SpawnDatacubeTextTag(vectm(-295,-3655,85), rotm(0,0,0,0), '02_Datacube07',False); //Paul's stash code, in bottom of closet
            }

            Spawn(class'PlaceholderItem',,, vectm(-180,-3365,70)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-180,-3450,70)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(480,-3775,125)); //Bathroom counter
            Spawn(class'PlaceholderItem',,, vectm(550,-3700,120)); //Kitchen counter
            Spawn(class'PlaceholderItem',,, vectm(-310,-3900,75)); //Crack next to Paul's bed
        }
        break;
    //#endregion

    //#region NSF HQ
    case "04_NYC_NSFHQ":
        if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
            foreach AllActors(class'#var(prefix)AutoTurret', turret) {
                turret.Event = '';
                turret.Destroy();
            }
            foreach AllActors(class'#var(prefix)ControlPanel', panel) {
                panel.Event = '';
                panel.Destroy();
            }
            foreach AllActors(class'#var(prefix)LaserTrigger', laser) {
                laser.Event = '';
                laser.Destroy();
            }
            foreach AllActors(class'#var(prefix)Containers', c) {
                if(#var(prefix)BoxLarge(c) != None || #var(prefix)BoxSmall(c) != None
                    || #var(prefix)CrateUnbreakableLarge(c) != None || #var(prefix)CrateUnbreakableMed(c) != None)
                {
                    c.SetCollision(false,false,false);
                    foreach c.BasedActors(class'Actor', a) {
                        a.SetLocation(a.Location - c.CollisionHeight*vect(0,0,2));
                    }
                    c.Event = '';
                    c.Destroy();
                }
            }
            foreach AllActors(class'#var(prefix)HackableDevices', hd) {
                hd.hackStrength /= 3.0;
            }
            foreach AllActors(class'#var(prefix)UNATCOTroop',troop,'UNATCOGateGuard'){
                troop.Destroy();
            }
        }

        foreach AllActors(class'#var(DeusExPrefix)Mover',door,'ExitDoor'){
            door.KeyIDNeeded='BasementDoor';
        }

        if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
            k = #var(prefix)Karkian(Spawnm(class'#var(prefix)Karkian',,, vect(54.688416, 1208.957275, -237.351410), rot(0,32768,0)));
            k.BindName="NSFMinotaur";
            k.bImportant = true;
            k.ChangeAlly('Player', -1, false);
            k.SetOrders('Standing');
            k.SetCollisionSize(k.CollisionRadius*0.3,k.CollisionHeight); //Make him more slim so he can squeeze through the doors better
        }

        //Button to open basement hatch from inside
        AddSwitch( vect(-558.536499,-426.806915,-16.069786), rot(0, 0, 0), 'BasementHatch');

        foreach AllActors(class'#var(prefix)UNATCOTroop', troop) {
            if (troop.BindName=="UNATCOGateGuard" ||
                troop.BindName=="TrooperTalking1" ||
                troop.BindName=="TrooperTalking2" )
            {
                troop.bIsSecretGoal=True;
            }
        }

        if (VanillaMaps){
            //One window on the roof doesn't have a FlagTrigger to make UNATCO hate you.  Add it back.
            ft = Spawn(class'#var(prefix)FlagTrigger',, 'SendingSignal3',vectm(233.9,693.64,1016.1));
            ft.SetCollisionSize(128,40);
            ft.bSetFlag=False;
            ft.bTrigger=True;
            ft.FlagName='NSFSignalSent';
            ft.flagValue=True;
            ft.Event='UNATCOHatesPlayer';

            foreach AllActors(class'Teleporter', tel) {
                if (tel.url == "04_NYC_Street#FromNSFHQ") {
                    tel.SetCollisionSize(tel.CollisionRadius, tel.CollisionHeight + 40.0);
                    break;
                }
            }
        }

        // allow Paul dialog to repeat, especially if you try to send the signal without aligning the dishes
        foreach AllActors(class'#var(prefix)DatalinkTrigger', dt, 'SendingSignal') {
            if(dt.datalinkTag == 'DL_PaulGoodJob') {
                dt.bTriggerOnceOnly = false;
            }
        }

        if(dxr.flags.settings.goals > 0) {
            foreach AllActors(class'#var(prefix)DatalinkTrigger', dt, 'DataLinkTrigger') {
                if(dt.datalinkTag != 'DL_SimonsPissed') continue;
                dt.Tag = 'UNATCOHatesPlayer';
                break;
            }
        }
        if (VanillaMaps){
            foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'SendingSignal') {
                ft.Tag = 'SendingSignal2';
                if(dxr.flags.settings.goals > 0) {
                    // immediately change alliances and trigger walt's dialog, but only if the goals are randomized (player won't be near the old triggers)
                    ft.Event = 'UNATCOHatesPlayer';
                }
                ft.bTrigger = true;
                // spawn intermediate trigger to check flag
                ft = Spawn(class'#var(prefix)FlagTrigger',, 'SendingSignal', ft.Location+vectm(10,10,10));
                ft.SetCollision(false,false,false);
                ft.bSetFlag=False;
                ft.bTrigger=True;
                ft.FlagName='CanSendSignal';
                ft.flagValue=True;
                ft.Event='SendingSignal2';
                break;
            }
        } else { //Revision
            //After the signal has been sent correctly (SentSignalCorrectly), trigger the WaltonSimons DataLinkTrigger
            foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'SentSignalCorrectly') {
                if(dxr.flags.settings.goals > 0) {
                    // immediately change alliances and trigger walt's dialog, but only if the goals are randomized (player won't be near the old triggers)
                    ft.bTrigger=True; //Make sure it triggers through as well
                    ft.Event = 'UNATCOHatesPlayer';
                }
                break;
            }
        }


        Spawn(class'PlaceholderItem',,, vectm(110.869766, 337.987732, 1034.306885)); // next to vanilla transmitter computer
        class'PlaceholderEnemy'.static.Create(self,vectm(485,1286,64),,'Shitting',,'UNATCO',1);
        class'PlaceholderEnemy'.static.Create(self,vectm(672,1268,64),,'Shitting',,'UNATCO',1);
        class'PlaceholderEnemy'.static.Create(self,vectm(-435,9,-208),,,,'UNATCO',1);
        class'PlaceholderEnemy'.static.Create(self,vectm(1486,1375,-208),,,,'UNATCO',1);
        class'PlaceholderEnemy'.static.Create(self,vectm(-438,1120,544),,,,'UNATCO',1);
        class'PlaceholderEnemy'.static.Create(self,vectm(-89,1261,304),,,,'UNATCO',1);

        if(class'MenuChoice_BalanceMaps'.static.MinorEnabled()) {
            dxr.flagbase.SetBool('DXRando_NSFHQVisited', true,, 5);
        }

        break;
    //#endregion

    //#region UNATCO Island
    case "04_NYC_UNATCOISLAND":
        if(class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
            foreach AllActors(class'#var(prefix)UNATCOTroop', lloyd) {
                if(lloyd.BindName != "PrivateLloyd") continue;
                lloyd.FamiliarName = "Sergeant Lloyd";
                lloyd.UnfamiliarName = "Sergeant Lloyd";
                lloyd.bImportant = true;
            }
        }

        // Make sure Anna is considered to have killed Lebedev if you left him alive with her
        if (!dxr.flagbase.GetBool('AnnaNavarre_Dead') &&
            !dxr.flagbase.GetBool('JuanLebedev_Dead')) {

            dxr.flagbase.SetBool('AnnaKilledLebedev',True,,999);
            dxr.flagbase.SetBool('JuanLebedev_Dead',True,,999);
        }

        // Make sure you are correctly attributed as having killed Anna if she's dead
        // (You can skip the infolink that marks this flag if she runs away)
        if (dxr.flagbase.GetBool('AnnaNavarre_Dead') &&
            !dxr.flagbase.GetBool('M03PlayerKilledAnna')) {

            dxr.flagbase.SetBool('M03PlayerKilledAnna',True,,5);
        }

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
        hoverHint.SetBaseActor(jock);

        SetAllLampsState(,, false, vect(-5723.258798, 1437.040527, -79.614632), 0.01);

        break;
    //#endregion

    //#region UNATCO HQ
    case "04_NYC_UNATCOHQ":
        FixUNATCOCarterCloset();
        FixAlexsEmail();
        MakeTurretsNonHostile(); //Revision has hostile turrets near jail
        SpeedUpUNATCOFurnaceVent();
        RemoveStopWhenEncroach();

        if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
            key = Spawn(class'#var(prefix)NanoKey',,, vectm(965,900,-28));
            key.KeyID = 'JaimeClosetKey';
            key.Description = "MedLab Closet Key Code";
            if(dxr.flags.settings.keysrando > 0)
                GlowUp(key);
        }

        if (VanillaMaps) {
            class'#var(prefix)ComputerPublic'.default.bCollideWorld = false;
            compublic = #var(prefix)ComputerPublic(Spawnm(
                class'#var(prefix)ComputerPublic',,,
                vect(741.36, 1609.34, 298.00),
                rot(0, -16384, 0)
            ));
            compublic.TextPackage = "#var(package)";
            compublic.BulletinTag = '04_BulletinMenuUnatco';

            foreach AllActors(class'#var(prefix)UNATCOTroop', troop) {
                if (troop.FamiliarName == "Scott") {
                     // this matches the other two friendly times you see him, and keeps his name from getting randomized
                     // alternatively, we could make him bImportant and his UnfamiliarName "Scott" in M03 and M04, since you've definitely learned his name by then
                    troop.UnfamiliarName = "UNATCO Trooper";
                }
            }
        }

        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vectm(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vectm(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vectm(-138.5,-790.1,-1.65)); //Anna's bookshelf
        if (VanillaMaps){
            Spawn(class'PlaceholderItem',,, vectm(-27,1651.5,291)); //Breakroom table
            Spawn(class'PlaceholderItem',,, vectm(602,1215.7,295)); //Kitchen Counter

            Spawn(class'PlaceholderItem',,, vectm(2033.8,1979.9,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderItem',,, vectm(2148,2249,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderItem',,, vectm(2433,1384,-85)); //Near MJ12 Door
            Spawn(class'PlaceholderContainer',,, vectm(2384,1669,-95)); //MJ12 Door

        } else {
            //Revision Kitchen/Breakroom is in a different location
            Spawn(class'PlaceholderItem',,, vectm(295,1385,485)); //Breakroom table
            Spawn(class'PlaceholderItem',,, vectm(765,1500,440)); //Kitchen Counter

            //Level 4/MJ12 Lab area is blocked off in Revision, these are alternate locations for those placeholders
            Spawn(class'PlaceholderItem',,, vectm(110,-1050,-20)); //Desk at entrance to jail area
            Spawn(class'PlaceholderItem',,, vectm(1280,-180,-55)); //Next to couch/plant outside medical
            Spawn(class'PlaceholderItem',,, vectm(1335,300,-35)); //Under desk near medical beds
            Spawn(class'PlaceholderContainer',,, vectm(1490,975,-20)); //Near blocked door down to level 4

        }
        Spawn(class'PlaceholderItem',,, vectm(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderItem',,, vectm(-433.128601,736.819763,314.310211)); //Weird electrical thing in closet
        Spawn(class'PlaceholderContainer',,, vectm(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vectm(-383.6,1376,273)); //JC's Office

        if(IsAprilFools()) {
            Spawnm(class'MahoganyDesk',,, vect(646.848999, 1524.899902, 263.097137), rot(0, -16384, 0));
        }

        break;
    //#endregion

    //#region Battery Park
    case "04_NYC_BATTERYPARK":
        foreach AllActors(class'AllianceTrigger',at,'GuntherAttacksJC'){
            //These default to colliding with actors, which means you can walk into them.  Oops.
            at.SetCollision(False,False,False);
        }
        foreach AllActors(class'BlockPlayer',bp){
            //Let the player free!  It's already possible to break outside of them, so just get rid of them.
            bp.bBlockPlayers=false;
        }
        foreach AllActors(class'DXRMapVariants', mapvariants) { break; }
        foreach AllActors(class'#var(prefix)GuntherHermann', gunther) {
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, class'DXRMapInfo'.static.GetTeleporterName(mapvariants.VaryMap("05_NYC_UNATCOMJ12Lab"),""), gunther.Location, gunther.CollisionRadius+5, gunther.CollisionHeight+5,,, true);
            hoverHint.SetBaseActor(gunther);
        }
        foreach AllActors(class'#var(prefix)AnnaNavarre',anna){
            anna.MaxProvocations = 0;
            anna.AgitationSustainTime = 3600;
            anna.AgitationDecayRate = 0;
        }

        //A crate in the water near the dock to let you climb out of the water (there's no ladder)
        a = Spawnm(class'#var(prefix)CrateUnbreakableMed',,,vect(-515,-3810,210));
        a.bIsSecretGoal = true; //Don't shuffle

        //Crates blocking the entrance to the empty Castle Clinton
        a = Spawnm(class'#var(prefix)CrateUnbreakableLarge',,,vect(1070,1175,400));
        a.bIsSecretGoal = true; //Don't shuffle
        a = Spawnm(class'#var(prefix)CrateUnbreakableLarge',,,vect(1070,1075,400));
        a.bIsSecretGoal = true; //Don't shuffle
        a = Spawnm(class'#var(prefix)CrateUnbreakableLarge',,,vect(1070,975,400));
        a.bIsSecretGoal = true; //Don't shuffle
        a = Spawnm(class'#var(prefix)CrateUnbreakableLarge',,,vect(1070,875,400));
        a.bIsSecretGoal = true; //Don't shuffle

        break;
    //#endregion

    //#region Bar
    case "04_NYC_BAR":
        if (class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)){
            Spawnm(class'BarDancer',,,vect(-1440,340,48),rot(0,-16348,0));
        } else {
            Spawnm(class'BarDancerBoring',,,vect(-1440,340,48),rot(0,-16348,0));
        }
        break;
    //#endregion

    //#region Street
    case "04_NYC_STREET":
        pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(-1849,286,-487));//Near free clinic
        pg.MaxCount=3;

        foreach AllActors(class'#var(prefix)FlagTrigger', ft) {
            if (ft.event == 'MainGates') {
                // Delete this, we manually open the doors in AnyEntryMapFixes()
                ft.Event = '';
                ft.Destroy();
            }
        }

        foreach AllActors(class'#var(prefix)UNATCOTroop', troop, 'UNATCOGateGuard') {
            troop.ChangeAlly('Player', 1.0, false);
            ChangeInitialAlliance(troop, 'Player', 1.0, false);
        }
        if (#defined(vanilla)){
            class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 0, 1, 0.0, 5);
            foreach AllActors(class'Teleporter', tel) {
                if (tel.URL == "04_NYC_Smug#ToSmugFrontDoor") {
                    dtel = class'DynamicTeleporter'.static.ReplaceTeleporter(tel);
                    dtel.SetDestination("04_NYC_Smug", 'PathNode83',, 16384);
                    class'DXREntranceRando'.static.AdjustTeleporterStatic(dxr, dtel);
                    break;
                }
            }
        }

        foreach AllActors(class'#var(prefix)Datacube', dc) {
            if (dc.textTag == '04_Datacube03') {
                dc.TextPackage = "#var(package)";
                break;
            }
        }

        GoalCompletedSilent(p, 'TellJaime');

        break;
    //#endregion

    //#region Smuggler
    case "04_NYC_SMUG":
        foreach AllActors(class'#var(DeusExPrefix)Mover', door,'botordertrigger') {
            door.tag = 'botordertriggerDoor';
        }
        oot = Spawn(class'OnceOnlyTrigger');
        oot.Event='botordertriggerDoor';
        oot.Tag='botordertrigger';

        foreach AllActors(class'Smuggler', smug) {
            smug.bImportant = true;
            break;
        }

        if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
            //The bot will no longer directly be ordered to attack the player
            //This prevents him from breaking stealth
            //There is already an AllianceTrigger and he will move to where his home base is outside the door
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'InitiateOrder'){
                ot.Destroy();

                ot = #var(prefix)OrdersTrigger(Spawnm(class'#var(prefix)OrdersTrigger',,'InitiateOrder'));
                ot.Event='smugglerbots';
                ot.SetCollision(false,false,false);
                ot.Orders='GoingTo';
                ot.ordersTag='SmugBotDest';

                break;
            }

            reinforce=Spawn(class'DXRReinforcementPoint',,'SmugBotDest',vectm(0,-400,-10));
            reinforce.SetCollisionSize(16,32);
            reinforce.SetAsHomeBase(false);

        }

        SetAllLampsState(false, true, true); // smuggler has one table lamp, upstairs where no one is
        class'MoverToggleTrigger'.static.CreateMTT(self, 'DXRSmugglerElevatorUsed', 'elevatorbutton', 1, 0, 0.0, 5);

        break;
    //#endregion

    //#region Underground (Sewers)
    case "04_NYC_UNDERGROUND":
        foreach AllActors(class'#var(prefix)LaserTrigger',lt){
            if (lt.Location.Z < -574 && lt.Location.Z > -575){
                lt.SetLocation(lt.Location+vect(0,0,11)); //Move them slightly higher up to match their location in mission 2, so you can crouch under
            }
        }
        break;
    //#endregion
    }
}
//#endregion

//#region Post First Entry
function PostFirstEntryMapFixes()
{
    switch(dxr.localURL)
    {
        case "04_NYC_UNATCOHQ":
            FixUNATCORetinalScanner();
            PreventUNATCOZombieDanger();
            break;
    }
}
//#endregion

//#region Any Entry
function AnyEntryMapFixes()
{
    local FordSchick ford;
    local #var(prefix)AnnaNavarre anna;
#ifdef revision
    local DXRKeypad k;
#endif
    local bool RevisionMaps;
    local bool VanillaMaps;
    local Mover door;
    local ConEventSpeech ces;
    local Conversation c;
    local #var(prefix)ScriptedPawn sp;
    local #var(prefix)BlackHelicopter jock;
    local bool raidStarted;
    local JoJoFine jojo;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());
    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    DeleteConversationFlag(GetConversation('AnnaBadMama'), 'TalkedToPaulAfterMessage_Played', true);
    FixConversationFlag(GetConversation('PaulAfterBadMama'), 'AnnaBadMama_Played', true, 'dummy', true);// these lines would've been intended for Paul at Battery Park?
    if(dxr.flagbase.GetBool('NSFSignalSent')) {
        foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {
            anna.EnterWorld();
        }
    }

    switch (dxr.localURL)
    {
    case "04_NYC_BATTERYPARK":
        raidStarted = dxr.flagbase.GetBool('M04RaidBegan');

        foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
            switch(sp.Alliance){
                case 'UNATCO':
                case 'gunther':
                case 'bots':
                    if (raidStarted){
                        sp.EnterWorld();
                    } else {
                        sp.LeaveWorld();
                    }
                    break;
            }
        }

        foreach AllActors(class'#var(prefix)BlackHelicopter',jock){
            if (raidStarted){
                jock.EnterWorld();
            } else {
                jock.LeaveWorld();
            }
        }

        break;
    case "04_NYC_NSFHQ":
        // allow Paul dialog to repeat, especially if you try to send the signal without aligning the dishes
        GetConversation('DL_PaulGoodJob').bDisplayOnce = false;
        break;

    case "04_NYC_HOTEL":
#ifdef vanilla
        NYC_04_CheckPaulUndead();
        if( ! dxr.flagbase.GetBool('PaulDenton_Dead') )
            SetTimer(1, True);
        if(dxr.flagbase.GetBool('NSFSignalSent')) {
            dxr.flagbase.SetBool('PaulInjured_Played', true,, 5);
        }

        // conversations are transient, so they need to be fixed in AnyEntry
        FixConversationFlag(GetConversation('PaulAfterAttack'), 'M04RaidDone', true, 'PaulLeftHotel', true);
        FixConversationFlag(GetConversation('PaulDuringAttack'), 'M04RaidDone', false, 'PaulLeftHotel', false);
#endif
        DeleteConversationFlag(GetConversation('FamilySquabbleWrapUpGilbertDead'), 'PlayerKilledRenton', false);
        FixConversationFlag(GetConversation('SandraMadAtPlayer'), 'PlayerKilledRenton', true, 'AlwaysFalse', true);

        // Make the conversation with Paul to start the raid startable by frob
        // (but still require entering the flagtrigger near him)
        c = GetConversation('TalkedToPaulAfterMessage');
        if (c!=None){
            c.bInvokeFrob=true;
            c.AddFlagRef('ApartmentEntered',True);
        }

        if (dxr.flagbase.GetBool('DXRando_NSFHQVisited')) {
            DeleteConversationFlag(GetConversation('M04PlayerLikesUNATCO'), 'M04MeetGateGuard_Played', true);
        }

        if (dxr.flagbase.GetBool('MS_JoJoUnhidden')) {
            foreach AllActors(class'JoJoFine', jojo, 'JoJoInLobby') {
                jojo.Destroy();
                break;
            }
        }

        break;

    case "04_NYC_SMUG":
        if(VanillaMaps){
            if( dxr.flagbase.GetBool('FordSchickRescued') )
            {
                foreach AllActors(class'FordSchick', ford)
                    ford.EnterWorld();
            }
        }

        if (dxr.flagbase.getBool('SmugglerDoorDone')) {
            dxr.flagbase.setBool('MetSmuggler', true,, -1);
        }

        break;

    case "04_NYC_STREET":
#ifdef revision
        if( dxr.flagbase.GetBool('TalkedToPaulAfterMessage_Played') && RevisionMaps )
        {
            foreach AllActors(class'DXRKeypad',k,'SubKeypad'){
                k.SetCollision(true);
            }
        }
#endif

        if(dxr.flagbase.GetBool('GatesOpen')) {
            foreach AllActors(class'Mover', door, 'MainGates') {
                door.DoOpen();
            }
        }

        ces = GetSpeechEvent(GetConversation('SmugglerDoorBellConvo').eventList, "... too sick");
        if (ces != None)
            ces.conSpeech.speech = "... too sick.  Come back later."; // add a missing period after "sick"

        GetConversation('DL_JockParkStart').AddFlagRef('PaulInjured_Played', false); // disable "Your brother's hurt pretty bad" infolink if you've already talked to him

        break;
    }
}
//#endregion

//#region Timer
function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "04_NYC_HOTEL":
        if(#defined(vanilla))
            NYC_04_CheckPaulRaid();
        break;
    }
}
//#endregion

//#region Paul Logic
// if you bail on Paul but then have a change of heart and re-enter to come back and save him
function NYC_04_CheckPaulUndead()
{
    local PaulDenton paul;
    local int count;

    if( ! dxr.flagbase.GetBool('PaulDenton_Dead')) return;

    foreach AllActors(class'PaulDenton', paul) {
        if( paul.Health > 0 ) {
            dxr.flagbase.SetBool('PaulDenton_Dead', false,, -999);
            return;
        }
    }
}

function NYC_04_CheckPaulRaid()
{
    local PaulDenton paul;
    local ScriptedPawn p;
    local int count, dead, pawns;

    if( ! dxr.flagbase.GetBool('M04RaidTeleportDone') ) return;

    foreach AllActors(class'PaulDenton', paul) {
        // fix a softlock if you jump while approaching Paul
        if( ! dxr.flagbase.GetBool('TalkedToPaulAfterMessage_Played') ) {
            if (dxr.FlagBase.GetBool('LDDPJCIsFemale')){
                player().StartConversationByName('FemJCTalkedToPaulAfterMessage', paul, False, False);
            } else {
                player().StartConversationByName('TalkedToPaulAfterMessage', paul, False, False);
            }
        }

        count++;
        if( paul.Health <= 0 ) dead++;
        if( ! paul.bInvincible ) continue;

        if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
            paul.bInvincible = false;
            SetPawnHealth(paul, 400);
        }
        paul.ChangeAlly('Player', 1, true);
    }

    foreach AllActors(class'ScriptedPawn', p) {
        if( !IsRelevantPawn(p.class) ) continue;
        if( p.bHidden ) continue;
        if( p.Alliance != 'UNATCO' ) continue;
        p.bStasis = false;
        pawns++;
    }

    if( dead > 0 || dxr.flagbase.GetBool('PaulDenton_Dead') ) {
        if(!dxr.flags.IsZeroRando()) player().ClientMessage("RIP Paul :(",, true);
        dxr.flagbase.SetBool('PaulDenton_Dead', true,, 999);
        SetTimer(0, False);
    }
    else if( dead == 0 && (count == 0 || pawns == 0) ) {
        NYC_04_MarkPaulSafe();
        SetTimer(0, False);
    }
    else if( pawns == 1 && pawns != old_pawns )
        player().ClientMessage(pawns$" enemy remaining");
    else if( pawns <3 && pawns != old_pawns )
        player().ClientMessage(pawns$" enemies remaining");
    old_pawns = pawns;
}

function NYC_04_MarkPaulSafe()
{
    local PaulDenton paul;
    local FlagTrigger t;
    local SkillAwardTrigger st;
    local int health;
    if( dxr.flagbase.GetBool('PaulLeftHotel') ) return;

    dxr.flagbase.SetBool('PaulLeftHotel', true,, 999);

    foreach AllActors(class'PaulDenton', paul) {
        paul.GenerateTotalHealth();
        health = paul.Health * 100 / paul.default.Health;// as a percentage
        if(health < 1) health = 1;
        paul.SetOrders('Leaving', 'PaulLeaves', True);
    }

    if(health > 0 && !dxr.flags.IsZeroRando() && !paul.bInvincible) {
        player().ClientMessage("Paul had " $ health $ "% health remaining.");
    }

    foreach AllActors(class'FlagTrigger', t) {
        switch(t.tag) {
            case 'KillPaul':
            case 'BailedOutWindow':
                t.Destroy();
                break;
        }
        if( t.Event == 'BailedOutWindow' )
            t.Destroy();
    }

    foreach AllActors(class'SkillAwardTrigger', st) {
        switch(st.Tag) {
            case 'StayedWithPaul':
            case 'PaulOutaHere':
                st.Touch(player());
        }
    }
    class'DXREvents'.static.SavedPaul(dxr, player(), health);
}

function NYC_04_LeaveHotel()
{
    local FlagTrigger t;
    // TODO: why touch the trigger when we can just change the flag directly?
    foreach AllActors(class'FlagTrigger', t) {
        if( t.Event == 'BailedOutWindow' )
        {
            t.Touch(player());
        }
    }
}
//#endregion
