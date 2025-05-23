class DXRFixupM05 extends DXRFixup;

function CheckConfig()
{
    local int i;
    //#region Add Datacubes
    add_datacubes[i].map = "05_NYC_UNATCOMJ12lab";
    add_datacubes[i].text = "Agent Sherman, I've updated the demiurge password for Agent Navarre's killphrase to archon. Make sure you don't leave this datacube lying around.";
    add_datacubes[i].Location = vect(-50,3540,-140); //Agent Sherman's desk in the back of the greasel lab
    add_datacubes[i].plaintextTag = "KillphrasePassword";
    i++;

    add_datacubes[i].map = "05_NYC_UNATCOHQ";
    add_datacubes[i].text = "Note to self:|nUsername: JCD|nPassword: bionicman ";
    add_datacubes[i].Location = vect(-210,1290,290); //JC's Desk
    add_datacubes[i].plaintextTag = "JCCompPassword";
    i++;
    //#endregion

    Super.CheckConfig();
}

function PartialHeal(out int health, int d)
{
    health = Clamp(health, d/2, d);
}

//#region Pre First Entry
function PreFirstEntryMapFixes()
{
    local #var(PlayerPawn) p;
    local #var(prefix)PaulDenton paul;
    local #var(prefix)PaulDentonCarcass paulcarc;
    local ComputerPersonal c;
    local DeusExMover dxm;
    local #var(prefix)UNATCOTroop lloyd;
    local #var(prefix)AlexJacobson alex;
    local #var(prefix)JaimeReyes j;
    local #var(prefix)MJ12Troop mj12;
    local #var(prefix)RatGenerator rg;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)NanoKey k;
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local DXRHoverHint hoverHint;
    local #var(prefix)HumanCivilian hc;
    local #var(prefix)Terrorist miguel;
    local #var(prefix)Keypad3 kp;
    local #var(prefix)Cigarettes cigs;
    local #var(prefix)ComputerPublic compublic;
    local #var(prefix)OrdersTrigger ot;
    local #var(prefix)AllianceTrigger at;
    local #var(prefix)CrateUnbreakableLarge crate;
    local #var(prefix)ThugMale2 thug;
    local #var(prefix)Karkian kark;

    local DXREnemies dxre;
    local int i;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch (dxr.localURL)
    {
    //#region UNATCO MJ12 Lab
    case "05_NYC_UNATCOMJ12LAB":
        if(!dxr.flags.f.GetBool('MS_InventoryRemoved')) {
            p = player();
            PartialHeal(p.HealthHead, p.default.HealthHead);
            PartialHeal(p.HealthTorso, p.default.HealthTorso);
            PartialHeal(p.HealthLegLeft, p.default.HealthLegLeft);
            PartialHeal(p.HealthLegRight, p.default.HealthLegRight);
            PartialHeal(p.HealthArmLeft, p.default.HealthArmLeft);
            PartialHeal(p.HealthArmRight, p.default.HealthArmRight);
            p.GenerateTotalHealth();
            if(dxr.flags.settings.prison_pocket > 0 || VanillaMaps)
                dxr.flags.f.SetBool('MS_InventoryRemoved', true,, 6);
            // we have to move the items in PostFirstEntry, otherwise they get swapped around with other things
        }
        foreach AllActors(class'#var(prefix)PaulDenton', paul) {
            paul.RaiseAlarm = RAISEALARM_Never;// https://www.twitch.tv/die4ever2011/clip/ReliablePerfectMarjoramDxAbomb
            paul.bDetectable=false;
            paul.bIgnore=true;
            paul.ChangeAlly('mj12',0,true,false);
        }
        foreach AllActors(class'#var(prefix)PaulDentonCarcass',paulcarc){
            paulcarc.bInvincible=true;
        }
        foreach AllActors(class'#var(prefix)MJ12Troop', mj12, 'Cellguard') {
            mj12.bImportant = true;
            if(class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
                mj12.UnfamiliarName = class'DXRNames'.static.RandomName(dxr);
                mj12.FamiliarName = mj12.UnfamiliarName;
            }
            mj12.BindName = "MJ12CellguardRick"; // he's still Rick in our hearts
        }

        //Anna hates weapons (why?) in Revision, but can't hurt to set it for all mods
        //If she sees you pull out a weapon with this set, she goes hostile and starts
        //running around
        foreach AllActors(class'#var(prefix)AnnaNavarre',anna){
            anna.bHateWeapon=False;
            anna.ResetReactions();
        }

        //Prevent the karkians from getting cloned (so they don't clone outside of the enclosure)
        foreach AllActors(class'#var(prefix)Karkian', kark){
            kark.bIsSecretGoal=true;
        }

        if (VanillaMaps){
            foreach AllActors(class'DeusExMover',dxm){
                if (dxm.Name=='DeusExMover34'){
                    //I think this filing cabinet door was supposed to
                    //be unlockable with Agent Sherman's key as well
                    dxm.KeyIDNeeded='Cabinet';
                }
            }

            foreach AllActors(class'#var(prefix)Keypad3', kp, 'Keypad3') {
                if(kp.Name=='Keypad10' && kp.Event=='') {
                    kp.Event = 'ExitDoor';
                    kp.hackStrength = 0.1;
                    kp.validCode = "1125";
                }
            }

            foreach AllActors(class'#var(prefix)Cigarettes', cigs) {
                if(cigs.Name=='Cigarettes0') {
                    cigs.Destroy();
                }
            }
        } else {
            foreach AllActors(class'DeusExMover',dxm){
                if (dxm.Name=='DeusExMover34'){
                    //I think this filing cabinet door was supposed to
                    //be unlockable with Agent Sherman's key as well
                    dxm.KeyIDNeeded='MiBCabinet';
                }
            }

            //Keypad10 fixed in Vanilla above is already fixed in Revision
        }

        //Mirrors verified in vanilla and Revision
        class'FakeMirrorInfo'.static.Create(self,vectm(-2840,1360,-64),vectm(-2875,1487,-160)); //Mirrors between cells
        class'FakeMirrorInfo'.static.Create(self,vectm(-2875,848,-64),vectm(-2840,978,-160));   //Mirrors between cells
        class'FakeMirrorInfo'.static.Create(self,vectm(-3010,1035,-64),vectm(-2877,1047,-160)); //Dead Body Cell
        class'FakeMirrorInfo'.static.Create(self,vectm(-2542,1035,-64),vectm(-2672,1047,-160)); //Miguel Cell
        class'FakeMirrorInfo'.static.Create(self,vectm(-2833,1300,-64),vectm(-2702,1290,-160)); //Empty Cell

        foreach AllActors(class'DeusExMover',dxm,'Mirror'){break;}
        class'FakeMirrorInfo'.static.Create(self,vectm(-3168,1300,-64),vectm(-3039,1290,-160),dxm); //JC's Cell (but we only want this while the window is reflective)

        class'PlaceholderEnemy'.static.Create(self,vectm(-5066,1368,208),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-4981,1521,208),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-3417,1369,208),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(479,3502,-144),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1439,1162,-144),,'Sitting');

        break;
    //#endregion

    //#region UNATCO HQ
    case "05_NYC_UNATCOHQ":
        if (VanillaMaps){
            FixAlexsEmail();
            //MakeTurretsNonHostile(); //Revision has hostile turrets near jail, but they should stay hostile this time

            // Anna's dialog depends on this flag
            dxr.flagbase.SetBool('DL_Choice_Played', true,, 6);

            foreach AllActors(class'ComputerPersonal', c) {
                if( c.Name != 'ComputerPersonal3' ) continue;
                // gunther and anna's computer across from Carter
                for(i=0; i < ArrayCount(c.UserList); i++) {
                    if( c.UserList[i].userName != "JCD" ) continue;
                    // it's silly that you can use JC's account to get part of Anna's killphrase, and also weird that Anna's account isn't on here
                    c.UserList[i].userName = "anavarre";
                    c.UserList[i].password = "scryspc";
                }
            }


            foreach AllActors(class'#var(prefix)AnnaNavarre',anna){
                anna.MaxProvocations = 0;
                anna.AgitationSustainTime = 3600;
                anna.AgitationDecayRate = 0;
            }

            if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
                k = Spawn(class'#var(prefix)NanoKey',,, vectm(420,195,333));
                k.KeyID = 'UNOfficeDoorKey';
                k.Description = "UNATCO Office Door Key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(k);

                k = Spawn(class'#var(prefix)NanoKey',,, vectm(965,900,-28));
                k.KeyID = 'JaimeClosetKey';
                k.Description = "MedLab Closet Key Code";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(k);
            }

            foreach AllActors(class'#var(prefix)ComputerPublic', compublic) {
                compublic.bCollideWorld = false;
                compublic.SetLocation(vectm(741.36, 1609.34, 298.0));
                compublic.SetRotation(rotm(0, -16384, 0, GetRotationOffset(class'#var(prefix)ComputerPublic')));
                break;
            }
            class'FakeMirrorInfo'.static.Create(self,vectm(2430,1872,-80),vectm(2450,2060,-16)); //Mirror window at level 4 entrance
        } else {
            class'FakeMirrorInfo'.static.Create(self,vectm(2475,1872,-80),vectm(2450,2064,-16)); //Mirror window at level 4 entrance
        }
        SpeedUpUNATCOFurnaceVent();

        foreach AllActors(class'#var(prefix)Terrorist', miguel){
            miguel.bHateShot=False;
            miguel.ResetReactions();
        }

        foreach AllActors(class'#var(prefix)AlexJacobson', alex) {
            RemoveFears(alex);
        }
        foreach AllActors(class'#var(prefix)JaimeReyes', j) {
            RemoveFears(j);
        }

        if(class'MenuChoice_BalanceMaps'.static.MinorEnabled()) {
            foreach AllActors(class'#var(prefix)CrateUnbreakableLarge',crate){
                crate.Destroy();
            }
        }

        if (class'MenuChoice_BalanceMaps'.static.ModerateEnabled()){
            //Manderley becomes hostile, rather than being ordered to Attack (which breaks stealth)
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'killjc'){
                class'FacePlayerTrigger'.static.Create(self,'killjc','JosephManderley',ot.Location);
                class'DrawWeaponTrigger'.static.Create(self,'killjc','JosephManderley',ot.Location,true);

                at = Spawn(class'#var(injectsprefix)AllianceTrigger',,'killjc',ot.Location);
                at.SetCollision(False,False,False);
                at.Event='JosephManderley';
                at.Alliance='UNATCO';
                at.Alliances[0].allianceName='Player';
                at.Alliances[0].allianceLevel=-1.0;
                at.Alliances[0].bPermanent=true;

                ot.Destroy();
                break;
            }

            //Anna becomes hostile, rather than being ordered to Attack (which breaks stealth)
            foreach AllActors(class'#var(prefix)OrdersTrigger',ot,'annahate'){
                class'FacePlayerTrigger'.static.Create(self,'annahate','AnnaNavarre',ot.Location);
                class'DrawWeaponTrigger'.static.Create(self,'annahate','AnnaNavarre',ot.Location,true);

                at = Spawn(class'#var(injectsprefix)AllianceTrigger',,'annahate',ot.Location);
                at.SetCollision(False,False,False);
                at.Event='AnnaNavarre';
                at.Alliance='UNATCO';
                at.Alliances[0].allianceName='Player';
                at.Alliances[0].allianceLevel=-1.0;
                at.Alliances[0].bPermanent=true;

                ot.Destroy();
                break;
            }
        }

        class'PlaceholderEnemy'.static.Create(self,vectm(164,-424,48),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-16,-609,48),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(-182,-859,-16),,'Sitting');
        class'PlaceholderEnemy'.static.Create(self,vectm(1153,1024,-16),,'Sitting');
        if (VanillaMaps){
            class'PlaceholderEnemy'.static.Create(self,vectm(144,176,40),,'Shitting'); //Bathroom
            class'PlaceholderEnemy'.static.Create(self,vectm(229,1828,288),,'Sitting'); //Breakroom
            class'PlaceholderEnemy'.static.Create(self,vectm(-1451,654,608),,'Sitting'); //Lobby Chair
            class'PlaceholderEnemy'.static.Create(self,vectm(-1662,786,608),,'Sitting'); //Lobby Chair
            class'PlaceholderEnemy'.static.Create(self,vectm(1885,-279,-16),,'Sitting'); //Alex office seats
        } else {
            class'PlaceholderEnemy'.static.Create(self,vectm(220,190,45),,'Shitting'); //Bathroom
            class'PlaceholderEnemy'.static.Create(self,vectm(256,1429,490),,'Sitting'); //Breakroom
            class'PlaceholderEnemy'.static.Create(self,vectm(-1980,1086,610),,'Sitting'); //Lobby Chair
            class'PlaceholderEnemy'.static.Create(self,vectm(-1739,915,610),,'Sitting'); //Lobby Chair
            class'PlaceholderEnemy'.static.Create(self,vectm(1332,-849,-10),,'Sitting'); //Alex office seats
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

        break;
    //#endregion

    //#region UNATCO Island
    case "05_NYC_UNATCOISLAND":
        foreach AllActors(class'#var(prefix)UNATCOTroop', lloyd) {
            if(lloyd.BindName != "PrivateLloyd") continue;
            if( ! class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) break; // not in Zero Rando
            RemoveFears(lloyd);
            lloyd.MinHealth = 0;
            lloyd.BaseAccuracy *= 0.1;
            GiveItem(lloyd, class'#var(prefix)BallisticArmor');
            if(!dxr.flags.IsReducedRando()) {
                dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
                if(dxre != None) {
                    dxre.GiveRandomWeapon(lloyd, false, 2);
                    dxre.GiveRandomMeleeWeapon(lloyd);
                }
            }
            if(class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
                lloyd.FamiliarName = "Master Sergeant Lloyd";
                lloyd.UnfamiliarName = "Master Sergeant Lloyd";
            }
            if(!#defined(vmd)) {// vmd allows AI to equip armor, so maybe he doesn't need the health boost?
                SetPawnHealth(lloyd, 200);
            }
        }

        //Get rid of the random ThugMale2 way on the other side of the island
        //Not an issue most of the time, but annoying for Crowd Control swaps
        foreach AllActors(class'#var(prefix)ThugMale2',thug){
            thug.Destroy();
        }

        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(-6348,1261,-134));//Near SATCOM
        rg.MaxCount=1;

        pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(-4685,2875,-124));//Outside the front door
        pg.MaxCount=3;

        //Add teleporter hint text to Jock
        foreach AllActors(class'#var(prefix)MapExit',exit){break;}
        foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
        hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit,, true);
        hoverHint.SetBaseActor(jock);

        SetAllLampsState(,, false, vect(-5724.620605, 1435.543213, -79.614632), 0.01);

        break;
    //#endregion
    }
}
//#endregion

