class DXRKeypad injects Keypad;

var () bool bCodeKnown;

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
         keypadwindow.bInstantSuccess = bHacked || bCodeKnown;
         keypadwindow.InitData();
      }
   }
}

defaultproperties
{
    bCodeKnown=False
}
