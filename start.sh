#!/bin/bash

GREEN="\033[38;5;82m"
RESET="\033[0m"
RED="\033[38;5;196m"
YELLOW="\033[38;5;226m"
BLUE="\033[38;5;153m"
if [[ "$1" == "--no-pwd" ]];then
    cmd="ansible-playbook start.yaml --tags"
else
    cmd="ansible-playbook start.yaml --ask-become-pass --tags"
fi
containers=("minio" "elasticsearch" "elastichq" "redpanda" "redpanda-console" "paperless_postgres" "paperless_backend")
function print_info()
{
    echo
    echo -e "${YELLOW}### Containers ###${RESET}"
    echo
    max_width=30
    for container in "${containers[@]}"; do
        status=$(docker inspect -f '{{.State.Running}}' "$container" 2>/dev/null)
        status_text="${RED}offline${RESET}"
        [[ "$status" == "true" ]] && status_text="${GREEN}running${RESET}"
        dots=$(( max_width - ${#container} ))
        dotline=$(printf '.%.0s' $(seq 1 $dots))
        echo -e "[${container}]${dotline}${status_text}"
    done
    echo
}
options=(
    "Setup LocalDev"
    "Remove LocalDev"
    "Setup Paparless"
    "Remove Paperless"
    "Quit"
)
PS3="Selection: "
while true; do
    print_info
    echo -e "${YELLOW}### Menu ###${RESET}"
    echo
    select opt in "${options[@]}";do
        case $REPLY in
            1) $cmd setup; break;;
            2) $cmd remove; break;;
            3) $cmd paperless; break;;
            4) $cmd remove_paperless; break;;
            5) echo "Exiting..." && exit;;
            *) echo "Invalid"; break;;
        esac
    done
done
