#!/bin/bash
# ─────────────────────────────────────────────
# healthcheck.sh – Check Nginx and Node Exporter health
# Usage: ./scripts/healthcheck.sh
# ─────────────────────────────────────────────
set -euo pipefail

PASS=0
FAIL=0

check() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  [OK]  $name"
    PASS=$((PASS+1))
  else
    echo "  [FAIL] $name"
    FAIL=$((FAIL+1))
  fi
}

echo "=============================="
echo " Health Check – $(date)"
echo "=============================="

check "Nginx service running"        "systemctl is-active --quiet nginx"
check "HTTP /health endpoint"        "curl -sf http://localhost/health"
check "HTTP index page"              "curl -sf http://localhost"
check "Node Exporter service"        "systemctl is-active --quiet node_exporter"
check "Node Exporter metrics"        "curl -sf http://localhost:9100/metrics"
check "Disk space < 85%"             "[ \$(df / | awk 'NR==2{print \$5}' | tr -d '%') -lt 85 ]"
check "Memory available"             "free -m | awk '/^Mem:/{exit (\$7 < 100)}'"

echo "=============================="
echo " Passed: $PASS | Failed: $FAIL"
echo "=============================="

[ "$FAIL" -eq 0 ]
