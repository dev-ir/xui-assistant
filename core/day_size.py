import sqlite3,json,os

def convert_days_to_ms(days):
    return days * 24 * 60 * 60 * 1000

def convert_gigabits_to_bits(gigabits):
    return gigabits * 1024 * 1024 * 1024 * 8

def get_user_input():
    days = float(input("Enter number of days: "))
    gigabits = float(input("Enter size in gigabits: "))
    return days, gigabits

def update_database(day_ms, size_bits):
    conn = sqlite3.connect('/etc/x-ui/x-ui.db')
    cursor = conn.cursor()

    query = f"""
    BEGIN TRANSACTION;

    -- Update client_traffics table
    UPDATE "client_traffics"
    SET 
        "total" = "total" + 1073741824,
        "expiry_time" = "expiry_time" + 86400000;

    -- Update inbounds table
    UPDATE "inbounds"
    SET 
        "settings" = json_set("settings",
            '$.clients[0].totalGB', (json_extract("settings", '$.clients[0].totalGB') + {size_bits}),
            '$.clients[0].expiryTime', (json_extract("settings", '$.clients[0].expiryTime') + {day_ms})
        );

    COMMIT;
    """
    cursor.executescript(query)
    conn.commit()
    conn.close()

def main():
    days, gigabits = get_user_input()
    day_ms = convert_days_to_ms(days)
    size_bits = convert_gigabits_to_bits(gigabits)
    update_database(day_ms, size_bits)
    print("Database updated successfully.")

if __name__ == "__main__":
    main()

