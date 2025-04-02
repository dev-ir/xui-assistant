#!/bin/bash

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Configuration
VERSION='2.3.1'
INSTALL_DIR='/root/xui-assistant'
BIN_PATH='/usr/local/bin/xui-assis'
REPO_URL='https://github.com/dev-ir/xui-assistant.git'

# Clean previous installation
rm -rf "${INSTALL_DIR}"

# Install dependencies
if ! command -v git &> /dev/null; then
    echo -e "${GREEN}Installing git...${NC}"
    apt-get update && apt-get install -y git
fi

# Clone repository
echo -e "${GREEN}Cloning repository...${NC}"
git clone "${REPO_URL}" "${INSTALL_DIR}"

# Set permissions
chmod +x "${INSTALL_DIR}"
chmod +x "${INSTALL_DIR}/menu.sh"

# Install binary
mv "${INSTALL_DIR}/menu.sh" "${BIN_PATH}"

# Display success message
clear
echo "+------------------------------------------------------------------------+"
echo -e "| Telegram Channel : ${RED}@DVHOST_CLOUD${NC} | YouTube : ${RED}youtube.com/@dvhost_cloud${NC} |"
echo "+------------------------------------------------------------------------+"
echo -e "| Now permanently access the menu by typing: ${GREEN}xui-assis${NC} | Version : ${GREEN}${VERSION}${NC} |"
echo "+------------------------------------------------------------------------+"
