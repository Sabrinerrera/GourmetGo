CREATE DATABASE GourmetGo; --crear base de datos
GO

USE GourmetGo;
GO

CREATE TABLE Comercio (
  id INT PRIMARY KEY,
  password NVARCHAR(8) NOT NULL, -- luego hacer un trigger que no permita un password valido
  telefono TEXT NOT NULL, -- sin lim (puede haber mas de uno)
  fecha_registro DATE NOT NULL,
  correo NVARCHAR(50) NOT NULL,
  nombre NVARCHAR(50) NOT NULL,
  ubicacion_fisica TEXT NOT NULL,
  hora_apertura INT CHECK (
    hora_apertura >= 0 AND
    hora_apertura <= 23
  ),
  hora_cierre INT CHECK (
    hora_cierre >= 0 AND
    hora_cierre <= 23
  ),
  estaActivo BIT 
);
GO

CREATE TABLE Cocina (id INT PRIMARY KEY, nombre NVARCHAR(50) NOT NULL, descripcion NVARCHAR(255) NOT NULL);
GO

CREATE TABLE ComercioCocina (
  idComercio INT,
  idCocina INT,
  FOREIGN KEY (idComercio) REFERENCES Comercio (id),
  FOREIGN KEY (idCocina) REFERENCES Cocina (id),
  PRIMARY KEY (idComercio, idCocina)
);

CREATE TABLE Menu (
  id INT PRIMARY KEY,
  nombre NVARCHAR(50) NOT NULL,
  descripcion NVARCHAR(255) NOT NULL,
  idComercio INT,
  FOREIGN KEY (idComercio) REFERENCES Comercio (id)
);

CREATE TABLE Seccion (
  id INT PRIMARY KEY,
  nombre NVARCHAR(50) NOT NULL,
  descripcion NVARCHAR(255) NOT NULL,
  idMenu INT,
  FOREIGN KEY (idMenu) REFERENCES Menu (id)
);

CREATE TABLE Plato (
  id INT PRIMARY KEY,
  nombre NVARCHAR(50) NOT NULL,
  orden INT CHECK (orden > 0) NOT NULL,
  cantidadDisponible INT CHECK (cantidadDisponible >= 0) NOT NULL,
  precio REAL CHECK (precio > 0) NOT NULL,
  descripcion NVARCHAR(255) NOT NULL,
  idSeccion INT,
  FOREIGN KEY (idSeccion) REFERENCES Seccion (id)
);

CREATE TABLE Opcion (
  id INT PRIMARY KEY, 
  nombre NVARCHAR(50) NOT NULL, 
  descripcion NVARCHAR(255) NOT NULL
 );

CREATE TABLE PlatoOpcion (
  idPlato INT,
  idOpcion INT,
  FOREIGN KEY (idPlato) REFERENCES Plato (id),
  FOREIGN KEY (idOpcion) REFERENCES Opcion (id),
  PRIMARY KEY (idPlato, idOpcion)
);

CREATE TABLE OpcionValor (
  id INT PRIMARY KEY,
  idOpcion INT,
  nombre NVARCHAR(50) NOT NULL,
  precio_extra REAL CHECK (precio_extra >= 0) NOT NULL, 
  FOREIGN KEY (idOpcion) REFERENCES Opcion (id)
);

CREATE TABLE PlatoOpcionValor (
  idPlato INT,
  idOpcionValor INT,
  idOpcion INT,
  FOREIGN KEY (idPlato) REFERENCES Plato (id),
  FOREIGN KEY (idOpcionValor) REFERENCES OpcionValor (id),
  FOREIGN KEY (idOpcion) REFERENCES Opcion (id),
  PRIMARY KEY (idPlato, idOpcionValor, idOpcion)
);

CREATE TABLE Cliente (
  id INT PRIMARY KEY,
  password NVARCHAR(8) NOT NULL,
  telefono TEXT NOT NULL,
  fecha_registro DATE NOT NULL,
  correo NVARCHAR(50) NOT NULL,
  nombre NVARCHAR(50) NOT NULL,
  apellido NVARCHAR(50) NOT NULL,
  fecha_nac DATE NOT NULL,
  nro_documento NVARCHAR(50) NOT NULL
);

CREATE TABLE ClienteConClienteReferido (
  idCliente INT,
  idClienteReferido INT,
  fecha_referido DATE,
  FOREIGN KEY (idCliente) REFERENCES Cliente (id),
  FOREIGN KEY (idClienteReferido) REFERENCES Cliente (id),
  PRIMARY KEY (idCliente, idClienteReferido, fecha_referido)
);

CREATE TABLE Direccion (
  id INT PRIMARY KEY,
  codigo_postal INT NOT NULL,
  calle NVARCHAR(50) NOT NULL,
  municipio NVARCHAR(50) NOT NULL,
  alias NVARCHAR(50) NOT NULL,
  nombre_edif NVARCHAR(50) NOT NULL
);

CREATE TABLE DireccionCliente (
  idCliente INT,
  idDireccion INT,
  FOREIGN KEY (idCliente) REFERENCES Cliente (id),
  FOREIGN KEY (idDireccion) REFERENCES Direccion (id),
  PRIMARY KEY (idCliente, idDireccion)
);

CREATE TABLE Repartidor (
  id INT PRIMARY KEY,
  password NVARCHAR(8) NOT NULL,
  telefono TEXT NOT NULL, 
  fecha_registro DATE NOT NULL,
  correo NVARCHAR(50) NOT NULL,
  nombre NVARCHAR(50) NOT NULL,
  apellido NVARCHAR(50) NOT NULL,
  fecha_nac DATE NOT NULL,
  nro_documento NVARCHAR(50) NOT NULL,
  detalle_vehiculo NVARCHAR(50) NOT NULL,
  estado NVARCHAR(10) CHECK (estado IN ('Activo', 'Inactivo'))
);

CREATE TABLE ClienteRepartidor (
  idCliente INT,
  idRepartidor INT,
  fecha DATETIME,
  FOREIGN KEY (idCliente) REFERENCES Cliente (id),
  FOREIGN KEY (idRepartidor) REFERENCES Repartidor (id),
  PRIMARY KEY (idCliente, idRepartidor, fecha),
  puntaje INT CHECK (
    puntaje >= 1 AND
    puntaje <= 5
  ) NOT NULL,
  comentario NVARCHAR(255) NOT NULL
);

CREATE TABLE Pedido (
  id INT PRIMARY KEY,
  cantidad_items INT CHECK (cantidad_items > 0),
  costo_envio REAL CHECK (costo_envio >= 0), 
  nota NVARCHAR(255) NOT NULL,
  tiempo_entrega INT NOT NULL,
  total REAL CHECK (total > 0)
);

CREATE TABLE Factura (
  numero INT PRIMARY KEY,
  fecha_emision DATETIME NOT NULL,
  sub_total REAL CHECK (sub_total > 0),
  porcentajeIva REAL CHECK (porcentajeIva >= 0), 
  montoIva REAL CHECK (montoIva >= 0),
  monto_total REAL CHECK (monto_Total > 0),
  idPedido INT,
  FOREIGN KEY (idPedido) REFERENCES Pedido (id)
);

CREATE TABLE ClientePedido (
  idCliente INT,
  idPedido INT,
  fecha DATETIME NOT NULL,
  FOREIGN KEY (idCliente) REFERENCES Cliente (id),
  FOREIGN KEY (idPedido) REFERENCES Pedido (id),
  PRIMARY KEY (idCliente, idPedido, fecha)
);

CREATE TABLE RepartidorPedido (
  idRepartidor INT,
  idPedido INT,
  tiempo_entrega INT NOT NULL,
  FOREIGN KEY (idRepartidor) REFERENCES Repartidor (id),
  FOREIGN KEY (idPedido) REFERENCES Pedido (id),
  PRIMARY KEY (idRepartidor, idPedido)
);

CREATE TABLE PedidoDetalle (
  id INT PRIMARY KEY,
  cantidad INT CHECK (cantidad > 0),
  nota NVARCHAR(255) NOT NULL,
  total REAL CHECK (total > 0),
  idPedido INT,
  idPlato INT,
  FOREIGN KEY (idPedido) REFERENCES Pedido (id),
  FOREIGN KEY (idPlato) REFERENCES Plato (id)
);

CREATE TABLE PedidoDetalleOpcionValor (
  idPedidoDetalle INT,
  idOpcionValor INT,
  idOpcion INT,
  FOREIGN KEY (idPedidoDetalle) REFERENCES PedidoDetalle (id),
  FOREIGN KEY (idOpcionValor) REFERENCES OpcionValor (id),
  FOREIGN KEY (idOpcion) REFERENCES Opcion (id),
  PRIMARY KEY (idPedidoDetalle, idOpcionValor, idOpcion)
);

CREATE TABLE EstadoPedido (
  id INT PRIMARY KEY,
  nombre NVARCHAR(50) NOT NULL,
  tiempo_promedio INT NOT NULL,
  descripcion NVARCHAR(255) NOT NULL
);

CREATE TABLE PedidoEstadoPedido (
  idPedido INT,
  idEstadoPedido INT,
  fecha_inicio DATETIME NOT NULL,
  FOREIGN KEY (idPedido) REFERENCES Pedido (id),
  FOREIGN KEY (idEstadoPedido) REFERENCES EstadoPedido (id),
  PRIMARY KEY (idPedido, idEstadoPedido, fecha_inicio)
);
GO

-- Factura (a):
CREATE OR ALTER FUNCTION GetCostoEnvio (@idPedido INT)
RETURNS REAL
AS
BEGIN
    DECLARE @costoEnvio REAL;
    -- Obtener el costo de envío del pedido
    SELECT @costoEnvio = costo_envio
    FROM Pedido
    WHERE id = @idPedido;

    RETURN @costoEnvio;
END;
GO

CREATE OR ALTER FUNCTION GetSubtotal (@idPedido INT)
RETURNS REAL
AS
BEGIN
    DECLARE @subTotal REAL;
    -- Calcular el subtotal del pedido sumando los precios de los detalles del pedido
    SELECT @subTotal = SUM(PD.total)
    FROM PedidoDetalle AS PD
    WHERE PD.idPedido = @idPedido;

    RETURN @subTotal;
END;
GO

CREATE OR ALTER FUNCTION GetMontoIva (@subTotal REAL, @porcentajeIva REAL)
RETURNS REAL
AS
BEGIN
    DECLARE @montoIva REAL;
    -- Calcular el monto del IVA
    SET @montoIva = @subTotal * (@porcentajeIva / 100);
    RETURN @montoIva;
END;
GO

-- Ya existe una función para obtener subTotal, montoIva y costoEnvio (se usa como parametros en la siguiente función)
CREATE OR ALTER FUNCTION GetMontoTotal (@subTotal REAL, @montoIva REAL, @costoEnvio REAL)
RETURNS REAL
AS
BEGIN
    DECLARE @montoTotal REAL;
    -- Calcular el monto total sumando el subtotal, el monto del IVA y el costo de envío
    SET @montoTotal = @subTotal + @montoIva + @costoEnvio;
    RETURN @montoTotal;
END;
GO

-- Repartidor (b):
CREATE OR ALTER FUNCTION RepartidorDisponible (@idRepartidor INT, @idPedido INT)
RETURNS TABLE -- retornar la info del repartidor disponible (instrucciones Telegram)
AS
RETURN
(
    SELECT
        R.id,
        R.password,
        R.telefono,
        R.fecha_registro,
        R.correo,
        R.nombre,
        R.apellido,
        R.fecha_nac,
        R.nro_documento,
        R.detalle_vehiculo,
        R.estado
    FROM Repartidor AS R
    WHERE R.id = @idRepartidor
      AND R.estado = 'Activo'
      AND NOT EXISTS (
          SELECT 1
          FROM RepartidorPedido AS RP_Check
          JOIN PedidoEstadoPedido AS PEP_Check ON RP_Check.idPedido = PEP_Check.idPedido
          JOIN EstadoPedido AS EP_Check ON PEP_Check.idEstadoPedido = EP_Check.id
          WHERE RP_Check.idRepartidor = R.id
            AND EP_Check.nombre NOT IN ('Entregado', 'Cancelado')
      )
);
GO

CREATE OR ALTER TRIGGER t_generarFactura
ON Pedido 
AFTER INSERT
AS 
BEGIN
    INSERT INTO Factura(
        numero, 
        fecha_emision, 
        sub_total, 
        porcentajeIva, 
        montoIva, 
        monto_total, 
        idPedido
    )
    SELECT
        P.id AS numero,
        GETDATE() AS fecha_emision,
        (P.total - P.costo_envio) AS sub_total, -- el total incluye el envio
        16.0 AS porcentajeIva, -- IVA = 16% (confirmado)
        ((P.total - P.costo_envio)*0.16) AS montoIva, 
        (((P.total - P.costo_envio)*0.16) + P.total) AS montoTotal, 
        P.id AS idPedido
    FROM
        INSERTED AS P;
END;
GO

CREATE OR ALTER TRIGGER t_pedidoEntregado
ON PedidoEstadoPedido
AFTER INSERT
AS 
BEGIN
    DECLARE @EstadoEntregado_ID INT;
    -- Obtener el ID (necesito hacer una consulta)
    SELECT @EstadoEntregado_ID = id FROM EstadoPedido WHERE nombre = 'Entregado';

    INSERT INTO ClienteRepartidor(
        idCliente, 
        idRepartidor, 
        fecha,
        puntaje,
        comentario
    )
    SELECT
        CP.idCliente, 
        RP.idRepartidor, 
        GETDATE(), 
        5, 
        N'Valoración por defecto por entrega completada.'
    FROM
        INSERTED AS PEP
        JOIN ClientePedido AS CP ON PEP.idPedido = CP.idPedido
        JOIN RepartidorPedido AS RP ON PEP.idPedido = RP.idPedido
        WHERE PEP.idEstadoPedido = @EstadoEntregado_ID
        -- Subconsulta para verificar si hay valoracion o no:
            AND NOT EXISTS (
                SELECT 1
                FROM ClienteRepartidor AS CR
                WHERE CR.idCliente = CP.idCliente 
                AND CR.idRepartidor = RP.idRepartidor 
            );
END;
GO

CREATE OR ALTER TRIGGER t_devolucionPedido
ON PedidoDetalle
AFTER DELETE
AS 
BEGIN
    UPDATE P
    SET P.cantidadDisponible = P.cantidadDisponible + PD.cantidad -- restaurando
    FROM Plato AS P
    JOIN DELETED AS PD ON PD.idPlato = P.id;
END;
GO

CREATE OR ALTER TRIGGER t_registrarOpecionesPedido
ON PedidoDetalle
AFTER INSERT
AS 
BEGIN
    INSERT INTO PedidoDetalleOpcionValor(
        idPedidoDetalle, 
        idOpcionValor, 
        idOpcion
    )
    SELECT
        PD.id AS idPedidoDetalle,
        opAzar.idOpcionValor AS idOpcionValor,
        opAzar.idOpcion AS idOpcion
    FROM
        INSERTED AS PD
        CROSS APPLY -- para que funcione con PD ⚠ VERIFICAR
        (
            SELECT TOP 1 POV.idOpcionValor, POV.idOpcion
            FROM PlatoOpcionValor AS POV
            WHERE POV.idPlato = PD.idPlato
            ORDER BY NEWID()   
        ) AS opAzar;
END;
GO

CREATE OR ALTER TRIGGER t_verificarPlatoSuficiente
ON PedidoDetalle
AFTER INSERT
AS 
BEGIN
    DECLARE @idPlato INT;
    DECLARE @cantidadSolicitada INT;
    DECLARE @cantidadDisponible INT;

    SELECT @idPlato = PD.idPlato, @cantidadSolicitada = PD.cantidad
    FROM INSERTED AS PD

    SELECT @cantidadDisponible = P.cantidadDisponible
    FROM Plato P
    WHERE P.id = @idPlato;

    IF @cantidadDisponible = 0
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('El producto no está disponible por los momentos.', 16, 1);
        RETURN;
    END

    IF @cantidadSolicitada > @cantidadDisponible
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('No hay unidades suficientes del producto para esta compra.', 16, 1);
        RETURN;
    END

    UPDATE Plato
    SET cantidadDisponible = cantidadDisponible - @cantidadSolicitada
    WHERE id = @idPlato;
END;
GO

INSERT INTO EstadoPedido (id, nombre, tiempo_promedio, descripcion) VALUES
(1, 'Pendiente', 5, 'Pedido registrado, esperando confirmaci�n.'),
(2, 'Confirmado', 10, 'Pedido confirmado por el comercio.'),
(3, 'En Preparaci�n', 20, 'El pedido est� siendo preparado.'),
(4, 'Listo para Entrega', 2, 'El pedido est� listo para ser entregado.'),
(5, 'En Camino', 30, 'El repartidor est� en camino.'),
(6, 'Entregado', 0, 'El pedido fue entregado al cliente.'),
(7, 'Cancelado', 0, 'El pedido fue cancelado.'),
(8, 'Retrasado', 15, 'El pedido tiene un retraso inesperado.'),
(9, 'Devoluci�n en Proceso', 5, 'El pedido est� en proceso de devoluci�n.'),
(10, 'Reembolsado', 0, 'El monto del pedido fue reembolsado.'),
(11, 'Rechazado por Comercio', 0, 'El comercio rechaz� el pedido por falta de disponibilidad.'),
(12, 'Esperando Repartidor', 10, 'Pedido listo pero sin repartidor asignado a�n.'),
(13, 'Reintento de Entrega', 20, 'Se est� realizando un segundo intento de entrega.'),
(14, 'Programado', 60, 'Pedido programado para entrega futura.'),
(15, 'Error en Pago', 0, 'El pago no se proces� correctamente, pedido en revisi�n.');

INSERT INTO Cocina (id, nombre, descripcion) VALUES
(1, 'China', 'Especialidades de comida china y oriental.'),
(2, 'Mexicana', 'Tacos, enchiladas y gastronom�a mexicana tradicional.'),
(3, 'Italiana', 'Pizzas, pastas y cocina mediterr�nea italiana.'),
(4, 'Japonesa', 'Sushi, ramen y platos t�picos de Jap�n.'),
(5, 'Hind�', 'Currys, especias y cocina de la India.'),
(6, '�rabe', 'Comida del Medio Oriente: shawarma, falafel, kebabs.'),
(7, 'Parrilla', 'Carnes a la parrilla, asados y BBQ.'),
(8, 'Venezolana', 'Platos t�picos venezolanos: arepas, pabell�n, cachapas.'),
(9, 'Mediterr�nea', 'Gastronom�a del Mediterr�neo: tapas, ensaladas, mariscos.'),
(10, 'Francesa', 'Alta cocina francesa, quiches, crepes y reposter�a.'),
(11, 'Espa�ola', 'Paellas, tortillas y cocina tradicional de Espa�a.'),
(12, 'Peruana', 'Ceviche, causa lime�a y gastronom�a peruana.'),
(13, 'Brasile�a', 'Churrasco, feijoada y platos t�picos de Brasil.'),
(14, 'Argentina', 'Cortes de carne, empanadas y parrilladas argentinas.'),
(15, 'Coreana', 'Bibimbap, bulgogi y cocina coreana.'),
(16, 'Tailandesa', 'Curry tailand�s, pad thai y sabores picantes.'),
(17, 'Vietnamita', 'Pho, rollitos primavera y cocina de Vietnam.'),
(18, 'Colombiana', 'Bandeja paisa, arepas y gastronom�a colombiana.'),
(19, 'Sin Gluten', 'Platos aptos para cel�acos.'),
(20, 'Salvadore�a', 'Pupusas, tamales y platos t�picos de El Salvador.'),
(21, 'Griega', 'Ensaladas, gyros y gastronom�a griega.'),
(22, 'Turca', 'D�ner kebab, baklava y cocina turca.'),
(23, 'Alemana', 'Salchichas, schnitzel y cocina alemana.'),
(24, 'Internacional', 'Fusi�n de platos de diferentes pa�ses.'),
(25, 'Tradicional', 'Comida casera y tradicional de la regi�n.'),
(26, 'Gourmet', 'Alta cocina, platos elaborados con t�cnicas sofisticadas.'),
(27, 'Experimental', 'Cocina creativa con t�cnicas innovadoras y sabores �nicos.'),
(28, 'Fusi�n', 'Combinaci�n de distintas tradiciones culinarias.'),
(29, 'Org�nica', 'Platos elaborados con ingredientes 100% org�nicos y sostenibles.'),
(30, 'Casera', 'Recetas tradicionales preparadas como en casa.'),
(31, 'Tex-Mex', 'Fusi�n de sabores mexicanos con cocina del sur de Estados Unidos.'),
(32, 'Street Food', 'Comida callejera internacional, pr�ctica y variada.'),
(33, 'Healthy-Fit', 'Platos saludables, bajos en calor�as y balanceados para dieta fitness.'),
(34, 'Comfort Food', 'Comidas reconfortantes y abundantes, t�picas del hogar.'),
(35, 'Mar y Tierra', 'Combinaci�n de mariscos y carnes a la parrilla.');

INSERT INTO Cliente (id, password, telefono, fecha_registro, correo, nombre, apellido, fecha_nac, nro_documento) VALUES
(1, 'Clie0001', '04121234567', '2023-01-15', 'ana.gomez@email.com', 'Ana', 'Gomez', '1985-03-20', 'V-12345678'),
(2, 'Clie0002', '04147654321', '2023-01-20', 'luis.perez@email.com', 'Luis', 'Perez', '1990-07-10', 'E-23456789'),
(3, 'Clie0003', '04269876543', '2023-01-25', 'maria.lopez@email.com', 'Maria', 'Lopez', '1978-11-05', 'V-13456789'),
(4, 'Clie0004', '04161112233', '2023-02-01', 'jose.diaz@email.com', 'Jose', 'Diaz', '1995-01-25', 'V-14567890'),
(5, 'Clie0005', '04125556677', '2023-02-05', 'carla.rojas@email.com', 'Carla', 'Rojas', '1982-09-12', 'E-15678901'),
(6, 'Clie0006', '04148889900', '2023-02-10', 'pedro.soto@email.com', 'Pedro', 'Soto', '1998-04-30', 'V-16789012'),
(7, 'Clie0007', '04263334455', '2023-02-15', 'sofia.castro@email.com', 'Sofia', 'Castro', '1975-06-18', 'V-17890123'),
(8, 'Clie0008', '04167778899', '2023-02-20', 'javier.fernandez@email.com', 'Javier', 'Fernandez', '1992-02-08', 'E-18901234'),
(9, 'Clie0009', '04122223344', '2023-02-25', 'valentina.morales@email.com', 'Valentina', 'Morales', '1988-10-01', 'V-19012345'),
(10, 'Clie0010', '04140001122', '2023-03-01', 'diego.gonzalez@email.com', 'Diego', 'Gonzalez', '1996-12-03', 'V-20123456'),
(11, 'Clie0011', '04265550011', '2023-03-05', 'alejandra.hernandez@email.com', 'Alejandra', 'Hernandez', '1980-08-22', 'E-21234567'),
(12, 'Clie0012', '04169990000', '2023-03-10', 'carlos.jimenez@email.com', 'Carlos', 'Jimenez', '1993-05-17', 'V-22345678'),
(13, 'Clie0013', '04123331122', '2023-03-15', 'andrea.navarro@email.com', 'Andrea', 'Navarro', '1987-01-09', 'V-23456789'),
(14, 'Clie0014', '04146667788', '2023-03-20', 'gabriel.ramirez@email.com', 'Gabriel', 'Ramirez', '1997-06-28', 'E-24567890'),
(15, 'Clie0015', '04260009988', '2023-03-25', 'victoria.vargas@email.com', 'Victoria', 'Vargas', '1983-03-02', 'V-25678901'),
(16, 'Clie0016', '04164445566', '2023-04-01', 'rafael.sanchez@email.com', 'Rafael', 'Sanchez', '1999-09-14', 'V-26789012'),
(17, 'Clie0017', '04128887766', '2023-04-05', 'paula.flores@email.com', 'Paula', 'Flores', '1979-11-29', 'E-27890123'),
(18, 'Clie0018', '04142221100', '2023-04-10', 'miguel.guerrero@email.com', 'Miguel', 'Guerrero', '1994-08-07', 'V-28901234'),
(19, 'Clie0019', '04266665544', '2023-04-15', 'camila.silva@email.com', 'Camila', 'Silva', '1986-04-20', 'V-29012345'),
(20, 'Clie0020', '04160000000', '2023-04-20', 'daniel.cruz@email.com', 'Daniel', 'Cruz', '1991-01-11', 'E-30123456'),
(21, 'Clie0021', '04121111111', '2023-04-25', 'emilia.delgado@email.com', 'Emilia', 'Delgado', '1989-07-27', 'V-31234567'),
(22, 'Clie0022', '04143333333', '2023-05-01', 'arturo.gomez@email.com', 'Arturo', 'Gomez', '1993-10-19', 'V-32345678'),
(23, 'Clie0023', '04267777777', '2023-05-05', 'luisa.hernandez@email.com', 'Luisa', 'Hernandez', '1984-02-06', 'E-33456789'),
(24, 'Clie0024', '04169999999', '2023-05-10', 'jorge.lopez@email.com', 'Jorge', 'Lopez', '1996-05-01', 'V-34567890'),
(25, 'Clie0025', '04120000000', '2023-05-15', 'sofia.perez@email.com', 'Sofia', 'Perez', '1981-11-16', 'V-35678901'),
(26, 'Clie0026', '04144444444', '2023-05-20', 'enrique.rodriguez@email.com', 'Enrique', 'Rodriguez', '1990-03-08', 'E-36789012'),
(27, 'Clie0027', '04268888888', '2023-05-25', 'isabella.sanchez@email.com', 'Isabella', 'Sanchez', '1985-09-21', 'V-37890123'),
(28, 'Clie0028', '04162222222', '2023-06-01', 'ricardo.torres@email.com', 'Ricardo', 'Torres', '1997-12-10', 'V-38901234'),
(29, 'Clie0029', '04125555555', '2023-06-05', 'mariana.diaz@email.com', 'Mariana', 'Diaz', '1983-06-03', 'E-39012345'),
(30, 'Clie0030', '04147777777', '2023-06-10', 'federico.garcia@email.com', 'Federico', 'Garcia', '1992-01-29', 'V-40123456'),
(31, 'Clie0031', '04261111111', '2023-06-15', 'gabriela.martinez@email.com', 'Gabriela', 'Martinez', '1988-08-15', 'V-41234567'),
(32, 'Clie0032', '04163333333', '2023-06-20', 'alberto.ruiz@email.com', 'Alberto', 'Ruiz', '1995-04-18', 'E-42345678'),
(33, 'Clie0033', '04126666666', '2023-06-25', 'laura.gutierrez@email.com', 'Laura', 'Gutierrez', '1980-10-05', 'V-43456789'),
(34, 'Clie0034', '04149999999', '2023-07-01', 'sergio.hernandez@email.com', 'Sergio', 'Hernandez', '1998-02-12', 'V-44567890'),
(35, 'Clie0035', '04260000000', '2023-07-05', 'adriana.jimenez@email.com', 'Adriana', 'Jimenez', '1987-07-30', 'E-45678901'),
(36, 'Clie0036', '04161234567', '2023-07-10', 'oscar.lopez@email.com', 'Oscar', 'Lopez', '1993-09-04', 'V-46789012'),
(37, 'Clie0037', '04127654321', '2023-07-15', 'paola.mendoza@email.com', 'Paola', 'Mendoza', '1982-04-25', 'V-47890123'),
(38, 'Clie0038', '04149876543', '2023-07-20', 'roberto.navarro@email.com', 'Roberto', 'Navarro', '1999-01-01', 'E-48901234'),
(39, 'Clie0039', '04261112233', '2023-07-25', 'andres.ortiz@email.com', 'Andres', 'Ortiz', '1986-06-19', 'V-49012345'),
(40, 'Clie0040', '04165556677', '2023-08-01', 'valeria.ramirez@email.com', 'Valeria', 'Ramirez', '1991-03-14', 'V-50123456'),
(41, 'Clie0041', '04128889900', '2023-08-05', 'gustavo.soto@email.com', 'Gustavo', 'Soto', '1984-12-28', 'E-51234567'),
(42, 'Clie0042', '04143334455', '2023-08-10', 'lorena.vega@email.com', 'Lorena', 'Vega', '1996-08-09', 'V-52345678'),
(43, 'Clie0043', '04267778899', '2023-08-15', 'hugo.vargas@email.com', 'Hugo', 'Vargas', '1980-05-02', 'V-53456789'),
(44, 'Clie0044', '04162223344', '2023-08-20', 'lucia.hernandez@email.com', 'Lucia', 'Hernandez', '1994-07-23', 'E-54567890'),
(45, 'Clie0045', '04120001122', '2023-08-25', 'mario.garcia@email.com', 'Mario', 'Garcia', '1989-01-16', 'V-55678901'),
(46, 'Clie0046', '04145550011', '2023-09-01', 'sofia.rodriguez@email.com', 'Sofia', 'Rodriguez', '1997-03-01', 'V-56789012'),
(47, 'Clie0047', '04269990000', '2023-09-05', 'ignacio.sanchez@email.com', 'Ignacio', 'Sanchez', '1983-09-10', 'E-57890123'),
(48, 'Clie0048', '04163331122', '2023-09-10', 'juana.gonzalez@email.com', 'Juana', 'Gonzalez', '1999-05-05', 'V-58901234'),
(49, 'Clie0049', '04126667788', '2023-09-15', 'tomas.perez@email.com', 'Tomas', 'Perez', '1986-11-20', 'V-59012345'),
(50, 'Clie0050', '04140009988', '2023-09-20', 'rocio.lopez@email.com', 'Rocio', 'Lopez', '1992-04-13', 'E-60123456'),
(51, 'Clie0051', '04264445566', '2023-09-25', 'jorge.diaz@email.com', 'Jorge', 'Diaz', '1980-07-07', 'V-61234567'),
(52, 'Clie0052', '04168887766', '2023-10-01', 'claudia.rojas@email.com', 'Claudia', 'Rojas', '1995-10-24', 'V-62345678'),
(53, 'Clie0053', '04122221100', '2023-10-05', 'alvaro.soto@email.com', 'Alvaro', 'Soto', '1987-02-01', 'E-63456789'),
(54, 'Clie0054', '04146665544', '2023-10-10', 'sandra.castro@email.com', 'Sandra', 'Castro', '1993-08-16', 'V-64567890'),
(55, 'Clie0055', '04260000000', '2023-10-15', 'franco.fernandez@email.com', 'Franco', 'Fernandez', '1981-04-09', 'V-65678901'),
(56, 'Clie0056', '04164444444', '2023-10-20', 'daniela.morales@email.com', 'Daniela', 'Morales', '1998-06-22', 'E-66789012'),
(57, 'Clie0057', '04127777777', '2023-10-25', 'pablo.gonzalez@email.com', 'Pablo', 'Gonzalez', '1985-01-18', 'V-67890123'),
(58, 'Clie0058', '04141111111', '2023-11-01', 'marcelo.hernandez@email.com', 'Marcelo', 'Hernandez', '1990-11-03', 'V-68901234'),
(59, 'Clie0059', '04265555555', '2023-11-05', 'florencia.jimenez@email.com', 'Florencia', 'Jimenez', '1979-05-14', 'E-69012345'),
(60, 'Clie0060', '04169999999', '2023-11-10', 'nico.navarro@email.com', 'Nicolas', 'Navarro', '1996-03-09', 'V-70123456'),
(61, 'Clie0061', '04123333333', '2023-11-15', 'victoria.ortiz@email.com', 'Victoria', 'Ortiz', '1982-08-28', 'V-71234567'),
(62, 'Clie0062', '04148888888', '2023-11-20', 'martin.ramirez@email.com', 'Martin', 'Ramirez', '1999-02-17', 'E-72345678'),
(63, 'Clie0063', '04262222222', '2023-11-25', 'elena.soto@email.com', 'Elena', 'Soto', '1988-10-06', 'V-73456789'),
(64, 'Clie0064', '04166666666', '2023-12-01', 'luciano.vega@email.com', 'Luciano', 'Vega', '1993-04-04', 'V-74567890'),
(65, 'Clie0065', '04129999999', '2023-12-05', 'agustina.vargas@email.com', 'Agustina', 'Vargas', '1980-12-19', 'E-75678901'),
(66, 'Clie0066', '04140000000', '2023-12-10', 'joaquin.hernandez@email.com', 'Joaquin', 'Hernandez', '1997-06-01', 'V-76789012'),
(67, 'Clie0067', '04263333333', '2023-12-15', 'lorena.garcia@email.com', 'Lorena', 'Garcia', '1984-03-22', 'V-77890123'),
(68, 'Clie0068', '04167777777', '2023-12-20', 'benjamin.martinez@email.com', 'Benjamin', 'Martinez', '1990-09-11', 'E-78901234'),
(69, 'Clie0069', '04121212121', '2023-12-25', 'sofia.ruiz@email.com', 'Sofia', 'Ruiz', '1981-01-07', 'V-79012345'),
(70, 'Clie0070', '04143434343', '2024-01-01', 'emiliano.gutierrez@email.com', 'Emiliano', 'Gutierrez', '1994-07-26', 'V-80123456');

