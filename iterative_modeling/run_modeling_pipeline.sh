#!/bin/sh

ENCID=$1
MODEL_PATH=$2
SIZE_LIST=$3
TEMPLATE_JSON=$4
LOCI_FILE=$5
NEGATIVES_FILE=$6
OUTPUT_DIR=$7

ml python/3.9.0
source /oak/stanford/groups/akundaje/patelas/sherlock_venv/arsenal-bpnet/bin/activate
export ARSENAL_MODEL_DIR="/oak/stanford/groups/akundaje/patelas/regulatory_lm/"

mkdir $OUTPUT_DIR

python make_json.py $ENCID $OUTPUT_DIR/base_config.json $TEMPLATE_JSON

bash run_iterative_modeling.sh $MODEL_PATH $SIZE_LIST $OUTPUT_DIR/base_config.json $LOCI_FILE $NEGATIVES_FILE $OUTPUT_DIR
