RED='\033[0;31m'
GREEN='\033[0;32m'

NC='\033[0m' # No Color
#Remove Old version
rm -rf /root/xui-assistant/

# install git
sudo apt install git -y

# clone from repo in xui-assistant directory
git clone https://github.com/dev-ir/xui-assistant.git /root/xui-assistant/

# Access Folder
sudo chmod +x /root/xui-assistant/
chmod +x /root/xui-assistant/menu.sh


sudo mv /root/xui-assistant/menu.sh /usr/local/bin/xui-assis

clear
echo "+-------------------------------------------------------------------------------------+"
echo -e "|  Telegram Channel : ${RED}@DVHOST_CLOUD ${NC} |  YouTube : ${RED}youtube.com/@dvhost_cloud${NC} "
echo "+-------------------------------------------------------------------------------------+"
echo -e "| You can now permanently access the menu by typing: ${GREEN}xui-assis${NC}    |  Version : ${GREEN} 2.0${NC} "
echo "+-------------------------------------------------------------------------------------+"

# xui-assis