class MoverToggleTrigger extends FlagToggleTrigger;

var byte keyFrame1;
var byte keyFrame2;
var float duration;

static function MoverToggleTrigger CreateMTT(
    Actor a,
    name flagName,
    name tag,
    byte keyFrame1,
    byte keyFrame2,
    float duration,
    optional int flagExpiration
) {
    local MoverToggleTrigger mtt;

    if (a == None || tag == '' || flagName == '') return None;

    mtt = a.Spawn(class'MoverToggleTrigger',, tag);
    mtt.InitMTT(flagName, keyFrame1, keyFrame2, duration, flagExpiration);
    return mtt;
}

function MoverToggleTrigger InitMTT(
    name flagName,
    byte keyFrame1,
    byte keyFrame2,
    float duration,
    optional int flagExpiration
) {
    InitFTT(flagName, flagExpiration);

    self.keyFrame1 = keyFrame1;
    self.keyFrame2 = keyFrame2;
    self.duration = duration;
}

function bool MoveMovers()
{
    local DeusExPlayer player;
    local #var(DeusExPrefix)Mover mover;
    local bool moved, flagVal;

    player = DeusExPlayer(GetPlayerPawn());
    if (player == None) return false;

    flagVal = player.flagbase.getBool(flagName);
    foreach player.AllActors(class'#var(DeusExPrefix)Mover', mover, tag) {
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
    Enable('Tick');
    Super.PostPostBeginPlay();
}

event Tick(float deltaTime)
{
    if(MoveMovers()) {
        Disable('Tick');
    }
}
