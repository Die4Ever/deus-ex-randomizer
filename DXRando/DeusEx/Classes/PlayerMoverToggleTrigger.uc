class PlayerMoverToggleTrigger extends MoverToggleTrigger;

var Vector loc;
var float radius;

var bool playerMoved;

static function PlayerMoverToggleTrigger CreatePMTT(
    Actor a,
    name flagName,
    name tag,
    byte keyFrame1,
    byte keyFrame2,
    float duration,
    Vector loc,
    optional int flagExpiration,
    optional float radius
) {
    local PlayerMoverToggleTrigger pmtt;

    if (a == None || tag == '' || flagName == '') return None;

    pmtt = a.Spawn(class'PlayerMoverToggleTrigger',, tag);
    pmtt.InitPMTT(flagName, keyFrame1, keyFrame2, duration, loc, flagExpiration, radius);
    return pmtt;
}

function InitPMTT(
    name flagName,
    byte keyFrame1,
    byte keyFrame2,
    float duration,
    Vector loc,
    optional int flagExpiration,
    optional float radius
) {
    InitMTT(flagName, keyFrame1, keyFrame2, duration, flagExpiration);

    self.loc = loc;
    self.radius = radius;
}

function PostPostBeginPlay()
{
    playerMoved = false;
    Super.PostPostBeginPlay();
}

event Tick(float deltaTime)
{
    local DeusExPlayer player;
    local float distance;

    Super.Tick(deltaTime);

    if (moversMoved && (playerMoved == false)) {
        player = DeusExPlayer(GetPlayerPawn());
        if (player == None) return;

        distance = VSize(player.location - loc);
        if (distance < 10.0 || (radius != 0.0 && distance > radius))
            playerMoved = true;
        else
            player.SetLocation(loc);
    }
}
