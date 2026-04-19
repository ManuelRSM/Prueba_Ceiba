# IDE-001-FinTrust — Caso Práctico Ingeniero de Datos

## Contexto

Este proyecto implementa una solución analítica end-to-end para FinTrust, una compañía que otorga microcréditos a clientes de nómina y canales digitales. El objetivo es crear un modelo analitico en Bigquery mediante la ejecución de un pipeline en Python que permita monitorear el desempeño del portafolio, segmentado por ciudad, tipo de cliente y cohorte de originación.

El ecosistema de datos incluye múltiples fuentes como clientes, créditos, cuotas y pagos, las cuales presentan problemas de calidad (inconsistencias en fechas y canales de pago, pagos parciales y ausencia de una capa analítica unificada).

Para abordar estos retos, se diseñó e implementó una arquitectura de datos en capas utilizando BigQuery y python, siguiendo buenas prácticas:

Capa Raw: Ingesta de datos fuente.
Capa Staging: Limpieza, estandarización y validaciones de datos.
Capa Analytics: Construcción de una tabla de hechos granular que integra créditos, cuotas y pagos.
Capa de consumo (Datamart): Vistas analíticas listas para responder preguntas de negocio.

Las principales preguntas de negocio abordadas incluyen:

Desembolso total por día, ciudad y segmento
Recaudo diario total y recaudo aplicado a cuotas en mora
Estado de la cartera (al día vs en mora) por cohorte de originación
Identificación de créditos de alto riesgo según atraso y saldo pendiente

Adicionalmente, se implementó un pipeline en Python para orquestar la ejecución de las transformaciones SQL, garantizando reproducibilidad, orden lógico y mantenibilidad del flujo de datos.

La solución está diseñada con foco en claridad, rendimiento y escalabilidad, permitiendo su integración directa con herramientas de visualización como Power BI, Tableau o Looker.

## Estructura del proyecto

IDE-001-fintrust/
│
├── docs/                                      # Documentación técnica
│   ├── decisiones-tecnicas.md                  # Justificación de arquitectura
│   └── evidencia-calidad-datos.md              # Reglas de limpieza y validación
│
├── python/                                    # Lógica de orquestación
│   ├── Pipeline_fintrust.py                   # Script principal de Python
│   ├── prueba-maps-283720-f3ada9b45580.json   # Credenciales de GCP
│   └── requirements.txt                       # Librerías necesarias
│
├── sql/                                       # Capas del modelo de datos
│   ├── 01-raw/                                # Ingesta inicial
│   │   ├── Creacion_tablas.sql
│   │   └── Insercion_tablas.sql
│   │
│   ├── 02-staging/                            # Transformación y Calidad
│   │   ├── Staging_customers.sql
│   │   ├── Staging_installments.sql
│   │   ├── Staging_loans.sql
│   │   └── Staging_payments.sql
│   │
│   ├── 03-analytics/                          # Tablas de hechos/dimensiones
│   │   └── fct_loan_installments_payments.sql
│   │
│   └── 04-queries-negocio/                    # Entregables de negocio (KPIs)
│       ├── q01_desembolso_diario.sql
│       ├── q02_recaudo_diario.sql
│       ├── q03_cartera_por_cohorte.sql
│       ├── q04_top_atraso.sql
│       ├── q05_porcentaje_pago_mora_dia.sql
│       └── q06_dataset_bi.sql
│
└── README.md                                  # Guía principal del proyecto

### Requisitos previos

1. Requisitos Previos

-Python 3.9 o superior: Asegúrese de tener instalado Python en su sistema. Puede verificarlo ejecutando en una consola bash: python --version

-Cuenta de Servicio en GCP: Se requiere una cuenta de servicio con el rol de Administrador de BigQuery (o permisos suficientes para crear datasets, tablas y vistas).

-Archivo de Credenciales: Descargue la llave de la cuenta de servicio en formato JSON.

2. Configuración del Entorno

-Clonar o descargar el proyecto: Sitúese en la raíz de la carpeta IDE-001-fintrust.

-Instalar dependencias: Ejecute el siguiente comando para instalar las librerías necesarias (principalmente google-cloud-bigquery):

pip install google-cloud-bigquery

3. Configuración de Credenciales y Variables

-Para que el script se comunique con su proyecto de Google Cloud, realice los siguientes ajustes en el archivo python/Pipeline_fintrust.py:
Llave JSON: Coloque su archivo de credenciales .json dentro de la carpeta python/. (El unico archivo .json del proyecto)

-Variables Globales: Actualice los siguientes valores al inicio del script:
JSON_KEY_NAME: El nombre del archivo JSON que colocó en la carpeta (ej: "mi-llave.json").
PROJECT_ID: El ID de su proyecto en Google Cloud Console.


## Instrucciones de ejecución

1. Ejecución del Pipeline
Una vez configurado, ejecute el script desde la terminal. Se recomienda posicionarse en la carpeta donde reside el archivo .py:

python Pipeline_fintrust.py

El script detectará automáticamente la carpeta ../sql, ordenará los archivos según su prefijo numérico (01, 02, 03, 04) y los ejecutará secuencialmente en BigQuery.

## Decisiones clave

Para el desarrollo de este pipeline, se tomaron decisiones estratégicas orientadas a la mantenibilidad, escalabilidad y orden lógico del modelo de datos:

1. Orquestación Basada en Prefijos Numéricos
Se implementó una lógica de escaneo de archivos que respeta el orden alfabético-numérico de los directorios (01-raw, 02-staging, etc.).

Por qué: En los modelos de datos (especialmente en arquitecturas tipo Medallion o esquemas de capas), es crítico asegurar que las tablas base existan antes de que las capas de transformación intenten consultarlas. Esto evita errores de dependencia.

2. Uso de Rutas Dinámicas (os.path)
El script utiliza rutas relativas basadas en la ubicación del archivo (__file__) en lugar de rutas fijas (hardcoded).

Por qué: Esto garantiza la portabilidad del proyecto. El script funcionará sin errores sin importar en qué carpeta o sistema operativo (Windows/Linux/Mac) lo ejecute el evaluador.

3. Ejecución Atómica por Archivo
Cada archivo .sql se envía como un job independiente a BigQuery mediante el método client.query(query).result().

Por qué: Esto permite un control de errores más granular. Si un script de la fase de staging falla, el pipeline se detiene inmediatamente, evitando la ejecución de las capas de negocio con datos incompletos o erróneos.

4. Integración Nativa con Google Cloud SDK
Se optó por la librería oficial google-cloud-bigquery en lugar de conectores genéricos.

Por qué: Permite aprovechar las optimizaciones nativas de GCP, el manejo de identidades mediante Cuentas de Servicio y una gestión más limpia de las excepciones de la API de BigQuery.

5. Enfoque Idempotente
Se diseñó el flujo bajo la premisa de que los scripts SQL utilicen sentencias como CREATE OR REPLACE o IF NOT EXISTS.

Por qué: Un pipeline de datos debe poder ejecutarse múltiples veces sin generar duplicados ni errores por objetos ya existentes, facilitando los reintentos en caso de fallos de red o de plataforma.