import subprocess
import os
import shutil
import time

def DVHOST_CLOUD_display_menu():
    os.system('clear')  # Clear the screen after installation
    print("1- Install and Configure")
    print("2- Uninstall")
    print("0- Exit")

def DVHOST_CLOUD_install_panels():
    panels = []
    while True:
        print("\nPlease enter your panel information:")
        url = input("Enter panel URL (e.g., http://1.1.1.1:2020): ")
        username = input("Enter username: ")
        password = input("Enter password: ")
        
        panels.append(f"  - url: {url}\n    username: {username}\n    password: {password}\n\n")
        
        more_panels = input("Do you have another panel? (yes/no): ").strip().lower()
        if more_panels != 'yes':
            break
    
    return panels

def DVHOST_CLOUD_get_telegram_token():
    token = input("Enter your Telegram bot token: ")
    return token

def DVHOST_CLOUD_save_config(config):
    config_dir = '/root/v2ray-tel-bot/config/'
    
    # Create the directory if it doesn't exist
    if not os.path.exists(config_dir):
        os.makedirs(config_dir)
    
    config_file_path = os.path.join(config_dir, 'config.yml')
    output = f"telegram_token: \"{config['telegram_token']}\"\nchannel_id: \"{config['channel_id']}\"\npanels:\n" + ''.join(config['panels'])
    
    with open(config_file_path, 'w') as file:
        file.write(output)

def DVHOST_CLOUD_run_process(command):
    process = subprocess.Popen(command, shell=True)
    process.wait()

def DVHOST_CLOUD_show_progress_bar(duration):
    print("Installing...")
    for _ in range(duration):
        time.sleep(0.1)
        print(".", end="", flush=True)
    print("\nInstallation complete.")

def DVHOST_CLOUD_check_and_install():
    if not os.path.exists('/root/v2ray-tel-bot'):
        print("v2ray-tel-bot not found. Installing now...\n")
        # Run the installation script
        DVHOST_CLOUD_run_process("bash -c 'bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/v2ray-tel-bot/main/install.sh)'")
        DVHOST_CLOUD_show_progress_bar(50)
        os.system('clear')  # Clear the screen after installation
        if not os.path.exists('/root/v2ray-tel-bot'):
            print("Installation failed. Exiting...")
            exit(1)
        
        # Install python3-pip after v2ray-tel-bot installation
        print("Installing python3-pip...\n")
        DVHOST_CLOUD_run_process("sudo apt-get update && sudo apt-get install -y python3-pip")
        os.system('clear')  # Clear the screen after installation
        print("python3-pip installation complete.\n")

def DVHOST_CLOUD_uninstall():
    dir_path = '/root/v2ray-tel-bot/'
    if os.path.exists(dir_path):
        shutil.rmtree(dir_path)
        print(f"\nDirectory {dir_path} has been removed.\n")
    else:
        print(f"\nDirectory {dir_path} does not exist.\n")

def DVHOST_CLOUD_reboot_system():
    for i in range(5, 0, -1):
        print(f"\033[91m{i}\033[0m")  # 91 is the ANSI code for red text
        time.sleep(1)
    print("Rebooting now...")
    DVHOST_CLOUD_run_process("reboot")

def main():
    # First, check if the necessary directory exists and install if needed
    DVHOST_CLOUD_check_and_install()

    # Now display the menu
    config = {
        "telegram_token": "",
        "channel_id": "",  # If you want to force the user to join the channel, provide channel's numeric ID (-1243423432). Otherwise, put Empty
        "panels": []
    }
    
    while True:
        DVHOST_CLOUD_display_menu()
        choice = input("Choose an option: ")
        
        if choice == '1':
            # Get the Telegram bot token first
            config['telegram_token'] = DVHOST_CLOUD_get_telegram_token()

            # Then get the panel information
            config['panels'] = DVHOST_CLOUD_install_panels()
            print("\nConfiguration created:\n")
            output = f"telegram_token: \"{config['telegram_token']}\"\nchannel_id: \"{config['channel_id']}\"\npanels:\n" + ''.join(config['panels'])
            print(output)

            confirmation = input("\nAre you sure you want to start the bot with this configuration? (yes/no): ").strip().lower()
            if confirmation == 'yes':
                print("\nSaving configuration to /root/v2ray-tel-bot/config/config.yml...\n")
                DVHOST_CLOUD_save_config(config)

                print("\nRunning the bot...\n")
                DVHOST_CLOUD_run_process("python3 /root/v2ray-tel-bot/login.py")

                # Countdown and reboot
                DVHOST_CLOUD_reboot_system()
                break
            else:
                print("\nRestarting configuration process...\n")
        
        elif choice == '2':
            DVHOST_CLOUD_uninstall()
        
        elif choice == '0':
            print("Exiting...")
            break
        
        else:
            print("Invalid option. Please try again.")

if __name__ == "__main__":
    main()
