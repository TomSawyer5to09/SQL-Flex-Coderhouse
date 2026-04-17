-- =========================================================
-- BASE DE DATOS: CEMENTERIO
-- Script completo: tablas, vistas, funciones, SPs y triggers
-- =========================================================

CREATE DATABASE IF NOT EXISTS CEMENTERIO;
USE CEMENTERIO;

-- =========================================================
-- TABLAS DIMENSIONALES
-- =========================================================

-- 1. Sucursales del cementerio
CREATE TABLE sucursales (
    id_sucursal    INT PRIMARY KEY AUTO_INCREMENT,
    nombre         VARCHAR(100) NOT NULL,
    direccion      TEXT,
    telefono       VARCHAR(20),
    email          VARCHAR(100),
    fecha_apertura DATE
);

-- 2. Sectores dentro de cada sucursal (Ej: Sector A, Jardín de Niños)
CREATE TABLE sectores (
    id_sector    INT PRIMARY KEY AUTO_INCREMENT,
    nombre_sector VARCHAR(50) NOT NULL,
    descripcion  TEXT,
    id_sucursal  INT NOT NULL,
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
);

-- 3. Tipos de entierro (Cremación, Féretro, Nicho, etc.)
CREATE TABLE tipos_entierro (
    id_tipo      INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tipo  VARCHAR(50) NOT NULL,
    descripcion  TEXT,
    precio_base  DECIMAL(10,2) DEFAULT 0.00
);

-- 4. Tipos de lápida (Mármol, Granito, etc.)
CREATE TABLE tipos_lapida (
    id_tipo_lapida INT PRIMARY KEY AUTO_INCREMENT,
    material       VARCHAR(50) NOT NULL,
    descripcion    TEXT,
    precio         DECIMAL(10,2) NOT NULL
);

-- 5. Cargos / Puestos de empleados
CREATE TABLE cargos_empleado (
    id_cargo     INT PRIMARY KEY AUTO_INCREMENT,
    nombre_cargo VARCHAR(50) NOT NULL,
    descripcion  TEXT,
    salario_base DECIMAL(10,2)
);

