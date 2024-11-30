class DXRBingoCampaign extends DXRActorsBase transient;

const BingoFlagM01 = 'DXRando_Mission01_BingoCompleted';
const BingoFlagM02 = 'DXRando_Mission02_BingoCompleted';
const BingoFlagM03 = 'DXRando_Mission03_BingoCompleted';
const BingoFlagM04 = 'DXRando_Mission04_BingoCompleted';
const BingoFlagM05 = 'DXRando_Mission05_BingoCompleted';
const BingoFlagM06 = 'DXRando_Mission06_BingoCompleted';
const BingoFlagM08 = 'DXRando_Mission08_BingoCompleted';
const BingoFlagM09 = 'DXRando_Mission09_BingoCompleted';
const BingoFlagM10 = 'DXRando_Mission10_BingoCompleted';
const BingoFlagM11 = 'DXRando_Mission11_BingoCompleted';
const BingoFlagM12 = 'DXRando_Mission12_BingoCompleted';
const BingoFlagM14 = 'DXRando_Mission14_BingoCompleted';
const BingoFlagM15 = 'DXRando_Mission15_BingoCompleted';

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
                AddBingoEventBlocker('MoveHelicopter', BingoFlagM03);
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

                AddBingoEventBlocker('everettsignaldoor', BingoFlagM10);

                dxr.flagbase.SetBool('MS_CommandosUnhidden', true,, 12); // keep commandos from spawning prematurely
                ft = Spawn(class'FlagTrigger',, 'everettsignaldoor_bingoblocked');
                ft.flagName = 'DXRando_CommandosUnhidden';
                ft.flagValue = true;
                ft.flagExpiration = 12;
                ft.SetCollision(false, false, false);

                GetConversation('DL_graveyard_ambush').AddFlagRef('DXRando_CommandosUnhidden', true);

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
                AddBingoEventBlocker('UN_BlackHeli', BingoFlagM12);
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
            AddBingoEventBlocker('Merge_helios_exit', BingoFlagM15);
            AddBingoEventBlocker('destroy_generator', BingoFlagM15);
            foreach AllActors(class'#var(prefix)FlagTrigger', ft) {
                if (ft.event == 'Merge_helios_exit') {
                    ft.bTriggerOnceOnly = false;
                }
            }
            break;
        case "15_AREA51_PAGE":
            AddBingoEventBlocker('kill_page', BingoFlagM15);
            break;
    }
}

function AnyEntry()
{
    if (!dxr.flags.IsBingoCampaignMode()) return;

    Super.AnyEntry();

    if (!IsBingoEnd(dxr.dxInfo.missionNumber, dxr.flags.bingo_duration)) return;

    switch (dxr.localURL) {
        case "01_NYC_UNATCOISLAND":
            GetConversation('GotoM02').AddFlagRef(BingoFlagM01, true);
            break;
        case "02_NYC_BATTERYPARK":
            GetConversation('BoatLeaving').AddFlagRef(BingoFlagM02, true);
            break;
        case "02_NYC_WAREHOUSE":
            GetConversation('JockExit').AddFlagRef(BingoFlagM02, true);
            break;
        case "03_NYC_AIRFIELD":
            GetConversation('M03JockLeave').AddFlagRef(BingoFlagM03, true);
            break;
        case "04_NYC_BATTERYPARK":
            GetConversation('GuntherShowdown').AddFlagRef(BingoFlagM04, true);
            break;
        case "05_NYC_UNATCOISLAND":
            GetConversation('M05MeetJock').AddFlagRef(BingoFlagM05, true);
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            GetConversation('M06JockExit').AddFlagRef(BingoFlagM06, true);
            break;
        case "08_NYC_STREET":
            GetConversation('M08JockExit').AddFlagRef(BingoFlagM08, true);
            break;
        case "09_NYC_GRAVEYARD":
            GetConversation('M09JockLeave').AddFlagRef(BingoFlagM09, true);
            break;
        case "10_PARIS_CHATEAU":
            UpdateCryptDoors();
            break;
        case "11_PARIS_EVERETT":
            GetConversation('TakeOff').AddFlagRef(BingoFlagM11, true);
            break;
        case "12_Vandenberg_GAS":
            GetConversation('M12JockFinal').AddFlagRef(BingoFlagM12, true);
            GetConversation('M12JockFinal2').AddFlagRef(BingoFlagM12, true);
            break;
        case "14_OCEANLAB_SILO":
            GetConversation('JockArea51').AddFlagRef(BingoFlagM14, true);
            break;
    }
}

function NewBingoBoard()
{
    local DXREvents events;

    foreach AllActors(class'DXREvents', events) break;
    if (events == None) return;

    dxr.flags.settings.starting_map = dxr.dxInfo.missionNumber * 10;
    dxr.flags.bingoBoardRoll = 0;
    dxr.flags.bingo_duration = 1;
    events.CreateBingoBoard();
    ClearDataVaultImages(player());
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
        dxr.flagbase.GetBool(BingoFlagM10) &&
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
    switch (missionNumber) {
        case 1:
            expiration = 2;
            return BingoFlagM01;
        case 2:
            expiration = 3;
            return BingoFlagM02;
        case 3:
            expiration = 4;
            return BingoFlagM03;
        case 4:
            expiration = 5;
            return BingoFlagM04;
        case 5:
            expiration = 6;
            return BingoFlagM05;
        case 6:
            expiration = 8;
            return BingoFlagM06;
        case 8:
            expiration = 9;
            return BingoFlagM08;
        case 9:
            expiration = 10;
            return BingoFlagM09;
        case 10:
            expiration = 12;
            return BingoFlagM10;
        case 11:
            expiration = 12;
            return BingoFlagM11;
        case 12:
            expiration = 15;
            return BingoFlagM12;
        case 14:
            expiration = 15;
            return BingoFlagM14;
        case 15:
            expiration = 999;
            return BingoFlagM15;
        default:
            expiration = 0;
            return '';
    }
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
