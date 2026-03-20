#!/bin/bash
# Sets up a couple of global arrays.
declare -a CMD_LABELS=()
declare -a CMD_LIST=()

# Formatting helper functions
section() { echo -e "\n== $1 =="; }
prompt() { echo -ne " > $1 "; }

# Need a function to register/display commands.
cmd() {
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

main() {
	clear
	collect_inputs

}

main "$@"
