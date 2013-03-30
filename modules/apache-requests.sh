#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:TotalRequests:COUNTER:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	DATA=$(wget -q -O - http://$HOSTNAME/server-status?auto | awk '
		/^Total Accesses:/ { print $3 }')
}

function plot() {
	plot_rrd \
		--title "Apache requests/s ($MACHINE)" \
		COMMENT:"Apache requests per second in last 24 hour\\c" \
		COMMENT:" \n" \
		--vertical-label='requests/s' \
		--units-exponent='0' \
		DEF:TotalRequests=$RRD:TotalRequests:AVERAGE \
		AREA:TotalRequests$C_AZURE:"Requests/s" \
		GPRINT:TotalRequests:LAST:"   Current\:%8.2lf" \
		GPRINT:TotalRequests:MIN:"Minimum\:%8.2lf"  \
		GPRINT:TotalRequests:AVERAGE:"Average\:%8.2lf"  \
		GPRINT:TotalRequests:MAX:"Maximum\:%8.2lf\n"
}
