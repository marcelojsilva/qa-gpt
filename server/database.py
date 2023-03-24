import sqlite3
from sqlite3 import Error
from config import *
import os

def upsert_text_dict(file_name, extracted_text):
    conn = create_connection(DATABASE_NAME)
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT OR REPLACE INTO text_dict (file_name, extracted_text) VALUES (?, ?)", (file_name, extracted_text))
        conn.commit()
        print("Data upserted successfully.")
    except Error as e:
        print(f"Error: {e}")
    finally:
        conn.close()
    return True
    
def insert_questions_answers(question, answer):
    conn = create_connection(DATABASE_NAME)
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO questions_answers (question, answer) VALUES (?, ?)", (question, answer))
        conn.commit()
        print("Data upserted successfully.")
    except Error as e:
        print(f"Error: {e}")
    finally:
        conn.close()
    return True

def query_text_dict(file_name=None):
    conn = create_connection(DATABASE_NAME)
    cursor = conn.cursor()
    try:
        if file_name:
            cursor.execute("SELECT * FROM text_dict WHERE file_name = ?", (file_name,))
        else:
            cursor.execute("SELECT * FROM text_dict")
        result = cursor.fetchall()
        conn.close()
        # result list to dict
        result = {file_name: extracted_text for file_name, extracted_text in result}
        return result
    except Error as e:
        conn.close()
        print(f"Error: {e}")
        return None

def create_connection(database=None):
    try:
        db_exists = database_exists(database)
        
        if database is None:
            conn = sqlite3.connect(":memory:")
        else:
            conn = sqlite3.connect(database)
        
        if not db_exists:
            create_tables(conn)

        return conn
    except Error as e:
        print(f"Error: {e}")
        return None

def execute_query(query):
    conn = create_connection(DATABASE_NAME)
    cursor = conn.cursor()

    try:
        cursor.execute(query)
        conn.commit()
        print("Query executed successfully.")
    except Error as e:
        print(f"Error: {e}")
    finally:
        conn.close()

def fetch_all(query):
    conn = create_connection(DATABASE_NAME)
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchall()
    conn.close()
    return result

def create_tables(conn):
    create_table_text_dict(conn)
    create_table_questions_answers(conn)
    return True

def create_table_text_dict(conn):
    conn = create_connection(DATABASE_NAME)
    table_query = """
    CREATE TABLE IF NOT EXISTS text_dict (
        file_name VARCHAR(255) PRIMARY KEY,
        extracted_text JSON
    )
    """
    execute_query(table_query)
    conn.close()
    return True

def create_table_questions_answers(conn):
    conn = create_connection(DATABASE_NAME)
    table_query = """
    CREATE TABLE IF NOT EXISTS questions_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        answer TEXT
    )
    """
    execute_query(table_query)
    conn.close()
    return True

def database_exists(database_name):
    return os.path.isfile(database_name)
