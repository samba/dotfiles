#!/bin/bash

set -euf -o pipefail

CONTAINER_NAME=transmission-ovpn
LOCAL_NETWORK=192.168.0.0/16


# TRANSMISSION_WEB_UI=flood-for-transmission
# TRANSMISSION_WEB_UI=transmission-web-control
TRANSMISSION_WEB_UI=combustion
# TRANSMISSION_WEB_UI=kettu
# TRANSMISSION_WEB_UI=shift


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

    # Update some config details for correct behavior
    run_container -it --rm -v ${PROFILEPATH}:/etc/openvpn/custom/:rw \
            haugene/transmission-openvpn bash -c "cd /etc/openvpn; ./adjustConfigs.sh custom"


    run_container --cap-add=NET_ADMIN -d \
            --name ${CONTAINER_NAME} \
            -v none:/dev/net:rw \
            -v ${STORAGE_PATH}:/data:rw \
            -v ${PROFILEPATH}:/etc/openvpn/custom/:rw \
            -e OPENVPN_PROVIDER=custom \
            -e OPENVPN_CONFIG="${OPENVPN_CONFIG}" \
            -e OPENVPN_USERNAME="${OPENVPN_USERNAME}" \
            -e OPENVPN_PASSWORD="${OPENVPN_PASSWORD}" \
            -e TRANSMISSION_WEB_UI=$TRANSMISSION_WEB_UI \
            -e TRANSMISSION_BLOCKLIST_ENABLED=true \
            -e TRANSMISSION_BLOCKLIST_URL="http://list.iblocklist.com/?list=ydxerpxkpcfqjaybcssw&fileformat=p2p&archiveformat=gz" \
            -e LOCAL_NETWORK=${LOCAL_NETWORK} \
            -e DROP_DEFAULT_ROUTE=true \
            -p 9092:9091 \
            haugene/transmission-openvpn "$@"
}

# Lima on MacOS requires mountpoints in a writeable /tmp/lima path.
# As a shortcut, this delegates into lima if present.
if command -v lima; then
    echo "Using VPN credentials from:" ./private/vpn-credentials.sh
    echo "Using VPN profiles directory:" /tmp/lima/vpn/private
    echo "Using Torrate data directory:" /tmp/lima/storage
    exec lima bash $0 $1 -c ./private/vpn-credentials.sh -p /tmp/lima/vpn/private/ -s /tmp/lima/storage/
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