//#region Post First Entry
function PostFirstEntryMapFixes()
{
    local RetinalScanner r;
    local bool VanillaMaps;
    local UNATCOTroop troop;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL) {
    case "05_NYC_UNATCOHQ":
        foreach AllActors(class'RetinalScanner', r) {
            if( r.Event == 'retinal_msg_trigger' ){
                r.Event = 'UN_blastdoor2';
                r.bHackable = true;
                r.hackStrength = 0;
                r.msgUsed = "Access De-/.&*% g r a n t e d";
            } else if (r.Event == 'securitytrigger') {
                if (VanillaMaps){
                    r.Event = 'UNblastdoor';
                } else {
                    r.Event = 'UN_blastdoor'; //Revision changed the tag name on the door
                }
                r.bHackable = true;
                r.hackStrength = 0;
                r.msgUsed = "Access De-/.&*% g r a n t e d";
            }
        }

        if (VanillaMaps && class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
            foreach AllActors(class'UNATCOTroop', troop) {
                if (troop.FamiliarName == "Scott") {
                    if (troop.name == 'UNATCOTroop4') {
                        // so he doesn't remain "UNATCO Trooper" forever, even with memes turned on
                        // this is the Scott that is ordinarily in the room by the entrance retinal scanner
                        troop.UnfamiliarName = "Scott";
                    } else {
                        // some other character named Scott for some reason, though you'd never see it
                        troop.FamiliarName = class'DXRNames'.static.RandomName(dxr);
                        troop.UnfamiliarName = troop.FamiliarName;
                    }
                }
            }
        }

        break;

    case "05_NYC_UNATCOMJ12LAB":
        BalanceJailbreak();
        break;
    }
}
//#endregion

