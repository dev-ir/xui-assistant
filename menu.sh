#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color


[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${RED} Please run this script with root privilege ${NC}  \n " && exit 1

XUI_ASSISTANT_MENU(){
    clear

    XUI_CORE=$(check_xui_exist)
    
    echo '+--------------------------------------------------------------------------------------------------------------------------------------+'
	echo '| Y88b   d88P 888     888 8888888            d8888  .d8888b.   .d8888b. 8888888 .d8888b. 88888888888     d8888 888b    888 88888888888 |'
	echo '|  Y88b d88P  888     888   888             d88888 d88P  Y88b d88P  Y88b  888  d88P  Y88b    888        d88888 8888b   888     888     |'
	echo '|   Y88o88P   888     888   888            d88P888 Y88b.      Y88b.       888  Y88b.         888       d88P888 88888b  888     888     |'
	echo '|    Y888P    888     888   888           d88P 888  "Y888b.    "Y888b.    888   "Y888b.      888      d88P 888 888Y88b 888     888     |'
	echo '|    d888b    888     888   888          d88P  888     "Y88b.     "Y88b.  888      "Y88b.    888     d88P  888 888 Y88b888     888     |'
	echo '|   d88888b   888     888   888  888888 d88P   888       "888       "888  888        "888    888    d88P   888 888  Y88888     888     |'
	echo '|  d88P Y88b  Y88b. .d88P   888        d8888888888 Y88b  d88P Y88b  d88P  888  Y88b  d88P    888   d8888888888 888   Y8888     888     |'
	echo '| d88P   Y88b  "Y88888P"  8888888     d88P     888  "Y8888P"   "Y8888P" 8888888 "Y8888P"     888  d88P     888 888    Y888     888     |'
    echo '+--------------------------------------------------------------------------------------------------------------------------------------+'
    echo -e "|  Telegram Channel : ${YELLOW}@DVHOST_CLOUD ${NC} |  YouTube : ${RED}youtube.com/@dvhost_cloud${NC}   |  Version : ${GREEN} 2.0${NC} "
    echo '+--------------------------------------------------------------------------------------------------------------------------------------+'
    echo -e "|${YELLOW}Please choose an option:${NC}"
    echo '+--------------------------------------------------------------------------------------------------------------------------------------+'
    echo -e $1
    echo '+--------------------------------------------------------------------------------------------------------------------------------------+'
    echo -e "\033[0m"
}

# Main menu function
loader() {
    XUI_ASSISTANT_MENU "| 1 - Copy Database to Destination VPS\n| 2 - Send Gift to All Clients\n| 3 - User Management\n| 4 - Set Cronjob for Resetting Xray\n| 5 - Fix WhatsApp Time\n| 6 - Install WordPress\n| 7 - Block All Speedtest Requests\n| 8 - XUI Bot (${RED}Multi-Server Support${NC})\n| 9 - Uninstall\n| 0 - Exit"

    read -p "| Enter option number: " choice
    case $choice in
        1) transfer_db ;;
        2) gift_user ;;
        3) manage_users ;;
        4) xray_restart ;;
        5) fix_timezone ;;
        6) install_wordpress ;;
        7) block_speedtest_sites ;;
        8) xui_bot ;;
        9) uninstall ;;
        0) exit_program ;;
        *) echo -e "${RED}Invalid option. Try again.${NC}" ;;
    esac
}

# Functions
gift_user() {
    python3 /root/xui-assistant/core/day_size.py
}

manage_users() {
    python3 /root/xui-assistant/core/user_managment.py
}

require_command() {
    local repo_url="https://github.com/dev-ir/xui-assistant.git"
    local install_dir="/root/xui-assistant"

    if [ ! -d "$install_dir" ]; then
        echo "Directory $install_dir does not exist. Installing..."

        # Check if git is installed
        if ! command -v git &>/dev/null; then
            echo "Git is not installed. Installing git..."
            apt update && apt install -y git
        fi

        # Clone the repository
        echo "Cloning repository..."
        git clone "$repo_url" "$install_dir"
    else
        echo "Directory $install_dir already exists."
    fi
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

transfer_db() {
    local db_file="/etc/x-ui/x-ui.db"

    read -p "Destination SERVER IP (e.g., 127.0.0.1): " dest_ip
    read -p "Destination SERVER USER (e.g., root) [default: root]: " dest_user
    read -p "Destination SERVER PORT (e.g., 22) [default: 22]: " dest_port

    dest_user=${dest_user:-root}
    dest_port=${dest_port:-22}

    echo "Transferring database..."
    scp -P "$dest_port" "$db_file" "$dest_user@$dest_ip:/etc/testfolder"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Transfer completed successfully.${NC}"
    else
        echo -e "${RED}Transfer failed.${NC}"
    fi
}

fix_timezone() {
    sudo timedatectl set-timezone UTC
    echo -e "${GREEN}Timezone set to UTC.${NC}"
}

install_wordpress() {
    bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/WordPress-Installer/master/main.sh)
}

block_speedtest_sites() {
    bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/speedtest-ban/master/main.sh)
}

xray_restart() {
    wget -q https://raw.githubusercontent.com/dev-ir/xui-assistant/master/xui-assistant/core/setup_cron.py
    python3 setup_cron.py && rm setup_cron.py
}

xui_bot() {
    wget -q https://raw.githubusercontent.com/dev-ir/xui-assistant/master/xui-assistant/core/v2ray_bot.py
    python3 v2ray_bot.py && rm v2ray_bot.py
}

uninstall() {
    echo -e "${GREEN}Uninstalling XUI-ASSISTANT...${NC}"
    rm -rf /root/xui-assistant/
    rm -rf /usr/local/bin/xui-assis
    echo -e "${RED}XUI-ASSISTANT Uninstalled.${NC}"
}

exit_program() {
    echo -e "${GREEN}Exiting program...${NC}"
    exit 0
}

# Ensure required commands and run loader
require_command
loader
