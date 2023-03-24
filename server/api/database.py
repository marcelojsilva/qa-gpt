import psycopg2
# from psycopg2 import Error
import os

def upsert_text_dict(file_name, extracted_text):
    conn = create_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO text_dict (file_name, extracted_text) VALUES (%s, %s) ON CONFLICT (file_name) DO UPDATE SET extracted_text = %s", (file_name, extracted_text, extracted_text))
        conn.commit()
        print("Data upserted successfully.")
    # except Error as e:
    #     print(f"Error: {e}")
    finally:
        conn.close()
    return True
    
def insert_questions_answers(question, answer):
    conn = create_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO questions_answers (question, answers) VALUES (%s, %s)", (question, answer))
        conn.commit()
        print("Data upserted successfully.")
    # except Error as e:
    #     print(f"Error: {e}")
    finally:
        conn.close()
    return True

def query_text_dict(file_name=None):
    conn = create_connection()
    cursor = conn.cursor()
    # try:
    if file_name:
        cursor.execute("SELECT * FROM text_dict WHERE file_name = ?", (file_name,))
    else:
        cursor.execute("SELECT * FROM text_dict")
    result = cursor.fetchall()
    conn.close()
    # result list to dict
    result = {file_name: extracted_text for file_name, extracted_text in result}
    return result
    # except Error as e:
    #     conn.close()
    #     print(f"Error: {e}")
    #     return None

def create_connection():
    # try:
    psql = os.environ["DATABASE_URL"]
    conn = psycopg2.connect(psql)

    return conn
    # except Error as e:
    #     print(f"Error: {e}")
    #     return None

def execute_query(query):
    conn = create_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(query)
        conn.commit()
        print("Query executed successfully.")
    # except Error as e:
    #     print(f"Error: {e}")
    finally:
        conn.close()

def fetch_all(query):
    conn = create_connection()
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchall()
    conn.close()
    return result

def create_tables():
    create_table_text_dict()
    create_table_questions_answers()
    return True

def create_table_text_dict():
    table_query = """
    CREATE TABLE IF NOT EXISTS text_dict (
        file_name VARCHAR(255) PRIMARY KEY,
        extracted_text TEXT
    )
    """
    execute_query(table_query)
    return True

def create_table_questions_answers():
    table_query = """
    CREATE TABLE IF NOT EXISTS questions_answers (
        id SERIAL PRIMARY KEY,
        question TEXT,
        answers TEXT
    )
    """
    execute_query(table_query)
    return True
