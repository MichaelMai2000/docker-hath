#!/bin/sh

# Author: avluis (alvaradorocks@gmail.com)

# Package
PACKAGE="hath"
DNAME="Hentai@Home"

# Package Variables
HATH_DIR="/home/$PACKAGE/client"
HATH_JAR="HentaiAtHome.jar"
HATH="$HATH_DIR/$HATH_JAR"
HATH_ARGS="--use_more_memory --disable_logging"
PID_FILE="$HATH_DIR/hath"
LOG_FILE="$HATH_DIR/data/log_out"
ERROR_FILE="$HATH_DIR/data/log_err"
JAVA="/opt/jdk/bin/java"
JAVA_ARGS="-jar $HATH"
USER="hath"

# Exit if the java is not installed
[ -x "$JAVA" ] || exit 0

start_daemon (){
	if [ -f "$HATH" ]; then
		nohup $JAVA $JAVA_ARGS $HATH_ARGS > /dev/null 2>&1 &
		PID=$!
		echo "$PID" > "$PID_FILE".pid
		exit 0
	else
		echo "Program not found, update location or script."
  	exit 1
  	fi
}

stop_daemon (){
    kill `cat "$PID_FILE".pid`
    wait_for_status 1 20 || kill -9 `cat "$PID_FILE".pid`
    rm -f "$PID_FILE".pid
}

daemon_status (){
    if [ -f "$PID_FILE".pid ] && kill -0 `cat "$PID_FILE".pid` > /dev/null 2>&1; then
        return
    fi
    rm -f "$PID_FILE".pid
    return 1
}

wait_for_status (){
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && return
        let counter=counter-1
        sleep 1
    done
    return 1
}

case $1 in
    start)
        if daemon_status; then
            echo ${DNAME} is already running
        else
            echo Starting ${DNAME} ...
            start_daemon
        fi
        ;;
    stop)
        if daemon_status; then
            echo Stopping ${DNAME} ...
            stop_daemon
        else
            echo ${DNAME} is not running
        fi
        ;;
    status)
        if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    log)
        echo ${LOG_FILE}
        ;;
    *)
    	echo "Usage: $0 {start|stop|status|log}"
        exit 1
        ;;
esac