INSERT INTO Direccion (id, codigo_postal, calle, municipio, alias, nombre_edif) VALUES
(1, 1060, 'Calle Las Acacias', 'Chacao', 'Casa Principal', 'Casa Independiente'),
(2, 1071, 'Av. Principal', 'El Hatillo', 'Oficina', 'Oficinas Los Robles'),
(3, 1050, 'Calle Miranda', 'Libertador', 'Apartamento', 'Edificio Central'),
(4, 1080, 'Transversal 5', 'Baruta', 'Hogar', 'Residencia Santa Fe'),
(5, 1061, 'Calle Sucre', 'Chacao', 'Residencia', 'Residencias Los Andes'),
(6, 1070, 'Av. Bolivar', 'El Hatillo', 'Local Comercial', 'Centro Comercial El Hatillo'),
(7, 1040, 'Calle 10', 'Libertador', 'Vivienda', 'Casa El Sam�n'),
(8, 1081, 'Calle Venezuela', 'Baruta', 'Casa Familiar', 'Casa La Colina'),
(9, 1062, 'Calle Guaicaipuro', 'Chacao', 'Piso Principal', 'Edificio Alto'),
(10, 1072, 'Av. La Toma', 'El Hatillo', 'Quinta', 'Quinta La Granja'),
(11, 1051, 'Calle Los Cedros', 'Libertador', 'Apartamento Norte', 'Residencias Cedro Real'),
(12, 1082, 'Calle Paris', 'Baruta', 'Sede Trabajo', 'Oficinas Paris Business'),
(13, 1063, 'Calle Tamanaco', 'Chacao', 'Casa Nueva', 'Casa Modelo Urbano'),
(14, 1073, 'Av. Madrid', 'El Hatillo', 'Torre Ejecutiva', 'Edificio Madrid Corporativo'),
(15, 1041, 'Calle Caracas', 'Libertador', 'Oficina Principal', 'Torre Financiera Caracas'),
(16, 1083, 'Calle Berlin', 'Baruta', 'Hogar Dulce Hogar', 'Casa Familiar Los Pinos'),
(17, 1064, 'Calle Elice', 'Chacao', 'Apartamento Sur', 'Residencias Elice Garden'),
(18, 1074, 'Av. Brasil', 'El Hatillo', 'Centro de Negocios', 'Centro Empresarial Brasil'),
(19, 1052, 'Calle Mexico', 'Libertador', 'Hogar Principal', 'Casa La Primavera'),
(20, 1084, 'Calle Londres', 'Baruta', 'Casa de Familia', 'Residencia Londres'),
(21, 1060, 'Calle San Ignacio', 'Chacao', 'Apartamento Personal', 'Edificio Las Delicias'),
(22, 1071, 'Av. Rio de Janeiro', 'El Hatillo', 'Consultorio', 'Centro Profesional Rio'),
(23, 1050, 'Calle Real', 'Libertador', 'Residencia Antigua', 'Edificio Cristal'),
(24, 1080, 'Transversal 3', 'Baruta', 'Vivienda Principal', 'Casa Confort'),
(25, 1061, 'Calle Los Chaguaramos', 'Chacao', 'Apartamento Oeste', 'Residencias Sol y Luna'),
(26, 1070, 'Av. Los Pinos', 'El Hatillo', 'Sede Administrativa', 'Torre Pinos Business'),
(27, 1040, 'Calle 7', 'Libertador', 'Casa de Campo', 'Quinta El Cedro'),
(28, 1081, 'Calle El Cafetal', 'Baruta', 'Casa Principal', 'Casa El Cafetal'),
(29, 1062, 'Calle La Paz', 'Chacao', 'Apartamento Norte', 'Edificio Armonia Residencial'),
(30, 1072, 'Av. Las Delicias', 'El Hatillo', 'Quinta Familiar', 'Quinta Las Delicias'),
(31, 1051, 'Calle Campo Elias', 'Libertador', 'Apartamento Centro', 'Residencias Esmeralda'),
(32, 1082, 'Calle Las Palmas', 'Baruta', 'Oficina Central', 'Oficinas Verdes Corporate'),
(33, 1063, 'Calle Las Flores', 'Chacao', 'Casa Con Jardin', 'Casa Las Flores'),
(34, 1073, 'Av. La Estancia', 'El Hatillo', 'Complejo Residencial', 'Edificio Los Robles Residencial'),
(35, 1041, 'Calle El Colegio', 'Libertador', 'Centro de Capacitaci�n', 'Torre Central Acad�mica'),
(36, 1083, 'Calle La Hacienda', 'Baruta', 'Casa Grande', 'Casa La Hacienda'),
(37, 1064, 'Calle Las Orquideas', 'Chacao', 'Apartamento Este', 'Residencias Paraiso'),
(38, 1074, 'Av. Los Tulipanes', 'El Hatillo', 'Centro Comercial', 'C.C. Jardines del Valle'),
(39, 1052, 'Calle San Jose', 'Libertador', 'Hogar Permanente', 'Casa San Jose'),
(40, 1084, 'Calle La Trinidad', 'Baruta', 'Casa de Descanso', 'Quinta La Trinidad'),
(41, 1060, 'Calle La Esperanza', 'Chacao', 'Apartamento Familiar', 'Edificio La Esperanza'),
(42, 1071, 'Av. Los Samanes', 'El Hatillo', 'Centro de Negocios', 'Torre Las Am�ricas'),
(43, 1050, 'Calle La Granja', 'Libertador', 'Hogar Acogedor', 'Edificio Aurora'),
(44, 1080, 'Transversal 6', 'Baruta', 'Casa Espaciosa', 'Residencia Campestre'),
(45, 1061, 'Calle El Hatillo', 'Chacao', 'Apartamento Amueblado', 'Residencias Oasis'),
(46, 1070, 'Av. Las Fuentes', 'El Hatillo', 'Local Comercial', 'Centro Comercial El Pueblo'),
(47, 1040, 'Calle El Paraiso', 'Libertador', 'Vivienda Familiar', 'Casa El Paraiso'),
(48, 1081, 'Calle La Candelaria', 'Baruta', 'Casa Confortable', 'Residencia La Candelaria'),
(49, 1062, 'Calle La Castellana', 'Chacao', 'Apartamento de Lujo', 'Edificio La Castellana Premier'),
(50, 1072, 'Av. La Esmeralda', 'El Hatillo', 'Quinta con Vista', 'Quinta La Esmeralda'),
(51, 1051, 'Calle La Estancia', 'Libertador', 'Apartamento de Inversi�n', 'Residencias Campestre Real'),
(52, 1082, 'Calle El Placer', 'Baruta', 'Sede Corporativa', 'Oficinas Executive Tower'),
(53, 1063, 'Calle La Floresta', 'Chacao', 'Casa Principal', 'Casa La Floresta'),
(54, 1073, 'Av. Los Campitos', 'El Hatillo', 'Complejo de Oficinas', 'Edificio Centro Parque'),
(55, 1041, 'Calle La Florida', 'Libertador', 'Torre de Oficinas', 'Torre Florida Business'),
(56, 1083, 'Calle La Boyera', 'Baruta', 'Residencia Familiar', 'Casa La Boyera'),
(57, 1064, 'Calle Las Mercedes', 'Chacao', 'Apartamento C�ntrico', 'Residencias Los Olivos'),
(58, 1074, 'Av. Los Naranjos', 'El Hatillo', 'Centro M�dico', 'Centro M�dico Naranjos'),
(59, 1052, 'Calle San Bernardino', 'Libertador', 'Casa Hist�rica', 'Casa San Bernardino'),
(60, 1084, 'Calle La Lagunita', 'Baruta', 'Club de Golf', 'Club de Golf La Lagunita'),
(61, 1060, 'Calle La Alameda', 'Chacao', 'Apartamento Moderno', 'Edificio La Alameda'),
(62, 1071, 'Av. La Paz', 'El Hatillo', 'Oficina Principal', 'Torre La Paz Corporativa'),
(63, 1050, 'Calle La Concordia', 'Libertador', 'Residencia Principal', 'Edificio La Armon�a'),
(64, 1080, 'Transversal 8', 'Baruta', 'Casa Acogedora', 'Residencia Tranquila'),
(65, 1061, 'Calle La Candelaria', 'Chacao', 'Apartamento Estudio', 'Residencias San Pedro'),
(66, 1070, 'Av. El Rosario', 'El Hatillo', 'Centro Empresarial', 'Centro Empresarial El Rosario'),
(67, 1040, 'Calle La Trinidad', 'Libertador', 'Casa de Lujo', 'Quinta La Trinidad Real'),
(68, 1081, 'Calle La Pradera', 'Baruta', 'Casa Amplia', 'Residencia La Pradera'),
(69, 1062, 'Calle El Bosque', 'Chacao', 'Apartamento Vista', 'Edificio Los Pinos Deluxe'),
(70, 1072, 'Av. La Colina', 'El Hatillo', 'Quinta Urbana', 'Quinta La Colina'),
(71, 1051, 'Calle La Castellana', 'Libertador', 'Apartamento Corporativo', 'Residencias La Colina Ejecutiva'),
(72, 1082, 'Calle El Valle', 'Baruta', 'Sede de Empresa', 'Oficinas El Valle Corporativo'),
(73, 1063, 'Calle La Escondida', 'Chacao', 'Casa Privada', 'Casa La Escondida'),
(74, 1073, 'Av. La Quebrada', 'El Hatillo', 'Edificio Residencial', 'Edificio La Quebrada'),
(75, 1041, 'Calle Los Samanes', 'Libertador', 'Torre de Consultorios', 'Torre El Sol M�dica'),
(76, 1083, 'Calle Las Mesetas', 'Baruta', 'Casa Moderna', 'Residencia Las Mesetas'),
(77, 1064, 'Calle El Cedral', 'Chacao', 'Apartamento Vacacional', 'Residencias El Cedral'),
(78, 1074, 'Av. Las Nieves', 'El Hatillo', 'Centro Educativo', 'Centro Educativo Las Nieves'),
(79, 1052, 'Calle Las Acacias', 'Libertador', 'Casa Unifamiliar', 'Casa Acacias'),
(80, 1084, 'Calle La Monta�a', 'Baruta', 'Casa con Vista', 'Residencia La Monta�a'),
(81, 1060, 'Calle Guaicaipuro', 'Chacao', 'Oficina de Cliente', 'Torre Guaicaipuro'),
(82, 1071, 'Av. Principal de La Boyera', 'El Hatillo', 'Residencia Familiar', 'Quinta Esmeralda'),
(83, 1050, 'Calle Las Palmas', 'Libertador', 'Apartamento Principal', 'Residencias Los Girasoles'),
(84, 1080, 'Transversal 11', 'Baruta', 'Sede Ejecutiva', 'Torre Empresarial Sigma'),
(85, 1061, 'Calle Francisco de Miranda', 'Chacao', 'Oficina Principal', 'Edificio Altamira'),
(86, 1070, 'Av. Los Pr�ceres', 'El Hatillo', 'Casa Rural', 'Casa de Campo Los Pr�ceres'),
(87, 1040, 'Calle Bol�var', 'Libertador', 'Consultorio M�dico', 'Centro Profesional �vila'),
(88, 1081, 'Calle El Parque', 'Baruta', 'Apartamento de Inversi�n', 'Residencias El Parque'),
(89, 1062, 'Calle Monse�or Arias', 'Chacao', 'Casa de Playa', 'Villa Monse�or Arias'),
(90, 1072, 'Av. La Guairita', 'El Hatillo', 'Conjunto Residencial', 'Conjunto Residencial Sol'),
(91, 1051, 'Calle San Antonio', 'Libertador', 'Oficina C�ntrica', 'Torre Centro Plaza'),
(92, 1082, 'Calle Los Naranjos', 'Baruta', 'Residencia Privada', 'Casa Los Naranjos'),
(93, 1063, 'Calle La Pedrera', 'Chacao', 'Apartamento de Lujo', 'Residencias Las Fuentes'),
(94, 1073, 'Av. P�ez', 'El Hatillo', 'Cl�nica Especializada', 'Consultorios M�dicos Oriental'),
(95, 1041, 'Calle La Victoria', 'Libertador', 'Edificio Emblem�tico', 'Edificio La Victoria'),
(96, 1083, 'Calle El Tamarindo', 'Baruta', 'Casa Recreativa', 'Casa El Tamarindo'),
(97, 1064, 'Calle Los Laureles', 'Chacao', 'Centro de Negocios', 'Centro Comercial Los Laureles'),
(98, 1074, 'Av. Ricaurte', 'El Hatillo', 'Apartamento Amueblado', 'Residencias Para�so'),
(99, 1052, 'Calle Las Lomas', 'Libertador', 'Casa de Monta�a', 'Casa Las Lomas'),
(100, 1084, 'Calle El Refugio', 'Baruta', 'Club de Campo', 'Club de Campo El Refugio'),
(101, 1060, 'Calle La Paz', 'Chacao', 'Casa Alterna', 'Casa de Hu�spedes'),
(102, 1071, 'Calle Los Pinos', 'El Hatillo', 'Casa de Campo', 'Quinta Vista Hermosa'),
(103, 1050, 'Av. Este 2', 'Libertador', 'Oficina Sucursal', 'Torre Financiera Anexo'),
(104, 1080, 'Calle La Capilla', 'Baruta', 'Residencia Familiar', 'Casa Colonial La Capilla'),
(105, 1061, 'Calle El Rosal', 'Chacao', 'Apartamento de Familia', 'Residencias El Rosal'),
(106, 1070, 'Av. Los Pinos (Sec. 2)', 'El Hatillo', 'Espacio de Coworking', 'Edificio Teletrabajo'),
(107, 1040, 'Calle Los Cerezos', 'Libertador', 'Casa de Verano', 'Villa Cerezos'),
(108, 1081, 'Calle La Cima', 'Baruta', 'Apartamento Inversi�n', 'Edificio Cima'),
(109, 1062, 'Calle El Parque', 'Chacao', 'Estudio Personal', 'Residencias Universitarias'),
(110, 1072, 'Av. San Felipe', 'El Hatillo', 'Casa Rural', 'Finca San Felipe'),
(111, 1051, 'Calle Venezuela (Sec. 2)', 'Libertador', 'Oficina Alterna', 'Centro Negocios Global'),
(112, 1082, 'Calle El Bosque (Sec. 2)', 'Baruta', 'Casa de Vacaciones', 'Caba�a El Bosque'),
(113, 1063, 'Calle Las Flores (Sec. 2)', 'Chacao', 'Apartamento Alquiler', 'Residencias Orqu�dea'),
(114, 1073, 'Av. Principal (Sec. 2)', 'El Hatillo', 'Oficina Provisional', 'Edificio Soluci�n'),
(115, 1041, 'Calle Los Mangos', 'Libertador', 'Casa de Descanso', 'Quinta Los Mangos'),
(116, 1083, 'Calle La Ensenada', 'Baruta', 'Apartamento Adicional', 'Residencias Costa Bella'),
(117, 1064, 'Calle Tamanaco (Sec. 2)', 'Chacao', 'Espacio Creativo', 'Centro Creativo'),
(118, 1074, 'Av. Intercomunal (Sec. 2)', 'El Hatillo', 'Casa de Inversi�n', 'Propiedad Intercomunal'),
(119, 1052, 'Calle Libertador (Sec. 2)', 'Libertador', 'Hogar Secundario', 'Casa Libertador'),
(120, 1084, 'Calle Principal (Sec. 2)', 'Baruta', 'Oficina Sat�lite', 'Oficina Baruta 2');

INSERT INTO DireccionCliente (idCliente, idDireccion) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30),
(31, 31),
(32, 32),
(33, 33),
(34, 34),
(35, 35),
(36, 36),
(37, 37),
(38, 38),
(39, 39),
(40, 40),
(41, 41),
(42, 42),
(43, 43),
(44, 44),
(45, 45),
(46, 46),
(47, 47),
(48, 48),
(49, 49),
(50, 50),
(51, 51),
(52, 52),
(53, 53),
(54, 54),
(55, 55),
(56, 56),
(57, 57),
(58, 58),
(59, 59),
(60, 60),
(61, 61),
(62, 62),
(63, 63),
(64, 64),
(65, 65),
(66, 66),
(67, 67),
(68, 68),
(69, 69),
(70, 70);

INSERT INTO Comercio (id, password, telefono, fecha_registro, correo, nombre, ubicacion_fisica, hora_apertura, hora_cierre, estaActivo) VALUES
(1, 'ComPss01', '02121112233', '2023-01-10', 'saborcriollo@email.com', 'El Sabor Criollo', 'Av. Libertador, Libertador, Caracas, 1050', 8, 22, 1),
(2, 'ComPss02', '02122223344', '2023-01-15', 'pizzeriaroma@email.com', 'Pizzeria Roma', 'Calle Sucre, Chacao, Caracas, 1060', 12, 23, 1),
(3, 'ComPss03', '02123334455', '2023-01-20', 'sakurabar@email.com', 'Sushi Bar Sakura', 'Calle M�rida, Baruta, Caracas, 1080', 11, 21, 1),
(4, 'ComPss04', '02124445566', '2023-01-25', 'tacosburritos@email.com', 'Tacos & Burritos Express', 'Calle El Boulevard, El Hatillo, Caracas, 1070', 9, 20, 1),
(5, 'ComPss05', '02125556677', '2023-02-01', 'cafearomas@email.com', 'Caf� Aromas', 'Av. Fco. de Miranda, Sucre, Caracas, 1071', 7, 19, 1),
(6, 'ComPss06', '02126667788', '2023-02-05', 'parrillamixta@email.com', 'Parrilla Mixta', 'Av. San Mart�n, Libertador, Caracas, 1050', 12, 23, 1),
(7, 'ComPss07', '02127778899', '2023-02-10', 'dulcestentaciones@email.com', 'Dulces Tentaciones', 'Calle Los Palos Grandes, Chacao, Caracas, 1060', 10, 18, 1),
(8, 'ComPss08', '02128889900', '2023-02-15', 'fenixchino@email.com', 'Comida China F�nix', 'Av. Principal de Las Mercedes, Baruta, Caracas, 1080', 11, 22, 1),
(9, 'ComPss09', '02129990011', '2023-02-20', 'arepazocasa@email.com', 'La Casa del Arepazo', 'Calle La Paz, El Hatillo, Caracas, 1070', 6, 22, 1),
(10, 'ComPss10', '02120001122', '2023-02-25', 'hamburguesasg@email.com', 'Hamburguesas Gigantes', 'Av. R�mulo Gallegos, Sucre, Caracas, 1071', 13, 23, 1),
(11, 'ComPss11', '02121110000', '2023-03-01', 'verdeveg@email.com', 'Vegetariano Verde', 'Calle Urdaneta, Libertador, Caracas, 1050', 9, 20, 1),
(12, 'ComPss12', '02122221111', '2023-03-05', 'heladosref@email.com', 'Helados Refrescantes', 'Calle Andr�s Bello, Chacao, Caracas, 1060', 10, 21, 1),
(13, 'ComPss13', '02123332222', '2023-03-10', 'pastasitalia@email.com', 'Pastas Italianas', 'Calle Veracruz, Baruta, Caracas, 1080', 12, 22, 1),
(14, 'ComPss14', '02124443333', '2023-03-15', 'arepasrellenas@email.com', 'Arepas Rellenas', 'Av. Intercomunal, El Hatillo, Caracas, 1070', 7, 21, 1),
(15, 'ComPss15', '02125554444', '2023-03-20', 'polloscrunchy@email.com', 'Pollos Asados Crunchy', 'Calle La California, Sucre, Caracas, 1071', 11, 23, 1),
(16, 'ComPss16', '02126665555', '2023-03-25', 'empanadasve@email.com', 'Empanadas Venezolanas', 'Av. Baralt, Libertador, Caracas, 1050', 8, 19, 1),
(17, 'ComPss17', '02127776666', '2023-04-01', 'churroschoc@email.com', 'Churros y Chocolate', 'Av. Francisco Solano, Chacao, Caracas, 1060', 14, 22, 1),
(18, 'ComPss18', '02128887777', '2023-04-05', 'cevichesmar@email.com', 'Ceviches del Mar', 'Calle Chama, Baruta, Caracas, 1080', 12, 20, 1),
(19, 'ComPss19', '02129998888', '2023-04-10', 'shawarmasrey@email.com', 'Shawarmas El Rey', 'Calle El Centro, El Hatillo, Caracas, 1070', 10, 23, 1),
(20, 'ComPss20', '02120009999', '2023-04-15', 'saborcubano@email.com', 'Comida Cubana Sabor', 'Av. Sucre, Sucre, Caracas, 1071', 11, 22, 1),
(21, 'ComPss21', '02121010101', '2023-04-20', 'ensaladasf@email.com', 'Ensaladas Frescas', 'Calle Real de Sabana Grande, Libertador, Caracas, 1050', 9, 18, 1),
(22, 'ComPss22', '02122020202', '2023-04-25', 'tortaspostres@email.com', 'Tortas y Postres', 'Calle Guaicaipuro, Chacao, Caracas, 1060', 10, 20, 1),
(23, 'ComPss23', '02123030303', '2023-05-01', 'laesquina@email.com', 'Cafeter�a La Esquina', 'Av. Principal de La Trinidad, Baruta, Caracas, 1080', 6, 17, 1),
(24, 'ComPss24', '02124040404', '2023-05-05', 'desayunosc@email.com', 'Desayunos Criollos', 'Calle El Progreso, El Hatillo, Caracas, 1070', 7, 14, 1),
(25, 'ComPss25', '02125050505', '2023-05-10', 'jugosnat@email.com', 'Jugos Naturales', 'Av. Sanz, Sucre, Caracas, 1071', 8, 19, 1),
(26, 'ComPss26', '02126060606', '2023-05-15', 'perrosgourmet@email.com', 'Perros Calientes Gourmet', 'Av. Urdaneta, Libertador, Caracas, 1050', 15, 23, 1),
(27, 'ComPss27', '02127070707', '2023-05-20', 'areperiaexp@email.com', 'Areper�a Express', 'Calle Elice, Chacao, Caracas, 1060', 7, 20, 1),
(28, 'ComPss28', '02128080808', '2023-05-25', 'bistrofrances@email.com', 'Bistro Franc�s', 'Calle Madrid, Baruta, Caracas, 1080', 18, 23, 1),
(29, 'ComPss29', '02129090909', '2023-06-01', 'panaderiaart@email.com', 'Panader�a Artesanal', 'Calle Bol�var, El Hatillo, Caracas, 1070', 6, 19, 1),
(30, 'ComPss30', '02120101010', '2023-06-05', 'pinchostapas@email.com', 'Pinchos y Tapas', 'Av. Boyac�, Sucre, Caracas, 1071', 17, 23, 1),
(31, 'ComPss31', '02121212121', '2023-06-10', 'comidarapida@email.com', 'Comida R�pida Leo', 'Av. M�xico, Libertador, Caracas, 1050', 11, 21, 0),
(32, 'ComPss32', '02122323232', '2023-06-15', 'deliciasmar@email.com', 'Delicias del Mar', 'Calle Principal de La Castellana, Chacao, Caracas, 1060', 12, 20, 0),
(33, 'ComPss33', '02123434343', '2023-06-20', 'asadorcerrado@email.com', 'El Asador Cerrado', 'Av. La Guairita, Baruta, Caracas, 1080', 18, 23, 0),
(34, 'ComPss34', '02124545454', '2023-06-25', 'desayunosolv@email.com', 'Desayunos Olvidados', 'Calle Uni�n, El Hatillo, Caracas, 1070', 7, 12, 0),
(35, 'ComPss35', '02125656565', '2023-07-01', 'dulceinactivo@email.com', 'El Dulce Inactivo', 'Av. El Marqu�s, Sucre, Caracas, 1071', 10, 16, 0);

INSERT INTO ComercioCocina (idComercio, idCocina) VALUES
-- 11 Comercios con 2 o m�s cocinas (30% de 35 es 10.5, redondeado a 11)
(1, 8), (1, 25), -- El Sabor Criollo (Venezolana, Tradicional)
(2, 3), (2, 28), -- Pizzeria Roma (Italiana, Fusi�n)
(3, 4), (3, 26), -- Sushi Bar Sakura (Japonesa, Gourmet)
(4, 2), (4, 31), -- Tacos & Burritos (Mexicana, Tex-Mex)
(5, 25), (5, 30), -- Caf� Aromas (Tradicional, Casera)
(6, 7), (6, 14), -- Parrilla Mixta (Parrilla, Argentina)
(7, 22), (7, 10), -- Dulces Tentaciones (Turca - por baklava, Francesa - por reposter�a)
(8, 1), (8, 24), -- Comida China F�nix (China, Internacional)
(9, 8), (9, 32), -- La Casa del Arepazo (Venezolana, Street Food)
(10, 24), (10, 34), -- Hamburguesas Gigantes (Internacional, Comfort Food)
(11, 19), (11, 33), -- Vegetariano Verde (Sin Gluten, Healthy-Fit)
-- Los 24 comercios restantes con al menos 1 cocina
(12, 25), -- Helados Refrescantes (Tradicional)
(13, 3), -- Pastas Italianas (Italiana)
(14, 8), -- Arepas Rellenas (Venezolana)
(15, 7), -- Pollos Asados Crunchy (Parrilla)
(16, 8), -- Empanadas Venezolanas (Venezolana)
(17, 25), -- Churros y Chocolate (Tradicional)
(18, 12), -- Ceviches del Mar (Peruana)
(19, 6), -- Shawarmas El Rey (�rabe)
(20, 24), -- Comida Cubana Sabor (Internacional)
(21, 33), -- Ensaladas Frescas (Healthy-Fit)
(22, 25), -- Tortas y Postres (Tradicional)
(23, 25), -- Cafeter�a La Esquina (Tradicional)
(24, 8), -- Desayunos Criollos (Venezolana)
(25, 33), -- Jugos Naturales (Healthy-Fit)
(26, 32), -- Perros Calientes Gourmet (Street Food)
(27, 8), -- Areper�a Express (Venezolana)
(28, 10), -- Bistro Franc�s (Francesa)
(29, 25), -- Panader�a Artesanal (Tradicional)
(30, 11), -- Pinchos y Tapas (Espa�ola)
(31, 24), -- Comida R�pida Leo (Internacional)
(32, 9), -- Delicias del Mar (Mediterr�nea)
(33, 7), -- El Asador Cerrado (Parrilla)
(34, 25), -- Desayunos Olvidados (Tradicional)
(35, 25); -- El Dulce Inactivo (Tradicional)

INSERT INTO Repartidor (id, password, telefono, fecha_registro, correo, nombre, apellido, fecha_nac, nro_documento, detalle_vehiculo, estado) VALUES
(1, 'RepPss01', '04141001001', '2023-01-15', 'juan.perez@reparto.com', 'Juan', 'Perez', '1990-05-20', 'V-12345678', 'Moto', 'Activo'),
(2, 'RepPss02', '04122002002', '2023-01-20', 'maria.gonzalez@reparto.com', 'Maria', 'Gonzalez', '1988-11-12', 'V-87654321', 'Bicicleta', 'Activo'),
(3, 'RepPss03', '04263003003', '2023-01-25', 'carlos.rojas@reparto.com', 'Carlos', 'Rojas', '1992-03-01', 'V-11223344', 'Carro', 'Activo'),
(4, 'RepPss04', '04164004004', '2023-02-01', 'ana.lopez@reparto.com', 'Ana', 'Lopez', '1995-07-25', 'E-44332211', 'Moto', 'Inactivo'),
(5, 'RepPss05', '04145005005', '2023-02-05', 'luis.diaz@reparto.com', 'Luis', 'Diaz', '1987-09-03', 'V-55667788', 'Bicicleta', 'Activo'),
(6, 'RepPss06', '04126006006', '2023-02-10', 'sofia.hernandez@reparto.com', 'Sofia', 'Hernandez', '1993-01-18', 'V-88776655', 'Carro', 'Activo'),
(7, 'RepPss07', '04267007007', '2023-02-15', 'pedro.ramirez@reparto.com', 'Pedro', 'Ramirez', '1991-04-30', 'V-99001122', 'Moto', 'Activo'),
(8, 'RepPss08', '04168008008', '2023-02-20', 'laura.gutierrez@reparto.com', 'Laura', 'Gutierrez', '1994-10-07', 'E-22110099', 'Bicicleta', 'Inactivo'),
(9, 'RepPss09', '04149009009', '2023-02-25', 'miguel.sanchez@reparto.com', 'Miguel', 'Sanchez', '1989-02-14', 'V-33445566', 'Carro', 'Activo'),
(10, 'RepPss10', '04121101100', '2023-03-01', 'elena.torres@reparto.com', 'Elena', 'Torres', '1996-06-22', 'V-66554433', 'Moto', 'Activo'),
(11, 'RepPss11', '04262202200', '2023-03-05', 'david.jimenez@reparto.com', 'David', 'Jimenez', '1986-08-08', 'V-77889900', 'Bicicleta', 'Activo'),
(12, 'RepPss12', '04163303300', '2023-03-10', 'valeria.castro@reparto.com', 'Valeria', 'Castro', '1997-01-05', 'V-00998877', 'Carro', 'Activo'),
(13, 'RepPss13', '04144404400', '2023-03-15', 'alejandro.morales@reparto.com', 'Alejandro', 'Morales', '1990-03-17', 'E-12121212', 'Moto', 'Inactivo'),
(14, 'RepPss14', '04125505500', '2023-03-20', 'camila.fernandez@reparto.com', 'Camila', 'Fernandez', '1993-09-09', 'V-34343434', 'Bicicleta', 'Activo'),
(15, 'RepPss15', '04266606600', '2023-03-25', 'gonzalo.ortiz@reparto.com', 'Gonzalo', 'Ortiz', '1985-12-01', 'V-56565656', 'Carro', 'Activo'),
(16, 'RepPss16', '04167707700', '2023-04-01', 'isabella.vargas@reparto.com', 'Isabella', 'Vargas', '1998-04-28', 'V-78787878', 'Moto', 'Activo'),
(17, 'RepPss17', '04148808800', '2023-04-05', 'francisco.silva@reparto.com', 'Francisco', 'Silva', '1992-07-11', 'V-90909090', 'Bicicleta', 'Activo'),
(18, 'RepPss18', '04129909900', '2023-04-10', 'catalina.garcia@reparto.com', 'Catalina', 'Garcia', '1987-01-23', 'E-10101010', 'Carro', 'Inactivo'),
(19, 'RepPss19', '04260010011', '2023-04-15', 'sebastian.mendoza@reparto.com', 'Sebastian', 'Mendoza', '1994-08-05', 'V-23232323', 'Moto', 'Activo'),
(20, 'RepPss20', '04161110022', '2023-04-20', 'ximena.ruiz@reparto.com', 'Ximena', 'Ruiz', '1991-06-19', 'V-45454545', 'Bicicleta', 'Activo');

INSERT INTO Opcion (id, nombre, descripcion) VALUES
(1, 'Tama�o', 'Define el tama�o de la porci�n del plato.'),
(2, 'Adicionales', 'Permite agregar elementos extras al plato principal.'),
(3, 'Salsa', 'Opciones de salsas para acompa�ar el plato.'),
(4, 'Bebida', 'Selecci�n de bebidas para complementar la comida.'),
(5, 'Cocci�n', 'Especifica el punto de cocci�n de la carne o ingrediente principal.'),
(6, 'Acompa�amiento', 'Opciones de guarniciones para el plato.'),
(7, 'Nivel Picante', 'Define la intensidad de picante del plato.'),
(8, 'Tipo de Queso', 'Variedades de queso disponibles para el plato.'),
(9, 'Crema', 'Opci�n de incluir o no crema en el plato.'),
(10, 'Toppings', 'Aderezos o coberturas para postres o bebidas.'),
(11, 'Glaseado', 'Tipos de glaseado para reposter�a.'),
(12, 'Cobertura', 'Opciones de capa superior para postres o pasteles.'),
(13, 'Prote�na Extra', 'A�adir una porci�n adicional de prote�na.'),
(14, 'Endulzante', 'Variedades de endulzantes para bebidas o postres.'),
(15, 'Tipo de Pan', 'Opciones de pan para s�ndwiches o acompa�amientos.'),
(16, 'Tipo de Leche', 'Variedades de leche para bebidas.'),
(17, 'Huevo', 'Forma de preparaci�n del huevo.'),
(18, 'Az�car', 'Opci�n de a�adir az�car.'),
(19, 'Aguacate', 'Opci�n de aguacate extra o no incluirlo.'),
(20, 'Salsas (Gen�rico)', 'Salsas variadas para distintos platos.'),
(21, 'Tipo de Helado', 'Sabores de helado disponibles.'),
(22, 'Guarnici�n Extra', 'Guarniciones adicionales que se pueden pedir.'),
(23, 'Fruta', 'Tipos de frutas para bebidas o postres.'),
(24, 'Relleno', 'Ingredientes para rellenar platos.'),
(25, 'Corte de Carne', 'Tipos de corte de carne.'),
(26, 'Tipo de Caf�', 'Variedades de preparaciones de caf�.'),
(27, 'Presentaci�n', 'Forma en que se sirve o empaqueta el plato.'),
(28, 'Grado de Tostado', 'Nivel de tostado para pan o caf�.'),
(29, 'Bebida Caliente', 'Opciones de bebidas calientes.'),
(30, 'Corte de Vegetales', 'Forma en que se preparan los vegetales.'),
(31, 'M�todo de Cocci�n', 'T�cnica utilizada para cocinar el alimento.'),
(32, 'Guarnici�n Principal', 'Tipo de guarnici�n que acompa�a el plato principal.'),
(33, 'Estilo de Salsa', 'Clasificaci�n o base de la salsa.'),
(34, 'Opci�n de Vegetales', 'Vegetales espec�ficos para incluir en el plato.'),
(35, 'Cantidad', 'N�mero de unidades o porciones.'),
(36, 'Tipo de Arroz', 'Variedades de arroz para acompa�amientos.'),
(37, 'Tipo de Pasta', 'Diversas formas y tipos de pasta.'),
(38, 'Base', 'Elemento fundamental sobre el que se construye el plato.'),
(39, 'Condimento', 'Especias o aditivos para realzar el sabor.'),
(40, 'Tipo de Masa', 'Variedades de masa para productos horneados.');

INSERT INTO OpcionValor (id, idOpcion, nombre, precio_extra) VALUES
-- Opcion: Tama�o (id=1)
(1, 1, 'Mediano', 0.00),
(2, 1, 'Grande', 2.00),
(3, 1, 'Personal', 0.00),
(4, 1, 'Familiar', 5.00),

-- Opcion: Adicionales (id=2)
(5, 2, 'Papas fritas', 3.00),
(6, 2, 'Ensalada peque�a', 2.50),
(7, 2, 'Tocino', 1.50),
(8, 2, 'Queso extra', 1.00),

-- Opcion: Salsa (id=3)
(9, 3, 'Tomate', 0.00),
(10, 3, 'Mayonesa', 0.00),
(11, 3, 'Mostaza', 0.00),
(12, 3, 'Ketchup', 0.00),
(13, 3, 'Rosada', 0.00),
(14, 3, 'Picante', 0.00),
(15, 3, 'T�rtara', 0.50),
(16, 3, 'Agridulce', 0.50),
(17, 3, 'Soja', 0.50),
(18, 3, 'Blanca', 0.50),

-- Opcion: Bebida (id=4)
(19, 4, 'Coca-Cola', 0.00),
(20, 4, 'Pepsi', 0.00),
(21, 4, 'Sprite', 0.00),
(22, 4, 'Fanta', 0.00),
(23, 4, 'Agua', 0.00),
(24, 4, 'Jugo Natural', 1.00),

-- Opcion: Cocci�n (id=5)
(25, 5, 'Bien cocido', 0.00),
(26, 5, 'Medio', 0.00),
(27, 5, 'Tres cuartos', 0.00),
(28, 5, 'Poco cocido', 0.00),

-- Opcion: Acompa�amiento (id=6)
(29, 6, 'Arroz', 0.00),
(30, 6, 'Ensalada', 0.00),
(31, 6, 'Papas', 0.00),
(32, 6, 'Tajadas', 1.00),
(33, 6, 'Arepitas', 1.50),

-- Opcion: Nivel Picante (id=7)
(34, 7, 'Suave', 0.00),
(35, 7, 'Medio', 0.00),
(36, 7, 'Picante', 0.00),
(37, 7, 'Muy picante', 0.50),

-- Opcion: Tipo de Queso (id=8)
(38, 8, 'Cheddar', 0.00),
(39, 8, 'Mozzarella', 0.00),
(40, 8, 'Blanco', 0.00),
(41, 8, 'Amarillo', 0.00),
(42, 8, 'De mano', 0.75),
(43, 8, 'Provolone', 0.75),

-- Opcion: Crema (id=9)
(44, 9, 'Con crema', 0.00),
(45, 9, 'Sin crema', 0.00),

-- Opcion: Toppings (id=10)
(46, 10, 'Chocolate chips', 0.50),
(47, 10, 'Nueces', 0.75),
(48, 10, 'Frutas frescas', 1.00),
(49, 10, 'Sirope de chocolate', 0.50),
(50, 10, 'Sirope de fresa', 0.50),
(51, 10, 'Crema batida', 0.50),

-- Opcion: Glaseado (id=11)
(52, 11, 'Chocolate', 0.00),
(53, 11, 'Vainilla', 0.00),
(54, 11, 'Naranja', 0.00),
(55, 11, 'Lim�n', 0.00),

-- Opcion: Cobertura (id=12)
(56, 12, 'Crema batida', 0.00),
(57, 12, 'Merengue', 0.00),
(58, 12, 'Ganache de chocolate', 0.00),

-- Opcion: Prote�na Extra (id=13)
(59, 13, 'Pollo', 3.00),
(60, 13, 'Res', 3.50),
(61, 13, 'Cerdo', 3.00),
(62, 13, 'Camarones', 4.00),
(63, 13, 'Tofu', 2.50),

-- Opcion: Endulzante (id=14)
(64, 14, 'Az�car', 0.00),
(65, 14, 'Splenda', 0.00),
(66, 14, 'Sacarina', 0.00),
(67, 14, 'Miel', 0.50),

-- Opcion: Tipo de Pan (id=15)
(68, 15, 'Pan de hamburguesa', 0.00),
(69, 15, 'Pan de perro', 0.00),
(70, 15, 'Pan �rabe', 0.50),
(71, 15, 'Pan de pita', 0.50),
(72, 15, 'Baguette', 1.00),

-- Opcion: Tipo de Leche (id=16)
(73, 16, 'Leche entera', 0.00),
(74, 16, 'Leche deslactosada', 0.00),
(75, 16, 'Leche de almendras', 0.50),
(76, 16, 'Leche de coco', 0.50),

-- Opcion: Huevo (id=17)
(77, 17, 'Frito', 0.00),
(78, 17, 'Revuelto', 0.00),
(79, 17, 'Poch�', 0.50),

-- Opcion: Az�car (id=18)
(80, 18, 'Con az�car', 0.00),
(81, 18, 'Sin az�car', 0.00),

-- Opcion: Aguacate (id=19)
(82, 19, 'Extra aguacate', 1.50),
(83, 19, 'Sin aguacate', 0.00),

-- Opcion: Salsas (Gen�rico) (id=20)
(84, 20, 'BBQ', 0.00),
(85, 20, 'Teriyaki', 0.00),
(86, 20, 'Dulce', 0.00),
(87, 20, 'Agria', 0.00),
(88, 20, 'Blanca', 0.00),
(89, 20, 'Guasacaca', 0.50),
(90, 20, 'Chimichurri', 0.50),

-- Opcion: Tipo de Helado (id=21)
(91, 21, 'Vainilla', 0.00),
(92, 21, 'Chocolate', 0.00),
(93, 21, 'Fresa', 0.00),
(94, 21, 'Mantecado', 0.00),
(95, 21, 'Pistacho', 0.75),

-- Opcion: Guarnici�n Extra (id=22)
(96, 22, 'Papas Fritas', 2.00),
(97, 22, 'Yuca Frita', 2.50),
(98, 22, 'Tostones', 2.50),
(99, 22, 'Ensalada Mixta', 2.00),

-- Opcion: Fruta (id=23)
(100, 23, 'Fresa', 0.00),
(101, 23, 'Mora', 0.00),
(102, 23, 'Pi�a', 0.00),
(103, 23, 'Parchita', 0.00),
(104, 23, 'Mango', 0.00),
(105, 23, 'Durazno', 0.00),

