#!/bin/bash

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
VERSION='2.3.1'

# Path Definitions
XUI_ASSISTANT_DIR="/root/xui-assistant"
XUI_DB_PATH="/etc/x-ui/x-ui.db"

# Check root privilege
[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: Please run this script with root privilege${NC}\n" && exit 1

xui_assis_display_menu() {
    clear
    local xui_status=$(xui_assis_check_installation)
    
    cat << "EOF"
+-----------------------------------------------------------------------------+
|    _  ____  ______       ___   __________ __________________    _   ________
|   | |/ / / / /  _/      /   | / ___/ ___//  _/ ___/_  __/   |  / | / /_  __/
|   |   / / / // / _____ / /| | \__ \\__ \ / / \__ \ / / / /| | /  |/ / / /   
|  /   / /_/ // / _____ / ___ |___/ /__/ // / ___/ // / / ___ |/ /|  / / /    
| /_/|_\____/___/      /_/  |_/____/____/___//____//_/ /_/  |_/_/ |_/ /_/     
+-----------------------------------------------------------------------------+
EOF
echo -e "| Telegram Channel : ${YELLOW}@DVHOST_CLOUD${NC} | YouTube : ${RED}@dvhost_cloud${NC} | Version : ${GREEN}${VERSION}${NC} "
echo '+-----------------------------------------------------------------------------+'
echo -e "|${YELLOW} Please choose an option:${NC}"
echo '+-----------------------------------------------------------------------------+'
echo -e "$1"
echo '+-----------------------------------------------------------------------------+'
}

xui_assis_check_installation() {
    [[ -f "$XUI_DB_PATH" ]] && echo "${GREEN}Installed${NC}" || echo "${RED}Not installed${NC}"
}

# Core Functions
xui_assis_transfer_database() {
    bash "${XUI_ASSISTANT_DIR}/core/database_transfer.sh"
}

xui_assis_gift_users() {
    python3 "${XUI_ASSISTANT_DIR}/core/day_size.py"
}

xui_assis_manage_admins() {
    python3 "${XUI_ASSISTANT_DIR}/core/user_managment.py"
}

xui_assis_set_xray_restart() {
    python3 "${XUI_ASSISTANT_DIR}/core/setup_cron.py"
}

xui_assis_fix_whatsapp_time() {
    timedatectl set-timezone UTC
    echo -e "${GREEN}Timezone set to UTC for WhatsApp compatibility.${NC}"
}

xui_assis_install_wordpress() {
    bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/WordPress-Installer/master/main.sh)
}

xui_assis_block_speedtest() {
    bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/speedtest-ban/master/main.sh)
}

xui_assis_user_management_bot() {
    python3 "${XUI_ASSISTANT_DIR}/core/v2ray_bot.py"
}

xui_assis_install_panels() {
    bash "${XUI_ASSISTANT_DIR}/core/mlxui.sh"
}

xui_assis_add_subscription_templates() {
    bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/xui-subscription-template/refs/heads/master/main.sh )
}

xui_assis_uninstall() {
    echo -e "${GREEN}Uninstalling XUI-ASSISTANT...${NC}"
    rm -rf "$XUI_ASSISTANT_DIR"
    rm -f /usr/local/bin/xui-assis
    echo -e "${RED}XUI-ASSISTANT has been completely removed.${NC}"
}

xui_assis_exit() {
    echo -e "${GREEN}Exiting the program...${NC}"
    exit 0
}

xui_assis_main_menu() {
    local menu_options
    read -r -d '' menu_options << EOM
| 1  - Transfer Database to Another Server
| 2  - Gift Flow/Time to All Users
+-----------------------------------------------------------------------------+
| 3  - Admin Management
| 4  - User Management Bot (Traffic/Date)
+-----------------------------------------------------------------------------+
| 5  - Schedule Xray Service Restart
| 6  - Fix WhatsApp Date/Time Issue
| 7  - Block Speedtest Websites
+-----------------------------------------------------------------------------+
| 8  - Install WordPress Alongside X-UI
| 9  - Install More X-UI Panels
| 10 - Add Subscription Templates
+-----------------------------------------------------------------------------+
| 11 - Uninstall This Script
| 0  - Exit Program
EOM
    
    xui_assis_display_menu "$menu_options"
    echo -ne "${YELLOW}| Enter option number: ${NC}"
    read -r choice
    case $choice in
        1) xui_assis_transfer_database ;;
        2) xui_assis_gift_users ;;
        3) xui_assis_manage_admins ;;
        4) xui_assis_user_management_bot;;
        5) xui_assis_set_xray_restart ;;
        6) xui_assis_fix_whatsapp_time ;;
        7) xui_assis_block_speedtest ;;
        8) xui_assis_install_wordpress;;
        9) xui_assis_install_panels ;;
        10) xui_assis_add_subscription_templates ;;
        11) xui_assis_uninstall ;;
        0) xui_assis_exit ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
    esac
}

# Start the program
xui_assis_main_menu