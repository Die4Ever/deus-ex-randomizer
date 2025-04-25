class DXRContainers injects #var(prefix)Containers;

//Only drop the contents when the health is 0 to prevent crate content duping 
//by carrying through level transitions.
function Destroyed()
{
    if (HitPoints<=0){
        //Normal "Containers" Destroyed behaviour, including dropping items
        Super.Destroyed();
    } else {
        //DeusExDecoration won't drop items for Containers
        Super(#var(DeusExPrefix)Decoration).Destroyed();
    }
}