-- 6. Clientes (responsables de difuntos o compradores de prevención)
CREATE TABLE clientes (
    id_cliente     INT PRIMARY KEY AUTO_INCREMENT,
    nombre         VARCHAR(100) NOT NULL,
    dni_cedula     VARCHAR(20) UNIQUE,
    telefono       VARCHAR(20),
    email          VARCHAR(100),
    direccion      TEXT,
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- 7. Familiares / contactos adicionales del cliente
CREATE TABLE familiares_cliente (
    id_familiar INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente  INT NOT NULL,
    nombre      VARCHAR(100) NOT NULL,
    parentesco  VARCHAR(50),
    telefono    VARCHAR(20),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- 8. Empleados
CREATE TABLE empleados (
    id_empleado   INT PRIMARY KEY AUTO_INCREMENT,
    nombre        VARCHAR(100) NOT NULL,
    dni_cedula    VARCHAR(20) UNIQUE,
    id_cargo      INT,
    id_sucursal   INT,
    fecha_ingreso DATE,
    activo        TINYINT(1) DEFAULT 1,
    FOREIGN KEY (id_cargo)    REFERENCES cargos_empleado(id_cargo),
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
);

-- 9. Proveedores (lápidas, ataúdes, flores, etc.)
CREATE TABLE proveedores (
    id_proveedor   INT PRIMARY KEY AUTO_INCREMENT,
    nombre_empresa VARCHAR(100) NOT NULL,
    contacto       VARCHAR(100),
    telefono       VARCHAR(20),
    email          VARCHAR(100),
    rubro          VARCHAR(100)
);

-- 10. Lotes / Parcelas del cementerio
CREATE TABLE lotes (
    id_lote          INT PRIMARY KEY AUTO_INCREMENT,
    codigo_ubicacion VARCHAR(50) UNIQUE,
    estado           ENUM('Disponible','Ocupado','Reservado','Mantenimiento') DEFAULT 'Disponible',
    id_sector        INT,
    id_sucursal      INT,
    FOREIGN KEY (id_sector)   REFERENCES sectores(id_sector),
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
);

-- 11. Lápidas (asociadas a un lote)
CREATE TABLE lapidas (
    id_lapida       INT PRIMARY KEY AUTO_INCREMENT,
    id_lote         INT UNIQUE,
    id_tipo_lapida  INT,
    inscripcion     TEXT,
    fecha_colocacion DATE,
    id_proveedor    INT,
    FOREIGN KEY (id_lote)        REFERENCES lotes(id_lote),
    FOREIGN KEY (id_tipo_lapida) REFERENCES tipos_lapida(id_tipo_lapida),
    FOREIGN KEY (id_proveedor)   REFERENCES proveedores(id_proveedor)
);

-- 12. Difuntos
CREATE TABLE difuntos (
    id_difunto           INT PRIMARY KEY AUTO_INCREMENT,
    nombre_completo      VARCHAR(150) NOT NULL,
    fecha_nacimiento     DATE,
    fecha_fallecimiento  DATE NOT NULL,
    causa_fallecimiento  VARCHAR(200),
    id_lote              INT,
    id_tipo_entierro     INT,
    id_cliente_responsable INT,
    FOREIGN KEY (id_lote)              REFERENCES lotes(id_lote),
    FOREIGN KEY (id_tipo_entierro)     REFERENCES tipos_entierro(id_tipo),
    FOREIGN KEY (id_cliente_responsable) REFERENCES clientes(id_cliente)
);

-- 13. Catálogo de precios y servicios
CREATE TABLE precios_servicios (
    id_servicio INT PRIMARY KEY AUTO_INCREMENT,
    concepto    VARCHAR(100) NOT NULL,
    descripcion TEXT,
    monto       DECIMAL(10,2) NOT NULL,
    activo      TINYINT(1) DEFAULT 1
);

-- =========================================================
-- TABLAS TRANSACCIONALES
-- =========================================================

-- 14. Contratos (Transaccional 1)
--     Puede ser por prevención (antes del fallecimiento) o inmediato
CREATE TABLE contratos (
    id_contrato   INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente    INT NOT NULL,
    id_difunto    INT,
    id_lote       INT,
    fecha_contrato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_contrato  ENUM('Prevision','Inmediato') NOT NULL,
    estado         ENUM('Activo','Cancelado','Finalizado') DEFAULT 'Activo',
    id_empleado   INT,
    observaciones TEXT,
    FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_difunto)  REFERENCES difuntos(id_difunto),
    FOREIGN KEY (id_lote)     REFERENCES lotes(id_lote),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

-- 15. Transacciones / Pagos (Transaccional 2)
CREATE TABLE transacciones (
    id_transaccion INT PRIMARY KEY AUTO_INCREMENT,
    fecha_pago     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_cliente     INT NOT NULL,
    id_empleado    INT,
    id_servicio    INT,
    id_contrato    INT,
    monto_pagado   DECIMAL(10,2) NOT NULL,
    metodo_pago    ENUM('Efectivo','Tarjeta','Transferencia','Cheque') NOT NULL,
    estado_pago    ENUM('Pagado','Pendiente','Anulado') DEFAULT 'Pagado',
    FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    FOREIGN KEY (id_servicio) REFERENCES precios_servicios(id_servicio),
    FOREIGN KEY (id_contrato) REFERENCES contratos(id_contrato)
);

-- =========================================================
-- TABLA DE HECHOS (para análisis y reportes)
-- =========================================================

-- 16. Hechos de servicios funerarios
--     Registra cada evento de servicio con sus dimensiones clave
CREATE TABLE hechos_servicios (
    id_hecho         INT PRIMARY KEY AUTO_INCREMENT,
    fecha_servicio   DATE NOT NULL,
    id_sucursal      INT,
    id_sector        INT,
    id_tipo_entierro INT,
    id_cliente       INT,
    id_empleado      INT,
    id_difunto       INT,
    id_contrato      INT,
    id_transaccion   INT,
    monto_total      DECIMAL(10,2),
    cantidad_servicios INT DEFAULT 1,
    FOREIGN KEY (id_sucursal)      REFERENCES sucursales(id_sucursal),
    FOREIGN KEY (id_sector)        REFERENCES sectores(id_sector),
    FOREIGN KEY (id_tipo_entierro) REFERENCES tipos_entierro(id_tipo),
    FOREIGN KEY (id_cliente)       REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_empleado)      REFERENCES empleados(id_empleado),
    FOREIGN KEY (id_difunto)       REFERENCES difuntos(id_difunto),
    FOREIGN KEY (id_contrato)      REFERENCES contratos(id_contrato),
    FOREIGN KEY (id_transaccion)   REFERENCES transacciones(id_transaccion)
);

-- 17. Mantenimiento de lotes
CREATE TABLE mantenimiento_lotes (
    id_mantenimiento INT PRIMARY KEY AUTO_INCREMENT,
    id_lote          INT NOT NULL,
    id_empleado      INT,
    fecha_inicio     DATE NOT NULL,
    fecha_fin        DATE,
    descripcion      TEXT,
    costo            DECIMAL(10,2),
    FOREIGN KEY (id_lote)     REFERENCES lotes(id_lote),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

-- =========================================================
-- FUNCIONES
-- =========================================================

DELIMITER $$

-- Función 1: Calcular la edad del difunto al momento del fallecimiento
CREATE FUNCTION fn_calcular_edad_difunto(
    p_fecha_nac  DATE,
    p_fecha_fall DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_fecha_nac, p_fecha_fall);
END$$

-- Función 2: Obtener el total pagado por un cliente (solo pagos confirmados)
CREATE FUNCTION fn_total_pagado_cliente(p_id_cliente INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT COALESCE(SUM(monto_pagado), 0)
    INTO   v_total
    FROM   transacciones
    WHERE  id_cliente  = p_id_cliente
      AND  estado_pago = 'Pagado';
    RETURN v_total;
END$$

DELIMITER ;

-- =========================================================
-- STORED PROCEDURES
-- =========================================================

DELIMITER $$

-- SP 1: Registrar un difunto (valida disponibilidad del lote)
CREATE PROCEDURE sp_registrar_difunto(
    IN p_nombre    VARCHAR(150),
    IN p_fecha_nac DATE,
    IN p_fecha_fall DATE,
    IN p_causa     VARCHAR(200),
    IN p_id_lote   INT,
    IN p_id_tipo   INT,
    IN p_id_cliente INT
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    SELECT estado INTO v_estado
    FROM   lotes
    WHERE  id_lote = p_id_lote;

    IF v_estado != 'Disponible' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El lote no está disponible para su uso.';
    ELSE
        INSERT INTO difuntos (
            nombre_completo, fecha_nacimiento, fecha_fallecimiento,
            causa_fallecimiento, id_lote, id_tipo_entierro, id_cliente_responsable
        ) VALUES (
            p_nombre, p_fecha_nac, p_fecha_fall,
            p_causa, p_id_lote, p_id_tipo, p_id_cliente
        );

        -- El trigger tr_actualizar_estado_lote se encargará del cambio de estado
    END IF;
END$$

-- SP 2: Registrar un pago / transacción
CREATE PROCEDURE sp_registrar_pago(
    IN p_id_cliente  INT,
    IN p_id_empleado INT,
    IN p_id_servicio INT,
    IN p_id_contrato INT,
    IN p_monto       DECIMAL(10,2),
    IN p_metodo      VARCHAR(20)
)
BEGIN
    INSERT INTO transacciones (
        id_cliente, id_empleado, id_servicio, id_contrato,
        monto_pagado, metodo_pago, estado_pago
    ) VALUES (
        p_id_cliente, p_id_empleado, p_id_servicio, p_id_contrato,
        p_monto, p_metodo, 'Pagado'
    );
END$$

DELIMITER ;

-- =========================================================
-- TRIGGERS
-- =========================================================

DELIMITER $$

-- Trigger 1: Al insertar un difunto, marcar el lote como Ocupado
CREATE TRIGGER tr_actualizar_estado_lote
AFTER INSERT ON difuntos
FOR EACH ROW
BEGIN
    IF NEW.id_lote IS NOT NULL THEN
        UPDATE lotes SET estado = 'Ocupado' WHERE id_lote = NEW.id_lote;
    END IF;
END$$

-- Trigger 2: Al registrar una transacción, insertar registro en tabla de hechos
CREATE TRIGGER tr_insertar_hecho_servicio
AFTER INSERT ON transacciones
FOR EACH ROW
BEGIN
    DECLARE v_id_difunto      INT DEFAULT NULL;
    DECLARE v_id_sucursal     INT DEFAULT NULL;
    DECLARE v_id_sector       INT DEFAULT NULL;
    DECLARE v_id_tipo_entierro INT DEFAULT NULL;

    IF NEW.id_contrato IS NOT NULL THEN
        SELECT co.id_difunto
        INTO   v_id_difunto
        FROM   contratos co
        WHERE  co.id_contrato = NEW.id_contrato;

        IF v_id_difunto IS NOT NULL THEN
            SELECT d.id_tipo_entierro, l.id_sector, l.id_sucursal
            INTO   v_id_tipo_entierro, v_id_sector, v_id_sucursal
            FROM   difuntos d
            JOIN   lotes    l ON d.id_lote = l.id_lote
            WHERE  d.id_difunto = v_id_difunto;
        END IF;
    END IF;

    INSERT INTO hechos_servicios (
        fecha_servicio, id_sucursal, id_sector, id_tipo_entierro,
        id_cliente, id_empleado, id_difunto,
        id_contrato, id_transaccion, monto_total
    ) VALUES (
        DATE(NEW.fecha_pago), v_id_sucursal, v_id_sector, v_id_tipo_entierro,
        NEW.id_cliente, NEW.id_empleado, v_id_difunto,
        NEW.id_contrato, NEW.id_transaccion, NEW.monto_pagado
    );
END$$

-- Trigger 3: Al iniciar mantenimiento de un lote, cambiar su estado
CREATE TRIGGER tr_inicio_mantenimiento
AFTER INSERT ON mantenimiento_lotes
FOR EACH ROW
BEGIN
    UPDATE lotes SET estado = 'Mantenimiento' WHERE id_lote = NEW.id_lote;
END$$

-- Trigger 4: Al registrar fecha_fin de mantenimiento, liberar el lote
CREATE TRIGGER tr_fin_mantenimiento
AFTER UPDATE ON mantenimiento_lotes
FOR EACH ROW
BEGIN
    IF NEW.fecha_fin IS NOT NULL AND OLD.fecha_fin IS NULL THEN
        UPDATE lotes SET estado = 'Disponible' WHERE id_lote = NEW.id_lote;
    END IF;
END$$

DELIMITER ;

-- =========================================================
-- VISTAS
-- =========================================================

-- Vista 1: Detalle completo de cada difunto
CREATE VIEW v_difuntos_detalle AS
SELECT
    d.id_difunto,
    d.nombre_completo,
    d.fecha_nacimiento,
    d.fecha_fallecimiento,
    fn_calcular_edad_difunto(d.fecha_nacimiento, d.fecha_fallecimiento) AS edad_al_fallecer,
    d.causa_fallecimiento,
    te.nombre_tipo          AS tipo_entierro,
    l.codigo_ubicacion      AS ubicacion_lote,
    l.estado                AS estado_lote,
    se.nombre_sector        AS sector,
    su.nombre               AS sucursal,
    c.nombre                AS cliente_responsable,
    c.telefono              AS telefono_responsable
FROM difuntos d
LEFT JOIN tipos_entierro te ON d.id_tipo_entierro          = te.id_tipo
LEFT JOIN lotes          l  ON d.id_lote                   = l.id_lote
LEFT JOIN sectores       se ON l.id_sector                 = se.id_sector
LEFT JOIN sucursales     su ON l.id_sucursal               = su.id_sucursal
LEFT JOIN clientes       c  ON d.id_cliente_responsable    = c.id_cliente;

-- Vista 2: Lotes disponibles con su ubicación completa
CREATE VIEW v_lotes_disponibles AS
SELECT
    l.id_lote,
    l.codigo_ubicacion,
    se.nombre_sector    AS sector,
    su.nombre           AS sucursal,
    su.direccion        AS direccion_sucursal
FROM lotes       l
JOIN sectores    se ON l.id_sector   = se.id_sector
JOIN sucursales  su ON l.id_sucursal = su.id_sucursal
WHERE l.estado = 'Disponible';

-- Vista 3: Historial de transacciones con información de cliente y servicio
CREATE VIEW v_historial_transacciones AS
SELECT
    t.id_transaccion,
    t.fecha_pago,
    c.nombre       AS cliente,
    c.dni_cedula,
    e.nombre       AS empleado,
    ps.concepto    AS servicio,
    t.monto_pagado,
    t.metodo_pago,
    t.estado_pago
FROM transacciones     t
LEFT JOIN clientes        c  ON t.id_cliente  = c.id_cliente
LEFT JOIN empleados       e  ON t.id_empleado = e.id_empleado
LEFT JOIN precios_servicios ps ON t.id_servicio = ps.id_servicio;

-- Vista 4: Detalle de empleados con cargo y sucursal
CREATE VIEW v_empleados_detalle AS
SELECT
    e.id_empleado,
    e.nombre,
    e.dni_cedula,
    ce.nombre_cargo  AS cargo,
    su.nombre        AS sucursal,
    e.fecha_ingreso,
    CASE WHEN e.activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS estado
FROM empleados       e
LEFT JOIN cargos_empleado ce ON e.id_cargo    = ce.id_cargo
LEFT JOIN sucursales      su ON e.id_sucursal = su.id_sucursal;

-- Vista 5: Ingresos totales por sucursal, año y mes
CREATE VIEW v_ingresos_por_sucursal AS
SELECT
    su.nombre                AS sucursal,
    YEAR(t.fecha_pago)       AS anio,
    MONTH(t.fecha_pago)      AS mes,
    COUNT(t.id_transaccion)  AS cantidad_transacciones,
    SUM(t.monto_pagado)      AS total_ingresos
FROM transacciones   t
JOIN hechos_servicios hs ON t.id_transaccion = hs.id_transaccion
JOIN sucursales       su ON hs.id_sucursal   = su.id_sucursal
WHERE t.estado_pago = 'Pagado'
GROUP BY su.nombre, YEAR(t.fecha_pago), MONTH(t.fecha_pago);

-- Vista 6: Contratos activos con información completa
CREATE VIEW v_contratos_activos AS
SELECT
    co.id_contrato,
    co.fecha_contrato,
    co.tipo_contrato,
    c.nombre           AS cliente,
    c.telefono,
    d.nombre_completo  AS difunto,
    l.codigo_ubicacion AS lote,
    e.nombre           AS empleado_responsable,
    co.estado
FROM contratos    co
JOIN clientes     c  ON co.id_cliente  = c.id_cliente
LEFT JOIN difuntos   d  ON co.id_difunto  = d.id_difunto
LEFT JOIN lotes      l  ON co.id_lote     = l.id_lote
LEFT JOIN empleados  e  ON co.id_empleado = e.id_empleado
WHERE co.estado = 'Activo';
