class DXRAugmentation merges Augmentation;

function PostBeginPlay()
{
    local DXRAugmentations a;
    Super.PostBeginPlay();

    foreach AllActors(class'DXRAugmentations', a) {
        a.RandoAug(self);
        break;
    }
}
