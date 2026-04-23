#!/bin/sh
# Append timestamped JSON lines to both volume files; trim to last 50 lines (~50 min at 1/min).
set -eu
RBD_FILE="/var/www/html/rbd/events.txt"
CEPH_FILE="/var/www/html/cephfs/events.txt"
mkdir -p "$(dirname "$RBD_FILE")" "$(dirname "$CEPH_FILE")"
seq=0
# Seed so probes can succeed before first sleep.
: >>"$RBD_FILE"
: >>"$CEPH_FILE"
while true; do
  seq=$((seq + 1))
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  host=$(hostname 2>/dev/null || echo pod)
  line="{\"ts\":\"${ts}\",\"seq\":${seq},\"vol\":\"both\",\"host\":\"${host}\"}"
  printf '%s\n' "$line" >>"$RBD_FILE"
  printf '%s\n' "$line" >>"$CEPH_FILE"
  for f in "$RBD_FILE" "$CEPH_FILE"; do
    tail -n 50 "$f" >"$f.tmp" && mv -f "$f.tmp" "$f"
  done
  sleep 60
done
