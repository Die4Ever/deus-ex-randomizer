class CreditsBingoWindow extends Window;

const bingoWidth = 395;
const bingoHeight = 360;
const bingoStartX = 16;
const bingoStartY = 22;

function FillBingoWindow(#var(PlayerPawn) player)
{
    local int x, y, progress, max;
    local string event, desc;
    local PlayerDataItem data;
    local int bActiveMission;

    data = class'PlayerDataItem'.static.GiveItem(player);

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            bActiveMission = data.GetBingoSpot(x, y, event, desc, progress, max);
            CreateBingoSpot(x, y, desc, progress, max, bActiveMission);
        }
    }

}

// we can fit about 6 lines of text, about 14 characters wide
function BingoTile CreateBingoSpot(int x, int y, string text, int progress, int max, int bActiveMission)
{
    local BingoTile t;
    local int w, h;
    t = BingoTile(NewChild(class'BingoTile'));
    t.SetText(text);
    t.SetWordWrap(true);
    t.SetTextAlignments(HALIGN_Center, VALIGN_Center);
    t.SetFont(Font'FontMenuSmall_DS');
    w = bingoWidth/5;
    h = bingoHeight/5;
    t.SetSize(w-1, h-1);
    t.SetPos(x * w + bingoStartX, y * h + bingoStartY);
    t.SetProgress(progress, max, bActiveMission);
    return t;
}
