require('dotenv').config();
const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const { sql, poolPromise } = require('../db');

// --- Inicializa Firebase Admin con la llave de servicio ---
const keyPath = path.resolve(process.env.FIREBASE_KEY_PATH || './firebase-key.json');
if (!fs.existsSync(keyPath)) {
  console.error(`No se encontró la llave de Firebase en: ${keyPath}`);
  console.error('Descárgala en Firebase Console > Configuración del proyecto > Cuentas de servicio.');
  process.exit(1);
}
if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(JSON.parse(fs.readFileSync(keyPath, 'utf8'))) });
}

// Busca al usuario por su firebase_uid; si es su primera vez, lo crea en SQL Server
async function obtenerOCrearUsuario(decoded) {
  const pool = await poolPromise;
  const buscar = () => pool.request().input('uid', sql.NVarChar, decoded.uid)
    .query('SELECT id FROM Usuarios WHERE firebase_uid = @uid');

  let r = await buscar();
  if (r.recordset.length) return r.recordset[0].id;

  const email = decoded.email || `${decoded.uid}@sin-correo.local`;
  const nombre = decoded.name || email.split('@')[0];
  try {
    const ins = await pool.request()
      .input('uid', sql.NVarChar, decoded.uid)
      .input('nombre', sql.NVarChar, nombre)
      .input('email', sql.NVarChar, email)
      .query(`INSERT INTO Usuarios (firebase_uid, nombre, email, fecha_creacion)
              OUTPUT INSERTED.id VALUES (@uid, @nombre, @email, SYSUTCDATETIME())`);
    return ins.recordset[0].id;
  } catch (e) {
    // Dos peticiones simultáneas de un usuario nuevo: la otra ya lo creó
    if (e.number === 2627 || e.number === 2601) {
      r = await buscar();
      if (r.recordset.length) return r.recordset[0].id;
    }
    throw e;
  }
}

module.exports = async function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Token requerido' });

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(token);
  } catch {
    return res.status(401).json({ error: 'Token inválido o expirado' });
  }

  try {
    const id = await obtenerOCrearUsuario(decoded);
    req.user = { id, uid: decoded.uid, email: decoded.email };
    next();
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
