#!/bin/bash
logfile=$1
dispynode_executable=~/.local/bin/dispynode.py
echo "Note: \"error connecting\" line immediately below is expected." &>> ${logfile}
tmux kill-session -t dispynode_session &>> ${logfile} # in case previous script on same node died before killing
tmux new-session -s dispynode_session -d "${dispynode_executable} --clean --daemon |& tee -a ${logfile}"