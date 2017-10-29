#!/bin/bash
# xplore_fs.sh
#
# This is a simple script to help you explore the content of any filesystem!
# Typical use case: to recursively read the ASCII text content of the (pseudo)files
# under pseudo-filesystems like procfs and sysfs!
# 
# Tune the MAXDEPTH variable below to control your descent into fs purgatory :)
# 
# Author: Kaiwan N Billimoria, kaiwanTECH.
# MIT License.

name=$(basename $0)
PFX=$(dirname `which $0`)
source ${PFX}/common.sh || {
 echo "${name}: fatal: could not source ${PFX}/common.sh , aborting..."
 exit 1
}

MAX_SZ=3000000  # 3 MB   #100
MAX_LINES=25000 #500

# Parameters
# $1 : regular text file's pathname - to display contents of
display_file()
{
[ $# -eq 0 ] && return

# Check limits
local sz=$(ls -l $1|awk '{print $5}')
#pr_sz_human "sz" ${sz}

tput bold
ls -lh $1

[ ${sz} -gt ${MAX_SZ} ] && {
  printf "\n   *** <Skipping, above max allowed size (%ld bytes)> ***\n" ${MAX_SZ}
  return
}
local numln=$(wc -l $1|awk '{print $1}')
printf "${numln} lines\n"
color_reset
[ ${numln} -gt ${MAX_LINES} ] && {
  printf "\n   *** <Skipping, above max allowed lines (%ld)> ***\n" ${MAX_LINES}
  return
}

printf "%s\n" "${SEP}"
[ -f $1 -a -r $1 ] && cat $1     # display file content
} # end display_file()

usage()
{
 echo "Usage: ${name} start-dir [max-folder-depth-to-traverse]

 Displays the names of all files starting from the folder 'start-dir';
 if a regular file And it's readable And it's size and number if lines lies
 within the preconfigured 'max', it's content is displayed.

 The 'max-folder-depth-to-traverse' parameter is optional; passing it
 constrains the folder depth of the search [default=4]."
 exit 1
} # end usage()


###--- "main" here
STARTDIR=/sys/devices
name=$(basename $0)
SEP="--------------------------------------------------------------------------"
MAXDEPTH=4

[ $# -lt 1 -o "$1" = "-h" -o "$1" = "--help" ] && usage
[ ! -d $1 ] && {
 echo "${name}: '$1' invalid folder. Aborting..."
 exit 1
}
[ ! -r $1 ] && {
 echo "${name}: '$1' not read-able, re-run this utility as root (with sudo)? Aborting..."
 exit 1
}
STARTDIR=$1
regex='^[0-9]+$'
[ $# -eq 2 ] && {
  if [[ ! $2 =~ ${regex} ]] ; then
    echo "${name}: 2nd parameter 'maxdepth' must be a positive integer"
	exit 1
  fi
  MAXDEPTH=$2
}

SHOW_SUMMARY=1
if [ ${SHOW_SUMMARY} -eq 1 ]; then
	echo "===================== SUMMARY LIST of Files =========================="
	echo
	echo "Note: Max Depth is ${MAXDEPTH}."
	echo
	find -L ${STARTDIR} -xdev -maxdepth ${MAXDEPTH}  # multi-level find; more info..
	echo
	echo
fi
printf "%s\n" ${SEP}

######### the main loop ################
#for sysfile in $(find ${STARTDIR})      # 1-level find; simpler..
for sysfile in $(find -L ${STARTDIR} -xdev -maxdepth ${MAXDEPTH})       # multi-level find; more info..
do
  tput bold 2>/dev/null
  fg_white ; bg_blue
  printf "%-60s " ${sysfile}
  case $(file --mime-type --brief ${sysfile}) in
		inode/symlink) #techo ": <slink>" ; continue ;;
		  printf ": <slink>\n" ; continue ;;
		inode/directory) printf ": <dir>\n" ; continue ;;
		inode/socket) printf ": <socket>\n" ; continue ;;
		inode/chardevice) printf ": <chardev>\n" ; continue ;;
		inode/blockdevice) printf ": <blockdev>\n" ; continue ;;
		application/x-sharedlib|*zlib) printf ": <binary>\n" ; continue ;;
		application/zip|application/x-xz) printf ": <zip file>\n" ; continue ;;
		# Text files
		text/plain|text/*)
					color_reset ; tput bold 2>/dev/null ; fg_red ; bg_white
					printf ": <reg file>\n"
					color_reset
					display_file ${sysfile}
					;;
		# procfs files
		inode/x-empty) # usually the case for procfs (pseudo)'files'
					color_reset ; tput bold 2>/dev/null
					firstdir="/$(echo "${sysfile}" |cut -d"/" -f2)"
					#echo "firstdir=${firstdir}"
					[ "${firstdir}"="/proc" ] && {
					  fg_magenta ; bg_white
					  display_file ${sysfile}
					}
					color_reset
					;;
		*) fg_white ; bg_blue
		   printf ": <-other->\n"
		   ls -l ${sysfile} 2>/dev/null
		   color_reset
		   continue ;;
  esac
  printf "%s\n" ${SEP}
  color_reset
done
################
exit 0
