class PlayerMoverToggleTrigger extends MoverToggleTrigger;

var Vector loc;

var bool playerMoved;

static function PlayerMoverToggleTrigger CreatePMTT(
    Actor a,
    name flagName,
    name tag,
    byte keyFrame1,
    byte keyFrame2,
    float duration,
    Vector loc,
    optional int flagExpiration
) {
    local PlayerMoverToggleTrigger pmtt;

    pmtt = a.Spawn(class'PlayerMoverToggleTrigger',, tag);
    _CreateMTT(pmtt, flagName, tag, keyFrame1, keyFrame2, duration, flagExpiration);
    pmtt.loc = loc;

    return pmtt;
}

function PostPostBeginPlay()
{
    playerMoved = false;
    Super.PostPostBeginPlay();
}

event Tick(float deltaTime)
{
    local DeusExPlayer player;

    Super.Tick(deltaTime);

    if (moversMoved && (playerMoved == false)) {
        player = DeusExPlayer(GetPlayerPawn());
        if (player == None) return;

        if (player.location == loc)
            playerMoved = true;
        else
            player.SetLocation(loc);
    }
}
