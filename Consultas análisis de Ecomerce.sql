/* .
PROYECTO: Análisis de ventas de un e-commerce

OBJETIVO: Analizar el desempeño de las ventas, la facturación,
          el rendimiento de productos y categorías, el comportamiento
          de los clientes y la actividad de los pedidos.

BASE DE DATOS: ecomerce
HERRAMIENTAS: MySQL / DBeaver


NOTA:
Este archivo reúne las consultas SQL utilizadas en el proyecto.
Se conserva la lógica de las consultas del archivo original.
*/



USE ecomerce;

-- 1.1 ¿Cuantos clientes tenemos?

SELECT count(*) AS cantidad_total_de_clientes
FROM customers c ;

-- 1.2 ¿Cómo está conformada la base de clientes? ¿En qué países se encuentran?

SELECT country,
count(*) AS cantidad_de_clientes_x_país
FROM customers c 
GROUP BY country;

-- 1.3 ¿Cuál es la facturación anual? 

SELECT YEAR,
sum(revenue) AS facturacion 
FROM sales_cleaned sc 
GROUP BY YEAR;

-- 1.4 ¿Cual es la facturación mensual?

SELECT MONTH,
sum(revenue) AS facturación
FROM sales_cleaned sc 
GROUP BY MONTH
ORDER BY MONTH asc;

-- 1.5 ¿Cómo está formada esa facturación? Por rubro

SELECT p.category,
sum(sc.Revenue ) AS facturacion 
FROM sales_cleaned sc 
JOIN products p 
ON p.product_id = sc.product_id 
GROUP BY p.category WITH ROLLUP;

-- 1.6 Cual es la facturacion por rubro por trimestre

SELECT EXTRACT(QUARTER FROM sc.order_date) AS trimestre,
       p.category AS rubro,
       SUM(sc.revenue) AS facturacion,
       ROUND(100.0 * SUM(sc.revenue)
             / SUM(SUM(sc.revenue)) OVER (PARTITION BY EXTRACT(QUARTER FROM sc.order_date)), 2) AS porcentaje
FROM sales_cleaned sc
JOIN products p
  ON sc.product_id = p.product_id
GROUP BY EXTRACT(QUARTER FROM sc.order_date), p.category
ORDER BY trimestre, facturacion DESC;


-- 1.7 ¿Cuál es la facuración total por país?

SELECT c.country,
sum(sc.revenue) AS facturacion 
FROM customers c 
JOIN sales_cleaned sc 
ON c.customer_id = sc.customer_id 
GROUP BY c.country WITH ROLLUP;

-- 1.7.1 ¿Cual es el ratio facturación/cliente por país?

WITH facturacion_x_pais AS (
SELECT c.country,
sum(sc.revenue) AS facturacion 
FROM customers c 
JOIN sales_cleaned sc 
ON c.customer_id = sc.customer_id 
GROUP BY country
),

clientes_x_pais AS (
SELECT country,
count(*) AS cantidad_de_clientes_x_país
FROM customers c 
GROUP BY country
)

SELECT c.country,
ROUND((facturacion / cantidad_de_clientes_x_país), 2) AS ratio
FROM facturacion_x_pais f
JOIN clientes_x_pais c
ON f.country = c.country;





-- 1.8 ¿Cuántas unidades se vendieron por producto?

SELECT p.product_name,
sum(sc.quantity) AS cantidad_unidades
FROM products p 
JOIN sales_cleaned sc 
ON p.product_id = sc.product_id 
GROUP BY p.product_name WITH ROLLUP
ORDER BY p.product_name IS NULL, cantidad_unidades DESC;

-- 1.8.1 Cantidad de unidades vendidas por rubro

SELECT p.category,
       SUM(oi.quantity) AS cantidad_unid_vendidas
FROM order_items oi
JOIN orders o
  ON oi.order_id = o.order_id
JOIN products p
  ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY cantidad_unid_vendidas DESC; 

-- 1.8.2 ¿Cuál es el ticket promedio?


WITH facturacion_x_ticket AS ( 
SELECT order_id,
sum(quantity * price) AS facturacion 
FROM sales_cleaned
GROUP BY order_id
)

SELECT ROUND( sum(facturacion) / count(DISTINCT order_id), 2) AS ticket_promedio
FROM facturacion_x_ticket;

-- 1.8.3 Cantidad en promedio de unidades vendidas por pedido

SELECT ROUND(SUM(quantity) / COUNT(DISTINCT order_id), 2) AS unidades_promedio_x_pedido
FROM sales_cleaned;


-- 2.1 ¿Cómo evolucionaron las ventas por mes?


SELECT MONTH,
sum(revenue) AS facturación 
FROM sales_cleaned sc 
GROUP BY MONTH
ORDER BY MONTH ASC;

-- 2.2 ¿Cómo se compara un mes con el anterior?

WITH facturacion_mensual AS (
SELECT MONTH,
sum(revenue) AS facturación 
FROM sales_cleaned sc 
GROUP BY MONTH
ORDER BY MONTH ASC
),

facturacion_del_mes_anterior AS (
SELECT MONTH, facturación,
lag(facturación) OVER ( ORDER BY month ) AS facturación_anterior
FROM facturacion_mensual sc 

)

SELECT MONTH, facturación, facturación_anterior,
round ((facturación - facturación_anterior) / facturación_anterior * 100, 0) AS variacion_porcentual
FROM facturacion_del_mes_anterior;


-- 3.1 ¿Cuáles son los productos que generan mayor facturación?

SELECT p.product_name, 
sum(sc.Revenue ) AS facturacion
FROM products p 
JOIN sales_cleaned sc 
ON p.product_id = sc.product_id  
GROUP BY p.product_name 
ORDER BY facturacion DESC;


