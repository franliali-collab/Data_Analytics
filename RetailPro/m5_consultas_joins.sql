-- ============================================================================
-- CHECKPOINT MÓDULO 5: CONSULTAS SQL CON JOIN Y UNION
-- Proyecto: RetailPro / Base de Datos: Ventas_Tech_DB
-- Archivo: m5_consultas_joins.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONSULTA 1 — Vista base del proyecto (INNER JOIN)
-- Combina ventas, clientes, productos y categorias para generar la vista
-- enriquecida principal que servirá como fuente para Power BI.
-- ----------------------------------------------------------------------------
SELECT 
    v.fecha_venta,
    c.nombre AS nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta ASC;


-- ----------------------------------------------------------------------------
-- CONSULTA 2 — Clientes sin ventas (LEFT JOIN + IS NULL)
-- Identifica aquellos clientes registrados que aún no han realizado compras.
-- ----------------------------------------------------------------------------
SELECT 
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- ----------------------------------------------------------------------------
-- CONSULTA 3 — Productos sin ventas (LEFT JOIN + IS NULL)
-- Identifica los productos del catálogo que no tienen transacciones registradas.
-- ----------------------------------------------------------------------------
SELECT 
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


-- ----------------------------------------------------------------------------
-- CONSULTA 4 — Consolidado por canal u origen (UNION ALL)
-- Consolida transacciones mediante UNION ALL agregando una columna descriptiva 
-- del canal de venta y agrupando el total facturado.
-- ----------------------------------------------------------------------------
SELECT 
    canal_origen,
    SUM(total_venta) AS total_facturado,
    COUNT(id_venta) AS cantidad_operaciones
FROM (
    SELECT 
        id_venta, 
        'Online' AS canal_origen, 
        (cantidad * precio_unitario) AS total_venta
    FROM ventas
    WHERE id_venta % 2 <> 0 -- Ejemplo de segmentación por ventas Online (IDs impares)

    UNION ALL

    SELECT 
        id_venta, 
        'Presencial' AS canal_origen, 
        (cantidad * precio_unitario) AS total_venta
    FROM ventas
    WHERE id_venta % 2 = 0 -- Ejemplo de segmentación por ventas Presenciales (IDs pares)
) AS ventas_consolidadas
GROUP BY canal_origen;


-- ----------------------------------------------------------------------------
-- BLOQUE DE CIERRE — HALLAZGOS Y JUSTIFICACIÓN TÉCNICA
-- ----------------------------------------------------------------------------
/*
HALLAZGOS Y JUSTIFICACIÓN:
1. Vista Base Enriquecida: El INNER JOIN unifica las 4 tablas garantizando que Power BI 
   tenga acceso directo a las dimensiones de cliente, categoría y totales calculados.
2. Detección de Inactividad (LEFT JOIN + IS NULL): Permite al área de CRM identificar 
   clientes registrados que requieren campañas de reactivación, e identificar productos 
   de catálogo sin movimiento de stock.
3. Consolidación de Fuentes (UNION ALL): Mantiene la integridad de todos los registros 
   sin costo computacional extra al unificar canales de distribución.
*/