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
containers=("ai-server" "minio" "elasticsearch" "elastichq" "redpanda" "redpanda-console" "paperless_postgres" "paperless-backend" "paperless-worker")
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
        if [[ "$status" == "true" && -n "${ui_urls[$container]}" ]]; then
            echo -e "  -> ${BLUE}UI:${RESET} ${ui_urls[$container]}"
            echo
        fi
done
    echo
}
declare -A ui_urls=(
    ["minio"]="http://localhost:9001"
    ["elastichq"]="http://localhost:5000"
    ["redpanda-console"]="http://localhost:8080"
)
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
