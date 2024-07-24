import sqlite3
import os

db_path = '/etc/x-ui/x-ui.db'

if not os.path.exists(db_path):
    print("Database file does not exist.")
    exit(1)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

username = input("Enter username: ")
password = input("Enter password: ")

cursor.execute("SELECT COUNT(*) FROM users WHERE username=?", (username,))
if cursor.fetchone()[0] > 0:
    print("Username already exists.")
else:
    cursor.execute("INSERT INTO users (username, password, login_secret) VALUES (?, ?, ?)", (username, password, ''))
    conn.commit()
    print("User added successfully.")

conn.close()
