#!/bin/bash

# ===== REXUS NODE INSTALLER =====
# Author: Und3rxpl0it
# Description: Fully automated deployment of REXUS NODE (AI-driven offensive security system)

# Exit on error
set -e

# OPSEC checks
if [ "$(whoami)" == "root" ]; then
    echo "[!] Never run as root! Use sudo only when required."
    exit 1
fi

# ===== 1. Install Dependencies =====
echo "[*] Installing dependencies..."
sudo apt update && sudo apt install -y \
    git python3 python3-pip nmap metasploit-framework \
    hydra sqlmap tor proxychains4 libssl-dev

# ===== 2. Clone REXUS Core =====
echo "[*] Downloading REXUS core..."
git clone https://github.com/und3rxpl0it/rexus-core.git ~/rexus
cd ~/rexus

# ===== 3. Python Requirements =====
echo "[*] Installing Python modules..."
pip3 install -r requirements.txt --user

# ===== 4. Configure Discord C2 =====
read -p "[?] Enter Discord Bot Token: " token
cat > ~/rexus/config.json <<EOF
{
    "discord_token": "$token",
    "command_prefix": "!",
    "admin_ids": []
}
EOF

# ===== 5. Install Exploit Database =====
echo "[*] Loading exploit database..."
sudo mkdir -p /usr/share/exploitdb
sudo git clone https://gitlab.com/exploit-database/exploitdb.git /usr/share/exploitdb
sudo ln -sf /usr/share/exploitdb/searchsploit /usr/local/bin/searchsploit

# ===== 6. Build Persistence =====
echo "[*] Creating systemd service..."
sudo tee /etc/systemd/system/rexus.service > /dev/null <<EOF
[Unit]
Description=REXUS Node
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=$HOME/rexus
ExecStart=/usr/bin/python3 $HOME/rexus/c2_server.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable rexus.service
sudo systemctl start rexus.service

# ===== 7. OPSEC Hardening =====
echo "[*] Applying OPSEC rules..."
sudo apt purge -y snapd ubuntu-standard  # Remove telemetry
sudo ufw deny outgoing 25,53  # Block DNS leaks

# ===== 8. Complete =====
echo -e "\n[+] REXUS NODE installed successfully!"
echo "[+] Connect via Discord with prefix: !"
echo "[+] Running on: $(curl -s ifconfig.me)"
echo "[!] Always use Tor: 'proxychains rexus-ctl'"

# Cleanup
history -c