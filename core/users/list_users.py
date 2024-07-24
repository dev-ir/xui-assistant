import sqlite3
import os

# file directory
db_path = '/etc/x-ui/x-ui.db'

# file exist
if not os.path.exists(db_path):
    print("Database file does not exist.")
    exit(1)

# connection to database
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# SQL execute
cursor.execute("SELECT id, username, password FROM users ORDER BY id")
users = cursor.fetchall()

# close connection databse
conn.close()
print("+=====================================================+")
print("|==================    X-UI Users    =================|")
print("+=====================================================+")
header = "| {:^5} | {:^20} | {:^20} |".format('ID', 'Username', 'Password')
separator = "+{:-^7}+{:-^22}+{:-^22}+".format('', '', '')
print(separator)
print(header)
print(separator)
for user in users:
    print("| {:^5} | {:^20} | {:^20} |".format(user[0], user[1], user[2]))
    print(separator)
