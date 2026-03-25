

-- 6. ¿Cuántos prestamos en estado de morosidad (Estado_Prestamo = 1) existen por cada Tipo_Vivienda?

SELECT 
	C.TIPO_VIVIENDA, 
	COUNT (*) AS CANT_PREST_DEFAULT
FROM Clientes AS C 
INNER JOIN PRESTAMOS AS P
	ON C.ID_Cliente = P.ID_Cliente
WHERE P.Estado_Prestamo = 1
GROUP BY C.Tipo_Vivienda 
ORDER BY CANT_PREST_DEFAULT DESC;

-- 7. ¿Cuál es el porcentaje de morosidad actual de los clientes que SÍ tenían histórico en default (Historico_Morosidad = 'Y') vs los que NO lo tenían ('N')?

SELECT 
    -- Transformamos el 1 y 0 a Y y N solo para esta vista
    CASE 
        WHEN H.Historico_Morosidad = '1' THEN 'Y'
        WHEN H.Historico_Morosidad = '0' THEN 'N'
        ELSE H.Historico_Morosidad 
    END AS Historial_Morosidad_Previo,

    ROUND((SUM(CAST(P.Estado_Prestamo AS FLOAT)) / COUNT(*)) * 100, 2) AS TASA_MOROSIDAD_PORCENTAJE
FROM Historial_Crediticio AS H 
INNER JOIN Prestamos AS P
    ON H.ID_Cliente = P.ID_Cliente
GROUP BY 
    -- Agrupamos por la misma lógica del CASE
    CASE 
        WHEN H.Historico_Morosidad = '1' THEN 'Y'
        WHEN H.Historico_Morosidad = '0' THEN 'N'
        ELSE H.Historico_Morosidad 
    END
ORDER BY TASA_MOROSIDAD_PORCENTAJE DESC;

-- 8. Agrupando por el motivo del préstamo (Motivo_Prestamo), ¿Cuáles son los motivos que nos hacen perder dinero por partida doble, 
-- es decir que tienen un ticket promedio superior a $10,000 y además concentran más de 500 operaciones en estado de morosidad?

SELECT 
    Motivo_Prestamo, 
    COUNT(*) AS TOTAL
FROM Prestamos
GROUP BY Motivo_Prestamo
HAVING
    AVG(MONTO) > 10000
    AND
    SUM(ESTADO_PRESTAMO) > 500;

-- 9. Comparando los préstamos pagados (Estado_Prestamo = 0) vs los morosos (Estado_Prestamo = 1), 
-- ¿cuál es el promedio de ingresos anuales (Ingreso_Anual) y el promedio del monto otorgado (Monto) para cada grupo?

SELECT 
    CASE 
        WHEN P.Estado_Prestamo = '0' THEN 'PAGADO'
        WHEN P.Estado_Prestamo = '1' THEN 'MORA'
        ELSE CAST(P.Estado_Prestamo AS VARCHAR)
        END AS SITUACION_PRESTAMO, 

    ROUND(AVG(C.INGRESO_ANUAL),2) AS AVG_ING_ANUAL, 
    ROUND(AVG(P.MONTO),2) AS AVG_MONTO_PRESTADO
FROM Clientes AS C
INNER JOIN Prestamos AS P
    ON C.ID_Cliente = P.ID_Cliente
GROUP BY 
    CASE 
        WHEN P.Estado_Prestamo = '0' THEN 'PAGADO'
        WHEN P.Estado_Prestamo = '1' THEN 'MORA'
        ELSE CAST(P.Estado_Prestamo AS VARCHAR)
        END;

-- 10. ¿Cuántos préstamos en estado de morosidad (Estado_Prestamo =1) existen segmentados por rangos de edad 
-- (Jovenes: < 25, Adultos: 25 - 40, Mayores: > 40)?

SELECT 
    CASE 
        WHEN C.Edad < 25 THEN 'Jovenes'
        WHEN C.Edad BETWEEN 25 AND 40 THEN 'Adultos'
        WHEN C.Edad > 40 THEN 'Mayores'
        ELSE CAST(C.EDAD AS VARCHAR)
        END AS GRUPO_ETARIO,
    COUNT(*) AS TOTAL_G_ETARIO
FROM CLIENTES AS C
INNER JOIN Prestamos AS P
ON C.ID_Cliente = P.ID_Cliente
WHERE P.Estado_Prestamo = 1
GROUP BY 
    CASE 
        WHEN C.Edad < 25 THEN 'Jovenes'
        WHEN C.Edad BETWEEN 25 AND 40 THEN 'Adultos'
        WHEN C.Edad > 40 THEN 'Mayores'
        ELSE CAST(C.EDAD AS VARCHAR)
        END
ORDER BY TOTAL_G_ETARIO DESC;
    
