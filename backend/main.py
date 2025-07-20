import argparse
import os
from contextlib import asynccontextmanager

from app.database.init_db import initialize_schema
from app.logger import logger
from app.routes import auth as auth_routes
from app.routes import user as user_routes
from app.routes import family as family_routes
from app.routes import care as care_routes
from app.routes import tasks as tasks_routes
from app.routes import interest_groups as interest_groups_routes
from app.routes import tickets as tickets_routes
from app.routes import notifications as notifications_routes
from app.routes import admin as admin_routes
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Application startup")

    # Check if database initialization is requested via environment variable
    init_db = os.getenv("INIT_DB_ON_STARTUP", "false").lower() == "true"
    if init_db:
        logger.info("Database initialization flag detected. Initializing schema...")
        try:
            initialize_schema()
            logger.info("Database schema initialization completed successfully")
        except Exception as e:
            logger.error(f"Failed to initialize database schema: {e}")
            raise

    yield
    logger.info("Application shutdown")


app = FastAPI(lifespan=lifespan)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

app.include_router(auth_routes.router, prefix="/api")
app.include_router(user_routes.router, prefix="/api")
app.include_router(family_routes.router, prefix="/api")
app.include_router(care_routes.router, prefix="/api")
app.include_router(tasks_routes.router, prefix="/api")
app.include_router(interest_groups_routes.router, prefix="/api")
app.include_router(tickets_routes.router, prefix="/api")
app.include_router(notifications_routes.router, prefix="/api")
app.include_router(admin_routes.router, prefix="/api")


@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI application"}


def main():
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(description="FastAPI Application Server")
    parser.add_argument(
        "--init-db",
        action="store_true",
        help="Initialize database schema from schema.sql on startup",
    )
    parser.add_argument(
        "--host",
        default="127.0.0.1",
        help="Host to bind the server to (default: 127.0.0.1)",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8000,
        help="Port to bind the server to (default: 8000)",
    )
    parser.add_argument(
        "--reload", action="store_true", help="Enable auto-reload for development"
    )

    args = parser.parse_args()

    # Set environment variable for database initialization
    if args.init_db:
        os.environ["INIT_DB_ON_STARTUP"] = "true"
        logger.info("Database schema will be initialized on startup")

    # Import uvicorn here to avoid import issues
    import uvicorn

    logger.info(f"Starting server on {args.host}:{args.port}")

    # Start the server
    uvicorn.run("main:app", host=args.host, port=args.port, reload=args.reload)


if __name__ == "__main__":
    main()
