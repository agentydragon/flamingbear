#!/bin/sh

source lib/boot.sh

if [ $# -lt 2 ]; then
	die "Usage: $0 [MACHINE] [MODULE] [FILE]"
fi

machine="$1"
module="$2"
file="$3"

load_machine "$machine"
load_module "$module"

plot_module_data "$file"
