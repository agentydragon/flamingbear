#!/bin/sh

# Create new RRD file
function create() {
	create_rrd \
		DS:BusyWorkers:GAUGE:$UN:0:U \
		DS:IdleWorkers:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	DATA=$(wget -q -O - http://$HOSTNAME/server-status?auto | awk '
		/^BusyWorkers:/ { bw = $2 }
		/^IdleWorkers:/ { iw = $2 }
		END { printf "%i:%i", bw, iw }')
}

function plot() {
	plot_rrd \
		--title "Apache workers ($MACHINE)" \
		COMMENT:"Number of apache workers in last 24 hour\\c" \
		COMMENT:" \n" \
		--vertical-label='workers' \
		--units-exponent='0' \
		DEF:BusyWorkers=$RRD:BusyWorkers:AVERAGE \
		DEF:IdleWorkers=$RRD:IdleWorkers:AVERAGE \
		CDEF:TotalWorkers=BusyWorkers,IdleWorkers,+ \
		AREA:BusyWorkers$C_USED:"BusyWorkers":STACK \
		GPRINT:BusyWorkers:LAST:"   Current\:%8.2lf" \
		GPRINT:BusyWorkers:MIN:"Minimum\:%8.2lf"  \
		GPRINT:BusyWorkers:AVERAGE:"Average\:%8.2lf"  \
		GPRINT:BusyWorkers:MAX:"Maximum\:%8.2lf\n"  \
		AREA:IdleWorkers$C_FREE:"IdleWorkers":STACK \
		GPRINT:IdleWorkers:LAST:"   Current\:%8.2lf" \
		GPRINT:IdleWorkers:MIN:"Minimum\:%8.2lf"  \
		GPRINT:IdleWorkers:AVERAGE:"Average\:%8.2lf"  \
		GPRINT:IdleWorkers:MAX:"Maximum\:%8.2lf\n" \
		LINE:TotalWorkers$C_BLACK:"TotalWorkers" \
		GPRINT:TotalWorkers:LAST:"  Current\:%8.2lf" \
		GPRINT:TotalWorkers:MIN:"Minimum\:%8.2lf"  \
		GPRINT:TotalWorkers:AVERAGE:"Average\:%8.2lf"  \
		GPRINT:TotalWorkers:MAX:"Maximum\:%8.2lf\n"
}
