class DXRFixupM01 extends DXRFixup;


function PostFirstEntryMapFixes()
{
    local DeusExMover m;
    local BlockPlayer bp;

    FixUNATCORetinalScanner();

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        foreach AllActors(class'DeusExMover', m, 'UN_maindoor') {
            m.bBreakable = false;
            m.bPickable = false;
            m.bIsDoor = false;// this prevents Floyd from opening the door
        }
        foreach AllActors(class'BlockPlayer', bp) {
            if(bp.Group == 'waterblock') {
                bp.bBlockPlayers = false;
            }
        }
        break;
    }

}


function PreFirstEntryMapFixes()
{
    switch(dxr.localURL) {
        case "01_NYC_UNATCOHQ":
        //Spawn some placeholders for new item locations
        Spawn(class'PlaceholderItem',,, vect(363.284149, 344.847, 50.32)); //Womens bathroom counter
        Spawn(class'PlaceholderItem',,, vect(211.227, 348.46, 50.32)); //Mens bathroom counter
        Spawn(class'PlaceholderItem',,, vect(982.255,1096.76,-7)); //Jaime's desk
        Spawn(class'PlaceholderItem',,, vect(2033.8,1979.9,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(2148,2249,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(2433,1384,-85)); //Near MJ12 Door
        Spawn(class'PlaceholderItem',,, vect(-307.8,-1122,-7)); //Anna's Desk
        Spawn(class'PlaceholderItem',,, vect(-138.5,-790.1,-1.65)); //Anna's bookshelf
        Spawn(class'PlaceholderItem',,, vect(-27,1651.5,291)); //Breakroom table
        Spawn(class'PlaceholderItem',,, vect(602,1215.7,295)); //Kitchen Counter
        Spawn(class'PlaceholderItem',,, vect(-672.8,1261,473)); //Upper Left Office desk
        Spawn(class'PlaceholderContainer',,, vect(-1187,-1154,-31)); //Behind Jail Desk
        Spawn(class'PlaceholderContainer',,, vect(2384,1669,-95)); //MJ12 Door
        Spawn(class'PlaceholderContainer',,, vect(-383.6,1376,273)); //JC's Office
        break;
    }
}
