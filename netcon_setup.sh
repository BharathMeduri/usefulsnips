#!/bin/bash
# netcon_setup.sh
# 
# Quick Description:
# Netconsole setup helper script.
# To be run on the local "patient" system; the remote system is the "doctor"
# / host :)
# Assumes the 'netconsole' kernel module is present.
#
# To learn more details and how to etup netconsole, pl read:
# https://www.kernel.org/doc/Documentation/networking/netconsole.txt
# https://wiki.ubuntu.com/Kernel/Netconsole
# https://mraw.org/blog/2010/11/08/Debugging_using_netconsole/
# 
# Last Updated : 29June2017
# Created      : 14June2017
# 
# Author:
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# kaiwanTECH
# 
# License: MIT.
# 
name=$(basename $0)

########### Functions follow #######################

remotePort=6666   # default recv port for netconsole

main()
{

localIP=$(hostname -I |cut -d" " -f1)
[ -z ${localIP} ] && {
  echo "${name}: error: could not fetch local IP address (network ok?)"
  exit 1
}

localDev=$(ifconfig |grep -B1 "${localIP}" |head -n1 |cut -d":" -f1)
[ -z ${localDev} ] && {
  echo "${name}: error: could not fetch local network interface name (network ok?)"
  exit 1
}

lsmod|grep -q netconsole && {
 sudo rmmod netconsole || {
   echo "${name}: rmmod netconsole [old instance] failing, aborting..."
   exit 1
 }
}

#cmdstr="modprobe netconsole netconsole=+@${localIP}/${localDev},${remotePort}@${remoteIP}/"
                                      # + => 'extended' console support (verbose)
cmdstr="sudo modprobe netconsole netconsole=@${localIP}/${localDev},${remotePort}@${remoteIP}/"
echo "Running: ${cmdstr}"
eval ${cmdstr} || {
 echo "${name}: sudo modprobe netconsole ... failed, aborting..
*** NOTE- netconsole fails on a WiFi local device, pl Ensure you use ***
*** Wired Ethernet on this (local) system                            ***
 Last 20 lines dmesg output follows:
"
 dmesg |tail -n20
 exit 1
}

lsmod|grep netconsole
echo "${name}: netconsole locked & loaded.
Ensure (remote) receiver is setup to receive log packets (over nc)
 Res: https://wiki.ubuntu.com/Kernel/Netconsole"
} # end main()

##### execution starts here #####

#[ $(id -u) -ne 0 ] && {
#  echo "${name}: requires root."
#  exit 1
#}
[ $# -ne 1 ] && {
 echo "Usage: ${name} remoteIP"
 exit 1
}
remoteIP=$1
main
exit 0
