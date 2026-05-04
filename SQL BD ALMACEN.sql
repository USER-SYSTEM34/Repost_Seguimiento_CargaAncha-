-- 1. CREACIÓN DE LA BASE DE DATOS
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'WMS_RepuestosPesados')
BEGIN
    DROP DATABASE WMS_RepuestosPesados; -- Reiniciamos para aplicar cambios
END
CREATE DATABASE WMS_RepuestosPesados;
GO

USE WMS_RepuestosPesados;
GO

-- 2. CREACIÓN DE TABLAS

CREATE TABLE Zonas (
    id_zona INT PRIMARY KEY,
    codigo_zona VARCHAR(10) NOT NULL,
    descripcion VARCHAR(100)
);

CREATE TABLE Productos (
    id_producto INT PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100),
    ancho_mm INT, -- Crucial para repuestos grandes
    largo_mm INT,
    peso_kg DECIMAL(10,2) -- Crucial para estanterías de alto tonelaje
);

CREATE TABLE Ubicaciones (
    id_ubicacion INT PRIMARY KEY,
    id_zona INT,
    pasillo INT,
    nivel INT,
    ancho_disponible_mm INT,
    CONSTRAINT FK_Ubicacion_Zona FOREIGN KEY (id_zona) REFERENCES Zonas(id_zona)
);

CREATE TABLE Inventario (
    id_inventario INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    id_ubicacion INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Inventario_Producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    CONSTRAINT FK_Inventario_Ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id_ubicacion)
);
GO

-- 3. INSERCIÓN DE DATOS (ESPECIALIZADOS EN TONELAJE)

INSERT INTO Zonas (id_zona, codigo_zona, descripcion) VALUES
(1, 'Z-MOTOR', 'Componentes de Motor (Pesados)'),
(2, 'Z-TRANS', 'Transmisiones y Diferenciales'),
(3, 'Z-NEUM', 'Neumáticos de Minería y Carga'),
(4, 'Z-FILT', 'Filtros y Consumibles (Picking Rápido)'),
(5, 'Z-ELEC', 'Sistemas Eléctricos y Sensores'),
(6, 'Z-SUSP', 'Muelles y Amortiguadores de Tonelaje'),
(7, 'Z-LUBR', 'Aceites y Lubricantes (Barriles)'),
(8, 'Z-FREN', 'Sistemas de Frenos de Aire'),
(9, 'Z-EXT', 'Chasis y Carrocería (Exteriores)'),
(10, 'Z-URG', 'Repuestos Críticos para Flota Detenida');

INSERT INTO Productos (id_producto, sku, nombre, ancho_mm, largo_mm, peso_kg) VALUES
(1, 'MOT-CAT-C15', 'Bloque de Motor Caterpillar C15', 1200, 1800, 1450.00),
(2, 'TRA-EAT-18', 'Transmisión Eaton Fuller 18 Vel.', 600, 1100, 320.00),
(3, 'NEU-315-80', 'Neumático 315/80 R22.5 Tracción', 315, 1050, 65.00),
(4, 'FIL-OIL-HD', 'Filtro de Aceite Heavy Duty', 150, 150, 1.50),
(5, 'TUR-HOL-HX', 'Turbocargador Holset HX55', 300, 350, 18.00),
(6, 'MUE-TRA-12', 'Paquete de Muelles Traseros (12 Hojas)', 100, 1200, 85.00),
(7, 'CIG-VOL-D13', 'Cigüeñal para Motor Volvo D13', 250, 1100, 115.00),
(8, 'INY-CUM-ISX', 'Inyector Common Rail Cummins ISX', 50, 200, 0.80),
(9, 'TAM-FRE-22', 'Tambor de Freno Posterior 22.5"', 450, 450, 45.00),
(10, 'BAR-HYD-55', 'Barril Aceite Hidráulico 55 Gal.', 600, 600, 200.00);

INSERT INTO Ubicaciones (id_ubicacion, id_zona, pasillo, nivel, ancho_disponible_mm) VALUES
(101, 1, 1, 1, 2500), -- Nivel suelo para motores
(102, 2, 2, 1, 2000), -- Nivel suelo para transmisiones
(103, 3, 3, 1, 5000), -- Estantería ancha para neumáticos
(104, 4, 4, 1, 1500), -- Picking de filtros
(105, 4, 4, 2, 1500), -- Picking filtros nivel 2
(106, 5, 5, 1, 1000), -- Sensores
(107, 6, 6, 1, 2000), -- Muelles
(108, 7, 7, 1, 1200), -- Barriles aceites
(109, 8, 8, 1, 1500), -- Frenos
(110, 10, 1, 1, 2000); -- Zona Urgencias

INSERT INTO Inventario (id_producto, id_ubicacion, cantidad) VALUES
(1, 101, 2),  -- 2 Motores Cat
(2, 102, 5),  -- 5 Transmisiones
(3, 103, 24), -- 24 Neumáticos
(4, 104, 100),-- 100 Filtros
(5, 101, 10), -- 10 Turbos cerca de motores
(6, 107, 15), -- 15 Paquetes de muelles
(7, 101, 4),  -- 4 Cigüeñales
(8, 106, 30), -- 30 Inyectores
(9, 109, 20), -- 20 Tambores de freno
(10, 108, 10);-- 10 Barriles de aceite
GO

-- 4. CONSULTA DE AUDITORÍA DE ALMACÉN
SELECT 
    P.sku AS [Código SKU],
    P.nombre AS [Repuesto de Tonelaje],
    Z.descripcion AS [Área Almacén],
    U.pasillo AS [Pasillo],
    U.nivel AS [Nivel],
    I.cantidad AS [Stock Actual],
    P.peso_kg AS [Peso Unit. Kg],
    (I.cantidad * P.peso_kg) AS [Peso Total en Estante (Kg)]
FROM Inventario I
JOIN Productos P ON I.id_producto = P.id_producto
JOIN Ubicaciones U ON I.id_ubicacion = U.id_ubicacion
JOIN Zonas Z ON U.id_zona = Z.id_zona;