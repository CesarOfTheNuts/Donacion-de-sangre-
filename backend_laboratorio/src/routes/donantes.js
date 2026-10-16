const router = require('express').Router();
const { sql, poolPromise } = require('../db');
const auth = require('../middleware/auth');
const { GRUPOS, normalizarGenero, limpio } = require('../util');

// POST /api/donantes
// Cada usuario tiene un solo perfil de donante: si ya existe, se actualiza.
router.post('/', auth, async (req, res) => {
  const b = req.body || {};
  const nombre = limpio(b.nombre), telefono = limpio(b.telefono), ubicacion = limpio(b.ubicacion);
  if (!nombre || !telefono || !b.grupo_sanguineo || !ubicacion)
    return res.status(400).json({ error: 'nombre, telefono, grupo_sanguineo y ubicacion son obligatorios' });
  if (!GRUPOS.includes(b.grupo_sanguineo))
    return res.status(400).json({ error: 'grupo_sanguineo inválido' });

  try {
    const pool = await poolPromise;
    const rq = pool.request()
      .input('uid', sql.Int, req.user.id)
      .input('nombre', sql.NVarChar, nombre)
      .input('telefono', sql.NVarChar, telefono)
      .input('grupo', sql.NVarChar, b.grupo_sanguineo)
      .input('genero', sql.NVarChar, normalizarGenero(b.genero))
      .input('ubicacion', sql.NVarChar, ubicacion)
      .input('ultima', sql.Date, b.ultima_donacion || null);

    const r = await rq.query(`
      IF EXISTS (SELECT 1 FROM Donantes WHERE usuario_id = @uid)
        UPDATE Donantes
           SET nombre = @nombre, telefono = @telefono, grupo_sanguineo = @grupo,
               genero = @genero, ubicacion = @ubicacion, ultima_donacion = @ultima, disponible = 1
        OUTPUT INSERTED.*
         WHERE usuario_id = @uid
      ELSE
        INSERT INTO Donantes (usuario_id, nombre, telefono, grupo_sanguineo, genero, ubicacion, ultima_donacion, fecha_registro)
        OUTPUT INSERTED.*
        VALUES (@uid, @nombre, @telefono, @grupo, @genero, @ubicacion, @ultima, SYSUTCDATETIME())`);
    res.status(201).json(r.recordset[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /api/donantes?grupo=O+&ubicacion=Santo Domingo
router.get('/', auth, async (req, res) => {
  const { grupo, ubicacion } = req.query;
  try {
    const pool = await poolPromise;
    const rq = pool.request();
    let where = 'WHERE disponible = 1';
    if (grupo) { where += ' AND grupo_sanguineo = @grupo'; rq.input('grupo', sql.NVarChar, grupo); }
    if (limpio(ubicacion)) { where += ' AND ubicacion LIKE @ub'; rq.input('ub', sql.NVarChar, `%${ubicacion.trim()}%`); }
    const r = await rq.query(`SELECT * FROM Donantes ${where} ORDER BY fecha_registro DESC`);
    res.json(r.recordset);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /api/donantes/:id
router.get('/:id', auth, async (req, res) => {
  try {
    const pool = await poolPromise;
    const r = await pool.request().input('id', sql.Int, req.params.id)
      .query('SELECT * FROM Donantes WHERE id = @id');
    if (!r.recordset.length) return res.status(404).json({ error: 'Donante no encontrado' });
    res.json(r.recordset[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
