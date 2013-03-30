#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:Load1:GAUGE:$UN:0:U \
		DS:Load5:GAUGE:$UN:0:U \
		DS:Load15:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	run_on_server "cat /proc/loadavg | cut -d' ' -f 1-3 | tr '\ ' ':'"
}

function plot() {
	plot_rrd \
		--title "Load Average ($MACHINE)" \
		COMMENT:"Load average in last 24 hour\\c" \
		COMMENT:"   \n" \
		--vertical-label='number of processes in the run queue' \
		--units-exponent='0' \
		DEF:Load1=$RRD:Load1:AVERAGE \
		DEF:Load5=$RRD:Load5:AVERAGE \
		DEF:Load15=$RRD:Load15:AVERAGE \
		AREA:Load1$C_YELLOW:" 1 Minute" \
		GPRINT:Load1:LAST:"  Current\:%8.2lf" \
		GPRINT:Load1:MIN:"  Minimum\:%8.2lf"  \
		GPRINT:Load1:AVERAGE:"  Average\:%8.2lf"  \
		GPRINT:Load1:MAX:"  Maximum\:%8.2lf\n"  \
		AREA:Load5$C_ORANGE:" 5 Minute":STACK \
		GPRINT:Load5:LAST:"  Current\:%8.2lf" \
		GPRINT:Load5:MIN:"  Minimum\:%8.2lf"  \
		GPRINT:Load5:AVERAGE:"  Average\:%8.2lf"  \
		GPRINT:Load5:MAX:"  Maximum\:%8.2lf\n"  \
		AREA:Load15$C_RED:"15 Minute":STACK \
		GPRINT:Load15:LAST:"  Current\:%8.2lf" \
		GPRINT:Load15:MIN:"  Minimum\:%8.2lf"  \
		GPRINT:Load15:AVERAGE:"  Average\:%8.2lf"  \
		GPRINT:Load15:MAX:"  Maximum\:%8.2lf\n"
}
