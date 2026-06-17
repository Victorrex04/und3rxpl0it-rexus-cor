#!/bin/bash
# ==============================================
# REXUS NODE - COMPLETE INSTALLER (v3.2)
# Guaranteed file structure verification
# ==============================================

set -eo pipefail
trap 'echo -e "\n\033[1;31m[!] Failed at line $LINENO\033[0m"; exit 1' ERR

# OPSEC Protected Creds
GITHUB_USER="Victorrex04"
GITHUB_PAT="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"
REPO_URL="https://${GITHUB_USER}:${GITHUB_PAT}@github.com/Victorrex04/und3rxpl0it-rexus-cor.git"

# ===== 1. Verify File Structure =====
echo -e "\n\033[1;34m[1/6] VERIFYING REPO STRUCTURE\033[0m"
[ -d ~/rexus ] && {
    echo -e "\033[1;33m[!] Existing rexus directory found - backing up\033[0m"
    mv ~/rexus ~/rexus.bak.$(date +%s)
}

git clone --depth 1 --quiet "$REPO_URL" ~/rexus || {
    echo -e "\033[1;31m[!] Clone failed - check:\n1. PAT validity\n2. Repository exists\033[0m"
    exit 1
}

# Critical file check
required_files=("c2_server.py" "tools/exploit_manager.py" "config.json.template")
for file in "${required_files[@]}"; do
    if [ ! -f ~/rexus/"$file" ]; then
        echo -e "\033[1;31m[!] Missing critical file: $file\033[0m"
        echo -e "\033[1;33m[•] Check if repository contains all required files\033[0m"
        exit 1
    fi
done

# ===== 2. Install Dependencies =====
echo -e "\033[1;34m[2/6] INSTALLING DEPENDENCIES\033[0m"
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    git python3 python3-pip python3-dev \
    nmap hydra sqlmap tor proxychains4 \
    libssl-dev libffi-dev build-essential

# ===== 3. Python Environment =====
echo -e "\033[1;34m[3/6] SETTING UP PYTHON\033[0m"
cd ~/rexus
python3 -m pip install --user --upgrade pip wheel
python3 -m pip install --user \
    discord.py==2.3.2 \
    requests==2.31.0 \
    python-nmap==0.7.1 \
    scapy==2.5.0 \
    cryptography==42.0.4 \
    psutil==5.9.8

# ===== 4. Configuration =====
echo -e "\033[1;34m[4/6] CONFIGURING REXUS\033[0m"
[ ! -f ~/rexus/config.json ] && \
    cp ~/rexus/config.json.template ~/rexus/config.json

chmod +x ~/rexus/tools/*.py 2>/dev/null || true

# ===== 5. Metasploit Framework =====
echo -e "\033[1;34m[5/6] INSTALLING METASPLOIT\033[0m"
if ! command -v msfconsole &>/dev/null; then
    wget -q --show-progress \
        https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
        -O /tmp/msfinstall
    chmod +x /tmp/msfinstall
    /tmp/msfinstall > /dev/null
fi

# ===== 6. Final Checks =====
echo -e "\033[1;34m[6/6] RUNNING SANITY CHECKS\033[0m"
cd ~/rexus
python3 -c "
import discord, scapy, requests
print('\033[1;32m[✔] All Python dependencies verified\033[0m')
" || {
    echo -e "\033[1;31m[!] Python environment verification failed\033[0m"
    exit 1
}

# OPSEC Cleanup
unset GITHUB_USER GITHUB_PAT REPO_URL
history -c

# ===== SUCCESS =====
echo -e "\n\033[1;32m[✔] REXUS NODE READY\033[0m"
echo -e "\033[1;36m[•] Directory structure:\033[0m"
ls -l ~/rexus
echo -e "\n\033[1;36m[•] Start command:\033[0m cd ~/rexus && python3 c2_server.py"
