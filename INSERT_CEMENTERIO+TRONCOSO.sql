-- =========================================================
-- BASE DE DATOS: CEMENTERIO
-- Script 2: Inserción de datos + Ejecución de vistas y SPs
-- =========================================================

USE CEMENTERIO;

-- =========================================================
-- INSERCIÓN DE DATOS
-- El orden respeta las claves foráneas y los triggers
-- =========================================================

-- -------------------------
-- 1. SUCURSALES
-- -------------------------
INSERT INTO sucursales (nombre, direccion, telefono, email, fecha_apertura) VALUES
('Cementerio Central',    'Av. Libertad 1250, Buenos Aires', '011-4523-0001',  'central@cementerio.com', '1985-03-15'),
('Cementerio Parque Sur', 'Calle Paz 430, La Plata',         '0221-4412-0022', 'sur@cementerio.com',     '1998-07-20'),
('Cementerio Los Pinos',  'Ruta 8 km 45, Luján',            '02323-440033',   'pinos@cementerio.com',   '2005-11-10');

-- -------------------------
-- 2. SECTORES (2 por sucursal)
-- -------------------------
INSERT INTO sectores (nombre_sector, descripcion, id_sucursal) VALUES
('Jardín Principal',    'Zona central con lotes ajardinados',         1),
('Jardín de la Paz',    'Área tranquila con arboleda',                1),
('Mausoleos Familia',   'Sector exclusivo para mausoleos familiares', 2),
('Campo Abierto Norte', 'Parcelas al aire libre sin techado',         2),
('Jardín Central',      'Área principal con acceso vehicular',        3),
('Columbario',          'Nichos para urnas de cremación',             3);

-- -------------------------
-- 3. TIPOS DE ENTIERRO
-- -------------------------
INSERT INTO tipos_entierro (nombre_tipo, descripcion, precio_base) VALUES
('Féretro en tierra', 'Inhumación tradicional en ataúd bajo tierra',         50000.00),
('Nicho',             'Disposición en nicho de pared o galería',             35000.00),
('Cremación',         'Incineración del cuerpo y entrega de urna',           25000.00),
('Mausoleo Familiar', 'Sepultura en estructura cubierta de uso familiar',   120000.00);

-- -------------------------
-- 4. TIPOS DE LÁPIDA
-- -------------------------
INSERT INTO tipos_lapida (material, descripcion, precio) VALUES
('Mármol Blanco', 'Lápida de mármol blanco pulido, acabado brillante', 15000.00),
('Granito Negro', 'Lápida de granito negro con grabado láser',          12000.00),
('Hormigón Gris', 'Lápida estándar de hormigón gris liso',               5000.00);

-- -------------------------
-- 5. CARGOS DE EMPLEADOS
-- -------------------------
INSERT INTO cargos_empleado (nombre_cargo, descripcion, salario_base) VALUES
('Director/a de Sucursal', 'Gestiona la operación total de la sucursal',           150000.00),
('Asesor/a Comercial',     'Atiende clientes y genera contratos de servicio',       80000.00),
('Empleado/a de Campo',    'Realiza mantenimiento y tareas operativas in situ',     60000.00),
('Administrativo/a',       'Gestiona documentación interna y cobros',               70000.00);

-- -------------------------
-- 6. CLIENTES
-- -------------------------
INSERT INTO clientes (nombre, dni_cedula, telefono, email, direccion, fecha_registro) VALUES
('María Fernanda López',   '28456789', '11-6234-5678', 'mflopez@mail.com',   'Corrientes 834, CABA',            '2022-04-10'),
('Carlos Enrique Ramírez', '32145678', '221-534-9900', 'ceramirez@mail.com', 'Av. 7 N°450, La Plata',           '2022-08-15'),
('Ana Sofía Herrera',      '25789012', '11-5512-3344', 'asherrera@mail.com', 'Rivadavia 2210, Ramos Mejía',     '2023-01-22'),
('Roberto Javier Gómez',   '19234567', '2323-47-8800', 'rjgomez@mail.com',   'San Martín 101, Luján',           '2023-06-05'),
('Luciana Beatriz Torres', '30567890', '11-4478-2211', 'lbtorres@mail.com',  'Belgrano 560, Merlo',             '2023-09-18'),
('Jorge Alberto Paz',      '22890123', '221-488-7700', 'japaz@mail.com',     'H. Yrigoyen 1200, Quilmes',       '2024-02-01');

