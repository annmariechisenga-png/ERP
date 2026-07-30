"""
Database configuration for MarshaERP
"""
import os

class Config:
    # Application settings
    APP_NAME = "MarshaERP"
    APP_VERSION = "1.0.0-dev"
    DOMAIN = os.getenv('MARSHA_DOMAIN', 'localhost')
    
    # PostgreSQL configuration
    POSTGRES_HOST = os.getenv('POSTGRES_HOST', 'localhost')
    POSTGRES_PORT = os.getenv('POSTGRES_PORT', '5432')
    POSTGRES_DB = os.getenv('POSTGRES_DB', 'hr_platform')
    POSTGRES_USER = os.getenv('POSTGRES_USER', 'postgres')
    POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'marshaerp2026')
    
    # Development mode
    DEBUG = os.getenv('DEBUG', 'True').lower() == 'true'
    
    @classmethod
    def get_postgres_url(cls):
        return f"postgresql://{cls.POSTGRES_USER}:{cls.POSTGRES_PASSWORD}@{cls.POSTGRES_HOST}:{cls.POSTGRES_PORT}/{cls.POSTGRES_DB}"
    
    @classmethod
    def get_postgres_params(cls):
        return {
            'host': cls.POSTGRES_HOST,
            'port': cls.POSTGRES_PORT,
            'database': cls.POSTGRES_DB,
            'user': cls.POSTGRES_USER,
            'password': cls.POSTGRES_PASSWORD
        }
    
    @classmethod
    def get_app_info(cls):
        return {
            'name': cls.APP_NAME,
            'version': cls.APP_VERSION,
            'domain': cls.DOMAIN,
            'debug': cls.DEBUG
        }