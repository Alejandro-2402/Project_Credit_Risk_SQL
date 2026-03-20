# Project_Credit_Risk_SQL
Este el proyecto de basico a avanzado en mi formacion como data analyst.

# Análisis Exploratorio de Datos (EDA) - Riesgo Crediticio

---

## Resumen del Proyecto
Este proyecto individual tiene como objetivo demostrar habilidades de limpieza, modelado y análisis exploratorio de datos (EDA) utilizando **SQL Server**. A través del análisis de un dataset financiero de más de 32,000 registros de solicitudes de crédito, se busca identificar perfiles de riesgo, evaluar la salud de la cartera y extraer *insights* de negocio para la toma de decisiones.

## Herramientas y Metodología
* **Motor de Base de Datos:** SQL Server (SSMS).
* **Lenguaje:** SQL (DDL, DML, DQL).
* **Metodología:** Extracción, Transformación y Carga (ETL), Normalización de Base de Datos (1NF/2NF/3NF), y Análisis Exploratorio de Datos (EDA).

---
## Fase 1: Arquitectura y Modelado de Datos (ETL)

El dataset original consistía en un archivo plano desnormalizado (CSV). Para asegurar la integridad de los datos y optimizar las consultas, diseñé e implementé un modelo relacional segmentando la información en tres entidades principales:

1.  **`Clientes` (Dimensión Demográfica):** Contiene la edad, ingresos, años de empleo y situación de vivienda.
2.  **`Historial_Crediticio` (Dimensión de Riesgo Previo):** Registra si el cliente ha incurrido en morosidad histórica y la longitud de su historial.
3.  **`Prestamos` (Tabla de Hechos):** Registra el monto, la tasa de interés, el propósito del crédito y el estado actual (vigente o en default).

*(Script: `1_ETL_y_Modelado.sql`)*

```sql 
ALTER TABLE DATA_CRUDA
ADD ID_FILA INT IDENTITY (1,1);
```

```sql
-- I. Normalizacion de los datos.

-- ==========================================
-- 1. TABLA CLIENTES 
-- ==========================================

CREATE TABLE Clientes (
    ID_Cliente INT PRIMARY KEY,
    Edad INT,
    Ingreso_Anual FLOAT,
    Tipo_Vivienda VARCHAR(50),
    Años_Empleo FLOAT
);

-- Insertamos los datos desde la data cruda

INSERT INTO Clientes (ID_Cliente, Edad, Ingreso_Anual, Tipo_Vivienda, A�os_Empleo)
SELECT 
    ID_FILA, 
    person_age, 
    person_income, 
    person_home_ownership, 
    person_emp_length 
FROM Data_Cruda;

-- ==========================================
-- 2. TABLA HISTORIAL CREDITICIO 
-- ==========================================

CREATE TABLE Historial_Crediticio (
    ID_Historial INT IDENTITY(1,1) PRIMARY KEY,
    ID_Cliente INT FOREIGN KEY REFERENCES Clientes(ID_Cliente),
    Historico_Morosidad VARCHAR(5), -- 'Y' o 'N'
    Años_Historia_Crediticia INT
);

-- Insertamos los datos

INSERT INTO Historial_Crediticio (ID_Cliente, Historico_Morosidad, Años_Historia_Crediticia)
SELECT 
    ID_Fila, 
    cb_person_default_on_file, 
    cb_person_cred_hist_length 
FROM Data_Cruda;


-- ==========================================
-- 3. TABLA PRESTAMOS 
-- ==========================================

CREATE TABLE Prestamos (
    ID_Prestamo INT IDENTITY(1,1) PRIMARY KEY,
    ID_Cliente INT FOREIGN KEY REFERENCES Clientes(ID_Cliente),
    Motivo_Prestamo VARCHAR(50),
    Grado_Riesgo VARCHAR(5),
    Monto FLOAT,
    Tasa_Interes FLOAT,
    Estado_Prestamo INT, -- 0 es pago al día, 1 es default/morosidad
    Porcentaje_Ingreso FLOAT
);

-- Insertamos los datos

INSERT INTO Prestamos (ID_Cliente, Motivo_Prestamo, Grado_Riesgo, Monto, Tasa_Interes, Estado_Prestamo, Porcentaje_Ingreso)
SELECT 
    ID_Fila, 
    loan_intent, 
    loan_grade, 
    loan_amnt, 
    loan_int_rate, 
    loan_status, 
    loan_percent_income 
FROM Data_Cruda;
```
---
## Fase 2: Análisis Exploratorio y Salud de la Data (Nivel Básico)

