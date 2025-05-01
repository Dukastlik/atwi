from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class DPSettings(BaseSettings):

    model_config = SettingsConfigDict(
        env_file=str(Path(__file__).parent.parent/'.env'),
        env_file_encoding='utf-8',
        extra='ignore'
    )
    TG_BOT_TOKEN: str = ''
    TG_GROUP_ID: str = ''
    DB_USER: str
    DB_PW: str
    DB_HOST: str
    DB_PORT: str
    DB_NAME: str
    TELEGRAM_API_URL: str = "https://api.telegram.org/bot"
    IS_TELE_APP: bool = True

    @property
    def db_uri(self):
        return (
            f'postgresql://{self.DB_USER}:{self.DB_PW}@'
            f'{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}'
        )

    @property
    def full_tg_groups_api_url(self) -> str:
        return (
            f'{self.TELEGRAM_API_URL}{self.TG_BOT_TOKEN}/getChatMember'
        )

settings = DPSettings()
