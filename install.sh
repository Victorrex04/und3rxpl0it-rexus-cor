#!/bin/bash
# ==============================================
# REXUS NODE - SECURE INSTALLER (PAT PROTECTED)
# OPSEC SAFE: Token masked in logs and memory
# ==============================================

set -e
trap 'echo -e "\n\033[1;31m[!] Installation failed.\033[0m"; exit 1' ERR

# PRIVATE AUTH (will not echo or log)
GITHUB_USER="Victorrex04"  # << YOUR USERNAME
GITHUB_PAT="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"  # << YOUR TOKEN

echo -e "\n\033[1;34mREXUS NODE INSTALLATION\033[0m"
echo -e "\033[1;36mOS: $(lsb_release -ds)\033[0m\n"

# ===== 1. Dependencies =====
echo -e "\033[1;32m[1/5] Installing tools...\033[0m"
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    git python3 python3-pip python3-dev \
    nmap hydra sqlmap tor proxychains4

# ===== 2. Clone REPO (Auth) =====
echo -e "\033[1;32m[2/5] Cloning REXUS (secure)...\033[0m"
git clone --quiet --depth 1 \
    "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/Victorrex04/und3rxpl0it-rexus-cor.git" \
    ~/rexus || { echo -e "\033[1;31m[!] Bad PAT/repo access.\033[0m"; exit 1; }

# ===== 3. Metasploit =====
echo -e "\033[1;32m[3/5] Installing Metasploit...\033[0m"
wget -q https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -O /tmp/msfinstall
chmod +x /tmp/msfinstall
/tmp/msfinstall > /dev/null

# ===== 4. Python Setup =====
echo -e "\033[1;32m[4/5] Configuring Python...\033[0m"
cd ~/rexus
pip3 install --user -r requirements.txt

# ===== 5. Cleanup =====
echo -e "\033[1;32m[5/5] Finalizing...\033[0m"
chmod +x ~/rexus/tools/*.py
rm -f /tmp/msfinstall

# OPSEC: Wipe credentials
unset GITHUB_USER GITHUB_PAT
history -c

echo -e "\n\033[1;32m[+] REXUS installed! Run:\033[0m"
echo -e "cd ~/rexus && python3 c2_server.py\n"