function Inventory FindPrisonPocketItem()
{
    local #var(PlayerPawn) p;
    local DeusExRootWindow root;
    local Inventory beltItem;
    local int i;

    p = player();

    root = DeusExRootWindow(p.rootWindow);

    if (root==None){
        return None;
    }

    //Items are in slots 1-9, Keyring is in 0
    for(i=1; i<10; i++){
        beltItem=root.hud.belt.GetObjectFromBelt(i);

        if (beltItem==None) continue;

        //Is it a single slot item?
        if (beltItem.invSlotsX==1 && beltItem.invSlotsY==1){
            return beltItem;
        }
    }

    return None;
}

//#region Balance Jailbreak
function BalanceJailbreak()
{
    local class<Inventory> iclass;
    local DXREnemies e;
    local DXRLoadouts loadout;
    local int i, num;
    local float r;
    local Inventory nextItem;
    local SpawnPoint SP;
    local #var(PlayerPawn) p;
    local vector itemLocations[50];
    local DXRMissions missions;
    local string EquipLocation;
    local #var(prefix)DataLinkTrigger dlt;
    local string freebieLocNames[4];
    local vector freebieLocs[4];
    local DynamicLight dl;
    local #var(prefix)Toilet jailToilet;
    local Pickup origPickup;
    local vector toiletLoc;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    SetSeed("BalanceJailbreak");

    // move the items instead of letting Mission05.uc do it
    // Revision also removes ammo and credits, and spawns special weapons from Paul if you saved him
    // This logic will cause that to not happen (for now)
    p = player();
    if(dxr.flags.settings.prison_pocket <= 1) { //Disabled (0) or Unaugmented (1)
        if(DeusExWeapon(p.inHand) != None)
            DeusExWeapon(p.inHand).LaserOff();

        EquipLocation = "Armory";
        missions = DXRMissions(dxr.FindModule(class'DXRMissions'));
        for(i=0;missions!=None && i<missions.num_goals;i++) {
            if(missions.GetSpoiler(i).goalName == "Equipment") {
                EquipLocation = missions.GetSpoiler(i).goalLocation;
            }
        }

        //Unaugmented Prison Pocket (Keep the first single-slot item in your belt)
        if (dxr.flags.settings.prison_pocket == 1) {
            nextItem = FindPrisonPocketItem();

            if (nextItem!=None){
                jailToilet = #var(prefix)Toilet(findNearestToActor(class'#var(prefix)Toilet',p));
                toiletLoc = jailToilet.Location;
                toiletLoc.Z = toiletLoc.Z + jailToilet.CollisionHeight + nextItem.CollisionHeight + 5;
                toiletLoc = toiletLoc + (vect(0,-10,0) >> jailToilet.Rotation); //Offset the item to be more forward on the seat

                origPickup = Pickup(nextItem);
                if (origPickup!=None && origPickup.NumCopies>1){
                    //If it's a stack, break one out and leave it in the cell
                    origPickup.NumCopies--;
                    nextItem = Spawn(origPickup.class,,,toiletLoc); //Spawned in the right location, but MoveNextItemTo will apply everything else
                }

                MoveNextItemTo(nextItem,toiletLoc,'player_prison_pocket');
            }
        }

        num=0;
        l("BalanceJailbreak EquipLocation == " $ EquipLocation);
        if(EquipLocation == "Armory")
            foreach AllActors(class'SpawnPoint', SP, 'player_inv')
                //Adjust item spawnpoints in armoury - specifically, move things off the top shelf
                switch(sp.Name){
                    case 'SpawnPoint24':
                        itemLocations[num++] = vectm(-8551,1061,-197);
                        break;
                    case 'SpawnPoint12':
                        itemLocations[num++] = vectm(-8542,1410,-148);
                        break;
                    case 'SpawnPoint10':
                        itemLocations[num++] = vectm(-8642,1410,-148);
                        break;
                    case 'SpawnPoint11':
                        itemLocations[num++] = vectm(-8636,1410,-197);
                        break;
                    case 'SpawnPoint22':
                        itemLocations[num++] = vectm(-8554,1057,-148);
                        break;
                    case 'SpawnPoint23':
                        itemLocations[num++] = vectm(-8655,1056,-148);
                        break;
                    default:
                        itemLocations[num++] = SP.Location;
                        break;
                }

        else { //EquipLocation == "Surgery Ward"
            // put the items in the surgery ward
            itemLocations[num++] = vectm(2160,-585,-203);// paul's bed
            itemLocations[num++] = vectm(2160,-505,-203);// paul's bed
            itemLocations[num++] = vectm(1805,-730,-203);// middle bed
            itemLocations[num++] = vectm(1805,-810,-203);// middle bed
            itemLocations[num++] = vectm(1555,-730,-203);// bed near ambrosia
            itemLocations[num++] = vectm(1555,-810,-203);// bed near ambrosia

            //Third bed locations
            itemLocations[num++] = vectm(2190,-545,-203);// paul's bed
            itemLocations[num++] = vectm(1775,-770,-203);// middle bed
            itemLocations[num++] = vectm(1585,-770,-203);// bed near ambrosia


            itemLocations[num++] = vectm(1270,-522,-211);// near ambrosia
            itemLocations[num++] = vectm(1275,-710,-211);// table with two microscopes and datacube (left)
            itemLocations[num++] = vectm(1275,-805,-211);// table with two microscopes and datacube (right)
            itemLocations[num++] = vectm(1910,-375,-211);// desk with microscope and datacube
            itemLocations[num++] = vectm(2160,-327,-211);// table with two monitors (left)
            itemLocations[num++] = vectm(2055,-327,-211);// table with two monitors (right)
            itemLocations[num++] = vectm(2110,-327,-211);// table with two monitors (middle)

            // on the floor, at the wall with the monitors, starting in the center, working out
            itemLocations[num++] = vectm(1575,-950,-251);
            itemLocations[num++] = vectm(1650,-950,-251);
            itemLocations[num++] = vectm(1500,-950,-251);
            itemLocations[num++] = vectm(1725,-950,-251);
            itemLocations[num++] = vectm(1425,-950,-251);
            itemLocations[num++] = vectm(1800,-950,-251);
            itemLocations[num++] = vectm(1350,-950,-251);
            itemLocations[num++] = vectm(1875,-950,-251);
            itemLocations[num++] = vectm(1275,-950,-251);

            // seriously, why do you have so much stuff, I never want to see these spots get used
            // on the floor, at the wall with the monitors, emergency second row
            itemLocations[num++] = vectm(1575,-900,-251);
            itemLocations[num++] = vectm(1650,-900,-251);
            itemLocations[num++] = vectm(1500,-900,-251);
            itemLocations[num++] = vectm(1725,-900,-251);
            itemLocations[num++] = vectm(1425,-900,-251);

            foreach AllActors(class'#var(prefix)DataLinkTrigger', dlt) {
                if(dlt.datalinkTag != 'dl_equipment') continue;
                dlt.bCollideWorld = false;
                l("BalanceJailbreak moving "$dlt @ dlt.SetLocation(vectm(1670.443237,-702.527649,-179.660095)) @ dlt.Location);
            }
        }

        nextItem = p.Inventory;
        while(nextItem != None)
            for(i=0; i<num; i++)
                nextItem = MoveNextItemTo(nextItem, itemLocations[i], 'player_inv');
    } else {
        //If Prison Pocket is enabled, there is no equipment to be found.  Remove the infolink.
        //If we implement tiers of Prison Pocket (ie. keep only one item), this will need to be revisited.
        foreach AllActors(class'#var(prefix)DataLinkTrigger', dlt) {
            if(dlt.datalinkTag != 'dl_equipment') continue;
            dlt.Destroy();
        }
    }

    //Freebie Weapon
    //Don't try to move this to DXRMissions
    //When it's there, it won't apply with goal rando disabled
    if(dxr.flags.settings.swapitems > 0 || dxr.flags.loadout != 0) {
        e = DXREnemies(dxr.FindModule(class'DXREnemies'));
        if( e != None ) {
            r = initchance();
            for(i=0; i < ArrayCount(e._randommelees); i++ ) {
                if( e._randommelees[i].type == None ) break;
                if( chance( e._randommelees[i].chance, r ) ) iclass = e._randommelees[i].type;
            }
            chance_remaining(r);
        }
        else iclass = class'#var(prefix)WeaponCombatKnife';

        // make sure Stick With the Prod and Ninja JC can beat this
        loadout = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
        if(loadout != None && loadout.is_banned(iclass)) {
            iclass = loadout.get_starting_item();
        }

        freebieLocNames[0]="Unlocked Jail Cell";
        freebieLocNames[1]="Crate past the Desk";
        freebieLocNames[2]="Desk";
        freebieLocNames[3]="Locked Jail Cell";

        //Define the locations by mod
        if (VanillaMaps){
            freebieLocs[0]=vectm(-2688.502686, 1424.474731, -158.099915); //Unlocked Jail Cell
            freebieLocs[1]=vectm(-1838.230225, 1250.242676, -110.399773); //Crate past the desk
            freebieLocs[2]=vectm(-2105.412598, 1232.926758, -134.400101); //Desk
            freebieLocs[3]=vectm(-3020.846924, 910.062134, -201.399750);  //Locked Jail Cell
        } else { //Revision
            freebieLocs[0]=vectm(-2690,1420,-190); //Unlocked Jail Cell
            freebieLocs[1]=vectm(-1893,1184,-110); //Crate past the desk
            freebieLocs[2]=vectm(-2190,1075,-130); //Desk
            freebieLocs[3]=vectm(-3024,910,-190);  //Locked Jail Cell
        }

        if (ArrayCount(freebieLocs) != ArrayCount(freebieLocNames)){
            err("DXRFixupM05 Freebie Weapon - freebieLocs and freebieLocNames sizes don't match!" @ ArrayCount(freebieLocs) @ ArrayCount(freebieLocNames));
        }

        i=rng(ArrayCount(freebieLocs));
        nextItem = Spawn(iclass,,, freebieLocs[i]);
        l("spawned freebie weapon" @ freebieLocNames[i] @ iclass @ nextItem);

        //Give the weapon a light so that it stands out a bit more
        //The light will disappear when you grab the item
        dl = Spawn(class'DynamicLight',,,nextItem.Location+vect(0,0,6));
        dl.LightRadius=6;
        dl.SetBase(nextItem);

    }
}
//#endregion
