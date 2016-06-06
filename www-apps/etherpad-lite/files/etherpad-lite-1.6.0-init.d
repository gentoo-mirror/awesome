#!/sbin/runscript
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETHERPAD_USER=${ETHERPAD_USER:=etherpad}
ETHERPAD_GROUP=${ETHERPAD_GROUP:=daemon}
ETHERPAD_PATH=${ETHERPAD_PATH:=/usr/share/etherpad-lite}
ETHERPAD_PID=${ETHERPAD_PID:-/run/etherpad-lite.pid}
ETHERPAD_DAEMON_NAME=${ETHERPAD_DAEMON_NAME:=etherpad-lite}
ETHERPAD_NODE=${ETHERPAD_NODE:=/usr/local/bin/node}
ETHERPAD_LOG=${ETHERPAD_LOG:=/var/log/etherpad-lite}

start_pre() {
	checkpath -f -m 0600 -o "${ETHERPAD_USER}":"${ETHERPAD_GROUP}" "${ETHERPAD_PATH}/SESSIONKEY.txt"
	checkpath -f -m 0600 -o "${ETHERPAD_USER}":"${ETHERPAD_GROUP}" "${ETHERPAD_PATH}/APIKEY.txt"
	checkpath -d -m 0700 -o "${ETHERPAD_USER}":"${ETHERPAD_GROUP}" "${ETHERPAD_PATH}/var"
}

start(){
	ebegin "Starting ${SVCNAME}"
	start-stop-daemon \
		-S \
		-x ${ETHERPAD_NODE} \
		-n ${ETHERPAD_DAEMON_NAME} \
		-d ${ETHERPAD_PATH} \
                -u ${ETHERPAD_USER} \
                -g ${ETHERPAD_GROUP} \
		-1 ${ETHERPAD_LOG}/stdout.log \
		-2 ${ETHERPAD_LOG}/stderr.log \
                -b \
		-m \
		-p ${ETHERPAD_PID} -- \
		"src/node/server.js" ${ETHERPAD_ARGS}
}

stop(){
	ebegin "Stopping ${SVCNAME}"
        start-stop-daemon \
                -K \
                -x ${ETHERPAT_NODE} \
                -d ${ETHERPAD_PATH} \
                -u ${ETHERPAD_USER} \
                -g ${ETHERPAD_GROUP} \
                -p ${ETHERPAD_PID}
}

depend() {
	need net
}
