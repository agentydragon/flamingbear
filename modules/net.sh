#!/bin/sh

IF="eth0"
if [ -n "$MODULE_ARGS" ]; then
	IF="$MODULE_ARGS"
fi

# Create new RRD file
function create() {
	create_rrd DS:TotalIn:COUNTER:$UN:0:U \
		DS:TotalOut:COUNTER:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	run_on_server "cat /proc/net/dev | awk '/^ *'$IF':/ { printf \"%i:%i\", \$2, \$10 }'"
}

function plot() {
	plot_rrd \
		--title "Traffic - $IF" \
		COMMENT:"Traffic on $IF in last 24 hour\\c" \
		COMMENT:" \n" \
		--vertical-label='bytes/s' \
		--base 1000 \
		DEF:TotalIn=$RRD:TotalIn:AVERAGE \
		DEF:TotalOut=$RRD:TotalOut:AVERAGE \
		LINE:TotalIn$C_GREEN:"TotalIn" \
		GPRINT:TotalIn:LAST:"   Current\:%8.2lf %s" \
		GPRINT:TotalIn:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:TotalIn:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:TotalIn:MAX:"Maximum\:%8.2lf %s\n"  \
		LINE:TotalOut$C_BLUE:"TotalOut" \
		GPRINT:TotalOut:LAST:"  Current\:%8.2lf %s" \
		GPRINT:TotalOut:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:TotalOut:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:TotalOut:MAX:"Maximum\:%8.2lf %s\n"
}
