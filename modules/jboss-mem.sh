#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:MemTotal:GAUGE:$UN:0:U \
		DS:MemFree:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	DATA=$(snmpwalk -v 1 -c public $HOSTNAME:1161 .1.2.3.4.1 | awk '
		/^iso.2.3.4.1.2/ { memf = $4 }
		/^iso.2.3.4.1.3/ { memt = $4 }
		END { printf "%i:%i", memt, memf}')
}

function plot() {
	plot_rrd \
		--title "JBoss memory usage ($MACHINE)" \
		COMMENT:"JBoss memory usage in last 24 hour\\c" \
		COMMENT:" \n" \
		--vertical-label='bytes' \
		--base 1024 \
		DEF:Free=$RRD:MemFree:AVERAGE \
		DEF:MemTotal=$RRD:MemTotal:AVERAGE \
		CDEF:Used=MemTotal,Free,- \
		AREA:Used$C_USED:"MemUsed":STACK \
		GPRINT:Used:LAST:"   Current\:%8.2lf %s" \
		GPRINT:Used:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Used:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Used:MAX:"Maximum\:%8.2lf %s\n"  \
		AREA:Free$C_FREE:"MemFree":STACK \
		GPRINT:Free:LAST:"   Current\:%8.2lf %s" \
		GPRINT:Free:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Free:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Free:MAX:"Maximum\:%8.2lf %s\n"
}
