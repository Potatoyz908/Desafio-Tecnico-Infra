import os

#DATABASE
SQLALCHEMY_DATABASE_URI = os.environ.get('SQLALCHEMY_DATABASE_URI')

if not SQLALCHEMY_DATABASE_URI:
    raise ValueError(
        "Verifique a variável SQLALCHEMY_DATABASE_URI! "
        "Exemplo: postgresql+psycopg2://user:password@host:port/database"
    )


#gere com: openssl rand -base64 42
SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY')

if not SECRET_KEY:
    raise ValueError(
        "Verifique a variável SUPERSET_SECRET_KEY! "
        "Gere uma com: openssl rand -base64 42"
    )

# Flask-WTF CSRF Protection
WTF_CSRF_ENABLED = True

# Add endpoints that need to be exempt from CSRF protection
# Security: Keep this list as minimal as possible
WTF_CSRF_EXEMPT_LIST = []

# CSRF token expiration time (1 year)
# Security: Consider reducing this for production environments
WTF_CSRF_TIME_LIMIT = 60 * 60 * 24 * 365

# APPLICATION CONFIGURATION
SUPERSET_LOAD_EXAMPLES = False

# OPTIONAL: MAPBOX CONFIGURATION
# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = os.environ.get('MAPBOX_API_KEY', '')

ROW_LIMIT = 50000

PUBLIC_ROLE_LIKE_GAMMA = False
