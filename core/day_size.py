import sqlite3
import time
import json

DB_PATH = '/etc/x-ui/x-ui.db'

def dvhost_connect_to_db():
    return sqlite3.connect(DB_PATH)

def dvhost_convert_days_to_unix_millis(days):
    try:
        expiration_time_millis = (int(days) * 86400) * 1000
        return int(expiration_time_millis)
    except ValueError:
        print("Invalid number of days. Please enter a valid integer.")
        return None

def dvhost_update_expiry_time(days):
    additional_time_millis = dvhost_convert_days_to_unix_millis(days)
    if additional_time_millis is None:
        return

    conn = dvhost_connect_to_db()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id, expiry_time, total FROM client_traffics")
        client_traffics = cursor.fetchall()
        for client_id, expiry_time, total in client_traffics:
            if expiry_time > 0:
                new_expiry_time = expiry_time + additional_time_millis
                cursor.execute("UPDATE client_traffics SET expiry_time = ? WHERE id = ?", (new_expiry_time, client_id))
        cursor.execute("SELECT id, settings FROM inbounds")
        inbounds = cursor.fetchall()

        for inbound_id, settings_json in inbounds:
            settings = json.loads(settings_json)
            if 'clients' in settings:
                for client in settings['clients']:
                    if client['enable'] and client['expiryTime'] > 0:
                        client['expiryTime'] += additional_time_millis
                new_settings_json = json.dumps(settings)
                cursor.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (new_settings_json, inbound_id))

        conn.commit()
        print("Expiry time and totalGB updated successfully.")
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
    finally:
        conn.close()

def dvhost_update_traffic():
    additional_gb = input("Enter additional gigabytes to add to totalGB: ")
    try:
        additional_gb = int(additional_gb)
        additional_bytes = additional_gb * 1024 * 1024 * 1024
    except ValueError:
        print("Invalid number of gigabytes. Please enter a valid integer.")
        return

    conn = dvhost_connect_to_db()
    try:
        cursor = conn.cursor()
        
        # Update total in client_traffics
        cursor.execute("SELECT id, total FROM client_traffics")
        client_traffics = cursor.fetchall()
        for client_id, total in client_traffics:
            if total > 0:
                new_total = total + additional_bytes
                cursor.execute("UPDATE client_traffics SET total = ? WHERE id = ?", (new_total, client_id))

        # Update totalGB in inbounds
        cursor.execute("SELECT id, settings FROM inbounds")
        inbounds = cursor.fetchall()

        for inbound_id, settings_json in inbounds:
            settings = json.loads(settings_json)
            if 'clients' in settings:
                for client in settings['clients']:
                    if client['enable'] and client['totalGB'] > 0:
                        client['totalGB'] += additional_bytes

                new_settings_json = json.dumps(settings)
                cursor.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (new_settings_json, inbound_id))

        conn.commit()
        print("Traffic updated successfully.")
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
    finally:
        conn.close()

def dvhost_main():
    try:
        while True:
            print("\n1- Update Expiration Date\n2- Update Traffic\n0- Exit")
            choice = input("Enter your choice: ")

            if choice == '1':
                days = input("Enter number of days for expiration: ")
                dvhost_update_expiry_time(days)
            elif choice == '2':
                dvhost_update_traffic()
            elif choice == '0':
                break
            else:
                print("Invalid choice. Please enter a valid option.")
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    print("x-ui Assistant Version 1.9")
    dvhost_main()
