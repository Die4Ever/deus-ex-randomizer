class PoolTableManager extends Info;

struct BallInfo {
    var #var(prefix)Poolball ball;
    var Vector OrigLoc;
    var bool sunk;
};

var BallInfo balls[16];
var ZoneInfo TableZone;

var #var(PlayerPawn) lastPlayer;

//To prevent multiple bingo events from a single table
var bool stripesSunk;
var bool solidsSunk;
var bool allSunk;
var bool allSunkRepeatable;

//Timing purposes
var float firstFrob;

static function CreatePoolTableManagers(Actor a)
{
    local #var(prefix)Poolball ball;

    foreach a.AllActors(class'#var(prefix)Poolball',ball){
        if (ball.SkinColor!=SC_Cue) continue;

        //Create a PoolTableManager for each cue ball
        Init(ball);
    }
}

static function PoolTableManager Init(#var(prefix)Poolball cue)
{
    local PoolTableManager ptm;
    local #var(prefix)Poolball ball;
    local int index;

    ptm = cue.Spawn(class'PoolTableManager',,,cue.Location);

    ptm.TableZone = cue.Region.Zone;
    ptm.TableZone.ZoneGroundFriction = FMax(0.25, ptm.TableZone.ZoneGroundFriction); // default seems to be 0.2

    foreach ptm.tableZone.ZoneActors(class'#var(prefix)Poolball',ball){
        if (ball.Class!=class'#var(prefix)Poolball' && ball.Class!=class'#var(injectsprefix)Poolball') continue;
        ptm.AddBall(ball);
    }

    ptm.AnalyzeTable();

    ptm.SetTimer(1.0,True);

    return ptm;
}

//Figure out the table orientation and determine the proper locations for all the balls
//so that they'll be properly racked after a reset
function AnalyzeTable()
{
    local float xPos,xNeg,yPos,yNeg, yWidth, xWidth, longDist;
    local vector CueLoc,RackLoc,HitLoc,HitNormal,TraceEnd, Centre;
    local rotator TableRot;
    local Actor HitActor;
    local int i;

    CueLoc = balls[0].OrigLoc;

    //Assess the length and width of the table, from the cue ball location
    //Positive X direction
    TraceEnd = CueLoc + vect(150,0,0);
    HitActor = Trace(HitLoc,HitNormal,TraceEnd,,false);
    xPos = VSize(HitLoc - CueLoc);

    //Negative X direction
    TraceEnd = CueLoc + vect(-150,0,0);
    HitActor = Trace(HitLoc,HitNormal,TraceEnd,,false);
    xNeg = VSize(HitLoc - CueLoc);

    xWidth = xPos + xNeg;

    //Positive Y direction
    TraceEnd = CueLoc + vect(0,150,0);
    HitActor = Trace(HitLoc,HitNormal,TraceEnd,,false);
    yPos = VSize(HitLoc - CueLoc);

    //Negative Y direction
    TraceEnd = CueLoc + vect(0,-150,0);
    HitActor = Trace(HitLoc,HitNormal,TraceEnd,,false);
    yNeg = VSize(HitLoc - CueLoc);

    yWidth = yPos + yNeg;

    //Determine the centre of the table based on the measurements above
    Centre = class'DXRBase'.static.MakeVector(CueLoc.X + ((xPos-xNeg)/2), CueLoc.Y + ((yPos-yNeg)/2),CueLoc.Z);

    //Determine Table Rotation
    if (xWidth < yWidth){
        longDist = yWidth;
        TableRot = Rot(0,0,0);
    } else {
        longDist = xWidth;
        TableRot = Rot(0,16384,0);
    }

    //"Default" table orientation is assumed to be Narrow Direction on the X axis, Long Direction on the Y.
    //Cue ball is a quarter of the table length (Y) positive, racked balls a quarter of the table length (Y) negative
    //This is the orientation of the NYC Bar pool table in vanilla
    CueLoc = Centre + (class'DXRBase'.static.MakeVector(0,(longDist/4),0) >> TableRot);
    RackLoc = Centre + (class'DXRBase'.static.MakeVector(0,-(longDist/4),0) >> TableRot);

    //Set the Cue Ball location to the calculated one
    balls[0].OrigLoc = CueLoc;

    //Set the location of the rest of the balls into the rack
    for(i=1;i<ArrayCount(balls);i++){
        if (balls[i].ball==None) continue;
        balls[i].OrigLoc = RackLoc + (GetRackOffset(i) >> TableRot);
    }
}

//Offsets determined based on the 02_NYC_BAR starting rack
//Some balls have been swapped around to make it a valid rack
//particularly, 8 ball to middle, and 1 ball to front
function Vector GetRackOffset(int i)
{
    switch(i){
        case 1:
            //return vect(0.555908,8.168701,-0.283325);
            return vect(0.555908,8.168701,0);
        case 2:
            return vect(-4.435303,0.176147,0);
        case 3:
            return vect(7.976807,-2.339233,0);
        case 4:
            return vect(4.365479,-2.451050,0);
        case 5:
            return vect(2.594971,5.455811,0);
        case 6:
            return vect(6.104736,0.283813,0);
        case 7:
            return vect(2.607666,0.164307,0);
        case 8:
            return vect(0.894775,2.861328,0);
        case 9:
            return vect(4.302002,2.836792,0);
        case 10:
            return vect(-2.510498,2.627075,0);
        case 11:
            return vect(-0.985107,5.360718,0);
        case 12:
            return vect(-6.130615,-2.460693,0);
        case 13:
            return vect(-2.745850,-2.640869,0);
        case 14:
            return vect(-0.963623,-0.136963,0);
        case 15:
            return vect(0.956299,-2.591187,0);
    }
    return vect(0,0,0);
}

//Make a specific ball be owned by this PoolTableManager
//If "update" is true, it will replace a ball slot that is already occupied (for DXRReplaceActors)
function AddBall(#var(prefix)Poolball ball, optional bool update)
{
    local int index;

    index = GetBallIndex(ball);

    if (update==False && balls[index].ball!=None) return; //Don't replace a ball if it isn't owned by this

    balls[index].ball=ball;

    if (!update){
        //"Update" will retain whatever location was stored before
        balls[index].OrigLoc=ball.Location;
    }
    if(index==0) ball.ScaleGlow = FMax(3, ball.ScaleGlow); // make the cue ball stick out more
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

function BallFrobbed(Actor Frobber)
{
    if (firstFrob==0){
        firstFrob = Level.TimeSeconds;
    }
    lastPlayer = #var(PlayerPawn)(Frobber);
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
function ResetPoolTable(optional bool eightBall)
{
    local int i;
    local #var(prefix)Poolball ball;
    local vector OrigLoc;

    if(!class'MenuChoice_BalanceEtc'.static.IsEnabled() && eightBall) return;

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

    firstFrob = 0;
    allSunkRepeatable = false;
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
        //ClientMessage("Ball "$i$" "$balls[i].ball);
        if (balls[i].ball==None) continue; //Skip balls that never existed

        if (!IsBallSunk(balls[i].ball)){
            //ClientMessage(balls[i].ball$" is NOT sunk");
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
        ResetPoolTable(true);
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
    class'DXREvents'.static.MarkBingo("PoolTableBall"$index); //A specific ball sunk
    class'DXREvents'.static.MarkBingo("PoolTableBallSunk"); //Generic "any ball" sunk
    //ClientMessage("Sunk ball "$index);

    if (IsStripeIndex(index)){
        class'DXREvents'.static.MarkBingo("PoolTableStripeBallSunk");
    } else if (IsSolidIndex(index)){
        class'DXREvents'.static.MarkBingo("PoolTableSolidBallSunk");
    }

}

function ReportStripesSunk()
{
    if (stripesSunk) return;

    stripesSunk=true;
    class'DXREvents'.static.MarkBingo("PoolTableStripes");
    //ClientMessage("All Stripes sunk");
}

function ReportSolidsSunk()
{
    if (solidsSunk) return;

    solidsSunk=true;
    class'DXREvents'.static.MarkBingo("PoolTableSolids");
    //ClientMessage("All Solids sunk");
}

function ReportAllSunk()
{
    local float completeTime;

    if (!allSunkRepeatable){
        //Allow the toot to be sent every time you clear the table
        completeTime = Level.TimeSeconds - firstFrob;
        class'DXREvents'.static.SendPoolTableComplete(completeTime); //A telemetry message for finishing the table

        ClientMessage("All balls sunk in "$class'DXRInfo'.static.ConstructTimeStr(completeTime)$"!");
        allSunkRepeatable=true;
    }

    if (allSunk) return;

    allSunk=true;
    class'DXREvents'.static.MarkBingo("PlayPool"); //The legacy "Sink all balls" goal

    //ClientMessage("All balls sunk");
}
//#endregion

function ClientMessage(string msg)
{
    if (lastPlayer!=None){
        lastPlayer.ClientMessage(msg);
    }
}


defaultproperties
{
    CollisionRadius=150
    CollisionHeight=2
    bCollideActors=True
}
