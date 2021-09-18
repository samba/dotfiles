#!/bin/bash

set -euf -o pipefail


CONTAINER_NAME=nzbget-ovpn
LOCAL_NETWORK=192.168.0.0/16

scan_runtime () {
    command -v nerdctl && return 0
    command -v podman && return 0
    command -v docker && return 0
}

RUN=$(scan_runtime | head -n 1)

test -z "${RUN}" && exit 2

run_container () {
    ${RUN} run "$@"
}


stop_container () {
    $RUN stop $1
    $RUN rm $1
}

clean_containers () {
    $RUN ps -a | tail -n +2 | grep Exit | awk '{ print $1 }' | xargs $RUN rm
}


start () {

    while getopts "c:s:p:" arg; do
        case $arg in
            c) CREDENTIALS_FILE=$OPTARG;;
            s) STORAGE_PATH=$OPTARG;;
            p) PROFILEPATH=$OPTARG;;
        esac
    done

    shift $((OPTIND-1))

    # Load the config file. Defines OPENVPN_USERNAME, OPENVPN_PASSWORD, and OPENVPN_CONFIG
    test -f "$CREDENTIALS_FILE" || exit 1
    source "$CREDENTIALS_FILE"


    # The container will modify files in both directories.
    test -d "$STORAGE_PATH" && test -w "$STORAGE_PATH" || exit 2
    test -d "$PROFILEPATH" && test -w "$PROFILEPATH" || exit 3


    # Ensure that VPN configs are real files named as required
    for i in $(ls -1 ${PROFILEPATH}/${OPENVPN_CONFIG/.ovpn/}.conf); do
        if grep -q "^proto" "$i"; then
            test -f "${i/.conf/.ovpn}" || cp -v  "${i}" "${i/.conf/.ovpn}";
        fi
    done

    test -L ${PROFILEPATH}/default.ovpn || {
        cd "${PROFILEPATH}";
        ln -s "${OPENVPN_CONFIG}.ovpn" "./default.ovpn"
        cd $OLDPWD
    }

    # Update some config details for correct behavior
    run_container -it --rm -v ${PROFILEPATH}:/etc/openvpn/custom/:rw \
            haugene/transmission-openvpn bash -c "cd /etc/openvpn; ./adjustConfigs.sh custom"

    # -e VPN_OPTIONS=<additional openvpn cli options> \
    # -e ADDITIONAL_PORTS=<port number(s)> \


    test -c /dev/net/tun || {
        mkdir -p /dev/net && mknod /dev/net/tun c 10 200
        chmod 0666 /dev/net/tun
    }

    run_container --cap-add=NET_ADMIN -d \
        --name=${CONTAINER_NAME} \
        -v ${STORAGE_PATH}:/data:rw \
        -v none:/config/:rw \
        -v /dev/net/tun:/dev/net/tun:rw \
        -v ${PROFILEPATH}:/config/openvpn/ \
        -v /etc/localtime:/etc/localtime:ro \
        -e VPN_ENABLED=yes \
        -e VPN_USER=${OPENVPN_USERNAME} \
        -e VPN_PASS=${OPENVPN_PASSWORD} \
        -e VPN_PROV=custom \
        -e VPN_CLIENT=openvpn \
        -e STRICT_PORT_FORWARD=yes \
        -e ENABLE_PRIVOXY=no \
        -e LAN_NETWORK=${LOCAL_NETWORK} \
        -e NAME_SERVERS=1.1.1.1 \
        -e DEBUG=true \
        -e UMASK=000 \
        -e PUID=$(id -u) \
        -e PGID=$(id -g) \
        -p 6789:6789 \
        jshridha/docker-nzbgetvpn:latest

}

# Lima on MacOS requires mountpoints in a writeable /tmp/lima path.
# As a shortcut, this delegates into lima if present.
if command -v lima; then
    echo "Using VPN credentials from:" ./private/vpn-credentials.sh
    echo "Using VPN profiles directory:" /tmp/lima/vpn/private
    echo "Using Torrate data directory:" /tmp/lima/storage/usenet
    exec lima bash $0 $1 -c ./private/vpn-credentials.sh -p /tmp/lima/vpn/private/ -s /tmp/lima/storage/usenet
fi



MODE=$1; shift;

case $MODE in
    start)  start "$@";;
    stop)   stop_container ${CONTAINER_NAME};;
    clean)  clean_containers;;
    restart)
        stop_container ${CONTAINER_NAME};
        start "$@";;
esac

