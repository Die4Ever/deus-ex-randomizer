class DXRGoal injects DeusExGoal;

var travel int goalMission;

function SetName( Name newGoalName )
{
    local DXRando dxr;
    
    goalName = newGoalName;
    
    //Also keep track of what mission this name was set on
    //This is maybe more clean than requiring the mission number to be
    //set by the DeusExPlayer, since that would require modifying the
    //AddGoal code as well
    foreach AllObjects(class'DXRando',dxr)
    {
        goalMission = dxr.dxInfo.missionNumber;
        return;
    }
}