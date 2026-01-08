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
containers=("ai-server" "minio" "elasticsearch" "kibana" "redpanda" "redpanda-console" "paperless_postgres" "paperless-backend" "paperless-worker" "paperless-frontend")
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
    ["kibana"]="http://localhost:5601"
    ["redpanda-console"]="http://localhost:8080"
    ["paperless-frontend"]="http://localhost:80"
)
options=(
    "Setup Paperless Application"
    "Remove Shutdown Paperless Application"
    "Integration Test"
    "Quit"
)
PS3="Selection: "
while true; do
    print_info
    echo -e "${YELLOW}### Menu ###${RESET}"
    echo
    echo "1) Setup Paperless Application"
    echo "2) Remove Shutdown Paperless Application"
    echo "3) Integration Test"
    echo "4) Quit"
    echo
    echo -n "Selection: "
    read choice

    case "$choice" in
        1) $cmd setup;;
        2) $cmd remove;;
        3) $cmd test;;
        4) echo "Exiting..." && exit;;
        *) echo "Invalid selection";;
    esac
done
