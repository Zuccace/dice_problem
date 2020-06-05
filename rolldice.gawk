#!/usr/bin/gawk --exec

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

	OFS="\t"
	"bash -c 'echo -n \"$RANDOM\"'" | getline seed
	close("bash -c 'echo -n \"$RANDOM\"'")
	srand(seed)

	dicenr=dicemultipler*dicesize

	for (d=dicesize; d <= dicenr; d=d+dicesize) {
		dicestat[d]["under"] = 0
		dicestat[d]["exact"] = 0
		dicestat[d]["atleast"] = 0
		dicestat[d]["over"] = 0
	}

	# Dice rolling loop
	for (round=0; round < totrounds; round++) {

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
		printf "\033cRounds: %s",round
	}

	
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
