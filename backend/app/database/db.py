from contextlib import contextmanager

import psycopg2
from app.config import settings
from app.logger import logger


@contextmanager
def get_db_connection():
    conn = None
    try:
        logger.info("Connecting to the database...")
        conn = psycopg2.connect(settings.DATABASE_URL)
        yield conn
        conn.commit()
    except Exception as e:
        logger.error(f"Database connection error: {e}")
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            conn.close()
            logger.info("Database connection closed.")
