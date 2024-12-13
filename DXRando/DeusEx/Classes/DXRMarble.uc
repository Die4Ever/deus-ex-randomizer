class DXRMarble extends #var(injectsprefix)Poolball;

//Reduce drawscale to look more like marbles, but leave
//the collision the same for more slipperiness
//Revision sets bCanBeBase to true for poolballs for some reason
//make sure they can't be, so they stay slippery
defaultproperties
{
     bCanBeBase=False
     bInvincible=False
     ItemName="Marble"
     DrawScale=0.5
     HitPoints=5
     FragType=Class'DeusEx.GlassFragment'
}