-- -------------------------
-- 7. EMPLEADOS
-- -------------------------
INSERT INTO empleados (nombre, dni_cedula, id_cargo, id_sucursal, fecha_ingreso, activo) VALUES
('Valeria Romero',        '27654321', 1, 1, '2010-05-01', 1),
('Sebastián Ríos',        '31987654', 2, 1, '2015-03-10', 1),
('Claudia Méndez',        '26321456', 1, 2, '2012-09-01', 1),
('Diego Arturo Flores',   '33765432', 3, 2, '2018-07-15', 1),
('Patricia Noemí Solís',  '29432187', 2, 3, '2020-01-20', 1),
('Hernán Luis Vera',      '35109876', 3, 3, '2021-11-03', 1);

-- -------------------------
-- 8. PROVEEDORES
-- -------------------------
INSERT INTO proveedores (nombre_empresa, contacto, telefono, email, rubro) VALUES
('Mármoles del Sur S.A.',  'Eduardo Blanco',    '011-4321-5566', 'ventas@marmolessur.com',  'Fabricación de lápidas'),
('Ataúdes Premium S.R.L.', 'Silvia Domínguez',  '0221-334-7788', 'info@ataudespremium.com', 'Fabricación de ataúdes'),
('Florería La Eternal',    'Marcos Vidal',       '02323-44-5599', 'floral@eternal.com',      'Arreglos florales y coronas');

-- -------------------------
-- 9. LOTES
-- Lotes 1-5  → se asignarán a difuntos (trigger los marcará Ocupado)
-- Lotes 6-7  → irán a mantenimiento  (trigger los marcará Mantenimiento)
-- Lotes 8-10 → permanecen Disponibles (para la vista y el stored procedure)
-- -------------------------
INSERT INTO lotes (codigo_ubicacion, estado, id_sector, id_sucursal) VALUES
('C1-SecA-F1-L1', 'Disponible', 1, 1),
('C1-SecA-F1-L2', 'Disponible', 1, 1),
('C1-SecB-F2-L1', 'Disponible', 2, 1),
('C2-SecC-F1-L1', 'Disponible', 3, 2),
('C2-SecD-F1-L1', 'Disponible', 4, 2),
('C2-SecD-F2-L1', 'Disponible', 4, 2),
('C3-SecE-F1-L1', 'Disponible', 5, 3),
('C3-SecE-F1-L2', 'Disponible', 5, 3),
('C3-SecE-F2-L1', 'Disponible', 5, 3),
('C3-SecF-N1',    'Disponible', 6, 3);

-- -------------------------
-- 10. FAMILIARES DE CLIENTES
-- -------------------------
INSERT INTO familiares_cliente (id_cliente, nombre, parentesco, telefono) VALUES
(1, 'Jorge López',     'Esposo',  '11-6234-0001'),
(2, 'Marta Ramírez',   'Madre',   '221-500-1111'),
(3, 'Pablo Herrera',   'Hermano', '11-5512-9900'),
(4, 'Elena Gómez',     'Cónyuge', '2323-41-0022'),
(5, 'Tomás Torres',    'Hijo',    '11-4478-8800');

-- -------------------------
-- 11. DIFUNTOS
-- Al insertar cada difunto, el trigger tr_actualizar_estado_lote
-- cambia automáticamente el estado del lote a 'Ocupado'.
-- -------------------------
INSERT INTO difuntos (nombre_completo, fecha_nacimiento, fecha_fallecimiento, causa_fallecimiento, id_lote, id_tipo_entierro, id_cliente_responsable) VALUES
('Alberto José López Ríos',   '1942-06-12', '2022-04-11', 'Insuficiencia cardíaca',    1, 1, 1),
('Elena Carmen Fonseca',      '1955-11-03', '2022-08-20', 'Cáncer de pulmón',          2, 2, 2),
('Mario Óscar Benedetti',     '1938-02-28', '2023-01-25', 'Accidente cerebrovascular', 3, 3, 3),
('Cristina Beatriz Salinas',  '1947-09-17', '2023-06-08', 'Vejez',                     4, 1, 4),
('Rodolfo Ernesto Gutiérrez', '1951-07-04', '2023-09-22', 'Diabetes complicada',       5, 4, 5);

-- -------------------------
-- 12. LÁPIDAS
-- -------------------------
INSERT INTO lapidas (id_lote, id_tipo_lapida, inscripcion, fecha_colocacion, id_proveedor) VALUES
(1, 1, 'Alberto López Ríos – En tu memoria, siempre',  '2022-04-20', 1),
(2, 2, 'Elena Fonseca – Luz que nunca se apaga',        '2022-09-01', 1),
(3, 3, 'Mario Benedetti – Las palabras no mueren',      '2023-02-10', 1),
(4, 1, 'Cristina Salinas – Con amor eterno, tu familia','2023-06-20', 1);

