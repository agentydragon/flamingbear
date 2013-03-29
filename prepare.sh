#!/bin/sh

source lib/boot.sh

for machine in $MACHINES; do
	load_machine "$machine"
	prepare_machine
done
