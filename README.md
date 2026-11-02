# Análisis comercial de un E-commerce



## 1. Descripción del proyecto

Análisis comercial de un e-commerce del sector cosmético que opera en cinco países (Italia, España, Marruecos, Francia y Alemania) y organiza su catálogo en cuatro categorías: Hair, Makeup, Body y Skin. El período analizado es el año 2024.

El objetivo es comprender el desempeño del negocio, identificar oportunidades comerciales y desarrollar propuestas de acción orientadas a mejorar las ventas.

Se utilizó SQL para consultar los datos y Power BI para visualizarlos. El trabajo combina análisis de datos e interpretación comercial, con el fin de transformar la información en conclusiones y recomendaciones para la toma de decisiones.

## 2. Objetivos del análisis

- Analizar la evolución de las ventas y la facturación.
- Identificar los mercados con mayor participación en los ingresos.
- Evaluar el rendimiento comercial de productos y categorías.
- Analizar el comportamiento de compra de los clientes.
- Detectar oportunidades de crecimiento y mejora comercial.
- Elaborar propuestas de acción para incrementar las ventas, fidelizar clientes y reducir cancelaciones y devoluciones.

## 3. Herramientas utilizadas

- **MySQL:** consultas y análisis de datos.
- **DBeaver:** entorno de trabajo para SQL.
- **Power BI:** desarrollo del dashboard e indicadores comerciales.

## 4. Datos

Base de datos de e-commerce obtenida de internet, compuesta por cinco tablas: `Customers`, `Products`, `Order_items`, `Orders` y `Sales_cleaned`.

La facturación y el ticket promedio consideran únicamente los pedidos con estado *Completed* que quedaron luego del proceso de limpieza de datos (695 pedidos). El análisis de estados de los pedidos (completados, cancelados y devueltos) se realiza sobre la base original de 1.000 pedidos.

## 5. Áreas de análisis

- **Ventas y facturación:** evolución mensual y trimestral, y facturación por país y por categoría.
- **Productos y categorías:** unidades vendidas, facturación y Top 20 de productos.
- **Clientes:** cantidad por país, clientes que nunca compraron y facturación por cliente.
- **Pedidos:** cantidad y estado de las operaciones (completados, cancelados y devueltos).

## 6. Principales hallazgos

- **Facturación 2024:** $311.730 sobre 695 pedidos completados, con un ticket promedio de $448,53.
- **Mercados:** Italia ($70.719) y España ($69.897) lideran la facturación, con una diferencia de apenas 1,2%.
- **Categorías:** HAIR es la que más factura ($102.045), seguida de MAKEUP ($81.296), BODY ($76.011) y SKIN ($52.378).
- **Clientes:** el 11% de los clientes registrados (33 de 300) nunca realizó una compra. Alemania es el país con mayor porcentaje (15%).
- **Pedidos:** el 80,5% se completa, el 10,3% se cancela y el 9,2% se devuelve.
- **Potencial:** si esos 33 clientes compraran como el promedio ($1.168), la facturación podría alcanzar cerca de $350.274.

## 7. Propuestas de mejora comercial

- **Captación de clientes potenciales:** contactar a los usuarios registrados que nunca realizaron una compra, conocer sus motivos y ofrecer beneficios de bienvenida.
- **Reactivación y fidelización:** implementar sorteos, acciones participativas, programas de referidos y comunicaciones personalizadas según las preferencias de los clientes.
- **Impulso de ventas:** reforzar las campañas publicitarias durante los meses de menor facturación, priorizando los mercados con mayor potencial, especialmente España.
- **Reducción de cancelaciones y devoluciones:** incorporar motivos de cancelación y devolución en el proceso de pedidos para identificar problemas y desarrollar acciones correctivas.

## 8. Entregables

- [Informe ejecutivo (PDF)](informe/Analisis_comercial_E-commerce.pdf): resultados, conclusiones y propuestas de mejora comercial.
- [Dashboard en Power BI](dashboard/dsahboard_analisis_ecommerce.pbix): indicadores comerciales interactivos.
- [Consultas SQL](consultas.sql): consultas utilizadas en el análisis.

## 9. Estructura del repositorio

```
analisis-comercial-ecommerce/
├── README.md
├── informe/
