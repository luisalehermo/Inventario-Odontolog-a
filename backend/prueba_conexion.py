from database import engine
try:
    connection = engine.connect()
    print("¡Conexión exitosa a la base de datos de la USM!")
    connection.close()
except Exception as e:
    print(f"Error al conectar: {e}")