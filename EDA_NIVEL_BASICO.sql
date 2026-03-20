
-- PREGUNTAS --

-- 1. ¿Cuantos clientes en total tienen valores NULOS en sus años de empleo o en la tasa de interes de su prestamo?


SELECT 
    COUNT(*) AS NULL_AÑOS_EMPLEO
FROM Clientes
WHERE Años_Empleo IS NULL;

SELECT 
    COUNT(*) AS NULL_TASA_INTERES
FROM Prestamos
WHERE Tasa_Interes IS NULL;

-- 2. ¿Cual es el monto toal de dinero colocado en prestamos historicamente y cual es el ticket promedio que suele pedir el cliente?

SELECT 
    SUM(Monto) AS MONTO_DINERO_HISTORICO, 
    AVG(Monto) AS TICKET_PROMEDIO
FROM Prestamos;

-- 3. ¿Exiten registros ilogicos en la base de datos, como clientes con edades mayores a 100 años o personas cuyos años de empleo superan su propia edad?

SELECT 
    COUNT(*) AS OUTLIERS_DEMOGRAFICOS
FROM Clientes
WHERE 
    Edad > 100 
    OR 
    Años_Empleo > Edad;

-- 4. ¿Como se distribuye la cartera de clientes segun su situacion de vivienda (Alquiler, Hipoteca, Propio)? y ¿Cuantos clientes hay por categoria?

SELECT 
    Tipo_Vivienda, 
    COUNT(*) AS CANTIDAD_TP_VIVIENDA
FROM Clientes
GROUP BY Tipo_Vivienda;

-- 5. ¿Cuales son los diferentes motivos por los que las personas solicitan dinero y cuantos prestamos se han otorgado para cada motivo? (Ordenado del mas comun al menos comun)

SELECT 
    Motivo_Prestamo, 
    COUNT(*) AS CANTIDAD_MOTIVO
FROM Prestamos
GROUP BY Motivo_Prestamo 
    ORDER BY CANTIDAD_MOTIVO DESC;