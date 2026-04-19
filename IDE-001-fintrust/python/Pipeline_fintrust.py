import os
import glob
from google.cloud import bigquery
from google.api_core.exceptions import GoogleAPIError

# === CONFIGURACIÓN ===
# Si no has configurado la variable de entorno GOOGLE_APPLICATION_CREDENTIALS,
# puedes pasar la ruta del JSON aquí:
# os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "ruta/a/tu/llave.json"

# El nombre exacto del archivo que descargaste
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"IDE-001-fintrust\python\prueba-maps-283720-bc3c1e459276.json"

PROJECT_ID = "prueba-maps-283720"
SQL_ROOT_DIR = 'sql'

# --- AJUSTE DE RUTA DINÁMICA ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SQL_ROOT_DIR = os.path.abspath(os.path.join(BASE_DIR, '..', 'sql'))

def get_sql_files_in_order(root_dir):
    search_path = os.path.join(root_dir, '**', '*.sql')
    all_files = glob.glob(search_path, recursive=True)
    return sorted(all_files)

def run_bigquery_script(client, file_path):
    """
    Lee el archivo SQL y lo envía a BigQuery.
    """
    print(f"---Ejecutando en BigQuery: {file_path} ---")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            query = file.read()

        if not query.strip():
            print(f"    [!] Archivo vacío, saltando...")
            return

        # Iniciamos el Query Job
        query_job = client.query(query)
        
        # Esperamos a que la consulta termine (bloqueante)
        query_job.result() 
        
        print(f"    [OK] Ejecución finalizada correctamente.")

    except (GoogleAPIError, Exception) as e:
        print(f"    [ERROR] Error en el archivo {file_path}:")
        print(f"    {str(e)}")
        # Lanzamos la excepción para detener el pipeline si algo falla
        raise e

def main():
    # Inicializar cliente de BigQuery
    client = bigquery.Client(project=PROJECT_ID)
    
    # Obtener archivos ordenados
    sql_files = get_sql_files_in_order(SQL_ROOT_DIR)
    
    if not sql_files:
        print(f"No se encontraron archivos .sql en '{SQL_ROOT_DIR}'")
        return

    print(f"Se detectaron {len(sql_files)} archivos para el modelo de datos.\n")

    try:
        for file_path in sql_files:
            run_bigquery_script(client, file_path)
        
        print("\nEl modelo en BigQuery se ha creado con éxito.")
    
    except Exception:
        print("\nEl pipeline se detuvo debido a un error en una de las fases.")

if __name__ == "__main__":
    main()