class PlaceholderEnemy extends #var(prefix)ThugMale;

static function PlaceholderEnemy Create(DXRBase a, vector loc, optional int yaw, optional Name orders, optional Name ordertag, optional Name Alliance, optional float playerAllianceLevel)
{
    local PlaceholderEnemy e;
    local rotator r;

    if (orders=='Shitting'){
        if (!a.IsAprilFools()){
            return None;
        }
        orders = 'Sitting';
    }

    r = a.rotm(0, yaw, 0, 16384);// Pawns need an offset of 16384
    e = a.Spawn(class'PlaceholderEnemy',,, loc, r);
    e.Alliance = Alliance;
    if(playerAllianceLevel != 0) {
        e.InitialAlliances[0].AllianceLevel = playerAllianceLevel;
    }
    e.InitializeAlliances(); //Needed to populate Alliance table in time for enemy shuffling
    if(orders!='') {
        e.SetOrders(orders, ordertag, false);
        e.FollowOrders();
    }
    log("Created "$ class'DXRInfo'.static.ActorToString(e) @ Alliance, 'PlaceholderEnemy');

#ifdef locdebug
    if("#var(locdebug)"~="PlaceholderEnemy") DXRActorsBase(class'DXRActorsBase'.static.Find()).DebugMarkKeyPosition(e.Location, e.Name);
#endif

    return e;
}

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    if(!class'DXRVersion'.static.VersionIsStable()) {
        Mesh=LodMesh'DeusExItems.TestBox';
    }
}

auto state StartUpScout
{
    // nil
}

defaultproperties
{
    Mesh=None
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1.000000)
    orders=DynamicPatrolling
    bInitialized=True
    bDetectable=False
    bIgnore=True
}
