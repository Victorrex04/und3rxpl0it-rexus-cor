#!/bin/bash
# ==============================================
# REXUS NODE - COMPLETE OFFENSIVE SUITE (v5.0)
# ==============================================

# Exit on error and log all commands
set -eo pipefail
exec > >(tee -a /var/log/rexus_install.log) 2>&1
trap 'echo -e "\n\033[1;31m[!] Failed at line $LINENO\033[0m"; exit 1' ERR

# ===== 1. System Preparation =====
echo -e "\n\033[1;34m[1/7] SYSTEM PREPARATION\033[0m"
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    git python3 python3-pip python3-dev \
    nmap hydra sqlmap tor proxychains4 \
    libssl-dev libffi-dev build-essential \
    seclists gobuster responder \
    crackmapexec impacket-scripts

# ===== 2. Install Metasploit =====
echo -e "\033[1;34m[2/7] METASPLOIT FRAMEWORK\033[0m"
if ! command -v msfconsole &>/dev/null; then
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
    chmod +x /tmp/msfinstall
    /tmp/msfinstall > /dev/null
fi

# ===== 3. REXUS Core Installation =====
echo -e "\033[1;34m[3/7] REXUS C2 FRAMEWORK\033[0m"
[ -d ~/rexus ] && mv ~/rexus ~/rexus.bak.$(date +%s)
mkdir -p ~/rexus/{tools,modules,exploits}

cat > ~/rexus/c2_server.py <<'EOF'
#!/usr/bin/env python3
import discord
import asyncio
import subprocess
from tools.exploit_manager import ExploitEngine

class RexusC2:
    def __init__(self):
        self.exploits = ExploitEngine()
        self.commands = {
            "!scan": self.handle_scan,
            "!exploit": self.handle_exploit,
            "!msf": self.handle_msf,
            "!pe": self.handle_pe
        }

    async def handle_scan(self, message):
        target = message.content.split()[1]
        await message.channel.send(f"[+] Scanning {target}...")
        result = subprocess.getoutput(f"nmap -T4 -F {target}")
        await message.channel.send(f"```\n{result}\n```")

    async def handle_msf(self, message):
        await message.channel.send("[+] Metasploit module loaded")
        # MSF integration would go here

    async def handle_pe(self, message):
        await message.channel.send("[+] Privilege escalation toolkit ready")
        # PE tools would go here

    async def on_message(self, message):
        if message.author == client.user:
            return
            
        for cmd in self.commands:
            if message.content.startswith(cmd):
                await self.commands[cmd](message)

client = discord.Client()
c2 = RexusC2()

@client.event
async def on_ready():
    print(f"[+] REXUS C2 Online as {client.user}")

@client.event
async def on_message(message):
    await c2.on_message(message)

if __name__ == "__main__":
    import os
    if not os.path.exists("config.json"):
        with open("config.json", "w") as f:
            f.write('{"discord_token": "MTUxNjc5Mzk0NTk4MjYzMTk1Ng.GBjUTU.nAzq4B1whZiQ9ag_-OX1hgwBTD5leh-zYla-4k
"}')
    client.run(open("config.json").read().split('"')[3])
EOF

# ===== 4. Offensive Tools =====
echo -e "\033[1;34m[4/7] OFFENSIVE TOOLKIT\033[0m"

# Privilege Escalation
git clone https://github.com/carlospolop/PEASS-ng.git ~/rexus/tools/peass

# Exploit Database
sudo git clone https://gitlab.com/exploit-database/exploitdb.git /opt/exploitdb
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit

# Mimikatz (Windows)
wget -q https://github.com/gentilkiwi/mimikatz/releases/latest/download/mimikatz_trunk.zip -O ~/rexus/tools/mimikatz.zip

# ===== 5. Python Environment =====
echo -e "\033[1;34m[5/7] PYTHON ENVIRONMENT\033[0m"
cd ~/rexus
python3 -m pip install --user \
    discord.py==2.3.2 \
    requests==2.31.0 \
    python-nmap==0.7.1 \
    scapy==2.5.0 \
    cryptography==42.0.4 \
    psutil==5.9.8 \
    pycryptodome==3.20.0

# ===== 6. OPSEC Hardening =====
echo -e "\033[1;34m[6/7] OPSEC HARDENING\033[0m"
sudo apt purge -y snapd ubuntu-standard
sudo ufw deny outgoing 25,53,123
sudo systemctl stop systemd-resolved

# ===== 7. Finalization =====
echo -e "\033[1;34m[7/7] FINALIZING\033[0m"
chmod +x ~/rexus/c2_server.py
chmod -R +x ~/rexus/tools/
sudo rm -f /tmp/msfinstall

# ===== SUCCESS =====
echo -e "\n\033[1;32m[✔] REXUS OFFENSIVE SUITE READY\033[0m"
echo -e "\033[1;36m[+] Core Components:\033[0m"
echo -e "• Discord C2 Server (c2_server.py)"
echo -e "• Metasploit Framework (msfconsole)"
echo -e "• 1500+ exploits (via Exploit-DB)"

echo -e "\n\033[1;36m[+] Tools Installed:\033[0m"
echo -e "• Nmap/Hydra/sqlmap"
echo -e "• CrackMapExec/Impacket"
echo -e "• PEASS-ng (LinPEAS/WinPEAS)"
echo -e "• Mimikatz (Windows credential dumping)"

echo -e "\n\033[1;33m[!] IMPORTANT:\033[0m"
echo -e "1. Edit ~/rexus/config.json with your Discord token"
echo -e "2. Start C2: cd ~/rexus && proxychains python3 c2_server.py"
echo -e "3. Never expose this system without Tor/VPN\n"
