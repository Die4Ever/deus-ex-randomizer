class PlaceholderEnemy extends #var(prefix)ThugMale;

static function PlaceholderEnemy Create(DXRBase a, vector loc, optional int yaw, optional Name orders, optional Name ordertag)
{
    local PlaceholderEnemy e;
    local rotator r;
    r = a.rotm(0, yaw, 0, 16384);// Pawns need an offset of 16384
    e = a.Spawn(class'PlaceholderEnemy',,, loc, r);
    e.InitializeAlliances(); //Needed to populate Alliance table in time for enemy shuffling
    if(orders!='') {
        e.SetOrders(orders, ordertag, false);
        e.FollowOrders();
    }
    log("Created "$ class'DXRInfo'.static.ActorToString(e), 'PlaceholderEnemy');
    return e;
}

defaultproperties
{
    Mesh=LodMesh'DeusExItems.TestBox'
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1.000000)
}
