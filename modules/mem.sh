#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:MemTotal:GAUGE:$UN:0:U \
		DS:MemFree:GAUGE:$UN:0:U \
		DS:MemBuffers:GAUGE:$UN:0:U \
		DS:MemCached:GAUGE:$UN:0:U \
		DS:SwapTotal:GAUGE:$UN:0:U \
		DS:SwapFree:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	COMMAND="cat /proc/meminfo | awk '
		/^MemTotal:/ { mt = \$2 }
		/^MemFree:/ { mf = \$2 }
		/^Buffers:/ { buf = \$2 }
		/^Cached:/ { cach = \$2 }
		/^SwapTotal:/ { swt = \$2 }
		/^SwapFree:/ { swf = \$2 }
		END { printf \"%i:%i:%i:%i:%i:%i\", mt, mf, buf, cach, swt, swf}'"
	run_on_server $COMMAND
}

function plot() {
	plot_rrd \
		--title "Memory usage" \
		COMMENT:"Memory usage in last 24 hour\\c" \
		COMMENT:"   \n" \
		--vertical-label='bytes' \
		--base 1024 \
		DEF:MemBuffers=$RRD:MemBuffers:AVERAGE \
		DEF:MemCached=$RRD:MemCached:AVERAGE \
		DEF:MemFree=$RRD:MemFree:AVERAGE \
		DEF:MemTotal=$RRD:MemTotal:AVERAGE \
		CDEF:Buffers=MemBuffers,1024,* \
		CDEF:Cached=MemCached,1024,* \
		CDEF:Free=MemFree,1024,* \
		CDEF:Total=MemTotal,1024,* \
		CDEF:Used=1024,MemTotal,MemBuffers,MemCached,MemFree,+,+,-,* \
		AREA:Used$C_USED:"MemUsed" \
		GPRINT:Used:LAST:"    Current\:%8.2lf %s" \
		GPRINT:Used:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Used:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Used:MAX:"Maximum\:%8.2lf %s\n"  \
		AREA:Buffers$C_RED:"MemBuffers":STACK \
		GPRINT:Buffers:LAST:" Current\:%8.2lf %s" \
		GPRINT:Buffers:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Buffers:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Buffers:MAX:"Maximum\:%8.2lf %s\n"  \
		AREA:Cached$C_YELLOW:"MemCached":STACK \
		GPRINT:Cached:LAST:"  Current\:%8.2lf %s" \
		GPRINT:Cached:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Cached:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Cached:MAX:"Maximum\:%8.2lf %s\n"  \
		AREA:Free$C_FREE:"MemFree":STACK \
		GPRINT:Free:LAST:"    Current\:%8.2lf %s" \
		GPRINT:Free:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Free:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Free:MAX:"Maximum\:%8.2lf %s\n"
}
