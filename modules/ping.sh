#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:Ping:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP
}

# Update RRD file
function update() {
	local SAMPLES=3
	DATA=$(ping -c $SAMPLES "$HOSTNAME" | awk "
		BEGIN { total = 0; }
		/time=/ { split(\$8,spl,\"=\"); total+=spl[2] }
		END { print total/$SAMPLES }
	")
}

function plot() {
	plot_rrd \
		--title "Ping in milliseconds" \
		--vertical-label="ping in milliseconds" \
		DEF:Ping=$RRD:Ping:AVERAGE \
		AREA:Ping$C_RED:Ping:STACK \
		GPRINT:Ping:LAST:"   Current\:%8.2lf %s" \
		GPRINT:Ping:MIN:"Minimum\:%8.0lf %s" \
		GPRINT:Ping:AVERAGE:"Average\:%8.0lf %s" \
		GPRINT:Ping:MAX:"Maximum\:%8.0lf %s\n"
}
