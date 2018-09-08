#!/bin/bash
set -o pipefail
me=$(basename ${0%%@@*})
full_me=${0%%@@*}
me_dir=$(dirname $(readlink -f ${0%%@@*}))

######################################################################
# Helper functions
######################################################################

function showHelp {

echo "NAME

  $me -
     1) Runs slurm job using srun
     2) Uses CPU or GPU options defined in project.rc as SRUN_OPTIONS_CPU or SRUN_OPTIONS_GPU

SYNOPSIS

  $me [OPTIONS] [--num_cpus|--num_gpus|--job_name|--time] [script_name]

DESCRIPTION

  -h, --help
                          Show this description
  -a, --mail
                          Send user e-mail when job starts and ends (right now hardcoded to gperr050@uottawa.ca)

  -c, --num_cpus
                          Number of CPUs to be allocated to the job. Default 1.

  --cmd, --command
                          The SLURM command to use: salloc, srun or sbatch. Default is srun.
                          If salloc, not script_name must not be provided.
                          If srun or sbatch, script_name must be provide.

  -e, --export
                          Which SLURM command (salloc, srun, sbatch) to use. Default salloc.

  -g, --num_gpus
                          Number of GPUs to be allocated to the job. Default 0.

  -j, --job_name
                          Name of job to be displayed in SLURM queue.

  -m, --mem
                          Amount of memory (eg 500m, 7g). Default 256m.

  -n, --nodes
                          Number of compute nodes.

  -o, --output
                          Logfile name.

  -s, --test
                          Run slurm command in test mode. Command that *would* be run is printed
                          but job is not actually scheduled.
                          Can be used to test the launch scripts themselves.

  -t, --time
                          Time allocated to the job: As of July 2018, admin max is 3 hours. The job will be interrupted
                          if the script is still running.


"
}

function die {
  printf "${me}: %b\n" "$@" >&2
  exit 1
}

time="00:01:00"
job_name=portfolio
num_cpus=1
num_gpus=0
mem=256m
slurm_command=srun
mail=''
slurm_test_mode=''

while [[ "$1" == -* ]]; do
  case "$1" in
    -h|--help)
      showHelp
      exit 0
    ;;
	-a|--mail)
	  mail=yes
	  shift 1
	;;
    -c|--num_cpus)
      num_cpus=$2
      shift 2
    ;;
    --cmd|--command)
      slurm_command=$2
      shift 2
    ;;
    -e|--export)
      export=$2
      shift 2
    ;;
    -g|--num_gpus)
      num_gpus=$2
      shift 2
    ;;
    -j|--job_name)
      job_name=$2
      shift 2
    ;;
	-m|--mem)
	  mem=$2
	  shift 2
	;;
    -n|--nodes)
      num_nodes=$2
      shift 2
    ;;
    -o|--output)
      logfile=$2
      shift 2
    ;;
    -s|--test)
      slurm_test_mode=yes
      shift 1
    ;;
    -t|--time)
      # for now, looks like max duration is 3hours
      time=`date -d "Dec 31 + $2"  "+%j-%H:%M:%S" |& sed 's/^365-//'`
	  if [[ $? -ne 0 ]]; then
	    # date command doesn't like the format given, we assume it's a format that slurm understands directly
		time=$2
	  fi
      shift 2
    ;;
    -*)
      die "Invalid option $1"
    ;;
  esac
done

if [[ -z ${num_nodes} ]]; then
  num_nodes=$((( ($2-1) / 48) + 1 ))
fi
  
if [[ -z ${logfile} ]]; then
  logfile=${job_name}.log
fi

if [[ "${slurm_command}" == "salloc" ]]; then
  if [[ $# -ne 0 ]]; then
    >&2 echo "$me: ERROR: salloc command does not require a script to be run"
    exit 1
  fi
else
  if [[ $# -ne 1 ]]; then
    >&2 echo "$me: ERROR: require exactly 1 script to run"
    exit 1
  fi
  script_name=$1
fi

slurm_options="--time=${time} --job-name=${job_name} --mem=${mem} --ntasks=${num_cpus} --nodes=${num_nodes}"
slurm_options+=" --output=${logfile} --open-mode=append"

if [[ -n ${mail} ]]; then
  #slurm_options+=" --mail-type=BEGIN --mail-type=END --mail-type=REQUEUE --mail-user=gperr050@uottawa.ca"
  slurm_options+=" --mail-type=BEGIN --mail-type=REQUEUE --mail-user=${EMAIL} --signal=USR1@5"
  export+=",mail=yes"
fi

if [[ -n ${slurm_test_mode} ]]; then
  slurm_options+=" --test-only"
fi

if [[ ${num_gpus} -gt 0 ]]; then
  slurm_options+=" --gres=gpu:${num_gpus}"
fi

if [[ ${slurm_command} == "salloc" ]]; then
  slurm_run_command="${slurm_command} ${slurm_options}"
else
  slurm_run_command="${slurm_command} ${slurm_options} --export=${export} ${script_name}"
fi

echo "${me}: SUBMITTING THE FOLLOWING SLURM COMMAND on `date`:"
echo  ${slurm_run_command}
echo ""

echo "${me}: SLURM SUBMISSION OUTPUT:"
eval ${slurm_run_command}

if [[ ${slurm_command} == "salloc" ]]; then
  echo "SLURM JOB ENDED ON `date`"
fi