from sqlalchemy import Column, Integer, String, Date, ForeignKey, Table
from sqlalchemy.orm import relationship
from database import Base
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey # Agregamos DateTime y ForeignKey
from datetime import datetime # Agregamos esta para el valor por defecto
#CLASES QUE CREAN LAS TABLAS EN MI BASE DE DATOS
#1. TABLAS DE LIBROS
class Libro(Base):
    __tablename__ = "libros"
    id_libro = Column(Integer, primary_key=True, index=True)
    titulo = Column(String)
    autor = Column(String)  # Ahora es texto puro
    anio = Column(String) #Año de
    nro_ejemplar = Column(Integer) # Coincide con tu main.py

class Solicitante(Base):
    __tablename__ = "solicitantes"
    cedula_solicitante = Column(String, primary_key=True, index=True)
    nombre_solicitante = Column(String)
    apellido_solicitante = Column(String)
    telefono_solicitante = Column(String)
    correo_solicitante = Column(String)
    facultad = Column(String)

class Prestamo(Base):
    __tablename__ = "prestamos"
    id_prestamo = Column(Integer, primary_key=True, index=True)
    cedula_solicitante = Column(String)
    nombre = Column(String)
    apellido = Column(String)
    facultad = Column(String)
    telefono = Column(String)  
    correo = Column(String)    
    id_libro = Column(Integer, ForeignKey("libros.id_libro")) # Relación con la tabla libros
    fecha_prestamo = Column(DateTime, default=datetime.utcnow)
    estatus = Column(String, default="PRESTADO")

#2. TABLA DE USUARIO
class Usuario(Base):
    __tablename__ = "usuarios"
    id_usuario = Column(Integer, primary_key=True, index=True)
    nombre_usuario = Column(String, unique=True, index=True)
    clave = Column(String)
    rol = Column(String, default="usuario")

    def __repr__(self):
        return f"<Usuario(id_usuario={self.id_usuario}, nombre_usuario='{self.nombre_usuario}', rol='{self.rol}')>"