-- Opcion: Relleno (id=24)
(106, 24, 'Queso', 0.00),
(107, 24, 'Pollo', 1.00),
(108, 24, 'Carne', 1.00),
(109, 24, 'Mixto', 1.50),
(110, 24, 'Dulce de Leche', 0.75),
(111, 24, 'Guayaba', 0.75),
(112, 24, 'Ricotta', 1.00),
(113, 24, 'Espinaca', 0.50),

-- Opcion: Corte de Carne (id=25)
(114, 25, 'Solomo', 0.00),
(115, 25, 'Punta Trasera', 0.00),
(116, 25, 'Asado de Tira', 0.00),

-- Nuevas Opciones y sus Valores:
-- Opcion: Tipo de Caf� (id=26)
(117, 26, 'Espresso', 0.00),
(118, 26, 'Americano', 0.00),
(119, 26, 'Latte', 0.00),
(120, 26, 'Capuccino', 0.00),
(121, 26, 'Moccha', 0.50),

-- Opcion: Presentaci�n (id=27)
(122, 27, 'En plato', 0.00),
(123, 27, 'Para llevar', 0.00),
(124, 27, 'Individual', 0.00),
(125, 27, 'Para compartir', 1.00),

-- Opcion: Grado de Tostado (id=28)
(126, 28, 'Claro', 0.00),
(127, 28, 'Medio', 0.00),
(128, 28, 'Oscuro', 0.00),

-- Opcion: Bebida Caliente (id=29)
(129, 29, 'T� Negro', 0.00),
(130, 29, 'Manzanilla', 0.00),
(131, 29, 'Chocolate', 0.00),

-- Opcion: Corte de Vegetales (id=30)
(132, 30, 'Juliana', 0.00),
(133, 30, 'Dados', 0.00),
(134, 30, 'Rodajas', 0.00),

-- Opcion: M�todo de Cocci�n (id=31)
(135, 31, 'Al vapor', 0.00),
(136, 31, 'Asado', 0.00),
(137, 31, 'Frito', 0.00),
(138, 31, 'A la parrilla', 0.00),

-- Opcion: Guarnici�n Principal (id=32)
(139, 32, 'Vegetales al vapor', 0.00),
(140, 32, 'Pur� de papas', 0.00),
(141, 32, 'Arroz blanco', 0.00),

-- Opcion: Estilo de Salsa (id=33)
(142, 33, 'Crema', 0.00),
(143, 33, 'Vinagreta', 0.00),
(144, 33, 'Reducci�n', 0.00),

-- Opcion: Opci�n de Vegetales (id=34)
(145, 34, 'Lechuga', 0.00),
(146, 34, 'Tomate', 0.00),
(147, 34, 'Cebolla', 0.00),
(148, 34, 'Pepinillos', 0.00),

-- Opcion: Cantidad (id=35)
(149, 35, '1 unidad', 0.00),
(150, 35, '2 unidades', 1.00),
(151, 35, '3 unidades', 2.00),

-- Opcion: Tipo de Arroz (id=36)
(152, 36, 'Arroz blanco', 0.00),
(153, 36, 'Arroz integral', 0.50),
(154, 36, 'Arroz salvaje', 1.00),

-- Opcion: Tipo de Pasta (id=37)
(155, 37, 'Spaghetti', 0.00),
(156, 37, 'Penne', 0.00),
(157, 37, 'Fettuccine', 0.00),
(158, 37, 'Ravioles', 1.00),

-- Opcion: Base (id=38)
(159, 38, 'Pan', 0.00),
(160, 38, 'Arroz', 0.00),
(161, 38, 'Vegetales', 0.00),

-- Opcion: Condimento (id=39)
(162, 39, 'Sal', 0.00),
(163, 39, 'Pimienta', 0.00),
(164, 39, 'Or�gano', 0.00),
(165, 39, 'Ajo', 0.00),

-- Opcion: Tipo de Masa (id=40)
(166, 40, 'Delgada', 0.00),
(167, 40, 'Gruesa', 0.00),
(168, 40, 'Integral', 0.50);

INSERT INTO Menu (id, nombre, descripcion, idComercio) VALUES
(1, 'Men� Tradici�n Venezolana', 'Platos caseros y t�picos de Venezuela.', 1),
(2, 'Men� Pizza & Fusi�n', 'Pizzas cl�sicas con toques innovadores de fusi�n.', 2),
(3, 'Men� Japon�s Gourmet', 'Sushi, ramen y alta cocina japonesa selecta.', 3),
(4, 'Men� Mexicano Tex-Mex', 'Aut�nticos tacos, burritos y quesadillas con sabor Tex-Mex.', 4),
(5, 'Men� Aromas Caseros', 'Caf�s, infusiones y dulces de reposter�a tradicional.', 5),
(6, 'Men� Parrilla Argentina', 'Cortes de carne a la parrilla al estilo argentino.', 6),
(7, 'Men� Dulces del Mundo', 'Postres turcos y reposter�a francesa para deleitar.', 7),
(8, 'Men� China Internacional', 'Especialidades chinas con toques internacionales.', 8),
(9, 'Men� Arepas & Street Food', 'Variedad de arepas y comida callejera venezolana.', 9),
(10, 'Men� Hamburguesas Comfort', 'Hamburguesas internacionales y reconfortantes.', 10),
(11, 'Men� Saludable Sin Gluten', 'Opciones aptas para cel�acos y saludables.', 11),
(12, 'Men� Helados Artesanales', 'Helados y postres fr�os de elaboraci�n tradicional.', 12),
(13, 'Men� Pastas Frescas', 'Pastas caseras con salsas italianas aut�nticas.', 13),
(14, 'Men� Arepas Aut�nticas', 'Arepas tradicionales con rellenos variados.', 14),
(15, 'Men� Pollos a la Parrilla', 'Deliciosos pollos asados con sabor a parrilla.', 15),
(16, 'Men� Empanadas Criollas', 'Empanadas venezolanas con distintos rellenos.', 16),
(17, 'Men� Churros y Reposter�a', 'Churros con chocolate y otros postres tradicionales.', 17),
(18, 'Men� Cebicher�a Peruana', 'Frescos ceviches y platos t�picos de Per�.', 18),
(19, 'Men� Kebab �rabe', 'Aut�nticos shawarmas, falafel y kebabs del Medio Oriente.', 19),
(20, 'Men� Sabor Internacional', 'Platos variados con influencia cubana e internacional.', 20),
(21, 'Men� Ensaladas Fit', 'Ensaladas frescas y saludables para tu dieta.', 21),
(22, 'Men� Tortas y Dulces', 'Variedad de pasteles y postres tradicionales.', 22),
(23, 'Men� Desayunos Tradicionales', 'Opciones para desayunos y meriendas caseras.', 23),
(24, 'Men� Desayunos Venezolanos', 'Desayunos t�picos criollos y tradicionales.', 24),
(25, 'Men� Jugos Fit', 'Jugos naturales y batidos saludables.', 25),
(26, 'Men� Hot Dogs Street Food', 'Perros calientes gourmet al estilo de la comida callejera.', 26),
(27, 'Men� Arepas al Instante', 'Servicio r�pido de arepas venezolanas.', 27),
(28, 'Men� Bistro Franc�s', 'Platos sofisticados de la alta cocina francesa.', 28),
(29, 'Men� Panader�a Casera', 'Panes artesanales y boller�a tradicional.', 29),
(30, 'Men� Tapas y Pinchos', 'Variedad de tapas y pinchos de la cocina espa�ola.', 30),
(31, 'Men� Comida R�pida Internacional', 'Opciones r�pidas y sencillas de cocina internacional.', 31),
(32, 'Men� Delicias Mediterr�neas', 'Especialidades con mariscos y sabores del Mediterr�neo.', 32),
(33, 'Men� Parrilla Cl�sica', 'Cortes de carne preparados a la brasa.', 33),
(34, 'Men� Desayunos Sencillos', 'Opciones b�sicas y tradicionales para el desayuno.', 34),
(35, 'Men� Dulces de Casa', 'Postres y dulces tradicionales caseros.', 35);

INSERT INTO Seccion (id, nombre, descripcion, idMenu) VALUES
-- Men� 1: Men� Tradici�n Venezolana
(1, 'Especialidades Venezolanas', 'Platos aut�nticos y caseros de Venezuela.', 1),
(2, 'Recetas Tradicionales', 'Variedad de platos con el sabor de casa.', 1),
(3, 'Sopas y Cremas', 'Caldo de gallina, asopado y otras sopas criollas.', 1),
(4, 'Platos Fuertes', 'Principales de carne, pollo y pescado al estilo venezolano.', 1),
(5, 'Acompa�amientos', 'Guarniciones t�picas para complementar tu plato.', 1),
(6, 'Postres Criollos', 'Dulces tradicionales para cerrar tu comida.', 1),

-- Men� 2: Men� Pizza & Fusi�n
(7, 'Pizzas Cl�sicas', 'Nuestras pizzas artesanales y favoritas.', 2),
(8, 'Creaciones Fusi�n', 'Platos innovadores que mezclan culturas culinarias.', 2),
(9, 'Pizzas Especiales', 'Recetas �nicas y sabores atrevidos.', 2),
(10, 'Entradas y Antipastos', 'Opciones ligeras para comenzar.', 2),
(11, 'Ensaladas Frescas', 'Variedad de ensaladas con aderezos caseros.', 2),

-- Men� 3: Men� Japon�s Gourmet
(12, 'Selecci�n de Sushi', 'Lo mejor del sushi, sashimi y rolls frescos.', 3),
(13, 'Alta Gastronom�a Japonesa', 'Experiencia culinaria sofisticada con sabores de Jap�n.', 3),
(14, 'Nigiris y Sashimis', 'Cortes selectos de pescado fresco.', 3),
(15, 'Rolls Especiales', 'Creaciones �nicas de nuestros chefs.', 3),
(16, 'Platos Calientes Japoneses', 'Teriyakis, tempuras y sopas tradicionales.', 3),
(17, 'Bebidas Japonesas', 'Sake, cervezas y t�s orientales.', 3),

-- Men� 4: Men� Mexicano Tex-Mex
(18, 'Antojitos Mexicanos', 'Tacos, burritos y quesadillas para todos los gustos.', 4),
(19, 'Fusi�n Tex-Mex', 'Una explosi�n de sabores entre M�xico y Texas.', 4),
(20, 'Especialidades con Carne', 'Platos con carne asada, cochinita y m�s.', 4),
(21, 'Platos Vegetarianos', 'Opciones sin carne con todo el sabor mexicano.', 4),
(22, 'Salsas y Guacamole', 'Picantes y aderezos caseros.', 4),

-- Men� 5: Men� Aromas Caseros
(23, 'Bebidas Tradicionales', 'Caf�s, infusiones y bebidas cl�sicas.', 5),
(24, 'Postres Caseros', 'Dulces y reposter�a hecha en casa.', 5),
(25, 'Caf�s Especiales', 'Variedad de caf�s fr�os y calientes.', 5),
(26, 'T�s e Infusiones', 'Selecci�n de t�s y tisanas.', 5),
(27, 'Pasteler�a', 'Tortas, ponqu�s y dulces para acompa�ar.', 5),

-- Men� 6: Men� Parrilla Argentina
(28, 'Maestros Parrilleros', 'Cortes premium asados a la perfecci�n.', 6),
(29, 'Tradici�n Argentina', 'Aut�nticas carnes y empanadas argentinas.', 6),
(30, 'Cortes de Res', 'Bife de chorizo, entra�a y otros cortes.', 6),
(31, 'Cortes de Cerdo y Pollo', 'Variedad de carnes a la brasa.', 6),
(32, 'Provoletas y Chorizos', 'Entradas cl�sicas de la parrilla.', 6),
(33, 'Guarniciones de la Casa', 'Acompa�amientos frescos y sabrosos.', 6),

-- Men� 7: Men� Dulces del Mundo
(34, 'Delicias Turcas', 'Exquisitos dulces y postres de oriente.', 7),
(35, 'Reposter�a Francesa', 'Elegancia y sabor en cada bocado dulce.', 7),
(36, 'Postres Mediterr�neos', 'Dulces con toques del sur de Europa.', 7),
(37, 'Tartas y Pasteles', 'Variedad de tartas y pasteles para ocasiones especiales.', 7),
(38, 'Chocolates Finos', 'Selecci�n de chocolates artesanales.', 7),

-- Men� 8: Men� China Internacional
(39, 'Platos Chinos Cl�sicos', 'Nuestros cl�sicos de la comida china.', 8),
(40, 'Sabores del Mundo', 'Platos que te llevar�n de viaje culinario.', 8),
(41, 'Arroces y Fideos', 'Chop suey, arroz frito y otras especialidades.', 8),
(42, 'Carnes y Aves', 'Pollo agridulce, cerdo asado y m�s.', 8),
(43, 'Sopas Orientales', 'Sopas tradicionales y nutritivas.', 8),
(44, 'Rollitos y Entradas', 'Entradas crujientes y deliciosas.', 8),

-- Men� 9: Men� Arepas & Street Food
(45, 'Variedad de Arepas', 'Las arepas m�s frescas y con los mejores rellenos.', 9),
(46, 'Comida Callejera', 'Opciones r�pidas y deliciosas para llevar.', 9),
(47, 'Arepas Tradicionales', 'Reinas, pel�as, domin� y m�s.', 9),
(48, 'Arepas Gourmet', 'Combinaciones innovadoras y sabrosas.', 9),
(49, 'Patacones y Tostones', 'Otras delicias venezolanas.', 9),

-- Men� 10: Men� Hamburguesas Comfort
(50, 'Hamburguesas Ex�ticas', 'Hamburguesas con ingredientes y estilos internacionales.', 10),
(51, 'Platos Reconfortantes', 'Comidas que te har�n sentir como en casa.', 10),
(52, 'Cl�sicas Americanas', 'Las hamburguesas de siempre con nuestro toque.', 10),
(53, 'Hamburguesas Veggie', 'Opciones vegetarianas y saludables.', 10),
(54, 'Combos y Promociones', 'Nuestras mejores ofertas en hamburguesas.', 10),
(55, 'Papas y Extras', 'Complementos para tu hamburguesa.', 10),

-- Men� 11: Men� Saludable Sin Gluten
(56, 'Opciones Sin Gluten', 'Platos preparados sin gluten para cuidar tu salud.', 11),
(57, 'Men� Healthy & Fit', 'Comidas nutritivas y balanceadas.', 11),
(58, 'Ensaladas Power', 'Ensaladas llenas de nutrientes y sabor.', 11),
(59, 'Platos con Prote�na', 'Opciones magras para tu dieta.', 11),
(60, 'Snacks Saludables', 'Bocadillos para un antojo sin culpa.', 11),

-- Men� 12: Men� Helados Artesanales
(61, 'Helados Artesanales', 'Sabores �nicos y cremosos para refrescar.', 12),
(62, 'Copas y Combinaciones', 'Arma tu helado con nuestros toppings.', 12),
(63, 'Malteadas y Batidos', 'Bebidas fr�as y cremosas.', 12),
(64, 'Postres Helados', 'Postres elaborados con nuestros helados.', 12),
(65, 'Sabores Cl�sicos', 'Los helados de siempre.', 12),

-- Men� 13: Men� Pastas Frescas
(66, 'Especiales de Pasta', 'Pasta fresca con nuestras salsas exclusivas.', 13),
(67, 'Pastas Rellenas', 'Ravioles, tortellinis y m�s.', 13),
(68, 'Salsas Tradicionales', 'Bolognesa, pesto, carbonara y m�s.', 13),
(69, 'Pastas Gratinadas', 'Opciones al horno con mucho queso.', 13),
(70, 'Entradas Italianas', 'Bruschettas, focaccias y carpaccios.', 13),

-- Men� 14: Men� Arepas Aut�nticas
(71, 'Arepas Rellenas', 'Descubre todos los rellenos para tus arepas.', 14),
(72, 'Arepas Fritas', 'Crujientes por fuera, suaves por dentro.', 14),
(73, 'Arepas Asadas', 'Opciones m�s ligeras y tradicionales.', 14),
(74, 'Combos de Arepas', 'Variedad para compartir.', 14),
(75, 'Mini Arepas', 'Perfectas para picar.', 14),

-- Men� 15: Men� Pollos a la Parrilla
(76, 'Asados a la Brasa', 'Pollos y carnes con el punto perfecto de cocci�n.', 15),
(77, 'Pollos Enteros', 'Para compartir en familia.', 15),
(78, 'Medios Pollos', 'Porciones individuales o para dos.', 15),
(79, 'Guarniciones', 'Papas, ensaladas y arroz.', 15),
(80, 'Salsas Adicionales', 'Para realzar el sabor de tu pollo.', 15),

-- Men� 16: Men� Empanadas Criollas
(81, 'Empanadas Venezolanas', 'Las empanadas m�s crujientes y sabrosas.', 16),
(82, 'Rellenos Tradicionales', 'Carne, pollo, queso, domin�.', 16),
(83, 'Rellenos Especiales', 'Pabell�n, mariscos, etc.', 16),
(84, 'Empanadas Fritas', 'Perfectas para un snack.', 16),
(85, 'Empanadas Horneadas', 'Opciones m�s saludables.', 16),

-- Men� 17: Men� Churros y Reposter�a
(86, 'Postres Fritos', 'Churros y delicias dulces para acompa�ar.', 17),
(87, 'Churros Cl�sicos', 'Con az�car, canela o chocolate.', 17),
(88, 'Rellenos Dulces', 'Dulce de leche, crema pastelera.', 17),
(89, 'Porras y Lzos', 'Otras especialidades de masa frita.', 17),
(90, 'Bebidas Calientes', 'Chocolate caliente, caf�.', 17),

-- Men� 18: Men� Cebicher�a Peruana
(91, 'Pescados y Mariscos', 'Lo mejor del mar en tu mesa.', 18),
(92, 'Ceviches Cl�sicos', 'Pescado blanco, mixto.', 18),
(93, 'Tiraditos y Causas', 'Entradas fr�as peruanas.', 18),
(94, 'Arroces Marinos', 'Arroz con mariscos, chaufa.', 18),
(95, 'Jaleas y Sudados', 'Platos calientes de mariscos.', 18),

-- Men� 19: Men� Kebab �rabe
(96, 'Tradici�n �rabe', 'Shawarmas, falafel y kebabs aut�nticos.', 19),
(97, 'Shawarmas', 'Pollo, carne, mixto.', 19),
(98, 'Falafel', 'Croquetas de garbanzo con salsa de yogur.', 19),
(99, 'Kebabs', 'Brochetas de carne y vegetales.', 19),
(100, 'Tabule y Hummus', 'Ensaladas y dips �rabes.', 19),
(101, 'Bebidas Orientales', 'T� de menta, ayran.', 19),

-- Men� 20: Men� Sabor Internacional
(102, 'Cocina del Mundo', 'Una mezcla de sabores de diferentes latitudes.', 20),
(103, 'Platos Cubanos', 'Ropa vieja, moros y cristianos.', 20),
(104, 'Especialidades Latinas', 'Sabores de toda Latinoam�rica.', 20),
(105, 'Bebidas Refrescantes', 'Mojitos, jugos tropicales.', 20),
(106, 'Postres Internacionales', 'Dulces de diferentes culturas.', 20),

-- Men� 21: Men� Ensaladas Fit
(107, 'Ensaladas Ligeras', 'Opciones frescas y saludables para tu dieta.', 21),
(108, 'Ensaladas Personalizadas', 'Arma tu propia ensalada con nuestros ingredientes.', 21),
(109, 'Prote�nas', 'Pollo, at�n, tofu.', 21),
(110, 'Aderezos', 'Vinagretas, yogurt.', 21),
(111, 'Extras Saludables', 'Frutos secos, semillas.', 21),

-- Men� 22: Men� Tortas y Dulces
(112, 'Tartas y Pasteles', 'Nuestra selecci�n de postres horneados.', 22),
(113, 'Tortas de Cumplea�os', 'Personaliza tu torta para cualquier ocasi�n.', 22),
(114, 'Cupcakes y Muffins', 'Porciones individuales para un dulce antojo.', 22),
(115, 'Postres Fr�os', 'Cheesecakes, mousses.', 22),
(116, 'Galletas y Brownies', 'Para acompa�ar tu caf�.', 22),

-- Men� 23: Men� Desayunos y Brunch
(117, 'Desayunos Cl�sicos', 'Empieza el d�a con nuestras opciones tradicionales.', 23),
(118, 'Brunch Especial', 'Opciones para un desayuno tard�o.', 23),
(119, 'Omelettes y Huevos', 'Preparados a tu gusto.', 23),
(120, 'Panqueques y Waffles', 'Dulces y salados.', 23),
(121, 'Bebidas de Desayuno', 'Caf�, t�, jugos.', 23),

-- Men� 24: Men� Desayunos Criollos
(122, 'Desayunos Criollos', 'Sabores venezolanos para tu primera comida.', 24),
(123, 'Arepas Ma�aneras', 'Con diferentes rellenos.', 24),
(124, 'Perico y Huevos', 'Opciones con huevos revueltos.', 24),
(125, 'Empanadas de Desayuno', 'Fritas y reci�n hechas.', 24),
(126, 'Bebidas Tradicionales', 'Caf� con leche, jugo de papel�n.', 24),

-- Men� 25: Men� Jugos Naturales
(127, 'Jugos y Batidos', 'Refrescantes bebidas naturales para tu bienestar.', 25),
(128, 'Jugos de Frutas', 'Variedad de frutas frescas.', 25),
(129, 'Batidos Verdes', 'Detox y llenos de energ�a.', 25),
(130, 'Smoothies', 'Con yogur y frutas.', 25),
(131, 'Extras para Jugos', 'Prote�na, ch�a.', 25),

-- Men� 26: Men� Hot Dogs Street Food
(132, 'Perros Calientes Gourmet', 'Hot dogs con variedad de ingredientes y estilos.', 26),
(133, 'Perros Cl�sicos', 'Los de siempre con nuestra salsa.', 26),
(134, 'Perros Especiales', 'Combinaciones �nicas y atrevidas.', 26),
(135, 'Extras y Salsas', 'Queso, bacon, cebolla caramelizada.', 26),
(136, 'Papas Fritas', 'Para acompa�ar tu perro caliente.', 26),

-- Men� 27: Men� Arepas al Instante
(137, 'Arepas al Momento', 'La rapidez en el sabor de Venezuela.', 27),
(138, 'Arepas para Llevar', 'Rellenos pr�cticos y deliciosos.', 27),
(139, 'Arepas R�pidas', 'Para cuando tienes prisa.', 27),
(140, 'Arepas Sencillas', 'Solo queso, mantequilla.', 27),
(141, 'Bebidas R�pidas', 'Refrescos y jugos.', 27),

-- Men� 28: Men� Bistro Franc�s
(142, 'Platos del Bistro', 'Creaciones elegantes con un toque franc�s.', 28),
(143, 'Entradas Francesas', 'Sopa de cebolla, pat�.', 28),
(144, 'Platos Fuertes', 'Coq au vin, steak frites.', 28),
(145, 'Postres Cl�sicos', 'Cr�me br�l�e, tarta tatin.', 28),
(146, 'Vinos Franceses', 'Maridajes perfectos para tu comida.', 28),

-- Men� 29: Men� Panader�a Casera
(147, 'Panes Artesanales', 'Variedad de panes y boller�a reci�n horneada.', 29),
(148, 'Panes Salados', 'Con hierbas, queso.', 29),
(149, 'Panes Dulces', 'Brioches, bollos.', 29),
(150, 'Boller�a', 'Croissants, danesas.', 29),
(151, 'Empanadas y Quiches', 'Opciones saladas para el desayuno/merienda.', 29),

-- Men� 30: Men� Tapas y Pinchos
(152, 'Tapas Espa�olas', 'Peque�as delicias para compartir.', 30),
(153, 'Pinchos Variados', 'Mini brochetas y montaditos.', 30),
(154, 'Tortillas y Fritos', 'Tortilla de patatas, calamares.', 30),
(155, 'Embutidos y Quesos', 'Tablas de ib�ricos y quesos.', 30),
(156, 'Bebidas Espa�olas', 'Vinos, sangr�a, ca�as.', 30),

-- Men� 31: Men� Comida R�pida Internacional
(157, 'Men� R�pido', 'Soluciones pr�cticas para tu d�a a d�a.', 31),
(158, 'Hamburguesas y Sandwiches', 'Opciones cl�sicas y variadas.', 31),
(159, 'Papas Fritas y Complementos', 'Para acompa�ar tu comida.', 31),
(160, 'Nuggets y Tiras de Pollo', 'Crujientes y deliciosos.', 31),
(161, 'Bebidas y Postres', 'Refrescos y dulces sencillos.', 31),

-- Men� 32: Men� Delicias del Mediterr�neo
(162, 'Delicias del Mediterr�neo', 'Platos frescos y saludables con influencias mediterr�neas.', 32),
(163, 'Pescados Frescos', 'A la plancha, al horno.', 32),
(164, 'Mariscos', 'Gambas, pulpo, calamares.', 32),
(165, 'Ensaladas Mediterr�neas', 'Con verduras frescas y aceite de oliva.', 32),
(166, 'Mezze y Entradas', 'Hummus, tzatziki, aceitunas.', 32),

-- Men� 33: Men� Parrilla Cl�sica
(167, 'Maestros de la Brasa', 'Especialidades de carne asada.', 33),
(168, 'Cortes de Carne', 'Solomo, punta trasera, asado.', 33),
(169, 'Parrilladas Mixtas', 'Para compartir con amigos y familia.', 33),
(170, 'Acompa�amientos de Parrilla', 'Yuca frita, ensalada rallada.', 33),
(171, 'Salsas y Aderezos', 'Chimichurri, guasacaca.', 33),

-- Men� 34: Men� Desayunos Sencillos
(172, 'Desayunos R�pidos', 'Opciones sencillas y deliciosas para empezar el d�a.', 34),
(173, 'Caf� y Pan', 'Cl�sico desayuno.', 34),
(174, 'Bebidas Calientes', 'Caf�, chocolate, t�.', 34),
(175, 'Tostadas y Mermeladas', 'Para un desayuno ligero.', 34),
(176, 'Opciones Saludables', 'Fruta, yogur.', 34),

-- Men� 35: Men� Dulces de Casa
(177, 'Dulces de Anta�o', 'Postres que te recordar�n a casa.', 35),
(178, 'Flanes y Pudines', 'Deliciosos y cremosos.', 35),
(179, 'Tortas Caseras', 'Recetas de la abuela.', 35),
(180, 'Postres con Frutas', 'Frescos y ligeros.', 35),
(181, 'Bocadillos Dulces', 'Para un antojo a cualquier hora.', 35);

INSERT INTO Plato (id, nombre, orden, cantidadDisponible, precio, descripcion, idSeccion) VALUES
-- Men� 1: El Sabor Criollo (idMenu=1)
(1, 'Pabell�n Criollo', 1, 25, 12.50, 'Arroz, caraotas, carne mechada y tajadas.', 4), -- Platos Fuertes
(2, 'Asopado de Mariscos', 2, 15, 15.00, 'Sopa espesa con variedad de mariscos frescos.', 3), -- Sopas y Cremas
(3, 'Arepa Reina Pepiada', 3, 30, 7.00, 'Arepa rellena de pollo, aguacate y mayonesa.', 1), -- Especialidades Venezolanas
(4, 'Empanada de Carne', 4, 40, 3.50, 'Crujiente empanada frita rellena de carne molida.', 2), -- Recetas Tradicionales
(5, 'Torta Tres Leches', 5, 20, 5.00, 'Cl�sico bizcocho remojado en tres tipos de leche.', 6), -- Postres Criollos

-- Men� 2: Pizzeria Roma (idMenu=2)
(6, 'Pizza Margherita', 6, 30, 10.00, 'Tomate, mozzarella fresca y albahaca.', 7), -- Pizzas Cl�sicas
(7, 'Pizza Cuatro Estaciones', 7, 20, 13.50, 'Hongos, jam�n, alcachofas y aceitunas.', 7), -- Pizzas Cl�sicas
(8, 'Pizza Fusi�n BBQ Pollo', 8, 18, 14.00, 'Pollo BBQ, cebolla morada y queso ahumado.', 8), -- Creaciones Fusi�n
(9, 'Bruschetta al Pomodoro', 9, 25, 6.00, 'Pan tostado con tomate fresco, ajo y albahaca.', 10), -- Entradas y Antipastos
(10, 'Ensalada Caprese', 10, 22, 8.50, 'Tomate, mozzarella fresca, albahaca y aceite de oliva.', 11), -- Ensaladas Frescas

-- Men� 3: Sushi Bar Sakura (idMenu=3)
(11, 'Sushi Combo Sakura', 11, 15, 22.00, 'Variedad de nigiris y rolls seleccionados por el chef.', 12), -- Selecci�n de Sushi
(12, 'Sashimi de Salm�n (6 und)', 12, 12, 18.00, 'Finas l�minas de salm�n fresco.', 14), -- Nigiris y Sashimis
(13, 'California Roll (8 und)', 13, 20, 10.00, 'Cangrejo, aguacate y pepino.', 12), -- Selecci�n de Sushi
(14, 'Drag�n Roll (8 und)', 14, 10, 16.50, 'Anguila, aguacate, pepino y topping de aguacate.', 15), -- Rolls Especiales
(15, 'Yakitori de Pollo (3 und)', 15, 18, 9.00, 'Brochetas de pollo glaseadas con salsa teriyaki.', 16), -- Platos Calientes Japoneses

-- Men� 4: Tacos & Burritos (idMenu=4)
(16, 'Tacos al Pastor (3 und)', 16, 30, 9.50, 'Cerdo marinado con pi�a, cebolla y cilantro.', 18), -- Antojitos Mexicanos
(17, 'Burrito de Carnitas', 17, 25, 11.00, 'Cerdo cocido lentamente con arroz, frijoles y salsa.', 18), -- Antojitos Mexicanos
(18, 'Quesadilla Fajita Res', 18, 20, 10.50, 'Tortilla con queso, tiras de res y pimientos.', 20), -- Especialidades con Carne
(19, 'Nachos Supreme', 19, 22, 12.00, 'Totopos con queso, frijoles, jalape�os y crema agria.', 19), -- Fusi�n Tex-Mex
(20, 'Guacamole Fresco', 20, 35, 7.00, 'Aguacate machacado con tomate, cebolla y cilantro.', 22), -- Salsas y Guacamole

-- Men� 5: Caf� Aromas (idMenu=5)
(21, 'Caf� Latte', 21, 50, 4.00, 'Espresso con leche vaporizada y espuma.', 25), -- Caf�s Especiales
(22, 'Torta de Chocolate', 22, 25, 5.50, 'Bizcocho h�medo de chocolate con glaseado cremoso.', 24), -- Postres Caseros
(23, 'Croissant de Almendras', 23, 30, 4.50, 'Crujiente croissant relleno de crema de almendras.', 27), -- Pasteler�a
(24, 'T� Verde con Menta', 24, 40, 3.50, 'Infusi�n refrescante de t� verde y menta.', 26), -- T�s e Infusiones
(25, 'Smoothie de Frutos Rojos', 25, 30, 6.00, 'Batido cremoso de fresas, ar�ndanos y frambuesas.', 23), -- Bebidas Tradicionales

-- Men� 6: Parrilla Mixta (idMenu=6)
(26, 'Bife de Chorizo (300gr)', 26, 20, 25.00, 'Jugoso corte argentino a la parrilla.', 30), -- Cortes de Res
(27, 'Parrillada Mixta (2 personas)', 27, 15, 45.00, 'Variedad de carnes asadas y embutidos.', 28), -- Maestros Parrilleros
(28, 'Empanadas de Carne (2 und)', 28, 30, 7.00, 'Empanadas al estilo argentino.', 29), -- Tradici�n Argentina
(29, 'Provoleta', 29, 25, 9.00, 'Queso provolone fundido a la parrilla con or�gano.', 32), -- Provoletas y Chorizos
(30, 'Ensalada Mixta', 30, 35, 6.00, 'Lechuga, tomate, cebolla.', 33), -- Guarniciones de la Casa

-- Men� 7: Dulces Tentaciones (idMenu=7)
(31, 'Baklava (3 und)', 31, 25, 7.50, 'Postre turco de masa filo, nueces y miel.', 34), -- Delicias Turcas
(32, 'Macarons Variados (5 und)', 32, 20, 10.00, 'Peque�os dulces franceses de almendra.', 35), -- Reposter�a Francesa
(33, 'Tiramis�', 33, 18, 6.50, 'Cl�sico postre italiano de caf� y mascarpone.', 36), -- Postres Mediterr�neos
(34, 'Tarta de Queso', 34, 15, 6.00, 'Cremosa tarta de queso con base de galleta.', 37), -- Tartas y Pasteles
(35, 'Caja de Bombones Artesanales (6 und)', 35, 20, 12.00, 'Selecci�n de bombones de chocolate fino.', 38), -- Chocolates Finos

-- Men� 8: Comida China F�nix (idMenu=8)
(36, 'Arroz Frito con Pollo', 36, 30, 9.00, 'Arroz salteado con pollo, huevo y vegetales.', 41), -- Arroces y Fideos
(37, 'Pollo Agridulce', 37, 25, 11.00, 'Trozos de pollo rebozados en salsa agridulce.', 42), -- Carnes y Aves
(38, 'Chop Suey de Vegetales', 38, 20, 8.50, 'Fideos salteados con variedad de vegetales frescos.', 41), -- Arroces y Fideos
(39, 'Sopa Wonton', 39, 25, 6.00, 'Sopa clara con dumplings rellenos de cerdo.', 43), -- Sopas Orientales
(40, 'Rollitos Primavera (2 und)', 40, 35, 5.00, 'Crujientes rollitos de vegetales fritos.', 44), -- Rollitos y Entradas

-- Men� 9: La Casa del Arepazo (idMenu=9)
(41, 'Arepa Pel�a', 41, 35, 7.50, 'Arepa rellena de carne mechada y queso amarillo.', 47), -- Arepas Tradicionales
(42, 'Arepa Domino', 42, 30, 7.00, 'Arepa rellena de caraotas negras y queso blanco rallado.', 47), -- Arepas Tradicionales
(43, 'Arepa Pabell�n', 43, 25, 8.50, 'Arepa con carne mechada, caraotas, tajadas y queso.', 48), -- Arepas Gourmet
(44, 'Patac�n con Pollo', 44, 20, 9.00, 'Pl�tano verde frito con pollo desmechado y salsas.', 49), -- Patacones y Tostones
(45, 'Teque�os (5 und)', 45, 40, 6.00, 'Dedos de queso envueltos en masa frita.', 45), -- Variedad de Arepas (como snack)

-- Men� 10: Hamburguesas Gigantes (idMenu=10)
(46, 'Hamburguesa Cl�sica', 46, 30, 10.00, 'Carne de res, lechuga, tomate, cebolla, pepinillos y queso.', 52), -- Cl�sicas Americanas
(47, 'Hamburguesa Doble Tocino', 47, 20, 13.00, 'Doble carne, doble queso, mucho tocino y salsa BBQ.', 50), -- Hamburguesas Ex�ticas
(48, 'Hamburguesa Veggie', 48, 25, 9.00, 'Hamburguesa de lentejas con vegetales frescos.', 53), -- Hamburguesas Veggie
(49, 'Combo Mega Burger', 49, 15, 16.00, 'Hamburguesa doble, papas grandes y refresco.', 54), -- Combos y Promociones
(50, 'Papas Fritas Grandes', 50, 40, 4.00, 'Crujientes papas fritas.', 55), -- Papas y Extras

-- Men� 11: Vegetariano Verde (idMenu=11)
(51, 'Ensalada Quinoa y Aguacate', 51, 25, 11.50, 'Quinoa, aguacate, vegetales mixtos y aderezo ligero.', 58), -- Ensaladas Power
(52, 'Wrap de Vegetales Sin Gluten', 52, 20, 9.00, 'Tortilla de arroz rellena de vegetales y hummus.', 56), -- Opciones Sin Gluten
(53, 'Bowl de Lentejas y Verduras', 53, 18, 10.00, 'Sano bowl con lentejas, verduras asadas y especias.', 59), -- Platos con Prote�na
(54, 'Hummus con Vegetales Crudos', 54, 30, 7.00, 'Dip de garbanzos con zanahorias, pepinos y apio.', 60), -- Snacks Saludables
(55, 'Jugo Verde Detox', 55, 35, 6.50, 'Mezcla de espinaca, pepino, manzana y jengibre.', 57), -- Men� Healthy & Fit

