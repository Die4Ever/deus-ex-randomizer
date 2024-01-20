class DXRFixupM05 extends DXRFixup;

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "05_NYC_UNATCOMJ12lab";
    add_datacubes[i].text = "Agent Sherman, I've updated the demiurge password for Agent Navarre's killphrase to archon. Make sure you don't leave this datacube lying around.";
    i++;

    add_datacubes[i].map = "05_NYC_UNATCOHQ";
    add_datacubes[i].text = "Note to self:|nUsername: JCD|nPassword: bionicman ";
    i++;

    Super.CheckConfig();
}

function PartialHeal(out int health, int d)
{
    health = Max(d/2, health);// half default health, or keep current health
    health = Min(health, d);// cap at the default
}

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
    local #var(prefix)SpawnPoint sp;
    local DXREnemies dxre;
    local int i;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch (dxr.localURL)
    {
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
            mj12.UnfamiliarName = "Rick";
            mj12.FamiliarName = "Rick";
            mj12.BindName = "MJ12CellguardRick";
        }

        if (VanillaMaps){
            foreach AllActors(class'DeusExMover',dxm){
                if (dxm.Name=='DeusExMover34'){
                    //I think this filing cabinet door was supposed to
                    //be unlockable with Agent Sherman's key as well
                    dxm.KeyIDNeeded='Cabinet';
                }
            }
        }

        break;

    case "05_NYC_UNATCOHQ":
        if (VanillaMaps){
            FixAlexsEmail();

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
            foreach AllActors(class'#var(prefix)AlexJacobson', alex) {
                RemoveFears(alex);
            }
            foreach AllActors(class'#var(prefix)JaimeReyes', j) {
                RemoveFears(j);
            }

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
        }

        break;

    case "05_NYC_UNATCOISLAND":
        foreach AllActors(class'#var(prefix)UNATCOTroop', lloyd) {
            if(lloyd.BindName != "PrivateLloyd") continue;
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
                lloyd.FamiliarName = "Master Sergeant Lloyd";
                lloyd.UnfamiliarName = "Master Sergeant Lloyd";
            }
            if(!#defined(vmd)) {// vmd allows AI to equip armor, so maybe he doesn't need the health boost?
                SetPawnHealth(lloyd, 200);
            }
        }

        rg=Spawn(class'#var(prefix)RatGenerator',,, vectm(-6348,1261,-134));//Near SATCOM
        rg.MaxCount=1;

        pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(-4685,2875,-124));//Outside the front door
        pg.MaxCount=3;

        break;
    }
}

function PostFirstEntryMapFixes()
{
    local RetinalScanner r;

    switch(dxr.localURL) {
    case "05_NYC_UNATCOHQ":
        foreach AllActors(class'RetinalScanner', r) {
            if( r.Event == 'retinal_msg_trigger' ){
                r.Event = 'UN_blastdoor2';
                r.bHackable = true;
                r.hackStrength = 0;
                r.msgUsed = "Access De-/.&*% g r a n t e d";
            } else if (r.Event == 'securitytrigger') {
                r.Event = 'UNblastdoor';
                r.bHackable = true;
                r.hackStrength = 0;
                r.msgUsed = "Access De-/.&*% g r a n t e d";
            }
        }
        break;

    case "05_NYC_UNATCOMJ12LAB":
        BalanceJailbreak();
        break;
    }
}

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
    local string PaulLocation;
    local #var(prefix)DataLinkTrigger dlt;

    SetSeed("BalanceJailbreak");

    // move the items instead of letting Mission05.uc do it
    // Revision also removes ammo and credits, and spawns special weapons from Paul if you saved him
    // This logic will cause that to not happen (for now)
    p = player();
    if(dxr.flags.settings.prison_pocket <= 0) {
        if(DeusExWeapon(p.inHand) != None)
            DeusExWeapon(p.inHand).LaserOff();

        PaulLocation = "Surgery Ward";
        missions = DXRMissions(dxr.FindModule(class'DXRMissions'));
        for(i=0;missions!=None && i<missions.num_goals;i++) {
            if(missions.GetSpoiler(i).goalName == "Paul") {
                PaulLocation = missions.GetSpoiler(i).goalLocation;
            }
        }
        num=0;
        l("BalanceJailbreak PaulLocation == " $ PaulLocation);
        if(PaulLocation == "Surgery Ward" || PaulLocation == "Greasel Pit")
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

        else {
            // put the items in the surgery ward
            itemLocations[num++] = vectm(2174.416504,-569.534729,-213.660309);// paul's bed
            itemLocations[num++] = vectm(2176.658936,-518.937012,-213.659302);// paul's bed
            itemLocations[num++] = vectm(1792.696533,-738.417175,-213.660248);// bed 2
            itemLocations[num++] = vectm(1794.898682,-802.133301,-213.658630);// bed 2
            itemLocations[num++] = vectm(1572.443237,-739.527649,-213.660095);// bed 1
            itemLocations[num++] = vectm(1570.557007,-801.213806,-213.660095);// bed 1
            itemLocations[num++] = vectm(1269.494019,-522.082458,-221.659180);// near ambrosia
            itemLocations[num++] = vectm(1909.302979,-376.711639,-221.660095);// desk with microscope and datacube
            itemLocations[num++] = vectm(1572.411865,-967.828735,-261.659546);// on the floor, at the wall with the monitors
            itemLocations[num++] = vectm(1642.170532,-968.813354,-261.660736);
            itemLocations[num++] = vectm(1715.513062,-965.846558,-261.657837);
            itemLocations[num++] = vectm(1782.731689,-966.754700,-261.661041);

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
    }

    if(!dxr.flags.IsReducedRando()) {
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

        switch(rng(4)) {
        case 1:// crate past the desk
            Spawn(iclass,,, vectm(-1838.230225, 1250.242676, -110.399773));
            break;
        case 2:// desk
            Spawn(iclass,,, vectm(-2105.412598, 1232.926758, -134.400101));
            break;
        case 3:// locked jail cell with medbot
            Spawn(iclass,,, vectm(-3020.846924, 910.062134, -201.399750));
            break;
        default:// unlocked jail cell
            Spawn(iclass,,, vectm(-2688.502686, 1424.474731, -158.099915));
            break;
        }
    }
}

