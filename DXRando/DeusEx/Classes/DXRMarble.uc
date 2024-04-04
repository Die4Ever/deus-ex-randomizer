class DXRMarble extends #var(injectsprefix)Poolball;

//Reduce drawscale to look more like marbles, but leave
//the collision the same for more slipperiness
defaultproperties
{
     bInvincible=False
     ItemName="Marble"
     DrawScale=0.5
     HitPoints=5
     FragType=Class'DeusEx.GlassFragment'
}
