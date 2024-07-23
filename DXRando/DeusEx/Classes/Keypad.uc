class DXRKeypad injects Keypad;

var () bool bCodeKnown;
var() bool bUnlock;

simulated function ActivateKeypadWindow(DeusExPlayer Hacker, bool bHacked)
{
   local DeusExRootWindow root;

   root = DeusExRootWindow(Hacker.rootWindow);
   if (root != None)
   {
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
   }
}

function bool GetInstantSuccess(DeusExPlayer Hacker, bool bHacked)
{
   if( bHacked ) return true;
   if( class'MenuChoice_PasswordAutofill'.default.value == 2 && bCodeKnown ) return true;
   return false;
}

function RunEvents(DeusExPlayer Player, bool bSuccess)
{
    super.RunEvents(Player,bSuccess);
    if (bSuccess){
        if ( !WasHacked() ) {
            bCodeKnown = True;
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
        bCodeKnown = True;
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
    bToggleLock=False
    bUnlock=True
}
