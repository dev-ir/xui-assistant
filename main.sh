#!/bin/bash

#add color for text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color


cur_dir=$(pwd)
# check root
# [[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

install_jq() {
    if ! command -v jq &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}

loader(){
    
    menu "| 1  - Transfer DB to another SERVER \n| 2  - Send Gift to All Client \n| 3 - Manage Users  \n| 4 - Cronjob for reset xray  \n| 5 - WhatsApp Time  \n| 0  - Exit"
    
    read -p "Enter option number: " choice
    case $choice in
        1)
            transfer_db
        ;;
        2)
            user_gift
        ;;
        3)
            
        ;;
        4)
            xray_restart
        ;;
        5)
            sudo timedatectl set-timezone UTC
            echo "Timezone Set."
        ;;
        2)
            unistall
        ;;
        0)
            echo -e "${GREEN}Exiting program...${NC}"
            exit 0
        ;;
        *)
            echo "Not valid"
        ;;
    esac
    
}

require_command(){
    
    apt update -y && apt upgrade -y
    sudo apt-get install dnsutils -y
    # install_jq
    if ! command -v pv &> /dev/null
    then
        echo "pv could not be found, installing it..."
        sudo apt update
        sudo apt install -y pv
    fi
}


menu(){
    clear
    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    # Fetch server country using ip-api.com
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')
    
    # Fetch server isp using ip-api.com
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')
    
    XUI_CORE=$(check_xui_exist)
    
    echo "+-------------------------------------------------------------------------------------------------+"
    echo "| __   __ _    _  _____                             _       _                  _                  |"
    echo "| \ \ / /| |  | ||_   _|          /\               (_)     | |                | |                 |"
    echo "|  \ V / | |  | |  | |   ____    /  \    ___   ___  _  ___ | |_   __ _  _ __  | |_                |"
    echo "|   > <  | |  | |  | |  |____|  / /\ \  / __| / __|| |/ __|| __| / _  || '_ \ | __| TG CHANNEL    |"
    echo "|  / . \ | |__| | _| |_        / ____ \ \__ \ \__ \| |\__ \| |_ | (_| || | | || |_  @DVHOST_CLOUD |"
    echo "| /_/ \_\ \____/ |_____|      /_/    \_\|___/ |___/|_||___/ \__| \__,_||_| |_| \__|               |"
    echo "+-------------------------------------------------------------------------------------------------+"
    echo -e "|${GREEN}Server Country    |${NC} $SERVER_COUNTRY"
    echo -e "|${GREEN}Server IP         |${NC} $SERVER_IP"
    echo -e "|${GREEN}Server ISP        |${NC} $SERVER_ISP"
    echo -e "|${GREEN}Server XUI        |${NC} $XUI_CORE"
    echo "+-------------------------------------------------------------------------------------------------+"
    echo -e "|${YELLOW}Please choose an option:${NC}"
    echo "+-------------------------------------------------------------------------------------------------+"
    echo -e $1
    echo "+-------------------------------------------------------------------------------------------------+"
    echo -e "\033[0m"
}

transfer_db(){
    
    read -p "Destination SERVER IP   ( Like : 127.0.0.1 ): " dest_ip
    read -p "Destination SERVER USER ( Like : root) [default: root]: " dest_user
    read -p "Destination SERVER PORT ( Like : 22 ) [default: 22]: " dest_port
    
    dest_user=${dest_user:-root}
    dest_port=${dest_port:-22}
    
    db_file="/etc/x-ui/x-ui.db"
    
    echo "Transferring file..."
    scp -P "$dest_port" "$db_file" "$dest_user@$dest_ip:/etc/testfolder"
    
    if [ $? -eq 0 ]; then
        echo $'\e[32m Transfer completed successfully , Return to Menu in 3 seconds... \e[0m' && sleep 1 && echo $'\e[32m2... \e[0m' && sleep 1 && echo $'\e[32m1... \e[0m' && sleep 1 && {
            menu
        }
    else
        echo "Transfer failed."
    fi
}

user_gift(){
    
    wget https://raw.githubusercontent.com/dev-ir/xui-assistant/master/core/day_size.py
    python3 day_size.py
    rm day_size.py
}

check_xui_exist() {
    local file_path="/etc/x-ui/x-ui.db"
    local status
    
    if [ -f "$file_path" ]; then
        status="${GREEN}Installed"${NC}
    else
        status=${RED}"Not installed"${NC}
    fi
    
    echo "$status"
}

function xray_restart(){
    
    wget https://raw.githubusercontent.com/dev-ir/xui-assistant/master/core/setup_cron.py
    python3 setup_cron.py
    rm setup_cron.py
    
}


require_command
loader