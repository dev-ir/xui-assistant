import os
import sqlite3
import subprocess

db_path = '/etc/x-ui/x-ui.db'

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def get_db_connection():
    if not os.path.exists(db_path):
        print("Database file does not exist.")
        input("Press Enter to continue...")
        return None
    conn = sqlite3.connect(db_path)
    return conn

def dvhost_add_user():
    conn = get_db_connection()
    if conn is None:
        return
    cursor = conn.cursor()

    username = input("Enter username: ")
    password = input("Enter password: ")

    cursor.execute("SELECT COUNT(*) FROM users WHERE username=?", (username,))
    if cursor.fetchone()[0] > 0:
        print("\033[91mUsername already exists.\033[0m")
    else:
        cursor.execute("INSERT INTO users (username, password, login_secret) VALUES (?, ?, ?)", (username, password, ''))
        conn.commit()
        print("\033[92mUser added successfully.\033[0m")

    conn.close()
    input("Press Enter to continue...")

def dvhost_delete_user():
    conn = get_db_connection()
    if conn is None:
        return
    cursor = conn.cursor()

    user_id = input("Enter User ID: ")

    cursor.execute("SELECT COUNT(*) FROM users WHERE id=?", (user_id,))
    if cursor.fetchone()[0] == 0:
        print("User does not exist.")
    else:
        confirm = input("Are you sure you want to delete this user? (yes/no): ").lower()
        if confirm == 'yes':
            cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
            conn.commit()
            print("\033[92mUser deleted successfully.\033[0m")
        else:
            print("Operation cancelled.")

    conn.close()
    input("Press Enter to continue...")

def dvhost_change_password():
    conn = get_db_connection()
    if conn is None:
        return
    cursor = conn.cursor()

    username = input("Enter username: ")

    cursor.execute("SELECT COUNT(*) FROM users WHERE username=?", (username,))
    if cursor.fetchone()[0] == 0:
        print("Username does not exist.")
        conn.close()
        input("Press Enter to continue...")
        return

    new_password = input("Enter new password: ")
    confirm_password = input("Re-enter new password: ")

    if new_password != confirm_password:
        print("Passwords do not match.")
        conn.close()
        input("Press Enter to continue...")
        return

    cursor.execute("UPDATE users SET password=? WHERE username=?", (new_password, username))
    conn.commit()
    print("\033[92mPassword updated successfully.\033[0m")

    conn.close()
    input("Press Enter to continue...")

def dvhost_list_users():
    conn = get_db_connection()
    if conn is None:
        return
    cursor = conn.cursor()

    cursor.execute("SELECT id, username, password, login_secret FROM users ORDER BY id")
    users = cursor.fetchall()

    conn.close()
    print("+============================================================================+")
    print("|==============================    X-UI Users    ============================|")
    print("+============================================================================+")
    header = "| {:^5} | {:^20} | {:^20} | {:^20} |".format('ID', 'Username', 'Password', 'Login Secret')
    separator = "+{:-^7}+{:-^22}+{:-^22}+{:-^22}+".format('', '', '', '')
    print(separator)
    print(header)
    print(separator)
    for user in users:
        print("| {:^5} | {:^20} | {:^20} | {:^20} |".format(user[0], user[1], user[2], user[3]))
        print(separator)

def main():
    while True:
        clear_screen()
        dvhost_list_users()
        
        print("\n1. Add User")
        print("2. Delete User")
        print("3. Change Password")
        print("4. Exit")

        choice = input("\nEnter your choice: ")

        if choice == '1':
            dvhost_add_user()
        elif choice == '2':
            dvhost_delete_user()
        elif choice == '3':
            dvhost_change_password()
        elif choice == '4':
            subprocess.run(['bash', '-c', 'curl -Ls https://raw.githubusercontent.com/dev-ir/xui-assistant/master/install.sh | bash'], check=True)
            break
        else:
            print("Invalid choice, please try again.")
            input("Press Enter to continue...")

if __name__ == "__main__":
    main()
