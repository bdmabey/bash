#!/bin/bash
# Sets up a couple of global arrays.
declare -a CMD_LABELS=()
declare -a CMD_LIST=()

# Formatting helper functions
section() { echo -e "\n== $1 =="; }

collect_inputs() {
	section "Target Configuration"
	
}

main() {
	clear
	collect_inputs

}

main "$@"
