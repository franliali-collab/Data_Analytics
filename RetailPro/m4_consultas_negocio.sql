-- ============================================================================
-- CHECKPOINT MÓDULO 4: CONSULTAS SQL DE NEGOCIO
-- Proyecto: RetailPro / Base de Datos: Ventas_Tech_DB
-- Archivo: m4_consultas_negocio.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONSULTA 1 — Resumen ejecutivo mensual
-- ----------------------------------------------------------------------------
SELECT 
    MONTH(fecha_venta) AS mes_numero,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(id_venta) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes_numero;

-- ----------------------------------------------------------------------------
-- CONSULTA 2 — Productos más vendidos por volumen y facturación
-- ----------------------------------------------------------------------------
SELECT 
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS ingresos_totales
FROM ventas
GROUP BY id_producto
ORDER BY ingresos_totales DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 3 — Clientes principales (Top Buyers > $500)
-- ----------------------------------------------------------------------------
SELECT 
    id_cliente,
    COUNT(id_venta) AS total_compras,
    SUM(cantidad * precio_unitario) AS monto_total_gastado
FROM ventas
GROUP BY id_cliente
HAVING SUM(cantidad * precio_unitario) > 500
ORDER BY monto_total_gastado DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 4 — Meses por encima/por debajo del promedio general
-- ----------------------------------------------------------------------------
WITH VentasMensuales AS (
    SELECT 
        MONTH(fecha_venta) AS mes_numero,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT 
    mes_numero,
    total_facturado,
    CASE 
        WHEN total_facturado >= (SELECT AVG(total_facturado) FROM VentasMensuales) 
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_vs_promedio
FROM VentasMensuales
ORDER BY mes_numero;

-- ----------------------------------------------------------------------------
-- BLOQUE DE CIERRE — HALLAZGOS DE NEGOCIO
-- ----------------------------------------------------------------------------
/*
HALLAZGOS CLAVE:
1. Concentración de producto: El id_producto = 1 concentra el mayor volumen de facturación por su alto precio unitario.
2. Clientes Top: Los clientes id_cliente 1 y 5 superan el umbral de $500 facturados acumulados.
3. Rendimiento mensual: Marzo registró la mayor actividad comercial quedando por encima del promedio mensual.
*/