#!/bin/bash

# Parse input arguments
MODEL_PATH=$1
SIZE_LIST=$2
CONFIG_JSON=$3
LOCI_FILE=$4
NEGATIVES_FILE=$5
OUTPUT_DIR=$6

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to sample lines from a file
sample_file() {
    local input_file=$1
    local output_file=$2
    local num_lines=$3

    if [[ "$input_file" == *.gz ]]; then
        # If the file is gzipped, decompress and sample
        zcat "$input_file" | shuf -n "$num_lines" > "$output_file"
    else
        # If the file is not gzipped, sample directly
        shuf -n "$num_lines" "$input_file" > "$output_file"
    fi
}


# Create subdirectories for the original arsenal and bpnet models
ORIGINAL_ARSENAL_DIR="$OUTPUT_DIR/original_arsenal"
ORIGINAL_BPNET_DIR="$OUTPUT_DIR/original_bpnet"
mkdir -p "$ORIGINAL_ARSENAL_DIR"
mkdir -p "$ORIGINAL_BPNET_DIR"

# Copy and unzip the original loci file to both directories
if [[ "$LOCI_FILE" == *.gz ]]; then
    zcat "$LOCI_FILE" > "$ORIGINAL_ARSENAL_DIR/loci.txt"
    zcat "$LOCI_FILE" > "$ORIGINAL_BPNET_DIR/loci.txt"
else
    cp "$LOCI_FILE" "$ORIGINAL_ARSENAL_DIR/loci.txt"
    cp "$LOCI_FILE" "$ORIGINAL_BPNET_DIR/loci.txt"
fi

# Copy and unzip the original negatives file to both directories
if [[ "$NEGATIVES_FILE" == *.gz ]]; then
    zcat "$NEGATIVES_FILE" > "$ORIGINAL_ARSENAL_DIR/negatives.txt"
    zcat "$NEGATIVES_FILE" > "$ORIGINAL_BPNET_DIR/negatives.txt"
else
    cp "$NEGATIVES_FILE" "$ORIGINAL_ARSENAL_DIR/negatives.txt"
    cp "$NEGATIVES_FILE" "$ORIGINAL_BPNET_DIR/negatives.txt"
fi

# Count the total number of lines in the original loci file
if [[ "$LOCI_FILE" == *.gz ]]; then
    TOTAL_LOCI_LINES=$(zcat "$LOCI_FILE" | wc -l)
else
    TOTAL_LOCI_LINES=$(wc -l < "$LOCI_FILE")
fi

# Run bpnet fit-arsenal for the original files from the arsenal directory
echo "Running bpnet fit-arsenal for the original files..."
cd "$ORIGINAL_ARSENAL_DIR"
bpnet fit-arsenal -p "$CONFIG_JSON" -a "$MODEL_PATH" -l "loci.txt" -n "negatives.txt"

# Train a bpnet model on the original data in the bpnet directory
echo "Training bpnet model on the original data..."
cd "$ORIGINAL_BPNET_DIR"
bpnet fit -p "$CONFIG_JSON" -l "loci.txt" -n "negatives.txt"

# Process each size in the size list
IFS=',' read -ra SIZES <<< "$SIZE_LIST"
for SIZE_PERCENT in "${SIZES[@]}"; do
    echo "Processing size percentage: $SIZE_PERCENT%"

    # Calculate the number of loci and negatives to sample
    NUM_LOCI=$(echo "$TOTAL_LOCI_LINES * $SIZE_PERCENT / 100" | bc)
    NUM_NEGATIVES=$((NUM_LOCI * 4))

    # Create a subdirectory for this size's arsenal output
    ARSENAL_DIR="$OUTPUT_DIR/arsenal_size_${SIZE_PERCENT}"
    mkdir -p "$ARSENAL_DIR"

    # Generate new loci and negatives files
    NEW_LOCI_FILE="$ARSENAL_DIR/loci_sampled.txt"
    NEW_NEGATIVES_FILE="$ARSENAL_DIR/negatives_sampled.txt"

    sample_file "$LOCI_FILE" "$NEW_LOCI_FILE" "$NUM_LOCI"
    sample_file "$NEGATIVES_FILE" "$NEW_NEGATIVES_FILE" "$NUM_NEGATIVES"

    # Run bpnet fit-arsenal for the sampled files from the arsenal directory
    echo "Running bpnet fit-arsenal for size $SIZE_PERCENT%..."
    cd "$ARSENAL_DIR"
    bpnet fit-arsenal -p "$CONFIG_JSON" -a "$MODEL_PATH" -l "loci_sampled.txt" -n "negatives_sampled.txt"

    # Create a subdirectory for this size's bpnet output
    BPNET_DIR="$OUTPUT_DIR/bpnet_size_${SIZE_PERCENT}"
    mkdir -p "$BPNET_DIR"

    # Run bpnet fit for the sampled files from the bpnet directory
    echo "Running bpnet fit for size $SIZE_PERCENT%..."
    cd "$BPNET_DIR"
    bpnet fit -p "$CONFIG_JSON" -l "$NEW_LOCI_FILE" -n "$NEW_NEGATIVES_FILE"
done

echo "All tasks completed."