
-- 11. ¿Cuántos préstamos en estado de morosidad tienen un monto de deuda estrictamente 
-- mayor al ticket promedio global de todo el banco?

SELECT COUNT(*) AS MOROSOS_SOBRE_PROMEDIO
FROM Prestamos
WHERE Estado_Prestamo = 1
AND
MONTO > (
SELECT AVG(MONTO)
FROM Prestamos
);

-- 12. Queremos aislar a nuestra población más tóxica (los que tienen historial de morosidad
-- en otros bancos) y descubrir exactamente cuánto dinero le deben a nuestro banco en promedio.

WITH CLIENTES_RIESGOSOS AS (
-- Consulta para obtener los ID's de clientes con historial de morosidad en otros bancos 
-- los cuales se almacenarán en una tabla virtual para la futura consulta.
	SELECT ID_CLIENTE
	FROM Historial_Crediticio
	WHERE Historico_Morosidad = 1
)
-- Consulta principal, usando la tabla virtual anterior.
SELECT ROUND(AVG(MONTO),2) AS TICKET_PROMEDIO_RIESGOSO
FROM Prestamos AS P
INNER JOIN
CLIENTES_RIESGOSOS AS CR
	ON P.ID_Cliente = CR.ID_Cliente;

-- 13. Queremos armar un ranking para encontrar los 3 préstamos más grandes otorgados
-- dentro de cada motivo de préstamo.

WITH RANKING_PRESTAMOS AS 
(
SELECT 
	ID_Cliente,
	Motivo_Prestamo, 
	Monto,
	ROW_NUMBER() OVER( PARTITION BY MOTIVO_PRESTAMO ORDER BY MONTO DESC) AS RANKING
FROM Prestamos
)

SELECT *
FROM RANKING_PRESTAMOS
WHERE RANKING <= 3
ORDER BY ID_Cliente ASC;

-- 14. ¿Qué clientes en estado de morosidad pidieron un monto que supera el ticket
-- promedio específico de su tipo de préstamo?

WITH PROMEDIOS_POR_CATEGORIA AS
(
SELECT
	ID_Cliente, 
	Motivo_Prestamo, 
	Monto,
	ROUND(AVG(MONTO) OVER (PARTITION BY MOTIVO_PRESTAMO),2) AS PROMEDIO_CATEGORIA
FROM Prestamos
WHERE Estado_Prestamo = 1
)
SELECT *
FROM PROMEDIOS_POR_CATEGORIA
WHERE MONTO > PROMEDIO_CATEGORIA
ORDER BY ID_Cliente ASC;

-- 15. ¿Cómo podemos segmentar a todos nuestros clientes en default (MOROSOS)
-- en 4 grupos prioritarios de cobranza (Cuartiles) basados en el monto de su deuda?

SELECT 
	ID_Cliente, 
	Monto,
	NTILE(4) OVER (ORDER BY MONTO DESC) AS CUARTIL_COBRANZA
FROM Prestamos
WHERE Estado_Prestamo = 1
ORDER BY 
	CUARTIL_COBRANZA ASC, 
	MONTO DESC, 
	ID_Cliente ASC;