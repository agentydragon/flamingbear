#!/bin/sh

# Create new RRD file in $1
function create() {
	RRD=$1
	rrdtool create "$RRD" --step $STEP \
		DS:Users:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP \
		|| die "Could not create RRD."
}

# Update RRD file in $1
function update() {
	RRD=$1
	rrdtool update "$RRD" $DATE:`who | wc -l`
}

# Plot a new graph from $1 to $2, where $2 may be a prefix when multiple graphs
# are plotted.
function plot() {
	RRD=$1
	GRAPH=$2

	rrdtool graph $GRAPH --lower-limit 0 \
		$GEOMETRY $STYLE \
		--title "Logged in Users" \
		COMMENT:"Number of logged in users in last 24 hour\\c" \
		COMMENT=" \n" \
		--vertical-label='logged in users' \
		--start=$START --end=$END \
		DEF:Users=$RRD:Users:AVERAGE \
		AREA:Users=$C_AZURE:"Users":STACK \
		GPRINT:Users:LAST:"   Current\:8.0lf %s" \
		GPRINT:Users:MIN:"Minimum\:%8.0lf %s" \
		GPRINT:Users:AVERAGE:"Average\:%8.0lf %s" \
		GPRINT:Users:MAX:"Maximum\:%8.0lf %s\n" \
}
