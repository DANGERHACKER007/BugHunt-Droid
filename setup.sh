#!/data/data/com.termux/files/usr/bin/bash

BugHunt-Droid: Setup Script for Termux CLI Bug Hunting Tool

Update & install core packages

pkg update -y && pkg upgrade -y pkg install -y git curl wget python nmap openssl grep sed awk nano

Install python tools

pip install requests colorama

Create working directory

mkdir -p ~/BugHunt-Droid/modules cd ~/BugHunt-Droid

Download wordlists

mkdir wordlists curl -o wordlists/common.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt

Create main tool script

cat << 'EOF' > bughunt.sh #!/data/data/com.termux/files/usr/bin/bash

TARGET="$2" MODE="$4"

function banner() { echo -e "\e[1;31m""\n[+] BugHunt-Droid - Android CLI Vulnerability Scanner\n""\e[0m" }

function recon() { echo "[+] Running Recon on $TARGET..." curl -s "$TARGET" | grep -Eo '(http|https)://[^"']+' | sort -u }

function dirscan() { echo "[+] Directory scanning on $TARGET using wordlists/common.txt" while read path; do code=$(curl -o /dev/null -s -w "%{http_code}" "$TARGET/$path") if [[ $code == 200 ]]; then echo "[!] Found: /$path => $code" fi done < wordlists/common.txt }

function vulnscan() { echo "[+] Checking basic XSS and Open Redirects on $TARGET" XSS="<script>alert(1)</script>" REDIR="http://evil.com"

for param in id query search url; do xss_url="$TARGET?$param=$XSS" redir_url="$TARGET?$param=$REDIR"

if curl -s "\$xss_url" | grep -q "\$XSS"; then
  echo "[!] Possible XSS on parameter '\$param'"
fi
if curl -s -L -w "%{url_effective}" "\$redir_url" -o /dev/null | grep -q "evil.com"; then
  echo "[!] Possible Open Redirect on parameter '\$param'"
fi

done }

banner

case $MODE in recon) recon ;; dirscan) dirscan ;; vulnscan) vulnscan ;; *) echo "[-] Usage: ./bughunt.sh -u <url> -m <mode>" echo "     Modes: recon | dirscan | vulnscan" ;; esac EOF

Make the main script executable

chmod +x bughunt.sh

Done

echo -e "\n[+] Setup complete! Run the tool like this:" echo "    cd ~/BugHunt-Droid && ./bughunt.sh -u https://example.com -m vulnscan"

