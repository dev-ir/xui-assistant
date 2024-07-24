import sqlite3
import os

db_path = '/etc/x-ui/x-ui.db'

if not os.path.exists(db_path):
    print("Database file does not exist.")
    exit(1)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

user_id = input("Enter User ID: ")

cursor.execute("SELECT COUNT(*) FROM users WHERE id=?", (user_id,))
if cursor.fetchone()[0] < 0:
    print("User not exists.")
else:
    cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
    conn.commit()
    print("User added successfully.")

conn.close()
