-- Ejecutar UNA vez si ya tienes la base LaboratorioDB creada (con firebase_uid).
-- Agrega los datos de perfil a Usuarios. Es seguro ejecutarlo más de una vez.
USE LaboratorioDB;
GO
IF COL_LENGTH('Usuarios', 'ubicacion') IS NULL
    ALTER TABLE Usuarios ADD ubicacion NVARCHAR(150) NULL;
GO
IF COL_LENGTH('Usuarios', 'genero') IS NULL
    ALTER TABLE Usuarios ADD genero NVARCHAR(10) NULL
        CONSTRAINT CK_Usuarios_genero CHECK (genero IN ('Male','Female','Other'));
GO
IF COL_LENGTH('Usuarios', 'grupo_sanguineo') IS NULL
    ALTER TABLE Usuarios ADD grupo_sanguineo NVARCHAR(3) NULL
        CONSTRAINT CK_Usuarios_grupo CHECK (grupo_sanguineo IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'));
GO
