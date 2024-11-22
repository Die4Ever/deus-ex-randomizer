class DXRBingoCampaign extends DXRActorsBase transient;

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
            foreach AllActors(class'BlackHelicopter', jock) {
                AddBingoEventBlocker(jock, 'DXRando_Mission03_BingoCompleted');
                break;
            }
            break;
        case "04_NYC_UNATCOISLAND":
            NewBingoBoard();
            break;
        case "05_NYC_UNATCOMJ12LAB":
            if (!dxr.flagbase.GetBool('DXRando_Mission04_BingoCompleted')) {
                SetTimer(1.0, true);
            }
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
            if (!dxr.flagbase.GetBool('DXRando_Mission10_BingoCompleted')) {
                SetTimer(1.0, true);
            }
            NewBingoBoard();
            break;
        case "12_VANDENBERG_CMD":
            NewBingoBoard();
            break;
        case "14_VANDENBERG_SUB":
            if (!dxr.flagbase.GetBool('DXRando_Mission12_BingoCompleted')) {
                // TODO: remove once Gas Station Jock's event is getting changed after he appears
                SetTimer(1.0, true);
            }
            NewBingoBoard();
            break;
        case "15_AREA51_BUNKER":
            NewBingoBoard();
            break;
        case "15_AREA51_FINAL":
            foreach AllActors(class'Switch1', button, 'destroy_generator_switch') {
                AddBingoEventBlocker(button, 'DXRando_Mission15_BingoCompleted');
                break;
            }
            foreach AllActors(class'#var(prefix)FlagTrigger', ft) {
                if (ft.event == 'Merge_helios_exit') {
                    AddBingoEventBlocker(ft, 'DXRando_Mission15_BingoCompleted');
                    break;
                }
            }
            break;
        case "15_AREA51_PAGE":
            foreach AllActors(class'Switch1', button, 'kill_page_switch') {
                AddBingoEventBlocker(button, 'DXRando_Mission15_BingoCompleted');
                break;
            }
            break;
    }
}

function AnyEntry()
{
    if (!dxr.flags.IsBingoCampaignMode()) return;

    Super.AnyEntry();

    switch (dxr.localURL) {
        case "01_NYC_UNATCOISLAND":
            GetConversation('GotoM02').AddFlagRef('DXRando_Mission01_BingoCompleted', true);
            break;
        case "02_NYC_BATTERYPARK":
            GetConversation('BoatLeaving').AddFlagRef('DXRando_Mission02_BingoCompleted', true);
            break;
        case "02_NYC_WAREHOUSE":
            GetConversation('JockExit').AddFlagRef('DXRando_Mission02_BingoCompleted', true);
            break;
        case "03_NYC_AIRFIELD":
            GetConversation('M03JockLeave').AddFlagRef('DXRando_Mission03_BingoCompleted', true);
            break;
        case "05_NYC_UNATCOISLAND":
            GetConversation('M05MeetJock').AddFlagRef('DXRando_Mission05_BingoCompleted', true);
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            GetConversation('M06JockExit').AddFlagRef('DXRando_Mission06_BingoCompleted', true);
            break;
        case "08_NYC_STREET":
            GetConversation('M08JockExit').AddFlagRef('DXRando_Mission08_BingoCompleted', true);
            break;
        case "09_NYC_GRAVEYARD":
            GetConversation('M09JockLeave').AddFlagRef('DXRando_Mission09_BingoCompleted', true);
            break;
        case "10_PARIS_CHATEAU":
            UpdateChateauInvisibleWall();
            break;
        case "11_PARIS_EVERETT":
            GetConversation('TakeOff').AddFlagRef('DXRando_Mission11_BingoCompleted', true);
            break;
        // TODO: uncomment once Jock's event is getting changed after he appears
        /* case "12_Vandenberg_GAS":
            GetConversation('M12JockFinal').AddFlagRef('DXRando_Mission12_BingoCompleted', true);
            GetConversation('M12JockFinal2').AddFlagRef('DXRando_Mission12_BingoCompleted', true);
            break; */
        case "14_OCEANLAB_SILO":
            GetConversation('JockArea51').AddFlagRef('DXRando_Mission14_BingoCompleted', true);
            break;
    }
}

function Timer()
{
    local #var(PlayerPawn) p;

    Super.Timer();

    p = player();
    p.TakeDamage(10000, p, p.Location, vect(0,0,0), 'Exploded');
}

function NewBingoBoard()
{
    local DXREvents events;

    foreach AllActors(class'DXREvents', events) break;
    if (events == None) return;

    dxr.flags.settings.starting_map = dxr.dxInfo.missionNumber * 10;
    events.CreateBingoBoard();
    ClearDataVaultImages();
}

function AddBingoEventBlocker(Actor a, name bingoFlag)
{
    local FlagTrigger ft;
    local name glue;

    glue = dxr.flagbase.StringToName(a.event $ "_bingoblocker");

    ft = Spawn(class'#var(prefix)FlagTrigger',, glue);
    ft.flagName = bingoFlag;
    ft.bSetFlag = false;
    ft.bTrigger = true;
    ft.SetCollision(false, false, false);
    ft.event = a.event;
    a.event = glue;
    if (Trigger(a) != None) {
        Trigger(a).bTriggerOnceOnly = false;
    }
}

function UpdateChateauInvisibleWall()
{
    local PayPhone invisibleWall;

    if (dxr.flagbase.GetBool('DXRando_Mission10_BingoCompleted')) {
        foreach AllActors(class'PayPhone', invisibleWall, 'invisible_wall') {
            invisibleWall.SetCollision(false, false, false);
            break;
        }
    }
}

function HandleBingo(int numBingos)
{
    if (!dxr.flags.IsBingoCampaignMode() || numBingos < dxr.flags.settings.bingo_win) return;
    info("Number of bingos: "$numBingos$" has exceeded the bingo campaign win threshold! "$dxr.flags.settings.bingo_win);

    switch (dxr.flags.settings.starting_map / 10) {
        case 1:
            dxr.flagbase.SetBool('DXRando_Mission01_BingoCompleted', true,, 2);
            break;
        case 2:
            dxr.flagbase.SetBool('DXRando_Mission02_BingoCompleted', true,, 3);
            break;
        case 3:
            dxr.flagbase.SetBool('DXRando_Mission03_BingoCompleted', true,, 4);
            break;
        case 4:
            dxr.flagbase.SetBool('DXRando_Mission04_BingoCompleted', true,, 6);
            break;
        case 5:
            dxr.flagbase.SetBool('DXRando_Mission05_BingoCompleted', true,, 6);
            break;
        case 6:
            dxr.flagbase.SetBool('DXRando_Mission06_BingoCompleted', true,, 8);
            break;
        case 8:
            dxr.flagbase.SetBool('DXRando_Mission08_BingoCompleted', true,, 9);
            break;
        case 9:
            dxr.flagbase.SetBool('DXRando_Mission09_BingoCompleted', true,, 10);
            break;
        case 10:
            dxr.flagbase.SetBool('DXRando_Mission10_BingoCompleted', true,, 12);
            UpdateChateauInvisibleWall();
            break;
        case 11:
            dxr.flagbase.SetBool('DXRando_Mission11_BingoCompleted', true,, 12);
            break;
        case 12:
            dxr.flagbase.SetBool('DXRando_Mission12_BingoCompleted', true,, 15);
            break;
        case 14:
            dxr.flagbase.SetBool('DXRando_Mission14_BingoCompleted', true,, 15);
            break;
        case 15:
            dxr.flagbase.SetBool('DXRando_Mission15_BingoCompleted', true);
            break;
    }
}
