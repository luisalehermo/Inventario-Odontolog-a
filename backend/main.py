from fastapi import FastAPI, Depends, HTTPException, Request, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import or_, text
from pydantic import BaseModel
from typing import List, Optional
from datetime import date, datetime
import csv
from io import StringIO, BytesIO

import models, database

from sqlalchemy import text

# Función mágica para actualizar la DB sin borrar tablas
def actualizar_base_de_datos(engine):
    with engine.connect() as conn:
        # Aquí añades las columnas nuevas que vayas creando
        try:
            conn.execute(text("ALTER TABLE prestamos ADD COLUMN IF NOT EXISTS telefono VARCHAR"))
            conn.execute(text("ALTER TABLE prestamos ADD COLUMN IF NOT EXISTS correo VARCHAR"))
            conn.commit()
        except Exception as e:
            print(f"La base de datos ya está al día: {e}")

# Ejecútala justo antes de iniciar la app
actualizar_base_de_datos(models.database.engine)

# Crear tablas si no existen (Usa el nuevo models.py simplificado)
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()

# Configuración de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- MOLDES DE DATOS (SCHEMAS) ACTUALIZADOS ---
class LibroCreate(BaseModel):
    titulo: str
    autor: str
    anio: Optional[str] = None
    cantidad: int = 1

class UsuarioCreate(BaseModel):
    nombre_usuario: str
    clave: str

class PrestamoCreate(BaseModel):
    cedula_solicitante: str
    id_libro: int
    nombre: str
    apellido: str
    facultad: str
    telefono: str  
    correo: str
    estatus: str = "PRESTADO"

# --- RUTAS (ENDPOINTS) ---

@app.post("/libros/")
def crear_libro(libro: LibroCreate, db: Session = Depends(database.get_db)):
    try:
        nuevo_libro = models.Libro(
            titulo=libro.titulo,
            autor=libro.autor,
            anio=libro.anio,
            nro_ejemplar=libro.cantidad
        )
        db.add(nuevo_libro)
        db.commit()
        db.refresh(nuevo_libro)
        return nuevo_libro
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al registrar: {str(e)}")

@app.get("/libros/")
def listar_libros(q: str | None = None, db: Session = Depends(database.get_db)):
    """Busca libros por título o autor de forma simple."""
    query = db.query(models.Libro)
    if q:
        patron = f"%{q}%"
        query = query.filter(
            or_(
                models.Libro.titulo.ilike(patron),
                models.Libro.autor.ilike(patron)
            )
        )
    return query.all()


# --- IMPORTACIÓN MASIVA DESDE EXCEL/CSV ---
@app.post("/importar_libros/")
async def importar_libros(file: UploadFile = File(...), db: Session = Depends(database.get_db)):
    """
    Lee tus archivos CSV y los carga directamente a la base de datos
    usando la estructura simplificada.
    """
    try:
        contents = await file.read()
        decoded = contents.decode('utf-8')
        reader = csv.DictReader(StringIO(decoded))
        
        inserted = 0
        for row in reader:
            # Normalizamos los nombres de las columnas de tus archivos
            titulo = row.get('TÍTULO') or row.get('Título') or row.get('TITULO')
            autor = row.get('AUTOR') or row.get('Autor') or "Anónimo"
            anio = row.get('AÑO') or row.get('Año') or ""
            ejemplares = row.get('EJEMPLARES') or row.get('NÚMERO DE EJEMPLARES') or 1
            
            if titulo:
                nuevo = models.Libro(
                    titulo=titulo.strip(),
                    autor=autor.strip(),
                    anio=str(anio).strip(),
                    nro_ejemplar=int(ejemplares)
                )
                db.add(nuevo)
                inserted += 1
        
        db.commit()
        return {"mensaje": f"Se importaron {inserted} libros exitosamente"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error en la importación: {str(e)}")
    
#ENDPOINT PARA PROCESAR PRESTAMOS
@app.post("/prestamos/")
def crear_prestamo(prestamo: PrestamoCreate, db: Session = Depends(database.get_db)):
    try:
        nuevo_prestamo = models.Prestamo(
            cedula_solicitante=prestamo.cedula_solicitante,
            id_libro=prestamo.id_libro,
            nombre=prestamo.nombre,
            apellido=prestamo.apellido,
            facultad=prestamo.facultad,
            telefono=prestamo.telefono,
            correo=prestamo.correo,
            estatus=prestamo.estatus
        )
        db.add(nuevo_prestamo)
        db.commit()
        db.refresh(nuevo_prestamo)
        return {"mensaje": "Préstamo registrado con éxito", "id": nuevo_prestamo.id_prestamo}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al procesar préstamo: {str(e)}")

# Buscar préstamos por cédula
@app.get("/prestamos/cedula/{cedula}")
def obtener_prestamos_por_cedula(cedula: str, db: Session = Depends(database.get_db)):    # Buscamos coincidencias exactas y que el libro no haya sido devuelto aún
    prestamos = db.query(models.Prestamo).filter(
        models.Prestamo.cedula_solicitante == cedula,
        models.Prestamo.estatus == "PRESTADO"
    ).all()
    
    if not prestamos:
        return [] # Flutter recibirá una lista vacía y mostrará el mensaje rojo
        
    return prestamos

# Registrar la devolución (cambiar estatus)

@app.put("/prestamos/devolver/{id_prestamo}")
def devolver_libro(id_prestamo: int, db: Session = Depends(database.get_db)):
    # 1. Buscamos el préstamo en la base de datos por su ID
    db_prestamo = db.query(models.Prestamo).filter(models.Prestamo.id_prestamo == id_prestamo).first()
    
    # 2. Si no existe, avisamos
    if not db_prestamo:
        raise HTTPException(status_code=404, detail="El préstamo no existe")
    
    # 3. Cambiamos el estatus a DEVUELTO
    db_prestamo.estatus = "DEVUELTO"
    
    # 4. Guardamos los cambios en PostgreSQL
    db.commit()
    
    return {"message": "¡Libro devuelto con éxito!"}
    
# --- USUARIOS ---
@app.post("/usuarios/")
def registrar_usuario(usuario: UsuarioCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.Usuario).filter(models.Usuario.nombre_usuario == usuario.nombre_usuario).first()
    if db_user:
        raise HTTPException(status_code=400, detail="El usuario ya existe")
    
    nuevo_usuario = models.Usuario(nombre_usuario=usuario.nombre_usuario, clave=usuario.clave)
    db.add(nuevo_usuario)
    db.commit()
    return {"mensaje": "Usuario creado con éxito"}