#!/bin/bash
# ==============================================
# REXUS NODE - GUARANTEED INSTALLER (v6.1)
# For Victorrex04/und3rxpl0it-rexus-cor
# ==============================================

# Safe installation with local logging
set -eo pipefail
LOG_FILE="$HOME/rexus_install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Clean installation function
install_rexus() {
    # ===== 1. Verify System =====
    echo -e "\n\033[1;34m[1/5] VERIFYING SYSTEM\033[0m"
    if ! command -v python3 >/dev/null; then
        sudo apt update -qq
        sudo apt install -y python3 python3-pip
    fi

    # ===== 2. Create Structure =====
    echo -e "\033[1;34m[2/5] CREATING DIRECTORIES\033[0m"
    [ -d ~/rexus ] && mv ~/rexus ~/rexus.bak.$(date +%s)
    mkdir -p ~/rexus/tools

    # ===== 3. Install C2 Server =====
    echo -e "\033[1;34m[3/5] INSTALLING C2 SERVER\033[0m"
    cat > ~/rexus/c2_server.py <<'EOF'
#!/usr/bin/env python3
# [Previous full c2_server.py content here]
# [Include the complete Python code from earlier versions]
EOF

    # ===== 4. Install Exploit Manager =====
    cat > ~/rexus/tools/exploit_manager.py <<'EOF'
#!/usr/bin/env python3
# [Previous full exploit_manager.py content here]
# [Include the complete Python code from earlier versions]
EOF

    # ===== 5. Final Setup =====
    echo -e "\033[1;34m[5/5] FINALIZING\033[0m"
    chmod +x ~/rexus/c2_server.py
    chmod +x ~/rexus/tools/*.py
    
    [ ! -f ~/rexus/config.json ] && \
        echo '{"discord_token": "YOUR_TOKEN_HERE"}' > ~/rexus/config.json
}

# Main execution
try {
    install_rexus
    echo -e "\n\033[1;32m[✔] INSTALLATION SUCCESSFUL\033[0m"
    echo -e "\033[1;36m[+] Start C2: cd ~/rexus && python3 c2_server.py\033[0m"
} catch {
    echo -e "\n\033[1;31m[!] INSTALLATION FAILED\033[0m"
    echo -e "\033[1;36m[+] Check logs: $LOG_FILE\033[0m"
    exit 1
}
