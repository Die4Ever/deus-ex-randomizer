class DXRTrashbag2 injects #var(prefix)Trashbag2;

function Tick(float deltaTime)
{
    if (IsInState('Burning')) {
        AmbientSound = Sound'Ambient.Ambient.FireSmall1';
    }
    Super.Tick(deltaTime);
}

function Destroyed()
{
    local DXRando dxr;

    if (IsInState('Burning')){
        foreach AllActors(class'DXRando',dxr){
            class'DXREvents'.static.MarkBingo(dxr,"BurnTrash");
        }
    }

    class'TrashContainerCommon'.static.GenerateTrashPaper(self, 0.5);

    Super.Destroyed();
}

defaultproperties
{
     bGenerateTrash=False
}
