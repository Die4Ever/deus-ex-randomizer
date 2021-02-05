# Can't use real Crowd Control?  Get a taste of the experience with this!

import socket
import time
import random


def genMsg(code,param):
    msg = '{"id":1,"viewer":"Python","code":"'+code+'","type":1'
    if param:
        msg+=',"parameters":['+param+']'
    msg+='}\0'

    return msg

def randomAug():
    augs = []
    augs.append('"aqualung"')
    augs.append('"ballistic"')
    augs.append('"cloak"')
    augs.append('"combat"')
    augs.append('"defense"')
    augs.append('"drone"')
    augs.append('"emp"')
    augs.append('"enviro"')
    augs.append('"healing"')
    augs.append('"heartlung"')
    augs.append('"muscle"')
    augs.append('"power"')
    augs.append('"radartrans"')
    augs.append('"shield"')
    augs.append('"speed"')
    augs.append('"stealth"')
    augs.append('"target"')
    augs.append('"vision"')

    return random.choice(augs)

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


    effects.append(("give_health",str(random.randint(10,100))))
    effects.append(("give_health",str(random.randint(10,100))))
    effects.append(("give_health",str(random.randint(10,100))))
    effects.append(("give_health",str(random.randint(10,100))))
    effects.append(("give_health",str(random.randint(10,100))))

    effects.append(("set_fire",None))
    
    effects.append(("drop_grenade",'"g_lam"'))
    effects.append(("drop_grenade",'"g_emp"'))
    effects.append(("drop_grenade",'"g_gas"'))
    effects.append(("drop_grenade",'"g_scrambler"'))
    effects.append(("drop_grenade",'"g_lam"'))
    effects.append(("drop_grenade",'"g_emp"'))
    effects.append(("drop_grenade",'"g_gas"'))
    effects.append(("drop_grenade",'"g_scrambler"'))

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

    effects.append(("give_energy",str(random.randint(10,100))))
    effects.append(("give_energy",str(random.randint(10,100))))
    effects.append(("give_energy",str(random.randint(10,100))))
    effects.append(("give_energy",str(random.randint(10,100))))
    effects.append(("give_energy",str(random.randint(10,100))))

    effects.append(("give_biocell",None))
    effects.append(("give_biocell",None))
    effects.append(("give_biocell",None))
    
    effects.append(("give_skillpoints",str(random.randint(100,1000))))
    effects.append(("give_skillpoints",str(random.randint(100,1000))))
    effects.append(("give_skillpoints",str(random.randint(100,1000))))

    effects.append(("remove_skillpoints",str(random.randint(100,1000))))
    effects.append(("remove_skillpoints",str(random.randint(100,1000))))

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

    effects.append(("add_credits",str(random.randint(100,1000))))
    effects.append(("add_credits",str(random.randint(100,1000))))

    effects.append(("remove_credits",str(random.randint(100,1000))))
    effects.append(("remove_credits",str(random.randint(100,1000))))

    effects.append(("lamthrower",None))
    effects.append(("lamthrower",None))

    effects.append(("give_ps40",None))
    effects.append(("give_ps40",None))
    effects.append(("give_ps40",None))

    effects.append(("up_aug",randomAug()))
    effects.append(("up_aug",randomAug()))
    effects.append(("down_aug",randomAug()))
    effects.append(("down_aug",randomAug()))



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
