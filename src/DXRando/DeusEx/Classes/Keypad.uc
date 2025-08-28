class DXRKeypad injects Keypad;

var() bool bCodeKnown;
var() bool bUnlock;
var() bool bGrouped;// set bCodeKnown of others

simulated function ActivateKeypadWindow(DeusExPlayer Hacker, bool bHacked)
{
   local DeusExRootWindow root;

   root = DeusExRootWindow(Hacker.rootWindow);
   if (root != None)
   {
#ifdef gmdxae
        //SARGE: GMDX AE uses a subwindow so it can display notes.
        Super.ActivateKeypadWindow(Hacker,GetInstantSuccess(Hacker,bHacked));
#else
        keypadwindow = HUDKeypadWindow(root.InvokeUIScreen(Class'HUDKeypadWindow', True));
        root.MaskBackground(True);

      // copy the tag data to the actual class
      if (keypadwindow != None)
      {
         keypadwindow.keypadOwner = Self;
         keypadwindow.player = Hacker;
         keypadwindow.bInstantSuccess = GetInstantSuccess(Hacker, bHacked);
         keypadwindow.InitData();
      }
#endif
   }
}

function bool GetInstantSuccess(DeusExPlayer Hacker, bool bHacked)
{
   if( bHacked ) return true;
   if( class'MenuChoice_PasswordAutofill'.static.GetSetting() == 2 && bCodeKnown ) return true;
   return false;
}

function RunEvents(DeusExPlayer Player, bool bSuccess)
{
    super.RunEvents(Player,bSuccess);
    if (bSuccess){
        if ( !WasHacked() ) {
            SetCodeKnown();
        }
        if (bUnlock) {
            UnlockDoor();
        }
    }
}

function ToggleLocks(DeusExPlayer Player)
{
    super.ToggleLocks(Player);
    if( !WasHacked() )
        SetCodeKnown();
}

function SetCodeKnown()
{
    local #var(injectsprefix)Keypad other;
    bCodeKnown = true;
    if(!bGrouped) return;
    foreach AllActors(class'#var(injectsprefix)Keypad', other) {
        if(other.Group == Group) {
            other.bCodeKnown = true;
        }
    }
}

function UnlockDoor()
{
    local #var(DeusExPrefix)Mover dxm;

    foreach AllActors(class'#var(DeusExPrefix)Mover', dxm, Event) {
        dxm.bLocked = false;
    }
}

function bool WasHacked()
{
    return bHackable && hackStrength == 0.0;
}

defaultproperties
{
    bCodeKnown=False
    bUnlock=True
}
