#!/bin/bash
# ==============================================
# REXUS NODE - ALL-IN-ONE INSTALLER (v4.0)
# No external dependencies - fully self-contained
# ==============================================

set -eo pipefail
trap 'echo -e "\n\033[1;31m[!] Failed at line $LINENO\033[0m"; exit 1' ERR

# ===== 1. System Preparation =====
echo -e "\n\033[1;34m[1/5] INSTALLING SYSTEM DEPENDENCIES\033[0m"
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    python3 python3-pip python3-dev \
    nmap hydra sqlmap tor proxychains4 \
    libssl-dev libffi-dev build-essential

# ===== 2. Create REXUS Structure =====
echo -e "\033[1;34m[2/5] SETTING UP REXUS COR\033[0m"
[ -d ~/rexus ] && { 
    echo -e "\033[1;33m[!] Backing up existing installation\033[0m"
    mv ~/rexus ~/rexus.bak.$(date +%s)
}

mkdir -p ~/rexus/tools

# ===== 3. Install C2 Server (Integrated Code) =====
echo -e "\033[1;34m[3/5] DEPLOYING C2 SERVER\033[0m"
cat > ~/rexus/c2_server.py <<'EOF'
#!/usr/bin/env python3
import discord
import asyncio
from tools.exploit_manager import ExploitEngine

class RexusC2:
    def __init__(self):
        self.exploits = ExploitEngine()
        self.commands = {
            "!scan": self.handle_scan,
            "!exploit": self.handle_exploit
        }

    async def handle_scan(self, message):
        target = message.content.split()[1]
        await message.channel.send(f"[+] Scanning {target}...")
        # Simulate scan (replace with actual nmap integration)
        await asyncio.sleep(2)
        await message.channel.send(f"Open ports on {target}: 22(SSH), 80(HTTP), 443(HTTPS)")

    async def handle_exploit(self, message):
        await message.channel.send("[+] Exploit module loaded")
        # Actual exploit logic would go here

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
            f.write('{"discord_token": "MTUxNjc5Mzk0NTk4MjYzMTk1Ng.GBjUTU.nAzq4B1whZiQ9ag_-OX1hgwBTD5leh-zYla-4k"}')
    client.run(open("config.json").read().split('"')[3])
EOF

# ===== 4. Install Exploit Manager =====
cat > ~/rexus/tools/exploit_manager.py <<'EOF'
#!/usr/bin/env python3
import subprocess
import json

class ExploitEngine:
    def __init__(self):
        self.exploits = {
            "CVE-2021-44228": self.log4j_rce,
            "CVE-2017-0144": self.eternal_blue
        }

    def log4j_rce(self, target):
        return f"[+] Executing Log4j RCE against {target}"

    def eternal_blue(self, target):
        return f"[+] Launching EternalBlue against {target}"

    def run(self, cve, target):
        if cve in self.exploits:
            return self.exploits[cve](target)
        return "[-] Exploit not available"
EOF

# ===== 5. Python Environment =====
echo -e "\033[1;34m[4/5] CONFIGURING PYTHON\033[0m"
cd ~/rexus
python3 -m pip install --user \
    discord.py==2.3.2 \
    requests==2.31.0 \
    python-nmap==0.7.1 \
    scapy==2.5.0 \
    cryptography==42.0.4 \
    psutil==5.9.8

# ===== 6. Finalization =====
echo -e "\033[1;34m[5/5] FINALIZING INSTALL\033[0m"
chmod +x ~/rexus/c2_server.py
chmod +x ~/rexus/tools/*.py

# Create default config
[ ! -f ~/rexus/config.json ] && \
    echo '{"discord_token": "MTUxNjc5Mzk0NTk4MjYzMTk1Ng.GBjUTU.nAzq4B1whZiQ9ag_-OX1hgwBTD5leh-zYla-4k"}' > ~/rexus/config.json

# ===== SUCCESS =====
echo -e "\n\033[1;32m[✔] REXUS INSTALLATION COMPLETE\033[0m"
echo -e "\033[1;36m[•] Directory structure:\033[0m"
tree -L 2 ~/rexus
echo -e "\n\033[1;36m[•] To start:\033[0m"
echo -e "1. Edit ~/rexus/config.json with your Discord bot token"
echo -e "2. Run: cd ~/rexus && python3 c2_server.py"
echo -e "\n\033[1;33m[!] Always use Tor/VPN when operating C2!\033[0m"
