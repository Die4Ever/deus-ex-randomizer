class DXRFixupM04 extends DXRFixup;

var int old_pawns;// used for NYC_04_CheckPaulRaid()

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "04_NYC_UNATCOHQ";
    add_datacubes[i].text = "Note to self:|nUsername: JCD|nPassword: bionicman ";
    i++;

    Super.CheckConfig();
}

function PreTravelMapFixes()
{
    switch(dxr.localURL) {
    case "04_NYC_HOTEL":
        if(#defined(vanilla))
            NYC_04_LeaveHotel();
        break;
    }
}

function PreFirstEntryMapFixes()
{
    local #var(prefix)FlagTrigger ft;
    local #var(prefix)DatalinkTrigger dt;
    local OrdersTrigger ot;
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
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local DXRHoverHint hoverHint;
    local DXRMapVariants mapvariants;
    local bool VanillaMaps;
    local #var(prefix)HumanCivilian hc;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch (dxr.localURL)
    {
    case "04_NYC_HOTEL":
#ifdef vanilla
        foreach AllActors(class'OrdersTrigger', ot, 'PaulSafe') {
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
#endif
        class'GilbertWeaponMegaChoice'.static.Create(Player());

        if (VanillaMaps){
            Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table

            key = Spawn(class'#var(prefix)NanoKey',,, vectm(-967,-1240,-74));
            key.KeyID = 'CrackRoom';
            key.Description = "'Ton Hotel, North Room Key";
            if(dxr.flags.settings.keysrando > 0)
                GlowUp(key);

            key = Spawn(class'#var(prefix)NanoKey',,, vectm(-845,-2920,180));
            key.KeyID = 'Apartment';
            key.Description = "Apartment key";
            if(dxr.flags.settings.keysrando > 0)
                GlowUp(key);

            SpawnDatacubeTextTag(vectm(-840,-2920,85), rotm(0,0,0), '02_Datacube07',False); //Paul's stash code, in closet
            Spawn(class'PlaceholderItem',,, vectm(-732,-2628,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-732,-2712,75)); //Actual closet
            Spawn(class'PlaceholderItem',,, vectm(-129,-3038,127)); //Bathroom counter
            Spawn(class'PlaceholderItem',,, vectm(15,-2972,123)); //Kitchen counter
            Spawn(class'PlaceholderItem',,, vectm(-853,-3148,75)); //Crack next to Paul's bed
        }
        break;

    case "04_NYC_NSFHQ":
        if(!dxr.flags.IsReducedRando()) {
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
                    c.Event = '';
                    c.Destroy();
                }
            }
            foreach AllActors(class'#var(prefix)HackableDevices', hd) {
                hd.hackStrength /= 3.0;
            }
        }

        foreach AllActors(class'#var(DeusExPrefix)Mover',door,'ExitDoor'){
            door.KeyIDNeeded='BasementDoor';
        }

        if(!dxr.flags.IsReducedRando()) {
            k = Spawn(class'#var(prefix)Karkian',,, vectm(54.688416, 1208.957275, -237.351410), rotm(0,32768,0));
            k.BindName="NSFMinotaur";
            k.bImportant = true;
            k.ChangeAlly('Player', -1, false);
            k.SetOrders('Standing');
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

            Spawn(class'PlaceholderItem',,, vectm(110.869766, 337.987732, 1034.306885)); // next to vanilla transmitter computer
            class'PlaceholderEnemy'.static.Create(self,vectm(485,1286,64),,'Shitting',,'UNATCO',1);
            class'PlaceholderEnemy'.static.Create(self,vectm(672,1268,64),,'Shitting',,'UNATCO',1);
            class'PlaceholderEnemy'.static.Create(self,vectm(-435,9,-208),,,,'UNATCO',1);
            class'PlaceholderEnemy'.static.Create(self,vectm(1486,1375,-208),,,,'UNATCO',1);
            class'PlaceholderEnemy'.static.Create(self,vectm(-438,1120,544),,,,'UNATCO',1);
            class'PlaceholderEnemy'.static.Create(self,vectm(-89,1261,304),,,,'UNATCO',1);
        }

        if(VanillaMaps && dxr.flags.settings.goals > 0) {
            foreach AllActors(class'#var(prefix)DatalinkTrigger', dt, 'DataLinkTrigger') {
                if(dt.datalinkTag != 'DL_SimonsPissed') continue;
                dt.Tag = 'SendingSignal3';
                break;
            }

            foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'SendingSignal') {
                ft.Tag = 'SendingSignal2';
                ft.Event = 'SendingSignal3';
                ft.bTrigger = true;
                // spawn intermediate trigger to check flag
                ft = Spawn(class'#var(prefix)FlagTrigger',, 'SendingSignal', ft.Location+vect(10,10,10));
                ft.SetCollision(false,false,false);
                ft.bSetFlag=False;
                ft.bTrigger=True;
                ft.FlagName='CanSendSignal';
                ft.flagValue=True;
                ft.Event='SendingSignal2';
                break;
            }
        }

        break;

    case "04_NYC_UNATCOISLAND":
        if(!dxr.flags.IsReducedRando()) {
            foreach AllActors(class'#var(prefix)UNATCOTroop', lloyd) {
                if(lloyd.BindName != "PrivateLloyd") continue;
                lloyd.FamiliarName = "Sergeant Lloyd";
                lloyd.UnfamiliarName = "Sergeant Lloyd";
                lloyd.bImportant = true;
            }
        }

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit);
        hoverHint.SetBaseActor(jock);

        break;
    case "04_NYC_UNATCOHQ":
        FixUNATCOCarterCloset();
        FixAlexsEmail();

        key = Spawn(class'#var(prefix)NanoKey',,, vectm(965,900,-28));
        key.KeyID = 'JaimeClosetKey';
        key.Description = "MedLab Closet Key Code";
        if(dxr.flags.settings.keysrando > 0)
            GlowUp(key);

        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vectm(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vectm(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vectm(2033.8,1979.9,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(2148,2249,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(2433,1384,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vectm(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vectm(-138.5,-790.1,-1.65)); //Anna's bookshelf
        Spawn(class'PlaceholderItem',,, vectm(-27,1651.5,291)); //Breakroom table
        Spawn(class'PlaceholderItem',,, vectm(602,1215.7,295)); //Kitchen Counter
        Spawn(class'PlaceholderItem',,, vectm(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderItem',,, vectm(-433.128601,736.819763,314.310211)); //Weird electrical thing in closet
        Spawn(class'PlaceholderContainer',,, vectm(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vectm(2384,1669,-95)); //MJ12 Door
        Spawn(class'PlaceholderContainer',,, vectm(-383.6,1376,273)); //JC's Office

        foreach AllActors(class'#var(prefix)HumanCivilian', hc, 'LDDPChet') {
            // Chet's name is Chet
            hc.bImportant = true;
        }

        break;

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
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, class'DXRMapInfo'.static.GetTeleporterName(mapvariants.VaryMap("05_NYC_UNATCOMJ12Lab"),""), gunther.Location, gunther.CollisionRadius+5, gunther.CollisionHeight+5);
            hoverHint.SetBaseActor(gunther);
        }

        break;
    case "04_NYC_BAR":
        Spawn(class'BarDancer',,,vectm(-1440,340,48),rotm(0,-16348,0));
        break;
    case "04_NYC_STREET":
        pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(-1849,286,-487));//Near free clinic
        pg.MaxCount=3;

        foreach AllActors(class'#var(prefix)FlagTrigger', ft) {
            if (ft.event == 'MainGates') {
                // Increase the radius to extend around the corner for NSFHQ starts
                ft.SetCollisionSize(7000.0, ft.CollisionHeight);
            }
        }

        break;
    }
}

function PostFirstEntryMapFixes()
{
    FixUNATCORetinalScanner();
}

function AnyEntryMapFixes()
{
    local FordSchick ford;
    local #var(prefix)AnnaNavarre anna;
#ifdef revision
    local DXRKeypad k;
#endif
    local bool RevisionMaps;
    local bool VanillaMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());
    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    DeleteConversationFlag(GetConversation('AnnaBadMama'), 'TalkedToPaulAfterMessage_Played', true);
    if(dxr.flagbase.GetBool('NSFSignalSent')) {
        foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {
            anna.EnterWorld();
        }
    }

    switch (dxr.localURL)
    {
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
        break;

    case "04_NYC_SMUG":
        if(VanillaMaps){
            if( dxr.flagbase.GetBool('FordSchickRescued') )
            {
                foreach AllActors(class'FordSchick', ford)
                    ford.EnterWorld();
            }
        }
        break;

#ifdef revision
    case "04_NYC_STREET":
        if( dxr.flagbase.GetBool('TalkedToPaulAfterMessage_Played') && RevisionMaps )
        {
            foreach AllActors(class'DXRKeypad',k,'SubKeypad'){
                k.SetCollision(true);
            }
        }
        break;
#endif
    }
}

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
            player().StartConversationByName('TalkedToPaulAfterMessage', paul, False, False);
        }

        count++;
        if( paul.Health <= 0 ) dead++;
        if( ! paul.bInvincible ) continue;

        paul.bInvincible = false;
        SetPawnHealth(paul, 400);
        paul.ChangeAlly('Player', 1, true);
    }

    foreach AllActors(class'ScriptedPawn', p) {
        if( PaulDenton(p) != None ) continue;
        if( !IsRelevantPawn(p.class) ) continue;
        if( p.bHidden ) continue;
        if( p.GetAllianceType('Player') != ALLIANCE_Hostile ) continue;
        p.bStasis = false;
        pawns++;
    }

    if( dead > 0 || dxr.flagbase.GetBool('PaulDenton_Dead') ) {
        player().ClientMessage("RIP Paul :(",, true);
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
        health = paul.Health * 100 / 400;// as a percentage
        if(health == 0) health = 1;
        paul.SetOrders('Leaving', 'PaulLeaves', True);
    }

    if(health > 0) {
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