-- Men� 12: Helados Refrescantes (idMenu=12)
(56, 'Copa de Helado de Vainilla', 56, 40, 5.00, 'Helado de vainilla con sirope de chocolate.', 61), -- Helados Artesanales
(57, 'Malteada de Fresa', 57, 30, 6.50, 'Batido cremoso de helado de fresa y leche.', 63), -- Malteadas y Batidos
(58, 'Banana Split', 58, 20, 8.00, 'Cl�sico postre con pl�tano, helado y crema batida.', 62), -- Copas y Combinaciones
(59, 'Cono de Chocolate', 59, 50, 4.00, 'Helado de chocolate en cono de barquillo.', 65), -- Sabores Cl�sicos
(60, 'Duraznos con Crema', 60, 25, 5.50, 'Melocotones en alm�bar con crema chantilly.', 64), -- Postres Helados

-- Men� 13: Pastas Italianas (idMenu=13)
(61, 'Spaghetti a la Carbonara', 61, 25, 13.00, 'Pasta con huevo, tocino, queso parmesano y pimienta.', 68), -- Salsas Tradicionales
(62, 'Lasagna Cl�sica', 62, 20, 14.50, 'Capas de pasta, carne rag�, bechamel y queso.', 69), -- Pastas Gratinadas
(63, 'Ravioles de Ricotta y Espinaca', 63, 18, 12.00, 'Pasta rellena con ricotta y espinaca en salsa de tomate.', 67), -- Pastas Rellenas
(64, 'Penne Arrabiata', 64, 22, 11.00, 'Pasta corta con salsa de tomate picante.', 66), -- Especiales de Pasta
(65, 'Focaccia con Romero', 65, 30, 5.00, 'Pan plano con romero y aceite de oliva.', 70), -- Entradas Italianas

-- Men� 14: Arepas Rellenas (idMenu=14)
(66, 'Arepa Reina Pepiada', 66, 35, 7.50, 'Arepa con pollo, aguacate y mayonesa.', 71), -- Arepas Rellenas
(67, 'Arepa Carne Mechada', 67, 30, 7.00, 'Arepa con carne desmechada.', 71), -- Arepas Rellenas
(68, 'Arepa con Queso Telita', 68, 40, 6.00, 'Arepa con queso fresco tipo Telita.', 73), -- Arepas Asadas
(69, 'Mini Arepas Mixtas (3 und)', 69, 25, 8.00, 'Peque�as arepas con diferentes rellenos.', 75), -- Mini Arepas
(70, 'Arepa Frita con Chicharr�n', 70, 20, 8.50, 'Arepa frita con crujientes chicharrones.', 72), -- Arepas Fritas

-- Men� 15: Pollos Asados Crunchy (idMenu=15)
(71, 'Pollo Asado Entero', 71, 15, 18.00, 'Pollo entero marinado y asado a la perfecci�n.', 77), -- Pollos Enteros
(72, 'Medio Pollo Asado', 72, 25, 10.00, 'Media porci�n de nuestro pollo asado.', 78), -- Medios Pollos
(73, 'Papas R�sticas', 73, 30, 4.00, 'Papas cortadas r�sticamente y fritas.', 79), -- Guarniciones
(74, 'Ensalada Coleslaw', 74, 20, 3.50, 'Ensalada fresca de repollo y zanahoria.', 79), -- Guarniciones
(75, 'Salsa de Ajo', 75, 50, 1.50, 'Salsa cremosa de ajo para acompa�ar.', 80), -- Salsas Adicionales

-- Men� 16: Empanadas Venezolanas (idMenu=16)
(76, 'Empanada de Pollo', 76, 35, 3.50, 'Empanada frita rellena de pollo desmechado.', 82), -- Rellenos Tradicionales
(77, 'Empanada de Pabell�n', 77, 25, 4.50, 'Empanada con carne mechada, caraotas y tajadas.', 83), -- Rellenos Especiales
(78, 'Empanada de Queso', 78, 40, 3.00, 'Empanada rellena de queso blanco.', 82), -- Rellenos Tradicionales
(79, 'Empanada de Caz�n', 79, 20, 4.00, 'Empanada con guiso de caz�n.', 83), -- Rellenos Especiales
(80, 'Empanada de Pl�tano y Queso', 80, 20, 3.80, 'Combinaci�n dulce y salada.', 84), -- Empanadas Fritas

-- Men� 17: Churros y Chocolate (idMenu=17)
(81, 'Churros Cl�sicos (5 und)', 81, 40, 5.00, 'Churros azucarados.', 87), -- Churros Cl�sicos
(82, 'Churros con Chocolate', 82, 30, 7.00, 'Churros acompa�ados de una taza de chocolate caliente.', 88), -- Rellenos Dulces
(83, 'Porras (3 und)', 83, 25, 6.00, 'Variedad de masa frita, m�s gruesa que los churros.', 89), -- Porras y Lzos
(84, 'Chocolate Caliente Espa�ol', 84, 50, 4.50, 'Chocolate espeso y cremoso.', 90), -- Bebidas Calientes
(85, 'Churros Rellenos de Dulce de Leche', 85, 20, 6.50, 'Churros rellenos con delicioso arequipe.', 88), -- Rellenos Dulces

-- Men� 18: Ceviches del Mar (idMenu=18)
(86, 'Ceviche Cl�sico de Pescado', 86, 20, 16.00, 'Pescado blanco marinado en lim�n con cebolla y aj�.', 92), -- Ceviches Cl�sicos
(87, 'Ceviche Mixto', 87, 18, 18.50, 'Variedad de mariscos y pescado en leche de tigre.', 92), -- Ceviches Cl�sicos
(88, 'Causa Lime�a de Pollo', 88, 15, 12.00, 'Pur� de papa amarilla con relleno de pollo y aguacate.', 93), -- Tiraditos y Causas
(89, 'Arroz con Mariscos', 89, 12, 17.00, 'Arroz cremoso con selecci�n de mariscos.', 94), -- Arroces Marinos
(90, 'Tiradito de Pulpo al Olivo', 90, 10, 15.00, 'Finas l�minas de pulpo con salsa de aceitunas.', 93), -- Tiraditos y Causas

-- Men� 19: Shawarmas El Rey (idMenu=19)
(91, 'Shawarma de Pollo', 91, 30, 9.50, 'Pollo marinado con vegetales frescos y salsa de ajo.', 97), -- Shawarmas
(92, 'Shawarma de Carne', 92, 25, 10.00, 'Carne de res con especias, vegetales y tahini.', 97), -- Shawarmas
(93, 'Falafel (5 und)', 93, 35, 7.00, 'Croquetas de garbanzo con salsa de yogur.', 98), -- Falafel
(94, 'Kebab de Cordero', 94, 20, 12.00, 'Brocheta de cordero a la parrilla.', 99), -- Kebabs
(95, 'Hummus con Pan Pita', 95, 40, 6.50, 'Dip de garbanzos con aceite de oliva y pan fresco.', 100), -- Tabule y Hummus

-- Men� 20: Comida Cubana Sabor (idMenu=20)
(96, 'Ropa Vieja con Arroz', 96, 20, 14.00, 'Carne deshebrada en salsa de tomate con arroz y frijoles.', 103), -- Platos Cubanos
(97, 'Moros y Cristianos', 97, 30, 6.00, 'Arroz blanco con frijoles negros.', 103), -- Platos Cubanos
(98, 'S�ndwich Cubano', 98, 25, 10.00, 'Cerdo asado, jam�n, queso suizo, pepinillos y mostaza.', 102), -- Cocina del Mundo
(99, 'Tostones con Mojo', 99, 35, 7.00, 'Pl�tanos verdes fritos con salsa de ajo.', 104), -- Especialidades Latinas
(100, 'Mojito Cl�sico', 100, 40, 8.50, 'Ron, hierbabuena, lima, az�car y soda.', 105), -- Bebidas Refrescantes

-- Men� 21: Ensaladas Frescas (idMenu=21)
(101, 'Ensalada C�sar con Pollo', 101, 30, 10.00, 'Lechuga romana, crutones, queso parmesano y aderezo C�sar.', 107), -- Ensaladas Ligeras
(102, 'Ensalada Griega', 102, 25, 9.50, 'Pepino, tomate, cebolla morada, aceitunas kalamata, queso feta.', 107), -- Ensaladas Ligeras
(103, 'Bowl de Salm�n y Quinoa', 103, 18, 14.00, 'Salm�n a la plancha, quinoa, aguacate, espinacas y aderezo.', 108), -- Ensaladas Personalizadas
(104, 'Aderezo Bals�mico', 104, 50, 1.50, 'Vinagre bals�mico, aceite de oliva, mostaza y miel.', 110), -- Aderezos
(105, 'Mix de Semillas', 105, 40, 2.00, 'Ch�a, lino, calabaza y girasol.', 111), -- Extras Saludables

-- Men� 22: Tortas y Postres (idMenu=22)
(106, 'Torta Selva Negra', 106, 15, 7.00, 'Bizcocho de chocolate, cerezas y crema chantilly.', 112), -- Tartas y Pasteles
(107, 'Torta de Zanahoria', 107, 20, 6.50, 'Bizcocho h�medo de zanahoria con glaseado de queso crema.', 112), -- Tartas y Pasteles
(108, 'Cheesecake de Frutos Rojos', 108, 18, 7.50, 'Base de galleta, queso crema y cobertura de frutos rojos.', 115), -- Postres Fr�os
(109, 'Brownie con Helado', 109, 25, 6.00, 'Brownie de chocolate caliente con una bola de helado de vainilla.', 116), -- Galletas y Brownies
(110, 'Cupcake de Vainilla', 110, 30, 4.00, 'Peque�o pastel individual con glaseado.', 114), -- Cupcakes y Muffins

-- Men� 23: Cafeter�a La Esquina (idMenu=23)
(111, 'Tostada Francesa', 111, 25, 7.00, 'Pan brioche empapado en huevo y frito, con sirope.', 120), -- Panqueques y Waffles
(112, 'Omelette de Queso y Jam�n', 112, 30, 8.50, 'Huevos batidos con queso y jam�n.', 119), -- Omelettes y Huevos
(113, 'Panqueques con Frutas', 113, 20, 9.00, 'Panqueques suaves con frutas frescas y miel.', 120), -- Panqueques y Waffles
(114, 'Capuccino', 114, 40, 4.50, 'Espresso con leche espumada y cacao.', 121), -- Bebidas de Desayuno
(115, 'S�ndwich de Croissant', 115, 28, 7.50, 'Croissant relleno de pavo y queso.', 117), -- Desayunos Cl�sicos

-- Men� 24: Desayunos Criollos (idMenu=24)
(116, 'Arepa con Perico', 116, 35, 7.00, 'Arepa rellena de huevos revueltos con cebolla y tomate.', 123), -- Arepas Ma�aneras
(117, 'Cachapa con Queso de Mano', 117, 25, 9.00, 'Tortilla de ma�z tierno con queso fresco.', 122), -- Desayunos Criollos
(118, 'Empanada de Carne Mechada', 118, 30, 4.00, 'Empanada frita con carne desmechada.', 125), -- Empanadas de Desayuno
(119, 'Jugo de Papel�n con Lim�n', 119, 40, 3.50, 'Bebida refrescante de papel�n y lim�n.', 126), -- Bebidas Tradicionales
(120, 'Teque��n', 120, 20, 5.00, 'Teque�o gigante relleno de queso.', 124); -- Perico y Huevos (como acompa�amiento)

INSERT INTO PlatoOpcion (idPlato, idOpcion) VALUES
-- Men� 1: El Sabor Criollo
(1, 6), (1, 3), (1, 32), -- Pabell�n Criollo - Acompa�amiento, Salsa, Guarnici�n Principal
(2, 1), (2, 7),          -- Asopado de Mariscos - Tama�o, Nivel Picante
(3, 1), (3, 19), (3, 24), -- Arepa Reina Pepiada - Tama�o, Aguacate, Relleno (para opciones de relleno extra)
(4, 3), (4, 7), (4, 31), -- Empanada de Carne - Salsa, Nivel Picante, M�todo de Cocci�n
(5, 9), (5, 27),         -- Torta Tres Leches - Crema, Presentaci�n

-- Men� 2: Pizzeria Roma
(6, 1), (6, 8), (6, 40),  -- Pizza Margherita - Tama�o, Tipo de Queso, Tipo de Masa
(7, 1), (7, 2), (7, 40),  -- Pizza Cuatro Estaciones - Tama�o, Adicionales, Tipo de Masa
(8, 1), (8, 20), (8, 40), -- Pizza Fusi�n BBQ Pollo - Tama�o, Salsas (Gen�rico), Tipo de Masa
(9, 3), (9, 28),          -- Bruschetta al Pomodoro - Salsa, Grado de Tostado
(10, 13), (10, 30), (10, 34), -- Ensalada Caprese - Prote�na Extra, Corte de Vegetales, Opci�n de Vegetales

-- Men� 3: Sushi Bar Sakura
(11, 20), (11, 27),      -- Sushi Combo Sakura - Salsas (Gen�rico), Presentaci�n
(12, 7), (12, 35),       -- Sashimi de Salm�n - Nivel Picante, Cantidad
(13, 1), (13, 20),       -- California Roll - Tama�o, Salsas (Gen�rico)
(14, 7), (14, 35),       -- Drag�n Roll - Nivel Picante, Cantidad
(15, 20), (15, 31),      -- Yakitori de Pollo - Salsas (Gen�rico), M�todo de Cocci�n

-- Men� 4: Tacos & Burritos
(16, 7), (16, 2), (16, 34), -- Tacos al Pastor - Nivel Picante, Adicionales, Opci�n de Vegetales
(17, 7), (17, 2), (17, 36), -- Burrito de Carnitas - Nivel Picante, Adicionales, Tipo de Arroz
(18, 8), (18, 31),          -- Quesadilla Fajita Res - Tipo de Queso, M�todo de Cocci�n
(19, 7), (19, 2),           -- Nachos Supreme - Nivel Picante, Adicionales
(20, 7), (20, 33),          -- Guacamole Fresco - Nivel Picante, Estilo de Salsa

-- Men� 5: Caf� Aromas
(21, 16), (21, 14), (21, 26), -- Caf� Latte - Tipo de Leche, Endulzante, Tipo de Caf�
(22, 9), (22, 27),            -- Torta de Chocolate - Crema, Presentaci�n
(23, 10), (23, 28),           -- Croissant de Almendras - Toppings, Grado de Tostado
(24, 14), (24, 29),           -- T� Verde con Menta - Endulzante, Bebida Caliente
(25, 23), (25, 14),           -- Smoothie de Frutos Rojos - Fruta, Endulzante

-- Men� 6: Parrilla Argentina
(26, 5), (26, 6), (26, 25), -- Bife de Chorizo - Cocci�n, Acompa�amiento, Corte de Carne
(27, 6), (27, 20), (27, 32), -- Parrillada Mixta - Acompa�amiento, Salsas (Gen�rico), Guarnici�n Principal
(28, 7), (28, 31),          -- Empanadas de Carne - Nivel Picante, M�todo de Cocci�n
(29, 8), (29, 39),          -- Provoleta - Tipo de Queso, Condimento
(30, 3), (30, 30),          -- Ensalada Mixta - Salsa, Corte de Vegetales

-- Men� 7: Dulces Tentaciones
(31, 10), (31, 27),          -- Baklava - Toppings, Presentaci�n
(32, 11), (32, 27),          -- Macarons Variados - Glaseado, Presentaci�n
(33, 9), (33, 27),           -- Tiramis� - Crema, Presentaci�n
(34, 10), (34, 27),          -- Tarta de Queso - Toppings, Presentaci�n
(35, 12), (35, 27),          -- Caja de Bombones Artesanales - Cobertura, Presentaci�n

-- Men� 8: Comida China F�nix
(36, 13), (36, 36),          -- Arroz Frito con Pollo - Prote�na Extra, Tipo de Arroz
(37, 7), (37, 31),           -- Pollo Agridulce - Nivel Picante, M�todo de Cocci�n
(38, 7), (38, 37),           -- Chop Suey de Vegetales - Nivel Picante, Tipo de Pasta
(39, 7), (39, 29),           -- Sopa Wonton - Nivel Picante, Bebida Caliente (como adicional)
(40, 3), (40, 31),           -- Rollitos Primavera - Salsa, M�todo de Cocci�n

-- Men� 9: La Casa del Arepazo
(41, 1), (41, 19), (41, 24), (41, 38), -- Arepa Pel�a - Tama�o, Aguacate, Relleno, Base
(42, 1), (42, 24), (42, 38),           -- Arepa Domino - Tama�o, Relleno, Base
(43, 1), (43, 19), (43, 24), (43, 38), -- Arepa Pabell�n - Tama�o, Aguacate, Relleno, Base
(44, 3), (44, 32),                     -- Patac�n con Pollo - Salsa, Guarnici�n Principal
(45, 3), (45, 24),                     -- Teque�os - Salsa, Relleno

-- Men� 10: Hamburguesas Gigantes
(46, 5), (46, 8), (46, 34), (46, 39), -- Hamburguesa Cl�sica - Cocci�n, Tipo de Queso, Opci�n de Vegetales, Condimento
(47, 5), (47, 2), (47, 39),          -- Hamburguesa Doble Tocino - Cocci�n, Adicionales, Condimento
(48, 15), (48, 34), (48, 39),        -- Hamburguesa Veggie - Tipo de Pan, Opci�n de Vegetales, Condimento
(49, 4), (49, 27),                   -- Combo Mega Burger - Bebida, Presentaci�n
(50, 3), (50, 39),                   -- Papas Fritas Grandes - Salsa, Condimento

-- Men� 11: Vegetariano Verde
(51, 13), (51, 33), (51, 30), -- Ensalada Quinoa y Aguacate - Prote�na Extra, Estilo de Salsa, Corte de Vegetales
(52, 22), (52, 31),           -- Wrap de Vegetales Sin Gluten - Guarnici�n Extra, M�todo de Cocci�n
(53, 7), (53, 36),            -- Bowl de Lentejas y Verduras - Nivel Picante, Tipo de Arroz
(54, 7), (54, 33),            -- Hummus con Vegetales Crudos - Nivel Picante, Estilo de Salsa
(55, 14), (55, 23),           -- Jugo Verde Detox - Endulzante, Fruta

-- Men� 12: Helados Refrescantes
(56, 10), (56, 27),          -- Copa de Helado de Vainilla - Toppings, Presentaci�n
(57, 10), (57, 16), (57, 23), -- Malteada de Fresa - Toppings, Tipo de Leche, Fruta
(58, 10), (58, 27),          -- Banana Split - Toppings, Presentaci�n
(59, 21), (59, 27),          -- Cono de Chocolate - Tipo de Helado, Presentaci�n
(60, 9), (60, 27),           -- Duraznos con Crema - Crema, Presentaci�n

-- Men� 13: Pastas Italianas
(61, 7), (61, 13), (61, 37), -- Spaghetti a la Carbonara - Nivel Picante, Prote�na Extra, Tipo de Pasta
(62, 13), (62, 31),          -- Lasagna Cl�sica - Prote�na Extra, M�todo de Cocci�n
(63, 3), (63, 37),           -- Ravioles de Ricotta y Espinaca - Salsa, Tipo de Pasta
(64, 7), (64, 37),           -- Penne Arrabiata - Nivel Picante, Tipo de Pasta
(65, 3), (65, 28),           -- Focaccia con Romero - Salsa, Grado de Tostado

-- Men� 14: Arepas Aut�nticas
(66, 1), (66, 19), (66, 24), (66, 38), -- Arepa Reina Pepiada - Tama�o, Aguacate, Relleno, Base
(67, 1), (67, 24), (67, 38),           -- Arepa Carne Mechada - Tama�o, Relleno, Base
(68, 1), (68, 8), (68, 38),            -- Arepa con Queso Telita - Tama�o, Tipo de Queso, Base
(69, 3), (69, 24), (69, 35),           -- Mini Arepas Mixtas - Salsa, Relleno, Cantidad
(70, 3), (70, 31), (70, 38),           -- Arepa Frita con Chicharr�n - Salsa, M�todo de Cocci�n, Base

-- Men� 15: Pollos Asados Crunchy
(71, 6), (71, 20), (71, 31), (71, 32), -- Pollo Asado Entero - Acompa�amiento, Salsas (Gen�rico), M�todo de Cocci�n, Guarnici�n Principal
(72, 6), (72, 31), (72, 32),          -- Medio Pollo Asado - Acompa�amiento, M�todo de Cocci�n, Guarnici�n Principal
(73, 20), (73, 39),                   -- Papas R�sticas - Salsas (Gen�rico), Condimento
(74, 3), (74, 30),                    -- Ensalada Coleslaw - Salsa, Corte de Vegetales
(75, 3), (75, 33),                    -- Salsa de Ajo - Salsa, Estilo de Salsa

-- Men� 16: Empanadas Criollas
(76, 3), (76, 24), (76, 31), -- Empanada de Pollo - Salsa, Relleno, M�todo de Cocci�n
(77, 3), (77, 24), (77, 31), -- Empanada de Pabell�n - Salsa, Relleno, M�todo de Cocci�n
(78, 3), (78, 24), (78, 31), -- Empanada de Queso - Salsa, Relleno, M�todo de Cocci�n
(79, 3), (79, 24), (79, 31), -- Empanada de Caz�n - Salsa, Relleno, M�todo de Cocci�n
(80, 3), (80, 24), (80, 31), -- Empanada de Pl�tano y Queso - Salsa, Relleno, M�todo de Cocci�n

-- Men� 17: Churros y Reposter�a
(81, 10), (81, 35),          -- Churros Cl�sicos - Toppings, Cantidad
(82, 10), (82, 18), (82, 29), -- Churros con Chocolate - Toppings, Az�car, Bebida Caliente (para el chocolate)
(83, 10), (83, 35),          -- Porras - Toppings, Cantidad
(84, 18), (84, 29),          -- Chocolate Caliente Espa�ol - Az�car, Bebida Caliente
(85, 24), (85, 35),          -- Churros Rellenos de Dulce de Leche - Relleno, Cantidad

-- Men� 18: Cebicher�a Peruana
(86, 7), (86, 22), (86, 30), (86, 31), -- Ceviche Cl�sico de Pescado - Nivel Picante, Guarnici�n Extra, Corte de Vegetales, M�todo de Cocci�n
(87, 7), (87, 22), (87, 30),           -- Ceviche Mixto - Nivel Picante, Guarnici�n Extra, Corte de Vegetales
(88, 22), (88, 32),                    -- Causa Lime�a de Pollo - Guarnici�n Extra, Guarnici�n Principal
(89, 7), (89, 36),                     -- Arroz con Mariscos - Nivel Picante, Tipo de Arroz
(90, 7), (90, 30),                     -- Tiradito de Pulpo al Olivo - Nivel Picante, Corte de Vegetales

-- Men� 19: Kebab �rabe
(91, 7), (91, 20), (91, 15), (91, 34), -- Shawarma de Pollo - Nivel Picante, Salsas (Gen�rico), Tipo de Pan, Opci�n de Vegetales
(92, 7), (92, 20), (92, 15), (92, 34), -- Shawarma de Carne - Nivel Picante, Salsas (Gen�rico), Tipo de Pan, Opci�n de Vegetales
(93, 20), (93, 31),                    -- Falafel - Salsas (Gen�rico), M�todo de Cocci�n
(94, 7), (94, 25),                     -- Kebab de Cordero - Nivel Picante, Corte de Carne
(95, 20), (95, 38),                    -- Hummus con Pan Pita - Salsas (Gen�rico), Base

-- Men� 20: Comida Cubana Sabor
(96, 6), (96, 32), (96, 36), -- Ropa Vieja con Arroz - Acompa�amiento, Guarnici�n Principal, Tipo de Arroz
(97, 6), (97, 36),           -- Moros y Cristianos - Acompa�amiento, Tipo de Arroz
(98, 15), (98, 2), (98, 39), -- S�ndwich Cubano - Tipo de Pan, Adicionales, Condimento
(99, 3), (99, 31),           -- Tostones con Mojo - Salsa, M�todo de Cocci�n
(100, 7), (100, 27),         -- Mojito Cl�sico - Nivel Picante, Presentaci�n

-- Men� 21: Ensaladas Fit
(101, 13), (101, 33), (101, 30), -- Ensalada C�sar con Pollo - Prote�na Extra, Estilo de Salsa, Corte de Vegetales
(102, 13), (102, 33), (102, 30), -- Ensalada Griega - Prote�na Extra, Estilo de Salsa, Corte de Vegetales
(103, 13), (103, 22), (103, 36), -- Bowl de Salm�n y Quinoa - Prote�na Extra, Guarnici�n Extra, Tipo de Arroz
(104, 7), (104, 33),             -- Aderezo Bals�mico - Nivel Picante, Estilo de Salsa
(105, 10), (105, 39),            -- Mix de Semillas - Toppings, Condimento

-- Men� 22: Tortas y Dulces
(106, 9), (106, 27),            -- Torta Selva Negra - Crema, Presentaci�n
(107, 9), (107, 27),            -- Torta de Zanahoria - Crema, Presentaci�n
(108, 10), (108, 27), (108, 12),-- Cheesecake de Frutos Rojos - Toppings, Presentaci�n, Cobertura
(109, 21), (109, 27),           -- Brownie con Helado - Tipo de Helado, Presentaci�n
(110, 11), (110, 27),           -- Cupcake de Vainilla - Glaseado, Presentaci�n

-- Men� 23: Cafeter�a La Esquina
(111, 10), (111, 28), (111, 27), -- Tostada Francesa - Toppings, Grado de Tostado, Presentaci�n
(112, 8), (112, 31),             -- Omelette de Queso y Jam�n - Tipo de Queso, M�todo de Cocci�n
(113, 10), (113, 23), (113, 27), -- Panqueques con Frutas - Toppings, Fruta, Presentaci�n
(114, 16), (114, 26), (114, 14), -- Capuccino - Tipo de Leche, Tipo de Caf�, Endulzante
(115, 15), (115, 27),            -- S�ndwich de Croissant - Tipo de Pan, Presentaci�n

-- Men� 24: Desayunos Criollos
(116, 17), (116, 24), (116, 38), -- Arepa con Perico - Huevo, Relleno, Base
(117, 8), (117, 31), (117, 38),  -- Cachapa con Queso de Mano - Tipo de Queso, M�todo de Cocci�n, Base
(118, 24), (118, 31), (118, 35), -- Empanada de Carne Mechada - Relleno, M�todo de Cocci�n, Cantidad
(119, 14), (119, 27),            -- Jugo de Papel�n con Lim�n - Endulzante, Presentaci�n
(120, 24), (120, 35);            -- Teque��n - Relleno, Cantidad

INSERT INTO PlatoOpcionValor (idPlato, idOpcionValor, idOpcion) VALUES
-- Men� 1: El Sabor Criollo
(1, 29, 6), (1, 30, 6),   -- Pabell�n Criollo - Acompa�amiento: Arroz, Ensalada
(1, 9, 3), (1, 10, 3),    -- Pabell�n Criollo - Salsa: Tomate, Mayonesa
(1, 141, 32),             -- Pabell�n Criollo - Guarnici�n Principal: Arroz blanco
(2, 1, 1), (2, 2, 1),     -- Asopado de Mariscos - Tama�o: Mediano, Grande
(2, 36, 7), (2, 34, 7),   -- Asopado de Mariscos - Nivel Picante: Picante, Suave
(3, 1, 1), (3, 2, 1),     -- Arepa Reina Pepiada - Tama�o: Mediano, Grande
(3, 82, 19), (3, 83, 19), -- Arepa Reina Pepiada - Aguacate: Extra aguacate, Sin aguacate
(3, 106, 24), (3, 107, 24),-- Arepa Reina Pepiada - Relleno: Queso, Pollo (si se desea agregar m�s relleno)
(4, 9, 3), (4, 10, 3),    -- Empanada de Carne - Salsa: Tomate, Mayonesa
(4, 36, 7), (4, 34, 7),   -- Empanada de Carne - Nivel Picante: Picante, Suave
(4, 137, 31),             -- Empanada de Carne - M�todo de Cocci�n: Frito
(5, 44, 9), (5, 45, 9),   -- Torta Tres Leches - Crema: Con crema, Sin crema
(5, 122, 27),             -- Torta Tres Leches - Presentaci�n: En plato

-- Men� 2: Pizzeria Roma
(6, 3, 1), (6, 1, 1), (6, 2, 1), -- Pizza Margherita - Tama�o: Personal, Mediano, Grande
(6, 39, 8), (6, 38, 8),          -- Pizza Margherita - Tipo de Queso: Mozzarella, Cheddar
(6, 166, 40), (6, 167, 40),      -- Pizza Margherita - Tipo de Masa: Delgada, Gruesa
(7, 1, 1), (7, 2, 1),            -- Pizza Cuatro Estaciones - Tama�o: Mediano, Grande
(7, 5, 2), (7, 6, 2),            -- Pizza Cuatro Estaciones - Adicionales: Papas fritas, Ensalada peque�a
(7, 166, 40), (7, 168, 40),      -- Pizza Cuatro Estaciones - Tipo de Masa: Delgada, Integral
(8, 1, 1), (8, 2, 1),            -- Pizza Fusi�n BBQ Pollo - Tama�o: Mediano, Grande
(8, 84, 20), (8, 87, 20),        -- Pizza Fusi�n BBQ Pollo - Salsas: BBQ, Agria
(8, 167, 40), (8, 168, 40),      -- Pizza Fusi�n BBQ Pollo - Tipo de Masa: Gruesa, Integral
(9, 9, 3), (9, 14, 3),           -- Bruschetta al Pomodoro - Salsa: Tomate, Picante
(9, 127, 28), (9, 128, 28),      -- Bruschetta al Pomodoro - Grado de Tostado: Medio, Oscuro
(10, 59, 13), (10, 62, 13),      -- Ensalada Caprese - Prote�na Extra: Pollo, Camarones
(10, 134, 30),                   -- Ensalada Caprese - Corte de Vegetales: Rodajas
(10, 146, 34), (10, 147, 34),    -- Ensalada Caprese - Opci�n de Vegetales: Tomate, Cebolla

-- Men� 3: Sushi Bar Sakura
(11, 85, 20), (11, 17, 3),  -- Sushi Combo Sakura - Salsas: Teriyaki, Soja
(11, 125, 27),              -- Sushi Combo Sakura - Presentaci�n: Para compartir
(12, 36, 7), (12, 34, 7),   -- Sashimi de Salm�n - Nivel Picante: Picante, Suave
(12, 150, 35), (12, 151, 35),-- Sashimi de Salm�n - Cantidad: 2 unidades, 3 unidades
(13, 1, 1), (13, 2, 1),     -- California Roll - Tama�o: Mediano, Grande
(13, 17, 3), (13, 86, 20),  -- California Roll - Salsas: Soja, Dulce
(14, 36, 7), (14, 37, 7),   -- Drag�n Roll - Nivel Picante: Picante, Muy picante
(14, 150, 35), (14, 151, 35),-- Drag�n Roll - Cantidad: 2 unidades, 3 unidades
(15, 85, 20), (15, 84, 20), -- Yakitori de Pollo - Salsas: Teriyaki, BBQ
(15, 138, 31),              -- Yakitori de Pollo - M�todo de Cocci�n: A la parrilla

-- Men� 4: Tacos & Burritos
(16, 36, 7), (16, 34, 7),   -- Tacos al Pastor - Nivel Picante: Picante, Suave
(16, 5, 2), (16, 8, 2),     -- Tacos al Pastor - Adicionales: Papas fritas, Queso extra
(16, 145, 34), (16, 147, 34),-- Tacos al Pastor - Opci�n de Vegetales: Lechuga, Cebolla
(17, 36, 7), (17, 34, 7),   -- Burrito de Carnitas - Nivel Picante: Picante, Suave
(17, 6, 2), (17, 7, 2),     -- Burrito de Carnitas - Adicionales: Ensalada peque�a, Tocino
(17, 152, 36), (17, 153, 36),-- Burrito de Carnitas - Tipo de Arroz: Arroz blanco, Arroz integral
(18, 38, 8), (18, 39, 8),   -- Quesadilla Fajita Res - Tipo de Queso: Cheddar, Mozzarella
(18, 136, 31),              -- Quesadilla Fajita Res - M�todo de Cocci�n: Asado
(19, 36, 7), (19, 37, 7),   -- Nachos Supreme - Nivel Picante: Picante, Muy picante
(19, 8, 2),                 -- Nachos Supreme - Adicionales: Queso extra
(20, 34, 7), (20, 35, 7),   -- Guacamole Fresco - Nivel Picante: Suave, Medio
(20, 142, 33),              -- Guacamole Fresco - Estilo de Salsa: Crema

-- Men� 5: Caf� Aromas
(21, 73, 16), (21, 75, 16), -- Caf� Latte - Tipo de Leche: Leche entera, Leche de almendras
(21, 64, 14), (21, 65, 14), -- Caf� Latte - Endulzante: Az�car, Splenda
(21, 119, 26),              -- Caf� Latte - Tipo de Caf�: Latte
(22, 44, 9), (22, 45, 9),   -- Torta de Chocolate - Crema: Con crema, Sin crema
(22, 122, 27),              -- Torta de Chocolate - Presentaci�n: En plato
(23, 46, 10), (23, 47, 10), -- Croissant de Almendras - Toppings: Chocolate chips, Nueces
(23, 127, 28),              -- Croissant de Almendras - Grado de Tostado: Medio
(24, 64, 14), (24, 67, 14), -- T� Verde con Menta - Endulzante: Az�car, Miel
(24, 129, 29),              -- T� Verde con Menta - Bebida Caliente: T� Negro
(25, 100, 23), (25, 104, 23),-- Smoothie de Frutos Rojos - Fruta: Fresa, Mango
(25, 64, 14), (25, 65, 14), -- Smoothie de Frutos Rojos - Endulzante: Az�car, Splenda

-- Men� 6: Parrilla Argentina
(26, 25, 5), (26, 26, 5),   -- Bife de Chorizo - Cocci�n: Bien cocido, Medio
(26, 29, 6), (26, 31, 6),   -- Bife de Chorizo - Acompa�amiento: Arroz, Papas
(26, 114, 25),              -- Bife de Chorizo - Corte de Carne: Solomo
(27, 29, 6), (27, 30, 6),   -- Parrillada Mixta - Acompa�amiento: Arroz, Ensalada
(27, 89, 20), (27, 90, 20), -- Parrillada Mixta - Salsas: Guasacaca, Chimichurri
(27, 140, 32),              -- Parrillada Mixta - Guarnici�n Principal: Pur� de papas
(28, 36, 7), (28, 34, 7),   -- Empanadas de Carne - Nivel Picante: Picante, Suave
(28, 137, 31),              -- Empanadas de Carne - M�todo de Cocci�n: Frito
(29, 43, 8), (29, 39, 8),   -- Provoleta - Tipo de Queso: Provolone, Mozzarella
(29, 164, 39),              -- Provoleta - Condimento: Or�gano
(30, 9, 3), (30, 14, 3),    -- Ensalada Mixta - Salsa: Tomate, Picante
(30, 132, 30),              -- Ensalada Mixta - Corte de Vegetales: Juliana

-- Men� 7: Dulces Tentaciones
(31, 46, 10), (31, 47, 10), -- Baklava - Toppings: Chocolate chips, Nueces
(31, 124, 27),              -- Baklava - Presentaci�n: Individual
(32, 51, 11), (32, 52, 11), -- Macarons Variados - Glaseado: Chocolate, Vainilla
(32, 124, 27),              -- Macarons Variados - Presentaci�n: Individual
(33, 44, 9), (33, 45, 9),   -- Tiramis� - Crema: Con crema, Sin crema
(33, 122, 27),              -- Tiramis� - Presentaci�n: En plato
(34, 48, 10), (34, 49, 10), -- Tarta de Queso - Toppings: Frutas frescas, Sirope de chocolate
(34, 122, 27),              -- Tarta de Queso - Presentaci�n: En plato
(35, 58, 12), (35, 57, 12), -- Caja de Bombones Artesanales - Cobertura: Ganache de chocolate, Merengue
(35, 124, 27),              -- Caja de Bombones Artesanales - Presentaci�n: Individual

-- Men� 8: Comida China F�nix
(36, 59, 13), (36, 61, 13), -- Arroz Frito con Pollo - Prote�na Extra: Pollo, Cerdo
(36, 152, 36), (36, 153, 36),-- Arroz Frito con Pollo - Tipo de Arroz: Arroz blanco, Arroz integral
(37, 36, 7), (37, 34, 7),   -- Pollo Agridulce - Nivel Picante: Picante, Suave
(37, 137, 31),              -- Pollo Agridulce - M�todo de Cocci�n: Frito
(38, 34, 7), (38, 35, 7),   -- Chop Suey de Vegetales - Nivel Picante: Suave, Medio
(38, 155, 37), (38, 157, 37),-- Chop Suey de Vegetales - Tipo de Pasta: Spaghetti, Fettuccine
(39, 34, 7), (39, 35, 7),   -- Sopa Wonton - Nivel Picante: Suave, Medio
(39, 131, 29),              -- Sopa Wonton - Bebida Caliente: Chocolate (como caldo)
(40, 16, 3), (40, 14, 3),   -- Rollitos Primavera - Salsa: Agridulce, Picante
(40, 137, 31),              -- Rollitos Primavera - M�todo de Cocci�n: Frito

