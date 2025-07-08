import os

from app.database.db import get_db_connection
from app.logger import logger


def initialize_schema():
    logger.info("Initializing database schema from schema.sql...")

    # Construct the absolute path to schema.sql
    dir_path = os.path.dirname(os.path.realpath(__file__))
    sql_file_path = os.path.join(dir_path, "schema.sql")

    with get_db_connection() as conn:
        with conn.cursor() as cur:
            try:
                with open(sql_file_path, "r") as f:
                    # Read the entire SQL file and execute it
                    sql_commands = f.read()
                    cur.execute(sql_commands)
                logger.info("Successfully executed schema.sql")
            except FileNotFoundError:
                logger.error(f"Could not find schema.sql at {sql_file_path}")
            except Exception as e:
                logger.error(f"An error occurred while executing schema.sql: {e}")
                raise

    logger.info("Database schema initialization complete.")
