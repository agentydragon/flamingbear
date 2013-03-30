#!/bin/sh

source etc/watchman.conf
source lib/functions.sh
source lib/colors.sh
source lib/module_helpers.sh

find_machines
find_modules

[ -n "$MACHINES" ] || die "No machines defined."
[ -n "$MODULES" ] || die "No modules defined."
