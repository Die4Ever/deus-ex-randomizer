from compiler.base import *

disabled = False
whitelist = ['ActorDisplayWindow',
'AllianceTrigger',
'AmmoShuriken',
'ATM',
'AugDrone',
'AugHealing',
'AugSpeed',
'AutoTurret',
'Barrel1',
'ClothesRack',
'Computers',
'ComputerScreenATM',
'ComputerScreenHack',
'ComputerScreenLogin',
'ComputerUIWindow',
'CreditsWindow',
'DartFlare',
'DeusExCarcass',
'DeusExNote',
'DeusExScopeView',
'FireExtinguisher',
'FrobDisplayWindow',
'HUDActiveItemsBorderBase',
'HUDObjectBelt',
'HUDObjectSlot',
'HumanBase',
'InformationDevices',
'JCDentonMaleCarcass',
'Keypad',
'MapExit',
'MenuMain',
'MenuScreenLoadGame',
'MissionEndgame',
'MissionIntro',
'MissionScript',
'NetworkTerminal',
'PaulDentonCarcass',
'ShowerFaucet',
'Shuriken',
'SkillWeaponPistol',
'SpyDrone',
'Toilet',
'Toilet2',
'WeaponFlamethrower',
'WeaponHideAGun',
'WeaponNanoSword',
'WeaponShuriken',
'ComputerUIWindow',
'InformationDevices',
'MenuMain',
'MissionIntro',
'MissionScript',
'ShowerFaucet',
'Toilet',
'Toilet2',
'ActorDisplayWindow',
'AutoTurret',
'Barrel1',
'FrobDisplayWindow',
'MissionEndgame','Human']

def execute_injections(f, prev, idx, inject, classname, classline, content, injects):
    global whitelist
    if disabled and classname not in whitelist:
        print("not injecting "+classname)
        return True, classname, classline, content

    if idx > 0:
        return True, classname, classline, content
    
    comment = "// === was "+classname+" ===\n"
    print(f['qualifiedclass'] + ' has '+ str(len(injects)) +' injections, renaming to '+f['classname']+'Base' )
    oldclassname = classname
    classname = classname+'Base'
    classline = re.sub('class '+oldclassname, comment + 'class '+classname, classline, count=1)
    content = re.sub('([^a-z])(self)([^a-z])', r'\1'+oldclassname+r'(Self)\3', content, flags=re.IGNORECASE)
    return True, classname, classline, content


def handle_inheritance_operator(f, classname, classline, content, injects):
    global whitelist
    if disabled and f['baseclass'] not in whitelist:
        return False, classname, classline, content
    
    qualifiedbase = f['namespace'] +'.'+ f['baseclass']
    
    injectsnum = injects[qualifiedbase].index(f)
    # we want the first one to be named ClassnameBase2 not 0
    injectsnum += 2
    print(f['file']+" injectsnum: "+str(injectsnum))

    comment = "// === was "+f['mod_name']+'/'+classname+" ===\n"

    classname = f['baseclass']
    if injectsnum-1 != len(injects[qualifiedbase]):
        classname = f['baseclass']+'Base' + str(injectsnum)
    
    baseclass = f['baseclass']+'Base'
    if injectsnum != 2:
        baseclass = f['baseclass']+'Base' + str(injectsnum-1)
    
    classline = re.sub('class '+f['classname']+' injects '+f['baseclass'], comment + 'class '+classname+' extends '+baseclass, classline, count=1)
    return True, classname, classline, content
