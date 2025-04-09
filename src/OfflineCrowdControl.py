# Can't use real Crowd Control?  Get a taste of the experience with this!

import socket
import time
import random


def genMsg(code,param):
    msg = '{"id":1,"viewer":"Python","code":"'+code+'","type":1'
    if param:
        msg+=',"parameters":['
        paramstr = ""
        for p in param:
            print(p)
            if isinstance(p,int):
                paramstr+=str(p)
            elif isinstance(p,str):
                paramstr+='"'+p+'"'
            paramstr+=","
        paramstr = paramstr[:-1]
        print(paramstr)
        msg+=paramstr
        msg+=']'
    msg+='}\0'

    return msg

def randomAug():
    augs = []
    augs.append('augaqualung')
    augs.append('augballistic')
    augs.append('augcloak')
    augs.append('augcombat')
    augs.append('augdefense')
    augs.append('augdrone')
    augs.append('augemp')
    augs.append('augenviro')
    augs.append('aughealing')
    augs.append('augheartlung')
    augs.append('augmuscle')
    augs.append('augpower')
    augs.append('augradartrans')
    augs.append('augshield')
    augs.append('augspeed')
    augs.append('augstealth')
    augs.append('augtarget')
    augs.append('augvision')

    return random.choice(augs).lower()

def randomAmmo():
    ammo = []
    ammo.append('Ammo10mm')
    ammo.append('Ammo20mm')
    ammo.append('Ammo762mm')
    ammo.append('Ammo3006')
    ammo.append('AmmoBattery')
    ammo.append('AmmoDart')
    ammo.append('AmmoDartFlare')
    ammo.append('AmmoDartPoison')
    ammo.append('AmmoNapalm')
    ammo.append('AmmoPepper')
    ammo.append('AmmoPlasma')
    ammo.append('AmmoRocket')
    ammo.append('AmmoRocketWP')
    ammo.append('AmmoSabot')
    ammo.append('AmmoShell')

    return random.choice(ammo).lower()

def pickEffect():
    effects = []

    effects.append(None)
    effects.append(None)
    effects.append(None)

    #This might be too mean for a machine
    #effects.append(("kill",None))
    
    effects.append(("poison",None))
    effects.append(("poison",None))

    effects.append(("glass_legs",None))
    effects.append(("glass_legs",None))
    effects.append(("glass_legs",None))


    effects.append(("give_health",[str(random.randint(10,100))]))
    effects.append(("give_health",[str(random.randint(10,100))]))
    effects.append(("give_health",[str(random.randint(10,100))]))
    effects.append(("give_health",[str(random.randint(10,100))]))
    effects.append(("give_health",[str(random.randint(10,100))]))

    effects.append(("set_fire",None))
    
    effects.append(("drop_lam", None))
    effects.append(("drop_empgrenade", None))
    effects.append(("drop_gasgrenade", None))
    effects.append(("drop_nanovirusgrenade", None))
    effects.append(("drop_lam", None))
    effects.append(("drop_empgrenade", None))
    effects.append(("drop_gasgrenade", None))
    effects.append(("drop_nanovirusgrenade", None))

    effects.append(("give_medkit",None))
    effects.append(("give_medkit",None))
    effects.append(("give_medkit",None))

    effects.append(("full_heal",None))
    effects.append(("full_heal",None))

    effects.append(("drunk_mode",None))
    effects.append(("drunk_mode",None))

    effects.append(("drop_selected_item",None))
    effects.append(("drop_selected_item",None))
    effects.append(("drop_selected_item",None))
    effects.append(("drop_selected_item",None))
    effects.append(("drop_selected_item",None))

    effects.append(("matrix",None))
    effects.append(("emp_field",None))

    effects.append(("give_energy",[str(random.randint(10,100))]))
    effects.append(("give_energy",[str(random.randint(10,100))]))
    effects.append(("give_energy",[str(random.randint(10,100))]))
    effects.append(("give_energy",[str(random.randint(10,100))]))
    effects.append(("give_energy",[str(random.randint(10,100))]))

    effects.append(("give_bioelectriccell",None))
    effects.append(("give_bioelectriccell",None))
    effects.append(("give_bioelectriccell",None))
    
    effects.append(("give_skillpoints",[str(random.randint(1,10))]))
    effects.append(("give_skillpoints",[str(random.randint(1,10))]))
    effects.append(("give_skillpoints",[str(random.randint(1,10))]))

    effects.append(("remove_skillpoints",[str(random.randint(1,10))]))
    effects.append(("remove_skillpoints",[str(random.randint(1,10))]))

    effects.append(("disable_jump",None))
    effects.append(("disable_jump",None))

    effects.append(("gotta_go_fast",None))
    effects.append(("gotta_go_fast",None))
    effects.append(("gotta_go_fast",None))
    effects.append(("gotta_go_fast",None))

    effects.append(("gotta_go_slow",None))
    effects.append(("gotta_go_slow",None))

    effects.append(("ice_physics",None))
    effects.append(("ice_physics",None))
    effects.append(("ice_physics",None))
    effects.append(("ice_physics",None))
    effects.append(("ice_physics",None))

    effects.append(("third_person",None))
    effects.append(("third_person",None))

    effects.append(("dmg_double",None))
    effects.append(("dmg_double",None))
    effects.append(("dmg_double",None))

    effects.append(("dmg_half",None))
    effects.append(("dmg_half",None))
    effects.append(("dmg_half",None))

    effects.append(("add_credits",[str(random.randint(1,10))]))
    effects.append(("add_credits",[str(random.randint(1,10))]))

    effects.append(("remove_credits",[str(random.randint(1,10))]))
    effects.append(("remove_credits",[str(random.randint(1,10))]))

    effects.append(("lamthrower",None))
    effects.append(("lamthrower",None))

    effects.append(("give_weaponhideagun",None))
    effects.append(("give_weaponhideagun",None))
    effects.append(("give_weaponhideagun",None))

    effects.append(("add_" + randomAug(), None ))
    effects.append(("add_" + randomAug(), None ))
    effects.append(("rem_" + randomAug(), None ))
    effects.append(("rem_" + randomAug(), None ))

    effects.append(("ask_a_question",None))
    effects.append(("ask_a_question",None))
    effects.append(("ask_a_question",None))
    effects.append(("ask_a_question",None))

    effects.append(("nudge",None))
    effects.append(("nudge",None))
    effects.append(("nudge",None))
    effects.append(("nudge",None))

    effects.append(("swap_player_position",None))
    effects.append(("swap_player_position",None))

    effects.append(("floaty_physics",None))
    
    effects.append(("floor_is_lava",None))

    effects.append(("give_"+randomAmmo(),[random.randint(1,2)]))

    effects.append(("invert_mouse",None))
    
    effects.append(("invert_movement",None))


    return random.choice(effects)


s=socket.create_server(("localhost",43384))

while True:
    print("Connecting...")
    conn,addr = s.accept()

    with conn:
        print("Connected to ",addr)
        while True:
            #conn.send(x)
            effect = pickEffect()
            if effect!=None:
                msg = genMsg(effect[0],effect[1])
                print("Sending "+msg)
                try:
                    conn.send(msg.encode('utf-8'))
                except:
                    break
                print("Sent")
            time.sleep(random.randint(5,30))
