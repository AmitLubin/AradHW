#!/bin/bash

# Output file
OUTPUT_FILE="net_stats.json"

# Duration for sampling (seconds)
DURATION=10

# Get only physical interfaces (skip lo, docker*, veth, etc.)
get_physical_interfaces() {
    ls /sys/class/net | grep -E '^(eth|enp|eno|ens)' | grep -vE 'virtual'
}

# Capture RX/TX bytes at a point in time
get_bytes() {
  local iface=$1
    cat /sys/class/net/$iface/statistics/rx_bytes
    cat /sys/class/net/$iface/statistics/tx_bytes
}

# Initialize
declare -A RX_START
declare -A TX_START
declare -A RX_END
declare -A TX_END

# Get physical interfaces
INTERFACES=($(get_physical_interfaces))

# Collect starting values
for iface in "${INTERFACES[@]}"; do
    RX_START[$iface]=$(cat /sys/class/net/$iface/statistics/rx_bytes)
    TX_START[$iface]=$(cat /sys/class/net/$iface/statistics/tx_bytes)
done

# Wait for sampling duration
sleep $DURATION

# Collect ending values
for iface in "${INTERFACES[@]}"; do
    RX_END[$iface]=$(cat /sys/class/net/$iface/statistics/rx_bytes)
    TX_END[$iface]=$(cat /sys/class/net/$iface/statistics/tx_bytes)
done

# Build JSON
echo '{"stats": [' > "$OUTPUT_FILE"
for iface in "${INTERFACES[@]}"; do
    RX_DIFF=$(( (${RX_END[$iface]} - ${RX_START[$iface]}) / DURATION ))
    TX_DIFF=$(( (${TX_END[$iface]} - ${TX_START[$iface]}) / DURATION ))

    echo "  {" >> "$OUTPUT_FILE"
    echo "    \"interface\": \"$iface\"," >> "$OUTPUT_FILE"
    echo "    \"rx_bytes_per_sec\": $RX_DIFF," >> "$OUTPUT_FILE"
    echo "    \"tx_bytes_per_sec\": $TX_DIFF" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
done

# Remove trailing comma from last object
sed -i '$ s/},/}/' "$OUTPUT_FILE"

# Close JSON array and object
echo "]}" >> "$OUTPUT_FILE"

echo "Network statistics written to $OUTPUT_FILE"

aws s3 cp net_stats.json s3://imtech-amit-shimi-hagever/