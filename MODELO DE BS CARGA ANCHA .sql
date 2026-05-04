-- =====================================================
-- BASE DE DATOS: SeguimientoCargaAnchaDB
-- AUTOR: [Tu Nombre]
-- FECHA: 2026
-- =====================================================

CREATE DATABASE SeguimientoCargaAnchaDB;
GO

USE SeguimientoCargaAnchaDB;
GO

-- CREACIÓN DE TABLAS (10 tablas)
CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY IDENTITY(1,1),
    razon_social NVARCHAR(150) NOT NULL,
    ruc NVARCHAR(20) UNIQUE NOT NULL,
    direccion NVARCHAR(200),
    telefono NVARCHAR(20)
);
GO

CREATE TABLE vehiculo (
    id_vehiculo INT PRIMARY KEY IDENTITY(1,1),
    id_empresa INT NOT NULL,
    placa NVARCHAR(20) UNIQUE NOT NULL,
    marca NVARCHAR(50),
    modelo NVARCHAR(50),
    anio INT,
    capacidad_toneladas DECIMAL(10,2),
    CONSTRAINT FK_vehiculo_empresa FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa)
);
GO

CREATE TABLE conductor (
    id_conductor INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(50) NOT NULL,
    apellido NVARCHAR(50) NOT NULL,
    licencia NVARCHAR(20) UNIQUE NOT NULL,
    telefono NVARCHAR(20)
);
GO

CREATE TABLE ruta (
    id_ruta INT PRIMARY KEY IDENTITY(1,1),
    origen NVARCHAR(100) NOT NULL,
    destino NVARCHAR(100) NOT NULL,
    distancia_km DECIMAL(10,2)
);
GO

CREATE TABLE monitoreo (
    id_monitoreo INT PRIMARY KEY IDENTITY(1,1),
    id_vehiculo INT NOT NULL,
    id_conductor INT NOT NULL,
    id_ruta INT NOT NULL,
    fecha_salida DATETIME NOT NULL,
    fecha_llegada DATETIME NULL,
    estado NVARCHAR(30) DEFAULT 'EN CURSO',
    CONSTRAINT FK_monitoreo_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo),
    CONSTRAINT FK_monitoreo_conductor FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor),
    CONSTRAINT FK_monitoreo_ruta FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta)
);
GO

CREATE TABLE consumo_combustible (
    id_consumo INT PRIMARY KEY IDENTITY(1,1),
    id_monitoreo INT NOT NULL,
    cantidad_litros DECIMAL(10,2) NOT NULL,
    costo_total DECIMAL(10,2) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_consumo_monitoreo FOREIGN KEY (id_monitoreo) REFERENCES monitoreo(id_monitoreo)
);
GO

CREATE TABLE incidencia (
    id_incidencia INT PRIMARY KEY IDENTITY(1,1),
    id_monitoreo INT NOT NULL,
    tipo NVARCHAR(50) NOT NULL,
    descripcion NVARCHAR(200),
    fecha DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_incidencia_monitoreo FOREIGN KEY (id_monitoreo) REFERENCES monitoreo(id_monitoreo)
);
GO

CREATE TABLE mantenimiento (
    id_mantenimiento INT PRIMARY KEY IDENTITY(1,1),
    id_vehiculo INT NOT NULL,
    descripcion NVARCHAR(200),
    fecha DATE DEFAULT GETDATE(),
    costo DECIMAL(10,2),
    CONSTRAINT FK_mantenimiento_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo)
);
GO

CREATE TABLE proveedor (
    id_proveedor INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    ruc NVARCHAR(20) UNIQUE,
    telefono NVARCHAR(20),
    direccion NVARCHAR(200)
);
GO

CREATE TABLE repuesto (
    id_repuesto INT PRIMARY KEY IDENTITY(1,1),
    id_proveedor INT NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    precio DECIMAL(10,2),
    stock INT DEFAULT 0,
    CONSTRAINT FK_repuesto_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
);
GO

-- DATOS DE PRUEBA
INSERT INTO empresa VALUES
('Transportes Ejemplo S.A.C.', '20123456789', 'Av. Principal 123', '555-1000'),
('Logística Rápida S.R.L.', '20987654321', 'Calle Secundaria 456', '555-2000');

INSERT INTO conductor VALUES
('Juan', 'Pérez', 'L123456', '955123456'),
('María', 'Gómez', 'L789012', '955789012'),
('Carlos', 'López', 'L345678', '955345678');

INSERT INTO ruta VALUES
('Lima', 'Callao', 15.5),
('Lima', 'Huacho', 148.0),
('Lima', 'Ica', 304.0);

INSERT INTO vehiculo VALUES
(1, 'ABC-123', 'Volvo', 'FH16', 2020, 25.5),
(1, 'XYZ-789', 'Scania', 'R500', 2021, 30.0),
(2, 'DEF-456', 'Mercedes', 'Actros', 2019, 28.0);

INSERT INTO monitoreo VALUES
(1, 1, 1, '2026-05-01 08:00:00', '2026-05-01 09:30:00', 'COMPLETADO'),
(2, 2, 2, '2026-05-02 07:00:00', '2026-05-02 10:00:00', 'COMPLETADO'),
(3, 3, 3, '2026-05-03 06:00:00', NULL, 'EN CURSO');

INSERT INTO consumo_combustible VALUES
(1, 45.5, 227.50, GETDATE()),
(2, 120.0, 600.00, GETDATE()),
(3, 80.0, 400.00, GETDATE());

INSERT INTO incidencia VALUES
(1, 'Retraso', 'Tráfico pesado', GETDATE()),
(2, 'Mecánica', 'Revisión de frenos', GETDATE());

INSERT INTO mantenimiento VALUES
(1, 'Cambio de aceite', '2026-04-15', 350.00),
(2, 'Alineamiento', '2026-04-20', 180.00);

INSERT INTO proveedor VALUES
('Repuestos El Tigre', '20444444444', '555-4000', 'Av. Argentina 500'),
('Lubricantes San Pedro', '20555555555', '555-5000', 'Calle Los Olivos 123');

INSERT INTO repuesto VALUES
(1, 'Filtro de Aceite', 45.50, 100),
(1, 'Pastillas de Freno', 120.00, 50),
(2, 'Aceite 15W40', 85.00, 200);