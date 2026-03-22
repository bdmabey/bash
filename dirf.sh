#!/bin/bash

dir=$1
file=$2

usage() { echo "Usage is: ./dirf.sh <directory> <file>"; }

# Check for args passed to script.
if [[ $# -lt 2 ]]; then
	usage
	exit 1
fi

if [[ -d $dir ]]; then
	echo "Directory: $dir exists"
	if [[ -f $dir/$file ]]; then
		echo "File: $dir/$file exists."
	else
		echo "File: $dir/$file does not exist."
		echo "Creating file."
		touch $dir/$file
		echo "Created file."
	fi
else
	echo "Directory: $dir does not exist."
	echo "File: $dir/$file does not exist."
	echo "Creating directory & file."
	mkdir -p $dir && touch $dir/$file
	echo "Directory & file created."
fi
