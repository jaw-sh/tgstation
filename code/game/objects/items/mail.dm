// Mail time!
// https://www.youtube.com/watch?v=-KRtN6-DgrY

/// Mail is tamper-evident and unresealable, postmarked by CentCom for an individual recepient.
/obj/item/mail
	name = "mail"
	gender = NEUTER
	desc = "An officially postmarked, tamper-evident parcel regulated by CentCom and made of high-quality materials."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_small"
	inhand_icon_state = "paper"
	worn_icon_state = "paper"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	/// Destination tagging for the mail sorter
	var/sortTag = 0
	/// Who this mail is for and who can open it
	/// Note: this variable may be blanked once set by QDEL.
	var/mob/recipient
	/// How many goodies this mail contains
	var/goodie_count = 1
	/// Goodies which can be given to anyone.
	/// The base weight for cash is 56. for there to be a 50/50 chance of getting a department item, they need 56 weight as well.
	var/list/generic_goodies = list(
		/obj/item/stack/spacecash/c100 = 30,
		/obj/item/stack/spacecash/c200 = 20,
		/obj/item/stack/spacecash/c500 = 10,
		/obj/item/stack/spacecash/c1000 = 5,
		/obj/item/stack/spacecash/c10000 = 1
	)

	// Overlays (pure fluff)
	/// Adds the Nanotrasen postmark overlay.
	var/postmarked = TRUE
	/// Adds stamps based on stamps_max.
	var/stamped = TRUE
	/// List of specific stamp overlay icon_state names.
	var/list/stamps = list()
	/// How many stamps we can have one.
	var/stamp_max = 1
	/// Horizontal offset for stamps.
	var/stamp_offset_x = 0
	/// Vertical offset for stamps.
	var/stamp_offset_y = 2

/obj/item/mail/envelope
	name = "envelope"
	icon_state = "mail_large"
	goodie_count = 2
	stamp_max = 2
	stamp_offset_y = 5

/obj/item/mail/Initialize()
	. = ..()
	// Icons
	// Add some random stamps.
	if(stamped)
		for(var/i in 1 to rand(1, stamp_max))
			var/x = rand(2, 6)
			stamps += list("stamp_[x]")
	update_icon()

/obj/item/mail/update_overlays()
	. = ..()

	var/bonus_stamp_offset = 0
	for(var/stamp in stamps)
		var/image/stamp_image = image(
			icon = icon,
			icon_state = stamp,
			pixel_x = stamp_offset_x,
			pixel_y = stamp_offset_y + bonus_stamp_offset
		)
		// Stops postmarks from inheriting letter color.
		// http://www.byond.com/docs/ref/#/atom/var/appearance_flags
		stamp_image.appearance_flags |= RESET_COLOR
		. += stamp_image
		bonus_stamp_offset -= 5

	if(postmarked == TRUE)
		var/image/postmark_image = image(
			icon = icon,
			icon_state = "postmark",
			pixel_x = stamp_offset_x + rand(-3, 1),
			pixel_y = stamp_offset_y + rand(bonus_stamp_offset + 3, 1)
		)
		postmark_image.appearance_flags |= RESET_COLOR
		. += postmark_image

/obj/item/mail/attackby(obj/item/W, mob/user, params)
	// Destination tagging
	if(!istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, TRUE)

/obj/item/mail/attack_self(mob/user)
	if(recipient && user != recipient)
		to_chat(user, "<span class='notice'>You can't open somebody else's mail! That's <em>illegal</em>!</span>")
		return

	to_chat(user, "<span class='notice'>You start to unwrap the package...</span>")
	if(!do_after(user, 15, target = user))
		return
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	unwrap_contents()
	for(var/content in contents)
		user.put_in_hands(content)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	qdel(src)

/obj/item/mail/proc/unwrap_contents()
	for(var/i in GetAllContents())
		var/atom/unwrapped_atom = i
		SEND_SIGNAL(unwrapped_atom, COMSIG_STRUCTURE_UNWRAPPED)

/// Accepts a mob to initialize goodies for a piece of mail.
/obj/item/mail/proc/initialize_for_recipient(mob/new_recipient)
	recipient = new_recipient
	name = "[initial(name)] for [recipient.real_name] ([recipient.job])"
	var/list/goodies = list()
	goodies += generic_goodies

	var/datum/job/this_job = SSjob.name_occupations[recipient.job]
	if(this_job)
		if(this_job.paycheck_department && GLOB.department_colors[this_job.paycheck_department])
			color = GLOB.department_colors[this_job.paycheck_department]
		var/list/job_goodies = this_job.get_mail_goodies()
		if(job_goodies.len)
			// certain roles and jobs (prisoner) do not receive generic gifts.
			if(this_job.exclusive_mail_goodies)
				goodies = job_goodies
			else
				goodies += job_goodies

	for(var/i in 1 to goodie_count)
		var/picked_goodie_type = pickweight(goodies)
		if(ispath(picked_goodie_type, /datum/reagent))
			var/obj/item/reagent_containers/reagent_container = new /obj/item/reagent_containers/glass/bottle(src)
			reagent_container.reagents.add_reagent(picked_goodie_type, reagent_container.volume)
			reagent_container.name = "[reagent_container.reagents.reagent_list[1].name] bottle"
			new_recipient.log_message("[key_name(new_recipient)] received reagent container [reagent_container] in the mail ([picked_goodie_type])", LOG_GAME)
		else
		//if(ispath(T, /obj))
			var/atom/movable/content = new picked_goodie_type(src)
			new_recipient.log_message("[key_name(new_recipient)] received [content] in the mail ([content.type])", LOG_GAME)
			//CRASH("[key_name(new_recipient)] received an unexpected type in the mail ([T])")

	return TRUE

/// Crate for mail from CentCom.
/obj/structure/closet/crate/mail
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon_state = "mail"

/// Crate for mail that automatically generates a lot of mail.
/obj/structure/closet/crate/mail/full
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon_state = "mail"

/obj/structure/closet/crate/mail/update_icon_state()
	if(opened)
		icon_state = "[initial(icon_state)]open"
		return
	for(var/obj/item/mail/M in src)
		// if we have any mail, prefer the icon state with visible mail.
		icon_state = initial(icon_state)
		return
	icon_state = "[initial(icon_state)]sealed"

/obj/structure/closet/crate/mail/full/Initialize()
	. = ..()
	// Generate some mail.
	var/mail_recipients = list()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client || H.stat == DEAD)
			continue
		mail_recipients += list(H)

	for(var/i in 1 to 21)
		var/obj/item/mail/NM
		if(rand(0, 10) < 7)
			NM = new /obj/item/mail(src)
		else
			NM = new /obj/item/mail/envelope(src)
		NM.initialize_for_recipient(pick(mail_recipients))

/// KF: Mailbag.
/obj/item/storage/bag/mail
	name = "mail bag"
	desc = "A bag for letters, envelopes, and other postage."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	worn_icon_state = "bookbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/mail/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 42
	STR.max_items = 21
	STR.display_numerical_stacking = FALSE
	STR.set_holdable(list(
		/obj/item/mail
	))
