# Decisiones Técnicas

Este documento detalla las razones detrás de la elección de la arquitectura actual y por qué se optó por un enfoque ligero en lugar de soluciones empresariales más complejas.

## Simplicidad vs. Complejidad

Dada la naturaleza de esta **prueba técnica**, se priorizó la agilidad, la facilidad de revisión y la portabilidad del código.

### 1. Ejecución Local vs. Cloud Storage
* **Decisión:** Los archivos SQL se gestionan directamente desde el sistema de archivos local en lugar de almacenarlos en **Google Cloud Storage (GCS)**.
* **Justificación:** Para una prueba técnica, subir archivos a un bucket de GCS añade una capa de configuración innecesaria para el evaluador (permisos de IAM adicionales, creación de buckets, etc.). Mantener los archivos localmente permite una revisión inmediata del código y una ejecución directa sin dependencias de red externas a BigQuery.

### 2. Orquestación con Python vs. Apache Airflow
* **Decisión:** Se desarrolló un orquestador ligero en Python puro en lugar de utilizar **Apache Airflow** o **Cloud Composer**.
* **Justificación:** * **Peso de Infraestructura:** Airflow requiere un servidor o entorno gestionado, lo cual es excesivo para un pipeline lineal de 4 fases.
    * **Velocidad de Despliegue:** Un script de Python se ejecuta en segundos, mientras que configurar un DAG de Airflow distraería del objetivo principal: la lógica de transformación en BigQuery.
    * **Facilidad de Evaluación:** El evaluador solo necesita Python instalado, eliminando la fricción de configurar un entorno de orquestación complejo.

### 3. Automatización de Rutas con `os.path`
* **Decisión:** Uso de lógica de directorios dinámica para localizar la carpeta `sql`.
* **Justificación:** Al evitar rutas absolutas (hardcoded), el proyecto se vuelve "Plug & Play". Esto demuestra buenas prácticas de desarrollo de software aplicadas a la ingeniería de datos.

### 4. Cliente Nativo `google-cloud-bigquery`
* **Decisión:** Uso de la librería oficial de Google sobre conectores genéricos como ODBC/JDBC.
* **Justificación:** Esto permite manejar los `Query Jobs` de manera asíncrona y obtener metadatos de la ejecución (como el tiempo de procesamiento o bytes escaneados) si fuera necesario en el futuro.

## Próximos Pasos (Escalabilidad)
En un entorno de producción real con volúmenes de datos masivos y dependencias complejas, la arquitectura evolucionaría naturalmente hacia:
1. **CI/CD:** Despliegue automático de scripts SQL a un Bucket de GCS.
2. **Orquestación:** Migración de la lógica de Python a **Airflow** o **Prefect** para manejar reintentos, alertas y paralelismo.
3. **Transformación:** Implementación de **dbt (data build tool)** para gestionar el linaje de datos y pruebas de calidad automatizadas.