class DXRBingoCampaign extends DXRActorsBase transient;


function FirstEntry()
{
    local #var(prefix)FlagTrigger ft;
    local DeusExMover mover;
    local Vector loc;

    if (!dxr.flags.IsBingoCampaignMode()) return;

    Super.FirstEntry();

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
                AddBingoEventBlocker('MoveHelicopter', GetBingoMissionFlag(3));
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
                        class'DXRHoverHint'.static.Create(self, "", loc, 50.0, 96.0,,, true);
                        break;
                    }
                    loc = mover.Location;
                }

                AddBingoEventBlocker('everettsignaldoor', GetBingoMissionFlag(10));

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
                AddBingoEventBlocker('UN_BlackHeli', GetBingoMissionFlag(12));
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
            AddBingoEventBlocker('Merge_helios_exit', GetBingoMissionFlag(15));
            AddBingoEventBlocker('destroy_generator', GetBingoMissionFlag(15));
            foreach AllActors(class'#var(prefix)FlagTrigger', ft) {
                if (ft.event == 'Merge_helios_exit') {
                    ft.bTriggerOnceOnly = false;
                }
            }
            break;
        case "15_AREA51_PAGE":
            AddBingoEventBlocker('kill_page', GetBingoMissionFlag(15));
            break;
    }
}

function AnyEntry()
{
    local name flagname;
    if (!dxr.flags.IsBingoCampaignMode()) return;

    Super.AnyEntry();

    if (!IsBingoEnd(dxr.dxInfo.missionNumber, dxr.flags.bingo_duration)) return;

    flagname = GetBingoMissionFlag(dxr.dxInfo.missionNumber);

    switch (dxr.localURL) {
        case "01_NYC_UNATCOISLAND":
            GetConversation('GotoM02').AddFlagRef(flagname, true);
            break;
        case "02_NYC_BATTERYPARK":
            GetConversation('BoatLeaving').AddFlagRef(flagname, true);
            break;
        case "02_NYC_WAREHOUSE":
            GetConversation('JockExit').AddFlagRef(flagname, true);
            break;
        case "03_NYC_AIRFIELD":
            GetConversation('M03JockLeave').AddFlagRef(flagname, true);
            break;
        case "04_NYC_BATTERYPARK":
            GetConversation('GuntherShowdown').AddFlagRef(flagname, true);
            break;
        case "05_NYC_UNATCOISLAND":
            GetConversation('M05MeetJock').AddFlagRef(flagname, true);
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            GetConversation('M06JockExit').AddFlagRef(flagname, true);
            break;
        case "08_NYC_STREET":
            GetConversation('M08JockExit').AddFlagRef(flagname, true);
            break;
        case "09_NYC_GRAVEYARD":
            GetConversation('M09JockLeave').AddFlagRef(flagname, true);
            break;
        case "10_PARIS_CHATEAU":
            GetConversation('DL_graveyard_ambush').AddFlagRef('DXRando_CommandosUnhidden', true);
            UpdateCryptDoors();
            break;
        case "11_PARIS_EVERETT":
            GetConversation('TakeOff').AddFlagRef(flagname, true);
            break;
        case "12_Vandenberg_GAS":
            GetConversation('M12JockFinal').AddFlagRef(flagname, true);
            GetConversation('M12JockFinal2').AddFlagRef(flagname, true);
            break;
        case "14_OCEANLAB_SILO":
            GetConversation('JockArea51').AddFlagRef(flagname, true);
            break;
    }
}

function NewBingoBoard()
{
    local DXREvents events;
    local PlayerDataItem data;
    local int i, numTempBans;
    local string s, tempBans[25];

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

    // create new board
    dxr.flags.bingoBoardRoll = 0;
    events.CreateBingoBoard(dxr.dxInfo.missionNumber * 10);

    // mark old images as old, no cheating!
    MarkDataVaultImagesAsViewed(player());
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

    if (
        dxr.localURL == "10_PARIS_CHATEAU" &&
        dxr.flagbase.GetBool('everettsignal') &&
        dxr.flagbase.GetBool(GetBingoMissionFlag(10)) &&
        IsBingoEnd(dxr.dxInfo.missionNumber, dxr.flags.bingo_duration) &&
        !dxr.flagbase.GetBool('DXRando_CommandosUnhidden')
    ) {
        foreach AllActors(class'#var(prefix)FlagTrigger', ft, 'everettsignaldoor') {
            ft.Trigger(None, None);
            break;
        }
    }
}

static function bool IsBingoEnd(int missionNumber, int bingo_duration)
{
    if (missionNumber > 12) {
        missionNumber -= 2;
    } else if (missionNumber > 6) {
        missionNumber -= 1;
    }
    return missionNumber % bingo_duration == 0 || missionNumber == 13;
}

static function name GetBingoMissionFlag(int missionNumber, optional out int expiration) {
    expiration = missionNumber+1;
    if(missionNumber==10) expiration++;
    if(missionNumber==12) expiration=15;
    return class'DXRInfo'.static.StringToName( "DXRando_Mission" $ missionNumber $ "_BingoCompleted");
}

function bool HandleBingo(int numBingos)
{
    local name bingoFlag;
    local int expiration;

    if (!dxr.flags.IsBingoCampaignMode() || numBingos < dxr.flags.settings.bingo_win || dxr.LocalURL == "ENDGAME4"/* || dxr.LocalURL == "ENDGAME4REV"*/) {
        return false;
    }

    if (numBingos == dxr.flags.settings.bingo_win) {
        player().ClientMessage("You have enough bingo lines to proceed!");
    }

    bingoFlag = GetBingoMissionFlag(dxr.dxInfo.missionNumber, expiration);
    dxr.flagbase.SetBool(bingoFlag, true,, expiration);
    UpdateCryptDoors();

    return true;
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
