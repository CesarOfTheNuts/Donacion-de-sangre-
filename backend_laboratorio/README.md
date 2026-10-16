# Backend – App de donación de sangre

Node.js + Express + SQL Server. El login lo hace **Firebase Auth** en la app Flutter;
el backend solo verifica el token de Firebase y guarda los datos en SQL Server.

## Puesta en marcha
1. SQL Server: ejecuta `sql/01_schema.sql` (si ya habías corrido el esquema anterior, ejecuta `sql/02_migracion_firebase.sql`).
   Si ya tenías `LaboratorioDB` con Firebase, ejecuta además `sql/03_perfil_columnas.sql` (agrega ubicación, género y grupo sanguíneo al perfil).
2. Firebase Console > Configuración del proyecto > Cuentas de servicio > **Generar nueva clave privada**.
   Guarda el JSON como `firebase-key.json` en esta carpeta (no lo subas a git).
3. `copy .env.example .env` y completa los datos de SQL Server.
4. `npm install` y `npm start` -> http://localhost:3000

## Endpoints (todos requieren `Authorization: Bearer <token de Firebase>`)
| Método | Ruta | Descripción |
|---|---|---|
| GET | /api/auth/me | Perfil (crea al usuario en SQL Server la primera vez) |
| PUT | /api/auth/me | Actualizar nombre, teléfono, ubicación, género, grupo sanguíneo |
| POST | /api/donantes | Registrar donante |
| GET | /api/donantes?grupo=O+&ubicacion= | Buscar donantes |
| POST | /api/solicitudes | Crear solicitud |
| GET | /api/solicitudes?grupo=A+ | Listar solicitudes abiertas |
| GET | /api/solicitudes/:id | Detalle |
| PATCH | /api/solicitudes/:id/estado | Abierta / Cubierta / Cancelada |