-- -------------------------
-- 13. CATÁLOGO DE SERVICIOS Y PRECIOS
-- -------------------------
INSERT INTO precios_servicios (concepto, descripcion, monto, activo) VALUES
('Servicio de inhumación', 'Traslado, preparación del cuerpo y entierro',      50000.00, 1),
('Servicio de cremación',  'Incineración completa y entrega de urna',          25000.00, 1),
('Mantenimiento de lote',  'Limpieza y cuidado mensual del lote asignado',      8000.00, 1),
('Colocación de lápida',   'Instalación y grabado de lápida',                  15000.00, 1),
('Arreglo floral',         'Corona o arreglo floral para el sepelio',           3500.00, 1);

-- -------------------------
-- 14. CONTRATOS (Tabla Transaccional 1)
-- -------------------------
INSERT INTO contratos (id_cliente, id_difunto, id_lote, tipo_contrato, estado, id_empleado, observaciones) VALUES
(1, 1, 1, 'Inmediato',  'Finalizado', 2, 'Contrato cerrado, pago total transferido'),
(2, 2, 2, 'Inmediato',  'Finalizado', 2, 'Incluye arreglo floral adicional'),
(3, 3, 3, 'Inmediato',  'Activo',     5, 'Cuota de mantenimiento aún pendiente'),
(4, 4, 4, 'Inmediato',  'Finalizado', 5, 'Abonado íntegramente en efectivo'),
(6, NULL, 10, 'Prevision', 'Activo', 2, 'Contrato de prevención sin difunto aún asignado');

-- -------------------------
-- 15. TRANSACCIONES (Tabla Transaccional 2)
-- Al insertar cada transacción, el trigger tr_insertar_hecho_servicio
-- registra automáticamente el evento en la tabla de hechos.
-- -------------------------
INSERT INTO transacciones (id_cliente, id_empleado, id_servicio, id_contrato, monto_pagado, metodo_pago, estado_pago) VALUES
(1, 2, 1, 1, 50000.00, 'Transferencia', 'Pagado'),
(1, 2, 4, 1, 15000.00, 'Tarjeta',       'Pagado'),
(2, 2, 1, 2, 50000.00, 'Efectivo',      'Pagado'),
(3, 5, 2, 3, 25000.00, 'Cheque',        'Pagado'),
(4, 5, 1, 4, 50000.00, 'Transferencia', 'Pagado');

-- -------------------------
-- 16. MANTENIMIENTO DE LOTES
-- Al insertar: trigger tr_inicio_mantenimiento → lote pasa a 'Mantenimiento'.
-- Al actualizar fecha_fin: trigger tr_fin_mantenimiento → lote vuelve a 'Disponible'.
-- -------------------------
INSERT INTO mantenimiento_lotes (id_lote, id_empleado, fecha_inicio, descripcion, costo) VALUES
(6, 4, '2024-03-01', 'Reparación de bordillo y nivelación del terreno', 12000.00),
(7, 6, '2024-03-10', 'Limpieza profunda y replantación de césped',       8500.00);

-- Cerrar el mantenimiento del lote 7:
-- trigger tr_fin_mantenimiento → lote 7 vuelve a 'Disponible'
UPDATE mantenimiento_lotes
SET    fecha_fin = '2024-03-25'
WHERE  id_mantenimiento = 2;


-- =========================================================
-- EJECUCIÓN DE VISTAS
-- =========================================================

SELECT 'VISTA 1: Detalle completo de difuntos' AS Reporte;
SELECT * FROM v_difuntos_detalle;

SELECT 'VISTA 2: Lotes disponibles con ubicacion' AS Reporte;
SELECT * FROM v_lotes_disponibles;

SELECT 'VISTA 3: Historial de transacciones' AS Reporte;
SELECT * FROM v_historial_transacciones;

SELECT 'VISTA 4: Empleados con cargo y sucursal' AS Reporte;
SELECT * FROM v_empleados_detalle;

SELECT 'VISTA 5: Ingresos por sucursal y mes' AS Reporte;
SELECT * FROM v_ingresos_por_sucursal;

SELECT 'VISTA 6: Contratos activos' AS Reporte;
SELECT * FROM v_contratos_activos;


-- =========================================================
-- EJECUCIÓN DE FUNCIONES
-- =========================================================

SELECT 'FUNCION 1: Edad al fallecer de Alberto Lopez' AS Reporte;
SELECT fn_calcular_edad_difunto('1942-06-12', '2022-04-11') AS edad_al_fallecer;

