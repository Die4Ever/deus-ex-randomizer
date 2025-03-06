class DXRBingoCampaign extends DXRActorsBase transient;

function FirstEntry()
{
    local #var(prefix)FlagTrigger ft;
    local DeusExMover mover;
    local Vector loc;
    local DXRHoverHint hoverHint;
    local name blockerFlag;

    if (!dxr.flags.IsBingoCampaignMode()) return;

    Super.FirstEntry();

    GetBingoMissionBlockerFlags(dxr.dxInfo.missionNumber, blockerFlag);

    if(IsLateStart(dxr.dxInfo.missionNumber)) return;

    switch (dxr.localURL) {
        case "02_NYC_BATTERYPARK":
            if (IsBingoEnd(1, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "03_NYC_UNATCOISLAND":
            if (IsBingoEnd(2, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "03_NYC_AIRFIELD":
            if (IsBingoEnd(3, dxr.flags.bingo_duration)) {
                AddBingoEventBlocker('MoveHelicopter', blockerFlag);
            }
            break;
        case "04_NYC_UNATCOISLAND":
            if (IsBingoEnd(3, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "05_NYC_UNATCOMJ12LAB":
            if (IsBingoEnd(4, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "06_HONGKONG_HELIBASE":
            if (IsBingoEnd(5, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "08_NYC_STREET":
            if (IsBingoEnd(6, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "09_NYC_Dockyard":
            if (IsBingoEnd(8, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "10_PARIS_CATACOMBS":
            if (IsBingoEnd(9, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "10_PARIS_CHATEAU":
            if (IsBingoEnd(10, dxr.flags.bingo_duration)) {
                loc = vect(0, 0, 0);
                foreach AllActors(class'DeusExMover', mover, 'everettsignaldoor') {
                    mover.bBreakable = false;
                    mover.bPickable = false;
                    mover.bFrobbable = false;
                    if (loc != vect(0, 0, 0)) {
                        loc = (loc + mover.Location) * 0.5;
                        loc.z += 120.0;
                        hoverHint = class'DXRHoverHint'.static.Create(self, "", loc, 50.0, 96.0,,, true);
                        hoverHint.tag = 'crypt_hint';
                        break;
                    }
                    loc = mover.Location;
                }

                AddBingoEventBlocker('everettsignaldoor', blockerFlag);

                dxr.flagbase.SetBool('MS_CommandosUnhidden', true,, 12); // keep commandos from being unhidden prematurely
                ft = Spawn(class'#var(prefix)FlagTrigger',, 'everettsignaldoor_bingoblocked');
                ft.flagName = 'DXRando_CommandosUnhidden';
                ft.flagValue = true;
                ft.flagExpiration = 12;
                ft.SetCollision(false, false, false);

                class'DXRInWorldTrigger'.static.Create(self, 'MJ12Commando', 'everettsignaldoor_bingoblocked', true);
                class'DXRSetFrobbableTrigger'.static.Create(self, 'everettsignaldoor_bingoblocked', 'everettsignaldoor_bingoblocked', true);
            }

            break;
        case "11_PARIS_CATHEDRAL":
            if (IsBingoEnd(10, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "12_VANDENBERG_CMD":
            if (IsBingoEnd(11, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "12_Vandenberg_GAS":
            if (IsBingoEnd(12, dxr.flags.bingo_duration)) {
                AddBingoEventBlocker('UN_BlackHeli', blockerFlag);
            }
            break;
        case "14_VANDENBERG_SUB":
            if (IsBingoEnd(12, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "15_AREA51_BUNKER":
            if (IsBingoEnd(14, dxr.flags.bingo_duration)) {
                NewBingoBoard();
            }
            break;
        case "15_AREA51_FINAL":
            AddBingoEventBlocker('Merge_helios_exit', blockerFlag);
            AddBingoEventBlocker('destroy_generator', blockerFlag);
            foreach AllActors(class'#var(prefix)FlagTrigger', ft) {
                if (ft.event == 'Merge_helios_exit') {
                    ft.bTriggerOnceOnly = false;
                }
            }
            break;
        case "15_AREA51_PAGE":
            AddBingoEventBlocker('kill_page',blockerFlag);
            break;
    }
}

function PostFirstEntry()
{
    if (!dxr.flags.IsBingoCampaignMode()) return;

    switch (dxr.localURL) {
        case "04_NYC_STREET":
        case "04_NYC_HOTEL":
        case "04_NYC_BatteryPark":
            HandleSpecialPerson("AnnaNavarre", "AnnaNavarre_DeadM4", "AnnaNavarre_DeadM5");
            break;
        case "14_VANDENBERG_SUB":
        case "14_OceanLab_Lab":
        case "14_OceanLab_UC":
            HandleSpecialPerson("WaltonSimons", "WaltonSimons_Dead");
            break;
    }
}

function AnyEntry()
{
    local name blockerFlag1, blockerFlag2;

    if (!dxr.flags.IsBingoCampaignMode()) return;

    Super.AnyEntry();

    if (!IsBingoEnd(dxr.dxInfo.missionNumber, dxr.flags.bingo_duration)) return;
    if(IsLateStart(dxr.dxInfo.missionNumber)) return;

    GetBingoMissionBlockerFlags(dxr.dxInfo.missionNumber, blockerFlag1, blockerFlag2);

    switch (dxr.localURL) {
        case "01_NYC_UNATCOISLAND":
            GetConversation('GotoM02').AddFlagRef(blockerFlag1, true);
            break;
        case "02_NYC_BATTERYPARK":
            GetConversation('BoatLeaving').AddFlagRef(blockerFlag2, true);
            break;
        case "02_NYC_WAREHOUSE":
            GetConversation('JockExit').AddFlagRef(blockerFlag1, true);
            break;
        case "03_NYC_AIRFIELD":
            GetConversation('M03JockLeave').AddFlagRef(blockerFlag1, true);
            break;
        case "04_NYC_BATTERYPARK":
            GetConversation('GuntherShowdown').AddFlagRef(blockerFlag1, true);
            break;
        case "05_NYC_UNATCOISLAND":
            GetConversation('M05MeetJock').AddFlagRef(blockerFlag1, true);
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            GetConversation('M06JockExit').AddFlagRef(blockerFlag1, true);
            break;
        case "08_NYC_STREET":
            GetConversation('M08JockExit').AddFlagRef(blockerFlag1, true);
            break;
        case "09_NYC_GRAVEYARD":
            GetConversation('M09JockLeave').AddFlagRef(blockerFlag1, true);
            break;
        case "10_PARIS_CHATEAU":
            GetConversation('DL_graveyard_ambush').AddFlagRef('DXRando_CommandosUnhidden', true);
            UpdateCryptDoors();
            break;
        case "11_PARIS_EVERETT":
            GetConversation('TakeOff').AddFlagRef(blockerFlag1, true);
            break;
        case "12_Vandenberg_GAS":
            GetConversation('M12JockFinal').AddFlagRef(blockerFlag1, true);
            GetConversation('M12JockFinal2').AddFlagRef(blockerFlag1, true);
            break;
        case "14_OCEANLAB_SILO":
            GetConversation('JockArea51').AddFlagRef(blockerFlag1, true);
            break;
    }
}

function bool IsLateStart(int mission)
{
    if(#bool(neverlate)) return false;
    if(mission==7) mission=6;
    if(mission==13) mission=12;
    return dxr.flags.settings.starting_map >= mission * 10 + 5;
}

function HandleSpecialPerson(string bindname, string thisGoal, optional string nextGoal) {
    local int oldSeed;
    local ScriptedPawn pawn;
    local PlayerDataItem data;

    if (IsBoardGoal(thisGoal)) return;

    data = class'PlayerDataItem'.static.GiveItem(player());
    oldSeed = SetGlobalSeed(dxr.dxInfo.MissionNumber @ "HandleSpecialPerson" @ bindname);

    if (chance_single(50)) {
        foreach AllActors(class'ScriptedPawn', pawn) {
            if (pawn.bindname == bindname) {
                log("Destroying " $ pawn.FamiliarName $ " in map " $ dxr.localURL);
                pawn.Destroy();
                break;
            }
        }
    } else {
        if (nextGoal == "") nextGoal = thisGoal;
        data.BanGoal(nextGoal, 999);
    }

    ReapplySeed(oldSeed);
}

function bool IsBoardGoal(string s)
{
    local PlayerDataItem data;
    local int i;

    data = class'PlayerDataItem'.static.GiveItem(player());

    for (i = 0; i < 25; i++) {
        if (data.GetBingoEvent(i) == s) {
            return true;
        }
    }
    return false;
}

function NewBingoBoard()
{
    local DXREvents events;
    local PlayerDataItem data;
    local int i, numTempBans;
    local string s, tempBans[25];

    if(IsLateStart(dxr.dxInfo.missionNumber-1)) return;

    events = DXREvents(class'DXREvents'.static.Find());
    if (events == None) return;

    // unban old goals
    data = class'PlayerDataItem'.static.GiveItem(player());
    data.TickUnbanGoals();

    // ban goals
    for(i=0; i<25; i++) {
        s = data.GetBingoEvent(i);
        switch(s) {
        case "SandraRenton_Dead":
        case "GilbertRenton_Dead":
            data.BanGoal("FamilySquabbleWrapUpGilbertDead_Played", 999);
            data.BanGoal(s, 999);
            break;

        case "AnnaNavarre_DeadM3":
        case "AnnaNavarre_DeadM4":
            data.BanGoal("AnnaNavarre_DeadM3", 999);
            data.BanGoal("AnnaNavarre_DeadM4", 999);
            data.BanGoal("AnnaNavarre_DeadM5", 999);
            data.BanGoal("AnnaKillswitch", 999);
            break;

        case "JordanShea_Dead":
        case "DXRNPCs1_Dead":
        case "WaltonSimons_Dead":
        case "JoeGreene_Dead":
        case "MeetSmuggler":
        case "Shannon_Dead":
            data.BanGoal(s, 999);
            break;

        default: // temporary ban
            tempBans[numTempBans++] = s;
            data.BanGoal(s, 2); // if this was on the M01 board (while generating M02 board), it will not be available again until generating M04 board
            break;
        }
    }

    if(data.IsBanned("JordanShea_Dead") && data.IsBanned("JoeGreene_Dead")) {
        data.BanGoal("SnitchDowd", 999); // a bit weird because you actually only need one of them to be alive
    }

    // create new board
    dxr.flags.bingoBoardRoll = 0;
    events.CreateBingoBoard(dxr.dxInfo.missionNumber * 10);

    // mark old images as old, no cheating!
    MarkDataVaultImagesAsViewed(player());

    // clear read items, so you can do new bingo goals with old reading material
    data.ForgetRead();

    player().ClientMessage("Mr. Page's Mean Bingo Machine has generated a new bingo board!");
}

function AddBingoEventBlocker(name blockedTag, name bingoFlag) {
    local #var(prefix)FlagTrigger ft;
    local Actor blocked;
    local name glue;

    glue = dxr.flagbase.StringToName(blockedTag $ "_bingoblocked");

    foreach AllActors(class'Actor', blocked, blockedTag) {
        if (
            MapExit(blocked) != None ||
            InterpolateTrigger(blocked) != None ||
            DataLinkTrigger(blocked) != None ||
            Dispatcher(blocked) != None ||
            DeusExMover(blocked) != None
        ) {
            blocked.tag = glue;
        }
    }

    ft = Spawn(class'#var(prefix)FlagTrigger',, blockedTag);
    ft.event = glue;
    ft.flagName = bingoFlag;
    ft.bTrigger = true;
    ft.bTriggerOnceOnly = false;
    ft.bSetFlag = false;
    ft.SetCollision(false, false, false);
}

function UpdateCryptDoors()
{
    local #var(prefix)FlagTrigger ft;
    local DXRHoverHint hoverHint;
    local name blockerFlag;

    GetBingoMissionBlockerFlags(10, blockerFlag);
    if (
        dxr.localURL == "10_PARIS_CHATEAU" &&
        dxr.flagbase.GetBool('everettsignal') &&
        dxr.flagbase.GetBool(blockerFlag) &&
        IsBingoEnd(dxr.dxInfo.missionNumber, dxr.flags.bingo_duration) &&
        !dxr.flagbase.GetBool('DXRando_CommandosUnhidden')
    ) {
        foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'everettsignaldoor') {
            ft.Trigger(None, None);
            break;
        }
        foreach AllActors(class'DXRHoverHint', hoverHint, 'crypt_hint') {
            hoverHint.Destroy();
            break;
        }
    }
}

static function int GetBingoEnd(int missionNumber, int bingoDuration) // TODO: don't assume an M01 start
{
    if (missionNumber > 12) {
        missionNumber -= 2;
    } else if (missionNumber > 6) {
        missionNumber -= 1;
    }

    if (missionNumber % bingoDuration != 0) {
        missionNumber = (missionNumber / bingoDuration) * bingoDuration + bingoDuration; // set missionNumber to the previous end, then add bingoDuration to it
        missionNumber = Min(missionNumber, 13);
    }

    if (missionNumber > 11) {
        missionNumber += 2;
    } else if (missionNumber > 6) {
        missionNumber += 1;
    }

    return missionNumber;
}

static function bool IsBingoEnd(int missionNumber, int bingoDuration)
{
    return GetBingoEnd(missionNumber, bingoDuration) == missionNumber;
}

static function int GetBingoMask(int missionNumber, int bingoDuration)
{
    local int mission, bingoMask;

    for (mission = GetBingoEnd(missionNumber, bingoDuration); mission >= missionNumber; mission--) {
        bingoMask = bingoMask | (1 << mission);
    }
    bingoMask = bingoMask & 57214; // remove M07 and M13

    return bingoMask;
}

static function GetBingoMissionBlockerFlags(int missionNumber, optional out name flag1, optional out name flag2, optional out int expiration) {
    if (missionNumber == 10) {
        expiration = 12;
    } else if (missionNumber == 12) {
        expiration = 15;
    } else {
        expiration = missionNumber + 1;
    }
    flag1 = class'DXRInfo'.static.StringToName("DXRando_Mission" $ missionNumber $ "_BingoCompleted"); // no number so as to not break existing playthroughs :(
    flag2 = class'DXRInfo'.static.StringToName("DXRando_Mission" $ missionNumber $ "_BingoCompleted_2");
}

function UnblockEarly(coerce string event, name blockerFlag, int expiration)
{
    if (class'PlayerDataItem'.static.GiveItem(dxr.player).PreviewNumberOfBingos(event) >= dxr.flags.settings.bingo_win) {
        dxr.flagbase.SetBool(blockerFlag, true,, expiration);
    }
}

// there's currently no reason to care what the goal is
function HandleBingoGoal()
{
    local name blockerFlag;
    local int expiration;

    switch (dxr.dxInfo.missionNumber) {
        case 2:
            GetBingoMissionBlockerFlags(2,, blockerFlag, expiration);
            UnblockEarly('DXREvents_LeftOnBoat', blockerFlag, expiration);
            break;
        case 3:
            GetBingoMissionBlockerFlags(3, blockerFlag,, expiration);
            break;
        case 6:
            GetBingoMissionBlockerFlags(6, blockerFlag,, expiration);
            break;
    }
}

function HandleBingoWin(int numBingos, int oldBingos)
{
    local name blockerFlag1, blockerFlag2;
    local int expiration, nextMission;

    if (numBingos > oldBingos) {
        player().ClientMessage("You have enough bingo lines to proceed!");
    }

    GetBingoMissionBlockerFlags(dxr.dxInfo.missionNumber, blockerFlag1, blockerFlag2, expiration);
    dxr.flagbase.SetBool(blockerFlag1, true,, expiration);
    dxr.flagbase.SetBool(blockerFlag2, true,, expiration);
    UpdateCryptDoors();
}

 static function string GetBingoHoverHintText(DXRando dxr, string hintText)
 {
    local string bingoText;
    local int bingosRemaining, spaces;

    if (!dxr.flags.IsBingoCampaignMode() || !IsBingoEnd(dxr.dxInfo.missionNumber, dxr.flags.bingo_duration)) {
         return hintText;
    }

    bingosRemaining = dxr.flags.settings.bingo_win - class'PlayerDataItem'.static.GiveItem(dxr.player).NumberOfBingos();
    if (bingosRemaining < 1) {
        return hintText;
    }

    if (dxr.flags.settings.bingo_win == 1) {
        bingoText = "Complete a bingo line!";
    } else if (bingosRemaining == dxr.flags.settings.bingo_win) {
        bingoText = "Complete " $ bingosRemaining $ " bingo lines!";
    } else if (bingosRemaining == 1) {
        bingoText = "Complete 1 more bingo line!";
    } else {
        bingoText = "Complete " $ bingosRemaining $ " more bingo lines!";
    }

    if (hintText == "") {
        return bingoText;
    }

    bingoText = "(" $ bingoText $ ")";
    spaces = (Len(bingoText) - Len(hintText)) >> 1;
    while (spaces > 1) {
        hintText = " " $ hintText;
        spaces--;
    }
    while (spaces < 1) {
        bingoText = " " $ bingoText;
        spaces++;
    }

    return hintText $ class'DXRInfo'.static.CR() $ bingoText;
}
