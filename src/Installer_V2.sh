#!/usr/bin/env bash

## Installer for KARAJ v2.0
## Run this to install all required dependencies.

set -e

echo
echo "=========================================================================="
echo "KARAJ v2.0 — Dependency Installer"
echo "=========================================================================="
echo

# ---- Helper: install a single apt package if not already present ----
install_apt_pkg() {
    local pkg="$1"
    local status

    status=$(dpkg-query -s "$pkg" 2>/dev/null | grep "install ok installed" || true)

    if [[ "$status" == "Status: install ok installed" ]]; then
        local version
        version=$(dpkg-query -s "$pkg" 2>/dev/null | grep "^Version:")
        echo "  [OK]   $pkg ($version)"
        return 0
    fi

    echo "  [...]  Installing $pkg..."
    sudo apt-get install -y "$pkg" >/dev/null 2>&1

    status=$(dpkg-query -s "$pkg" 2>/dev/null | grep "install ok installed" || true)
    if [[ "$status" == "Status: install ok installed" ]]; then
        echo "  [OK]   $pkg installed"
        return 0
    else
        echo "  [FAIL] $pkg installation failed — please install manually"
        return 1
    fi
}

# ---- System packages ----
echo "Checking system packages..."
echo

sudo apt-get update -qq

failed=0
for pkg in lynx ncbi-entrez-direct curl axel parallel wget bc; do
    install_apt_pkg "$pkg" || failed=1
done

echo

# ---- IBM Aspera SDK ----
echo "Checking IBM Aspera SDK..."
echo

ASCP_BIN="$HOME/.aspera/sdk/ascp"
ASCP_KEY="$HOME/.aspera/sdk/etc/asperaweb_id_dsa.openssh"

aspera_ok=0
if [[ -x "$ASCP_BIN" ]] && "$ASCP_BIN" --version 2>/dev/null | grep -Eiq "ascp version|IBM Aspera"; then
    if [[ -f "$ASCP_KEY" ]]; then
        echo "  [OK]   ascp found at $ASCP_BIN"
        echo "         $("$ASCP_BIN" --version 2>/dev/null | head -1)"
        echo "  [OK]   Aspera key found at $ASCP_KEY"
        aspera_ok=1
    else
        echo "  [FAIL] ascp found, but Aspera key missing at $ASCP_KEY"
        failed=1
    fi
else
    echo "  [FAIL] IBM Aspera SDK / ascp not found at $ASCP_BIN"
    echo
    echo "         To install IBM Aspera CLI:"
    echo "         1. Download from https://www.ibm.com/aspera/connect/"
    echo "         2. Or install via: pip install --user aspera-cli && ascli config transferd install"
    failed=1
fi

echo

# ---- NCBI API key reminder ----
echo "Checking NCBI API key..."
echo

if [[ -n "${NCBI_API_KEY:-}" ]]; then
    echo "  [OK]   NCBI_API_KEY is set"
else
    echo "  [INFO] NCBI_API_KEY is not set."
    echo "         KARAJ will work without it, but you may encounter occasional"
    echo "         'curl: (52) Empty reply from server' errors during runs."
    echo
    echo "         To fix: register a free key at https://www.ncbi.nlm.nih.gov/account/"
    echo "         Then add to ~/.bashrc:"
    echo "             export NCBI_API_KEY=\"your-key-here\""
fi

echo

# ---- Final summary ----
echo "=========================================================================="
if [[ "$failed" == "0" ]]; then
    echo "KARAJ v2.0 — All dependencies installed successfully."
else
    echo "KARAJ v2.0 — Some dependencies failed to install."
    echo "Please install the missing packages manually and re-run this installer."
fi
echo "=========================================================================="
echo
