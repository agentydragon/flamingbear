#!/bin/sh

source lib/boot.sh

case $1 in
--help|-h)
	echo "Usage: $0 [MACHINE1 MACHINE2 ...]"
	echo "Collects data from all machines by default."
	exit 0
esac

BOXES="$@"
if [ "z" == "${BOXES}z" ]; then
	BOXES="$MACHINES"
fi

PIDS=""
for BOX in $BOXES; do
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
