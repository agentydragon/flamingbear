#!/bin/sh

source etc/watchman.conf
source lib/functions.sh

find_machines
find_modules

[ -n "$MACHINES" ] || die "No machines defined."
[ -n "$MODULES" ] || die "No modules defined."
