#!/bin/bash
# demo.sh
# Author: nirgeier@gmail.com
# Description: Main demo script for Docker Security & Trust lab

echo "=== Docker Security & Trust Lab Demos ==="
echo ""
echo "This lab has been split into individual demos for each security topic:"
echo ""
echo "1. demo1-nonroot.sh      - Non-root user execution"
echo "2. demo2-capabilities.sh - Linux capabilities management"
echo "3. demo3-security-options.sh - Security options (no-new-privileges)"
echo "4. demo4-mac.sh          - Mandatory Access Control (Seccomp/AppArmor)"
echo "5. demo5-userns.sh       - User Namespace Remapping"
echo ""
echo "demo-all.sh              - All demos in one script (original)"
echo ""
echo "To run a specific demo:"
echo "chmod +x demo1-nonroot.sh"
echo "./demo1-nonroot.sh"
echo ""
echo "Each demo is self-contained with cleanup."