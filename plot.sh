#!/bin/sh

# Usage: plot.sh (machine) (module) (file)

function do_plot() {
	module="$1"
	load_module "$module"
	if [ $# -ge 2 ]; then
		file="$2"
	else
		ensure_graph_directory
		file="$GRAPH_DIR/$MACHINE/$SANITIZED_MODULE_COMMANDLINE.png"
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

case $1 in
--help|-h)
	echo "Usage: $0 [MACHINE [MODULE [OUTPUT_FILE]]]"
	echo "By default, all modules activated on all machines plot their graphs to the default location ($GRAPH_DIR)."
	exit 0
esac

if [ $# -ge 1 ]; then
	process_machine "$1" "$2" "$3"
else
	for machine in $MACHINES; do
		process_machine "$machine"
	done
fi

