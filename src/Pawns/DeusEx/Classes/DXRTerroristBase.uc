class DXRTerroristBase extends #var(prefix)Terrorist;

function bool Facelift(bool bOn)
{
    return false;
}

function VMDRandomizeAppearance(){} //Dummy function to prevent VMD from randomizing the appearance of these guys

#ifdef gmdxae
//GMDX:AE functions to do HDTP and Augmentique skin randomization
exec function UpdateHDTPsettings(){}
function SetupSkin(){}
#endif
