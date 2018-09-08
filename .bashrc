# .bashrc

logs_dir=/home/gobbedy/projects/def-yymao/gobbedy/logs

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# load the compute canada modules I need
module load python/3.6.3

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
# add current directory to path
PATH=.:/home/gobbedy/projects/def-yymao/gobbedy/scripts:$PATH

#### Shell
export HISTSIZE=10000

# get rid of the git pager
export GIT_PAGER="cut -c 1-${COLUMNS-80}"

# don't write byte code orelse get funky behavior sometimes
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

CURRENT_PROJ=/home/gobbedy/projects/def-yymao/gobbedy/thesis-scratch/portfolio
export EMAIL=gperr050@uottawa.ca

if [[ $- == *i* ]]; then
# only for interactive shells

  # only one tab for autocomplete list
  bind "set show-all-if-ambiguous on"

  bind "set bell-style none"

  # get search backward to work with up arrow key and search forward to work with down arrow key
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
  bind '"\eOA": history-search-backward'
  bind '"\eOB": history-search-forward'
fi

 
#machine_name=`hostname | sed 's/\..*//g'`
#echo $machine_name > $logs_dir/last_machine.log
  
#### Prompt
#START_COLOR_RED="\\[\e[0;31m\\]"
#START_COLOR_GREEN="\\[\e[0;32m\\]"
#START_COLOR_BLUE="\\[\e[0;34m\\]"
#END_COLOR="\\[\e[m\\]"

export PS1="\[\033[01;31m\]\u@\h\[\033[01;32m\] \w \[\033[00m\]\$ "


function diff ()
{
  if [[ $# -eq 2 ]]; then
    tkdiff "$@" &
  else
    gdiff "$@"
  fi
}

function n () 
{ 
  nedit -xrm '*font: -*-dina-medium-r-*-*-16-*-*-*-*-*-*-*' "$@" &
}

# GIT ALIASES BEGIN HERE

function g () 
{ 
  git "$@"
}

function gn () 
{ 
  git_nedit.sh "$@"
}

function gdif () 
{ 
  gdiff "$@"
}

function glsh () 
{ 
  g lsh "$@"
}

function lsh ()
{
  glsh "$@"
}

function gadd () 
{ 
  g add "$@"
}

function add () 
{ 
  gadd "$@"
}

function commit () 
{ 
  g commit "$@"
}

function gci () 
{ 
  commit "$@"
}

function ci () 
{ 
  commit "$@"
}

function gstatus () 
{ 
  g status "$@"
}

function status () 
{ 
  gstatus "$@"
}

# GIT ALIASES END HERE

function ll ()
{
  ls -l "$@" & 
}

function rr ()
{
  rm -rf "$@" & 
}

function close ()
{
  pkill -3 "$@"
}

function lst ()
{
  ls -lt "$@"
}

function mann ()
{
  man "$@" > ~/tmp_nedit_man_page_remove_after; nedit ~/tmp_nedit_man_page_remove_after; rm ~/tmp_nedit_man_page_remove_after
}

function proj ()
{
  cd $CURRENT_PROJ
}

function cdh ()
{
  cd /home/gobbedy
}

