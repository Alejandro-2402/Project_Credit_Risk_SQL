
-- PREPARACION DEL ENTORNO DE TRABAJO --

-- 1. Creamos nuestra DB de trabajo "PROYECTO_01"
-- 2. Importamos el archivo .CSV
-- 3. Importamos la tabla general para su posterior normalización y separacion de datos para el EDA
-- 4. Añadimos un "ID_FILA" como identificador único de cada registro, para posteriormente separar los datos sin perder informacion

ALTER TABLE DATA_CRUDA
ADD ID_FILA INT IDENTITY (1,1);


-- I. Normalizacion de los datos.

-- ==========================================
-- 1. TABLA CLIENTES (Dimensión Demográfica)
-- ==========================================
CREATE TABLE Clientes (
    ID_Cliente INT PRIMARY KEY,
    Edad INT,
    Ingreso_Anual FLOAT,
    Tipo_Vivienda VARCHAR(50),
    Años_Empleo FLOAT
);

-- Insertamos los datos desde la data cruda
INSERT INTO Clientes (ID_Cliente, Edad, Ingreso_Anual, Tipo_Vivienda, Años_Empleo)
SELECT 
    ID_FILA, 
    person_age, 
    person_income, 
    person_home_ownership, 
    person_emp_length 
FROM Data_Cruda;


-- ==========================================
-- 2. TABLA HISTORIAL CREDITICIO (Dimensión de Riesgo Previo)
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
-- 3. TABLA PRESTAMOS (Tabla de Hechos / Transaccional)
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

--- NORMALIZACION COMPLETADA ---

-- PREGUNTAS --