#!/bin/sh

# Usage: plot.sh (machine) (module) (file)

function do_plot() {
	module="$1"
	load_module "$module"
	if [ $# -ge 2 ]; then
		file="$2"
	else
		ensure_graph_directory
		file="$GRAPH_DIR/$MACHINE/$module-$(date +%Y%m%d-%H%M).png"
	fi

	debug "Plotting into $file"
	plot_module_data "$file"
}

function process_machine() {
	machine="$1"
	load_machine "$machine"
	if [ $# -ge 2 ]; then
		do_plot "$2" "$3"
	else
		for module in $USE_MODULES; do
			do_plot "$module"
		done
	fi
}

source lib/boot.sh

if [ $# -ge 1 ]; then
	process_machine "$1" "$2" "$3"
else
	for machine in $MACHINES; do
		process_machine "$machine"
	done
fi

