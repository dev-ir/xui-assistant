import sqlite3
import os

db_path = '/etc/x-ui/x-ui.db'


def change_password(db_path):
    if not os.path.exists(db_path):
        print("Database file does not exist.")
        return

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    username = input("Enter username: ")

    cursor.execute("SELECT COUNT(*) FROM users WHERE username=?", (username,))
    if cursor.fetchone()[0] == 0:
        print("Username does not exist.")
        conn.close()
        return

    new_password = input("Enter new password: ")
    confirm_password = input("Re-enter new password: ")

    if new_password != confirm_password:
        print("Passwords do not match.")
        conn.close()
        return

    cursor.execute("UPDATE users SET password=? WHERE username=?", (new_password, username))
    conn.commit()
    print("Password updated successfully.")

    conn.close()

change_password(db_path)
