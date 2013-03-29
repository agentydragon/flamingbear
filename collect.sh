#!/bin/sh

source lib/boot.sh

PIDS=""
for BOX in $MACHINES; do
	load_machine "$BOX"
	collect_machine_data &
	PID=$!
	PIDS="$PIDS $PID"
	debug "Background machine PID: $PID"
done

for PID in $PIDS; do
	debug "Waiting for machine PID $PID"
	wait $PID
done

# Usage:
#   no args: collect from all machines
#   some args: collect from those machines
