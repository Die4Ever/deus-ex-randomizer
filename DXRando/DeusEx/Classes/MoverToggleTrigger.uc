class MoverToggleTrigger expands FlagToggleTrigger;

var byte keyFrame1;
var byte keyFrame2;
var float duration;

var bool moverMoved;

static function MoverToggleTrigger CreateMTT(
    Actor a,
    name flagName,
    name event,
    byte keyFrame1,
    byte keyFrame2,
    float duration,
    optional int flagExpiration
) {
    local MoverToggleTrigger mtt;

    if (event == '') return None;

    mtt = a.Spawn(class'MoverToggleTrigger',, event);
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

function bool MoveMover()
{
    local DeusExPlayer player;
    local #var(prefix)DeusExMover mover;

    player = DeusExPlayer(GetPlayerPawn());
    if (player == None) return false;
    foreach player.AllActors(class'#var(prefix)DeusExMover', mover, tag) break;
    if (mover == None) return false;

    if (player.flagbase.getBool(flagName))
        mover.InterpolateTo(keyFrame2, duration);
    else
        mover.InterpolateTo(keyFrame1, duration);

    return true;
}

function PostPostBeginPlay()
{
    moverMoved = false;
}

event Tick(float deltaTime)
{
    if (moverMoved == false)
        moverMoved = MoveMover();
    Super.Tick(deltaTime);
}
