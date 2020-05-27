#!/usr/bin/gawk --exec

BEGIN {
	dicemultiply=12
	maxrounds=10000

	OFS="\t"
	"bash -c 'echo -n \"$RANDOM\"'" | getline seed
	close("bash -c 'echo -n \"$RANDOM\"'")
	srand(seed)

	dicenr=dicemultiply*6

	for (d=6; d <= dicenr; d=d+6) {
		dicestat[d]["under"] = 0
		dicestat[d]["exact"] = 0
		dicestat[d]["atleast"] = 0
	}
	
	for (round=0; round < maxrounds; round++) {

		for (d=6; d <= dicenr; d=d+6) {
	
			for (i=0; i<=d; i++) if (substr(rand() * 6 + 1,1,1) == 6) sixcount++
			if (sixcount == 0) dicestat[d]["under"]++
			else if (sixcount == 1) {dicestat[d]["exact"]++; dicestat[d]["atleast"]++}
			else dicestat[d]["atleast"]++
			sixcount = 0
		}

	}
	
	print "Rounds: " round
	print "#dices","under","exact","at least"

	for (d=6; d <= dicenr; d=d+6) {
		print d,dicestat[d]["under"],dicestat[d]["exact"],dicestat[d]["atleast"]
	}
}
