class SmugglerElevatorTracker expands FlagToggleTrigger;

var bool street, elevatorMoved;

static function SmugglerElevatorTracker CreateSET(DXRando dxr)
{
    local SmugglerElevatorTracker set;

    set = dxr.Spawn(class'SmugglerElevatorTracker',, 'elevatorbutton');
    set.street = dxr.localURL == "02_NYC_STREET" || dxr.localURL == "04_NYC_STREET" || dxr.localURL == "08_NYC_STREET";
    set.flagExpiration = dxr.dxInfo.missionNumber + 1;

    return set;
}

event Tick(float deltaTime)
{
    if (elevatorMoved == false) {
        MoveElevator();
        elevatorMoved = true;
    }
    Super.Tick(deltaTime);
}

function MoveElevator()
{
    local DeusExPlayer player;
    local #var(prefix)DeusExMover elevator;

    player = DeusExPlayer(GetPlayerPawn());
    foreach player.AllActors(class'#var(prefix)DeusExMover', elevator, 'elevatorbutton') break;

    if (player.flagbase.getBool(flagName))
        elevator.InterpolateTo(Float(street), 0.0);
    else
        elevator.InterpolateTo(Float(!street), 0.0);
}

function PostPostBeginPlay()
{
    elevatorMoved = false;
}

defaultproperties
{
    flagName="DXRSmugglerElevatorUsed"
}
