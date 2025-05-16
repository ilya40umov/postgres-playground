import psycopg2
import os
from psycopg2._psycopg import connection
from dotenv import load_dotenv

_dotenv_loaded = False


def get_connection() -> connection:
    global _dotenv_loaded
    if not _dotenv_loaded:
        load_dotenv()

    return psycopg2.connect(
        database="wallet",
        host="localhost",
        port=5432,
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
    )
