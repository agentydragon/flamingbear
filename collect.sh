#!/bin/sh

source lib/boot.sh

for machine in $MACHINES; do
	load_machine "$machine"
	collect_machine_data
done

# Usage:
#   no args: collect from all machines
#   some args: collect from those machines
