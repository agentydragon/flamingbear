#!/bin/sh

source lib/boot.sh

if [ "$1" == "-f" ]; then
	FORCE_REMOVE_RRDS="yes"
fi

for machine in $MACHINES; do
	load_machine "$machine"
	prepare_machine
done
