class DXRandoFixTextures extends Object abstract;

//Fixed UNATCO Helmet (To remove purple line - see issue #1359)
#exec TEXTURE IMPORT NAME=UNATCOHelmetFixed FILE=Textures\UNATCOHelmetFixed.pcx GROUP=DXRandoFixes FLAGS=2

//Adaptive Armor (Thermoptic Camo) charged icon that actually looks like the item
#exec TEXTURE IMPORT FILE="Textures\ChargedIconAdaptiveArmorCorrected.pcx"    NAME="ChargedIconAdaptiveArmorCorrected"    GROUP=DXRandoFixes MIPS=Off
