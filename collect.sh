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

FAULTS=0
for PID in $PIDS; do
	debug "Waiting for machine PID $PID"
	wait $PID
	if [ $? -ne 0 ]; then
		FAULTS=$(($FAULTS+1))
		error "Failed to collect data from a machine"
	fi
done

if [ $FAULTS -ne 0 ]; then
	die "Failed to collect data from $FAULTS machine(s)."
fi

# Usage:
#   no args: collect from all machines
#   some args: collect from those machines
