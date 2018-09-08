#!/bin/bash

# process args
error=$1
slurm_job_name=$2
slurm_job_id=$3
output_dir=$4

# setup variables
mailx_executable="/usr/bin/mailx"
email_file=${output_dir}/summary.html

# create summary e-mail
#echo "<html><b><font size='7'>Log directory: ${output_dir}</b></html><br>" > ${email_file}
#echo "<html><b><font size='7'></font>SLURM Job ID: ${slurm_job_id}</b></html><br>" >> ${email_file}
echo "<html><b>Log directory: ${output_dir}</b></html><br>" > ${email_file}
echo "<html><b>SLURM Job ID: ${slurm_job_id}</b></html><br>" >> ${email_file}


# create subject
if [[ ${error} -eq 0 ]]; then
  subject="Simulation Ended: ${slurm_job_name}"
else
  subject="Simulation INTERRUPTED: ${slurm_job_name}"
fi

# e-mail user
cat ${email_file} | ${mailx_executable} -s "$(echo -e "${subject}\nContent-Type: text/html")" ${EMAIL}