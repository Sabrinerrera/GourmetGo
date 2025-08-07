-- A CTEs
WITH Duraciones AS (
    SELECT PEP.idPedido, EP.nombre AS nombre_estado,
           EP.tiempo_promedio,
           DATEDIFF(minute, PEP.fecha_inicio,
                    ISNULL((
                        SELECT MIN(PEP_sig.fecha_inicio)
                        FROM PedidoEstadoPedido AS PEP_sig
                        WHERE PEP_sig.idPedido = PEP.idPedido
                          AND PEP_sig.fecha_inicio > PEP.fecha_inicio
                    ), GETDATE())
           ) AS duracion_minutos

    FROM EstadoPedido AS EP
    JOIN PedidoEstadoPedido AS PEP ON EP.id = PEP.idEstadoPedido
)

SELECT D.nombre_estado,
       COUNT(D.idPedido) AS cantidad_veces_usado,
       AVG(D.duracion_minutos) AS promedio_real,
       D.tiempo_promedio AS promedio_estimado,
       SUM(CASE WHEN D.duracion_minutos <= D.tiempo_promedio THEN 1 ELSE 0 END) * 100.0 / COUNT(D.idPedido) AS porcentaje_cumplimiento

FROM Duraciones AS D
GROUP BY D.nombre_estado, D.tiempo_promedio
ORDER BY D.nombre_estado;

-- B usando CTEs
WITH ComercioFacturacion AS (
    -- total facturado por comercio en el último mes
    SELECT c.id AS idComercio, c.nombre AS nombre_comercio, SUM(f.monto_total) AS total_facturado, -- agg idComercio para mayor facilidad al agrupar
        -- plato más pedido por comercio
        (
            SELECT TOP 1 pl.nombre

            FROM Plato AS pl
            JOIN PedidoDetalle AS pd ON pl.id = pd.idPlato
            JOIN Pedido AS pe ON pd.idPedido = pe.id
            JOIN Factura AS fa ON pe.id = fa.idPedido
            JOIN Menu AS m ON pl.idSeccion IN (SELECT id FROM Seccion WHERE idMenu = m.id)

            WHERE m.idComercio = c.id
              AND fa.fecha_emision >= DATEADD(month, -1, GETDATE())
              AND fa.fecha_emision <= GETDATE()
            GROUP BY pl.nombre
            ORDER BY SUM(pd.cantidad) DESC
        ) AS plato_mas_pedido,
        -- cocina principal del comercio
        (
            SELECT TOP 1 co.nombre

            FROM Cocina AS co
            JOIN ComercioCocina AS cc ON co.id = cc.idCocina

            WHERE cc.idComercio = c.id
            ORDER BY co.nombre 
        ) AS cocina_principal

    FROM Comercio AS c
    JOIN Menu AS m ON c.id = m.idComercio
    JOIN Seccion AS s ON m.id = s.idMenu
    JOIN Plato AS p ON s.id = p.idSeccion
    JOIN PedidoDetalle AS pd ON p.id = pd.idPlato
    JOIN Pedido AS pe ON pd.idPedido = pe.id
    JOIN Factura AS f ON pe.id = f.idPedido

    WHERE f.fecha_emision >= DATEADD(month, -1, GETDATE()) AND f.fecha_emision <= GETDATE()
    GROUP BY c.id, c.nombre
),
PromedioGeneral AS (
    SELECT AVG(total_facturado) AS promedio
    FROM ComercioFacturacion
)

SELECT cf.nombre_comercio, cf.total_facturado, cf.cocina_principal, cf.plato_mas_pedido,
    CASE
        WHEN cf.total_facturado > pg.promedio THEN 'Por encima del promedio'
        WHEN cf.total_facturado < pg.promedio THEN 'Por debajo del promedio'
        ELSE 'Igual al promedio' -- en caso de que sea exactamente igual (agg a consideración)
    END AS ComparacionPromedio

FROM ComercioFacturacion AS cf, PromedioGeneral AS pg
ORDER BY cf.nombre_comercio;

