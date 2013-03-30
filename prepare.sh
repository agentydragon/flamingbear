#!/bin/sh

source lib/boot.sh

case $1 in
--help|-h)
	echo "Usage: $0 [-f] [MACHINE1 MACHINE2 ...]"
	echo "Prepares RRD files of machines. Does this for all machines by default."
	echo "\t-f: forcefully create RRDs, even if they already exist"
	exit 0
esac

if [ "$1" == "-f" ]; then
	FORCE_REMOVE_RRDS="yes"
	shift
fi

BOXES="$@"
if [ "z" == "${BOXES}z" ]; then
	BOXES="$MACHINES"
fi

for machine in $BOXES; do
	load_machine "$machine"
	prepare_machine
done
