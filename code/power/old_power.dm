var/global/DERVENPOWER = 0
var/global/list/smes = list()
var/global/list/apc = list()
var/global/list/cables = list()

/obj/cable
	name = "cable"
	icon = 'icons/obj/cable.dmi'
	var/powernet = 0
	var/reset = 0
	alpha = 128
	typer = 4

/obj/machinery/smes
	name = "smes"
	icon = 'icons/obj/POWER.dmi'
	icon_state = "smes"
	layer = 4
	var/power = 120000
	var/new_power = 0
	//

/obj/machinery
	var/use_power = 0
	var/powernet = 0

/obj/machinery/PIZDA
	name = "power intensity zone device assistant(PIZDA)"
	icon = 'icons/obj/POWER.dmi'
	icon_state = "apc"
	layer = 4
	var/reset = 0

	//
	var/power = 15000
	var/new_power = 0

	proc/power_get(var/val)
		power -= val

	process()
		spawn while(1)
			sleep(1)
			for(var/obj/machinery/M in src.loc.loc)
				if(!istype(M, /obj/machinery/door/airlock) && !istype(M, /obj/machinery/PIZDA) && !istype(M, /obj/machinery/hydroponics))
					M.process(src)


/obj/machinery/PIZDA/act()
	world << "[powernet]; [power]"

/obj/machinery/PIZDA/New()
	apc += src
	var/area/MYAREA = src.loc.loc
	for(MYAREA in areas)
		MYAREA.power_device = src
	process()
	..()

/obj/machinery/smes/process()
	spawn while(1)
		sleep(1)
		for(var/obj/machinery/PIZDA/epta in apc)
			if(epta.powernet == powernet)
				if(power > 0)
					power -= 100
					epta.power += 100

/obj/cable/New()
	cables += src
	process()


/proc/CABLES()
	spawn while(1)
		sleep(2)
		for(var/obj/cable/C in cables)
			C.process()

/obj/cable/proc/PART_PROCESS(var/list/directions)
	for(var/direct in directions)
		var/turf/direction = direct
		for(var/obj/cable/A in direction)
			if(A.powernet != 0)
				powernet = A.powernet

		for(var/obj/machinery/S in direction)
			if(istype(S, /obj/machinery/generator) || istype(S,/obj/machinery/collector))
				S.powernet = powernet

			if(istype(S, /obj/machinery/smes))
				if(S.powernet != 0)
					powernet = S.powernet

			if(istype(S, /obj/machinery/PIZDA))
				if(powernet != 0)
					S.powernet = powernet


/obj/cable/process()
	if(dir == 2 || dir == 1 ||  dir == 6 || dir == 10 || dir == 9 || dir == 5)

		var/list/directions = list(get_step(src,NORTH), get_step(src,SOUTH))
		PART_PROCESS(directions)

	if(dir == 4 || dir == 6 || dir == 10 || dir == 9 || dir == 5)

		var/list/directions = list(get_step(src,EAST), get_step(src,WEST))
		PART_PROCESS(directions)

	//code bamming

		if(reset == 1)
			powernet = 0
			reset = 0

/obj/cable/Del()

	for(var/obj/cable/P in world)
		if(powernet == P.powernet)
			P.reset = 1

	for(var/obj/machinery/PIZDA/A in apc)
		if(powernet == A.powernet)
			A.reset = 1

/obj/cable/act()
	world << "[powernet]"

/obj/machinery/smes/New()
	DERVENPOWER ++
	powernet = DERVENPOWER
	world << powernet
	smes += src
	var/area/MyArea = src.loc.loc
	MyArea.SMES = src
	process()

/obj/machinery/generator
	name = "generator"
	icon = 'icons/obj/POWER.dmi'
	icon_state = "generator"
	layer = 4

/obj/machinery/smes/act()
	usr << "Power equal [power]"

/obj/machinery/generator/act()
	usr << "Wow. Energy"
	for(var/obj/machinery/smes/S in smes)
		if(S)
			if(S.powernet == powernet)
				S.new_power += 1000000
				S.power += S.new_power