/datum/job/qm
	title = "Quartermaster"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#d7b088"
	exp_type_department = EXP_TYPE_SUPPLY // This is so the jobs menu can work properly

	outfit = /datum/outfit/job/quartermaster

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT, ACCESS_AUX_BASE)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT, ACCESS_AUX_BASE)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER
	bounty_types = CIV_JOB_RANDOM

	mail_goodies = list(
		/obj/item/circuitboard/machine/emitter = 3
	)

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/qm

	belt = /obj/item/pda/quartermaster
	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo/qm
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	l_hand = /obj/item/clipboard

	chameleon_extras = /obj/item/stamp/qm


// KF: Mail goodies.
/datum/job/quartermaster/get_mail_goodies(mob/recipient)
	. = ..()
	// Strange Reagent if the pet is dead.
	for(var/mob/living/simple_animal/sloth/citrus/staff_pet in GLOB.dead_mob_list)
		. += list(/datum/reagent/medicine/strange_reagent = 20)
		break