SELECT 'FUNCION 2: Total pagado por el cliente ID 1' AS Reporte;
SELECT fn_total_pagado_cliente(1) AS total_pagado;

SELECT 'FUNCION 2: Total pagado por el cliente ID 3' AS Reporte;
SELECT fn_total_pagado_cliente(3) AS total_pagado;


-- =========================================================
-- EJECUCIÓN DE STORED PROCEDURES
-- =========================================================

-- -------------------------------------------------------
-- SP 1: Registrar nuevo difunto usando un lote disponible
-- El trigger tr_actualizar_estado_lote cambiará lote 8 a 'Ocupado'
-- -------------------------------------------------------
SELECT 'SP 1: Registrando nuevo difunto en lote 8' AS Reporte;

CALL sp_registrar_difunto(
    'Graciela Susana Morales',
    '1960-03-14',
    '2024-04-10',
    'Paro respiratorio',
    8,   -- Lote 8: Disponible
    2,   -- Tipo: Nicho
    6    -- Cliente: Jorge Alberto Paz
);

-- Verificación: el difunto fue creado y el lote cambió a Ocupado
SELECT 'Verificacion SP 1: difunto creado' AS Reporte;
SELECT id_difunto, nombre_completo, fecha_fallecimiento, id_lote
FROM   difuntos
ORDER  BY id_difunto DESC
LIMIT  1;

SELECT 'Verificacion SP 1: estado del lote 8' AS Reporte;
SELECT id_lote, codigo_ubicacion, estado FROM lotes WHERE id_lote = 8;

-- -------------------------------------------------------
-- SP 2: Registrar pago para el nuevo difunto
-- Se crea el contrato y luego se llama al SP de pago
-- El trigger tr_insertar_hecho_servicio poblará hechos_servicios
-- -------------------------------------------------------
SELECT 'SP 2: Registrando contrato y pago para el nuevo difunto' AS Reporte;

-- Obtener id del difunto recién registrado
SET @id_nuevo_difunto = LAST_INSERT_ID();

-- Crear contrato asociado
INSERT INTO contratos (id_cliente, id_difunto, id_lote, tipo_contrato, estado, id_empleado, observaciones)
VALUES (6, @id_nuevo_difunto, 8, 'Inmediato', 'Activo', 5, 'Contrato generado post SP demo');

SET @id_nuevo_contrato = LAST_INSERT_ID();

-- Registrar el pago mediante el stored procedure
CALL sp_registrar_pago(
    6,                    -- id_cliente: Jorge Alberto Paz
    5,                    -- id_empleado: Patricia Noemí Solís
    2,                    -- id_servicio: Cremación
    @id_nuevo_contrato,   -- id_contrato recién creado
    35000.00,
    'Tarjeta'
);

-- Verificación: la transacción fue creada
SELECT 'Verificacion SP 2: transaccion registrada' AS Reporte;
SELECT * FROM v_historial_transacciones
ORDER  BY id_transaccion DESC
LIMIT  1;

-- Verificación: el trigger pobló la tabla de hechos automáticamente
SELECT 'Verificacion SP 2: hecho registrado por trigger' AS Reporte;
SELECT * FROM hechos_servicios
ORDER  BY id_hecho DESC
LIMIT  1;

-- =========================================================
-- RESUMEN FINAL DEL ESTADO DE LA BASE DE DATOS
-- =========================================================

SELECT 'RESUMEN: Estado de todos los lotes' AS Reporte;
SELECT l.id_lote, l.codigo_ubicacion, l.estado,
       s.nombre_sector AS sector, su.nombre AS sucursal
FROM   lotes l
JOIN   sectores    s  ON l.id_sector   = s.id_sector
JOIN   sucursales  su ON l.id_sucursal = su.id_sucursal
ORDER  BY l.id_lote;

SELECT 'RESUMEN: Total de registros por tabla principal' AS Reporte;
SELECT 'sucursales'        AS tabla, COUNT(*) AS registros FROM sucursales        UNION ALL
SELECT 'clientes',                   COUNT(*)              FROM clientes           UNION ALL
SELECT 'empleados',                  COUNT(*)              FROM empleados          UNION ALL
SELECT 'lotes',                      COUNT(*)              FROM lotes              UNION ALL
SELECT 'difuntos',                   COUNT(*)              FROM difuntos           UNION ALL
SELECT 'contratos',                  COUNT(*)              FROM contratos          UNION ALL
SELECT 'transacciones',              COUNT(*)              FROM transacciones      UNION ALL
SELECT 'hechos_servicios',           COUNT(*)              FROM hechos_servicios;
