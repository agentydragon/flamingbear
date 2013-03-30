#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:Users:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP

}

# Update RRD file
function update() {
	run_on_server "who | wc -l"
}

function plot() {
	plot_rrd \
		--title "Logged in Users ($MACHINE)" \
		COMMENT:"Number of logged in users in last 24 hour\\c" \
		COMMENT:" \n" \
		--vertical-label='logged in users' \
		DEF:Users=$RRD:Users:AVERAGE \
		AREA:Users$C_AZURE:"Users":STACK \
		GPRINT:Users:LAST:"   Current\:%8.0lf %s" \
		GPRINT:Users:MIN:"Minimum\:%8.0lf %s"  \
		GPRINT:Users:AVERAGE:"Average\:%8.0lf %s"  \
		GPRINT:Users:MAX:"Maximum\:%8.0lf %s\n"
}
