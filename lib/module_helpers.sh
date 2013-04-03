#!/bin/sh
# Module helpers

# Runs $@ on the tested machine and saves into $OUTPUT.
function run_on_server() {
	COMMAND="$@"
	if [ -z $LOCAL ]; then
		local TARGET="$HOSTNAME"
		if [ -n $USER ]; then
			TARGET="$USER@$TARGET"
		fi

		DATA=$(ssh "$TARGET" $COMMAND)
		RESULT=$?
		[ $RESULT -eq 0 ] || die "Remote command failed: $@"
	else
		DATA=$(sh -c "$COMMAND")
		RESULT=$?
		[ $RESULT -eq 0 ] || die "Local command failed: $COMMAND"
	fi
	return $RESULT
}

function create_rrd() {
	rrdtool create "$RRD" --step $STEP \
		$@ \
		|| die "Could not create RRD."
}

function plot_rrd() {
	# The options this function sets are sane defaults. If the module
	# wants to, it is free to override those.
	rrdtool graph "$GRAPH" --lower-limit 0 \
		$GEOMETRY $STYLE \
		--start=$START --end=$END \
		"$@" \
		> /dev/null \
		|| die "Failed to plot the graph."
}
