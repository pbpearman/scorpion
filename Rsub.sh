#!/bin/sh

#$ -N scorp
#$ -S /bin/bash

#$ -cwd
#$ -j y

#$ -t 1-1:1

echo $SGE_TASK_ID

time R --vanilla --quiet --args $SGE_TASK_ID < prediction_on_miroc_data.r > scorp_predict_models$SGE_TASK_ID.log

