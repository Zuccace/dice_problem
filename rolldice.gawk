#!/usr/bin/gawk --exec

function init_seed() {
	"bash -c 'echo -n \"$RANDOM\"'" | getline seed[1]
	close("bash -c 'echo -n \"$RANDOM\"'")
	srand(seed[1])
}

function renew_seed() {
	seed[1] = sin(seed[1])*1000000 # TODO: ? Might need better tuning... 
	srand(seed[1])
}

function roll_set(dicesize) {
	for (d=dicesize; d <= dicenr; d=d+dicesize) {

		for (i=0; i<=d; i++) {
			# Throw a single dice
			diceface = rand() * dicesize + 1
			# Add to hitcount if we rolled the highest value possible.
			# Also use substr() and match() to drop decimals.
			if (substr(diceface,1,match(diceface,/\./)-1) == dicesize) hitcount++
		}
		if (hitcount == 0) dicestat[d]["under"]++
		else if (hitcount == 1) {dicestat[d]["exact"]++; dicestat[d]["atleast"]++}
		else {dicestat[d]["atleast"]++; dicestat[d]["over"]++}
		hitcount = 0
	}
}

function roll_round(totrounds,dicesize) {
	for (round=0; round < totrounds; round++) {
		roll_set(dicesize)
		printf "\033cRounds: %s",round
	}
}

function roll_newseed_round(totrounds,dicesize) {
	for (round=0; round < totrounds; round++) {
		roll_set(dicesize)
		printf "\033cRounds: %s",round
		renew_seed()
	}

}

BEGIN {

	maxdicesize = 20000
	maxdicemultipler = 100
	maxrounds = 1000000
	
	if (ARGV[1] != "" && ARGV[1] ~ /^[0-9]+$/ && ARGV[1] <= maxdicesize) dicesize = ARGV[1]
	else dicesize = 6
	
	if (ARGV[2] != "" && ARGV[2] ~ /^[0-9]+$/ && ARGV[2] <= maxdicemultipler) dicemultipler = ARGV[2]
	else dicemultipler = 5
	
	if (ARGV[3] != "" && ARGV[3] ~ /^[0-9]+$/ && ARGV[3] <= maxrounds) totrounds = ARGV[3]
	else totrounds = 25000

	if (ARGV[4] == "1") roll = "roll_newseed_round"
	else roll = "roll_round"

	OFS="\t"

	dicenr=dicemultipler*dicesize

	for (d=dicesize; d <= dicenr; d=d+dicesize) {
		dicestat[d]["under"] = 0
		dicestat[d]["exact"] = 0
		dicestat[d]["atleast"] = 0
		dicestat[d]["over"] = 0
	}

	init_seed()
	# Dice rolling loop
	@roll(totrounds,dicesize)
	
	printf "\033cRounds: %s\n",round
	print "Dice: d" dicesize

	printf "#dices\t"
	for (stat in dicestat[dicesize]) printf "%s\t\t\t", stat
	print ""

	pformat = "%s - %.1f%%\t\t"

	for (d=dicesize; d <= dicenr; d=d+dicesize) {
		printf "\n%s\t",d
		for (stat in dicestat[d]) {
			statvalue = dicestat[d][stat]
			printf pformat, statvalue, statvalue / round * 100
		}
	}
	print ""
}
