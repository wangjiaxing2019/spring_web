#!/usr/bin/env bash
# Per-boot startup: bring MySQL up before the app terminal starts.
set -euo pipefail

sudo service mysql start
for _ in $(seq 1 30); do
  sudo mysqladmin ping >/dev/null 2>&1 && break
  sleep 1
done