-- Men� 9: La Casa del Arepazo
(41, 1, 1), (41, 2, 1),      -- Arepa Pel�a - Tama�o: Mediano, Grande
(41, 82, 19), (41, 83, 19),  -- Arepa Pel�a - Aguacate: Extra aguacate, Sin aguacate
(41, 108, 24),               -- Arepa Pel�a - Relleno: Carne
(41, 159, 38),               -- Arepa Pel�a - Base: Pan (en sentido de masa de arepa)
(42, 1, 1), (42, 2, 1),      -- Arepa Domino - Tama�o: Mediano, Grande
(42, 106, 24),               -- Arepa Domino - Relleno: Queso
(42, 159, 38),               -- Arepa Domino - Base: Pan
(43, 1, 1), (43, 2, 1),      -- Arepa Pabell�n - Tama�o: Mediano, Grande
(43, 82, 19), (43, 83, 19),  -- Arepa Pabell�n - Aguacate: Extra aguacate, Sin aguacate
(43, 109, 24),               -- Arepa Pabell�n - Relleno: Mixto
(43, 159, 38),               -- Arepa Pabell�n - Base: Pan
(44, 13, 3), (44, 14, 3),    -- Patac�n con Pollo - Salsa: Rosada, Picante
(44, 140, 32),               -- Patac�n con Pollo - Guarnici�n Principal: Pur� de papas
(45, 10, 3), (45, 11, 3),    -- Teque�os - Salsa: Mayonesa, Mostaza
(45, 106, 24),               -- Teque�os - Relleno: Queso

-- Men� 10: Hamburguesas Gigantes
(46, 26, 5), (46, 27, 5),   -- Hamburguesa Cl�sica - Cocci�n: Medio, Tres cuartos
(46, 38, 8), (46, 39, 8),   -- Hamburguesa Cl�sica - Tipo de Queso: Cheddar, Mozzarella
(46, 145, 34), (46, 146, 34),-- Hamburguesa Cl�sica - Opci�n de Vegetales: Lechuga, Tomate
(46, 163, 39),              -- Hamburguesa Cl�sica - Condimento: Pimienta
(47, 25, 5), (47, 26, 5),   -- Hamburguesa Doble Tocino - Cocci�n: Bien cocido, Medio
(47, 7, 2), (47, 8, 2),     -- Hamburguesa Doble Tocino - Adicionales: Tocino, Queso extra
(47, 162, 39),              -- Hamburguesa Doble Tocino - Condimento: Sal
(48, 68, 15), (48, 70, 15), -- Hamburguesa Veggie - Tipo de Pan: Pan de hamburguesa, Pan �rabe
(48, 145, 34), (48, 148, 34),-- Hamburguesa Veggie - Opci�n de Vegetales: Lechuga, Pepinillos
(48, 164, 39),              -- Hamburguesa Veggie - Condimento: Or�gano
(49, 19, 4), (49, 21, 4),   -- Combo Mega Burger - Bebida: Coca-Cola, Sprite
(49, 125, 27),              -- Combo Mega Burger - Presentaci�n: Para compartir
(50, 12, 3), (50, 9, 3),    -- Papas Fritas Grandes - Salsa: Ketchup, Tomate
(50, 162, 39),              -- Papas Fritas Grandes - Condimento: Sal

-- Men� 11: Vegetariano Verde
(51, 63, 13), (51, 59, 13), -- Ensalada Quinoa y Aguacate - Prote�na Extra: Tofu, Pollo
(51, 132, 30), (51, 133, 30),-- Ensalada Quinoa y Aguacate - Corte de Vegetales: Juliana, Dados
(51, 143, 33),              -- Ensalada Quinoa y Aguacate - Estilo de Salsa: Vinagreta
(52, 95, 22), (52, 96, 22), -- Wrap de Vegetales Sin Gluten - Guarnici�n Extra: Papas Fritas, Yuca Frita
(52, 135, 31),              -- Wrap de Vegetales Sin Gluten - M�todo de Cocci�n: Al vapor
(53, 34, 7), (53, 35, 7),   -- Bowl de Lentejas y Verduras - Nivel Picante: Suave, Medio
(53, 153, 36), (53, 154, 36),-- Bowl de Lentejas y Verduras - Tipo de Arroz: Arroz integral, Arroz salvaje
(54, 34, 7), (54, 35, 7),   -- Hummus con Vegetales Crudos - Nivel Picante: Suave, Medio
(54, 142, 33),              -- Hummus con Vegetales Crudos - Estilo de Salsa: Crema
(55, 67, 14), (55, 64, 14), -- Jugo Verde Detox - Endulzante: Miel, Az�car
(55, 100, 23), (55, 101, 23),-- Jugo Verde Detox - Fruta: Fresa, Mora

-- Men� 12: Helados Refrescantes
(56, 49, 10), (56, 50, 10), -- Copa de Helado de Vainilla - Toppings: Sirope de chocolate, Sirope de fresa
(56, 122, 27),              -- Copa de Helado de Vainilla - Presentaci�n: En plato
(57, 51, 10), (57, 48, 10), -- Malteada de Fresa - Toppings: Crema batida, Frutas frescas
(57, 73, 16), (57, 75, 16), -- Malteada de Fresa - Tipo de Leche: Leche entera, Leche de almendras
(57, 100, 23), (57, 101, 23),-- Malteada de Fresa - Fruta: Fresa, Mora
(58, 47, 10), (58, 48, 10), -- Banana Split - Toppings: Nueces, Frutas frescas
(58, 125, 27),              -- Banana Split - Presentaci�n: Para compartir
(59, 92, 21), (59, 91, 21), -- Cono de Chocolate - Tipo de Helado: Chocolate, Vainilla
(59, 124, 27),              -- Cono de Chocolate - Presentaci�n: Individual
(60, 44, 9), (60, 45, 9),   -- Duraznos con Crema - Crema: Con crema, Sin crema
(60, 122, 27),              -- Duraznos con Crema - Presentaci�n: En plato

-- Men� 13: Pastas Italianas
(61, 36, 7), (61, 34, 7),   -- Spaghetti a la Carbonara - Nivel Picante: Picante, Suave
(61, 61, 13), (61, 60, 13), -- Spaghetti a la Carbonara - Prote�na Extra: Cerdo, Res
(61, 155, 37), (61, 157, 37),-- Spaghetti a la Carbonara - Tipo de Pasta: Spaghetti, Fettuccine
(62, 59, 13), (62, 60, 13), -- Lasagna Cl�sica - Prote�na Extra: Pollo, Res
(62, 136, 31),              -- Lasagna Cl�sica - M�todo de Cocci�n: Asado
(63, 9, 3), (63, 18, 3),    -- Ravioles de Ricotta y Espinaca - Salsa: Tomate, Blanca
(63, 158, 37),              -- Ravioles de Ricotta y Espinaca - Tipo de Pasta: Ravioles
(64, 36, 7), (64, 37, 7),   -- Penne Arrabiata - Nivel Picante: Picante, Muy picante
(64, 156, 37),              -- Penne Arrabiata - Tipo de Pasta: Penne
(65, 9, 3), (65, 14, 3),    -- Focaccia con Romero - Salsa: Tomate, Picante
(65, 127, 28),              -- Focaccia con Romero - Grado de Tostado: Medio

-- Men� 14: Arepas Aut�nticas
(66, 1, 1), (66, 2, 1),      -- Arepa Reina Pepiada - Tama�o: Mediano, Grande
(66, 82, 19), (66, 83, 19),  -- Arepa Reina Pepiada - Aguacate: Extra aguacate, Sin aguacate
(66, 107, 24),               -- Arepa Reina Pepiada - Relleno: Pollo
(66, 159, 38),               -- Arepa Reina Pepiada - Base: Pan
(67, 1, 1), (67, 2, 1),      -- Arepa Carne Mechada - Tama�o: Mediano, Grande
(67, 108, 24),               -- Arepa Carne Mechada - Relleno: Carne
(67, 159, 38),               -- Arepa Carne Mechada - Base: Pan
(68, 1, 1), (68, 2, 1),      -- Arepa con Queso Telita - Tama�o: Mediano, Grande
(68, 42, 8),                 -- Arepa con Queso Telita - Tipo de Queso: De mano
(68, 159, 38),               -- Arepa con Queso Telita - Base: Pan
(69, 10, 3), (69, 13, 3),    -- Mini Arepas Mixtas - Salsa: Mayonesa, Rosada
(69, 106, 24), (69, 107, 24),-- Mini Arepas Mixtas - Relleno: Queso, Pollo
(69, 149, 35), (69, 150, 35),-- Mini Arepas Mixtas - Cantidad: 1 unidad, 2 unidades
(70, 14, 3), (70, 9, 3),     -- Arepa Frita con Chicharr�n - Salsa: Picante, Tomate
(70, 137, 31),               -- Arepa Frita con Chicharr�n - M�todo de Cocci�n: Frito
(70, 159, 38),               -- Arepa Frita con Chicharr�n - Base: Pan

-- Men� 15: Pollos Asados Crunchy
(71, 31, 6), (71, 30, 6),   -- Pollo Asado Entero - Acompa�amiento: Papas, Ensalada
(71, 84, 20), (71, 85, 20), -- Pollo Asado Entero - Salsas: BBQ, Teriyaki
(71, 136, 31),              -- Pollo Asado Entero - M�todo de Cocci�n: Asado
(71, 141, 32),              -- Pollo Asado Entero - Guarnici�n Principal: Arroz blanco
(72, 29, 6), (72, 31, 6),   -- Medio Pollo Asado - Acompa�amiento: Arroz, Papas
(72, 136, 31),              -- Medio Pollo Asado - M�todo de Cocci�n: Asado
(72, 140, 32),              -- Medio Pollo Asado - Guarnici�n Principal: Pur� de papas
(73, 84, 20), (73, 88, 20), -- Papas R�sticas - Salsas: BBQ, Blanca
(73, 162, 39),              -- Papas R�sticas - Condimento: Sal
(74, 10, 3), (74, 9, 3),    -- Ensalada Coleslaw - Salsa: Mayonesa, Tomate
(74, 133, 30),              -- Ensalada Coleslaw - Corte de Vegetales: Dados
(75, 15, 3), (75, 18, 3),   -- Salsa de Ajo - Salsa: T�rtara, Blanca
(75, 142, 33),              -- Salsa de Ajo - Estilo de Salsa: Crema

-- Men� 16: Empanadas Criollas
(76, 9, 3), (76, 10, 3),   -- Empanada de Pollo - Salsa: Tomate, Mayonesa
(76, 107, 24),             -- Empanada de Pollo - Relleno: Pollo
(76, 137, 31),             -- Empanada de Pollo - M�todo de Cocci�n: Frito
(77, 9, 3), (77, 10, 3),   -- Empanada de Pabell�n - Salsa: Tomate, Mayonesa
(77, 108, 24),             -- Empanada de Pabell�n - Relleno: Carne
(77, 137, 31),             -- Empanada de Pabell�n - M�todo de Cocci�n: Frito
(78, 9, 3), (78, 10, 3),   -- Empanada de Queso - Salsa: Tomate, Mayonesa
(78, 106, 24),             -- Empanada de Queso - Relleno: Queso
(78, 137, 31),             -- Empanada de Queso - M�todo de Cocci�n: Frito
(79, 9, 3), (79, 10, 3),   -- Empanada de Caz�n - Salsa: Tomate, Mayonesa
(79, 137, 31),             -- Empanada de Caz�n - M�todo de Cocci�n: Frito
(80, 9, 3), (80, 10, 3),   -- Empanada de Pl�tano y Queso - Salsa: Tomate, Mayonesa
(80, 110, 24),             -- Empanada de Pl�tano y Queso - Relleno: Dulce de Leche (puede ser mixto)
(80, 137, 31),             -- Empanada de Pl�tano y Queso - M�todo de Cocci�n: Frito

-- Men� 17: Churros y Reposter�a
(81, 46, 10), (81, 49, 10), -- Churros Cl�sicos - Toppings: Chocolate chips, Sirope de chocolate
(81, 149, 35), (81, 150, 35),-- Churros Cl�sicos - Cantidad: 1 unidad, 2 unidades
(82, 46, 10), (82, 51, 10), -- Churros con Chocolate - Toppings: Chocolate chips, Crema batida
(82, 80, 18), (82, 81, 18), -- Churros con Chocolate - Az�car: Con az�car, Sin az�car
(82, 131, 29),              -- Churros con Chocolate - Bebida Caliente: Chocolate
(83, 47, 10), (83, 50, 10), -- Porras - Toppings: Nueces, Sirope de fresa
(83, 149, 35), (83, 150, 35),-- Porras - Cantidad: 1 unidad, 2 unidades
(84, 80, 18), (84, 81, 18), -- Chocolate Caliente Espa�ol - Az�car: Con az�car, Sin az�car
(84, 131, 29),              -- Chocolate Caliente Espa�ol - Bebida Caliente: Chocolate
(85, 110, 24),              -- Churros Rellenos de Dulce de Leche - Relleno: Dulce de Leche
(85, 149, 35), (85, 150, 35),-- Churros Rellenos de Dulce de Leche - Cantidad: 1 unidad, 2 unidades

-- Men� 18: Cebicher�a Peruana
(86, 36, 7), (86, 34, 7),   -- Ceviche Cl�sico de Pescado - Nivel Picante: Picante, Suave
(86, 96, 22), (86, 97, 22), -- Ceviche Cl�sico de Pescado - Guarnici�n Extra: Papas Fritas, Tostones
(86, 132, 30), (86, 133, 30),-- Ceviche Cl�sico de Pescado - Corte de Vegetales: Juliana, Dados
(86, 135, 31),              -- Ceviche Cl�sico de Pescado - M�todo de Cocci�n: Al vapor (por marinado)
(87, 36, 7), (87, 37, 7),   -- Ceviche Mixto - Nivel Picante: Picante, Muy picante
(87, 98, 22), (87, 99, 22), -- Ceviche Mixto - Guarnici�n Extra: Tostones, Ensalada Mixta
(87, 134, 30),              -- Ceviche Mixto - Corte de Vegetales: Rodajas
(88, 97, 22), (88, 98, 22), -- Causa Lime�a de Pollo - Guarnici�n Extra: Tostones, Ensalada Mixta
(88, 140, 32),              -- Causa Lime�a de Pollo - Guarnici�n Principal: Pur� de papas
(89, 36, 7), (89, 35, 7),   -- Arroz con Mariscos - Nivel Picante: Picante, Medio
(89, 152, 36), (89, 154, 36),-- Arroz con Mariscos - Tipo de Arroz: Arroz blanco, Arroz salvaje
(90, 34, 7), (90, 35, 7),   -- Tiradito de Pulpo al Olivo - Nivel Picante: Suave, Medio
(90, 134, 30),              -- Tiradito de Pulpo al Olivo - Corte de Vegetales: Rodajas

-- Men� 19: Kebab �rabe
(91, 36, 7), (91, 34, 7),   -- Shawarma de Pollo - Nivel Picante: Picante, Suave
(91, 88, 20), (91, 87, 20), -- Shawarma de Pollo - Salsas: Blanca, Agria
(91, 70, 15), (91, 71, 15), -- Shawarma de Pollo - Tipo de Pan: Pan �rabe, Pan de pita
(91, 145, 34), (91, 147, 34),-- Shawarma de Pollo - Opci�n de Vegetales: Lechuga, Cebolla
(92, 36, 7), (92, 34, 7),   -- Shawarma de Carne - Nivel Picante: Picante, Suave
(92, 88, 20), (92, 87, 20), -- Shawarma de Carne - Salsas: Blanca, Agria
(92, 70, 15), (92, 71, 15), -- Shawarma de Carne - Tipo de Pan: Pan �rabe, Pan de pita
(92, 146, 34), (92, 147, 34),-- Shawarma de Carne - Opci�n de Vegetales: Tomate, Cebolla
(93, 88, 20), (93, 87, 20), -- Falafel - Salsas: Blanca, Agria
(93, 137, 31),              -- Falafel - M�todo de Cocci�n: Frito
(94, 36, 7), (94, 34, 7),   -- Kebab de Cordero - Nivel Picante: Picante, Suave
(94, 116, 25),              -- Kebab de Cordero - Corte de Carne: Asado de Tira
(95, 88, 20), (95, 89, 20), -- Hummus con Pan Pita - Salsas: Blanca, Guasacaca
(95, 159, 38), (95, 160, 38),-- Hummus con Pan Pita - Base: Pan, Arroz

-- Men� 20: Comida Cubana Sabor
(96, 29, 6), (96, 32, 6),   -- Ropa Vieja con Arroz - Acompa�amiento: Arroz, Tajadas
(96, 141, 32),              -- Ropa Vieja con Arroz - Guarnici�n Principal: Arroz blanco
(96, 152, 36),              -- Ropa Vieja con Arroz - Tipo de Arroz: Arroz blanco
(97, 29, 6), (97, 32, 6),   -- Moros y Cristianos - Acompa�amiento: Arroz, Tajadas
(97, 152, 36), (97, 153, 36),-- Moros y Cristianos - Tipo de Arroz: Arroz blanco, Arroz integral
(98, 68, 15), (98, 69, 15), -- S�ndwich Cubano - Tipo de Pan: Pan de hamburguesa, Pan de perro
(98, 5, 2), (98, 7, 2),     -- S�ndwich Cubano - Adicionales: Papas fritas, Tocino
(98, 163, 39),              -- S�ndwich Cubano - Condimento: Pimienta
(99, 13, 3), (99, 14, 3),   -- Tostones con Mojo - Salsa: Rosada, Picante
(99, 137, 31),              -- Tostones con Mojo - M�todo de Cocci�n: Frito
(100, 34, 7), (100, 35, 7), -- Mojito Cl�sico - Nivel Picante: Suave, Medio
(100, 122, 27),             -- Mojito Cl�sico - Presentaci�n: En plato

-- Men� 21: Ensaladas Fit
(101, 59, 13), (101, 62, 13),-- Ensalada C�sar con Pollo - Prote�na Extra: Pollo, Camarones
(101, 143, 33), (101, 144, 33),-- Ensalada C�sar con Pollo - Estilo de Salsa: Vinagreta, Reducci�n
(101, 132, 30), (101, 133, 30),-- Ensalada C�sar con Pollo - Corte de Vegetales: Juliana, Dados
(102, 59, 13), (102, 63, 13),-- Ensalada Griega - Prote�na Extra: Pollo, Tofu
(102, 143, 33), (102, 142, 33),-- Ensalada Griega - Estilo de Salsa: Vinagreta, Crema
(102, 134, 30),              -- Ensalada Griega - Corte de Vegetales: Rodajas
(103, 59, 13), (103, 60, 13),-- Bowl de Salm�n y Quinoa - Prote�na Extra: Pollo, Res
(103, 99, 22), (103, 98, 22),-- Bowl de Salm�n y Quinoa - Guarnici�n Extra: Ensalada Mixta, Tostones
(103, 153, 36), (103, 154, 36),-- Bowl de Salm�n y Quinoa - Tipo de Arroz: Arroz integral, Arroz salvaje
(104, 34, 7), (104, 35, 7), -- Aderezo Bals�mico - Nivel Picante: Suave, Medio
(104, 143, 33), (104, 144, 33),-- Aderezo Bals�mico - Estilo de Salsa: Vinagreta, Reducci�n
(105, 47, 10), (105, 48, 10),-- Mix de Semillas - Toppings: Nueces, Frutas frescas
(105, 162, 39), (105, 163, 39),-- Mix de Semillas - Condimento: Sal, Pimienta

-- Men� 22: Tortas y Dulces
(106, 44, 9), (106, 45, 9), -- Torta Selva Negra - Crema: Con crema, Sin crema
(106, 122, 27),             -- Torta Selva Negra - Presentaci�n: En plato
(107, 44, 9), (107, 45, 9), -- Torta de Zanahoria - Crema: Con crema, Sin crema
(107, 122, 27),             -- Torta de Zanahoria - Presentaci�n: En plato
(108, 48, 10), (108, 49, 10),-- Cheesecake de Frutos Rojos - Toppings: Frutas frescas, Sirope de chocolate
(108, 122, 27),             -- Cheesecake de Frutos Rojos - Presentaci�n: En plato
(108, 56, 12), (108, 57, 12),-- Cheesecake de Frutos Rojos - Cobertura: Crema batida, Merengue
(109, 91, 21), (109, 92, 21),-- Brownie con Helado - Tipo de Helado: Vainilla, Chocolate
(109, 122, 27),             -- Brownie con Helado - Presentaci�n: En plato
(110, 52, 11), (110, 53, 11),-- Cupcake de Vainilla - Glaseado: Chocolate, Vainilla
(110, 124, 27),             -- Cupcake de Vainilla - Presentaci�n: Individual

-- Men� 23: Cafeter�a La Esquina
(111, 46, 10), (111, 49, 10),-- Tostada Francesa - Toppings: Chocolate chips, Sirope de chocolate
(111, 127, 28), (111, 128, 28),-- Tostada Francesa - Grado de Tostado: Medio, Oscuro
(111, 122, 27),             -- Tostada Francesa - Presentaci�n: En plato
(112, 38, 8), (112, 40, 8), -- Omelette de Queso y Jam�n - Tipo de Queso: Cheddar, Blanco
(112, 136, 31),             -- Omelette de Queso y Jam�n - M�todo de Cocci�n: Asado
(113, 48, 10), (113, 51, 10),-- Panqueques con Frutas - Toppings: Frutas frescas, Crema batida
(113, 100, 23), (113, 101, 23),-- Panqueques con Frutas - Fruta: Fresa, Mora
(113, 122, 27),             -- Panqueques con Frutas - Presentaci�n: En plato
(114, 73, 16), (114, 75, 16),-- Capuccino - Tipo de Leche: Leche entera, Leche de almendras
(114, 120, 26),             -- Capuccino - Tipo de Caf�: Capuccino
(114, 64, 14), (114, 65, 14),-- Capuccino - Endulzante: Az�car, Splenda
(115, 68, 15), (115, 72, 15),-- S�ndwich de Croissant - Tipo de Pan: Pan de hamburguesa, Baguette
(115, 122, 27),             -- S�ndwich de Croissant - Presentaci�n: En plato

-- Men� 24: Desayunos Criollos
(116, 77, 17), (116, 78, 17),-- Arepa con Perico - Huevo: Frito, Revuelto
(116, 106, 24), (116, 108, 24),-- Arepa con Perico - Relleno: Queso, Carne
(116, 159, 38),             -- Arepa con Perico - Base: Pan
(117, 42, 8), (117, 40, 8), -- Cachapa con Queso de Mano - Tipo de Queso: De mano, Blanco
(117, 136, 31), (117, 138, 31),-- Cachapa con Queso de Mano - M�todo de Cocci�n: Asado, A la parrilla
(117, 159, 38),             -- Cachapa con Queso de Mano - Base: Pan
(118, 108, 24), (118, 109, 24),-- Empanada de Carne Mechada - Relleno: Carne, Mixto
(118, 137, 31),             -- Empanada de Carne Mechada - M�todo de Cocci�n: Frito
(118, 149, 35), (118, 150, 35),-- Empanada de Carne Mechada - Cantidad: 1 unidad, 2 unidades
(119, 64, 14), (119, 65, 14),-- Jugo de Papel�n con Lim�n - Endulzante: Az�car, Splenda
(119, 123, 27),             -- Jugo de Papel�n con Lim�n - Presentaci�n: Para llevar
(120, 106, 24), (120, 109, 24),-- Teque��n - Relleno: Queso, Mixto
(120, 149, 35), (120, 150, 35);-- Teque��n - Cantidad: 1 unidad, 2 unidades

INSERT INTO ClienteRepartidor (idCliente, idRepartidor, fecha, puntaje, comentario) VALUES
(1, 1, '2024-03-01 08:00:00', 5, 'Excelente servicio, muy r�pido.'),
(2, 2, '2024-03-01 08:10:00', 4, 'Entrega puntual y sin problemas.'),
(3, 3, '2024-03-01 08:20:00', 3, 'La entrega tard� un poco m�s de lo esperado.'),
(4, 4, '2024-03-01 08:30:00', 5, 'Repartidor muy amable y eficiente.'),
(5, 5, '2024-03-01 08:40:00', 2, 'No fue muy cuidadoso con el paquete.'),
(6, 6, '2024-03-01 08:50:00', 4, 'Todo correcto, buena comunicaci�n.'),
(7, 7, '2024-03-01 09:00:00', 5, 'R�pido como siempre, �gracias!'),
(8, 8, '2024-03-01 09:10:00', 3, 'Se confundi� de puerta al principio.'),
(9, 9, '2024-03-01 09:20:00', 5, 'Servicio impecable.'),
(10, 10, '2024-03-01 09:30:00', 4, 'Lleg� en el tiempo estimado.'),
(11, 11, '2024-03-01 09:40:00', 5, 'Muy profesional y educado.'),
(12, 12, '2024-03-01 09:50:00', 3, 'La comida lleg� tibia.'),
(13, 13, '2024-03-01 10:00:00', 4, 'Amable y atento al entregar.'),
(14, 14, '2024-03-01 10:10:00', 5, 'Sin quejas, todo perfecto.'),
(15, 15, '2024-03-01 10:20:00', 2, 'Demasiado lento en el tr�fico.'),
(16, 16, '2024-03-01 10:30:00', 4, 'Buena actitud y servicio.'),
(17, 17, '2024-03-01 10:40:00', 5, 'Mi repartidor favorito.'),
(18, 18, '2024-03-01 10:50:00', 3, 'Le cost� encontrar la direcci�n.'),
(19, 19, '2024-03-01 11:00:00', 5, 'Excelente, lo recomiendo.'),
(20, 20, '2024-03-01 11:10:00', 4, 'Lleg� a la hora justa.'),
(21, 1, '2024-03-02 08:00:00', 5, 'Muy r�pido a pesar de la distancia.'),
(22, 2, '2024-03-02 08:10:00', 4, 'Buen servicio, repetir�.'),
(23, 3, '2024-03-02 08:20:00', 3, 'Un poco desorganizado con el pedido.'),
(24, 4, '2024-03-02 08:30:00', 5, 'Siempre eficiente.'),
(25, 5, '2024-03-02 08:40:00', 2, 'Tuvo problemas con el pago.'),
(26, 6, '2024-03-02 08:50:00', 4, 'Todo en orden y a tiempo.'),
(27, 7, '2024-03-02 09:00:00', 5, 'Perfecto, ninguna queja.'),
(28, 8, '2024-03-02 09:10:00', 3, 'Tuve que darle indicaciones por tel�fono.'),
(29, 9, '2024-03-02 09:20:00', 5, 'Profesionalismo al 100%.'),
(30, 10, '2024-03-02 09:30:00', 4, 'Lleg� en buen estado.'),
(31, 11, '2024-03-02 09:40:00', 5, 'El mejor repartidor que he tenido.'),
(32, 12, '2024-03-02 09:50:00', 3, 'Se demor� un poco en la puerta.'),
(33, 13, '2024-03-02 10:00:00', 4, 'Amable y la entrega fue correcta.'),
(34, 14, '2024-03-02 10:10:00', 5, 'Excelente manejo del tiempo.'),
(35, 15, '2024-03-02 10:20:00', 2, 'El envase del pedido estaba ligeramente abierto.'),
(36, 16, '2024-03-02 10:30:00', 4, 'Buen servicio en general.'),
(37, 17, '2024-03-02 10:40:00', 5, 'Siempre supera las expectativas.'),
(38, 18, '2024-03-02 10:50:00', 3, 'Necesita un mejor GPS.'),
(39, 19, '2024-03-02 11:00:00', 5, 'Rapidez y eficiencia.'),
(40, 20, '2024-03-02 11:10:00', 4, 'Entreg� sin contratiempos.');

