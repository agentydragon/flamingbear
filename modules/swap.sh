#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:SwapTotal:GAUGE:$UN:0:U \
		DS:SwapFree:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	run_on_server "cat /proc/meminfo | awk '
		/^SwapTotal:/ { swt = \$2 }
		/^SwapFree:/ { swf = \$2 }
		END { printf \"%i:%i\", swt, swf}'"
}

function plot() {
	plot_rrd \
		--title "Swap usage ($MACHINE)" \
		COMMENT:"Swap usage in last 24 hour\\c" \
		COMMENT:" \n" \
		--vertical-label='bytes' \
		--base 1024 \
		DEF:SwapFree=$RRD:SwapFree:AVERAGE \
		DEF:SwapTotal=$RRD:SwapTotal:AVERAGE \
		CDEF:Free=SwapFree,1024,* \
		CDEF:Used=1024,SwapTotal,SwapFree,-,* \
		AREA:Used$C_USED:"SwapUsed":STACK \
		GPRINT:Used:LAST:"   Current\:%8.2lf %s" \
		GPRINT:Used:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Used:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Used:MAX:"Maximum\:%8.2lf %s\n"  \
		AREA:Free$C_FREE:"SwapFree":STACK \
		GPRINT:Free:LAST:"   Current\:%8.2lf %s" \
		GPRINT:Free:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Free:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Free:MAX:"Maximum\:%8.2lf %s\n"
}
