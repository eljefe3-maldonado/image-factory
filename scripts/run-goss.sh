#!/usr/bin/env bash
set -euo pipefail

# Expect goss.yaml placed at /tmp/goss.yaml
goss -g /tmp/goss.yaml validate
