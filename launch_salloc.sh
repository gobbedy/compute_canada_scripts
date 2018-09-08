#!/bin/bash

set -o pipefail
me=$(basename ${0%%@@*})
full_me=${0%%@@*}
me_dir=$(dirname $(readlink -f ${0%%@@*}))

logs_dir=/home/gobbedy/projects/def-yymao/gobbedy/logs
logfile=$logs_dir/salloc_session.log
rm -f $logfile

# kill previous tmux session (if any) -- ie any session whose name is not a current job id
echo "$me: killing previous tmux sessions"
tmux kill-session -t salloc_session &> /dev/null # in case script died before rename
tmux ls -F '#{session_name}' > tmux_session_names.txt
squeue -u gobbedy -h -o '%A' > slurm_job_ids.txt
sessions_to_kill=`comm -23 tmux_session_names.txt slurm_job_ids.txt`
for session_to_kill in "${sessions_to_kill[@]}"
do
  tmux kill-session -t $session_to_kill &> /dev/null
done

#tmux kill-session -t salloc_session &> /dev/null

# Create tmux session and launch salloc job (3 hours)
#echo "$me: creating tmux session"
#tmux new-session -s salloc_session -d salloc_session -d slurm.sh --cmd salloc --time '3 hours'
# launch salloc job (3 hours)

# Create tmux session and launch salloc job (3 hours)
echo "$me: creating tmux session, launching salloc job, and waiting for job allocation"
#echo "slurm.sh --cmd salloc $@ |& tee $logfile"

# args step is a hack, but I need it to work and no time to make it proper
args=$@
tmux new-session -s salloc_session -d "slurm.sh --cmd salloc $args |& tee $logfile"

sleep 1
tail -f $logfile &

#tmux send -t salloc_session slurm.sh SPACE --cmd SPACE salloc SPACE --time SPACE \'3 hours\' ENTER
#tmux capture-pane -pt salloc_session

# wait until salloc allocation established (timeout after 2mins)
# note: could also get bashrc to dump a file with name of machine if that's more robust
salloc_machine=''
error_detected=''
timeout_counter=0
while [[ "${timeout_counter}" -lt 1800 && -z ${error_detected} ]]; do

  #salloc_machine=`tmux capture-pane -pt salloc_session | sed '/^$/d' | tail -n1 | grep -oP 'gra\d\d\d'`
  #cat $logfile
  #echo $timeout_counter
  job_id=`grep Granted $logfile | grep -oP '\d+'`
  #grep Granted $logfile | grep -oP '\d+'
  if [[ -n ${job_id} ]]; then
    tmux rename-session -t salloc_session ${job_id}
    salloc_machine=`squeue -u gobbedy | grep ${job_id} | awk '{print $12}'`
    break
  fi
  
  if [[ -n `grep "salloc: error" $logfile` ]]; then
    error_detected=1
  fi
  
  sleep 1 
  #salloc_machine=`grep -oP 'gra\d\d\d' $logfile`
  timeout_counter=$((timeout_counter+1))
done

if [[ -z "${salloc_machine}" ]]; then
  echo "$me: salloc command failed"
  exit 1
else
  # print salloc machine
  echo "$me: connected to ${salloc_machine}"
fi


# wait until salloc allocation established (timeout after 2mins)
##timestamp_file=${logs_dir}/$(date +%b%d_%H%M%S).log
##touch ${timestamp_file}
##timeout_counter=0
##while [[ ${timestamp_file} -nt ${logs_dir}/last_machine && "${timeout_counter}" -lt 180 ]]; do
##  sleep 1
##  timeout_counter=$((timeout_counter+1))
##done

##if [[ "${timeout_counter}" -eq 180 || -n ${error_detected} ]]; then
##  echo "salloc command failed"
##  exit 1
##else
##  # print salloc machine
##  echo "${salloc_machine}"
##fi