import os
import subprocess

def check_and_install_cron():
    cron_check = subprocess.run(['which', 'crontab'], capture_output=True, text=True)
    
    if cron_check.returncode != 0:
        print("Crontab is not installed. Installing cron...")
        os.system('sudo apt-get update')
        os.system('sudo apt-get install cron')
        print("Crontab has been installed.")
        # Start cron service
        os.system('sudo systemctl enable cron')
        os.system('sudo systemctl start cron')

def get_user_input():
    while True:
        try:
            interval = int(input("Please enter the interval in hours (e.g., 8 for every 8 hours): "))
            if interval > 0 and 24 % interval == 0:
                return interval
            else:
                print("Invalid input. Interval must be a positive divisor of 24 (e.g., 1, 2, 3, 4, 6, 8, 12, 24).")
        except ValueError:
            print("Invalid input. Please enter an integer.")

def setup_cron_job(interval):
    # Define the cron job
    cron_job = f"0 */{interval} * * * /usr/bin/env bash -c 'x-ui restart'\n"
    
    # Write the cron job to the user's crontab
    with open("mycron", "w") as cron_file:
        cron_file.write(cron_job)
    
    # Install the new cron file
    os.system('crontab mycron')
    os.remove("mycron")
    print(f"Cron job has been set to run 'x-ui restart' every {interval} hours.")

if __name__ == "__main__":
    check_and_install_cron()
    user_interval = get_user_input()
    setup_cron_job(user_interval)
