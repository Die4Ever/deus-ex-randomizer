class PlaceholderEnemy extends #var(prefix)ThugMale;

static function PlaceholderEnemy Create(Actor a, vector loc, optional rotator rot, optional Name orders, optional Name ordertag)
{
    local PlaceholderEnemy e;
    e = a.Spawn(class'PlaceholderEnemy',,, loc, rot);
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
