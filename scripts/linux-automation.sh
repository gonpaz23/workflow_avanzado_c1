#!/bin/bash
# scripts/linux-automation.sh

set -e  # Exit on error
set -o pipefail

echo "=== LINUX SYSTEM AUTOMATION ==="
echo "Timestamp: $(date)"
echo "User: $(whoami)"
echo "Hostname: $(hostname)"
echo ""

# Create directories
echo "1. Creating directory structure..."
mkdir -p output logs backups

# File operations - Read/write files
echo ""
echo "2. File operations..."

# Create system info file
cat > output/system-info.txt << EOF
System Information
==================
Date: $(date)
User: $(whoami)
Hostname: $(hostname)
OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME)
Kernel: $(uname -r)
Memory: $(free -h | awk '/^Mem:/ {print $2}')
EOF

# Create CSV file
echo "id,name,value,timestamp" > output/data.csv
for i in {1..5}; do
  echo "$i,item_$i,$((RANDOM % 100)),$(date +%s)" >> output/data.csv
done

# Create JSON file
cat > output/config.json << EOF
{
  "environment": "${NODE_ENV}",
  "timestamp": "$(date -Iseconds)",
  "system": {
    "hostname": "$(hostname)",
    "user": "$(whoami)"
  }
}
EOF

echo "Files created in output/ directory"

# File permissions management (chmod)
echo ""
echo "3. Managing file permissions..."

# Create files with different permissions
echo "Public content" > output/public.txt
echo "Private content" > output/private.txt
echo "Executable script" > output/script.sh
echo "Backup data" > backups/data.bak

# Apply permissions
chmod 644 output/public.txt      # rw-r--r--
chmod 600 output/private.txt     # rw-------
chmod 755 output/script.sh       # rwxr-xr-x
chmod 400 backups/data.bak       # r--------

echo "Permissions applied:"
echo "  public.txt: $(stat -c %A output/public.txt)"
echo "  private.txt: $(stat -c %A output/private.txt)"
echo "  script.sh: $(stat -c %A output/script.sh)"
echo "  data.bak: $(stat -c %A backups/data.bak)"

# Background processes
echo ""
echo "4. Creating background processes..."

# Process 1: System monitor
(
  echo "Starting system monitor at $(date)" > logs/monitor.log
  for i in {1..3}; do
    echo "[$(date '+%H:%M:%S')] Monitor iteration $i" >> logs/monitor.log
    echo "CPU load: $(uptime | awk '{print $10 $11 $12}')" >> logs/monitor.log
    sleep 2
  done
) &
MONITOR_PID=$!

# Process 2: Data processor
(
  for i in {1..5}; do
    echo "Processing data $i at $(date)" >> logs/processor.log
    sleep 1
  done
) &
PROCESSOR_PID=$!

echo "Background processes started:"
echo "  Monitor PID: $MONITOR_PID"
echo "  Processor PID: $PROCESSOR_PID"

# Wait for processes to do some work
echo "Waiting for processes to work..."
sleep 3

# Stop background processes
kill $MONITOR_PID $PROCESSOR_PID 2>/dev/null || true
echo "Background processes stopped"

# Environment variables and secrets
echo ""
echo "5. Environment variables and secrets..."

echo "Environment variables:" > output/env-vars.txt
echo "NODE_ENV: $NODE_ENV" >> output/env-vars.txt
echo "USER: $(whoami)" >> output/env-vars.txt
echo "HOSTNAME: $(hostname)" >> output/env-vars.txt

# Handle secret (without exposing it)
if [ -n "$SECRET_MESSAGE" ]; then
  echo "Secret is configured (value hidden)" >> output/secrets.txt
  echo "Operation using secret completed" >> output/secret-operation.txt
else
  echo "No secret configured" >> output/secrets.txt
fi

echo "Environment info saved to output/env-vars.txt"

# Generate artifacts
echo ""
echo "6. Generating artifacts..."

# Create summary file
cat > output/execution-summary.md << EOF
# Linux Automation Execution Summary

## Execution Details
- Date: $(date)
- Script: linux-automation.sh
- Status: Completed successfully
- Exit Code: 0

## Files Generated
$(find output/ -type f | while read f; do
  echo "- \`$(basename "$f")\` ($(stat -c %s "$f") bytes)"
done)

## System Info
- OS: $(uname -s)
- Kernel: $(uname -r)
- Architecture: $(uname -m)

## Background Processes
- Started: 2 processes
- Duration: ~3 seconds
EOF

# List generated files
echo ""
echo "=== GENERATED FILES ==="
find output/ logs/ backups/ -type f 2>/dev/null | sort

echo ""
echo "=== LINUX AUTOMATION COMPLETED SUCCESSFULLY ==="
echo "Exit code: 0"