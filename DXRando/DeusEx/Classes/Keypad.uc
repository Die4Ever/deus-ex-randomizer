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
         keypadwindow.bInstantSuccess = GetInstantSuccess(Hacker, bHacked);
         keypadwindow.InitData();
      }
   }
}

function bool GetInstantSuccess(DeusExPlayer Hacker, bool bHacked)
{
   local int codes_mode;
   if( bHacked ) return true;
   codes_mode = Hacker.FlagBase.GetInt('Rando_codes_mode');
   if( codes_mode == 2 && bCodeKnown ) return true;
   return false;
}

defaultproperties
{
    bCodeKnown=False
}
