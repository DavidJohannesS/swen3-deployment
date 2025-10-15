#!/bin/bash

cmd="ansible-playbook start.yaml --ask-become-pass --tags"

options=(
    "Setup LocalDev"
    "Remove LocalDev"
    "Setup Paparless"
    "Remove Paperless"
    "Quit"
)
select opt in "${options[@]}";do
    case $REPLY in
        1) $cmd setup;;
        2) $cmd remove;;
        3) $cmd paperless;;
        4) $cmd remove_paperless;;
        5) echo "Exiting..." && break ;;
        *) echo "Invalid" ;;
    esac
done
