from sqlalchemy import create_engine  # <--- CORREGIDO
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Tu URL de conexión (verifica que tu contraseña sea la correcta)
SQLALCHEMY_DATABASE_URL = "postgresql://postgres:superadmin1234@localhost:5433/Biblioteca_USM"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Función para obtener la sesión de la base de datos
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()