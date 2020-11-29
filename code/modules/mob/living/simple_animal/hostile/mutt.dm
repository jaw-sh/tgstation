/// KF: A mutt to replace Renault in the Captain's office.
/mob/living/simple_animal/hostile/retaliate/mutt
	name = "\improper mutt"
	gender = MALE // sprite has testicles
	real_name = "mutt"
	desc = "It's a mutt."
	icon = 'icons/mob/pets.dmi'
	icon_state = "slobbermutt"
	icon_living = "slobbermutt"
	icon_dead = "slobbermutt_dead"
	faction = list("neutral")
	status_flags = CANKNOCKDOWN
	attack_same = 1
	stop_automated_movement_when_pulled = 1
	stat_attack = SOFT_CRIT
	robust_searching = 1
	health = 200
	maxHealth = 200
	harm_intent_damage = 15
	obj_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 20
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	a_intent = INTENT_HELP
	butcher_results = list(/obj/item/food/meat/slab/mutt = 4)
	gold_core_spawnable = FRIENDLY_SPAWN
	held_state = "slobbermutt"
	environment_smash = ENVIRONMENT_SMASH_NONE
	move_to_delay = 1
	charger = TRUE

/mob/living/simple_animal/hostile/retaliate/mutt/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PUG, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/retaliate/mutt/FindTarget(list/possible_targets, HasTargetsList = 0)
	// Regular mutts shouldn't be aggressive.
	. = list()

/mob/living/simple_animal/hostile/retaliate/mutt/captains
	name = "Slobbermutt"
	desc = "A vicious-looking dog, fangs bared."

/mob/living/simple_animal/hostile/retaliate/mutt/captains/ListTargets()
	. = ..()
	// Slobbermutt hunts for two targets:
	// 1. Anyone holding the disk (filtered by CanAttack later).
	var/turf/OT = get_turf(src)
	for(var/obj/item/disk/nuclear/N in GLOB.poi_list)
		var/mob/living/carbon/DT = get_turf(N)
		if(OT.z != DT.z || get_dist(OT, DT) > vision_range)
			continue
		var/atom/DL = N.loc
		while(!isturf(DL))
			if(ismob(DL))
				// Return here. The disk holder is more important than anything else.
				return list(DL)
			DL = DL.loc

	// 2. Anyone in the Captain's Quarters.
	var/area/A = get_area(loc)
	if(!istype(A, /area/crew_quarters/heads/captain))
		// But only if he's there too.
		return .
	for(var/mob/living/carbon/C in A)
		. += C

	return .

/mob/living/simple_animal/hostile/retaliate/mutt/captains/FindTarget(list/possible_targets, HasTargetsList = 0)
	. = list()
	if(!HasTargetsList)
		possible_targets = ListTargets()
	for(var/pos_targ in possible_targets)
		var/atom/A = pos_targ
		if(Found(A))
			. = list(A)
			break
		if(CanAttack(A))
			. += A
			continue
	var/Target = PickTarget(.)
	GiveTarget(Target)
	return Target

/mob/living/simple_animal/hostile/retaliate/mutt/captains/CanAttack(atom/the_target)
	. = ..()

	// Nothing that will default AI won't attack is valid to us.
	if(!.)
		return FALSE

	// Protects you from Slobbermutt's keen mind reading senses.
	if(HAS_TRAIT(the_target, TRAIT_MINDSHIELD))
		return FALSE
	// More advanced checks.
	if(!iscarbon(the_target))
		return TRUE

	var/mob/living/carbon/TC = the_target
	var/datum/mind/TM = TC.last_mind
	// Dog will recognize all command staff as friends
	if(TM && (TM.assigned_role in GLOB.command_positions))
		return FALSE

	return TRUE

/mob/living/simple_animal/hostile/retaliate/mutt/captains/Aggro()
	. = ..()
	a_intent = INTENT_HARM

/mob/living/simple_animal/hostile/retaliate/mutt/captains/LoseAggro()
	. = ..()
	a_intent = INTENT_HELP
