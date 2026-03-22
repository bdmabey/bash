#!/bin/bash
# Sets up a couple of global arrays.
declare -a CMD_LABELS=()
declare -a CMD_LIST=()

# Formatting helper functions
section() { echo -e "\n== $1 =="; }
prompt() { echo -ne " > $1 "; }

# Need a function to register/display commands.
cmd() {
	local command="$1"
	local desc="$2"

	echo -e "  [$(( ${#CMD_LIST[@]} + 1 ))] $command"
	echo -e "      ${desc}"

	CMD_LIST+=("$command")
	CMD_LABELS+=("$desc")
}

collect_inputs() {
	section "Target Configuration"
	
	prompt "Enter target IP / range / hostname (e.g. 192.168.1.1 or 192.168.1.0/24):"
	read -r TARGET
	TARGET="${TARGET:-192.168.1.1}" # Defaults to 192.168.1.1 if nothing is entered.

	prompt "Enter port(s) - blank for nmap defaults (e.g. 80,443, or 1-1000 or 'all'):"
	read -r PORT_INPUT

	# Selects what ports are going to be used.
	# Sets the flag and label to give to nmap.
	if [[ -z "$PORT_INPUT" ]]; then
		PORT_FLAG=""
		PORT_LABEL="default top-1000 ports"
	elif [[ "${PORT_INPUT,,}" == "all" ]]; then
		PORT_FLAG="-p-"
		PORT_LABEL="all 65535 ports"
	else
		PORT_FLAG="-p ${PORT_INPUT}"
		PORT_LABEL="port(s): ${PORT_INPUT}"
	fi

	section "Scan Categories"
	echo -e " Select categories to generate (comma-separated, or 'all')"
	echo -e " 1) Discovery / Host Detection"
	echo -e " 2) Port & Service Enumeration"
	echo -e " 3) Version & OS Detection"
	echo -e " 4) Vulnerability / Script Scanning"
	echo -e " 5) Stealth & Evasion"
	echo -e " 6) Output Formats"
	echo

	prompt "Your choice [default: all]:"
	read -r CHOICE
	CHOICE="${CHOICE:-all}"
}

# Building of the different command sections.
show_discovery() {
	section "1 - Discovery / Host Detection"
	cmd "nmap -sn ${TARGET}"		"Ping sweep - find live hosts, no port scan."
	cmd "nmap -sn -PE -PP -PM ${TARGET}"	"ICMP echo, timestamp & netmask sweep."
	cmd "nmap -sn --traceroute ${TARGET}"	"Ping sweep + traceroute."
	cmd "nmap -sL ${TARGET}"		"List targets without sending packets."
	cmd "nmap -sn -PR ${TARGET}"		"ARP scan (LAN only, very fast)"
	cmd "nmap -n -sn ${TARGET}"		"Skip DNS resolution for faster sweep."
}

show_port_enum() {
	section "2 - Port & Service Enumeration"
	cmd "nmap -sS ${PORT_FLAG} ${TARGET}"		"SYN (stealth) scan - ${PORT_LABEL}"
	cmd "nmap -sT ${PORT_FLAG} ${TARGET}"		"Full TCP connect scan - ${PORT_LABEL}"
	cmd "nmap -sU ${PORT_FLAG} ${TARGET}"		"UDP scan - ${PORT_LABEL}"
	cmd "nmap -sS -sU ${PORT_FLAG} ${TARGET}"	"Combined TCP SYN & UDP - ${PORT_LABEL}"
	cmd "nmap -p- ${TARGET}"			"All 65535 ports (slow but thorough)"
	cmd "nmap --top-ports 100 ${TARGET}"		"Top 100 most common ports"
	cmd "nmap --top-ports 1000 ${TARGET}"		"Top 1000 most common ports"
	cmd "nmap -sS -F ${TARGET}"			"Fast scan - top 100 ports only"	
}

show_version_os() {
	section "3 - Version & OS Detection"
	cmd "nmap -sV ${PORT_FLAG} ${TARGET}"		"Service/version detection - ${PORT_LABEL}"
	cmd "nmap -O ${TARGET}"				"OS fingerprinting"
	cmd "nmap -A ${PORT_FLAG} ${TARGET}"		"Aggressive OS/version/scripts/traceroute"
	cmd "nmap -sV --version-intensity 9 ${PORT_FLAG} ${TARGET}" "Max version detection intensity"
	cmd "nmap -sV -sC ${PORT_FLAG} ${TARGET}"	"Version detection & default scripts"
	cmd "nmap -O --osscan-guess ${TARGET}"		"OS detection with best-guess fallback"
}

