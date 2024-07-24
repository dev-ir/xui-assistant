import subprocess
import os

def check_and_install_cron():
    # Check if crontab is installed
    cron_check = subprocess.run(['which', 'crontab'], capture_output=True, text=True)
    
    if cron_check.returncode != 0:
        print("Crontab is not installed. Installing cron...")
        # Install crontab
        os.system('sudo apt-get update')
        os.system('sudo apt-get install cron')
        print("Crontab has been installed.")
        # Start cron service
        os.system('sudo systemctl enable cron')
        os.system('sudo systemctl start cron')
    else:
        print("Crontab is already installed.")

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

def list_cron_jobs():
    result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
    if result.returncode != 0:
        print("No crontab for this user or crontab is not installed.")
        return []
    
    cron_jobs = result.stdout.strip().split('\n')
    if not cron_jobs or cron_jobs == ['']:
        print("No cron jobs found.")
        return []
    
    print("Current cron jobs:")
    for i, job in enumerate(cron_jobs):
        print(f"{i+1}: {job}")
    
    return cron_jobs

def delete_cron_job(cron_jobs):
    if not cron_jobs:
        return
    
    while True:
        try:
            job_number = int(input("Enter the number of the cron job to delete (0 to cancel): "))
            if job_number == 0:
                print("Operation cancelled.")
                return
            elif 1 <= job_number <= len(cron_jobs):
                break
            else:
                print(f"Invalid input. Please enter a number between 0 and {len(cron_jobs)}.")
        except ValueError:
            print("Invalid input. Please enter a valid number.")
    
    del cron_jobs[job_number-1]
    
    with open("mycron", "w") as cron_file:
        for job in cron_jobs:
            cron_file.write(job + '\n')
    
    os.system('crontab mycron')
    os.remove("mycron")
    print("Cron job has been deleted.")

def main():
    check_and_install_cron()
    while True:
        print("\nMenu:")
        print("1- Set Cronjob Restart X-UI")
        print("2- Delete Cronjob")
        print("3- Exit")
        
        choice = input("Enter your choice: ")
        
        if choice == '1':
            user_interval = get_user_input()
            setup_cron_job(user_interval)
        elif choice == '2':
            cron_jobs = list_cron_jobs()
            delete_cron_job(cron_jobs)
        elif choice == '3':
            print("Exiting...")
            os.system('bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/xui-assistant/master/main.sh)')
            break
        else:
            print("Invalid choice. Please enter 1, 2, or 3.")

if __name__ == "__main__":
    main()
