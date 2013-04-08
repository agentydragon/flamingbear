#!/bin/sh

function log() {
	echo "$(date +%Y-%m-%d\ %H:%M) $@" >> $LOG_FILE
}

function error() {
	log Error: $@
	echo "==> $@"
}

function die() {
	error $@
	log Exiting.
	echo "==> Exiting."
	exit 1
}

function debug() {
	echo "--> $@"
}

function cut_directory_and_extension() {
	echo -n "$1" | rev | cut -d. -f2- | cut -d/ -f1 | rev
}

function find_machines() {
	MACHINES=$(find etc/machines/ -name "*.conf" -type f |
	while read filename
	do
		echo -n "$(cut_directory_and_extension "$filename") "
	done)
}

function find_modules() {
	MODULES=$(find modules/ -name "*.sh" -type f |
	while read filename
	do
		echo -n "$(cut_directory_and_extension "$filename") "
	done)
}

function load_machine() {
	MACHINE=$(echo "$1" | sed -e 's/^ *//' -e 's/ *$//')
	(echo " $MACHINES " | grep -- " $MACHINE " > /dev/null) || die "No such machine known: $MACHINE"
	source "etc/machines/${MACHINE}.conf"
	debug "Machine $MACHINE loaded."
}

function load_module() {
	MODULE_COMMANDLINE="$1"
	SANITIZED_MODULE_COMMANDLINE=$(echo "$1" | tr : _)
	MODULE="$(echo -n "$MODULE_COMMANDLINE" | cut -d: -f1)"
	MODULE_ARGS="$(echo -n "$MODULE_COMMANDLINE" | cut -d: -f2-)"
	if [ "$MODULE_ARGS" == "$MODULE" ]; then
		MODULE_ARGS=""
	fi
	(echo "$MODULES" | grep -- "$MODULE" > /dev/null) || die "No such module known: $MODULE"
	source "modules/${MODULE}.sh"
	debug "Module $MODULE loaded."
}

function collect_machine_data() {
	# Run in a subshell so that machine settings don't persist.
	(
		MACHINE="$1"
		log "Collecting data from $MACHINE."

		lock_machine

		load_machine "$MACHINE"

		PIDS=""
		for module in $USE_MODULES; do
			debug "Collecting data with module ${module} on $MACHINE."
			load_module "$module"
			collect_module_data &
			PID=$!
			PIDS="$PIDS $PID"
			debug "Background module PID: $PID"
		done

		FAULTS=0
		for PID in $PIDS; do
			debug "Waiting for module PID $PID"
			wait $PID
			if [ $? -ne 0 ]; then
				FAULTS=$(($FAULTS+1))
				error "Module failed to collect data."
			fi
		done
		unlock_machine

		if [ $FAULTS -ne 0 ]; then
			die "Failed to collect data from $FAULTS module(s) on $MACHINE."
		fi
	)
}

function prepare_machine() {
	# Run in a subshell so that machine settings don't persist.
	(
		MACHINE="$1"
		load_machine "$MACHINE"

		MACHINE_DIR="$RRD_DIR/$MACHINE"
		mkdir -p "$MACHINE_DIR" || die "Failed to create machine directory $MACHINE_DIR"
		for module in $USE_MODULES; do
			debug "Preparing module ${module}."
			load_module "$module"
			prepare_module_data
		done
	)
}

function find_rrd_path() {
	RRD="$RRD_DIR/$MACHINE/${SANITIZED_MODULE_COMMANDLINE}.rrd"
}

function prepare_module_data() {
	find_rrd_path
	if [ -f "$RRD" ]; then
		if [ -z "$FORCE_REMOVE_RRDS" ]; then
			die "RRD file $RRD already exists. Run with -f to force removal."
		else
			debug "Removing ${RRD}."
			rm -f "$RRD"
		fi
	fi
	create
}

function collect_module_data() {
	find_rrd_path
	[ -f "$RRD" ] || die "RRD file for module $MODULE on $MACHINE ($RRD) doesn't exist. Please, run prepare.sh first."

	# Modules may change OKAY if they wish.
	UNCHECKED="unchecked"
	STATUS="$UNCHECKED"

	update

	rrdtool update "$RRD" "$(date +%s):$DATA"

	STATUS_PATH="$STATUS_DIR/$MACHINE/${SANITIZED_MODULE_COMMANDLINE}.status"

	if [ "$STATUS" != "$UNCHECKED" ]; then
		debug "Reported module $MODULE status on $MACHINE: $STATUS"
		mkdir -p "$STATUS_DIR/$MACHINE" || die "Failed to create machine status directory"
		echo "$STATUS" > "$STATUS_PATH"
	else
		if [ -f "$STATUS_PATH" ]; then
			echo "?" > "$STATUS_PATH"
		fi
	fi
}

function plot_module_data() {
	find_rrd_path
	[ -f "$RRD" ] || die "RRD file for module $MODULE on $MACHINE ($RRD) doesn't exist. Please, run prepare.sh first."
	GRAPH="$1"
	plot
}

function ensure_lock_directory() {
	mkdir -p "$LOCK_DIR" || die "Failed to create lock directory $LOCK_DIR"
}

function try_lock_machine() {
	local LOCK_DIR="$LOCK_DIR/$MACHINE"
	mkdir "$LOCK_DIR" &>/dev/null && return 0

	debug "Failed to lock $MACHINE."
	return 1
}

function lock_machine() {
	ensure_lock_directory
	debug "Locking machine $MACHINE as $MAIN_PID"
	local MAX_ATTEMPTS=10
	local ATTEMPTS="$MAX_ATTEMPTS"

	while [ "$ATTEMPTS" -gt 0 ]; do
		if try_lock_machine; then
			debug "$MACHINE lock obtained."
			return
		fi

		ATTEMPTS=$(($ATTEMPTS - 1))
		debug "$MACHINE still locked, trying again in 2 seconds."
		sleep 2
	done

	die "Failed to lock $MACHINE after $MAX_ATTEMPTS attempts."
}

function unlock_machine() {
	debug "Unlocking machine $MACHINE"
	local LOCK_DIR="$LOCK_DIR/$MACHINE"
	[ -d "$LOCK_DIR" ] || die "Unlocking an unlocked machine ($MACHINE)"
	rmdir "$LOCK_DIR" || die "Failed to unlock machine $MACHINE"
}

function ensure_graph_directory() {
	mkdir -p "$GRAPH_DIR/$MACHINE" || die "Failed to create graph directory for $MACHINE"
}
