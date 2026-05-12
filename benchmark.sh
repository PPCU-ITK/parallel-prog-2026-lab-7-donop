#!/bin/bash
# Benchmark ./out across scale factors on both GPU and CPU.

BINARY=./out
SCALES=(64 128)

declare -A GPU_TIMES
declare -A CPU_TIMES

extract_time() {
    grep -oP 'Total elapsed time:\s*\K[0-9]+' <<< "$1"
}

echo "=== GPU runs ==="
for s in "${SCALES[@]}"; do
    echo "scale=$s"
    out=$(srun -p gpu --gres=gpu:1 --ntasks=1 --time=00:05:00 --mem=40G "$BINARY" "$s" 2>&1)
    GPU_TIMES[$s]=$(extract_time "$out")
done

echo
echo "=== CPU runs ==="
for s in "${SCALES[@]}"; do
    echo "scale=$s"
    out=$(srun -p cpu --ntasks=1 --cpus-per-task=1 --time=00:05:00 --mem=40G "$BINARY" "$s" 2>&1)
    CPU_TIMES[$s]=$(extract_time "$out")
done

echo
echo "=== Results ==="
printf "| %-11s | %-10s | %-10s |\n" "ScaleFactor" "GPU (ms)" "CPU (ms)"
printf "|-%-11s-|-%-10s-|-%-10s-|\n" "-----------" "----------" "----------"
for s in "${SCALES[@]}"; do
    printf "| %-11s | %-10s | %-10s |\n" "$s" "${GPU_TIMES[$s]:-N/A}" "${CPU_TIMES[$s]:-N/A}"
done