-- C CTEs
WITH PedidosConSeccionesValidas AS (
    -- Paso 1: Identificar qué pedidos tienen al menos dos platos de secciones distintas
    SELECT PD.idPedido

    FROM PedidoDetalle AS PD
    JOIN Plato AS P ON PD.idPlato = P.id
    JOIN Seccion AS S ON P.idSeccion = S.id

    GROUP BY PD.idPedido
    HAVING COUNT(DISTINCT S.id) >= 2
),
RepartidorCalificacionesPromedio AS (
    -- Paso 2: Calcular el puntaje promedio de CADA repartidor por CADA cliente
    SELECT
        CR.idCliente,
        CR.idRepartidor,
        R.nombre + ' ' + R.apellido AS nombre_repartidor,
        AVG(CAST(CR.puntaje AS DECIMAL(5,2))) AS puntaje_promedio_repartidor -- CAST para mantener decimales

    FROM ClienteRepartidor AS CR
    JOIN Repartidor AS R ON CR.idRepartidor = R.id

    WHERE CR.puntaje >= 4 -- Solo calificaciones de 4 estrellas o más
    GROUP BY CR.idCliente, CR.idRepartidor, R.nombre, R.apellido
),
MejorRepartidorPorCliente AS (
    -- Paso 3: Mejor repartidor para cada cliente
    SELECT rcp.idCliente,
        MAX(rcp.puntaje_promedio_repartidor) AS max_puntaje_repartidor,
        -- si hay empate en puntaje, desempatamos eligiendo el repartidor con el ID más bajo
        MIN(rcp.idRepartidor) AS idRepartidorElegido

    FROM RepartidorCalificacionesPromedio AS rcp
    GROUP BY rcp.idCliente
)

SELECT
    C.nombre + ' ' + C.apellido AS nombre_cliente,
    COUNT(DISTINCT P.id) AS total_pedidos_validos,
    SUM(P.total) AS total_gastado,
    RC_Elegido.nombre_repartidor AS repartidor_mejor_calificado,
    RC_Elegido.puntaje_promedio_repartidor AS puntaje_repartidor

FROM Cliente AS C
JOIN ClientePedido AS CP ON C.id = CP.idCliente
JOIN Pedido AS P ON CP.idPedido = P.id
JOIN Factura AS F ON P.id = F.idPedido -- usamos Factura para la fecha de emisión del pedido
JOIN PedidosConSeccionesValidas AS PCSV ON P.id = PCSV.idPedido
JOIN PedidoEstadoPedido AS PEP ON P.id = PEP.idPedido
JOIN EstadoPedido AS EP ON PEP.idEstadoPedido = EP.id
JOIN MejorRepartidorPorCliente AS MRPC ON C.id = MRPC.idCliente
JOIN RepartidorCalificacionesPromedio AS RC_Elegido ON MRPC.idCliente = RC_Elegido.idCliente
                                                    AND MRPC.max_puntaje_repartidor = RC_Elegido.puntaje_promedio_repartidor
                                                    AND MRPC.idRepartidorElegido = RC_Elegido.idRepartidor -- condición de desempate para elegir UN repartidor

WHERE F.fecha_emision >= DATEADD(month, -6, GETDATE()) -- pedidos en los últimos 6 meses (usando fecha de factura)
    AND EP.nombre = 'Entregado' -- solo pedidos entregados correctamente
GROUP BY C.id, C.nombre, C.apellido, RC_Elegido.nombre_repartidor, RC_Elegido.puntaje_promedio_repartidor
HAVING COUNT(DISTINCT P.id) >= 4 -- al menos 4 pedidos distintos
ORDER BY total_gastado DESC;

-- D
SELECT C.nombre + ' ' + C.apellido AS nombre_cliente,
    CASE
        WHEN COUNT(CP.idPedido) > 0 THEN 'Sí'
        ELSE 'No'
    END AS ha_realizado_pedidos,
    ISNULL(SUM(P.total), 0) AS total_gastado,
    CASE
        WHEN COUNT(CCR.idClienteReferido) > 0 THEN 'Sí'
        ELSE 'No'
    END AS ha_generado_referidos

FROM Cliente AS C
LEFT JOIN ClientePedido AS CP ON C.id = CP.idCliente
LEFT JOIN Pedido AS P ON CP.idPedido = P.id
LEFT JOIN ClienteConClienteReferido AS CCR ON C.id = CCR.idCliente

WHERE C.id IN (SELECT idClienteReferido FROM ClienteConClienteReferido) -- filtra solo clientes que son referidos
GROUP BY C.id, C.nombre, C.apellido;

