#!/usr/bin/env bash
set -euo pipefail

GOSS_VERSION="v0.4.6"
ARCH="amd64"

curl -fsSL "https://github.com/goss-org/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCH}" -o /usr/local/bin/goss
chmod +x /usr/local/bin/goss
