#!/bin/sh

ENCID=$1
MODEL_PATH=$2
SIZE_LIST=$3
TEMPLATE_JSON=$4
LOCI_FILE=$5
NEGATIVES_FILE=$6
OUTPUT_DIR=$7

export ARSENAL_MODEL_DIR="/oak/stanford/groups/akundaje/patelas/regulatory_lm/"

sbatch --export=ALL --requeue \
    -J $ENCID \
    -p akundaje,gpu,owners -t 36:00:00 \
    -G 1 -C "GPU_MEM:80GB|GPU_SKU:A100_PCIE|GPU_SKU:A100_SXM4|GPU_SKU:L40S" \
    --mem=80G \
    -o $OUTPUT_DIR/log.o \
    -e $OUTPUT_DIR/log.e \
    run_modeling_pipeline.sh $ENCID $MODEL_PATH $SIZE_LIST $TEMPLATE_JSON $LOCI_FILE $NEGATIVES_FILE $OUTPUT_DIR


