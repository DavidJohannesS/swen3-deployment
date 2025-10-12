#!/bin/bash

cmd="ansible-playbook start.yaml --tags"

options=(
    "Setup LocalDev"
    "Remove LocalDev"
    "Quit"
)
select opt in "${options[@]}";do
    case $REPLY in
        1) $cmd setup;;
        2) $cmd remove;;
        10) echo "Exiting..." && break ;;
        *) echo "Invalid" ;;
    esac
done
