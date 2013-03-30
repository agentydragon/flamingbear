#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:TotalThreads:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	DATA=$(snmpwalk -v 1 -c public $HOSTNAME:1161 .1.2.3.4.1.1 | cut -d\  -f 4)
}

function plot() {
	plot_rrd \
		--title "JBoss threads ($MACHINE)" \
		COMMENT:"JBoss threads in last 24 hours\\c" \
		COMMENT:" \n" \
		--vertical-label='number of threads' \
		--units-exponent='0' \
		DEF:TotalThreads=$RRD:TotalThreads:AVERAGE \
		AREA:TotalThreads$C_AZURE:"Threads" \
		GPRINT:TotalThreads:LAST:"   Current\:%8.2lf" \
		GPRINT:TotalThreads:MIN:"Minimum\:%8.2lf"  \
		GPRINT:TotalThreads:AVERAGE:"Average\:%8.2lf"  \
		GPRINT:TotalThreads:MAX:"Maximum\:%8.2lf\n"
}
