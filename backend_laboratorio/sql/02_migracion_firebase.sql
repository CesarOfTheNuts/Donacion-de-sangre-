-- Solo si YA ejecutaste el esquema anterior (el que tenía password_hash).
-- Si vas a crear la base desde cero con 01_schema.sql, ignora este archivo.
USE LaboratorioDB;
GO
ALTER TABLE Usuarios ADD firebase_uid NVARCHAR(128) NULL;
GO
-- Los usuarios viejos no existen en Firebase, así que se borran junto con sus datos de prueba
DELETE FROM Solicitudes;
DELETE FROM Donantes;
DELETE FROM Usuarios;
GO
ALTER TABLE Usuarios DROP COLUMN password_hash;
ALTER TABLE Usuarios ALTER COLUMN firebase_uid NVARCHAR(128) NOT NULL;
ALTER TABLE Usuarios ADD CONSTRAINT UQ_Usuarios_firebase_uid UNIQUE (firebase_uid);
GO
