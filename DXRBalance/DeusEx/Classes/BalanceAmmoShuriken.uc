class BalanceAmmoShuriken injects AmmoShuriken;

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        AmmoAmount=10;
        MaxAmmo=100;
    } else {
        AmmoAmount=5;
        MaxAmmo=25;
    }
    default.AmmoAmount = AmmoAmount;
    default.MaxAmmo = MaxAmmo;
    Super.BeginPlay();
}

defaultproperties
{
    AmmoAmount=10
    MaxAmmo=100
    Icon=Texture'DeusExUI.Icons.BeltIconShuriken'
    ItemName="Throwing Knives"
    ItemArticle="some"
    Description="A favorite weapon of assassins in the Far East for centuries, throwing knives can be deadly when wielded by a master but are more generally used when it becomes desirable to send a message. The message is usually 'Your death is coming on swift feet.'"
}
