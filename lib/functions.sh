#!/bin/sh

MACHINES=""
MODULES=""

#####################
DATE=`date +%s`
WEEK=$(( 7 * 24 * 60 * 60 ))
END=$DATE
START=$(( $END - 24 * 60 * 60 ))
#START=$(( $END - 10 * 60 ))

# Setup default values. Command : does nothing, sucessfully. It is there to 
# safely evaluate variable substitutions. Don't worry that your editors sees 
# it as a comment. It is a comment. With sideeffects.

: ${STEP:=120}
: ${UN:=$(( 2 * $STEP ))}

: ${KEEP:=$(( $WEEK / $STEP ))}

: ${GEOMETRY:="--width 712"}
: ${FONTS:="--font TITLE:12: --font AXIS:8:	--font LEGEND:10: --font UNIT:8:"}
: ${STYLE:="$FONTS --slope-mode"}

: ${HOST:="localhost"}
: ${HOST_NAME:=$HOST}

: ${GRAPH_DIR:=graphs}
#####################

function die() {
	echo "==> $@"
	echo "==> Exiting."
	exit 1
}

function debug() {
	echo "--> $@"
}

function find_machines() {
	MACHINES=$(find etc/machines/ -name "*.conf" -type f |
	while read filename
	do
		echo -n "$(echo -n "$filename" | rev | cut -d. -f2- | cut -d/ -f1 | rev) "
	done)
}

function find_modules() {
	MODULES=$(find modules/ -name "*.sh" -type f |
	while read filename
	do
		echo -n "$(echo -n "$filename" | rev | cut -d. -f2- | cut -d/ -f1 | rev) "
	done)
}

function load_machine() {
	MACHINE=$(echo "$1" | sed -e 's/^ *//' -e 's/ *$//')
	(echo "$MACHINES" | grep -- "$MACHINE" > /dev/null) || die "No such machine known: $MACHINE"
	source "etc/machines/${MACHINE}.conf"
	debug "Machine $MACHINE loaded."
}

function load_module() {
	MODULE="$1"
	(echo "$MODULES" | grep -- "$MODULE" > /dev/null) || die "No such module known: $MODULE"
	source "modules/${MODULE}.sh"
	debug "Module $MODULE loaded."
}

function collect_machine_data() {
	lock_machine
	PIDS=""
	for module in $USE_MODULES; do
		debug "Collecting data with module ${module}."
		load_module "$module"
		collect_module_data &
		PID=$!
		PIDS="$PIDS $PID"
		debug "Background module PID: $PID"
	done

	for PID in $PIDS; do
		debug "Waiting for module PID $PID"
		wait $PID
	done

	unlock_machine
}

function prepare_machine() {
	MACHINE_DIR="$RRD_DIR/$MACHINE"
	mkdir -p "$MACHINE_DIR" || die "Failed to create machine directory $MACHINE_DIR"
	# TODO: parametry za dvojteckou jdou modulu
	for module in $USE_MODULES; do
		debug "Preparing module ${module}."
		load_module "$module"
		prepare_module_data
	done
}

function find_rrd_path() {
	RRD="$RRD_DIR/$MACHINE/${MODULE}.rrd"
}

function prepare_module_data() {
	find_rrd_path
	create "$RRD"
}

function collect_module_data() {
	find_rrd_path
	DATE=$(date +%s)
	update "$RRD"
}

function plot_module_data() {
	FILE="$1"
	find_rrd_path
	plot "$RRD" "$FILE"
}

function ensure_lock_directory() {
	mkdir -p "$LOCK_DIR" || die "Failed to create lock directory $LOCK_DIR"
}

function lock_machine() {
	ensure_lock_directory
	debug "Locking machine $MACHINE"
	LOCK_FILE="$LOCK_DIR/$MACHINE"
	MAX_ATTEMPTS=10
	ATTEMPTS="$MAX_ATTEMPTS"

	while [ -f "$LOCK_FILE" ]; do
		if [ "$ATTEMPTS" -lt 1 ]; then
			die "Failed to lock machine $MACHINE after $MAX_ATTEMPTS attempts"
		fi
		ATTEMPTS=$(($ATTEMPTS - 1))
		sleep 2 
		debug "$MACHINE still locked, trying again."
	done

	touch "$LOCK_FILE" || die "Failed to create lock file for $MACHINE"
}

function unlock_machine() {
	debug "Unlocking machine $MACHINE"
	LOCK_FILE="$LOCK_DIR/$MACHINE"
	[ -f "$LOCK_FILE" ] || die "Unlocking an unlocked machine ($MACHINE)"
	rm "$LOCK_FILE" || die "Failed to unlock machine $MACHINE"
}

function ensure_graph_directory() {
	mkdir -p "$GRAPH_DIR/$MACHINE" || die "Failed to create graph directory for $MACHINE"
}
