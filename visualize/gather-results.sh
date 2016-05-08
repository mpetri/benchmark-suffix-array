
INPUT_DIR=$1
OUTPUT_FILE=$2
PREFIX=$3

echo "Gathering results for visualization."

# (1) write header
echo "testcase;index_name;input_type;text_size_bytes;index_size_bytes;total_occs;pattern_cnt;pattern_len;total_syms;time_ns" >> $OUTPUT_FILE

# (2) gather content
for f in "$INPUT_DIR/$PREFIX*.csv"
do
	cat $f >> $OUTPUT_FILE
done