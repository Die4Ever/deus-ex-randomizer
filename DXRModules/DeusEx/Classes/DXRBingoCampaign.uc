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

function PreFirstEntry()
{
    local BlackHelicopter jock;
    local Switch1 button;
    local PayPhone invisibleWall;
    local #var(prefix)FlagTrigger ft;

    if (!dxr.flags.IsBingoCampaignMode()) return;

    Super.PreFirstEntry();

    switch (dxr.localURL) {
        case "02_NYC_BATTERYPARK":
            NewBingoBoard();
            break;
        case "03_NYC_UNATCOISLAND":
            NewBingoBoard();
            break;
        case "03_NYC_AIRFIELD":
            AddBingoEventBlocker('MoveHelicopter', BingoFlagM03);
            break;
        case "04_NYC_UNATCOISLAND":
            NewBingoBoard();
            break;
        case "05_NYC_UNATCOMJ12LAB":
            NewBingoBoard();
            break;
        case "06_HONGKONG_HELIBASE":
            NewBingoBoard();
            break;
        case "08_NYC_STREET":
            NewBingoBoard();
            break;
        case "09_NYC_Dockyard":
            NewBingoBoard();
            break;
        case "10_PARIS_CATACOMBS":
            NewBingoBoard();
            break;
        case "10_PARIS_CHATEAU":
            if (class'DXRMapVariants'.static.IsVanillaMaps(player())) {
                invisibleWall = PayPhone(Spawnm(class'PayPhone',, 'invisible_wall', vect(-999.7, -4484.5, -174.4)));
                invisibleWall.bHighlight = false;
                invisibleWall.SetCollisionSize(100.0, 150.0);
            }
            break;
        case "11_PARIS_CATHEDRAL":
            NewBingoBoard();
            break;
        case "12_VANDENBERG_CMD":
            NewBingoBoard();
            break;
        case "12_Vandenberg_GAS":
            AddBingoEventBlocker('UN_BlackHeli', BingoFlagM12);
            break;
        case "14_VANDENBERG_SUB":
            NewBingoBoard();
            break;
        case "15_AREA51_BUNKER":
            NewBingoBoard();
            break;
        case "15_AREA51_FINAL":
            AddBingoEventBlocker('Merge_helios_exit', BingoFlagM15);
            AddBingoEventBlocker('destroy_generator', BingoFlagM15);
            foreach AllActors(class'FlagTrigger', ft) {
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
            UpdateChateauInvisibleWall();
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
    events.CreateBingoBoard();
    ClearDataVaultImages(player());
}

function AddBingoEventBlocker(name blockedTag, name bingoFlag) {
    local FlagTrigger ft;
    local Actor blocked;
    local name glue;

    glue = dxr.flagbase.StringToName(blockedTag $ "_bingoblocked");

    foreach AllActors(class'Actor', blocked, blockedTag) {
        if (
            MapExit(blocked) != None ||
            InterpolateTrigger(blocked) != None ||
            Dispatcher(blocked) != None ||
            DataLinkTrigger(blocked) != None
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

function UpdateChateauInvisibleWall()
{
    local PayPhone invisibleWall;

    if (dxr.flagbase.GetBool(BingoFlagM10)) {
        foreach AllActors(class'PayPhone', invisibleWall, 'invisible_wall') {
            invisibleWall.SetCollision(false, false, false);
            break;
        }
    }
}

static function name GetBingoMissionFlag(int missionNumber) {
    switch (missionNumber) {
        case 1:
            return BingoFlagM01;
        case 2:
            return BingoFlagM02;
        case 3:
            return BingoFlagM03;
        case 4:
            return BingoFlagM04;
        case 5:
            return BingoFlagM05;
        case 6:
            return BingoFlagM06;
        case 8:
            return BingoFlagM08;
        case 9:
            return BingoFlagM09;
        case 10:
            return BingoFlagM10;
        case 11:
            return BingoFlagM11;
        case 12:
            return BingoFlagM12;
        case 14:
            return BingoFlagM14;
        case 15:
            return BingoFlagM15;
    }
    return '';
}

function HandleBingo(int numBingos)
{
    if (!dxr.flags.IsBingoCampaignMode() || numBingos < dxr.flags.settings.bingo_win) return;

    if (numBingos == dxr.flags.settings.bingo_win) {
        player().ClientMessage("You have enough bingo lines to proceed!");
    }

    switch (dxr.flags.settings.starting_map / 10) {
        case 1:
            dxr.flagbase.SetBool(BingoFlagM01, true,, 2);
            break;
        case 2:
            dxr.flagbase.SetBool(BingoFlagM02, true,, 3);
            break;
        case 3:
            dxr.flagbase.SetBool(BingoFlagM03, true,, 4);
            break;
        case 4:
            dxr.flagbase.SetBool(BingoFlagM04, true,, 5);
            break;
        case 5:
            dxr.flagbase.SetBool(BingoFlagM05, true,, 6);
            break;
        case 6:
            dxr.flagbase.SetBool(BingoFlagM06, true,, 8);
            break;
        case 8:
            dxr.flagbase.SetBool(BingoFlagM08, true,, 9);
            break;
        case 9:
            dxr.flagbase.SetBool(BingoFlagM09, true,, 10);
            break;
        case 10:
            dxr.flagbase.SetBool(BingoFlagM10, true,, 12);
            UpdateChateauInvisibleWall();
            break;
        case 11:
            dxr.flagbase.SetBool(BingoFlagM11, true,, 12);
            break;
        case 12:
            dxr.flagbase.SetBool(BingoFlagM12, true,, 15);
            break;
        case 14:
            dxr.flagbase.SetBool(BingoFlagM14, true,, 15);
            break;
        case 15:
            dxr.flagbase.SetBool(BingoFlagM15, true);
            break;
    }
}

 static function string GetBingoHoverHintText(DXRando dxr, string hintText)
 {
    local string bingoText;
    local int bingosRemaining, hintLen, bingoLen, i;

    if (!dxr.flags.IsBingoCampaignMode()) {
        return hintText;
    }

    bingosRemaining = dxr.flags.settings.bingo_win - class'PlayerDataItem'.static.GiveItem(dxr.player).NumberOfBingos();
    if (bingosRemaining < 1) {
        return hintText;
    }

    if (dxr.flags.settings.bingo_win == 1) {
        bingoText = "(Complete a bingo line!)";
    } else if (bingosRemaining == dxr.flags.settings.bingo_win) {
        bingoText = "(Complete " $ bingosRemaining $ " bingo lines!)";
    } else if (bingosRemaining == 1) {
        bingoText = "(Complete 1 more bingo line!)";
    } else {
        bingoText = "(Complete " $ bingosRemaining $ " more bingo lines!)";
    }

    hintLen = Len(hintText);
    bingoLen = Len(bingoText);
    if (hintLen > bingoLen) {
        for (i = 0; i < (hintLen - bingoLen) / 2; i++) {
            bingoText = " " $ bingoText;
        }
    } else {
        for (i = 0; i < (bingoLen - hintLen) / 2; i++) {
            hintText = " " $ hintText;
        }
    }

    return hintText $ class'DXRInfo'.static.CR() $ bingoText;
}
