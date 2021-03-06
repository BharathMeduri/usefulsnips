#!/bin/bash
# 0setup.bash
# Convenience startup script
#
# You must run this as:
# $ . /0setup.bash
#
# Don't miss the ". " syntax!
# 
# Part of the Seawolf Appliance
# (c) kaiwanTECH

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

pushd . >/dev/null
PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:/home/seawolf/kaiwanTECH/usefulsnips
BASH_ENV=$HOME/.bashrc

export BASH_ENV PATH
unset USERNAME

#--- Prompt
# ref: https://unix.stackexchange.com/questions/20803/customizing-bash-shell-bold-color-the-command
[ `id -u` -eq 0 ] && {
   #export PS1='# '
   export PS1='\[\e[1;34m\] $(hostname) # \[\e[0;32m\]'
} || {
   #export PS1='$ '
   export PS1='\[\e[1;34m\] $(hostname) \$ \[\e[0;32m\]'
}
trap 'printf \\e[0m' DEBUG  # IMP: turn Off color once Enter pressed..

# Aliases
alias cl='clear'
alias ls='ls -F --color=auto'
alias l='ls -lFh --color=auto'
alias ll='ls -lF --color=auto'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias dmesg='/bin/dmesg --decode --nopager --color --ctime'
alias dm='dmesg|tail -n35'
alias dc='echo "Clearing klog"; dmesg -c > /dev/null'
alias jlog='/bin/journalctl -ab --no-pager'
alias jlogr='/bin/journalctl -amxr' #--no-pager|tail -n30' # r => reverse order
alias lsh='lsmod | head'

alias grep='grep --color=auto'
alias s='echo "Syncing.."; sync; sync; sync'
alias d='df -h|grep "^/dev/"'
alias f='free -ht'
alias ma='mount -a; df -h'

alias py='ping -c3 yahoo.com'
alias inet='netstat -a|grep ESTABLISHED'
alias ifw='/sbin/ifconfig wlan0'
#--------------------ps stuff
# custom recent ps
alias rps='ps -o user,pid,rss,stat,time,command -Aww |tail -n30'
# custom ps sorted by highest CPU usage
alias rcpu='ps -o %cpu,%mem,user,pid,rss,stat,time,command -Aww |sort -k1n'
alias pscpu='ps aux|sort -k3n'
#------------------------------------------------------------------------------

#alias vim='vim $@ >/dev/null 2>&1'
#alias vimc='vim *.[ch] Makefile *.sh'

popd >/dev/null

# Ubuntu
alias sd='sudo /bin/bash'

[ $(id -u) -eq 0 ] && {
  # console debug: show all printk's on the console
  [ `id -u` -eq 0 ] && echo -n "7 4 1 7" > /proc/sys/kernel/printk
  # better core pattern
  [ $(id -u) -eq 0 ] && {
   echo "corefile:host=%h:gPID=%P:gTID=%I:ruid=%u:sig=%s:exe=%E" > /proc/sys/kernel/core_pattern
  }
}

# Git !
alias gdiff='git diff -r'
alias gfiles='git diff --name-status -r'
alias gstat='git status ; echo ; git diff --stat -r'

###
# Some useful functions
###
function mem()
{
 echo "PID    RSS    WCHAN            NAME"
 ps -eo pid,rss,wchan:16,comm |sort -k2n
 echo
 echo "Note: 
 -Output auto-sorted by RSS (Resident Set Size)
 -RSS is expressed in kB!"
}

# dtop: useful wrapper over dstat
dtop()
{
DLY=5
echo dstat --time --top-io-adv --top-cpu --top-mem ${DLY}
 #--top-latency-avg
dstat --time --top-io-adv --top-cpu --top-mem ${DLY}
 #--top-latency-avg
}

# shortcut for git SCM;
# -to add a file(s) and then commit it with a commit msg
function gitac()
{
 [ $# -ne 2 ] && {
  echo "Usage: gitac filename \"commit-msg\""
  return
 }
 echo "git add $1 ..."
 git add $1
 echo "git commit -m ..."
 git commit -m "$2"
}

# Show thread(s) running on cpu core 'n'  - func c'n'
function c0()
{
ps -eLF |awk '{ if($5==0) print $0}'
}
function c1()
{
ps -eLF |awk '{ if($5==1) print $0}'
}
function c2()
{
ps -eLF |awk '{ if($5==2) print $0}'
}
function c3()
{
ps -eLF |awk '{ if($5==3) print $0}'
}

# end 0setup.bash
