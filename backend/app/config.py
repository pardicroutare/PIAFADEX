from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    openai_api_key: str = Field(default="", alias="OPENAI_API_KEY")
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    openai_api_key: str = Field(alias="OPENAI_API_KEY")
    app_env: str = Field(default="production", alias="APP_ENV")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")
    temp_dir: str = Field(default="/tmp/piafadex", alias="TEMP_DIR")
    host: str = Field(default="0.0.0.0", alias="HOST")
    port: int = Field(default=8000, alias="PORT")
    openai_model_analyze: str = Field(default="gpt-5", alias="OPENAI_MODEL_ANALYZE")
    openai_model_audio: str = Field(default="gpt-5", alias="OPENAI_MODEL_AUDIO")
    request_timeout_seconds: int = Field(default=15, alias="REQUEST_TIMEOUT_SECONDS")

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
