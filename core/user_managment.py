import sqlite3
from datetime import datetime


import os

# کدهای رنگ برای نمایش رنگ‌ها
GREEN = "\033[32m"
RED = "\033[31m"
YELLOW = "\033[33m"
RESET = "\033[0m"

def display_menu():
    # اطلاعات سرور
    os.system("clear")
    print("+----------------------------------------------------------------------------------------------------+")
    print("|  _    _                    __  __                                                            _     |")
    print("| | |  | |                  |  \/  |                                                          | |    |")
    print("| | |  | | ___   ___  _ __  | \  / |  __ _  _ __    __ _   __ _   ___  _ __ ___    ___  _ __  | |_   |")
    print("| | |  | |/ __| / _ \|  __| | |\/| | / _  ||  _ \  / _  | / _  | / _ \|  _   _ \  / _ \|  _ \ | __|  |")
    print("| | |__| |\__ \|  __/| |    | |  | || (_| || | | || (_| || (_| ||  __/| | | | | ||  __/| | | || |_   |")
    print("|  \____/ |___/ \___||_|    |_|  |_| \__,_||_| |_| \__,_| \__, | \___||_| |_| |_| \___||_| |_| \__|  |")
    print("|                                                          __/ |                                     |")
    print("|                                                         |___/                                      |")
    print("+----------------------------------------------------------------------------------------------------+")
    print(f"|  Telegram Channel : {GREEN}@DVHOST_CLOUD{RESET}   |   YouTube : {RED}youtube.com/@dvhost_cloud{RESET}")
    print("+----------------------------------------------------------------------------------------------------+")
    print(f"|{YELLOW} Please choose an option:{RESET}")
    print("+----------------------------------------------------------------------------------------------------+")
    print("| 1- Users with upcoming expiry dates                                                                |")
    print("| 2- Users with low remaining volume                                                                 |")
    print("| 3- Admin Manager                                                                                   |")
    print("| 0- Back                                                                                            |")
    print("+----------------------------------------------------------------------------------------------------+")


class DvhostCloudDB:
    # کدهای رنگ برای نمایش پیام‌ها
    RED = "\033[91m"
    RESET = "\033[0m"
    
    def __init__(self, db_path="/etc/x-ui/x-ui.db"):
        self.db_path = db_path
        self.connection = None
        # بررسی وجود فایل دیتابیس
        if not os.path.exists(self.db_path):
            print(f"{self.RED}Database file not found. Please visit our Telegram channel for support:")
            print("https://t.me/dvhost_cloud" + self.RESET)
            exit()  # خروج از برنامه در صورت عدم وجود فایل دیتابیس
        self.dvhost_cloud_connect()

    def dvhost_cloud_connect(self):
        """Connects to the SQLite database and displays a connection message."""
        try:
            self.connection = sqlite3.connect(self.db_path)
            print("Connected to the database successfully.")
        except sqlite3.Error as e:
            print(f"Failed to connect to the database: {e}")
            self.connection = None

    def dvhost_cloud_query(self, query, params=()):
        """Executes a query on the database and returns the results if connected."""
        if self.connection is None:
            print("No database connection available.")
            return None
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, params)
            results = cursor.fetchall()
            return results
        except sqlite3.Error as e:
            print(f"An error occurred while executing the query: {e}")
            return None

    def dvhost_cloud_calculate_size(self, size_in_bytes):
        """Converts size from bytes to the nearest unit and returns it with the unit."""
        units = ["B", "KB", "MB", "GB", "TB"]
        size = size_in_bytes
        unit_index = 0

        while size >= 1024 and unit_index < len(units) - 1:
            size /= 1024
            unit_index += 1

        return f"{size:.2f} {units[unit_index]}"

    def dvhost_cloud_time_left(self, expiry_time):
        """Calculates the days and hours left until the expiry time."""
        current_timestamp = int(datetime.now().timestamp() * 1000)
        time_left_ms = expiry_time - current_timestamp
        days_left = time_left_ms // (1000 * 60 * 60 * 24)
        hours_left = (time_left_ms % (1000 * 60 * 60 * 24)) // (1000 * 60 * 60)
        return days_left, hours_left

    def dvhost_cloud_expire_time(self):
        """Displays users with remaining volume under 5 GB in a table format."""
        self.clear_screen()
        print("{:<5} {:<25} {:<20}".format("No.", "Email", "Remaining Volume"))
        print("=" * 50)
        query = """
        SELECT email, total, down, up, (total - (down + up)) AS remaining_volume 
        FROM client_traffics
        """
        results = self.dvhost_cloud_query(query)
        
        if results:
            index = 1
            for email, total, down, up, remaining_volume in results:
                if 0 < remaining_volume < 5 * 1024 ** 3:
                    remaining_converted = self.dvhost_cloud_calculate_size(remaining_volume)
                    print("{:<5} {:<25} {:<20}".format(index, email, remaining_converted))
                    index += 1
            if index == 1:
                print("No users with remaining volume under 5 GB.")
        else:
            print("No data found.")

    def dvhost_cloud_expire_vol(self):
        """Displays users with expiry dates within the next 2 days in a table format."""
        self.clear_screen()
        print("{:<5} {:<25} {:<30}".format("No.", "Email", "Time Left"))
        print("=" * 60)
        results = self.dvhost_cloud_query(
            """
            SELECT expiry_time, email 
            FROM client_traffics 
            WHERE expiry_time > strftime('%s', 'now') * 1000 
              AND expiry_time <= (strftime('%s', 'now', '+2 day')) * 1000 
            ORDER BY rowid ASC
            """
        )
        
        if results:
            for index, (expiry_time, email) in enumerate(results, start=1):
                days_left, hours_left = self.dvhost_cloud_time_left(expiry_time)
                print("{:<5} {:<25} {:<30}".format(index, email, f"{days_left} days and {hours_left} hours"))
            if index == 1:
                print("No users with upcoming expiry dates within 2 days.")
        else:
            print("No data found.")

    def clear_screen(self):
        """Clears the console screen."""
        os.system('cls' if os.name == 'nt' else 'clear')

    def dvhost_cloud_close(self):
        """Closes the database connection."""
        if self.connection:
            self.connection.close()
            print("Database connection closed.")

if __name__ == "__main__":
    db = DvhostCloudDB()
    try:
        while True:
            display_menu()
            choice = input("Please enter your choice (1, 2, 3, 4...): ")
            
            if choice == '1':
                os.system('cls' if os.name == 'nt' else 'clear')
                print("Displaying users with upcoming expiry dates...")
                db.dvhost_cloud_expire_vol()
            elif choice == '2':
                os.system('cls' if os.name == 'nt' else 'clear')
                print("Displaying users with low remaining volume...")
                db.dvhost_cloud_expire_time()
            elif choice == '3':
                os.system('cls' if os.name == 'nt' else 'clear')
                print("Adding a new admin...")
                os.system("cd ~/xui-assistant && python3 core/user_manager.py")
            elif choice == '0':
                os.system('cls' if os.name == 'nt' else 'clear')
                print("Returning to the previous menu...")
                os.system("xui-assis")
                break
            else:
                print("Invalid choice. Please try again.")
            
            input("\nPress Enter to return to the menu...")
    except KeyboardInterrupt:
        print("\nProgram interrupted. Exiting cleanly...")
        db.dvhost_cloud_close()

