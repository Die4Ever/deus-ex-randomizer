class PoolTableManager extends Info;

struct BallInfo {
    var #var(prefix)Poolball ball;
    var Vector OrigLoc;
    var bool sunk;
};

var BallInfo balls[16];

//To prevent multiple bingo events from a single table
var bool stripesSunk;
var bool solidsSunk;
var bool allSunk;

static function CreatePoolTableManagers(Actor a)
{
    local #var(prefix)Poolball ball;

    foreach a.AllActors(class'#var(prefix)Poolball',ball){
        if (ball.SkinColor!=SC_Cue) continue;

        //Create a PoolTableManager for each cue ball
        Init(a,ball.Location);
    }
}

static function PoolTableManager Init(Actor a, vector Loc)
{
    local PoolTableManager ptm;
    local #var(prefix)Poolball ball;
    local int index;

    ptm = a.Spawn(class'PoolTableManager',,,Loc);

    foreach ptm.RadiusActors(class'#var(prefix)Poolball',ball,ptm.CollisionRadius){
        if (ball.Class!=class'#var(prefix)Poolball' && ball.Class!=class'#var(injectsprefix)Poolball') continue;
        ptm.AddBall(ball);
    }

    ptm.SetTimer(1.0,True);

    return ptm;
}

//Make a specific ball be owned by this PoolTableManager
//If "update" is true, it will replace a ball slot that is already occupied (for DXRReplaceActors)
function AddBall(#var(prefix)Poolball ball, optional bool update)
{
    local int index;

    index = GetBallIndex(ball);

    if (update==False && balls[index].ball!=None) return; //Don't replace a ball if it isn't owned by this

    balls[index].ball=ball;
    balls[index].OrigLoc=ball.Location;
    ball.SetOwner(self);

    AdjustBallSize(ball);
    SetBallName(ball,index);
}

function AdjustBallSize(#var(prefix)Poolball ball)
{
    //Don't shrink the cue ball
    if (ball.SkinColor==SC_Cue) return;

    //Default collision radius is 1.7, shrink the numbered balls a smidge to fit in the pockets better
    ball.SetCollisionSize(1.5,ball.CollisionHeight);
}

function SetBallName(#var(prefix)Poolball ball, int index)
{
    local string ballName;

    if(!class'MenuChoice_BalanceEtc'.static.IsEnabled()) return;

    switch(index){
        case 0: //Cue ball
            ballName="Cue Ball";
            break;
        case 8: //Eight Ball
            ballName="Eight Ball";
            break;
        default:
            ballName=index$" Ball";
            if (IsSolidIndex(index)){
                ballName = ballName$" (Solid)";
            } else if (IsStripeIndex(index)){
                ballName = ballName$" (Stripe)";
            }
            break;
    }
    ball.FamiliarName = ballName;
    ball.UnfamiliarName = ballName;
}

//Check if the given ball is owned by this PoolTableManager
function Bool BallOwnedHere(#var(prefix)Poolball ball)
{
    local int i;

    i = GetBallIndex(ball);

    return balls[i].ball==ball;
}

//#region Ball Identification
function int GetBallIndex(#var(prefix)Poolball ball)
{
    switch(ball.SkinColor){
        case SC_Cue: return 0;
        case SC_1:   return 1;
        case SC_2:   return 2;
        case SC_3:   return 3;
        case SC_4:   return 4;
        case SC_5:   return 5;
        case SC_6:   return 6;
        case SC_7:   return 7;
        case SC_8:   return 8;
        case SC_9:   return 9;
        case SC_10:  return 10;
        case SC_11:  return 11;
        case SC_12:  return 12;
        case SC_13:  return 13;
        case SC_14:  return 14;
        case SC_15:  return 15;
    }
    return -1;
}

function bool IsCueBall(#var(prefix)Poolball ball)
{
    return GetBallIndex(ball)==0;
}

function bool IsEightBall(#var(prefix)Poolball ball)
{
    return GetBallIndex(ball)==8;
}

function bool IsSolidBall(#var(prefix)Poolball ball)
{
    local int index;

    index = GetBallIndex(ball);
    return IsSolidIndex(index);
}

function bool IsStripeBall(#var(prefix)Poolball ball)
{
    local int index;

    index = GetBallIndex(ball);
    return IsStripeIndex(index);
}

function bool IsSolidIndex(int index)
{
    if (index<1) return false;
    if (index>7) return false;
    return true;
}

function bool IsStripeIndex(int index)
{
    if (index<9) return false;
    if (index>15) return false;
    return true;
}
//#endregion

function Timer()
{
    local int i;

    CheckPoolBalls();

    for (i=0;i<ArrayCount(balls);i++) {
        if (!IsBallSunk(balls[i].ball)){
            balls[i].ball.bJustHit = False;
        }
    }
}

//#region Ball Resets
function ResetPoolTable()
{
    local int i;
    local #var(prefix)Poolball ball;
    local vector OrigLoc;

    if(!class'MenuChoice_BalanceEtc'.static.IsEnabled()) return;

    for (i=0;i<ArrayCount(balls);i++) {
        ball = balls[i].ball;
        OrigLoc = balls[i].OrigLoc;

        if (ball==None) continue;

        ball.SetCollision(False,False,False);
        ball.bJustHit=true;
        ball.Velocity=vect(0,0,0);
        ball.Acceleration=vect(0,0,0);
        ball.SetLocation(OrigLoc);
    }

    for (i=0;i<ArrayCount(balls);i++) {
        balls[i].ball.SetCollision(True,True,True);
    }
}

function ResetSingleBall(int index)
{
    local #var(prefix)Poolball ball;

    if(!class'MenuChoice_BalanceEtc'.static.IsEnabled()) return;

    ball = balls[index].ball;

    if (ball==None) return;

    ball.SetCollision(False,False,False);
    ball.Velocity=vect(0,0,0);
    ball.Acceleration=vect(0,0,0);
    ball.SetLocation(balls[index].OrigLoc);
    ball.SetCollision(True,True,True);
}

function ResetCueBall()
{
    ResetSingleBall(0);
}

function ResetEightBall()
{
    ResetSingleBall(8);
}
//#endregion

function bool IsBallSunk(#var(prefix)Poolball ball)
{
    return ball.Location.Z < (Location.Z - 1);
}

function CheckPoolBalls()
{
    local int i, stripesUnsunk,solidsUnsunk;
    local bool eightUnsunk, cueUnsunk;

    for (i=0;i<ArrayCount(balls);i++){
        //DEBUGClientMessage("Ball "$i$" "$balls[i].ball);
        if (balls[i].ball==None) continue; //Skip balls that never existed

        if (!IsBallSunk(balls[i].ball)){
            //DEBUGClientMessage(balls[i].ball$" is NOT sunk");
            //Ball is unsunk
            if (IsSolidIndex(i)){
                solidsUnsunk++;
            } else if (IsStripeIndex(i)) {
                stripesUnsunk++;
            } else if (IsEightBall(balls[i].ball)) {
                eightUnsunk=true;
            } else if (IsCueBall(balls[i].ball)) {
                cueUnsunk=true;
            }
        } else {
            balls[i].ball.bJustHit=true;
            ReportBallSunk(i);
        }
    }
    if (class'MenuChoice_BalanceEtc'.static.IsEnabled() && !eightUnsunk && stripesUnsunk!=0 && solidsUnsunk!=0) {
        //If you sank the eightball before one set of balls has been sunk, RESET
        //Or should it just reset the eightball? (see below)
        ResetPoolTable();
        return;
    }

    //Reset the cueball if it's been sunk
    if (!cueUnsunk) ResetCueBall();

    if (stripesUnsunk==0) ReportStripesSunk();
    if (solidsUnsunk==0)  ReportSolidsSunk();

    //Just unsink the eight ball?
    //if (!eightUnsunk && stripesUnsunk!=0 && solidsUnsunk!=0) {
    //    ResetEightBall();
    //    eightUnsunk=true;
    //}

    if (stripesUnsunk==0 && solidsUnsunk==0 && !eightUnsunk) {
        ReportAllSunk();
        //ResetPoolTable(); //Also reset the table?
    }
}
//#region Bingo Events
function ReportBallSunk(int index)
{
    if (balls[index].sunk) return;

    balls[index].sunk=true;
    class'DXREvents'.static.MarkBingo("PoolTableBall"$index);
    //DEBUGClientMessage("Sunk ball "$index);

}

function ReportStripesSunk()
{
    if (stripesSunk) return;

    stripesSunk=true;
    class'DXREvents'.static.MarkBingo("PoolTableStripes");
    //DEBUGClientMessage("All Stripes sunk");
}

function ReportSolidsSunk()
{
    if (solidsSunk) return;

    solidsSunk=true;
    class'DXREvents'.static.MarkBingo("PoolTableSolids");
    //DEBUGClientMessage("All Solids sunk");
}

function ReportAllSunk()
{
    if (allSunk) return;

    allSunk=true;
    class'DXREvents'.static.MarkBingo("PlayPool"); //The legacy "Sink all balls" goal
    //DEBUGClientMessage("All balls sunk");
}
//#endregion

function DEBUGClientMessage(string msg)
{
    local #var(PlayerPawn) p;

    foreach AllActors(class'#var(PlayerPawn)',p){break;}

    p.ClientMessage("PTM: "$msg);
}


defaultproperties
{
    CollisionRadius=150
    CollisionHeight=2
    bCollideActors=True
}
