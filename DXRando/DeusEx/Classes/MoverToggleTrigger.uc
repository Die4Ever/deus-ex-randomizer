class MoverToggleTrigger extends FlagToggleTrigger;

var byte keyFrame1;
var byte keyFrame2;
var float duration;

var bool moversMoved;

static function MoverToggleTrigger CreateMTT(
    Actor a,
    name flagName,
    name tag,
    byte keyFrame1,
    byte keyFrame2,
    float duration,
    optional int flagExpiration
) {
    if (a == None) return None;
    return _CreateMTT(a.Spawn(class'MoverToggleTrigger',, tag), flagName, tag, keyFrame1, keyFrame2, duration, flagExpiration);
}

static function MoverToggleTrigger _CreateMTT(
    MoverToggleTrigger mtt,
    name flagName,
    name tag,
    byte keyFrame1,
    byte keyFrame2,
    float duration,
    optional int flagExpiration
) {
    if (mtt == None || tag == '' || flagName == '') return None;

    mtt.flagName = flagName;
    mtt.keyFrame1 = keyFrame1;
    mtt.keyFrame2 = keyFrame2;
    mtt.duration = duration;

    if (flagExpiration == 0)
        mtt.flagExpiration = 999;
    else
        mtt.flagExpiration = flagExpiration;

    return mtt;
}

function bool MoveMovers()
{
    local DeusExPlayer player;
    local #var(prefix)DeusExMover mover;
    local bool moved, flagVal;

    player = DeusExPlayer(GetPlayerPawn());
    if (player == None) return false;

    flagVal = player.flagbase.getBool(flagName);
    foreach player.AllActors(class'#var(prefix)DeusExMover', mover, tag) {
        if (flagVal)
            mover.InterpolateTo(keyFrame2, duration);
        else
            mover.InterpolateTo(keyFrame1, duration);
        moved = true;
    }

    return moved;
}

function PostPostBeginPlay()
{
    moversMoved = false;
    Super.PostPostBeginPlay();
}

event Tick(float deltaTime)
{
    if (moversMoved == false)
        moversMoved = MoveMovers();
    Super.Tick(deltaTime);
}
