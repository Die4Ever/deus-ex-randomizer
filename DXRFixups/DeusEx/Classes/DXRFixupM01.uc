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
