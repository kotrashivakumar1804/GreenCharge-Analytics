
import pandas as pd
import mysql.connector
from mysql.connector import Error
from getpass import getpass

# 1. Load the cleaned dataset
df = pd.read_csv("cleaned_data.csv")

print("Dataset loaded successfully!")
print("Rows:", len(df))
print("Columns:", df.columns.tolist())

connection = None
cursor = None

try:
    # 2. Connect to MySQL
    password = getpass("Enter your MySQL password: ")

    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password=password,
        database="ev_charging_db"
)

    cursor = connection.cursor()


    table_name = "ev_charging_data"

    column_definitions = []
    for column in df.columns:
        safe_column = column.replace("`", "")
        column_definitions.append(f"`{safe_column}` TEXT")

    create_sql = (
        f"CREATE TABLE IF NOT EXISTS `{table_name}` ("
        + ", ".join(column_definitions)
        + ")"
    )

    cursor.execute(create_sql)

    # 4. Insert the cleaned records
    columns_sql = ", ".join(f"`{col.replace('`', '')}`" for col in df.columns)
    placeholders = ", ".join(["%s"] * len(df.columns))

    insert_sql = (
        f"INSERT INTO `{table_name}` ({columns_sql}) "
        f"VALUES ({placeholders})"
    )

    # Convert missing values to SQL NULL
    data = [
        tuple(None if pd.isna(value) else str(value) for value in row)
        for row in df.itertuples(index=False, name=None)
    ]

    cursor.executemany(insert_sql, data)
    connection.commit()

    print("Upload completed successfully!")
    print("Rows inserted:", cursor.rowcount)
    print("Table:", table_name)

except (Error, FileNotFoundError) as e:
    if connection and connection.is_connected():
        connection.rollback()
    print("Error:", e)

finally:
    if cursor:
        cursor.close()
    if connection and connection.is_connected():
        connection.close()
        print("MySQL connection closed.")
