#!/bin/bash
#
# push_metrics_to_graphite.sh
#
# Collects CPU, memory, disk, network and website-availability metrics and
# sends them to Graphite's Carbon plaintext receiver, so they can be
# visualised later in a Grafana dashboard.
#
# Usage:
#   ./push_metrics_to_graphite.sh
#
# Configure the variables below to match your environment.

GRAPHITE_HOST="localhost"       # Host running the graphite container
GRAPHITE_PORT="2003"            # Carbon plaintext port
METRIC_PREFIX="college_event_site"
APP_URL="http://localhost:30081/healthz"   # NodePort URL of the website (30080=nginx static site, 30081=Maven backend)
INTERVAL_SECONDS=30              # How often to push metrics

send_metric() {
  local path="$1"
  local value="$2"
  local ts
  ts=$(date +%s)
  echo "${METRIC_PREFIX}.${path} ${value} ${ts}" | nc -q0 "${GRAPHITE_HOST}" "${GRAPHITE_PORT}"
}

echo "Pushing metrics to Graphite at ${GRAPHITE_HOST}:${GRAPHITE_PORT} every ${INTERVAL_SECONDS}s. Ctrl+C to stop."

while true; do

  # ---- CPU usage (%) ----
  CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk -F',' '{print $4}' | grep -o '[0-9.]*')
  CPU_USAGE=$(awk -v idle="$CPU_IDLE" 'BEGIN {printf "%.2f", 100 - idle}')
  send_metric "system.cpu_usage_percent" "$CPU_USAGE"

  # ---- Memory usage (%) ----
  MEM_TOTAL=$(free -m | awk '/Mem:/{print $2}')
  MEM_USED=$(free -m | awk '/Mem:/{print $3}')
  MEM_PERCENT=$(awk -v used="$MEM_USED" -v total="$MEM_TOTAL" 'BEGIN {printf "%.2f", (used/total)*100}')
  send_metric "system.memory_usage_percent" "$MEM_PERCENT"

  # ---- Disk usage (%) on root partition ----
  DISK_PERCENT=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
  send_metric "system.disk_usage_percent" "$DISK_PERCENT"

  # ---- Network usage (bytes received/transmitted on default interface) ----
  IFACE=$(ip route | awk '/default/ {print $5; exit}')
  if [ -n "$IFACE" ] && [ -f "/sys/class/net/${IFACE}/statistics/rx_bytes" ]; then
    RX=$(cat "/sys/class/net/${IFACE}/statistics/rx_bytes")
    TX=$(cat "/sys/class/net/${IFACE}/statistics/tx_bytes")
    send_metric "system.network_rx_bytes" "$RX"
    send_metric "system.network_tx_bytes" "$TX"
  fi

  # ---- Uptime (seconds) ----
  UPTIME_SECONDS=$(awk '{print int($1)}' /proc/uptime)
  send_metric "system.uptime_seconds" "$UPTIME_SECONDS"

  # ---- HTTP availability of the website (1 = up, 0 = down) ----
  HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time 5 "$APP_URL")
  if [ "$HTTP_CODE" == "200" ]; then
    send_metric "app.http_availability" 1
  else
    send_metric "app.http_availability" 0
  fi

  sleep "$INTERVAL_SECONDS"
done
