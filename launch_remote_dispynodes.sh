#!/bin/bash

set -o pipefail
me=$(basename ${0%%@@*})
full_me=${0%%@@*}
me_dir=$(dirname $(readlink -f ${0%%@@*}))

# first argument is output dir
output_dir=$1
shift 1

# remaining arguments are nodes
node_name_list=( "$@" )

for node_name in ${node_name_list[@]} ; do
  dispynode_logfile=${output_dir}/dispy/${node_name}_dispynode.log

  # -f option to make it non-blocking, important as this may otherwise make thousands of cores sit idly
  # as we wait for each ssh command to finish sequentially
  ssh -f ${node_name} "launch_dispynode.sh ${dispynode_logfile}"
done