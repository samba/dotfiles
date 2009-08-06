#!/bin/bash

function system-status () {
# on host munich:
echo "Uptime:" `uptime`
echo "CPU Frequency:" `cpufreq-info -fm`
echo "System Temperature:" `printf "%s %s" $(sensors -f k8temp-pci-00c3 | grep -E '[0-9]+ F')`
}