Antes de cruzar variables complejas, se realizó una auditoría de la información y una evaluación volumétrica de la cartera.

### 1. Auditoría de Datos Faltantes (Nulos)

**Situación de Negocio:** Antes de analizar riesgos, debemos saber cuánta información laboral y financiera nos falta.

**Query:**

```sql
-- Buscando nulos en Años de Empleo (Tabla Clientes)

SELECT 
    COUNT(*) AS NULL_AÑOS_EMPLEO
FROM Clientes
WHERE Años_Empleo IS NULL;

-- Buscando nulos en Tasa de Interes (Tabla Prestamos)
SELECT 
    COUNT(*) AS NULL_TASA_INTERES
FROM Prestamos
WHERE Tasa_Interes IS NULL;
```

![resultado_q1](PICTURES\resultado_q1.png)


### 2. Volumetría y Ticket Promedio

**Situación del negocio:** Queremos calcular cual es el monto total de dinero colocado en préstamos históricamente y el monto del ticket promedio que se suele pedir.

**Query**

```sql
SELECT 
    SUM(Monto) AS MONTO_DINERO_HISTORICO, 
    AVG(Monto) AS TICKET_PROMEDIO
FROM Prestamos;
```

![resultado_q2](PICTURES\resultado_q2.png)

### 3. Anomalías Demográficas (Outliers)

**Situación del negocio:** Queremos averiguar si existen registros ilógicos dentro de la base, como clientes con edades mayores a 100 años o cuyos años de empleo superan su propia edad.

**Query**

```sql
SELECT 
    COUNT(*) AS OUTLIERS_DEMOGRAFICOS
FROM Clientes
WHERE 
    Edad > 100 
    OR 
    Años_Empleo > Edad;
```

![resultado_q3](PICTURES\resultado_q3.png)

### 4. Distribución de Vivienda

**Situación del negocio:** Queremos saber cómo se distribuye la cartera de clientes según la situación de vivienda *(Rent, Mortage, Own)* y saber la cantidad de clientes por cada categoría.

**Query**

```sql
SELECT 
    Tipo_Vivienda, 
    COUNT(*) AS CANTIDAD_TP_VIVIENDA
FROM Clientes
GROUP BY Tipo_Vivienda;
```

![resultado_q4](PICTURES\resultado_q4.png)

### 5. Concentración por motivos de préstamo

**Situación del negocio:** Queremos averiguar cuales son los diferentes motivos por los que las personas solicitan los préstamos y saber la cantidad de préstamos otorgados por motivo. *(Ordenados del más común al menos común)*

**Query**

```sql
SELECT 
    Motivo_Prestamo, 
    COUNT(*) AS CANTIDAD_MOTIVO
FROM Prestamos
GROUP BY Motivo_Prestamo 
    ORDER BY CANTIDAD_MOTIVO DESC;
```

![resultado_q5](PICTURES\resultado_q5.png)


### Hallazgos Clave y Conclusiones de Negocio:
1.  **Auditoría de Calidad:** Se detectaron **895** registros nulos en la variable de Años de Empleo y **3,116** en la variable de Tasas de interés. Asimismo, se identificaron **7** registros atípicos (*outliers*), incluyendo edades irreales (mayores a 100 años) e inconsistencias lógicas entre edad y años de experiencia laboral. Estos datos deben ser filtrados antes de entrenar modelos de riesgo.

2.  **Exposición y Perfil del Cliente:** El banco tiene una colocación histórica total de **$312'431,300**, con un ticket promedio de crédito de **$9,589.37**. Este monto promedio confirma que la cartera analizada pertenece a banca *Retail* (consumo minorista) y no a banca corporativa.

3.  **Arraigo y Patrimonio:** La distribución de la cartera por tipo de vivienda muestra que la mayoría de los clientes se concentran en el segmento de **Mortage (Hipoteca)**, lo cual es un indicador crucial para la evaluación de garantías.

4.  **Concentración Comercial:** El principal motivo de endeudamiento de los clientes es **Educación**, lo que brinda una oportunidad clara para que el área comercial dirija campañas de retención o venta cruzada hacia ese producto específico.


---
*(En desarrollo: Nivel Intermedio y Avanzado)*