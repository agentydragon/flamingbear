
#!/bin/sh

# Create new RRD file in $1
function create() {
	RRD=$1
	rrdtool create "$RRD" --step $STEP \
		DS:Ping:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP \
		|| die "Could not create RRD."
}

# Update RRD file in $1
function update() {
	RRD=$1
	SAMPLES=3
	PING=$(ping -c $SAMPLES "$HOSTNAME" | awk "
		BEGIN { total = 0; }
		/time=/ { split(\$8,spl,\"=\"); total+=spl[2] }
		END { print total/$SAMPLES }
	")
	rrdtool update "$RRD" $DATE:$PING
}

# Plot a new graph from $1 to $2, where $2 may be a prefix when multiple graphs
# are plotted.
function plot() {
	RRD=$1
	GRAPH=$2

	rrdtool graph $GRAPH --lower-limit 0 \
		$GEOMETRY $STYLE \
		--title "Ping in milliseconds" \
		--vertical-label='ping in milliseconds' \
		--start=$START --end=$END \
		DEF:Ping=$RRD:Ping:AVERAGE \
		AREA:Ping\#60A2FF:Ping:STACK \
		GPRINT:Ping:LAST:"   Current\:%8.2lf %s" \
		GPRINT:Ping:MIN:"Minimum\:%8.0lf %s" \
		GPRINT:Ping:AVERAGE:"Average\:%8.0lf %s" \
		GPRINT:Ping:MAX:"Maximum\:%8.0lf %s\n"
}