INSERT INTO Pedido (id, cantidad_items, costo_envio, nota, tiempo_entrega, total) VALUES
(1, 2, 3.50, 'sin nota', 30, 28.00),
(2, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(3, 3, 2.50, 'sin nota', 25, 40.00),
(4, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(5, 2, 3.80, 'sin nota', 40, 27.50),
(6, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(7, 3, 2.80, 'sin nota', 20, 35.00),
(8, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(9, 2, 4.20, 'sin nota', 30, 30.00),
(10, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(11, 2, 3.50, 'sin nota', 30, 28.00),
(12, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(13, 3, 2.50, 'sin nota', 25, 40.00),
(14, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(15, 2, 3.80, 'sin nota', 40, 27.50),
(16, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(17, 3, 2.80, 'sin nota', 20, 35.00),
(18, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(19, 2, 4.20, 'sin nota', 30, 30.00),
(20, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(21, 2, 3.50, 'sin nota', 30, 28.00),
(22, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(23, 3, 2.50, 'sin nota', 25, 40.00),
(24, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(25, 2, 3.80, 'sin nota', 40, 27.50),
(26, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(27, 3, 2.80, 'sin nota', 20, 35.00),
(28, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(29, 2, 4.20, 'sin nota', 30, 30.00),
(30, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(31, 2, 3.50, 'sin nota', 30, 28.00),
(32, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(33, 3, 2.50, 'sin nota', 25, 40.00),
(34, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(35, 2, 3.80, 'sin nota', 40, 27.50),
(36, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(37, 3, 2.80, 'sin nota', 20, 35.00),
(38, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(39, 2, 4.20, 'sin nota', 30, 30.00),
(40, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(41, 2, 3.50, 'sin nota', 30, 28.00),
(42, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(43, 3, 2.50, 'sin nota', 25, 40.00),
(44, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(45, 2, 3.80, 'sin nota', 40, 27.50),
(46, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(47, 3, 2.80, 'sin nota', 20, 35.00),
(48, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(49, 2, 4.20, 'sin nota', 30, 30.00),
(50, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(51, 2, 3.50, 'sin nota', 30, 28.00),
(52, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(53, 3, 2.50, 'sin nota', 25, 40.00),
(54, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(55, 2, 3.80, 'sin nota', 40, 27.50),
(56, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(57, 3, 2.80, 'sin nota', 20, 35.00),
(58, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(59, 2, 4.20, 'sin nota', 30, 30.00),
(60, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(61, 2, 3.50, 'sin nota', 30, 28.00),
(62, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(63, 3, 2.50, 'sin nota', 25, 40.00),
(64, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(65, 2, 3.80, 'sin nota', 40, 27.50),
(66, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(67, 3, 2.80, 'sin nota', 20, 35.00),
(68, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(69, 2, 4.20, 'sin nota', 30, 30.00),
(70, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(71, 2, 3.50, 'sin nota', 30, 28.00),
(72, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(73, 3, 2.50, 'sin nota', 25, 40.00),
(74, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(75, 2, 3.80, 'sin nota', 40, 27.50),
(76, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(77, 3, 2.80, 'sin nota', 20, 35.00),
(78, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(79, 2, 4.20, 'sin nota', 30, 30.00),
(80, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(81, 2, 3.50, 'sin nota', 30, 28.00),
(82, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(83, 3, 2.50, 'sin nota', 25, 40.00),
(84, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(85, 2, 3.80, 'sin nota', 40, 27.50),
(86, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(87, 3, 2.80, 'sin nota', 20, 35.00),
(88, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(89, 2, 4.20, 'sin nota', 30, 30.00),
(90, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(91, 2, 3.50, 'sin nota', 30, 28.00),
(92, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(93, 3, 2.50, 'sin nota', 25, 40.00),
(94, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(95, 2, 3.80, 'sin nota', 40, 27.50),
(96, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(97, 3, 2.80, 'sin nota', 20, 35.00),
(98, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(99, 2, 4.20, 'sin nota', 30, 30.00),
(100, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(101, 2, 3.50, 'sin nota', 30, 28.00),
(102, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(103, 3, 2.50, 'sin nota', 25, 40.00),
(104, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(105, 2, 3.80, 'sin nota', 40, 27.50),
(106, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(107, 3, 2.80, 'sin nota', 20, 35.00),
(108, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(109, 2, 4.20, 'sin nota', 30, 30.00),
(110, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(111, 2, 3.50, 'sin nota', 30, 28.00),
(112, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(113, 3, 2.50, 'sin nota', 25, 40.00),
(114, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(115, 2, 3.80, 'sin nota', 40, 27.50),
(116, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(117, 3, 2.80, 'sin nota', 20, 35.00),
(118, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(119, 2, 4.20, 'sin nota', 30, 30.00),
(120, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(121, 2, 3.50, 'sin nota', 30, 28.00),
(122, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(123, 3, 2.50, 'sin nota', 25, 40.00),
(124, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(125, 2, 3.80, 'sin nota', 40, 27.50),
(126, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(127, 3, 2.80, 'sin nota', 20, 35.00),
(128, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(129, 2, 4.20, 'sin nota', 30, 30.00),
(130, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(131, 2, 3.50, 'sin nota', 30, 28.00),
(132, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(133, 3, 2.50, 'sin nota', 25, 40.00),
(134, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(135, 2, 3.80, 'sin nota', 40, 27.50),
(136, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(137, 3, 2.80, 'sin nota', 20, 35.00),
(138, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(139, 2, 4.20, 'sin nota', 30, 30.00),
(140, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(141, 2, 3.50, 'sin nota', 30, 28.00),
(142, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(143, 3, 2.50, 'sin nota', 25, 40.00),
(144, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(145, 2, 3.80, 'sin nota', 40, 27.50),
(146, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(147, 3, 2.80, 'sin nota', 20, 35.00),
(148, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(149, 2, 4.20, 'sin nota', 30, 30.00),
(150, 1, 2.90, 'No tocar el timbre', 40, 9.50),
(151, 2, 3.50, 'sin nota', 30, 28.00),
(152, 1, 4.00, 'Entrega en puerta principal', 45, 14.50),
(153, 3, 2.50, 'sin nota', 25, 40.00),
(154, 1, 3.00, 'Dejar en la garita', 35, 11.00),
(155, 2, 3.80, 'sin nota', 40, 27.50),
(156, 1, 3.20, 'Llamar antes de llegar', 50, 16.00),
(157, 3, 2.80, 'sin nota', 20, 35.00),
(158, 1, 3.70, 'Entregar al vecino si no estoy', 55, 12.00),
(159, 2, 4.20, 'sin nota', 30, 30.00),
(160, 1, 2.90, 'No tocar el timbre', 40, 9.50)
;

INSERT INTO PedidoDetalle (id, cantidad, nota, total, idPedido, idPlato) VALUES
(1, 1, 'sin nota', 12.50, 1, 1),
(2, 1, 'sin nota', 10.00, 1, 2),
(3, 1, 'sin nota', 14.50, 2, 16),
(4, 1, 'sin nota', 15.00, 3, 3),
(5, 1, 'sin nota', 10.00, 3, 23),
(6, 1, 'sin nota', 8.00, 3, 4),
(7, 1, 'sin nota', 11.00, 4, 6),
(8, 1, 'sin nota', 9.50, 5, 5),
(9, 1, 'sin nota', 18.00, 5, 69),
(10, 1, 'sin nota', 16.00, 6, 10),
(11, 1, 'sin nota', 13.00, 7, 7),
(12, 1, 'sin nota', 12.00, 7, 19),
(13, 1, 'sin nota', 10.00, 7, 11),
(14, 1, 'sin nota', 10.50, 8, 18),
(15, 1, 'sin nota', 14.00, 9, 9),
(16, 1, 'sin nota', 16.00, 9, 29),
(17, 1, 'sin nota', 7.50, 10, 8),
(18, 1, 'sin nota', 12.50, 11, 1),
(19, 1, 'sin nota', 10.00, 11, 2),
(20, 1, 'sin nota', 14.50, 12, 16),
(21, 1, 'sin nota', 15.00, 13, 3),
(22, 1, 'sin nota', 10.00, 13, 23),
(23, 1, 'sin nota', 8.00, 13, 4),
(24, 1, 'sin nota', 11.00, 14, 6),
(25, 1, 'sin nota', 9.50, 15, 5),
(26, 1, 'sin nota', 18.00, 15, 69),
(27, 1, 'sin nota', 16.00, 16, 10),
(28, 1, 'sin nota', 13.00, 17, 7),
(29, 1, 'sin nota', 12.00, 17, 19),
(30, 1, 'sin nota', 10.00, 17, 11),
(31, 1, 'sin nota', 10.50, 18, 18),
(32, 1, 'sin nota', 14.00, 19, 9),
(33, 1, 'sin nota', 16.00, 19, 29),
(34, 1, 'sin nota', 7.50, 20, 8),
(35, 1, 'sin nota', 12.50, 21, 1),
(36, 1, 'sin nota', 10.00, 21, 2),
(37, 1, 'sin nota', 14.50, 22, 16),
(38, 1, 'sin nota', 15.00, 23, 3),
(39, 1, 'sin nota', 10.00, 23, 23),
(40, 1, 'sin nota', 8.00, 23, 4),
(41, 1, 'sin nota', 11.00, 24, 6),
(42, 1, 'sin nota', 9.50, 25, 5),
(43, 1, 'sin nota', 18.00, 25, 69),
(44, 1, 'sin nota', 16.00, 26, 10),
(45, 1, 'sin nota', 13.00, 27, 7),
(46, 1, 'sin nota', 12.00, 27, 19),
(47, 1, 'sin nota', 10.00, 27, 11),
(48, 1, 'sin nota', 10.50, 28, 18),
(49, 1, 'sin nota', 14.00, 29, 9),
(50, 1, 'sin nota', 16.00, 29, 29),
(51, 1, 'sin nota', 7.50, 30, 8),
(52, 1, 'sin nota', 12.50, 31, 1),
(53, 1, 'sin nota', 10.00, 31, 2),
(54, 1, 'sin nota', 14.50, 32, 16),
(55, 1, 'sin nota', 15.00, 33, 3),
(56, 1, 'sin nota', 10.00, 33, 23),
(57, 1, 'sin nota', 8.00, 33, 4),
(58, 1, 'sin nota', 11.00, 34, 6),
(59, 1, 'sin nota', 9.50, 35, 5),
(60, 1, 'sin nota', 18.00, 35, 69),
(61, 1, 'sin nota', 16.00, 36, 10),
(62, 1, 'sin nota', 13.00, 37, 7),
(63, 1, 'sin nota', 12.00, 37, 19),
(64, 1, 'sin nota', 10.00, 37, 11),
(65, 1, 'sin nota', 10.50, 38, 18),
(66, 1, 'sin nota', 14.00, 39, 9),
(67, 1, 'sin nota', 16.00, 39, 29),
(68, 1, 'sin nota', 7.50, 40, 8),
(69, 1, 'sin nota', 12.50, 41, 1),
(70, 1, 'sin nota', 10.00, 41, 2),
(71, 1, 'sin nota', 14.50, 42, 16),
(72, 1, 'sin nota', 15.00, 43, 3),
(73, 1, 'sin nota', 10.00, 43, 23),
(74, 1, 'sin nota', 8.00, 43, 4),
(75, 1, 'sin nota', 11.00, 44, 6),
(76, 1, 'sin nota', 9.50, 45, 5),
(77, 1, 'sin nota', 18.00, 45, 69),
(78, 1, 'sin nota', 16.00, 46, 10),
(79, 1, 'sin nota', 13.00, 47, 7),
(80, 1, 'sin nota', 12.00, 47, 19),
(81, 1, 'sin nota', 10.00, 47, 11),
(82, 1, 'sin nota', 10.50, 48, 18),
(83, 1, 'sin nota', 14.00, 49, 9),
(84, 1, 'sin nota', 16.00, 49, 29),
(85, 1, 'sin nota', 7.50, 50, 8),
(86, 1, 'sin nota', 12.50, 51, 1),
(87, 1, 'sin nota', 10.00, 51, 2),
(88, 1, 'sin nota', 14.50, 52, 16),
(89, 1, 'sin nota', 15.00, 53, 3),
(90, 1, 'sin nota', 10.00, 53, 23),
(91, 1, 'sin nota', 8.00, 53, 4),
(92, 1, 'sin nota', 11.00, 54, 6),
(93, 1, 'sin nota', 9.50, 55, 5),
(94, 1, 'sin nota', 18.00, 55, 69),
(95, 1, 'sin nota', 16.00, 56, 10),
(96, 1, 'sin nota', 13.00, 57, 7),
(97, 1, 'sin nota', 12.00, 57, 19),
(98, 1, 'sin nota', 10.00, 57, 11),
(99, 1, 'sin nota', 10.50, 58, 18),
(100, 1, 'sin nota', 14.00, 59, 9),
(101, 1, 'sin nota', 16.00, 59, 29),
(102, 1, 'sin nota', 7.50, 60, 8),
(103, 1, 'sin nota', 12.50, 61, 1),
(104, 1, 'sin nota', 10.00, 61, 2),
(105, 1, 'sin nota', 14.50, 62, 16),
(106, 1, 'sin nota', 15.00, 63, 3),
(107, 1, 'sin nota', 10.00, 63, 23),
(108, 1, 'sin nota', 8.00, 63, 4),
(109, 1, 'sin nota', 11.00, 64, 6),
(110, 1, 'sin nota', 9.50, 65, 5),
(111, 1, 'sin nota', 18.00, 65, 69),
(112, 1, 'sin nota', 16.00, 66, 10),
(113, 1, 'sin nota', 13.00, 67, 7),
(114, 1, 'sin nota', 12.00, 67, 19),
(115, 1, 'sin nota', 10.00, 67, 11),
(116, 1, 'sin nota', 10.50, 68, 18),
(117, 1, 'sin nota', 14.00, 69, 9),
(118, 1, 'sin nota', 16.00, 69, 29),
(119, 1, 'sin nota', 7.50, 70, 8),
(120, 1, 'sin nota', 12.50, 71, 1),
(121, 1, 'sin nota', 10.00, 71, 2),
(122, 1, 'sin nota', 14.50, 72, 16),
(123, 1, 'sin nota', 15.00, 73, 3),
(124, 1, 'sin nota', 10.00, 73, 23),
(125, 1, 'sin nota', 8.00, 73, 4),
(126, 1, 'sin nota', 11.00, 74, 6),
(127, 1, 'sin nota', 9.50, 75, 5),
(128, 1, 'sin nota', 18.00, 75, 69),
(129, 1, 'sin nota', 16.00, 76, 10),
(130, 1, 'sin nota', 13.00, 77, 7),
(131, 1, 'sin nota', 12.00, 77, 19),
(132, 1, 'sin nota', 10.00, 77, 11),
(133, 1, 'sin nota', 10.50, 78, 18),
(134, 1, 'sin nota', 14.00, 79, 9),
(135, 1, 'sin nota', 16.00, 79, 29),
(136, 1, 'sin nota', 7.50, 80, 8),
(137, 1, 'sin nota', 12.50, 81, 1),
(138, 1, 'sin nota', 10.00, 81, 2),
(139, 1, 'sin nota', 14.50, 82, 16),
(140, 1, 'sin nota', 15.00, 83, 3),
(141, 1, 'sin nota', 10.00, 83, 23),
(142, 1, 'sin nota', 8.00, 83, 4),
(143, 1, 'sin nota', 11.00, 84, 6),
(144, 1, 'sin nota', 9.50, 85, 5),
(145, 1, 'sin nota', 18.00, 85, 69),
(146, 1, 'sin nota', 16.00, 86, 10),
(147, 1, 'sin nota', 13.00, 87, 7),
(148, 1, 'sin nota', 12.00, 87, 19),
(149, 1, 'sin nota', 10.00, 87, 11),
(150, 1, 'sin nota', 10.50, 88, 18),
(151, 1, 'sin nota', 14.00, 89, 9),
(152, 1, 'sin nota', 16.00, 89, 29),
(153, 1, 'sin nota', 7.50, 90, 8),
(154, 1, 'sin nota', 12.50, 91, 1),
(155, 1, 'sin nota', 10.00, 91, 2),
(156, 1, 'sin nota', 14.50, 92, 16),
(157, 1, 'sin nota', 15.00, 93, 3),
(158, 1, 'sin nota', 10.00, 93, 23),
(159, 1, 'sin nota', 8.00, 93, 4),
(160, 1, 'sin nota', 11.00, 94, 6),
(161, 1, 'sin nota', 9.50, 95, 5),
(162, 1, 'sin nota', 18.00, 95, 69),
(163, 1, 'sin nota', 16.00, 96, 10),
(164, 1, 'sin nota', 13.00, 97, 7),
(165, 1, 'sin nota', 12.00, 97, 19),
(166, 1, 'sin nota', 10.00, 97, 11),
(167, 1, 'sin nota', 10.50, 98, 18),
(168, 1, 'sin nota', 14.00, 99, 9),
(169, 1, 'sin nota', 16.00, 99, 29),
(170, 1, 'sin nota', 7.50, 100, 8),
(171, 1, 'sin nota', 12.50, 101, 1),
(172, 1, 'sin nota', 10.00, 101, 2),
(173, 1, 'sin nota', 14.50, 102, 16),
(174, 1, 'sin nota', 15.00, 103, 3),
(175, 1, 'sin nota', 10.00, 103, 23),
(176, 1, 'sin nota', 8.00, 103, 4),
(177, 1, 'sin nota', 11.00, 104, 6),
(178, 1, 'sin nota', 9.50, 105, 5),
(179, 1, 'sin nota', 18.00, 105, 69),
(180, 1, 'sin nota', 16.00, 106, 10),
(181, 1, 'sin nota', 13.00, 107, 7),
(182, 1, 'sin nota', 12.00, 107, 19),
(183, 1, 'sin nota', 10.00, 107, 11),
(184, 1, 'sin nota', 10.50, 108, 18),
(185, 1, 'sin nota', 14.00, 109, 9),
(186, 1, 'sin nota', 16.00, 109, 29),
(187, 1, 'sin nota', 7.50, 110, 8),
(188, 1, 'sin nota', 12.50, 111, 1),
(189, 1, 'sin nota', 10.00, 111, 2),
(190, 1, 'sin nota', 14.50, 112, 16),
(191, 1, 'sin nota', 15.00, 113, 3),
(192, 1, 'sin nota', 10.00, 113, 23),
(193, 1, 'sin nota', 8.00, 113, 4),
(194, 1, 'sin nota', 11.00, 114, 6),
(195, 1, 'sin nota', 9.50, 115, 5),
(196, 1, 'sin nota', 18.00, 115, 69),
(197, 1, 'sin nota', 16.00, 116, 10),
(198, 1, 'sin nota', 13.00, 117, 7),
(199, 1, 'sin nota', 12.00, 117, 19),
(200, 1, 'sin nota', 10.00, 117, 11),
(201, 1, 'sin nota', 10.50, 118, 18),
(202, 1, 'sin nota', 14.00, 119, 9),
(203, 1, 'sin nota', 16.00, 119, 29),
(204, 1, 'sin nota', 7.50, 120, 8),
(205, 1, 'sin nota', 12.50, 121, 1),
(206, 1, 'sin nota', 10.00, 121, 2),
(207, 1, 'sin nota', 14.50, 122, 16),
(208, 1, 'sin nota', 15.00, 123, 3),
(209, 1, 'sin nota', 10.00, 123, 23),
(210, 1, 'sin nota', 8.00, 123, 4),
(211, 1, 'sin nota', 11.00, 124, 6),
(212, 1, 'sin nota', 9.50, 125, 5),
(213, 1, 'sin nota', 18.00, 125, 69),
(214, 1, 'sin nota', 16.00, 126, 10),
(215, 1, 'sin nota', 13.00, 127, 7),
(216, 1, 'sin nota', 12.00, 127, 19),
(217, 1, 'sin nota', 10.00, 127, 11),
(218, 1, 'sin nota', 10.50, 128, 18),
(219, 1, 'sin nota', 14.00, 129, 9),
(220, 1, 'sin nota', 16.00, 129, 29),
(221, 1, 'sin nota', 7.50, 130, 8),
(222, 1, 'sin nota', 12.50, 131, 1),
(223, 1, 'sin nota', 10.00, 131, 2),
(224, 1, 'sin nota', 14.50, 132, 16),
(225, 1, 'sin nota', 15.00, 133, 3),
(226, 1, 'sin nota', 10.00, 133, 23),
(227, 1, 'sin nota', 8.00, 133, 4),
(228, 1, 'sin nota', 11.00, 134, 6),
(229, 1, 'sin nota', 9.50, 135, 5),
(230, 1, 'sin nota', 18.00, 135, 69),
(231, 1, 'sin nota', 16.00, 136, 10),
(232, 1, 'sin nota', 13.00, 137, 7),
(233, 1, 'sin nota', 12.00, 137, 19),
(234, 1, 'sin nota', 10.00, 137, 11),
(235, 1, 'sin nota', 10.50, 138, 18),
(236, 1, 'sin nota', 14.00, 139, 9),
(237, 1, 'sin nota', 16.00, 139, 29),
(238, 1, 'sin nota', 7.50, 140, 8),
(239, 1, 'sin nota', 12.50, 141, 1),
(240, 1, 'sin nota', 10.00, 141, 2),
(241, 1, 'sin nota', 14.50, 142, 16),
(242, 1, 'sin nota', 15.00, 143, 3),
(243, 1, 'sin nota', 10.00, 143, 23),
(244, 1, 'sin nota', 8.00, 143, 4),
(245, 1, 'sin nota', 11.00, 144, 6),
(246, 1, 'sin nota', 9.50, 145, 5),
(247, 1, 'sin nota', 18.00, 145, 69),
(248, 1, 'sin nota', 16.00, 146, 10),
(249, 1, 'sin nota', 13.00, 147, 7),
(250, 1, 'sin nota', 12.00, 147, 19),
(251, 1, 'sin nota', 10.00, 147, 11),
(252, 1, 'sin nota', 10.50, 148, 18),
(253, 1, 'sin nota', 14.00, 149, 9),
(254, 1, 'sin nota', 16.00, 149, 29),
(255, 1, 'sin nota', 7.50, 150, 8),
(256, 1, 'sin nota', 12.50, 151, 1),
(257, 1, 'sin nota', 10.00, 151, 2),
(258, 1, 'sin nota', 14.50, 152, 16),
(259, 1, 'sin nota', 15.00, 153, 3),
(260, 1, 'sin nota', 10.00, 153, 23),
(261, 1, 'sin nota', 8.00, 153, 4),
(262, 1, 'sin nota', 11.00, 154, 6),
(263, 1, 'sin nota', 9.50, 155, 5),
(264, 1, 'sin nota', 18.00, 155, 69),
(265, 1, 'sin nota', 16.00, 156, 10),
(266, 1, 'sin nota', 13.00, 157, 7),
(267, 1, 'sin nota', 12.00, 157, 19),
(268, 1, 'sin nota', 10.00, 157, 11),
(269, 1, 'sin nota', 10.50, 158, 18),
(270, 1, 'sin nota', 14.00, 159, 9),
(271, 1, 'sin nota', 16.00, 159, 29),
(272, 1, 'sin nota', 7.50, 160, 8)
;

INSERT INTO PedidoDetalleOpcionValor (idPedidoDetalle, idOpcionValor, idOpcion) VALUES
(1, 1, 1),
(2, 3, 2),
(3, 43, 9),
(4, 9, 3),
(5, 106, 26),
(6, 13, 3),
(8, 21, 5),
(9, 149, 40),
(11, 29, 7),
(12, 83, 19),
(13, 31, 7),
(15, 43, 9),
(16, 113, 28),
(18, 1, 1),
(19, 3, 2),
(20, 43, 9),
(21, 9, 3),
(22, 106, 26),
(23, 13, 3),
(25, 21, 5),
(26, 149, 40),
(28, 29, 7),
(29, 83, 19),
(30, 31, 7),
(32, 43, 9),
(33, 113, 28),
(35, 1, 1),
(36, 3, 2),
(37, 43, 9),
(38, 9, 3),
(39, 106, 26),
(40, 13, 3),
(42, 21, 5),
(43, 149, 40),
(45, 29, 7),
(46, 83, 19),
(47, 31, 7),
(49, 43, 9),
(50, 113, 28),
(52, 1, 1),
(53, 3, 2),
(54, 43, 9),
(55, 9, 3),
(56, 106, 26),
(57, 13, 3),
(59, 21, 5),
(60, 149, 40),
(62, 29, 7),
(63, 83, 19),
(64, 31, 7),
(66, 43, 9),
(67, 113, 28),
(69, 1, 1),
(70, 3, 2),
(71, 43, 9),
(72, 9, 3),
(73, 106, 26),
(74, 13, 3),
(76, 21, 5),
(77, 149, 40),
(79, 29, 7),
(80, 83, 19),
(81, 31, 7),
(83, 43, 9),
(84, 113, 28),
(86, 1, 1),
(87, 3, 2),
(88, 43, 9),
(89, 9, 3),
(90, 106, 26),
(91, 13, 3),
(93, 21, 5),
(94, 149, 40),
(96, 29, 7),
(97, 83, 19),
(98, 31, 7),
(100, 43, 9),
(101, 113, 28),
(103, 1, 1),
(104, 3, 2),
(105, 43, 9),
(106, 9, 3),
(107, 106, 26),
(108, 13, 3),
(110, 21, 5),
(111, 149, 40),
(113, 29, 7),
(114, 83, 19),
(115, 31, 7),
(117, 43, 9),
(118, 113, 28),
(120, 1, 1),
(121, 3, 2),
(122, 43, 9),
(123, 9, 3),
(124, 106, 26),
(125, 13, 3),
(127, 21, 5),
(128, 149, 40),
(130, 29, 7),
(131, 83, 19),
(132, 31, 7),
(134, 43, 9),
(135, 113, 28),
(137, 1, 1),
(138, 3, 2),
(139, 43, 9),
(140, 9, 3),
(141, 106, 26),
(142, 13, 3),
(144, 21, 5),
(145, 149, 40),
(147, 29, 7),
(148, 83, 19),
(149, 31, 7),
(151, 43, 9),
(152, 113, 28),
(154, 1, 1),
(155, 3, 2),
(156, 43, 9),
(157, 9, 3),
(158, 106, 26),
(159, 13, 3),
(161, 21, 5),
(162, 149, 40),
(164, 29, 7),
(165, 83, 19),
(166, 31, 7),
(168, 43, 9),
(169, 113, 28),
(171, 1, 1),
(172, 3, 2),
(173, 43, 9),
(174, 9, 3),
(175, 106, 26),
(176, 13, 3),
(178, 21, 5),
(179, 149, 40),
(181, 29, 7),
(182, 83, 19),
(183, 31, 7),
(185, 43, 9),
(186, 113, 28),
(188, 1, 1),
(189, 3, 2),
(190, 43, 9),
(191, 9, 3),
(192, 106, 26),
(193, 13, 3),
(195, 21, 5),
(196, 149, 40),
(198, 29, 7),
(199, 83, 19),
(200, 31, 7),
(202, 43, 9),
(203, 113, 28),
(205, 1, 1),
(206, 3, 2),
(207, 43, 9),
(208, 9, 3),
(209, 106, 26),
(210, 13, 3),
(212, 21, 5),
(213, 149, 40),
(215, 29, 7),
(216, 83, 19),
(217, 31, 7),
(219, 43, 9),
(220, 113, 28),
(222, 1, 1),
(223, 3, 2),
(224, 43, 9),
(225, 9, 3),
(226, 106, 26),
(227, 13, 3),
(229, 21, 5),
(230, 149, 40),
(232, 29, 7),
(233, 83, 19),
(234, 31, 7),
(236, 43, 9),
(237, 113, 28),
(239, 1, 1),
(240, 3, 2),
(241, 43, 9),
(242, 9, 3),
(243, 106, 26),
(244, 13, 3),
(246, 21, 5),
(247, 149, 40),
(249, 29, 7),
(250, 83, 19),
(251, 31, 7),
(253, 43, 9),
(254, 113, 28),
(256, 1, 1),
(257, 3, 2),
(258, 43, 9),
(259, 9, 3),
(260, 106, 26),
(261, 13, 3),
(263, 21, 5),
(264, 149, 40),
(266, 29, 7),
(267, 83, 19),
(268, 31, 7),
(270, 43, 9),
(271, 113, 28)
;

INSERT INTO ClientePedido (idCliente, idPedido, fecha) VALUES
(1, 1, '2024-07-20'),
(2, 2, '2024-07-21'),
(3, 3, '2024-07-22'),
(4, 4, '2024-07-23'),
(5, 5, '2024-07-24'),
(6, 6, '2024-07-25'),
(7, 7, '2024-07-26'),
(8, 8, '2024-07-27'),
(9, 9, '2024-07-28'),
(10, 10, '2024-07-29'),
(11, 11, '2024-07-30'),
(12, 12, '2024-07-31'),
(13, 13, '2024-08-01'),
(14, 14, '2024-08-02'),
(15, 15, '2024-08-03'),
(16, 16, '2024-08-04'),
(17, 17, '2024-08-05'),
(18, 18, '2024-08-06'),
(19, 19, '2024-08-07'),
(20, 20, '2024-08-08'),
(21, 21, '2024-08-09'),
(22, 22, '2024-08-10'),
(23, 23, '2024-08-11'),
(24, 24, '2024-08-12'),
(25, 25, '2024-08-13'),
(26, 26, '2024-08-14'),
(27, 27, '2024-08-15'),
(28, 28, '2024-08-16'),
(29, 29, '2024-08-17'),
(30, 30, '2024-08-18'),
(31, 31, '2024-08-19'),
(32, 32, '2024-08-20'),
(33, 33, '2024-08-21'),
(34, 34, '2024-08-22'),
(35, 35, '2024-08-23'),
(36, 36, '2024-08-24'),
(37, 37, '2024-08-25'),
(38, 38, '2024-08-26'),
(39, 39, '2024-08-27'),
(40, 40, '2024-08-28'),
(1, 41, '2024-08-29'),
(2, 42, '2024-08-30'),
(3, 43, '2024-08-31'),
(4, 44, '2024-09-01'),
(5, 45, '2024-09-02'),
(6, 46, '2024-09-03'),
(7, 47, '2024-09-04'),
(8, 48, '2024-09-05'),
(9, 49, '2024-09-06'),
(10, 50, '2024-09-07'),
(11, 51, '2024-09-08'),
(12, 52, '2024-09-09'),
(13, 53, '2024-09-10'),
(14, 54, '2024-09-11'),
(15, 55, '2024-09-12'),
(16, 56, '2024-09-13'),
(17, 57, '2024-09-14'),
(18, 58, '2024-09-15'),
(19, 59, '2024-09-16'),
(20, 60, '2024-09-17'),
(21, 61, '2024-09-18'),
(22, 62, '2024-09-19'),
(23, 63, '2024-09-20'),
(24, 64, '2024-09-21'),
(25, 65, '2024-09-22'),
(26, 66, '2024-09-23'),
(27, 67, '2024-09-24'),
(28, 68, '2024-09-25'),
(29, 69, '2024-09-26'),
(30, 70, '2024-09-27'),
(31, 71, '2024-09-28'),
(32, 72, '2024-09-29'),
(33, 73, '2024-09-30'),
(34, 74, '2024-10-01'),
(35, 75, '2024-10-02'),
(36, 76, '2024-10-03'),
(37, 77, '2024-10-04'),
(38, 78, '2024-10-05'),
(39, 79, '2024-10-06'),
(40, 80, '2024-10-07'),
(1, 81, '2024-10-08'),
(2, 82, '2024-10-09'),
(3, 83, '2024-10-10'),
(4, 84, '2024-10-11'),
(5, 85, '2024-10-12'),
(6, 86, '2024-10-13'),
(7, 87, '2024-10-14'),
(8, 88, '2024-10-15'),
(9, 89, '2024-10-16'),
(10, 90, '2024-10-17'),
(11, 91, '2024-10-18'),
(12, 92, '2024-10-19'),
(13, 93, '2024-10-20'),
(14, 94, '2024-10-21'),
(15, 95, '2024-10-22'),
(16, 96, '2024-10-23'),
(17, 97, '2024-10-24'),
(18, 98, '2024-10-25'),
(19, 99, '2024-10-26'),
(20, 100, '2024-10-27'),
(21, 101, '2024-10-28'),
(22, 102, '2024-10-29'),
(23, 103, '2024-10-30'),
(24, 104, '2024-10-31'),
(25, 105, '2024-11-01'),
(26, 106, '2024-11-02'),
(27, 107, '2024-11-03'),
(28, 108, '2024-11-04'),
(29, 109, '2024-11-05'),
(30, 110, '2024-11-06'),
(31, 111, '2024-11-07'),
(32, 112, '2024-11-08'),
(33, 113, '2024-11-09'),
(34, 114, '2024-11-10'),
(35, 115, '2024-11-11'),
(36, 116, '2024-11-12'),
(37, 117, '2024-11-13'),
(38, 118, '2024-11-14'),
(39, 119, '2024-11-15'),
(40, 120, '2024-11-16'),
(1, 121, '2024-11-17'),
(2, 122, '2024-11-18'),
(3, 123, '2024-11-19'),
(4, 124, '2024-11-20'),
(5, 125, '2024-11-21'),
(6, 126, '2024-11-22'),
(7, 127, '2024-11-23'),
(8, 128, '2024-11-24'),
(9, 129, '2024-11-25'),
(10, 130, '2024-11-26'),
(11, 131, '2024-11-27'),
(12, 132, '2024-11-28'),
(13, 133, '2024-11-29'),
(14, 134, '2024-11-30'),
(15, 135, '2024-12-01'),
(16, 136, '2024-12-02'),
(17, 137, '2024-12-03'),
(18, 138, '2024-12-04'),
(19, 139, '2024-12-05'),
(20, 140, '2024-12-06'),
(21, 141, '2024-12-07'),
(22, 142, '2024-12-08'),
(23, 143, '2024-12-09'),
(24, 144, '2024-12-10'),
(25, 145, '2024-12-11'),
(26, 146, '2024-12-12'),
(27, 147, '2024-12-13'),
(28, 148, '2024-12-14'),
(29, 149, '2024-12-15'),
(30, 150, '2024-12-16'),
(31, 151, '2024-12-17'),
(32, 152, '2024-12-18'),
(33, 153, '2024-12-19'),
(34, 154, '2024-12-20'),
(35, 155, '2024-12-21'),
(36, 156, '2024-12-22'),
(37, 157, '2024-12-23'),
(38, 158, '2024-12-24'),
(39, 159, '2024-12-25'),
(40, 160, '2024-12-26')
;

INSERT INTO PedidoEstadoPedido (idPedido, idEstadoPedido, fecha_inicio) VALUES
(1, 1, '2024-07-20 10:00:00'),
(1, 2, '2024-07-20 10:05:00'),
(1, 3, '2024-07-20 10:15:00'),
(1, 4, '2024-07-20 10:35:00'),
(1, 5, '2024-07-20 10:37:00'),
(1, 6, '2024-07-20 11:07:00'),
(2, 1, '2024-07-21 11:00:00'),
(2, 2, '2024-07-21 11:05:00'),
(2, 3, '2024-07-21 11:15:00'),
(2, 4, '2024-07-21 11:35:00'),
(2, 5, '2024-07-21 11:37:00'),
(2, 6, '2024-07-21 12:22:00'),
(3, 1, '2024-07-22 12:00:00'),
(3, 2, '2024-07-22 12:05:00'),
(3, 3, '2024-07-22 12:15:00'),
(3, 4, '2024-07-22 12:35:00'),
(3, 5, '2024-07-22 12:37:00'),
(3, 6, '2024-07-22 13:02:00'),
(4, 1, '2024-07-23 13:00:00'),
(4, 2, '2024-07-23 13:05:00'),
(4, 3, '2024-07-23 13:15:00'),
(4, 4, '2024-07-23 13:35:00'),
(4, 5, '2024-07-23 13:37:00'),
(4, 6, '2024-07-23 14:12:00'),
(5, 1, '2024-07-24 14:00:00'),
(5, 2, '2024-07-24 14:05:00'),
(5, 3, '2024-07-24 14:15:00'),
(5, 4, '2024-07-24 14:35:00'),
(5, 5, '2024-07-24 14:37:00'),
(5, 6, '2024-07-24 15:17:00'),
(6, 1, '2024-07-25 15:00:00'),
(6, 2, '2024-07-25 15:05:00'),
(6, 3, '2024-07-25 15:15:00'),
(6, 4, '2024-07-25 15:35:00'),
(6, 5, '2024-07-25 15:37:00'),
(6, 6, '2024-07-25 16:27:00'),
(7, 1, '2024-07-26 16:00:00'),
(7, 2, '2024-07-26 16:05:00'),
(7, 3, '2024-07-26 16:15:00'),
(7, 4, '2024-07-26 16:35:00'),
(7, 5, '2024-07-26 16:37:00'),
(7, 6, '2024-07-26 16:57:00'),
(8, 1, '2024-07-27 17:00:00'),
(8, 2, '2024-07-27 17:05:00'),
(8, 3, '2024-07-27 17:15:00'),
(8, 4, '2024-07-27 17:35:00'),
(8, 5, '2024-07-27 17:37:00'),
(8, 6, '2024-07-27 18:32:00'),
(9, 1, '2024-07-28 10:00:00'),
(9, 2, '2024-07-28 10:05:00'),
(9, 3, '2024-07-28 10:15:00'),
(9, 4, '2024-07-28 10:35:00'),
(9, 5, '2024-07-28 10:37:00'),
(9, 6, '2024-07-28 11:07:00'),
(10, 1, '2024-07-29 11:00:00'),
(10, 2, '2024-07-29 11:05:00'),
(10, 3, '2024-07-29 11:15:00'),
(10, 4, '2024-07-29 11:35:00'),
(10, 5, '2024-07-29 11:37:00'),
(10, 6, '2024-07-29 12:17:00'),
(11, 1, '2024-07-30 12:00:00'),
(11, 2, '2024-07-30 12:05:00'),
(11, 3, '2024-07-30 12:15:00'),
(11, 4, '2024-07-30 12:35:00'),
(11, 5, '2024-07-30 12:37:00'),
(11, 6, '2024-07-30 13:07:00'),
(12, 1, '2024-07-31 13:00:00'),
(12, 2, '2024-07-31 13:05:00'),
(12, 3, '2024-07-31 13:15:00'),
(12, 4, '2024-07-31 13:35:00'),
(12, 5, '2024-07-31 13:37:00'),
(12, 6, '2024-07-31 14:22:00'),
(13, 1, '2024-08-01 14:00:00'),
(13, 2, '2024-08-01 14:05:00'),
(13, 3, '2024-08-01 14:15:00'),
(13, 4, '2024-08-01 14:35:00'),
(13, 5, '2024-08-01 14:37:00'),
(13, 6, '2024-08-01 15:02:00'),
(14, 1, '2024-08-02 15:00:00'),
(14, 2, '2024-08-02 15:05:00'),
(14, 3, '2024-08-02 15:15:00'),
(14, 4, '2024-08-02 15:35:00'),
(14, 5, '2024-08-02 15:37:00'),
(14, 6, '2024-08-02 16:12:00'),
(15, 1, '2024-08-03 16:00:00'),
(15, 2, '2024-08-03 16:05:00'),
(15, 3, '2024-08-03 16:15:00'),
(15, 4, '2024-08-03 16:35:00'),
(15, 5, '2024-08-03 16:37:00'),
(15, 6, '2024-08-03 17:17:00'),
(16, 1, '2024-08-04 17:00:00'),
(16, 2, '2024-08-04 17:05:00'),
(16, 3, '2024-08-04 17:15:00'),
(16, 4, '2024-08-04 17:35:00'),
(16, 5, '2024-08-04 17:37:00'),
(16, 6, '2024-08-04 18:27:00'),
(17, 1, '2024-08-05 10:00:00'),
(17, 2, '2024-08-05 10:05:00'),
(17, 3, '2024-08-05 10:15:00'),
(17, 4, '2024-08-05 10:35:00'),
(17, 5, '2024-08-05 10:37:00'),
(17, 6, '2024-08-05 11:02:00'),
(18, 1, '2024-08-06 11:00:00'),
(18, 2, '2024-08-06 11:05:00'),
(18, 3, '2024-08-06 11:15:00'),
(18, 4, '2024-08-06 11:35:00'),
(18, 5, '2024-08-06 11:37:00'),
(18, 6, '2024-08-06 12:12:00'),
(19, 1, '2024-08-07 12:00:00'),
(19, 2, '2024-08-07 12:05:00'),
(19, 3, '2024-08-07 12:15:00'),
(19, 4, '2024-08-07 12:35:00'),
(19, 5, '2024-08-07 12:37:00'),
(19, 6, '2024-08-07 13:07:00'),
(20, 1, '2024-08-08 13:00:00'),
(20, 2, '2024-08-08 13:05:00'),
(20, 3, '2024-08-08 13:15:00'),
(20, 4, '2024-08-08 13:35:00'),
(20, 5, '2024-08-08 13:37:00'),
(20, 6, '2024-08-08 14:17:00'),
(21, 1, '2024-08-09 14:00:00'),
(21, 2, '2024-08-09 14:05:00'),
(21, 3, '2024-08-09 14:15:00'),
(21, 4, '2024-08-09 14:35:00'),
(21, 5, '2024-08-09 14:37:00'),
(21, 6, '2024-08-09 15:07:00'),
(22, 1, '2024-08-10 15:00:00'),
(22, 2, '2024-08-10 15:05:00'),
(22, 3, '2024-08-10 15:15:00'),
(22, 4, '2024-08-10 15:35:00'),
(22, 5, '2024-08-10 15:37:00'),
(22, 6, '2024-08-10 16:22:00'),
(23, 1, '2024-08-11 16:00:00'),
(23, 2, '2024-08-11 16:05:00'),
(23, 3, '2024-08-11 16:15:00'),
(23, 4, '2024-08-11 16:35:00'),
(23, 5, '2024-08-11 16:37:00'),
(23, 6, '2024-08-11 17:02:00'),
(24, 1, '2024-08-12 17:00:00'),
(24, 2, '2024-08-12 17:05:00'),
(24, 3, '2024-08-12 17:15:00'),
(24, 4, '2024-08-12 17:35:00'),
(24, 5, '2024-08-12 17:37:00'),
(24, 6, '2024-08-12 18:12:00'),
(25, 1, '2024-08-13 10:00:00'),
(25, 2, '2024-08-13 10:05:00'),
(25, 3, '2024-08-13 10:15:00'),
(25, 4, '2024-08-13 10:35:00'),
(25, 5, '2024-08-13 10:37:00'),
(25, 6, '2024-08-13 11:17:00'),
(26, 1, '2024-08-14 11:00:00'),
(26, 2, '2024-08-14 11:05:00'),
(26, 3, '2024-08-14 11:15:00'),
(26, 4, '2024-08-14 11:35:00'),
(26, 5, '2024-08-14 11:37:00'),
(26, 6, '2024-08-14 12:27:00'),
(27, 1, '2024-08-15 12:00:00'),
(27, 2, '2024-08-15 12:05:00'),
(27, 3, '2024-08-15 12:15:00'),
(27, 4, '2024-08-15 12:35:00'),
(27, 5, '2024-08-15 12:37:00'),
(27, 6, '2024-08-15 13:02:00'),
(28, 1, '2024-08-16 13:00:00'),
(28, 2, '2024-08-16 13:05:00'),
(28, 3, '2024-08-16 13:15:00'),
(28, 4, '2024-08-16 13:35:00'),
(28, 5, '2024-08-16 13:37:00'),
(28, 6, '2024-08-16 14:12:00'),
(29, 1, '2024-08-17 14:00:00'),
(29, 2, '2024-08-17 14:05:00'),
(29, 3, '2024-08-17 14:15:00'),
(29, 4, '2024-08-17 14:35:00'),
(29, 5, '2024-08-17 14:37:00'),
(29, 6, '2024-08-17 15:07:00'),
(30, 1, '2024-08-18 15:00:00'),
(30, 2, '2024-08-18 15:05:00'),
(30, 3, '2024-08-18 15:15:00'),
(30, 4, '2024-08-18 15:35:00'),
(30, 5, '2024-08-18 15:37:00'),
(30, 6, '2024-08-18 16:17:00'),
(31, 1, '2024-08-19 16:00:00'),
(31, 2, '2024-08-19 16:05:00'),
(31, 3, '2024-08-19 16:15:00'),
(31, 4, '2024-08-19 16:35:00'),
(31, 5, '2024-08-19 16:37:00'),
(31, 6, '2024-08-19 17:07:00'),
(32, 1, '2024-08-20 17:00:00'),
(32, 2, '2024-08-20 17:05:00'),
(32, 3, '2024-08-20 17:15:00'),
(32, 4, '2024-08-20 17:35:00'),
(32, 5, '2024-08-20 17:37:00'),
(32, 6, '2024-08-20 18:22:00'),
(33, 1, '2024-08-21 10:00:00'),
(33, 2, '2024-08-21 10:05:00'),
(33, 3, '2024-08-21 10:15:00'),
(33, 4, '2024-08-21 10:35:00'),
(33, 5, '2024-08-21 10:37:00'),
(33, 6, '2024-08-21 11:02:00'),
(34, 1, '2024-08-22 11:00:00'),
(34, 2, '2024-08-22 11:05:00'),
(34, 3, '2024-08-22 11:15:00'),
(34, 4, '2024-08-22 11:35:00'),
(34, 5, '2024-08-22 11:37:00'),
(34, 6, '2024-08-22 12:12:00'),
(35, 1, '2024-08-23 12:00:00'),
(35, 2, '2024-08-23 12:05:00'),
(35, 3, '2024-08-23 12:15:00'),
(35, 4, '2024-08-23 12:35:00'),
(35, 5, '2024-08-23 12:37:00'),
(35, 6, '2024-08-23 13:17:00'),
(36, 1, '2024-08-24 13:00:00'),
(36, 2, '2024-08-24 13:05:00'),
(36, 3, '2024-08-24 13:15:00'),
(36, 4, '2024-08-24 13:35:00'),
(36, 5, '2024-08-24 13:37:00'),
(36, 6, '2024-08-24 14:27:00'),
(37, 1, '2024-08-25 14:00:00'),
(37, 2, '2024-08-25 14:05:00'),
(37, 3, '2024-08-25 14:15:00'),
(37, 4, '2024-08-25 14:35:00'),
(37, 5, '2024-08-25 14:37:00'),
(37, 6, '2024-08-25 15:02:00'),
(38, 1, '2024-08-26 15:00:00'),
(38, 2, '2024-08-26 15:05:00'),
(38, 3, '2024-08-26 15:15:00'),
(38, 4, '2024-08-26 15:35:00'),
(38, 5, '2024-08-26 15:37:00'),
(38, 6, '2024-08-26 16:12:00'),
(39, 1, '2024-08-27 16:00:00'),
(39, 2, '2024-08-27 16:05:00'),
(39, 3, '2024-08-27 16:15:00'),
(39, 4, '2024-08-27 16:35:00'),
(39, 5, '2024-08-27 16:37:00'),
(39, 6, '2024-08-27 17:07:00'),
(40, 1, '2024-08-28 17:00:00'),
(40, 2, '2024-08-28 17:05:00'),
(40, 3, '2024-08-28 17:15:00'),
(40, 4, '2024-08-28 17:35:00'),
(40, 5, '2024-08-28 17:37:00'),
(40, 6, '2024-08-28 18:17:00'),
(41, 1, '2024-08-29 10:00:00'),
(41, 2, '2024-08-29 10:05:00'),
(41, 3, '2024-08-29 10:15:00'),
(41, 4, '2024-08-29 10:35:00'),
(41, 5, '2024-08-29 10:37:00'),
(41, 6, '2024-08-29 11:07:00'),
(42, 1, '2024-08-30 11:00:00'),
(42, 2, '2024-08-30 11:05:00'),
(42, 3, '2024-08-30 11:15:00'),
(42, 4, '2024-08-30 11:35:00'),
(42, 5, '2024-08-30 11:37:00'),
(42, 6, '2024-08-30 12:22:00'),
(43, 1, '2024-08-31 12:00:00'),
(43, 2, '2024-08-31 12:05:00'),
(43, 3, '2024-08-31 12:15:00'),
(43, 4, '2024-08-31 12:35:00'),
(43, 5, '2024-08-31 12:37:00'),
(43, 6, '2024-08-31 13:02:00'),
(44, 1, '2024-09-01 13:00:00'),
(44, 2, '2024-09-01 13:05:00'),
(44, 3, '2024-09-01 13:15:00'),
(44, 4, '2024-09-01 13:35:00'),
(44, 5, '2024-09-01 13:37:00'),
(44, 6, '2024-09-01 14:12:00'),
(45, 1, '2024-09-02 14:00:00'),
(45, 2, '2024-09-02 14:05:00'),
(45, 3, '2024-09-02 14:15:00'),
(45, 4, '2024-09-02 14:35:00'),
(45, 5, '2024-09-02 14:37:00'),
(45, 6, '2024-09-02 15:17:00'),
(46, 1, '2024-09-03 15:00:00'),
(46, 2, '2024-09-03 15:05:00'),
(46, 3, '2024-09-03 15:15:00'),
(46, 4, '2024-09-03 15:35:00'),
(46, 5, '2024-09-03 15:37:00'),
(46, 6, '2024-09-03 16:27:00'),
(47, 1, '2024-09-04 16:00:00'),
(47, 2, '2024-09-04 16:05:00'),
(47, 3, '2024-09-04 16:15:00'),
(47, 4, '2024-09-04 16:35:00'),
(47, 5, '2024-09-04 16:37:00'),
(47, 6, '2024-09-04 17:02:00'),
(48, 1, '2024-09-05 17:00:00'),
(48, 2, '2024-09-05 17:05:00'),
(48, 3, '2024-09-05 17:15:00'),
(48, 4, '2024-09-05 17:35:00'),
(48, 5, '2024-09-05 17:37:00'),
(48, 6, '2024-09-05 18:32:00'),
(49, 1, '2024-09-06 10:00:00'),
(49, 2, '2024-09-06 10:05:00'),
(49, 3, '2024-09-06 10:15:00'),
(49, 4, '2024-09-06 10:35:00'),
(49, 5, '2024-09-06 10:37:00'),
(49, 6, '2024-09-06 11:07:00'),
(50, 1, '2024-09-07 11:00:00'),
(50, 2, '2024-09-07 11:05:00'),
(50, 3, '2024-09-07 11:15:00'),
(50, 4, '2024-09-07 11:35:00'),
(50, 5, '2024-09-07 11:37:00'),
(50, 6, '2024-09-07 12:17:00'),
(51, 1, '2024-09-08 12:00:00'),
(51, 2, '2024-09-08 12:05:00'),
(51, 3, '2024-09-08 12:15:00'),
(51, 4, '2024-09-08 12:35:00'),
(51, 5, '2024-09-08 12:37:00'),
(51, 6, '2024-09-08 13:07:00'),
(52, 1, '2024-09-09 13:00:00'),
(52, 2, '2024-09-09 13:05:00'),
(52, 3, '2024-09-09 13:15:00'),
(52, 4, '2024-09-09 13:35:00'),
(52, 5, '2024-09-09 13:37:00'),
(52, 6, '2024-09-09 14:22:00'),
(53, 1, '2024-09-10 14:00:00'),
(53, 2, '2024-09-10 14:05:00'),
(53, 3, '2024-09-10 14:15:00'),
(53, 4, '2024-09-10 14:35:00'),
(53, 5, '2024-09-10 14:37:00'),
(53, 6, '2024-09-10 15:02:00'),
(54, 1, '2024-09-11 15:00:00'),
(54, 2, '2024-09-11 15:05:00'),
(54, 3, '2024-09-11 15:15:00'),
(54, 4, '2024-09-11 15:35:00'),
(54, 5, '2024-09-11 15:37:00'),
(54, 6, '2024-09-11 16:12:00'),
(55, 1, '2024-09-12 16:00:00'),
(55, 2, '2024-09-12 16:05:00'),
(55, 3, '2024-09-12 16:15:00'),
(55, 4, '2024-09-12 16:35:00'),
(55, 5, '2024-09-12 16:37:00'),
(55, 6, '2024-09-12 17:17:00'),
(56, 1, '2024-09-13 17:00:00'),
(56, 2, '2024-09-13 17:05:00'),
(56, 3, '2024-09-13 17:15:00'),
(56, 4, '2024-09-13 17:35:00'),
(56, 5, '2024-09-13 17:37:00'),
(56, 6, '2024-09-13 18:27:00'),
(57, 1, '2024-09-14 10:00:00'),
(57, 2, '2024-09-14 10:05:00'),
(57, 3, '2024-09-14 10:15:00'),
(57, 4, '2024-09-14 10:35:00'),
(57, 5, '2024-09-14 10:37:00'),
(57, 6, '2024-09-14 11:02:00'),
(58, 1, '2024-09-15 11:00:00'),
(58, 2, '2024-09-15 11:05:00'),
(58, 3, '2024-09-15 11:15:00'),
(58, 4, '2024-09-15 11:35:00'),
(58, 5, '2024-09-15 11:37:00'),
(58, 6, '2024-09-15 12:12:00'),
(59, 1, '2024-09-16 12:00:00'),
(59, 2, '2024-09-16 12:05:00'),
(59, 3, '2024-09-16 12:15:00'),
(59, 4, '2024-09-16 12:35:00'),
(59, 5, '2024-09-16 12:37:00'),
(59, 6, '2024-09-16 13:07:00'),
(60, 1, '2024-09-17 13:00:00'),
(60, 2, '2024-09-17 13:05:00'),
(60, 3, '2024-09-17 13:15:00'),
(60, 4, '2024-09-17 13:35:00'),
(60, 5, '2024-09-17 13:37:00'),
(60, 6, '2024-09-17 14:17:00'),
(61, 1, '2024-09-18 14:00:00'),
(61, 2, '2024-09-18 14:05:00'),
(61, 3, '2024-09-18 14:15:00'),
(61, 4, '2024-09-18 14:35:00'),
(61, 5, '2024-09-18 14:37:00'),
(61, 6, '2024-09-18 15:07:00'),
(62, 1, '2024-09-19 15:00:00'),
(62, 2, '2024-09-19 15:05:00'),
(62, 3, '2024-09-19 15:15:00'),
(62, 4, '2024-09-19 15:35:00'),
(62, 5, '2024-09-19 15:37:00'),
(62, 6, '2024-09-19 16:22:00'),
(63, 1, '2024-09-20 16:00:00'),
(63, 2, '2024-09-20 16:05:00'),
(63, 3, '2024-09-20 16:15:00'),
(63, 4, '2024-09-20 16:35:00'),
(63, 5, '2024-09-20 16:37:00'),
(63, 6, '2024-09-20 17:02:00'),
(64, 1, '2024-09-21 17:00:00'),
(64, 2, '2024-09-21 17:05:00'),
(64, 3, '2024-09-21 17:15:00'),
(64, 4, '2024-09-21 17:35:00'),
(64, 5, '2024-09-21 17:37:00'),
(64, 6, '2024-09-21 18:12:00'),
(65, 1, '2024-09-22 10:00:00'),
(65, 2, '2024-09-22 10:05:00'),
(65, 3, '2024-09-22 10:15:00'),
(65, 4, '2024-09-22 10:35:00'),
(65, 5, '2024-09-22 10:37:00'),
(65, 6, '2024-09-22 11:17:00'),
(66, 1, '2024-09-23 11:00:00'),
(66, 2, '2024-09-23 11:05:00'),
(66, 3, '2024-09-23 11:15:00'),
(66, 4, '2024-09-23 11:35:00'),
(66, 5, '2024-09-23 11:37:00'),
(66, 6, '2024-09-23 12:27:00'),
(67, 1, '2024-09-24 12:00:00'),
(67, 2, '2024-09-24 12:05:00'),
(67, 3, '2024-09-24 12:15:00'),
(67, 4, '2024-09-24 12:35:00'),
(67, 5, '2024-09-24 12:37:00'),
(67, 6, '2024-09-24 13:02:00'),
(68, 1, '2024-09-25 13:00:00'),
(68, 2, '2024-09-25 13:05:00'),
(68, 3, '2024-09-25 13:15:00'),
(68, 4, '2024-09-25 13:35:00'),
(68, 5, '2024-09-25 13:37:00'),
(68, 6, '2024-09-25 14:12:00'),
(69, 1, '2024-09-26 14:00:00'),
(69, 2, '2024-09-26 14:05:00'),
(69, 3, '2024-09-26 14:15:00'),
(69, 4, '2024-09-26 14:35:00'),
(69, 5, '2024-09-26 14:37:00'),
(69, 6, '2024-09-26 15:07:00'),
(70, 1, '2024-09-27 15:00:00'),
(70, 2, '2024-09-27 15:05:00'),
(70, 3, '2024-09-27 15:15:00'),
(70, 4, '2024-09-27 15:35:00'),
(70, 5, '2024-09-27 15:37:00'),
(70, 6, '2024-09-27 16:17:00'),
(71, 1, '2024-09-28 16:00:00'),
(71, 2, '2024-09-28 16:05:00'),
(71, 3, '2024-09-28 16:15:00'),
(71, 4, '2024-09-28 16:35:00'),
(71, 5, '2024-09-28 16:37:00'),
(71, 6, '2024-09-28 17:07:00'),
(72, 1, '2024-09-29 17:00:00'),
(72, 2, '2024-09-29 17:05:00'),
(72, 3, '2024-09-29 17:15:00'),
(72, 4, '2024-09-29 17:35:00'),
(72, 5, '2024-09-29 17:37:00'),
(72, 6, '2024-09-29 18:22:00'),
(73, 1, '2024-09-30 10:00:00'),
(73, 2, '2024-09-30 10:05:00'),
(73, 3, '2024-09-30 10:15:00'),
(73, 4, '2024-09-30 10:35:00'),
(73, 5, '2024-09-30 10:37:00'),
(73, 6, '2024-09-30 11:02:00'),
(74, 1, '2024-10-01 11:00:00'),
(74, 2, '2024-10-01 11:05:00'),
(74, 3, '2024-10-01 11:15:00'),
(74, 4, '2024-10-01 11:35:00'),
(74, 5, '2024-10-01 11:37:00'),
(74, 6, '2024-10-01 12:12:00'),
(75, 1, '2024-10-02 12:00:00'),
(75, 2, '2024-10-02 12:05:00'),
(75, 3, '2024-10-02 12:15:00'),
(75, 4, '2024-10-02 12:35:00'),
(75, 5, '2024-10-02 12:37:00'),
(75, 6, '2024-10-02 13:17:00'),
(76, 1, '2024-10-03 13:00:00'),
(76, 2, '2024-10-03 13:05:00'),
(76, 3, '2024-10-03 13:15:00'),
(76, 4, '2024-10-03 13:35:00'),
(76, 5, '2024-10-03 13:37:00'),
(76, 6, '2024-10-03 14:27:00'),
(77, 1, '2024-10-04 14:00:00'),
(77, 2, '2024-10-04 14:05:00'),
(77, 3, '2024-10-04 14:15:00'),
(77, 4, '2024-10-04 14:35:00'),
(77, 5, '2024-10-04 14:37:00'),
(77, 6, '2024-10-04 15:02:00'),
(78, 1, '2024-10-05 15:00:00'),
(78, 2, '2024-10-05 15:05:00'),
(78, 3, '2024-10-05 15:15:00'),
(78, 4, '2024-10-05 15:35:00'),
(78, 5, '2024-10-05 15:37:00'),
(78, 6, '2024-10-05 16:12:00'),
(79, 1, '2024-10-06 16:00:00'),
(79, 2, '2024-10-06 16:05:00'),
(79, 3, '2024-10-06 16:15:00'),
(79, 4, '2024-10-06 16:35:00'),
(79, 5, '2024-10-06 16:37:00'),
(79, 6, '2024-10-06 17:07:00'),
(80, 1, '2024-10-07 17:00:00'),
(80, 2, '2024-10-07 17:05:00'),
(80, 3, '2024-10-07 17:15:00'),
(80, 4, '2024-10-07 17:35:00'),
(80, 5, '2024-10-07 17:37:00'),
(80, 6, '2024-10-07 18:17:00'),
(81, 1, '2024-10-08 10:00:00'),
(81, 2, '2024-10-08 10:05:00'),
(81, 3, '2024-10-08 10:15:00'),
(81, 4, '2024-10-08 10:35:00'),
(81, 5, '2024-10-08 10:37:00'),
(81, 6, '2024-10-08 11:07:00'),
(82, 1, '2024-10-09 11:00:00'),
(82, 2, '2024-10-09 11:05:00'),
(82, 3, '2024-10-09 11:15:00'),
(82, 4, '2024-10-09 11:35:00'),
(82, 5, '2024-10-09 11:37:00'),
(82, 6, '2024-10-09 12:22:00'),
(83, 1, '2024-10-10 12:00:00'),
(83, 2, '2024-10-10 12:05:00'),
(83, 3, '2024-10-10 12:15:00'),
(83, 4, '2024-10-10 12:35:00'),
(83, 5, '2024-10-10 12:37:00'),
(83, 6, '2024-10-10 13:02:00'),
(84, 1, '2024-10-11 13:00:00'),
(84, 2, '2024-10-11 13:05:00'),
(84, 3, '2024-10-11 13:15:00'),
(84, 4, '2024-10-11 13:35:00'),
(84, 5, '2024-10-11 13:37:00'),
(84, 6, '2024-10-11 14:12:00'),
(85, 1, '2024-10-12 14:00:00'),
(85, 2, '2024-10-12 14:05:00'),
(85, 3, '2024-10-12 14:15:00'),
(85, 4, '2024-10-12 14:35:00'),
(85, 5, '2024-10-12 14:37:00'),
(85, 6, '2024-10-12 15:17:00'),
(86, 1, '2024-10-13 15:00:00'),
(86, 2, '2024-10-13 15:05:00'),
(86, 3, '2024-10-13 15:15:00'),
(86, 4, '2024-10-13 15:35:00'),
(86, 5, '2024-10-13 15:37:00'),
(86, 6, '2024-10-13 16:27:00'),
(87, 1, '2024-10-14 16:00:00'),
(87, 2, '2024-10-14 16:05:00'),
(87, 3, '2024-10-14 16:15:00'),
(87, 4, '2024-10-14 16:35:00'),
(87, 5, '2024-10-14 16:37:00'),
(87, 6, '2024-10-14 17:02:00'),
(88, 1, '2024-10-15 17:00:00'),
(88, 2, '2024-10-15 17:05:00'),
(88, 3, '2024-10-15 17:15:00'),
(88, 4, '2024-10-15 17:35:00'),
(88, 5, '2024-10-15 17:37:00'),
(88, 6, '2024-10-15 18:32:00'),
(89, 1, '2024-10-16 10:00:00'),
(89, 2, '2024-10-16 10:05:00'),
(89, 3, '2024-10-16 10:15:00'),
(89, 4, '2024-10-16 10:35:00'),
(89, 5, '2024-10-16 10:37:00'),
(89, 6, '2024-10-16 11:07:00'),
(90, 1, '2024-10-17 11:00:00'),
(90, 2, '2024-10-17 11:05:00'),
(90, 3, '2024-10-17 11:15:00'),
(90, 4, '2024-10-17 11:35:00'),
(90, 5, '2024-10-17 11:37:00'),
(90, 6, '2024-10-17 12:17:00'),
(91, 1, '2024-10-18 12:00:00'),
(91, 2, '2024-10-18 12:05:00'),
(91, 3, '2024-10-18 12:15:00'),
(91, 4, '2024-10-18 12:35:00'),
(91, 5, '2024-10-18 12:37:00'),
(91, 6, '2024-10-18 13:07:00'),
(92, 1, '2024-10-19 13:00:00'),
(92, 2, '2024-10-19 13:05:00'),
(92, 3, '2024-10-19 13:15:00'),
(92, 4, '2024-10-19 13:35:00'),
(92, 5, '2024-10-19 13:37:00'),
(92, 6, '2024-10-19 14:22:00'),
(93, 1, '2024-10-20 14:00:00'),
(93, 2, '2024-10-20 14:05:00'),
(93, 3, '2024-10-20 14:15:00'),
(93, 4, '2024-10-20 14:35:00'),
(93, 5, '2024-10-20 14:37:00'),
(93, 6, '2024-10-20 15:02:00'),
(94, 1, '2024-10-21 15:00:00'),
(94, 2, '2024-10-21 15:05:00'),
(94, 3, '2024-10-21 15:15:00'),
(94, 4, '2024-10-21 15:35:00'),
(94, 5, '2024-10-21 15:37:00'),
(94, 6, '2024-10-21 16:12:00'),
(95, 1, '2024-10-22 16:00:00'),
(95, 2, '2024-10-22 16:05:00'),
(95, 3, '2024-10-22 16:15:00'),
(95, 4, '2024-10-22 16:35:00'),
(95, 5, '2024-10-22 16:37:00'),
(95, 6, '2024-10-22 17:17:00'),
(96, 1, '2024-10-23 17:00:00'),
(96, 2, '2024-10-23 17:05:00'),
(96, 3, '2024-10-23 17:15:00'),
(96, 4, '2024-10-23 17:35:00'),
(96, 5, '2024-10-23 17:37:00'),
(96, 6, '2024-10-23 18:27:00'),
(97, 1, '2024-10-24 10:00:00'),
(97, 2, '2024-10-24 10:05:00'),
(97, 3, '2024-10-24 10:15:00'),
(97, 4, '2024-10-24 10:35:00'),
(97, 5, '2024-10-24 10:37:00'),
(97, 6, '2024-10-24 11:02:00'),
(98, 1, '2024-10-25 11:00:00'),
(98, 2, '2024-10-25 11:05:00'),
(98, 3, '2024-10-25 11:15:00'),
(98, 4, '2024-10-25 11:35:00'),
(98, 5, '2024-10-25 11:37:00'),
(98, 6, '2024-10-25 12:12:00'),
(99, 1, '2024-10-26 12:00:00'),
(99, 2, '2024-10-26 12:05:00'),
(99, 3, '2024-10-26 12:15:00'),
(99, 4, '2024-10-26 12:35:00'),
(99, 5, '2024-10-26 12:37:00'),
(99, 6, '2024-10-26 13:07:00'),
(100, 1, '2024-10-27 13:00:00'),
(100, 2, '2024-10-27 13:05:00'),
(100, 3, '2024-10-27 13:15:00'),
(100, 4, '2024-10-27 13:35:00'),
(100, 5, '2024-10-27 13:37:00'),
(100, 6, '2024-10-27 14:17:00'),
(101, 1, '2024-10-28 14:00:00'),
(101, 2, '2024-10-28 14:05:00'),
(101, 3, '2024-10-28 14:15:00'),
(101, 4, '2024-10-28 14:35:00'),
(101, 5, '2024-10-28 14:37:00'),
(101, 6, '2024-10-28 15:07:00'),
(102, 1, '2024-10-29 15:00:00'),
(102, 2, '2024-10-29 15:05:00'),
(102, 3, '2024-10-29 15:15:00'),
(102, 4, '2024-10-29 15:35:00'),
(102, 5, '2024-10-29 15:37:00'),
(102, 6, '2024-10-29 16:22:00'),
(103, 1, '2024-10-30 16:00:00'),
(103, 2, '2024-10-30 16:05:00'),
(103, 3, '2024-10-30 16:15:00'),
(103, 4, '2024-10-30 16:35:00'),
(103, 5, '2024-10-30 16:37:00'),
(103, 6, '2024-10-30 17:02:00'),
(104, 1, '2024-10-31 17:00:00'),
(104, 2, '2024-10-31 17:05:00'),
(104, 3, '2024-10-31 17:15:00'),
(104, 4, '2024-10-31 17:35:00'),
(104, 5, '2024-10-31 17:37:00'),
(104, 6, '2024-10-31 18:12:00'),
(105, 1, '2024-11-01 10:00:00'),
(105, 2, '2024-11-01 10:05:00'),
(105, 3, '2024-11-01 10:15:00'),
(105, 4, '2024-11-01 10:35:00'),
(105, 5, '2024-11-01 10:37:00'),
(105, 6, '2024-11-01 11:17:00'),
(106, 1, '2024-11-02 11:00:00'),
(106, 2, '2024-11-02 11:05:00'),
(106, 3, '2024-11-02 11:15:00'),
(106, 4, '2024-11-02 11:35:00'),
(106, 5, '2024-11-02 11:37:00'),
(106, 6, '2024-11-02 12:27:00'),
(107, 1, '2024-11-03 12:00:00'),
(107, 2, '2024-11-03 12:05:00'),
(107, 3, '2024-11-03 12:15:00'),
(107, 4, '2024-11-03 12:35:00'),
(107, 5, '2024-11-03 12:37:00'),
(107, 6, '2024-11-03 13:02:00'),
(108, 1, '2024-11-04 13:00:00'),
(108, 2, '2024-11-04 13:05:00'),
(108, 3, '2024-11-04 13:15:00'),
(108, 4, '2024-11-04 13:35:00'),
(108, 5, '2024-11-04 13:37:00'),
(108, 6, '2024-11-04 14:12:00'),
(109, 1, '2024-11-05 14:00:00'),
(109, 2, '2024-11-05 14:05:00'),
(109, 3, '2024-11-05 14:15:00'),
(109, 4, '2024-11-05 14:35:00'),
(109, 5, '2024-11-05 14:37:00'),
(109, 6, '2024-11-05 15:07:00'),
(110, 1, '2024-11-06 15:00:00'),
(110, 2, '2024-11-06 15:05:00'),
(110, 3, '2024-11-06 15:15:00'),
(110, 4, '2024-11-06 15:35:00'),
(110, 5, '2024-11-06 15:37:00'),
(110, 6, '2024-11-06 16:17:00'),
(111, 1, '2024-11-07 16:00:00'),
(111, 2, '2024-11-07 16:05:00'),
(111, 3, '2024-11-07 16:15:00'),
(111, 4, '2024-11-07 16:35:00'),
(111, 5, '2024-11-07 16:37:00'),
(111, 6, '2024-11-07 17:07:00'),
(112, 1, '2024-11-08 17:00:00'),
(112, 2, '2024-11-08 17:05:00'),
(112, 3, '2024-11-08 17:15:00'),
(112, 4, '2024-11-08 17:35:00'),
(112, 5, '2024-11-08 17:37:00'),
(112, 6, '2024-11-08 18:22:00'),
(113, 1, '2024-11-09 10:00:00'),
(113, 2, '2024-11-09 10:05:00'),
(113, 3, '2024-11-09 10:15:00'),
(113, 4, '2024-11-09 10:35:00'),
(113, 5, '2024-11-09 10:37:00'),
(113, 6, '2024-11-09 11:02:00'),
(114, 1, '2024-11-10 11:00:00'),
(114, 2, '2024-11-10 11:05:00'),
(114, 3, '2024-11-10 11:15:00'),
(114, 4, '2024-11-10 11:35:00'),
(114, 5, '2024-11-10 11:37:00'),
(114, 6, '2024-11-10 12:12:00'),
(115, 1, '2024-11-11 12:00:00'),
(115, 2, '2024-11-11 12:05:00'),
(115, 3, '2024-11-11 12:15:00'),
(115, 4, '2024-11-11 12:35:00'),
(115, 5, '2024-11-11 12:37:00'),
(115, 6, '2024-11-11 13:17:00'),
(116, 1, '2024-11-12 13:00:00'),
(116, 2, '2024-11-12 13:05:00'),
(116, 3, '2024-11-12 13:15:00'),
(116, 4, '2024-11-12 13:35:00'),
(116, 5, '2024-11-12 13:37:00'),
(116, 6, '2024-11-12 14:27:00'),
(117, 1, '2024-11-13 14:00:00'),
(117, 2, '2024-11-13 14:05:00'),
(117, 3, '2024-11-13 14:15:00'),
(117, 4, '2024-11-13 14:35:00'),
(117, 5, '2024-11-13 14:37:00'),
(117, 6, '2024-11-13 15:02:00'),
(118, 1, '2024-11-14 15:00:00'),
(118, 2, '2024-11-14 15:05:00'),
(118, 3, '2024-11-14 15:15:00'),
(118, 4, '2024-11-14 15:35:00'),
(118, 5, '2024-11-14 15:37:00'),
(118, 6, '2024-11-14 16:12:00'),
(119, 1, '2024-11-15 16:00:00'),
(119, 2, '2024-11-15 16:05:00'),
(119, 3, '2024-11-15 16:15:00'),
(119, 4, '2024-11-15 16:35:00'),
(119, 5, '2024-11-15 16:37:00'),
(119, 6, '2024-11-15 17:07:00'),
(120, 1, '2024-11-16 17:00:00'),
(120, 2, '2024-11-16 17:05:00'),
(120, 3, '2024-11-16 17:15:00'),
(120, 4, '2024-11-16 17:35:00'),
(120, 5, '2024-11-16 17:37:00'),
(120, 6, '2024-11-16 18:17:00'),
(121, 1, '2024-11-17 10:00:00'),
(121, 2, '2024-11-17 10:05:00'),
(121, 3, '2024-11-17 10:15:00'),
(121, 4, '2024-11-17 10:35:00'),
(121, 5, '2024-11-17 10:37:00'),
(121, 6, '2024-11-17 11:07:00'),
(122, 1, '2024-11-18 11:00:00'),
(122, 2, '2024-11-18 11:05:00'),
(122, 3, '2024-11-18 11:15:00'),
(122, 4, '2024-11-18 11:35:00'),
(122, 5, '2024-11-18 11:37:00'),
(122, 6, '2024-11-18 12:22:00'),
(123, 1, '2024-11-19 12:00:00'),
(123, 2, '2024-11-19 12:05:00'),
(123, 3, '2024-11-19 12:15:00'),
(123, 4, '2024-11-19 12:35:00'),
(123, 5, '2024-11-19 12:37:00'),
(123, 6, '2024-11-19 13:02:00'),
(124, 1, '2024-11-20 13:00:00'),
(124, 2, '2024-11-20 13:05:00'),
(124, 3, '2024-11-20 13:15:00'),
(124, 4, '2024-11-20 13:35:00'),
(124, 5, '2024-11-20 13:37:00'),
(124, 6, '2024-11-20 14:12:00'),
(125, 1, '2024-11-21 14:00:00'),
(125, 2, '2024-11-21 14:05:00'),
(125, 3, '2024-11-21 14:15:00'),
(125, 4, '2024-11-21 14:35:00'),
(125, 5, '2024-11-21 14:37:00'),
(125, 6, '2024-11-21 15:17:00'),
(126, 1, '2024-11-22 15:00:00'),
(126, 2, '2024-11-22 15:05:00'),
(126, 3, '2024-11-22 15:15:00'),
(126, 4, '2024-11-22 15:35:00'),
(126, 5, '2024-11-22 15:37:00'),
(126, 6, '2024-11-22 16:27:00'),
(127, 1, '2024-11-23 16:00:00'),
(127, 2, '2024-11-23 16:05:00'),
(127, 3, '2024-11-23 16:15:00'),
(127, 4, '2024-11-23 16:35:00'),
(127, 5, '2024-11-23 16:37:00'),
(127, 6, '2024-11-23 17:02:00'),
(128, 1, '2024-11-24 17:00:00'),
(128, 2, '2024-11-24 17:05:00'),
(128, 3, '2024-11-24 17:15:00'),
(128, 4, '2024-11-24 17:35:00'),
(128, 5, '2024-11-24 17:37:00'),
(128, 6, '2024-11-24 18:32:00'),
(129, 1, '2024-11-25 10:00:00'),
(129, 2, '2024-11-25 10:05:00'),
(129, 3, '2024-11-25 10:15:00'),
(129, 4, '2024-11-25 10:35:00'),
(129, 5, '2024-11-25 10:37:00'),
(129, 6, '2024-11-25 11:07:00'),
(130, 1, '2024-11-26 11:00:00'),
(130, 2, '2024-11-26 11:05:00'),
(130, 3, '2024-11-26 11:15:00'),
(130, 4, '2024-11-26 11:35:00'),
(130, 5, '2024-11-26 11:37:00'),
(130, 6, '2024-11-26 12:17:00'),
(131, 1, '2024-11-27 12:00:00'),
(131, 2, '2024-11-27 12:05:00'),
(131, 3, '2024-11-27 12:15:00'),
(131, 4, '2024-11-27 12:35:00'),
(131, 5, '2024-11-27 12:37:00'),
(131, 6, '2024-11-27 13:07:00'),
(132, 1, '2024-11-28 13:00:00'),
(132, 2, '2024-11-28 13:05:00'),
(132, 3, '2024-11-28 13:15:00'),
(132, 4, '2024-11-28 13:35:00'),
(132, 5, '2024-11-28 13:37:00'),
(132, 6, '2024-11-28 14:22:00'),
(133, 1, '2024-11-29 14:00:00'),
(133, 2, '2024-11-29 14:05:00'),
(133, 3, '2024-11-29 14:15:00'),
(133, 4, '2024-11-29 14:35:00'),
(133, 5, '2024-11-29 14:37:00'),
(133, 6, '2024-11-29 15:02:00'),
(134, 1, '2024-11-30 15:00:00'),
(134, 2, '2024-11-30 15:05:00'),
(134, 3, '2024-11-30 15:15:00'),
(134, 4, '2024-11-30 15:35:00'),
(134, 5, '2024-11-30 15:37:00'),
(134, 6, '2024-11-30 16:12:00'),
(135, 1, '2024-12-01 16:00:00'),
(135, 2, '2024-12-01 16:05:00'),
(135, 3, '2024-12-01 16:15:00'),
(135, 4, '2024-12-01 16:35:00'),
(135, 5, '2024-12-01 16:37:00'),
(135, 6, '2024-12-01 17:17:00'),
(136, 1, '2024-12-02 17:00:00'),
(136, 2, '2024-12-02 17:05:00'),
(136, 3, '2024-12-02 17:15:00'),
(136, 4, '2024-12-02 17:35:00'),
(136, 5, '2024-12-02 17:37:00'),
(136, 6, '2024-12-02 18:27:00'),
(137, 1, '2024-12-03 10:00:00'),
(137, 2, '2024-12-03 10:05:00'),
(137, 3, '2024-12-03 10:15:00'),
(137, 4, '2024-12-03 10:35:00'),
(137, 5, '2024-12-03 10:37:00'),
(137, 6, '2024-12-03 11:02:00'),
(138, 1, '2024-12-04 11:00:00'),
(138, 2, '2024-12-04 11:05:00'),
(138, 3, '2024-12-04 11:15:00'),
(138, 4, '2024-12-04 11:35:00'),
(138, 5, '2024-12-04 11:37:00'),
(138, 6, '2024-12-04 12:12:00'),
(139, 1, '2024-12-05 12:00:00'),
(139, 2, '2024-12-05 12:05:00'),
(139, 3, '2024-12-05 12:15:00'),
(139, 4, '2024-12-05 12:35:00'),
(139, 5, '2024-12-05 12:37:00'),
(139, 6, '2024-12-05 13:07:00'),
(140, 1, '2024-12-06 13:00:00'),
(140, 2, '2024-12-06 13:05:00'),
(140, 3, '2024-12-06 13:15:00'),
(140, 4, '2024-12-06 13:35:00'),
(140, 5, '2024-12-06 13:37:00'),
(140, 6, '2024-12-06 14:17:00'),
(141, 1, '2024-12-07 14:00:00'),
(141, 2, '2024-12-07 14:05:00'),
(141, 3, '2024-12-07 14:15:00'),
(141, 4, '2024-12-07 14:35:00'),
(141, 5, '2024-12-07 14:37:00'),
(141, 6, '2024-12-07 15:07:00'),
(142, 1, '2024-12-08 15:00:00'),
(142, 2, '2024-12-08 15:05:00'),
(142, 3, '2024-12-08 15:15:00'),
(142, 4, '2024-12-08 15:35:00'),
(142, 5, '2024-12-08 15:37:00'),
(142, 6, '2024-12-08 16:22:00'),
(143, 1, '2024-12-09 16:00:00'),
(143, 2, '2024-12-09 16:05:00'),
(143, 3, '2024-12-09 16:15:00'),
(143, 4, '2024-12-09 16:35:00'),
(143, 5, '2024-12-09 16:37:00'),
(143, 6, '2024-12-09 17:02:00'),
(144, 1, '2024-12-10 17:00:00'),
(144, 2, '2024-12-10 17:05:00'),
(144, 3, '2024-12-10 17:15:00'),
(144, 4, '2024-12-10 17:35:00'),
(144, 5, '2024-12-10 17:37:00'),
(144, 6, '2024-12-10 18:12:00'),
(145, 1, '2024-12-11 10:00:00'),
(145, 2, '2024-12-11 10:05:00'),
(145, 3, '2024-12-11 10:15:00'),
(145, 4, '2024-12-11 10:35:00'),
(145, 5, '2024-12-11 10:37:00'),
(145, 6, '2024-12-11 11:17:00'),
(146, 1, '2024-12-12 11:00:00'),
(146, 2, '2024-12-12 11:05:00'),
(146, 3, '2024-12-12 11:15:00'),
(146, 4, '2024-12-12 11:35:00'),
(146, 5, '2024-12-12 11:37:00'),
(146, 6, '2024-12-12 12:27:00'),
(147, 1, '2024-12-13 12:00:00'),
(147, 2, '2024-12-13 12:05:00'),
(147, 3, '2024-12-13 12:15:00'),
(147, 4, '2024-12-13 12:35:00'),
(147, 5, '2024-12-13 12:37:00'),
(147, 6, '2024-12-13 13:02:00'),
(148, 1, '2024-12-14 13:00:00'),
(148, 2, '2024-12-14 13:05:00'),
(148, 3, '2024-12-14 13:15:00'),
(148, 4, '2024-12-14 13:35:00'),
(148, 5, '2024-12-14 13:37:00'),
(148, 6, '2024-12-14 14:12:00'),
(149, 1, '2024-12-15 14:00:00'),
(149, 2, '2024-12-15 14:05:00'),
(149, 3, '2024-12-15 14:15:00'),
(149, 4, '2024-12-15 14:35:00'),
(149, 5, '2024-12-15 14:37:00'),
(149, 6, '2024-12-15 15:07:00'),
(150, 1, '2024-12-16 15:00:00'),
(150, 2, '2024-12-16 15:05:00'),
(150, 3, '2024-12-16 15:15:00'),
(150, 4, '2024-12-16 15:35:00'),
(150, 5, '2024-12-16 15:37:00'),
(150, 6, '2024-12-16 16:17:00'),
(151, 1, '2024-12-17 16:00:00'),
(151, 2, '2024-12-17 16:05:00'),
(151, 3, '2024-12-17 16:15:00'),
(151, 4, '2024-12-17 16:35:00'),
(151, 5, '2024-12-17 16:37:00'),
(151, 6, '2024-12-17 17:07:00'),
(152, 1, '2024-12-18 17:00:00'),
(152, 2, '2024-12-18 17:05:00'),
(152, 3, '2024-12-18 17:15:00'),
(152, 4, '2024-12-18 17:35:00'),
(152, 5, '2024-12-18 17:37:00'),
(152, 6, '2024-12-18 18:22:00'),
(153, 1, '2024-12-19 10:00:00'),
(153, 2, '2024-12-19 10:05:00'),
(153, 3, '2024-12-19 10:15:00'),
(153, 4, '2024-12-19 10:35:00'),
(153, 5, '2024-12-19 10:37:00'),
(153, 6, '2024-12-19 11:02:00'),
(154, 1, '2024-12-20 11:00:00'),
(154, 2, '2024-12-20 11:05:00'),
(154, 3, '2024-12-20 11:15:00'),
(154, 4, '2024-12-20 11:35:00'),
(154, 5, '2024-12-20 11:37:00'),
(154, 6, '2024-12-20 12:12:00'),
(155, 1, '2024-12-21 12:00:00'),
(155, 2, '2024-12-21 12:05:00'),
(155, 3, '2024-12-21 12:15:00'),
(155, 4, '2024-12-21 12:35:00'),
(155, 5, '2024-12-21 12:37:00'),
(155, 6, '2024-12-21 13:17:00'),
(156, 1, '2024-12-22 13:00:00'),
(156, 2, '2024-12-22 13:05:00'),
(156, 3, '2024-12-22 13:15:00'),
(156, 4, '2024-12-22 13:35:00'),
(156, 5, '2024-12-22 13:37:00'),
(156, 6, '2024-12-22 14:27:00'),
(157, 1, '2024-12-23 14:00:00'),
(157, 2, '2024-12-23 14:05:00'),
(157, 3, '2024-12-23 14:15:00'),
(157, 4, '2024-12-23 14:35:00'),
(157, 5, '2024-12-23 14:37:00'),
(157, 6, '2024-12-23 15:02:00'),
(158, 1, '2024-12-24 15:00:00'),
(158, 2, '2024-12-24 15:05:00'),
(158, 3, '2024-12-24 15:15:00'),
(158, 4, '2024-12-24 15:35:00'),
(158, 5, '2024-12-24 15:37:00'),
(158, 6, '2024-12-24 16:12:00'),
(159, 1, '2024-12-25 16:00:00'),
(159, 2, '2024-12-25 16:05:00'),
(159, 3, '2024-12-25 16:15:00'),
(159, 4, '2024-12-25 16:35:00'),
(159, 5, '2024-12-25 16:37:00'),
(159, 6, '2024-12-25 17:07:00'),
(160, 1, '2024-12-26 17:00:00'),
(160, 2, '2024-12-26 17:05:00'),
(160, 3, '2024-12-26 17:15:00'),
(160, 4, '2024-12-26 17:35:00'),
(160, 5, '2024-12-26 17:37:00'),
(160, 6, '2024-12-26 18:17:00')
;

INSERT INTO RepartidorPedido (idRepartidor, idPedido, tiempo_entrega) VALUES
(1, 1, 30),
(2, 2, 45),
(3, 3, 25),
(4, 4, 35),
(5, 5, 40),
(6, 6, 50),
(7, 7, 20),
(8, 8, 55),
(9, 9, 30),
(10, 10, 40),
(11, 11, 30),
(12, 12, 45),
(13, 13, 25),
(14, 14, 35),
(15, 15, 40),
(16, 16, 50),
(17, 17, 20),
(18, 18, 55),
(19, 19, 30),
(20, 20, 40),
(1, 21, 30),
(2, 22, 45),
(3, 23, 25),
(4, 24, 35),
(5, 25, 40),
(6, 26, 50),
(7, 27, 20),
(8, 28, 55),
(9, 29, 30),
(10, 30, 40),
(11, 31, 30),
(12, 32, 45),
(13, 33, 25),
(14, 34, 35),
(15, 35, 40),
(16, 36, 50),
(17, 37, 20),
(18, 38, 55),
(19, 39, 30),
(20, 40, 40),
(1, 41, 30),
(2, 42, 45),
(3, 43, 25),
(4, 44, 35),
(5, 45, 40),
(6, 46, 50),
(7, 47, 20),
(8, 48, 55),
(9, 49, 30),
(10, 50, 40),
(11, 51, 30),
(12, 52, 45),
(13, 53, 25),
(14, 54, 35),
(15, 55, 40),
(16, 56, 50),
(17, 57, 20),
(18, 58, 55),
(19, 59, 30),
(20, 60, 40),
(1, 61, 30),
(2, 62, 45),
(3, 63, 25),
(4, 64, 35),
(5, 65, 40),
(6, 66, 50),
(7, 67, 20),
(8, 68, 55),
(9, 69, 30),
(10, 70, 40),
(11, 71, 30),
(12, 72, 45),
(13, 73, 25),
(14, 74, 35),
(15, 75, 40),
(16, 76, 50),
(17, 77, 20),
(18, 78, 55),
(19, 79, 30),
(20, 80, 40),
(1, 81, 30),
(2, 82, 45),
(3, 83, 25),
(4, 84, 35),
(5, 85, 40),
(6, 86, 50),
(7, 87, 20),
(8, 88, 55),
(9, 89, 30),
(10, 90, 40),
(11, 91, 30),
(12, 92, 45),
(13, 93, 25),
(14, 94, 35),
(15, 95, 40),
(16, 96, 50),
(17, 97, 20),
(18, 98, 55),
(19, 99, 30),
(20, 100, 40),
(1, 101, 30),
(2, 102, 45),
(3, 103, 25),
(4, 104, 35),
(5, 105, 40),
(6, 106, 50),
(7, 107, 20),
(8, 108, 55),
(9, 109, 30),
(10, 110, 40),
(11, 111, 30),
(12, 112, 45),
(13, 113, 25),
(14, 114, 35),
(15, 115, 40),
(16, 116, 50),
(17, 117, 20),
(18, 118, 55),
(19, 119, 30),
(20, 120, 40),
(1, 121, 30),
(2, 122, 45),
(3, 123, 25),
(4, 124, 35),
(5, 125, 40),
(6, 126, 50),
(7, 127, 20),
(8, 128, 55),
(9, 129, 30),
(10, 130, 40),
(11, 131, 30),
(12, 132, 45),
(13, 133, 25),
(14, 134, 35),
(15, 135, 40),
(16, 136, 50),
(17, 137, 20),
(18, 138, 55),
(19, 139, 30),
(20, 140, 40),
(1, 141, 30),
(2, 142, 45),
(3, 143, 25),
(4, 144, 35),
(5, 145, 40),
(6, 146, 50),
(7, 147, 20),
(8, 148, 55),
(9, 149, 30),
(10, 150, 40),
(11, 151, 30),
(12, 152, 45),
(13, 153, 25),
(14, 154, 35),
(15, 155, 40),
(16, 156, 50),
(17, 157, 20),
(18, 158, 55),
(19, 159, 30),
(20, 160, 40)
;

INSERT INTO Factura (numero, fecha_emision, sub_total, porcentajeIva, montoIva, monto_total, idPedido) VALUES
(1, '2024-07-20', 25.00, 16.00, 4.00, 29.00, 1),
(2, '2024-07-21', 10.50, 16.00, 1.68, 12.18, 2),
(3, '2024-07-22', 37.50, 16.00, 6.00, 43.50, 3),
(4, '2024-07-23', 8.00, 16.00, 1.28, 9.28, 4),
(5, '2024-07-24', 23.50, 16.00, 3.76, 27.26, 5),
(6, '2024-07-25', 13.00, 16.00, 2.08, 15.08, 6),
(7, '2024-07-26', 32.50, 16.00, 5.20, 37.70, 7),
(8, '2024-07-27', 8.50, 16.00, 1.36, 9.86, 8),
(9, '2024-07-28', 26.50, 16.00, 4.24, 30.74, 9),
(10, '2024-07-29', 7.50, 16.00, 1.20, 8.70, 10),
(11, '2024-07-30', 25.00, 16.00, 4.00, 29.00, 11),
(12, '2024-07-31', 10.50, 16.00, 1.68, 12.18, 12),
(13, '2024-08-01', 37.50, 16.00, 6.00, 43.50, 13),
(14, '2024-08-02', 8.00, 16.00, 1.28, 9.28, 14),
(15, '2024-08-03', 23.50, 16.00, 3.76, 27.26, 15),
(16, '2024-08-04', 13.00, 16.00, 2.08, 15.08, 16),
(17, '2024-08-05', 32.50, 16.00, 5.20, 37.70, 17),
(18, '2024-08-06', 8.50, 16.00, 1.36, 9.86, 18),
(19, '2024-08-07', 26.50, 16.00, 4.24, 30.74, 19),
(20, '2024-08-08', 7.50, 16.00, 1.20, 8.70, 20),
(21, '2024-08-09', 25.00, 16.00, 4.00, 29.00, 21),
(22, '2024-08-10', 10.50, 16.00, 1.68, 12.18, 22),
(23, '2024-08-11', 37.50, 16.00, 6.00, 43.50, 23),
(24, '2024-08-12', 8.00, 16.00, 1.28, 9.28, 24),
(25, '2024-08-13', 23.50, 16.00, 3.76, 27.26, 25),
(26, '2024-08-14', 13.00, 16.00, 2.08, 15.08, 26),
(27, '2024-08-15', 32.50, 16.00, 5.20, 37.70, 27),
(28, '2024-08-16', 8.50, 16.00, 1.36, 9.86, 28),
(29, '2024-08-17', 26.50, 16.00, 4.24, 30.74, 29),
(30, '2024-08-18', 7.50, 16.00, 1.20, 8.70, 30),
(31, '2024-08-19', 25.00, 16.00, 4.00, 29.00, 31),
(32, '2024-08-20', 10.50, 16.00, 1.68, 12.18, 32),
(33, '2024-08-21', 37.50, 16.00, 6.00, 43.50, 33),
(34, '2024-08-22', 8.00, 16.00, 1.28, 9.28, 34),
(35, '2024-08-23', 23.50, 16.00, 3.76, 27.26, 35),
(36, '2024-08-24', 13.00, 16.00, 2.08, 15.08, 36),
(37, '2024-08-25', 32.50, 16.00, 5.20, 37.70, 37),
(38, '2024-08-26', 8.50, 16.00, 1.36, 9.86, 38),
(39, '2024-08-27', 26.50, 16.00, 4.24, 30.74, 39),
(40, '2024-08-28', 7.50, 16.00, 1.20, 8.70, 40),
(41, '2024-08-29', 25.00, 16.00, 4.00, 29.00, 41),
(42, '2024-08-30', 10.50, 16.00, 1.68, 12.18, 42),
(43, '2024-08-31', 37.50, 16.00, 6.00, 43.50, 43),
(44, '2024-09-01', 8.00, 16.00, 1.28, 9.28, 44),
(45, '2024-09-02', 23.50, 16.00, 3.76, 27.26, 45),
(46, '2024-09-03', 13.00, 16.00, 2.08, 15.08, 46),
(47, '2024-09-04', 32.50, 16.00, 5.20, 37.70, 47),
(48, '2024-09-05', 8.50, 16.00, 1.36, 9.86, 48),
(49, '2024-09-06', 26.50, 16.00, 4.24, 30.74, 49),
(50, '2024-09-07', 7.50, 16.00, 1.20, 8.70, 50),
(51, '2024-09-08', 25.00, 16.00, 4.00, 29.00, 51),
(52, '2024-09-09', 10.50, 16.00, 1.68, 12.18, 52),
(53, '2024-09-10', 37.50, 16.00, 6.00, 43.50, 53),
(54, '2024-09-11', 8.00, 16.00, 1.28, 9.28, 54),
(55, '2024-09-12', 23.50, 16.00, 3.76, 27.26, 55),
(56, '2024-09-13', 13.00, 16.00, 2.08, 15.08, 56),
(57, '2024-09-14', 32.50, 16.00, 5.20, 37.70, 57),
(58, '2024-09-15', 8.50, 16.00, 1.36, 9.86, 58),
(59, '2024-09-16', 26.50, 16.00, 4.24, 30.74, 59),
(60, '2024-09-17', 7.50, 16.00, 1.20, 8.70, 60),
(61, '2024-09-18', 25.00, 16.00, 4.00, 29.00, 61),
(62, '2024-09-19', 10.50, 16.00, 1.68, 12.18, 62),
(63, '2024-09-20', 37.50, 16.00, 6.00, 43.50, 63),
(64, '2024-09-21', 8.00, 16.00, 1.28, 9.28, 64),
(65, '2024-09-22', 23.50, 16.00, 3.76, 27.26, 65),
(66, '2024-09-23', 13.00, 16.00, 2.08, 15.08, 66),
(67, '2024-09-24', 32.50, 16.00, 5.20, 37.70, 67),
(68, '2024-09-25', 8.50, 16.00, 1.36, 9.86, 68),
(69, '2024-09-26', 26.50, 16.00, 4.24, 30.74, 69),
(70, '2024-09-27', 7.50, 16.00, 1.20, 8.70, 70),
(71, '2024-09-28', 25.00, 16.00, 4.00, 29.00, 71),
(72, '2024-09-29', 10.50, 16.00, 1.68, 12.18, 72),
(73, '2024-09-30', 37.50, 16.00, 6.00, 43.50, 73),
(74, '2024-10-01', 8.00, 16.00, 1.28, 9.28, 74),
(75, '2024-10-02', 23.50, 16.00, 3.76, 27.26, 75),
(76, '2024-10-03', 13.00, 16.00, 2.08, 15.08, 76),
(77, '2024-10-04', 32.50, 16.00, 5.20, 37.70, 77),
(78, '2024-10-05', 8.50, 16.00, 1.36, 9.86, 78),
(79, '2024-10-06', 26.50, 16.00, 4.24, 30.74, 79),
(80, '2024-10-07', 7.50, 16.00, 1.20, 8.70, 80),
(81, '2024-10-08', 25.00, 16.00, 4.00, 29.00, 81),
(82, '2024-10-09', 10.50, 16.00, 1.68, 12.18, 82),
(83, '2024-10-10', 37.50, 16.00, 6.00, 43.50, 83),
(84, '2024-10-11', 8.00, 16.00, 1.28, 9.28, 84),
(85, '2024-10-12', 23.50, 16.00, 3.76, 27.26, 85),
(86, '2024-10-13', 13.00, 16.00, 2.08, 15.08, 86),
(87, '2024-10-14', 32.50, 16.00, 5.20, 37.70, 87),
(88, '2024-10-15', 8.50, 16.00, 1.36, 9.86, 88),
(89, '2024-10-16', 26.50, 16.00, 4.24, 30.74, 89),
(90, '2024-10-17', 7.50, 16.00, 1.20, 8.70, 90),
(91, '2024-10-18', 25.00, 16.00, 4.00, 29.00, 91),
(92, '2024-10-19', 10.50, 16.00, 1.68, 12.18, 92),
(93, '2024-10-20', 37.50, 16.00, 6.00, 43.50, 93),
(94, '2024-10-21', 8.00, 16.00, 1.28, 9.28, 94),
(95, '2024-10-22', 23.50, 16.00, 3.76, 27.26, 95),
(96, '2024-10-23', 13.00, 16.00, 2.08, 15.08, 96),
(97, '2024-10-24', 32.50, 16.00, 5.20, 37.70, 97),
(98, '2024-10-25', 8.50, 16.00, 1.36, 9.86, 98),
(99, '2024-10-26', 26.50, 16.00, 4.24, 30.74, 99),
(100, '2024-10-27', 7.50, 16.00, 1.20, 8.70, 100),
(101, '2024-10-28', 25.00, 16.00, 4.00, 29.00, 101),
(102, '2024-10-29', 10.50, 16.00, 1.68, 12.18, 102),
(103, '2024-10-30', 37.50, 16.00, 6.00, 43.50, 103),
(104, '2024-10-31', 8.00, 16.00, 1.28, 9.28, 104),
(105, '2024-11-01', 23.50, 16.00, 3.76, 27.26, 105),
(106, '2024-11-02', 13.00, 16.00, 2.08, 15.08, 106),
(107, '2024-11-03', 32.50, 16.00, 5.20, 37.70, 107),
(108, '2024-11-04', 8.50, 16.00, 1.36, 9.86, 108),
(109, '2024-11-05', 26.50, 16.00, 4.24, 30.74, 109),
(110, '2024-11-06', 7.50, 16.00, 1.20, 8.70, 110),
(111, '2024-11-07', 25.00, 16.00, 4.00, 29.00, 111),
(112, '2024-11-08', 10.50, 16.00, 1.68, 12.18, 112),
(113, '2024-11-09', 37.50, 16.00, 6.00, 43.50, 113),
(114, '2024-11-10', 8.00, 16.00, 1.28, 9.28, 114),
(115, '2024-11-11', 23.50, 16.00, 3.76, 27.26, 115),
(116, '2024-11-12', 13.00, 16.00, 2.08, 15.08, 116),
(117, '2024-11-13', 32.50, 16.00, 5.20, 37.70, 117),
(118, '2024-11-14', 8.50, 16.00, 1.36, 9.86, 118),
(119, '2024-11-15', 26.50, 16.00, 4.24, 30.74, 119),
(120, '2024-11-16', 7.50, 16.00, 1.20, 8.70, 120),
(121, '2024-11-17', 25.00, 16.00, 4.00, 29.00, 121),
(122, '2024-11-18', 10.50, 16.00, 1.68, 12.18, 122),
(123, '2024-11-19', 37.50, 16.00, 6.00, 43.50, 123),
(124, '2024-11-20', 8.00, 16.00, 1.28, 9.28, 124),
(125, '2024-11-21', 23.50, 16.00, 3.76, 27.26, 125),
(126, '2024-11-22', 13.00, 16.00, 2.08, 15.08, 126),
(127, '2024-11-23', 32.50, 16.00, 5.20, 37.70, 127),
(128, '2024-11-24', 8.50, 16.00, 1.36, 9.86, 128),
(129, '2024-11-25', 26.50, 16.00, 4.24, 30.74, 129),
(130, '2024-11-26', 7.50, 16.00, 1.20, 8.70, 130),
(131, '2024-11-27', 25.00, 16.00, 4.00, 29.00, 131),
(132, '2024-11-28', 10.50, 16.00, 1.68, 12.18, 132),
(133, '2024-11-29', 37.50, 16.00, 6.00, 43.50, 133),
(134, '2024-11-30', 8.00, 16.00, 1.28, 9.28, 134),
(135, '2024-12-01', 23.50, 16.00, 3.76, 27.26, 135),
(136, '2024-12-02', 13.00, 16.00, 2.08, 15.08, 136),
(137, '2024-12-03', 32.50, 16.00, 5.20, 37.70, 137),
(138, '2024-12-04', 8.50, 16.00, 1.36, 9.86, 138),
(139, '2024-12-05', 26.50, 16.00, 4.24, 30.74, 139),
(140, '2024-12-06', 7.50, 16.00, 1.20, 8.70, 140),
(141, '2024-12-07', 25.00, 16.00, 4.00, 29.00, 141),
(142, '2024-12-08', 10.50, 16.00, 1.68, 12.18, 142),
(143, '2024-12-09', 37.50, 16.00, 6.00, 43.50, 143),
(144, '2024-12-10', 8.00, 16.00, 1.28, 9.28, 144),
(145, '2024-12-11', 23.50, 16.00, 3.76, 27.26, 145),
(146, '2024-12-12', 13.00, 16.00, 2.08, 15.08, 146),
(147, '2024-12-13', 32.50, 16.00, 5.20, 37.70, 147),
(148, '2024-12-14', 8.50, 16.00, 1.36, 9.86, 148),
(149, '2024-12-15', 26.50, 16.00, 4.24, 30.74, 149),
(150, '2024-12-16', 7.50, 16.00, 1.20, 8.70, 150),
(151, '2024-12-17', 25.00, 16.00, 4.00, 29.00, 151),
(152, '2024-12-18', 10.50, 16.00, 1.68, 12.18, 152),
(153, '2024-12-19', 37.50, 16.00, 6.00, 43.50, 153),
(154, '2024-12-20', 8.00, 16.00, 1.28, 9.28, 154),
(155, '2024-12-21', 23.50, 16.00, 3.76, 27.26, 155),
(156, '2024-12-22', 13.00, 16.00, 2.08, 15.08, 156),
(157, '2024-12-23', 32.50, 16.00, 5.20, 37.70, 157),
(158, '2024-12-24', 8.50, 16.00, 1.36, 9.86, 158),
(159, '2024-12-25', 26.50, 16.00, 4.24, 30.74, 159),
(160, '2024-12-26', 7.50, 16.00, 1.20, 8.70, 160);
GO

-- Aclaracion Telegram (ejecutar despues de llenar 70% Cliente)
CREATE OR ALTER TRIGGER t_relacionReferido
ON Cliente
AFTER INSERT
AS
BEGIN
    DECLARE @idCliente INT;
    DECLARE @fecha_referido DATE;

    -- Seleccionar un id_Cliente aleatorio entre los 7 primeros registrados
    SELECT TOP 1 @idCliente = azar.id
    FROM (
        SELECT TOP 7 C.id
        FROM Cliente C
        ORDER BY NEWID()
    ) AS azar;

    -- Obtener solo la fecha actual sin la hora
    SET @fecha_referido = CAST(GETDATE() AS DATE);

    INSERT INTO ClienteConClienteReferido(
        idCliente,
        idClienteReferido, 
        fecha_referido
    )
    SELECT
        @idCliente, -- IdCliente que acaba de ser insertado
        I.id, -- El IdClienteReferido seleccionado aleatoriamente
        @fecha_referido -- La fecha de referencia
    FROM
        INSERTED I; -- La tabla INSERTED contiene las filas que se acaban de insertar
END;
GO

-- 30% despues del trigger
INSERT INTO Cliente (id, password, telefono, fecha_registro, correo, nombre, apellido, fecha_nac, nro_documento) VALUES
(71, 'Clie0071', '04265656565', '2024-01-05', 'ines.hernandez@email.com', 'Ines', 'Hernandez', '1987-03-03', 'E-81234567'),
(72, 'Clie0072', '04167878787', '2024-01-10', 'facundo.jimenez@email.com', 'Facundo', 'Jimenez', '1999-08-10', 'V-82345678'),
(73, 'Clie0073', '04129090909', '2024-01-15', 'julia.lopez@email.com', 'Julia', 'Lopez', '1983-05-15', 'V-83456789'),
(74, 'Clie0074', '04141010101', '2024-01-20', 'felipe.mendoza@email.com', 'Felipe', 'Mendoza', '1996-11-29', 'E-84567890'),
(75, 'Clie0075', '04263030303', '2024-01-25', 'clara.navarro@email.com', 'Clara', 'Navarro', '1980-02-12', 'V-85678901'),
(76, 'Clie0076', '04165050505', '2024-02-01', 'diego.ortiz@email.com', 'Diego', 'Ortiz', '1993-09-07', 'V-86789012'),
(77, 'Clie0077', '04127070707', '2024-02-05', 'silvina.ramirez@email.com', 'Silvina', 'Ramirez', '1985-07-04', 'E-87890123'),
(78, 'Clie0078', '04149090909', '2024-02-10', 'enzo.soto@email.com', 'Enzo', 'Soto', '1998-01-20', 'V-88901234'),
(79, 'Clie0079', '04261111111', '2024-02-15', 'lourdes.vega@email.com', 'Lourdes', 'Vega', '1978-04-08', 'V-89012345'),
(80, 'Clie0080', '04163333333', '2024-02-20', 'esteban.vargas@email.com', 'Esteban', 'Vargas', '1991-10-17', 'E-90123456'),
(81, 'Clie0081', '04125555555', '2024-02-25', 'martin.acosta@email.com', 'Martin', 'Acosta', '1984-06-23', 'V-91234567'),
(82, 'Clie0082', '04147777777', '2024-03-01', 'lucia.blanco@email.com', 'Lucia', 'Blanco', '1997-03-05', 'E-92345678'),
(83, 'Clie0083', '04269999999', '2024-03-05', 'damian.cabrera@email.com', 'Damian', 'Cabrera', '1989-11-18', 'V-93456789'),
(84, 'Clie0084', '04161010101', '2024-03-10', 'sofia.dominguez@email.com', 'Sofia', 'Dominguez', '1992-05-02', 'V-94567890'),
(85, 'Clie0085', '04123030303', '2024-03-15', 'gabriel.escalante@email.com', 'Gabriel', 'Escalante', '1986-07-29', 'E-95678901'),
(86, 'Clie0086', '04145050505', '2024-03-20', 'micaela.fuentes@email.com', 'Micaela', 'Fuentes', '1995-01-04', 'V-96789012'),
(87, 'Clie0087', '04267070707', '2024-03-25', 'juan.guzman@email.com', 'Juan', 'Guzman', '1983-09-16', 'V-97890123'),
(88, 'Clie0088', '04169090909', '2024-04-01', 'emilia.ibarra@email.com', 'Emilia', 'Ibarra', '1998-02-23', 'E-98901234'),
(89, 'Clie0089', '04122020202', '2024-04-05', 'santiago.jara@email.com', 'Santiago', 'Jara', '1980-10-10', 'V-99012345'),
(90, 'Clie0090', '04144040404', '2024-04-10', 'paula.keller@email.com', 'Paula', 'Keller', '1993-04-27', 'V-10012345'),
(91, 'Clie0091', '04266060606', '2024-04-15', 'agustin.lara@email.com', 'Agustin', 'Lara', '1985-12-09', 'E-10123456'),
(92, 'Clie0092', '04168080808', '2024-04-20', 'florencia.mora@email.com', 'Florencia', 'Mora', '1999-06-15', 'V-10234567'),
(93, 'Clie0093', '04121010101', '2024-04-25', 'cristian.nu�ez@email.com', 'Cristian', 'Nu�ez', '1982-02-03', 'V-10345678'),
(94, 'Clie0094', '04143030303', '2024-05-01', 'valentina.oliva@email.com', 'Valentina', 'Oliva', '1996-09-20', 'E-10456789'),
(95, 'Clie0095', '04265050505', '2024-05-05', 'manuel.paz@email.com', 'Manuel', 'Paz', '1988-05-11', 'V-10567890'),
(96, 'Clie0096', '04167070707', '2024-05-10', 'juliana.quiroga@email.com', 'Juliana', 'Quiroga', '1991-03-08', 'V-10678901'),
(97, 'Clie0097', '04129090909', '2024-05-15', 'esteban.reyes@email.com', 'Esteban', 'Reyes', '1984-11-01', 'E-10789012'),
(98, 'Clie0098', '04142020202', '2024-05-20', 'fernanda.sierra@email.com', 'Fernanda', 'Sierra', '1997-07-19', 'V-10890123'),
(99, 'Clie0099', '04264040404', '2024-05-25', 'ignacio.torres@email.com', 'Ignacio', 'Torres', '1981-09-04', 'V-10901234'),
(100, 'Clie0100', '04166060606', '2024-06-01', 'melina.ulloa@email.com', 'Melina', 'Ulloa', '1994-02-14', 'E-11012345');

-- 30% despues del trigger
INSERT INTO DireccionCliente (idCliente, idDireccion) VALUES
(71, 71),
(72, 72),
(73, 73),
(74, 74),
(75, 75),
(76, 76),
(77, 77),
(78, 78),
(79, 79),
(80, 80),
-- Clientes con dos direcciones (IDs 81 al 100)
(81, 81),
(81, 101),
(82, 82),
(82, 102),
(83, 83),
(83, 103),
(84, 84),
(84, 104),
(85, 85),
(85, 105),
(86, 86),
(86, 106),
(87, 87),
(87, 107),
(88, 88),
(88, 108),
(89, 89),
(89, 109),
(90, 90),
(90, 110),
(91, 91),
(91, 111),
(92, 92),
(92, 112),
(93, 93),
(93, 113),
(94, 94),
(94, 114),
(95, 95),
(95, 115),
(96, 96),
(96, 116),
(97, 97),
(97, 117),
(98, 98),
(98, 118),
(99, 99),
(99, 119),
(100, 100),
(100, 120);
GO

-- a) Pedido completo
CREATE OR ALTER PROCEDURE sp_SimularPedidoOptimizado
AS
BEGIN
    -- Al azar cliente
    DECLARE @idCliente INT = (SELECT TOP 1 id FROM Cliente ORDER BY NEWID());
    
    -- Al azar 1 plato
    DECLARE @idPlato INT = (SELECT TOP 1 id FROM Plato WHERE cantidadDisponible > 0 ORDER BY NEWID());
    DECLARE @precioPlato REAL = (SELECT precio FROM Plato WHERE id = @idPlato);
    
    -- Calcula totales
    DECLARE @costoEnvio REAL;
    SET @costoEnvio = FLOOR(1 + RAND() * 5);
    DECLARE @subTotal REAL = @precioPlato;
    DECLARE @montoIva REAL = @subTotal * 0.16;
    DECLARE @montoTotal REAL = @subTotal + @montoIva + @costoEnvio;
    
    DECLARE @idPedido INT;
    SELECT @idPedido = ISNULL(MAX(id), 0) + 1 FROM Pedido;

    INSERT INTO Pedido (id, cantidad_items, costo_envio, nota, tiempo_entrega, total)
    VALUES (@idPedido, 1, @costoEnvio, 'Pedido optimizado', 30, @montoTotal);

    INSERT INTO ClientePedido (idCliente, idPedido, fecha)
    VALUES (@idCliente, @idPedido, GETDATE());
    
    DECLARE @idPedidoDetalle INT;
    SELECT @idPedidoDetalle = ISNULL(MAX(id), 0) + 1 FROM PedidoDetalle;

    INSERT INTO PedidoDetalle (id, cantidad, nota, total, idPedido, idPlato)
    VALUES (@idPedidoDetalle, 1, 'Pedido', @precioPlato, @idPedido, @idPlato);
    
    -- Asigna un estado inicial para el pedido
    INSERT INTO PedidoEstadoPedido (idPedido, idEstadoPedido, fecha_inicio)
    VALUES (@idPedido, 1, GETDATE());
END;
GO

-- b) Asignar repartidor 
CREATE PROCEDURE sp_asignarRepartidor
    @idPedido INT
AS
BEGIN
    DECLARE @idRepartidor INT;
    
    SELECT TOP 1 @idRepartidor = r.id
    FROM Repartidor AS r
    WHERE r.estado = 'Activo'
    ORDER BY (
        SELECT COUNT(*) 
        FROM RepartidorPedido AS rp
        JOIN ClientePedido AS cp ON rp.idPedido = cp.idPedido
        WHERE rp.idRepartidor = r.id
        AND CONVERT(DATE, cp.fecha) = CONVERT(DATE, GETDATE())
    ) ASC;
    
    IF @idRepartidor IS NOT NULL
    BEGIN
        -- Asignar repartidor al pedido
        DECLARE @valor_tiempo_entrega INT;
        SET @valor_tiempo_entrega = FLOOR(5 + RAND() * (50 - 5 + 1));

        INSERT INTO RepartidorPedido (idRepartidor, idPedido, tiempo_entrega)
        VALUES (@idRepartidor, @idPedido, @valor_tiempo_entrega);

        SELECT 'Repartidor asignado correctamente' AS Mensaje, @idRepartidor AS IdRepartidor, @valor_tiempo_entrega AS TiempoEntrega;
    END
    ELSE
    BEGIN
        SELECT 'No hay repartidores disponibles en este momento' AS Mensaje;
    END
END;
GO

-- c) Reporte de pedidos de un comercio por dias
CREATE PROCEDURE sp_reportePedidosPorComercio
    @idComercio INT
AS
BEGIN
    SELECT 
        CONVERT(DATE, f.fecha_emision) AS Fecha,
        COUNT(DISTINCT pe.id) AS NumeroPedidos,
        (
            SELECT COUNT(DISTINCT pep.idPedido)
            FROM PedidoEstadoPedido AS pep
            JOIN Pedido AS pe2 ON pep.idPedido = pe2.id
            JOIN Factura AS f2 ON pe2.id = f2.idPedido
            JOIN PedidoDetalle AS pd2 ON pe2.id = pd2.idPedido
            JOIN Plato AS pl2 ON pd2.idPlato = pl2.id
            JOIN Seccion AS s2 ON pl2.idSeccion = s2.id
            JOIN Menu AS m2 ON s2.idMenu = m2.id
            WHERE m2.idComercio = @idComercio
              AND CONVERT(DATE, f2.fecha_emision) = CONVERT(DATE, f.fecha_emision)
              AND pep.idEstadoPedido = 6 -- Entregado
              AND NOT EXISTS (
                  SELECT 1 FROM PedidoEstadoPedido pep2
                  WHERE pep2.idPedido = pep.idPedido AND pep2.idEstadoPedido = 10 -- Reembolsado
              )
        ) AS TotalVentas
    FROM Factura AS f
    JOIN Pedido AS pe ON f.idPedido = pe.id
    JOIN PedidoDetalle AS pd ON pe.id = pd.idPedido
    JOIN Plato AS pl ON pd.idPlato = pl.id
    JOIN Seccion AS s ON pl.idSeccion = s.id
    JOIN Menu AS m ON s.idMenu = m.id
    WHERE m.idComercio = @idComercio
    GROUP BY CONVERT(DATE, f.fecha_emision)
    ORDER BY Fecha;
    
    -- Top 3 platos por dia
    WITH PlatoDia AS (
        SELECT 
            CONVERT(DATE, f.fecha_emision) AS Fecha,
            pl.id AS PlatoID,
            pl.nombre AS PlatoNombre,
            SUM(pd.cantidad) AS CantidadTotal,
            ROW_NUMBER() OVER (
                PARTITION BY CONVERT(DATE, f.fecha_emision) 
                ORDER BY SUM(pd.cantidad) DESC
            ) AS Ranking
        FROM PedidoDetalle pd
        JOIN Plato pl ON pd.idPlato = pl.id
        JOIN Seccion s ON pl.idSeccion = s.id
        JOIN Menu m ON s.idMenu = m.id
        JOIN Pedido pe ON pd.idPedido = pe.id
        JOIN Factura f ON pe.id = f.idPedido
        WHERE m.idComercio = @idComercio
        GROUP BY CONVERT(DATE, f.fecha_emision), pl.id, pl.nombre
    )
    SELECT 
        Fecha,
        PlatoID,
        PlatoNombre,
        CantidadTotal,
        Ranking
    FROM PlatoDia
    WHERE Ranking <= 3
    ORDER BY Fecha, Ranking;
END;
GO

-- d) Registrar nuevo plato
CREATE PROCEDURE sp_registrarNuevoPlato
    @idComercio INT,
    @idMenu INT,
    @idSeccion INT,
    @nombrePlato NVARCHAR(50),
    @precio REAL,
    @descripcion NVARCHAR(255),
    @cantidadDisponible INT,
    @orden INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Comercio WHERE id = @idComercio AND estaActivo = 1)
    BEGIN
        SELECT 'El comercio no existe o no está activo' AS Error;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Menu WHERE id = @idMenu AND idComercio = @idComercio)
    BEGIN
        SELECT 'El menú no pertenece a este comercio' AS Error;
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Seccion WHERE id = @idSeccion AND idMenu = @idMenu)
    BEGIN
        SELECT 'La sección no existe en este menú' AS Error;
        RETURN;
    END

    DECLARE @proximoID INT;
    SELECT @proximoID = ISNULL(MAX(id), 0) + 1 FROM Plato;
    
    -- Insertar el plato
    INSERT INTO Plato (
        id,
        nombre, 
        orden, 
        cantidadDisponible, 
        precio, 
        descripcion, 
        idSeccion
    )
    VALUES (
        @proximoID,
        @nombrePlato,
        @orden,
        @cantidadDisponible,
        @precio,
        @descripcion,
        @idSeccion
    );
    SELECT 'Plato registrado exitosamente' AS Resultado, @proximoID AS idNuevoPlato;
END;
GO