-- 3.2 ¿Hay productos que venden muchas unidades pero generan poco dinero?


WITH unidades_facturacion AS (
SELECT p.product_name,
sum(sc.quantity) AS unidades_vendidas,
sum(sc.Revenue ) AS facturacion
FROM products p 
JOIN sales_cleaned sc 
ON p.product_id = sc.product_id 
GROUP BY p.product_name 
ORDER BY facturacion desc
)

SELECT product_name, unidades_vendidas, facturacion,
ROUND(facturacion / unidades_vendidas, 2) AS pcio_prom_x_unidad
FROM unidades_facturacion;

-- 3.3 ¿Qué categorías funcionan mejor?


WITH facturacion_x_categoria AS (
SELECT p.category,
sum(sc.Revenue ) AS facturacion 
FROM sales_cleaned sc 
JOIN products p 
ON p.product_id = sc.product_id 
GROUP BY p.category

),

cant_prod_x_categoria AS (
SELECT category, 
count(p.product_id ) AS cantidad
FROM products p 
GROUP BY category
)

SELECT c.category,
       f.facturacion,
       ROUND(f.facturacion * 100 / SUM(f.facturacion) OVER (), 2) AS pct_del_total,
       c.cantidad AS cant_productos,
       ROUND(f.facturacion / c.cantidad, 2) AS fact_prom_x_prod
FROM cant_prod_x_categoria c
JOIN facturacion_x_categoria f
  ON c.category = f.category
ORDER BY f.facturacion DESC;

-- 3.4 ¿Qué categorías están perdiendo participación?



WITH trimestres AS (
    SELECT p.category,
           SUM(CASE WHEN sc.month IN (1,2,3) THEN sc.revenue ELSE 0 END) AS fact_1er_trimestre,
           SUM(CASE WHEN sc.month IN (10,11,12) THEN sc.revenue ELSE 0 END) AS fact_4to_trimestre
    FROM sales_cleaned sc
    JOIN products p
        ON p.product_id = sc.product_id
    GROUP BY p.category
)
SELECT category,
       fact_1er_trimestre,
       fact_4to_trimestre,
       ROUND(fact_1er_trimestre * 100 / SUM(fact_1er_trimestre) OVER (), 2) AS part_1er_trimestre,
       ROUND(fact_4to_trimestre * 100 / SUM(fact_4to_trimestre) OVER (), 2) AS part_4_trimestre,
       ROUND(fact_4to_trimestre * 100 / SUM(fact_4to_trimestre) OVER ()
           - fact_1er_trimestre * 100 / SUM(fact_1er_trimestre) OVER (), 2) AS variacion_puntos
FROM trimestres
ORDER BY variacion_puntos;



-- 4.1 ¿Cuántos clientes nunca compraron?

SELECT c.country,
count(*) AS inactivos
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
GROUP BY c.country;

-- 4.2 ¿cuántos clientes tienen al menos un pedido completado?

SELECT status,
count(DISTINCT customer_id) AS pedidos_completos
FROM sales_cleaned
WHERE status = 'Completed';



SELECT status,
count(DISTINCT customer_id) AS pedidos_cancelados
FROM sales_cleaned
WHERE status = '';


-- 4.3 ¿Cuál es la facturación por cliente?

SELECT customer_id,
sum(revenue) AS facturacion_x_cliente
FROM sales_cleaned
GROUP BY customer_id
ORDER BY facturacion_x_cliente desc;

-- 4.3.1 ¿Cúal es la facturación promedio por cliente?

SELECT SUM(revenue) AS facturacion_total,
       COUNT(DISTINCT customer_id) AS cant_clientes,
       ROUND(SUM(revenue) / NULLIF(COUNT(DISTINCT customer_id), 0), 0) AS facturacion_por_cliente
FROM sales_cleaned sc;

-- 4.4 ¿Cuál es la frecuencia de re compra? 

SELECT customer_id,
count(DISTINCT order_id) AS cantidad
FROM sales_cleaned
GROUP BY customer_id
ORDER BY cantidad DESC
LIMIT 20;

-- 4.5 ¿Cuál es el ticket promedio por cliente?


WITH consumo_x_cliente AS (
     SELECT customer_id,
            sum(revenue) AS facturacion_x_cliente
     FROM sales_cleaned
     GROUP BY customer_id
),

cant_pedidos_x_clientes AS (
    SELECT customer_id,
    count(DISTINCT order_id) AS pedidos_x_clientes
    FROM sales_cleaned
    GROUP BY customer_id
)

SELECT c.customer_id, facturacion_x_cliente, pedidos_x_clientes,
ROUND(facturacion_x_cliente / pedidos_x_clientes, 2) AS ticket_promedio
FROM cant_pedidos_x_clientes p
JOIN consumo_x_cliente c
ON c.customer_id = p.customer_id
ORDER BY ticket_promedio desc;

-- 4.6 ¿Cuál es el valor promedio de un cliente?

SELECT ROUND(SUM(revenue) / (SELECT COUNT(DISTINCT customer_id) FROM sales_cleaned), 2 )  AS valor_promedio_cliente
FROM sales_cleaned;

-- 5.1 ¿Cuantos pedidos hay cancelados por pais?

SELECT c.country,
COUNT(DISTINCT o.order_id)AS pedidos_cancelados
FROM orders o 
JOIN customers c 
ON o.customer_id = c.customer_id 
WHERE o.status = 'Cancelled'
GROUP BY c.country ;

-- 5.2 ¿Cantidad de pedidos por país?

SELECT c.country,
COUNT(DISTINCT o.ORDER_id) AS cantidad_de_pedidos_x_pais
FROM customers c 
JOIN orders o 
ON c.customer_id = o.customer_id 
GROUP BY c.country
ORDER BY cantidad_de_pedidos_x_pais DESC;