-- E
SELECT R.nombre + ' ' + R.apellido AS nombre_repartidor,
    COUNT(RP.idPedido) AS pedidos_asignados,
    ISNULL(AVG(CAST(CR.puntaje AS REAL)), 0) AS promedio_puntaje_recibido,
    ISNULL(AVG(CAST(RP.tiempo_entrega AS REAL)), 0) AS tiempo_promedio_entrega,

FROM Repartidor AS R
LEFT JOIN RepartidorPedido AS RP ON R.id = RP.idRepartidor
LEFT JOIN ClienteRepartidor AS CR ON R.id = CR.idRepartidor
GROUP BY R.id, R.nombre, R.apellido;

-- F. 
SELECT C.nombre + ' ' + C.apellido AS nombre_cliente,
        COUNT(CP.idPedido) AS numero_pedidos,
        SUM(P.total) AS total_gastado,
        (
        SELECT AVG(Pe.total) 
        FROM Pedido AS Pe
        JOIN Factura AS Fa ON Pe.id = Fa.idPedido
        WHERE Fa.fecha_emision >= DATEADD(month, -3, GETDATE())
        ) AS promedio_general

FROM ClientePedido AS CP
JOIN Cliente AS C ON CP.idCliente = C.id
JOIN Pedido AS P ON CP.idPedido = P.id
JOIN Factura AS F ON P.id = F.idPedido

WHERE F.fecha_emision >= DATEADD(month, -3, GETDATE()) -- pedidos de los últimos 3 meses
    AND EXISTS ( -- al menos un plato de la sección Principales
        SELECT 1
        FROM PedidoDetalle AS PD
        JOIN Plato AS Pl ON PD.idPlato = Pl.id
        JOIN Seccion AS S ON Pl.idSeccion = S.id
        WHERE PD.idPedido = P.id AND S.nombre = 'Principales'
    )
    AND EXISTS ( -- al menos un plato de la sección Bebidas
        SELECT 1 
        FROM PedidoDetalle AS PD
        JOIN Plato AS Pl ON PD.idPlato = Pl.id
        JOIN Seccion AS S ON Pl.idSeccion = S.id
        WHERE PD.idPedido = P.id AND S.nombre = 'Bebidas' 
    )
        AND EXISTS ( -- al menos un repartidor con vehículo tipo Moto
        SELECT 1 
        FROM RepartidorPedido AS RP
        JOIN Repartidor AS R ON RP.idRepartidor = R.id
        WHERE RP.idPedido = P.id AND R.tipo_vehiculo = 'Moto'
    )

GROUP BY C.id, C.nombre, C.apellido -- agrupar por Cliente 
HAVING COUNT(CP.idPedido) >= 3 
    AND SUM(P.total) > (
                        SELECT AVG(Pe.total) 
                        FROM Pedido AS Pe
                        JOIN Factura AS Fa ON Pe.id = Fa.idPedido
                        WHERE Fa.fecha_emision >= DATEADD(month, -3, GETDATE())
); -- total gastado mayor al promedio de los últimos 3 meses

-- G. 
SELECT
    C.nombre AS nombre_comercio,
    C.ubicacion_fisica,
    C.hora_apertura,
    C.hora_cierre,
    COUNT(DISTINCT Pe.id) AS numero_pedidos, 
    DATEDIFF(hour, C.hora_apertura, C.hora_cierre) * 7 AS horas_semanales_trabajadas 
FROM Comercio AS C
JOIN ComercioCocina AS CC ON C.id = CC.idComercio
JOIN Cocina AS Co ON CC.idCocina = Co.id
JOIN Menu AS M ON C.id = M.idComercio
JOIN Seccion AS S ON M.id = S.idMenu
JOIN Plato AS P ON S.id = P.idSeccion
JOIN PedidoDetalle AS PD ON P.id = PD.idPlato
JOIN Pedido AS Pe ON PD.idPedido = Pe.id 
JOIN Factura AS F ON Pe.id = F.idPedido 
WHERE
    Co.nombre = 'China' 
    AND F.fecha_emision >= DATEADD(month, -1, GETDATE())
    AND F.fecha_emision <= GETDATE()
GROUP BY C.id, C.nombre, C.ubicacion_fisica, C.hora_apertura, C.hora_cierre
HAVING
    COUNT(DISTINCT Pe.id) > 20 
    AND DATEDIFF(hour, C.hora_apertura, C.hora_cierre) * 7 >= 50;

