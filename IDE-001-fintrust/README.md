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
├── README.md
│   # Documentación principal: contexto,
│   # instrucciones de ejecución y decisiones clave
│
├── docs/
│   ├── decisiones-tecnicas.md
│   │   # Supuestos, decisiones de diseño y riesgos conocidos
│   │
│   └── evidencia-calidad-datos.md
│       # Validaciones aplicadas y resultados observados
│
├── sql/
│   ├── 01-raw/
│   │   └── create_raw_tables.sql
│   │       # DDL y carga de tablas fuente en raw_fintrust
│   │
│   ├── 02-staging/
│   │   └── stg_*.sql
│   │       # Transformaciones intermedias, limpieza y estandarización
│   │
│   ├── 03-analytics/
│   │   └── dm_*.sql / vw_*.sql
│   │       # Data mart y vistas analíticas finales para BI
│   │
│   └── 04-queries-negocio/
│       ├── q01_desembolso_diario.sql
│       ├── q02_recaudo_diario.sql
│       ├── q03_cartera_por_cohorte.sql
│       ├── q04_top_atraso.sql
│       └── q05_dataset_bi.sql
│       # Consultas que responden las preguntas del caso
│
├── python/
│   ├── pipeline.py
│   │   # Automatización ETL / orquestación de pasos
│   │
│   ├── validations.py
│   │   # Controles de calidad de datos
│   │
│   └── requirements.txt
│       # Dependencias del proyecto
│
└── bonus/
    └── llm_proposal.md
        # (Opcional) Propuesta de uso de LLMs


## Instrucciones de ejecución



### Requisitos previos

### Pasos

## Decisiones clave