show_vuln_scripts() {
	section "4 - Vulnerabilty / Script Scanning"
	cmd "nmap -sC ${PORT_FLAG} ${TARGET}"		"Default NSE scripts - ${PORT_LABEL}"
	cmd "nmap --script=vuln ${PORT_FLAG} ${TARGET}"	"Run all vuln-category scripts."
	cmd "nmap --script=safe,discovery ${PORT_FLAG} ${TARGET}" "Safe & discovery scripts."
	cmd "nmap --script=http-enum ${PORT_FLAG:-p 80,443,8000} ${TARGET}" "HTTP Enumeration"
	cmd "nmap --script=smb-vuln-* -p 445 ${TARGET}" "SMB vulnerability check."
	cmd "nmap --script=ssl-enum-ciphers ${PORT_FLAG:-p 443} ${TARGET}" "SSL/TLS cipher enumeration."
	cmd "nmap --script=ftp-anon -p 21 ${TARGET}"	"Check for anonymous FTP access."
	cmd "nmap --script=dns-brute ${TARGET}"		"DNS subdomain brute-force."
	cmd "nmap --script=auth ${PORT_FLAG} ${TARGET}"	"Test for default/blank credentials."
}

show_stealth() {
	section "5 - Stealth & Evasion"
	cmd "nmap -sS -T0 ${PORT_FLAG} ${TARGET}"	"Paranoid timing - slowest, hardest to detect."
	cmd "nmap -sS -T1 ${PORT_FLAG} ${TARGET}"	"Sneaky timing."
	cmd "nmap -sS -f ${PORT_FLAG} ${TARGET}"	"Fragment pakcets to evade firewalls."
	cmd "nmap -D RND:10 ${PORT_FLAG} ${TARGET}"	"Decoy scan (10 random decoys)"
	cmd "nmap --source-port 53 ${PORT_FLAG} ${TARGET}" "Spoof source port (DNS - often allowed)"
	cmd "nmap -sS --data-length 25 ${PORT_FLAG} ${TARGET}" "Append random data to packets."
	cmd "nmap -sS -n ${PORT_FLAG} ${TARGET}" 	"Skip DNS lookups (faster & quieter)."
	cmd "nmap --randomize-hosts ${PORT_FLAG} ${TARGET}" "Randomise host scan order."
	cmd "nmap --spoof-mac APPLE ${PORT_FLAG} ${TARGET}" "Spoof MAC address as Apple vendor."
}

show_output_cmds() {
	section "6 - Output & Reporting"
	cmd "nmap ${PORT_FLAG} ${TARGET} -oN scan.txt"	"Normal (human-readable) output"
	cmd "nmap ${PORT_FLAG} ${TARGET} -oX scan.xml"	"XML Output"
	cmd "nmap ${PORT_FLAG} ${TARGET} -oG scan.txt"	"Greppable output."
	cmd "nmap ${PORT_FLAG} ${TARGET} -oA scan"	"All formats at once"
	cmd "nmap -v ${PORT_FLAG} ${TARGET}"		"Verbose output."
	cmd "nmap -vv ${PORT_FLAG} ${TARGET}"		"Very verbose output."
	cmd "nmap --open ${PORT_FLAG} ${TARGET}"		"Show only open ports."
	cmd "nmap --reason ${PORT_FLAG} ${TARGET}"	"Show reason for each port state."
	cmd "nmap -sV --open ${PORT_FLAG} ${TARGET} -oA scan"	"Combined scan & all output."
}

main() {
	clear
	collect_inputs

	local c="${CHOICE,,}"

	if [[ "$c" == "all" ]]; then
		show_discovery
		show_port_enum
		show_version_os
		show_vuln_scripts
		show_stealth
		show_output_cmds
	else
		IFS=',' read -ra CATS <<< "$c"
		for cat in "${CATS[@]}"; do
			cat="${cat// /}"
			case "$cat" in
				1) show_discovery    ;;
				2) show_port_enum    ;;
				3) show_version_os   ;;
				4) show_vuln_scripts ;;
				5) show_stealth      ;;
				6) show_output_cmds  ;;
			esac
		done
	fi
}

main "$@"