-- H CTEs
WITH OpcionesPorPedidoDetalle AS (
    -- opciones seleccionadas por cada pedido detalle
    SELECT PD.idPedido,
        PD.id AS idPedidoDetalle,
        COUNT(PDOV.idOpcionValor) AS CantidadOpcionesSeleccionadas

    FROM PedidoDetalle AS PD
    JOIN PedidoDetalleOpcionValor AS PDOV ON PD.id = PDOV.idPedidoDetalle
    GROUP BY PD.idPedido, PD.id
)
SELECT C.id AS idCliente,
    C.nombre + ' ' + C.apellido AS nombre_cliente,
    COUNT(DISTINCT P.id) AS total_pedidos_realizados, -- DISTINCT evita duplicados
    ISNULL(SUM(OPD.CantidadOpcionesSeleccionadas), 0) AS total_opciones_seleccionadas, 
    CASE
        WHEN COUNT(DISTINCT P.id) = 0 THEN 0 -- evitar división por cero (por si a caso)
        ELSE CAST(ISNULL(SUM(OPD.CantidadOpcionesSeleccionadas), 0) AS DECIMAL(10, 2)) / COUNT(DISTINCT P.id)
    END AS promedio_personalizaciones

FROM Cliente AS C
JOIN ClientePedido AS CP ON C.id = CP.idCliente
JOIN Pedido AS P ON CP.idPedido = P.id
JOIN PedidoEstadoPedido AS PEP ON P.id = PEP.idPedido
JOIN EstadoPedido AS EP ON PEP.idEstadoPedido = EP.id
-- LEFT JOIN para incluir los que no tienen ninguna opción seleccionada (pedido/cliente)
LEFT JOIN OpcionesPorPedidoDetalle AS OPD ON P.id = OPD.idPedido

WHERE EP.estado = 'Entregado'
GROUP BY C.id, C.nombre, C.apellido
ORDER BY C.id; -- agg adicional para que la consulta sea más ordenada

-- I
SELECT D.municipio, Co.nombre AS nombre_comercio, P.nombre AS nombre_plato,
    SUM(PD.cantidad) AS cantidad_vendida

FROM Pedido AS Pe
JOIN PedidoDetalle AS PD ON Pe.id = PD.idPedido
JOIN Plato AS P ON PD.idPlato = P.id
JOIN Seccion AS S ON P.idSeccion = S.id
JOIN Menu AS M ON S.idMenu = M.id
JOIN Comercio AS Co ON M.idComercio = Co.id
JOIN ClientePedido AS CP ON Pe.id = CP.idPedido
JOIN DireccionCliente AS DC ON CP.idCliente = DC.idCliente
JOIN Direccion AS D ON DC.idDireccion = D.id

WHERE P.nombre LIKE '%Pizza%'
GROUP BY D.municipio, Co.nombre, P.nombre
ORDER BY CantidadTotalVendida; -- ordena en ASC de manera predeterminada

-- J
SELECT P.nombre AS nombre_plato, S.nombre AS seccion_plato,
    ISNULL(
        STRING_AGG(O.nombre + ' ' + OV.nombre, ', '),
        'Sin opciones registradas'
    ) AS opciones_registradas

FROM Plato AS P
JOIN Seccion AS S ON P.idSeccion = S.id
LEFT JOIN PlatoOpcionValor AS POV ON P.id = POV.idPlato
LEFT JOIN OpcionValor AS OV ON POV.idOpcionValor = OV.id
LEFT JOIN Opcion AS O ON OV.idOpcion = O.id
GROUP BY P.id, P.nombre, S.nombre;

-- K 
SELECT 
    AVG(F.monto_total) AS ingreso_mensual_promedio,
    SUM(F.monto_total) AS ingreso_ultimo_anio,
    AVG(F.monto_total) * 12 AS ingreso_proyectado_12_meses,
    CASE
        WHEN SUM(F.monto_total) = 0 THEN 0 -- evitar división por cero
        ELSE ((AVG(F.monto_total) * 12 - SUM(F.monto_total)) / CAST(SUM(F.monto_total) AS DECIMAL(18, 2))) * 100 -- con CAST para mantener decimales en el cálculo
    END AS variacion_porcentual_estimada

FROM Factura AS F
WHERE F.fecha_emision >= DATEADD(year, -1, GETDATE()) AND F.fecha_emision <= GETDATE();
