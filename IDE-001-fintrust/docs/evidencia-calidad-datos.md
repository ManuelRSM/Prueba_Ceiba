# Evidencia de Calidad de Datos (Data Quality)

En este proyecto, la capa de **02-Staging** no solo actúa como una zona de paso, sino como el primer filtro de integridad y limpieza. Se han implementado reglas de negocio dentro de los scripts SQL para asegurar que los datos que llegan a la capa de **Analytics** sean confiables.

## Reglas de Calidad Implementadas

Durante la transformación de `raw` a `staging`, se ejecutan las siguientes validaciones:

### 1. Gestión de Valores Nulos (Null Handling)
* **Regla:** Campos críticos como `customer_id`, `loan_id` y `payment_id` no pueden ser nulos.
* **Acción:** Se filtran o se imputan valores por defecto para evitar errores en los `JOINs` de las capas posteriores.

### 2. Estandarización de Formatos y Tipos
* **Regla:** Las fechas deben tener un formato uniforme (`DATE` o `TIMESTAMP`) y los montos deben ser numéricos consistentes.
* **Acción:** Se realiza un `CAST` explícito en los archivos `staging_*.sql` para asegurar que BigQuery interprete correctamente las métricas financieras.

### 3. Limpieza de Strings (Data Scrubbing)
* **Regla:** Eliminar espacios en blanco innecesarios y normalizar textos (ej. convertir estados a Mayúsculas).
* **Acción:** Uso de funciones como `TRIM()` y `UPPER()` para garantizar que los filtros de negocio en la capa de `queries-negocio` funcionen correctamente.

### 4. Eliminación de Duplicados
* **Regla:** Cada registro en staging debe ser único según su llave primaria de negocio.
* **Acción:** Implementación de sentencias `DISTINCT` o cláusulas `QUALIFY ROW_NUMBER()` para asegurar que no existan duplicidad de transacciones provenientes de la capa `raw`.

## Beneficios para el Negocio
* **Confiabilidad:** Los reportes de cobranza diaria (`vw_daily_collections`) se basan en datos previamente saneados.
* **Eficiencia:** Al limpiar los datos en *Staging*, evitamos repetir procesos de limpieza en cada una de las vistas finales, optimizando el consumo de slots en BigQuery.
* **Rastreabilidad:** Cualquier anomalía en los datos de origen es detectada y tratada antes de llegar a los dashboards finales.