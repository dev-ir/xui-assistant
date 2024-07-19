import os
import subprocess

def check_and_install_cron():
    # Check if cron is installed
    cron_check = subprocess.run(['which', 'cron'], capture_output=True, text=True)
    
    if cron_check.returncode != 0:
        print("Cron is not installed. Installing cron...")
        # Install cron
        os.system('sudo apt-get update')
        os.system('sudo apt-get install cron')
        print("Cron has been installed.")
    else:
        print("Cron is already installed.")

def get_user_input():
    while True:
        try:
            hour = int(input("Please enter an hour (0-23): "))
            if 0 <= hour <= 23:
                return hour
            else:
                print("Invalid input. Hour must be between 0 and 23.")
        except ValueError:
            print("Invalid input. Please enter an integer.")

def setup_cron_job(hour):
    # Define the cron job
    cron_job = f"0 {hour} * * * /usr/bin/env bash -c 'x-ui restart'\n"
    
    # Write the cron job to the user's crontab
    with open("mycron", "w") as cron_file:
        cron_file.write(cron_job)
    
    # Install the new cron file
    os.system('crontab mycron')
    os.remove("mycron")
    print(f"Cron job has been set to run 'x-ui restart' at {hour}:00 every day.")

if __name__ == "__main__":
    check_and_install_cron()
    user_hour = get_user_input()
    setup_cron_job(user_hour)
