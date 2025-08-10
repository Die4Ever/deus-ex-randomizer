class BingoFrobber extends #var(DeusExPrefix)Decoration;

var string bingoEvent;
var string frobMsg;
var bool used;

replication
{
    reliable if( Role==ROLE_Authority )
        bingoEvent,frobMsg,used;
}

simulated function BeginPlay()
{
    //If DrawType is none, this isn't visible in the editor, which is annoying for placement.
    //Set it to none after the level starts so it isn't visible.  If this is bHidden, you can't
    //highlight or frob it, so we can't make it invisible that way.
    DrawType=DT_None;
}

function Frob(actor Frobber, Inventory frobWith)
{
    local #var(PlayerPawn) p;

    Super.Frob(Frobber, frobWith);

    if (used) return;

    if (frobMsg!=""){
        p=#var(PlayerPawn)(Frobber);
        if (p!=None){
            p.ClientMessage(frobMsg);
        }
    }

    class'DXREvents'.static.MarkBingo(bingoEvent);
    used=True;
}

static function BingoFrobber Create(Actor a, String displayName, Name bingoEvent, vector loc, float rad, float height, optional String frobMessage)
{
    local BingoFrobber bf;

    bf = a.Spawn(class'BingoFrobber',,bingoEvent,loc); //Tag defaults to the bingoEvent name
    bf.bingoEvent = String(bingoEvent);
    bf.SetCollisionSize(rad,height);
    bf.ItemName=displayName;
    bf.frobMsg=frobMessage;

    return bf;

}

defaultproperties
{
    Physics=PHYS_None
    bAlwaysRelevant=True
    bCollideWorld=False
    bBlockPlayers=False
    bInvincible=True
    bPushable=False
    Mesh=None
    DrawType=DT_Sprite
    Texture=Texture'Engine.S_Pickup'
    CollisionRadius=40
    CollisionHeight=40
    frobMsg=""
#ifdef hx
    ItemName="Bingo Object"
#else
    ItemName="BingoFrobber DEFAULT NAME - REPORT TO DEVS!"
#endif
}
