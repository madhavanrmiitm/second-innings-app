from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    DATABASE_URL: str
    FIREBASE_ADMIN_SDK_PATH: str = (
        "second-innings-iitm-firebase-adminsdk-fbsvc-3521fdd41b.json"
    )
    GEMINI_API_KEY: str

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
