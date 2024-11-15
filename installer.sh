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
