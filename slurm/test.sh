#!/bin/bash
 #SBATCH -p debug
 #SBATCH -n 1
 #SBATCH -t 12:00:00
 #SBATCH -J some_job_name
 
ls / > /home/vagrant/slurm.out
