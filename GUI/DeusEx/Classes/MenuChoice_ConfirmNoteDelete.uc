//=============================================================================
// MenuChoice_ConfirmNoteDelete
//=============================================================================

class MenuChoice_ConfirmNoteDelete extends DXRMenuUIChoiceBool;

defaultproperties
{
     enabled=True;
     defaultInfoWidth=243
     defaultInfoPosX=203
     HelpText="Confirm when deleting a note"
     actionText="Confirm Note Deletion"
     enumText(0)="Don't Confirm"
     enumText(1)="Confirm"
}
