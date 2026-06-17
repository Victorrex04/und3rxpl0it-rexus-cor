#!/bin/bash
# ==============================================
# REXUS NODE - ERROR-PROOF INSTALLER (v3.1)
# Tested on: Codespaces, Ubuntu 22.04, Kali 2023
# ==============================================

set -eo pipefail
trap 'echo -e "\n\033[1;31m[!] Failed at line $LINENO\033[0m"; exit 1' ERR

# OPSEC Protected Creds
GITHUB_USER="Victorrex04"
GITHUB_PAT="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"
REPO_URL="https://${GITHUB_USER}:${GITHUB_PAT}@github.com/Victorrex04/und3rxpl0it-rexus-cor.git"

# ===== 1. System Preparation =====
echo -e "\n\033[1;34m[1/6] SYSTEM PREP\033[0m"
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    git python3 python3-pip python3-dev \
    nmap hydra sqlmap tor proxychains4 \
    libssl-dev libffi-dev build-essential \
    || echo -e "\033[1;33m[!] Non-critical package failed\033[0m"

# ===== 2. Repository Clone =====
echo -e "\033[1;34m[2/6] CLONING REPO\033[0m"
[ -d ~/rexus ] && mv ~/rexus ~/rexus.bak.$(date +%s)
git clone --depth 1 --quiet "$REPO_URL" ~/rexus || {
    echo -e "\033[1;31m[!] Clone failed - check:\n1. PAT validity\n2. Repository exists\n3. Network access\033[0m"
    exit 1
}

# ===== 3. Metasploit Framework =====
echo -e "\033[1;34m[3/6] METASPLOIT INSTALL\033[0m"
if ! command -v msfconsole &>/dev/null; then
    wget -q --show-progress https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -O /tmp/msfinstall
    chmod +x /tmp/msfinstall
    /tmp/msfinstall > /dev/null || echo -e "\033[1;33m[!] Metasploit install warning (may need manual fix)\033[0m"
fi

# ===== 4. Python Environment =====
echo -e "\033[1;34m[4/6] PYTHON SETUP\033[0m"
cd ~/rexus
python3 -m pip install --user --upgrade pip wheel || {
    echo -e "\033[1;31m[!] Pip upgrade failed - trying alternate method\033[0m"
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3 -
}

# Critical packages (installed individually for fault tolerance)
for pkg in discord.py==2.3.2 requests==2.31.0 python-nmap==0.7.1 scapy==2.5.0 cryptography==42.0.4 psutil==5.9.8; do
    pip install --user "$pkg" || echo -e "\033[1;33m[!] Failed to install $pkg - may affect functionality\033[0m"
done

# ===== 5. Post-Install =====
echo -e "\033[1;34m[5/6] CONFIGURATION\033[0m"
find ~/rexus/tools -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
sudo rm -f /tmp/msfinstall

# ===== 6. OPSEC Cleanup =====
echo -e "\033[1;34m[6/6] OPSEC CLEANUP\033[0m"
unset GITHUB_USER GITHUB_PAT REPO_URL
history -c
find ~ -name ".*_history" -exec rm -f {} \; 2>/dev/null || true

# ===== SUCCESS =====
echo -e "\n\033[1;32m[✔] REXUS NODE READY\033[0m"
echo -e "\033[1;36m[•] Start: cd ~/rexus && python3 c2_server.py\033[0m"
echo -e "\033[1;36m[•] Test: !scan 8.8.8.8 in Discord\033[0m\n"
