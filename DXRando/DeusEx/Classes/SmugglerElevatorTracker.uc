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
    if (elevatorMoved == false)
        elevatorMoved = MoveElevator();
    Super.Tick(deltaTime);
}

function bool MoveElevator()
{
    local DeusExPlayer player;
    local #var(prefix)DeusExMover elevator;

    player = DeusExPlayer(GetPlayerPawn());
    if (player == None) return false;
    foreach player.AllActors(class'#var(prefix)DeusExMover', elevator, 'elevatorbutton') break;
    if (elevator == None) return false;

    if (player.flagbase.getBool(flagName))
        elevator.InterpolateTo(Int(street), 0.0);
    else
        elevator.InterpolateTo(Int(!street), 0.0);

    return true;
}

function PostPostBeginPlay()
{
    elevatorMoved = false;
}

defaultproperties
{
    flagName="DXRSmugglerElevatorUsed"
}
