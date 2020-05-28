#!/usr/bin/gawk --exec

BEGIN {

	maxdicesize = 1000
	maxdicemultipler = 50
	maxrounds = 1000000
	
	if (ARGV[1] != "" && ARGV[1] ~ /^[0-9]+$/ && ARGV[1] < maxdicesize) dicesize = ARGV[1]
	else dicesize = 6
	
	if (ARGV[2] != "" && ARGV[2] ~ /^[0-9]+$/ && ARGV[2] < maxdicemultipler) dicemultipler = ARGV[2]
	else dicemultipler = 6
	
	if (ARGV[3] != "" && ARGV[3] ~ /^[0-9]+$/ && ARGV[3] < maxrounds) totrounds = ARGV[3]
	else totrounds = 10000

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
	print "#dices","under","exact","at least","over"

	for (d=dicesize; d <= dicenr; d=d+dicesize) {
		print d,dicestat[d]["under"],dicestat[d]["exact"],dicestat[d]["atleast"],"\t" dicestat[d]["over"]
	}
}
