#!/bin/sh

source etc/watchman.conf
source lib/functions.sh
source lib/colors.sh
source lib/module_helpers.sh

find_machines
find_modules

[ -n "$MACHINES" ] || die "No machines defined."
[ -n "$MODULES" ] || die "No modules defined."

MAIN_PID=$$

WEEK=$((7 * 24 * 60 * 60))
END=$(date +%s)
START=$(( $END - 24 * 60 * 60 ))

# Setup default values. Command : does nothing, sucessfully. It is there to 
# safely evaluate variable substitutions. Don't worry that your editors sees 
# it as a comment. It is a comment. With sideeffects.

: ${STEP:=120}
: ${UN:=$(( 2 * $STEP ))}

: ${KEEP:=$(( $WEEK / $STEP ))}

: ${GEOMETRY:="--width 712"}
: ${FONTS:="--font TITLE:12: --font AXIS:8:	--font LEGEND:10: --font UNIT:8:"}
: ${STYLE:="$FONTS --slope-mode"}

: ${RRD_DIR:=rrd}
: ${LOCK_DIR:=locks}
: ${GRAPH_DIR:=graphs}
: ${LOG_FILE:=watchman.log}
