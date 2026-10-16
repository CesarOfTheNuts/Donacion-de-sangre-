-- Base de datos sencilla para la app de donación de sangre
IF DB_ID('LaboratorioDB') IS NULL CREATE DATABASE LaboratorioDB;
GO
USE LaboratorioDB;
GO

CREATE TABLE Usuarios (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    firebase_uid   NVARCHAR(128)  NOT NULL UNIQUE,   -- ID del usuario en Firebase Auth
    nombre         NVARCHAR(100)  NOT NULL,
    email          NVARCHAR(150)  NOT NULL UNIQUE,
    telefono       NVARCHAR(20)   NULL,
    ubicacion      NVARCHAR(150)  NULL,
    genero         NVARCHAR(10)   NULL CHECK (genero IN ('Male','Female','Other')),
    grupo_sanguineo NVARCHAR(3)   NULL
        CHECK (grupo_sanguineo IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    fecha_creacion DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE Donantes (
    id               INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id       INT            NOT NULL REFERENCES Usuarios(id),
    nombre           NVARCHAR(100)  NOT NULL,
    telefono         NVARCHAR(20)   NOT NULL,
    grupo_sanguineo  NVARCHAR(3)    NOT NULL
        CHECK (grupo_sanguineo IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    genero           NVARCHAR(10)   NULL CHECK (genero IN ('Male','Female','Other')),
    ubicacion        NVARCHAR(150)  NOT NULL,
    ultima_donacion  DATE           NULL,
    disponible       BIT            NOT NULL DEFAULT 1,
    fecha_registro   DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE Solicitudes (
    id                 INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id         INT            NOT NULL REFERENCES Usuarios(id),
    paciente           NVARCHAR(100)  NOT NULL,
    grupo_sanguineo    NVARCHAR(3)    NOT NULL
        CHECK (grupo_sanguineo IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    bolsas             INT            NOT NULL CHECK (bolsas > 0),
    telefono           NVARCHAR(20)   NOT NULL,
    telefono_emergencia NVARCHAR(20)  NOT NULL,
    causa              NVARCHAR(150)  NOT NULL,
    genero             NVARCHAR(10)   NULL CHECK (genero IN ('Male','Female','Other')),
    ubicacion          NVARCHAR(150)  NULL,
    fecha_limite       DATE           NOT NULL,
    otros              NVARCHAR(300)  NULL,
    estado             NVARCHAR(15)   NOT NULL DEFAULT 'Abierta'
        CHECK (estado IN ('Abierta','Cubierta','Cancelada')),
    fecha_creacion     DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_Donantes_Grupo     ON Donantes(grupo_sanguineo);
CREATE INDEX IX_Solicitudes_Grupo  ON Solicitudes(grupo_sanguineo, estado);
GO
