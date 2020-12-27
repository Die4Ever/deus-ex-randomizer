class DXRWeapon merges DeusExWeapon abstract;

function PostBeginPlay()
{
    local DXRWeapons m;
    _PostBeginPlay();

    foreach AllActors(class'DXRWeapons', m) {
        m.RandoWeapon(self);
        break;
    }
}
