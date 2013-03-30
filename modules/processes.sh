#!/bin/sh

# Create new RRD file
function create() {
	create_rrd DS:ProcsTotal:GAUGE:$UN:0:U \
		DS:ProcsRunning:GAUGE:$UN:0:U \
		DS:ProcsBlocked:GAUGE:$UN:0:U \
		RRA:AVERAGE:0.5:1:$KEEP

}

# Update RRD file
function update() {
	COMMAND="cat /proc/stat | awk '
			/^procs_running/ { pr = \$2 }
			/^procs_blocked/ { pb = \$2 }
			END { printf \"%i:%i:%i\", '\$(ps -e -o pid=0 -o comm=o | wc -l)', pr, pb}'"
	run_on_server $COMMAND
}

function plot() {
	plot_rrd \
		--title "Processes ($MACHINE)" \
		COMMENT:"Number of processes in last 24 hour\\c" \
		COMMENT:" \n" \
		--vertical-label='processes' \
		DEF:Total=$RRD:ProcsTotal:AVERAGE \
		DEF:Blocked=$RRD:ProcsBlocked:AVERAGE \
		DEF:Running=$RRD:ProcsRunning:AVERAGE \
		CDEF:Idle=Total,Blocked,Running,+,- \
		AREA:Blocked$C_RED:"Blocked" \
		GPRINT:Blocked:LAST:"   Current\:%8.2lf %s" \
		GPRINT:Blocked:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Blocked:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Blocked:MAX:"Maximum\:%8.2lf %s\n"  \
		AREA:Running$C_GREEN:"Running":STACK \
		GPRINT:Running:LAST:"   Current\:%8.2lf %s" \
		GPRINT:Running:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Running:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Running:MAX:"Maximum\:%8.2lf %s\n" \
		AREA:Idle$C_AZURE:"Idle":STACK \
		GPRINT:Idle:LAST:"      Current\:%8.2lf %s" \
		GPRINT:Idle:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Idle:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Idle:MAX:"Maximum\:%8.2lf %s\n" \
		LINE:Total$C_BLACK:"Total" \
		GPRINT:Total:LAST:"     Current\:%8.2lf %s" \
		GPRINT:Total:MIN:"Minimum\:%8.2lf %s"  \
		GPRINT:Total:AVERAGE:"Average\:%8.2lf %s"  \
		GPRINT:Total:MAX:"Maximum\:%8.2lf %s\n"
}
