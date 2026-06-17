#!/bin/bash
# ==============================================
# REXUS NODE - OFFICIAL INSTALLER (v2.3.1)
# Tested on: GitHub Codespaces, Ubuntu 22.04
# Last verified: 2024-03-15
# ==============================================

# Exit immediately on error
set -e

# Header
echo -e "\n\033[1;34mREXUS NODE INSTALLATION\033[0m"
echo -e "\033[1;36mAuthor: Und3rxpl0it\033[0m"
echo -e "\033[1;36mOS: $(lsb_release -ds)\033[0m\n"

# ===== 1. Dependency Installation =====
echo -e "\033[1;32m[1/5] Installing base dependencies...\033[0m"
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    git python3 python3-pip python3-dev \
    nmap hydra sqlmap tor proxychains4 \
    libssl-dev libffi-dev build-essential

# ===== 2. Metasploit Framework =====
echo -e "\033[1;32m[2/5] Installing Metasploit...\033[0m"
wget -q https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -O /tmp/msfinstall
chmod +x /tmp/msfinstall
/tmp/msfinstall > /dev/null

# ===== 3. REXUS Core =====
echo -e "\033[1;32m[3/5] Downloading REXUS core...\033[0m"
if [ -d ~/rexus ]; then
    echo -e "\033[1;33m[!] Existing installation found. Updating...\033[0m"
    cd ~/rexus && git pull --quiet
else
    git clone --depth 1 https://github.com/Victorrex04/und3rxpl0it-rexus-core.git ~/rexus
fi

# ===== 4. Python Environment =====
echo -e "\033[1;32m[4/5] Setting up Python environment...\033[0m"
cd ~/rexus
python3 -m pip install --user --upgrade pip wheel
python3 -m pip install --user -r requirements.txt

# ===== 5. Configuration =====
echo -e "\033[1;32m[5/5] Finalizing installation...\033[0m"
chmod +x ~/rexus/tools/*.py

# ===== Completion =====
echo -e "\n\033[1;32m[+] Installation successful!\033[0m"
echo -e "\033[1;36m[•] Metasploit Version: $(msfconsole --version)\033[0m"
echo -e "\033[1;36m[•] Python Version: $(python3 --version)\033[0m"
echo -e "\033[1;36m[•] Installed in: ~/rexus\033[0m\n"

echo -e "\033[1;33m[!] To start REXUS:\033[0m"
echo -e "1. cd ~/rexus"
echo -e "2. python3 c2_server.py\n"

# Cleanup
unset HISTFILE
history -c